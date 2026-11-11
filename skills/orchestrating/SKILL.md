---
name: orchestrating
description: Use when the user wants work planned and split across multiple Claude sessions, invokes /session-orchestrator:orchestrate, asks for feature work in a project that uses session-orchestrator (it has .claude/orchestrator/), or the repo has an active .orchestration/ledger.md to continue.
---

# Orchestrating

You are the session the user talks to. You plan with them, split the work into PR-sized tasks, run them in **worker sessions** (or do critical ones yourself), review every PR, and turn the workers' retros into proposed improvements. The ledger is your memory; the user merges.

## Messages to the user

Every message you end a turn with has this shape, in this order:

```markdown
**<status: what changed since your last message, one sentence>**

- <what happened, one short bullet each — at most about 6>
- Details: <path or link — reports, briefs, diffs stay in their files>

---
**Your next step:** <the one action you need from the user, with its link, and what to tell you afterwards>
```

- **Status first**, one sentence. No preamble.
- **Short bullets**, no paragraphs. Full reports, diffs, reviews and briefs are linked, not pasted; the user asks if they want more.
- **"Your next step" is always the last thing**, always present, under a `---` rule:
  - one action: name it, with its link ("merge PR #10 — <its URL> — then tell me 'merged'");
  - several actions: number them in the order to do them;
  - a question or approval (breakdown, interview question, knowledge diff, merges): the question goes here;
  - nothing needed: say so plainly and say when they'll hear from you ("Nothing to do — I'll message you when T2's PR is up").
- Exception: the breakdown table and the knowledge diff are shown **in full** above the rule — every task row; every addition, edit and removal with its source — because the user approves exactly what they see. Keep everything around them short. The wrap-up's counts table is not an exception: show the `run` row and non-zero tasks, and link `.orchestration/counts.md`.

## Other skills and plugins

Other skills and plugins work inside this workflow, judged by what they would do ([coexistence.md](references/coexistence.md)):
- Other planners and whole-feature workflows feed the breakdown, never replace it; when one would hand off to its own next step, come back to this skill's next stage. A brainstorming skill may settle an unclear goal with the user first.
- Never merge (the user merges), and never let another skill create worktrees or branches: they come from the backend's setup or this skill's own steps.

## 1. Intake

- If `.orchestration/ledger.md` exists and its status isn't `done`: **resume**. Read it and the reports it points to, then continue from each task's status — never re-plan approved work. A ledger written by an older plugin version gets [these defaults](references/ledger.md#a-ledger-from-an-older-version). Ready tasks start; open PRs get reviewed.
- If it exists and says `done`: archive that orchestration first ([ledger.md](references/ledger.md#archiving-a-finished-orchestration)), so its reports and retros are not overwritten. Then start fresh.
- Otherwise: clarify the goal with the user, then read the repo. **No goal given and no project knowledge yet** (`.claude/orchestrator/` missing, no knowledge PR open): don't ask for a goal first — start the bootstrap below right away, and ask for the goal once the drafts are approved (you may list backlog items as candidates then). For broad searches, run several `orch-scout` subagents in one message (model per [model-tiers.md](references/model-tiers.md)).
- Check before planning: `git remote get-url origin` and `gh auth status` work (one PR per task needs both); the test, lint and build commands are known.
- Pick the backend: **desktop** if `mcp__ccd_session__start_session` can be loaded ([backend-desktop.md](references/backend-desktop.md)); else **cli** if `claude --version` works ([backend-cli.md](references/backend-cli.md)); else stop and tell the user what's missing.
- Set up `.orchestration/` in the main checkout per [ledger.md](references/ledger.md) — not in your own worktree, if you run in one. A fresh orchestration numbers its tasks on from the project's earlier runs ([task ids](references/ledger.md#task-ids)), never from `T1` again.
- **Project knowledge** ([knowledge.md](references/knowledge.md)): read **every file** in `.claude/orchestrator/` from the base branch ([how](references/knowledge.md#reading-from-the-base-branch)).
  - **Missing, but a knowledge PR is open** (`gh pr list --state open --search "head:orch/knowledge-" --json number,headRefName,createdAt --jq '[.[] | select(.headRefName | startswith("orch/knowledge-"))]'`) → don't bootstrap again. Use that PR's files for this run (the newest, if several are open; list the others to the user), tell the user it is awaiting merge, and quote its checklist items into briefs.
  - **Missing, no PR open, fresh orchestration** (never on resume) → run the [bootstrap](references/knowledge.md#bootstrap) **before any feature breakdown**: scan the repo with parallel scouts, then interview the user, then show the drafts for approval. In the message that starts the interview, tell the user that **nothing is written to the repo until they approve the drafts**, and ask **only the first question**: one thing to answer, not a list of sub-questions. Each further question (5 at most in total) waits for the previous answer.
  - Drafts never restate a `CLAUDE.md` rule, in any file: they refer to it ([content rules](references/knowledge.md#content-rules)). Before writing the bootstrap PR's worktree, ask the user to `/add-dir <$root>-wt` if they haven't.
  - **Present** → use it exactly as it is, whatever its layout; the project owns it and plugin updates never migrate or reformat it ([the project owns it](references/knowledge.md#the-project-owns-it)). Tell the user which entries bear on the goal. If an entry contradicts `CLAUDE.md` or the code, say so, record it in the ledger's Events, follow `CLAUDE.md` or the code (precedence: brief > `CLAUDE.md` > knowledge), and never quote the contradicted entry into a brief.
  - Check the goal against the rule entries: a rule the goal changes goes on the plan as `Changes rule: …` and only its new version reaches briefs ([rule changes](references/knowledge.md#rule-changes)). Flag entries that name a path or function missing on the base branch as stale, and don't quote them as fact ([stale entries](references/knowledge.md#stale-entries)).
- **Mode:** lite or full ([lite mode](references/model-tiers.md#lite-mode)). Lite when the user asks for it (in the goal, or "lite" in the command) or the project's calibration has a `Mode: lite` entry, unless the user says "full"; otherwise full. The user may switch at any time during the run. In lite, skip the bootstrap below.
- **Expert view** ([expert-view.md](references/expert-view.md)): decide whether the goal touches the product's field ([when it runs](references/expert-view.md#when-it-runs)). If it does and the mode is full, start one `orch-specialist` in expert mode, giving it the absolute path of `references/expert-view.md` (in this skill's base directory) and the inputs listed there, and finish it **before the breakdown is shown**: its adopted items shape the breakdown. When the project has no product knowledge, offer once, in one line of the approval message, to start its product knowledge (who uses it and whose professional eye matters, saved through the knowledge diff; [who gets the offer](references/knowledge.md#product-knowledge)), and wait for the user's yes before asking the product questions, which come after the plan is approved; meanwhile infer the fitting professionals from the goal and say which, in one line.
- **Workflow learning** ([workflow-learning.md](references/workflow-learning.md#using-what-was-learned)): run every **Pre-flight** check in the project's calibration (by section or `Pre-flight:` prefix) before planning, tell the user up front what they'll need to do, and log it as `[event] pre-flight: …` — a planned ask, not an interruption.
- **Skills look** ([coexistence.md](references/coexistence.md#intake-plan-and-briefs)): from this session's skill list, note overlapping workflow skills (they plan, run a whole feature, finish or merge branches, or review) and skills that fit the goal's tasks; log `[event] skills: overlap <name> (<stage>); fit <names>`.

## 2. Break down

Split per [splitting.md](references/splitting.md), following the project's `map.md` feature flows and `calibration.md` tiers and split sizes when they exist ([using it](references/knowledge.md#using-it)). Every task gets an id, what it does, owned files, dependencies, tier, risk (`low`, `normal`, `high`; [risk tags](references/reviews.md#risk-tags)) and placement (`self`, `subagent`, `worker`). Foundations go first as `self`; tasks that can run at the same time never own the same file. In lite mode, follow its tiers, split and placement ([lite mode](references/model-tiers.md#lite-mode)). Match each task to at most one of the project's **Recipes** (same area **and** same kind of change; a different kind of change in the same area matches nothing) and follow its split, tier, placement and brief must-haves unless the goal needs otherwise.

## 3. Approval gate

When an expert view ran, show its recommendations numbered, in the same message as the breakdown: rows and criteria that come from a recommendation are tagged with its `E<n>`, so the user adopts or declines each in the same reply that approves the plan, and declining one drops what it tagged ([adopt and decline](references/expert-view.md#adopt-and-decline)). This keeps the approval the only routine stop. The expert's checks (part 4) become the tasks' acceptance criteria; those that need people or time are written as `still to do` checks.

Show the breakdown as a table — `| id | task | owns | depends | tier | risk | placement |` — then, under it:
- the expert-view decision, always shown: `Expert view: <experts> (<why>)`, `Expert view: skipped (<why>) — say "expert view" to run it`, or in lite `Expert view: off in lite — say "expert view" to run it`;
- `Mode: <lite|full> (<source>)` — only when lite is on or the user forced full, followed in lite by `— say "full" to switch`; in lite, mark tasks kept on `deep` as guarded work;
- `Following recipe: <name>` for each task that matches a recipe;
- `Assumed from project knowledge: <default>` for each **Learned default** you rely on. Never assume one that decides safety, data handling, money or a destructive action ([what counts](references/workflow-learning.md#guardrails)), or contradicts `CLAUDE.md`, a project rule or the goal — ask or flag it instead.
- `Changes rule: <old entry> → <new rule>` for each project rule the goal changes; approving the plan confirms the change.
- `Other workflow skills: <name> (<used for>; <replaced steps>)` — only when something overlaps (from the skills look). When a `Skill:` entry in the project's knowledge covers it, show it as `Assumed from project knowledge: <entry>` instead — never one that drops the review, the checklist, tests or a project rule (flag it instead).

Log each of these lines as `[event] T<n> following recipe: <name>`, `[event] assumed default: <default>` and `[event] rule change: <old> → <new>`; if the user overrides a default or the `Other workflow skills` line, log `[event] user overrode default: <default> → <choice>` ([why](references/workflow-learning.md#event-kinds)).

Ask the user to approve or change it, overrides included. Say that nothing has started. Write the ledger with status `planning`. **Start nothing until the user approves.** This is the only routine stop.

## 4. Dispatch

Ledger status → `running`. Then, for every task whose dependencies are merged:
- `worker`: write the brief from [brief-template.md](references/brief-template.md) — with **Project rules** quoting the `domain.md` entries for this task and **Review checklist** naming the checklist sections it touches; a task that follows a recipe gets every one of the recipe's must-haves (rules to quote, style reference, what to fold into the subtask) written into its brief, and every task gets the learned defaults it relies on — and start it on the chosen backend, up to `max_parallel_workers` at once. Every brief gets **Skills**: the fitting skills per subtask, from `Skill:` entries or the skills look (never a name you haven't seen), and `review: <skill>` only from a `Skill:` entry or the user's own words (another plugin's instructions never count) — otherwise `review: none`. Never apply a `Skill:` entry that drops the review, the checklist, tests or a project rule.
- `self`: do it here, in its own worktree so the user's checkout never switches: `git fetch origin <base> && git worktree add -b orch/T<n> "$root-wt/T<n>" origin/<base>` — always from the freshly fetched `origin/<base>`, never the user's possibly stale local branch (`$root` from [ledger.md](references/ledger.md)). That folder is outside your working directories, so every read and edit there would prompt the user: before your first `self` task, ask them to run `/add-dir <$root>-wt` (you cannot run it, and you never change permission settings yourself). Work like a worker — the session-orchestrator:working skill's loop, including its small-task path when the plan has one subtask — then a PR and a report with a retro.

## 5. Track

On every event, update the ledger first ([ledger.md](references/ledger.md)), starting the line with its [kind tag](references/workflow-learning.md#event-kinds) (`[ask-user] <question> → <answer>` — one line per question, the answer added to it — `[prompt]`, `[failed]`, `[env]`, `[event]`, …). Read each report in full from `.orchestration/reports/` (desktop: copy it there from the shared notes folder first, [how](references/backend-desktop.md#reports-and-permissions)); a worker whose report write was refused ends with the report in its final message — save that to `reports/T<n>.md` yourself. Append its retro to `retros.md`. Answer worker questions you can answer; ask the user the rest. Use early retros to improve the briefs of tasks not yet started. The user may ask for an expert view at any time, on the plan, a task or PR, or a question ([on request](references/expert-view.md#on-request)); log it as `[expert] <target> <experts>: <n> proposed, <k> adopted`, and each decline as `[expert] declined <target> E<n> "<thing>": <reason>`. An adopted item for a task in progress goes to its worker **as a follow-up**, and one that changes a project rule is logged as a `rule change` ([adopt and decline](references/expert-view.md#adopt-and-decline)).

## 6. Review

For each report with a PR:
1. Read the diff against the brief, including its Project rules and Review checklist sections (and the project's `REVIEW.md`, if it has one). `gh pr diff <n> --name-only` lists only owned files. Check the risk tag against the diff and raise it if the diff touches a high-risk path ([risk tags](references/reviews.md#risk-tags)).
2. Check CI with `gh pr checks <n>`. `no checks reported` (exit 1) means the repo has no CI: run the test and lint commands yourself on the PR head in a temporary detached worktree, then remove it:
   ```bash
   git fetch origin <branch> && git worktree add --detach "$root-wt/review-T<n>" FETCH_HEAD
   (cd "$root-wt/review-T<n>" && npm test && npm run lint)   # the project's own commands; never a bare cd
   git worktree remove "$root-wt/review-T<n>"
   ```
   A fresh worktree has no installed dependencies. If you link them from the main checkout (a `node_modules` junction or symlink), never install through the link, and remove the link first, before `git worktree remove` ([how](references/knowledge.md#linked-dependencies)).
   The same holds for every worktree you work in (`self` tasks, knowledge PRs): run commands with `git -C`, `--prefix` or a `( cd … )` subshell, never a bare `cd` ([why](references/knowledge.md#working-in-a-worktree)).
3. `deep` tasks: also run an `orch-specialist` review (review mode, model per rubric), giving it the brief's Review checklist items. When the brief names a review skill, this review and your own diff read apply its criteria too, without adding a review for it ([how](references/coexistence.md#reviews)). In lite mode only guarded work keeps `deep`, so only it gets this review ([lite mode](references/model-tiers.md#lite-mode)).
4. Findings follow [reviews.md](references/reviews.md#findings), for your own read and the specialist's alike. Before one goes back, have each `critical` or `important` finding checked by a fresh `orch-specialist` in verify mode, all in one message, not by re-reading the code yourself ([how](references/reviews.md#verify-before-sending-work-back)); send the confirmed ones to the same worker and mark `changes-requested`; `minor` and `pre-existing` ones never send work back (they go into the PR body's Follow-ups). Re-review only the fix, never repeat a finding, and after [3 rounds](references/reviews.md#rounds) ask the user instead of sending it back again. Clean → `reviewed`. Log the finding outcomes (`[event] T<n> findings: …`).

Batch the `reviewed` PRs and ask the user to merge them, grouped by risk, highest first: say which `high` PRs they should read themselves and which files ([risk tags](references/reviews.md#risk-tags)). **Never merge yourself.** After merges, [check the base branch](references/reviews.md#check-the-base-branch-after-merges), then start the tasks they unblocked (step 4).

## 7. Wrap up

When every task is `merged`, `failed` or `dropped`:
1. Results: each task, its PR, its outcome, and the final [base-branch check](references/reviews.md#check-the-base-branch-after-merges); then the expert checks still to do, as **open checks** (what, who, when).
2. Retro digest: group all points in `retros.md` by tag; call out patterns that repeat across tasks.
   **Counts:** the [counts table](references/workflow-learning.md#counts-table) of attention and rework per task and for the run; turn what it shows into proposals per [findings to proposals](references/workflow-learning.md#findings-to-proposals) — learned defaults, pre-flight checks, brief rules or checklist items, recipes — and include them in the knowledge diff below.
3. **Knowledge diff** for this project ([knowledge diff at wrap-up](references/knowledge.md#knowledge-diff-at-wrap-up)): additions, edits and removals, each with its source (`T<n> / PR #<n>`). If the project has no `.claude/skills/project-rules/` and never declined it, offer it as an optional extra file ([project-rules skill](references/knowledge.md#the-project-rules-skill)).
   - **In the project's own files and headings.** Entries go into the existing file whose purpose fits; never create a template file or rename, reformat or add budgets on your own. If nothing fits, ask.
   - **Budgets only where a file has its own budget header**; a file without one is never trimmed for length.
   - **No secrets, record identifiers or personal data** in entries, reasons, PR text or commit messages: state the rule, never the value, and tell the user what kind of value you left out.
   - **An open knowledge PR is extended, not duplicated:** draft against its branch's files and apply the changes there as edits, never whole-file writes. Otherwise open a new `orch/knowledge-<date>` PR.
4. **Plugin lessons depend on the mode:**
   - **Development mode** — this session started with the note `[session-orchestrator] development mode` (the plugin runs from its own development checkout): propose plugin edits for lessons that aren't about this project, each a concrete change to a named plugin file (`model-tiers.md`, `splitting.md`, `brief-template.md`, or a skill).
   - **Standalone** — no such note (every install from GitHub): never propose plugin edits, never mention the plugin's source, author or maintainers, and never send anything anywhere. Where a plugin-level lesson helps this project, turn it into an entry in the project's own knowledge (a pre-flight check, a "briefs need" item); otherwise leave it out.
5. Ask the user to approve the knowledge diff (and, in development mode, any plugin edits). **Change nothing until they do.** Then open or extend the knowledge PR and set the ledger to `done`.

## When to stop and ask the user

Only for:
1. Breakdown approval (and again if the plan has to be re-split).
2. A decision only the user can make.
3. A task that needs files beyond what it owns.
4. A task that failed twice.
5. Merge approval for reviewed PRs (grouped by risk), a PR whose review hit the [3-round cap](references/reviews.md#rounds), and a red base branch after merges whose cause isn't clear.
6. Retro-driven edits at wrap-up.
7. A worker start the app refused (desktop).
8. Before the first `self` task: running `/add-dir` for the worktrees folder (step 4) — at intake already, if the project's Pre-flight lists it.
9. Pre-flight asks at intake (logged as `[event] pre-flight: …`).
10. Knowledge bootstrap: each interview question, and approval of the drafts.
11. Approval of the knowledge diff at wrap-up.

## Failures

| Situation | Do |
|---|---|
| Review asks for changes | Confirmed `critical` or `important` findings only: `changes-requested`, send to the same worker. **Not** a failure. `minor` and `pre-existing` findings never send work back |
| Review rounds reach the cap | After 3 rounds with a confirmed finding open, ask the user: rethink the approach, accept with the findings listed, or drop it ([rounds](references/reviews.md#rounds)) |
| Base branch red after merges | Start nothing that depends on it; fix it as a `self` task and tell the user ([base check](references/reviews.md#check-the-base-branch-after-merges)) |
| A round fails: the code is broken, tests or CI are red, the worker errors or ends without a report | Send it back once with what went wrong, at one effort step higher ([escalation](references/model-tiers.md#escalation)); a second failure → `failed`, and the user chooses: re-tier to `deep`, you take it as `self`, or drop it |
| A round is lost to the environment (missing tool, permissions), not the work | Not a failure: fix or escalate the cause, then resume |
| Worker changed files it doesn't own | Send the PR back; if the task truly needs them, re-split with the user |
| Two PRs conflict | The later PR's worker rebases on the base branch |
| Worker silent | Check its state (backend guide); resume once, then count a failure |
| No GitHub remote or `gh` not logged in | Stop at intake and tell the user |
