# End-to-end checklist

A dry run of the whole system on a throwaway repo, once per backend. Tick each box with what you saw; anything that fails becomes a test or eval case before it is fixed.

## Setup

- [x] `claude plugin marketplace add D:/dev/claude-orchestrator`
- [x] `claude plugin install session-orchestrator@session-orchestrator`
- [x] `claude plugin list` shows `session-orchestrator` (user scope, read from `D:\dev\claude-orchestrator`)
- [x] Sandbox project at `D:\dev\orch-sandbox`: Node, `npm test` (`node --test`) and `npm run lint`, no build step, initial commit on `main`
- [x] The sandbox's commands are allowed for workers in its tracked `.claude/settings.json`
- [x] Private GitHub repo `donVortex/orch-sandbox` created, set as `origin`, `main` pushed
- [ ] Desktop app restarted (so it loads the plugin and finds `claude` on PATH)

Goal to use (three tasks: one `self`, two workers):

> Add a `slugify(text)` utility in `src/strings/slugify.js` and a `truncate(text, n)` utility in `src/strings/truncate.js`, each with tests, plus `src/strings/index.js` that re-exports both. Commands: test `npm test`, lint `npm run lint`, no build.

Also try one deliberately thin brief: when a worker's brief leaves something out, it should block and ask, not guess.

## Desktop run

In a new desktop session opened on the sandbox folder: `/session-orchestrator:orchestrate <goal>`

- [ ] Intake checks `origin`, `gh auth status`, and picks the desktop backend
- [ ] The breakdown table appears and the orchestrator waits for approval
- [ ] `.orchestration/` exists and is listed in `.git/info/exclude`
- [ ] After approval, workers appear as sessions titled `T<n> · …` with the tier's model and effort
- [ ] Workers load `session-orchestrator:working` (confirms plugins load in sessions started by another session)
- [ ] A worker posts its plan table, writes `me` pieces itself, and delegates only with a reason (parallel calls in one message)
- [ ] A worker runs one whole-diff review before the PR, and its report has a Work line
- [ ] Each worker opens a PR and writes `.orchestration/reports/T<n>.md`
- [ ] `retros.md` gains one entry per finished task
- [ ] The orchestrator reviews each PR and asks you to merge; it never merges
- [ ] `/compact` in the orchestrator, then a message: the ledger is re-injected and work continues
- [ ] After merges: the wrap-up digest and proposed edits appear, and nothing is edited until you approve

## CLI run

In a terminal (Git Bash) in the sandbox: `claude`, then `/session-orchestrator:orchestrate <goal>`

Run on 2026-11-03 in `donVortex/orch-sandbox` (PRs #1–#3).

- [x] Intake picks the CLI backend
- [x] Workers start via `cli-worker.sh start`, in `<repo>-wt/T<n>` on `orch/T<n>`, in the background
- [x] `session_id` lands in the ledger
- [x] A blocked worker is answered via `cli-worker.sh resume`
- [x] PRs, reports and retros as in the desktop run
- [x] The orchestrator re-runs tests itself, checks owned files, sends a PR back, and asks you to merge; it never merges
- [x] `/compact` re-injects the ledger (SessionStart hook) and skills are restored
- [x] `self` task (T3) done in its own worktree with a PR
- [x] Wrap-up: results, retros grouped by tag, concrete edits to named plugin files, nothing changed before approval
- [ ] After merge, `cli-worker.sh remove` cleans up the worktree (not observed for T1/T2; T3's worktree was removed)
- [x] Parallel subagents inside a worker: observed in the third (desktop) run, PR #8. Three implementers were sent in one response (sonnet, haiku, haiku), followed by one review.
- [x] Small-task path: observed in the third run, PR #7. It posted a one-line plan, saw the red check first, and ran one sonnet review subagent.

## Results

Record what passed, what failed, and what was fixed in the README's "Verified" section.
