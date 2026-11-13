# Contributing to session-orchestrator

This file is for working on the plugin itself. To use it, see the [README](README.md).

## Development setup

1. Clone the repo and mark the checkout as a development checkout (the marker is git-ignored):
   ```bash
   git clone https://github.com/donVortex/session-orchestrator.git
   cd session-orchestrator
   touch .plugin-dev
   ```
2. Install the plugin from this folder instead of from GitHub, so your edits load in new sessions:
   ```bash
   claude plugin marketplace add "$PWD"
   claude plugin install session-orchestrator@session-orchestrator --scope user
   ```
3. Restart Claude Code. Because the plugin now loads from a checkout with the marker, sessions in this repo start with the note `[session-orchestrator] development mode`, and wrap-ups there may also propose edits to the plugin; installs from GitHub never do.

   Sessions in **other projects** that use this checkout start with `[session-orchestrator] report-only mode`. Their wrap-ups only report plugin lessons, saved to that project's `.orchestration/plugin-proposals.md`, and never edit, commit or open PRs in the plugin, even when the user approves. Bring the proposals to a session in this repo, which judges them.

Changes go through pull requests. Bump `version` in `.claude-plugin/plugin.json` (and the check in `tests/test_manifest.sh`) for every release, so installed copies pick up the update.

## Design

[Plugin](docs/superpowers/specs/2026-11-03-orchestrator-plugin-design.md) · [project knowledge](docs/superpowers/specs/2026-11-03-project-knowledge-design.md) · [workflow learning](docs/superpowers/specs/2026-11-03-workflow-learning-design.md)

## Tests

**Unit tests** check the skill files, hooks and scripts:

```bash
bash tests/run.sh
```

**Behaviour evals** check what the skills actually make Claude do. Each case in `evals/` is a scenario with graders. It runs several times with the plugin and without it, and a judge model grades the answers, so you can see whether the plugin makes a difference.

Run one case (what you'll usually want after a change):

```bash
claude plugin eval . --judge-model sonnet --no-publish --case <case-name>
```

Run all cases:

```bash
claude plugin eval . --judge-model sonnet --no-publish
```

- `--judge-model sonnet`: the default Haiku judge sometimes fails correct answers.
- `--no-publish`: keeps the report on your machine, in `evals/results/` (git-ignored).

## Verified runs

**CLI backend, end to end** (2026-11-03, sandbox repo, 2 workers + 1 `self` task, all merged). Checklist: [docs/e2e-checklist.md](docs/e2e-checklist.md).

Found and fixed during the run:
- Workers started from Git Bash couldn't find Git Bash and got only PowerShell, which no `Bash(...)` allow rule matches. The launcher now sets `CLAUDE_CODE_GIT_BASH_PATH` and turns PowerShell off.
- Blanket `Edit`/`Write` allow rules let a worker write outside its worktree. Removed; edits are scoped to the worktree and `.orchestration/`.
- `self` worktrees sit outside the orchestrator's working directories, so it now asks you to `/add-dir` them first.
- A review nit counted as a failed round. Now only broken code, red tests/CI, worker errors or missing reports count.
- From the run's own retros: workers may run `gh pr diff`, open PRs with `--body-file`, must see a failing test before any implementation, and check exact source text with grep.

**Desktop backend, end to end** (2026-11-03, sandbox PRs #4–#6): worker sessions start on their tier's model and load the plugin; the previous run is archived first. Found and fixed: folder trust is now handled as a blocked start, tiny tasks get a small-task path that still has one review, and branch names from an earlier run no longer collide.

**Worker behaviour** (third run, sandbox PRs #7–#8): a worker with three independent subtasks sent three implementer subagents in a single response, each on its tier's model, followed by a review. A one-subtask worker took the small-task path and still ran one review.

**Project knowledge, end to end** (sandbox PRs #9–#13): the first orchestration bootstrapped the knowledge (repo scan, an interview one question at a time, your approval, knowledge PR #9); feature 1 (`formatMoney`, #10) briefed its worker with those rules and its wrap-up added what it learned (knowledge PR #11); feature 2 (`sumPrices`, #12) quoted a rule feature 1 had taught, and its wrap-up added more (#13). Found and fixed along the way: structured messages ending in "Your next step", reading the base branch with `MSYS_NO_PATHCONV=1` on Windows, never `cd`-ing into a worktree, starting every task from GitHub's latest base, and the orchestrator as the default workflow in projects with knowledge.

**Workflow learning, end to end** (sandbox PRs #14–#17, on a project whose knowledge predates v0.3.0): run 1 (`maxPrice`, #14) tagged every ledger event, counted 1 question to you and 0 rework, turned that question into a domain rule, and learned a "Money helper" recipe, filed under the project's existing heading with a `Recipe:` prefix (#15). Run 2 (`minPrice`, #16) followed that recipe and finished with **0 questions and 0 rework**, and its wrap-up updated the recipe's track record (#17). Found and fixed along the way: a recipe may be learned when its only question became a domain rule; workers wait for their review subagents in the same turn; a branch-cleanup question you left unanswered isn't asked again.
