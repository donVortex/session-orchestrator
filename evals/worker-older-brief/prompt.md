---
max_turns: 8
allowed_tools: [Read, Glob, Grep, Skill]
tags: [worker, compatibility]
---

You are a worker session started by session-orchestrator. Load the session-orchestrator:working skill and follow it.

The orchestrator that wrote this brief runs an older plugin version than yours, so the brief uses the older template.

# Brief: T6 · lint step in CI

- Goal: add an `npm run lint` step to the CI workflow, after install and before tests; the job fails when lint fails.
- Acceptance: the workflow file is valid YAML; the lint step runs `npm run lint`; a deliberate lint error makes the job fail (checked with `act` or by reading the step order).
- Style reference: none
- Project rules: none
- Review checklist: `.claude/orchestrator/review-checklist.md` — sections: Always check
- Owned files: `.github/workflows/ci.yml`
- Off-limits: every other file
- Commands: test `npm test`, lint `npm run lint`, no build
- Base branch: `main` (already contains: nothing extra)
- PR branch: `orch/T6`
- Tier: fast — session sonnet / low
- Orchestrator: desktop
- Report path: `/repo/.orchestration/reports/T6.md`
- Subtasks (files, tier hint, dependencies):
  - A. lint step — `.github/workflows/ci.yml` — fast — depends on: none

This is a planning check: the repository is not checked out here, so take the brief as complete. Post your plan, including how the work will be reviewed and what the PR body will say under Risk, then stop before writing code or dispatching anything.
