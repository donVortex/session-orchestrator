# CLI backend

Workers run as headless `claude -p` processes, each in its own git worktree, launched by `scripts/cli-worker.sh` in this plugin.

## When to use it

At intake, use this backend when:
1. `mcp__ccd_session__start_session` cannot be loaded (you are not in the desktop app), **and**
2. `claude --version` succeeds in Bash.

If neither backend is available, stop and tell the user what is missing. Record the choice in the ledger header (`Backend: cli`).

## The launcher

The script lives at `<plugin root>/scripts/cli-worker.sh` — two levels up from this file. Run it from inside the **main checkout** (any subfolder works).

| Command | Does |
|---|---|
| `bash <plugin>/scripts/cli-worker.sh start <task-id> <base-branch> <model> <effort> <brief-file>` | Creates (or reuses) worktree `<repo>-wt/<task-id>` on branch `orch/<task-id>`, then runs the brief as a headless worker. It reuses an existing `orch/<task-id>` on purpose (re-spawning within one run), so a name left over from an earlier run must not be passed: use `T<n>-<slug>` instead (see [ledger.md](ledger.md)). |
| `bash <plugin>/scripts/cli-worker.sh resume <task-id> <session-id> <message-file> [effort]` | Sends a follow-up (an answer, review fixes) to the same worker conversation. Pass an effort to raise it for this round, e.g. after a failed round ([escalation](model-tiers.md#escalation)). |
| `bash <plugin>/scripts/cli-worker.sh remove <task-id>` | Removes the worktree after the PR is merged. The branch is kept. |

- `<model>` and `<effort>` are the task tier's **worker session** values from [model-tiers.md](model-tiers.md).
- Write the brief and every follow-up message to a file first (e.g. `.orchestration/briefs/<task-id>.md`); the launcher reads them from files so quoting never breaks.
- Exit codes: `1` git failure, `2` usage or invalid id, `3` base branch not found, `4` the directory exists but is not this task's worktree, `5` no worktree (resume/remove). Anything else is the worker's own exit code.

## Running workers

- **Always** launch `start` and `resume` with the Bash tool's `run_in_background: true`. You are notified when the worker exits; never poll or sleep.
- Respect `max_parallel_workers` from [model-tiers.md](model-tiers.md): count running background workers before starting another.
- The launcher's stdout is the worker's JSON result. Read `session_id` from it and record it in the ledger's `session/run` column; `resume` needs it.
- The JSON's `result` is only a summary. The full report is at `.orchestration/reports/<task-id>.md` in the main checkout — read that.

## After a worker exits

| Report status | Do |
|---|---|
| `done` | Ledger → `pr-open`, append the retro to `retros.md`, review the PR. |
| `blocked` | Read the question in the report. Answer it if you can; otherwise ask the user. Write the answer to a file and `resume`. |
| `failed`, or no report file | Count a failure for the task. Resume once with what went wrong; a second failure escalates to the user. |

Review fixes go back the same way: write the requested changes to a file and `resume`.

## Permissions

`-p` runs start in Manual mode, so the launcher always passes `--permission-mode acceptEdits --settings <plugin>/settings/worker-allowlist.json --add-dir <main checkout>/.orchestration` (the last so workers can write their report). It never uses a bypass mode. Edits are allowed inside the worktree and `.orchestration/` only; writes anywhere else are denied.

On Windows the launcher also points workers at Git Bash (`CLAUDE_CODE_GIT_BASH_PATH`, unless already set) and turns off the PowerShell tool, because every shell rule in the allowlist is a `Bash(...)` rule. A worker that reports "no Bash tool" means Git Bash wasn't found: tell the user to set `CLAUDE_CODE_GIT_BASH_PATH` to their `bash.exe`.

The allowlist covers reading and editing files, skills and subagents, `git` commits, pushing to `orch/*` branches only, and `gh pr`. The project's own test, lint and build commands are not in it. At intake, tell the user to add them to the project's `.claude/settings.json` (e.g. `"Bash(npm test*)"`), which workers load from their worktree. If a worker still reports a denied command, tell the user which one and resume the worker after they add it. Do not edit permission settings yourself.

## Cleanup

After the user merges a task's PR: `cli-worker.sh remove <task-id>`. If it fails with uncommitted changes, report it to the user rather than forcing removal.
