# Ledger and state files

All orchestration state lives in `.orchestration/` in the **main checkout** of the target repo — even when your own session runs in a worktree, where `.git` is a file, not a folder. Nothing important lives only in your context: after compaction or resume, a SessionStart hook re-injects the ledger (it resolves the main checkout the same way), and you continue from it.

## Setup (once per repo)

```bash
common=$(git rev-parse --path-format=absolute --git-common-dir)   # the main checkout's .git folder
root=$(dirname "$common")                                         # the main checkout
mkdir -p "$root/.orchestration/reports" "$root/.orchestration/briefs"
grep -qxF '.orchestration/' "$common/info/exclude" 2>/dev/null || echo '.orchestration/' >> "$common/info/exclude"
```

`info/exclude` keeps it out of commits without touching `.gitignore`. Use `$root/.orchestration/…` (an absolute path) everywhere: in the ledger, in CLI briefs' report paths, and when reading reports (desktop briefs point at the app's shared notes folder; [why](backend-desktop.md#reports-and-permissions)).

## Layout

```
.orchestration/
├─ ledger.md            # this orchestration's live state
├─ retros.md            # every retro, appended in arrival order
├─ briefs/T<n>.md       # the brief sent to each worker (and follow-up messages)
├─ reports/T<n>.md      # each worker's full report
└─ archive/<date>-<slug>/   # earlier, finished orchestrations
```

## Task ids

Task ids keep counting across the project's orchestrations, so the user's session list never shows two sessions with the same `T<n>`. A new orchestration's first task is one past the highest id in the archived ledgers and the `orch/T<n>` branches (local and on `origin`, which still count when the archive is gone); with neither, it is `T1`. Work it out after archiving the previous run, before the breakdown, and number the breakdown's tasks up from it. A resumed orchestration keeps its ids.

```bash
last=$( { grep -ho '^| T[0-9][0-9]*' "$root"/.orchestration/archive/*/ledger.md 2>/dev/null
          git branch -a --format='%(refname:short)' | grep 'orch/T[0-9]'; } \
        | grep -o 'T[0-9][0-9]*' | tr -d T | sort -n | tail -1)
next=$(( ${last:-0} + 1 ))   # the first task of this orchestration is T$next
```

## Archiving a finished orchestration

Each orchestration has its own ledger, reports and retros, so a new one must not overwrite a finished one's files. When `ledger.md` says `Status: done`, move everything in `.orchestration/` except `archive/` into `.orchestration/archive/<YYYY-MM-DD>-<short goal slug>/` (add `-2`, `-3` if that name exists), then start the new ledger. Never delete an earlier orchestration's files.

```bash
dest="$root/.orchestration/archive/<YYYY-MM-DD>-<slug>"
mkdir -p "$dest"
for f in "$root/.orchestration"/*; do [ "$(basename "$f")" = archive ] || mv "$f" "$dest/"; done
```

Branches are not archived. After the move, list the finished run's branches — `git branch --list 'orch/T*'` and `git branch -r --merged origin/<base> | grep 'origin/orch/T'` — and ask the user whether to delete them locally and on the remote. Never delete without a yes. If the archived ledger shows this question was left unanswered in the previous run (or answered no), don't ask again: mention the leftover branches in one line of your next message instead, and log it as `[event]`, not `[ask-user]`.

## Branch names

A task's branch is `orch/T<n>`. If that name is already taken (locally or on `origin`) when the task starts, use `orch/T<n>-<short slug>` instead, write it in the ledger and the brief, and log it in Events. On the CLI backend, pass `T<n>-<short slug>` as the task id, so the launcher's worktree and branch get the same name.

## `ledger.md`

```markdown
# Orchestration: <goal>
Started: <date> · Backend: desktop|cli · Base branch: <branch> · Mode: full|lite · Status: planning|running|wrap-up|done

| id | task | owns (files/globs) | depends | tier | risk | placement | session/run | branch | PR | status |
|----|------|--------------------|---------|------|------|-----------|-------------|--------|----|--------|
| T1 | ... | src/db/schema.ts | — | deep | high | self | — | orch/T1 | #12 | merged |
| T2 | ... | src/api/users/** | T1 | standard | normal | worker | local_ab12 | orch/T2 | #13 | in-review |

## Events
- <time> [event] T2 started (local_ab12, sonnet/medium)
- <time> [ask-user] T2 Should PUT return 422 or 400 on validation errors? → 422
- <time> [event] T2 report received → reports/T2.md
```

Every Events line starts with a kind tag after the time; the tags and what each counts toward are in [workflow-learning.md](workflow-learning.md#event-kinds).

- The header's `Status:` must stay on line 2 — the hook reads the first lines, and stays silent once it says `done`.
- `session/run`: the desktop session id (`local_…`) or the CLI `session_id`.
- `branch`: the PR's branch on GitHub: `orch/T<n>`, or `orch/T<n>-<slug>` when that name was taken (see Branch names). A desktop worker's local branch has an app-chosen name; note it in the Events line when the session starts.
- An expert view logs `[expert] <target> <experts>: <n> proposed, <k> adopted`, and each recommendation the user declines `[expert] declined <target> E<n> "<thing>": <reason>` ([expert-view.md](expert-view.md#adopt-and-decline)).
- Log a `[failed] T<n> …` line each time a task fails a round (see the two-failure limit); a round lost to the environment is `[env]`, not `[failed]`.

## Task statuses

`planned → running → blocked → pr-open → in-review → changes-requested → reviewed → merged`, or `failed` / `dropped`.

| Status | Means |
|---|---|
| `planned` | approved, not started (waiting for dependencies or a free slot) |
| `running` | worker (or you, for `self`) is working |
| `blocked` | waiting on an answer, a start click, or the user |
| `pr-open` | report received, PR not yet reviewed |
| `in-review` | you are reviewing |
| `changes-requested` | fixes sent back to the worker |
| `reviewed` | ready for the user to merge |
| `merged` | the user merged it |

## Update rule

Update the ledger **on every event** — start, question, answer, report, review, merge, failure — before doing anything else.

## `retros.md`

Append each report's `## Retro` section under a heading naming the task:

```markdown
## T2 (worker, standard)
<the report's Went well / Went badly / Improve sections, unchanged>
```

Write one for every `self` task too, in the same format.

## A ledger from an older version

The plugin may be updated while a run is in progress, and a new session then resumes a ledger an older version wrote. Fill in what it lacks and never re-plan approved work:

- **no `risk` column:** add one and tag every task right away, each by its own change: from its PR's diff if it has one, otherwise from its owned files ([risk tags](reviews.md#risk-tags)). There is no default here: authentication, security, money, deleting data, migrations and CI files are `high`.
- **no `Mode:` in the header:** the run is `full`, unless the user asked for lite. Add `Mode: full` to the header.
- **older event lines** without kind tags: the counts at wrap-up are partial ([workflow learning](workflow-learning.md#counts-table)).
- **briefs already sent** keep their older fields; workers on the new version fill in the defaults themselves.

Log it once as `[event] ledger from an older plugin version: added <what>`.
