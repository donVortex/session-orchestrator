# session-orchestrator

A Claude Code plugin that turns the session you talk to into an **orchestrator**. It plans the work with you, splits it into PR-sized tasks, and runs them in **worker sessions** (desktop app sessions, or headless `claude -p` runs). Workers write their task themselves, test-first, use subagents only where they pay off, get one fresh review of the whole change, open one PR per task, and report back with a short retro. The orchestrator does critical tasks itself, reviews every PR, and leaves merging to you. Each project it works on builds up its own knowledge, so it gets better at that project with every feature.

**Works in Claude Code**: the desktop app's Code tab and the `claude` CLI. It needs a local git checkout and starts other Claude Code sessions, so it doesn't run in claude.ai chat or cloud sessions.

## Install

**You need:**
- Claude Code: the desktop app (Code tab) or the `claude` CLI;
- `git`, and the GitHub CLI `gh`, logged in (`gh auth login`);
- a project with a GitHub remote (every task becomes a pull request);
- for the CLI backend only: `claude` on your PATH.

**1. Add the marketplace and install the plugin** (in a terminal):

```bash
claude plugin marketplace add donVortex/session-orchestrator
```

```bash
claude plugin install session-orchestrator@session-orchestrator --scope user
```

`--scope user` makes it available in every project, in both the desktop app and the `claude` CLI on that machine. Plugins don't load in cloud sessions (claude.ai/code).

**2. Restart** the desktop app, or start a new `claude` session.

**3. Check it's there:** `claude plugin list` shows `session-orchestrator`, and typing `/session-orchestrator` in a session suggests `/session-orchestrator:orchestrate`.

**Updating.** Turn on auto-update once: run `claude`, type `/plugin`, open Marketplaces → `session-orchestrator` and enable auto-update. The setting is shared by the CLI and the desktop app. To update by hand instead:

```bash
claude plugin marketplace update session-orchestrator
```

```bash
claude plugin update session-orchestrator@session-orchestrator
```

Then restart; sessions already open keep the old version.

**Updating while a run is in progress.** A session keeps the plugin version it started with, and new worker sessions get the new one. Both work together, but the run follows the older rules until you switch. Either:
- let the run finish in its current session, or
- start a **new** session in the project and say "continue the orchestration": it picks up from `.orchestration/ledger.md` with the new version and fills in anything the older version didn't record.

Don't resume an old session across an update: its history holds the older instructions, so it can end up following old and new ones at once.

**Uninstalling:** `claude plugin uninstall session-orchestrator@session-orchestrator`. The knowledge in your projects (`.claude/orchestrator/`) stays; it belongs to the projects.

## Use

### Your first run in a project

1. **Open the project:** in the desktop app, a Code session on the project's folder; in a terminal, `claude` in the repo.
2. **Start it with a goal:**
   ```
   /session-orchestrator:orchestrate add a refund flow
   ```
   Or without a goal (`/session-orchestrator:orchestrate`) to let it learn the project first.
3. **Project setup (first run only):** scouts read the repo, then it asks you up to 5 questions about the domain, one at a time, and shows you the drafted knowledge. Nothing is written until you approve; then it opens a knowledge PR for you to merge.
4. **Approve the plan:** it shows the tasks as a table (what each does, which files it owns, its model tier, where it runs). Approve it or ask for changes. Nothing starts before you approve.
5. **Work runs:**
   - **Desktop app:** each task gets its own worker session, listed in the sidebar as `T<n> · <task>`. You can open one to watch it; you don't have to.
   - **CLI:** workers run headless in their own git worktrees ([permissions](#cli-workers-and-permissions)).
   - The orchestrator does small or critical tasks itself. Before the first one it asks you once to run `/add-dir <repo>-wt`, so its worktrees don't prompt for every edit.
   - Workers that get stuck ask the orchestrator; it asks you only what it can't answer.
6. **Reviews and merging:** each task ends in one pull request. The orchestrator reviews it (diff, tests, CI).
   - Each finding is `critical`, `important` or `minor`, with the file and line. A finding that was already on the base branch is tagged `pre-existing` and never becomes the worker's job.
   - Before an `important` finding goes back to the worker, a fresh reviewer double-checks it, so false alarms don't cost a round. `minor` findings are listed, not sent back.
   - After 3 rounds with a problem still open, it asks you how to proceed instead of looping.
   - Clean PRs are batched and you're asked to merge them, grouped by risk (`low`, `normal`, `high`). For `high`-risk PRs (security, money, data deletion, migrations, CI files) it tells you which files to read yourself. **You merge; it never does.**
   - After merges it runs the tests on the updated base branch, then starts the tasks that were waiting on them.
7. **Wrap-up:** when every task is done it shows the results, what went well or badly, and a **knowledge diff**: what it learned about the project, each change with its source. Approve it and it opens a knowledge PR.

### Every run after that

- **Just describe the feature** in any new session in that project ("add CSV export"): once a project has `.claude/orchestrator/`, it plans and delegates without the command. Questions, explanations, reviews and small one-file fixes stay normal, quick work.
- **Pick the mode** that fits the run: full or lite ([Modes](#modes-full-and-lite)).
- **Pick up where you left off:** the run's state lives in `.orchestration/ledger.md`. When the orchestrator's context fills up or you resume its session, the plan is loaded back automatically. If a run is unfinished, a new session there continues it on its own; if it doesn't, say "continue the orchestration" (or run `/session-orchestrator:orchestrate`).
- **Task numbers keep counting** across runs (T1–T8, then T9…), so sessions in the sidebar never share a number.

### On an existing project

The plugin is made for projects that already have code, a team and their own habits. Start exactly as in [Your first run in a project](#your-first-run-in-a-project); the first run reads the repo and asks you about it before any feature work.

**What it needs from your project:**
- a GitHub remote and `gh` logged in: every task becomes a pull request;
- test, lint and build commands it can run. It asks if it can't find them. For CLI workers, also allow them in the project's `.claude/settings.json` ([how](#cli-workers-and-permissions)).

**What it adds to your repo:** all of it through pull requests you review and merge.
- `.claude/orchestrator/`: the project knowledge (rules, codebase map, review checklist, calibration), via a knowledge PR;
- optionally `.claude/skills/project-rules/`, a small skill that points every session to those rules; you can decline it;
- one `orch/T<n>` branch and one PR per task.

**What stays out of git:**
- `.orchestration/`, the working files of a run (plan, briefs, reports). It's kept out through your local `.git/info/exclude`, so your `.gitignore` isn't touched;
- the worktrees it works in: a `<repo>-wt` folder next to your repo for tasks it does itself and for CLI workers; the desktop app creates worktrees for its worker sessions.

**What it never touches:**
- your checkout and current branch: all work happens in separate worktrees, so you can keep working while it runs;
- `main` (or your base branch): it never pushes there and never merges; you merge the PRs;
- your `CLAUDE.md`: it follows it, ranks it above its own knowledge, and never copies it;
- your existing knowledge layout: if `.claude/orchestrator/` already exists, it's used as it is, and plugin updates never rewrite it.

Your other skills and plugins keep working alongside it ([how](#alongside-other-skills-and-plugins)).

**Working in a team:**
- The knowledge is committed to the repo, so everyone with the plugin gets the same rules and checklist.
- Teammates without the plugin still get the rules through the project-rules skill, if you added it.
- Knowledge changes arrive as normal PRs, so the team reviews them like code.

**Removing it:**
- **Keep the knowledge, stop the takeover:** to keep a project manual (no orchestrator unless you run the command), add this to its `.claude/settings.json`:

  ```json
  { "env": { "ORCH_DEFAULT": "off" } }
  ```
- **Remove it from the project:** delete `.claude/orchestrator/` (and `.claude/skills/project-rules/`, if you added it) in a normal commit, then delete the local `.orchestration/` folder and any leftover `orch/T*` branches.

## Modes: full and lite

**Full** (the default) puts the effort where the work needs it. Hard tasks (design, cross-cutting changes, unknown bugs, security) run on opus and get an extra specialist review. That pays off on complex products.

**Lite** is for runs where speed matters more than depth: a simple codebase, small changes, a time crunch.

| | Full | Lite |
|---|---|---|
| Models | opus for `deep` work | sonnet for everything except an expert view you ask for (`deep` runs as `standard`) |
| Tasks | PR-sized, one worker session each | as few tasks as the work allows; small ones done in the orchestrator session |
| Reviews | one review of the whole change per task, specialist review of `deep` PRs | one review of the whole change per task, on sonnet except high-risk work; no specialist PR review |
| Expert view | at planning, when the goal touches the product's field | only when you ask |
| Knowledge setup | interview and drafts on a project's first run | skipped (the wrap-up mentions it) |

**Turning it on**

- **One run:** `/session-orchestrator:orchestrate lite: <goal>`, or say "lite" in your request.
- **A whole project:** add a `Mode: lite` entry to `.claude/orchestrator/calibration.md`. After you choose lite twice in a project, the wrap-up proposes this entry for you.
- **During a run:** say "lite" or "full" at any time. Tasks that haven't started switch; workers already running finish on their current model.
- **Back to full:** say "full", for one run or mid-run. The plan always shows the mode and where it came from: `Mode: lite (from project knowledge) — say "full" to switch`.

**Lite never cuts the safety net.** Work that touches security, authentication, money, deleting data or migrations keeps its normal model and the specialist review. A subtask that fails can still move up to opus once. Tests, one PR per task, your plan approval, your merges and the wrap-up learning all stay.

**Tip:** the orchestrator session can't change its own model, so for lite runs start that session on sonnet. If it runs on opus, the plan reminds you once.

### How workers work

In the desktop app, each worker's title starts with its status: ⏳ working · ❓ needs you · ⛔ failed · 🔀 waiting for your merge · ✅ merged. Only titles the orchestrator wrote change; a worker you renamed keeps your name.


A worker does its task in its own session: it writes each piece itself, test-first, and runs the full test suite after each one. It hands a piece to a subagent only for:
- a wide search through the code (a cheap read-only scout);
- a piece too big to do in one session, such as a 40-file migration;
- independent pieces worth running at the same time;
- one piece harder than the rest of the task.

Before the PR, one fresh reviewer checks the whole change (Opus for high-risk work, Sonnet otherwise), then the orchestrator reviews the PR as before.

Each worker's report says how much it delegated, how full its context got, and whether its context was compacted; on the CLI backend it also gives the cost. The wrap-up compares this with the project's earlier runs: PR findings, rework, compaction and subagent use per task. In an area where the change does worse in two runs, it proposes going back to per-piece reviews or subagents there, through a knowledge entry you approve.

### Which model to start the orchestrator on

The orchestrator plans, briefs workers and reviews their PRs; it keeps the model you start it with, and worker sessions can't run above it.

- **Opus 5.5** (Claude Code's default): most runs.
- **Fable 5.2:** big migrations or refactors, architecture work, and runs with many tasks at once. It's the model best at leading many sessions, at about twice Opus's price.
- **Sonnet 5.5:** lite runs and small, clear goals.

Worker sessions and subagents get their models from the task tiers, whatever you pick here: Haiku only for searching and reading, Sonnet for well-scoped code, Opus for design, hard bugs and security.

## Project knowledge

Each project keeps what the orchestrator has learned about it in `.claude/orchestrator/`, committed to the project's repo: domain rules and glossary, who your users are and what they need, a codebase map, a review checklist, and tier and split calibration. A healthcare team's orchestrator becomes expert in their healthcare product; an insurtech team's in theirs.

- **First run in a project:** scouts read the repo, the orchestrator asks you up to 5 questions (one at a time), two of them about your users and experts, shows you the drafts, and opens a knowledge PR after you approve. Start it without a goal (`/session-orchestrator:orchestrate`) and it learns the project first, then asks what to build.
- **Project-rules skill (optional):** the orchestrator offers a small `.claude/skills/project-rules/SKILL.md` that points every session in the repo, even ones not using the orchestrator, to the project's rules. Decline it once and it isn't offered again.
- **Every run:** briefs quote the relevant rules, reviews use the checklist, and splits follow the codebase map.
- **Every wrap-up:** proposes additions, edits and removals, each with its source. After you approve, it opens (or extends) a knowledge PR for the team to review.
- **Hand edits are welcome** and always win. Never put secrets, identifiers or personal data in it.

**The project owns its knowledge.** Plugin updates never rewrite, reformat or migrate it, whatever its layout. The plugin's templates only shape a brand-new bootstrap; after that, the knowledge changes only through PRs you approve.

**Standalone by design.** Installed from GitHub, the plugin works on its own and improves only within each project, through that project's knowledge. It never proposes changes to the plugin itself and never sends anything to its author or anyone else; the only outside requests it adds are the expert view's fetches of public sources ([details](#what-it-runs-and-sends)). Lessons about tooling that help your project become entries in its own knowledge (for example a pre-flight check).

### Product knowledge and the expert view

`product.md` holds who uses your product, what they need (and where that's known from: interviews, support tickets, analytics, or an assumption nobody has checked yet), what you decided not to do, and whose professional eye matters: for a fitness app, say, a strength coach and a physiotherapist, with their primary sources and where your own data lives.

From that, the **expert view** looks at the work the way those professionals would. For each goal that touches your product's field, before showing the plan, a fresh specialist answers four things:

1. What a top professional would do here that you didn't ask for.
2. The raw material they'd start from: primary sources and your own data, not someone's summary. Each source is marked *opened* (read now), *recalled* (not read now: known from the model's training, or only cited) or *unreachable*.
3. The methods and tools they'd use.
4. What, other than you and Claude, would show the result is right: a professional's sign-off, a user test, numbers from your logs.

You adopt or decline each recommendation. Adopted ones change the plan, or go to the worker if the task is already running; declined ones go into `product.md` as out of scope, so they don't come back every run. Checks nobody can run during the session are listed in the PR as still to do; they never block a merge.

- **When it runs:** automatically at planning, unless the goal has nothing to do with the product (refactors, CI, dependencies). The plan always says whether it ran and why. In lite mode it runs only when you ask.
- **Asking for it:** say "expert view" at any time, about the plan, a task or PR, or a question, or name the professional ("what would a physio say about T4?").
- **Projects set up before v0.7.0:** the first time a goal touches the product, the orchestrator offers once to start `product.md` with two questions. Decline and it doesn't ask again.

## Workflow learning

Besides the domain, each project's orchestrator learns **how work goes best there**, aiming at fewer interruptions for you and less rework, with the same output.

- **Measured, not guessed:** every ledger event carries a kind tag (`[ask-user]`, `[prompt]`, `[failed]`, `[changes]`, …). Each wrap-up shows a table of your attention and the rework per task. Expected stops (approving the plan, merges, the knowledge diff) don't count against it.
- **What it learns,** all in the project's `calibration.md`:
  - **Recipes:** how a kind of task goes through cleanly.
  - **Learned defaults:** answers you gave twice, so it stops asking.
  - **Pre-flight checks:** environment problems to catch at intake.
  - **Brief rules:** to prevent rework.
- **What you see:** the plan says `Following recipe: …` and `Assumed from project knowledge: …`, so you can override either in the same reply.
- **Guardrails:** everything still goes through the approved knowledge PR. Learned defaults never override `CLAUDE.md` or project rules, and never cover safety, data handling or money.

## Alongside other skills and plugins

The orchestrator runs alongside whatever other skills and plugins you use, without either getting in the other's way or doing the same work twice. It judges every skill by **what it would do**, not by its name ([the contract](skills/orchestrating/references/coexistence.md)):

- **The orchestrator owns how work is organised**: the plan and your approval, branches, worktrees, one PR per task, reviews, and project knowledge. You merge. Another planner's ideas feed the breakdown but never replace it, and no skill merges, creates its own worktree, or writes plan files into a PR.
- **Everything inside a task is open to other skills**: test-driven development, framework and domain skills (Stripe, Cloudflare, design), debugging.
- **When a workflow skill overlaps,** the plan says so in one line (`Other workflow skills: …`), and you can override it in the same reply.
- **Briefs name the skills that fit each task,** so workers don't each go looking for them.
- **Still one review per change:** if the project has a preferred review skill, the reviewer uses it **and** the project's checklist.
- **Each project learns its own skill set:** wrap-ups propose `Skill:` entries ("use payments-kit for refunds", "skip that plugin's worktree step"), which you approve in the usual knowledge PR.

[superpowers](https://github.com/obra/superpowers) is the worked example: brainstorming helps with an unclear goal; its planning, worktree and finishing steps are replaced by the orchestrator's; its TDD, review and verification skills are used inside tasks.

## CLI workers and permissions

Outside the desktop app, workers run as headless `claude -p` processes in their own git worktrees (`scripts/cli-worker.sh`). Headless runs can't ask you for permission, so each worker gets `--permission-mode acceptEdits` plus [settings/worker-allowlist.json](settings/worker-allowlist.json). Edits are limited to the worker's worktree and the `.orchestration/` folder. The allowlist adds skills and subagents, `git` commits, pushing to `orch/*` branches only (no force-push, nothing to `main`/`master`), and `gh pr`. The plugin never uses a bypass mode.

Workers also need your project's test, lint and build commands. Don't edit the plugin's allowlist (an installed plugin runs from a cached copy that updates replace); add them to the project's `.claude/settings.json`, which workers pick up from their worktree:

```json
{ "permissions": { "allow": ["Bash(npm test*)", "Bash(npm run lint*)", "Bash(npm run build*)"] } }
```

To replace the whole allowlist, point `ORCH_ALLOWLIST` at your own file.

On Windows, workers use Git Bash for shell commands (the PowerShell tool is turned off for them). The launcher finds Git Bash itself; if your Git install is unusual, set `CLAUDE_CODE_GIT_BASH_PATH` to its `bash.exe`.

## What it runs and sends

**Hooks.** Three short scripts run when a session starts (`SessionStart`). They only read local files and print a note into the session:
- `hooks/project-default.sh` (new or cleared session): if the project has `.claude/orchestrator/`, tells the session the project uses the orchestrator;
- `hooks/ledger-context.sh` (after compaction or resume): if a run is in progress, prints its plan from `.orchestration/ledger.md`;
- `hooks/plugin-mode.sh` (every start): prints the development-mode note, only in the plugin's own development checkout.

**Commands it runs** (Claude runs them through its normal tools, with your usual permission prompts):
- `git`: fetch, worktrees, branches, commits, and pushes to `orch/*` branches. Never a force push, never to your base branch;
- `gh`: create, view and check pull requests, and list knowledge PRs;
- your project's test, lint and build commands;
- CLI backend only: `scripts/cli-worker.sh`, which starts each worker as `claude -p` in its own worktree.

**Sessions and permissions:**
- Desktop app: it starts worker sessions and sets each one's model and effort. The app asks you to trust the project folder; the plugin can't do that for you.
- CLI workers run with `--permission-mode acceptEdits` and the rules in [`settings/worker-allowlist.json`](settings/worker-allowlist.json), passed only to those worker processes ([details](#cli-workers-and-permissions)).
- It never changes your permission settings and never uses a bypass mode. When a step needs access (`/add-dir`, folder trust), it asks you to grant it.

**Files it writes:**
- `.orchestration/` in your repo (plan, briefs, reports), kept out of git through `.git/info/exclude`;
- worktrees for tasks, and `orch/T<n>` branches with their pull requests;
- `.claude/orchestrator/` and the optional project-rules skill, only through pull requests you approve and merge.

**Network.** Your own `git` and `gh` talking to GitHub, Claude Code's own model calls, and, for the expert view, up to 5 web requests per view (searches and fetches of public sources such as guidelines, standards and papers), found with general search terms only: never your code, your data or your product's name. No telemetry: nothing is sent to the plugin's author or anyone else.

## Contributing

Working on the plugin itself (development mode, tests, evals)? See [CONTRIBUTING.md](CONTRIBUTING.md).

## License

[MIT](LICENSE)
