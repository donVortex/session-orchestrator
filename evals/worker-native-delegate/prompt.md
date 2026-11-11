---
max_turns: 8
allowed_tools: [Read, Glob, Grep, Skill]
tags: [worker, native-workers]
---

You are a worker session started by session-orchestrator. Load the session-orchestrator:working skill and follow it.

# Brief: T8 · new report placeholders

- Goal: move all report templates from the old `{{name}}` placeholder syntax to the new `${name}` syntax, and add the `formatDate` helper the new syntax needs.
- Acceptance: all 40 templates under `reports/**` use `${name}`; snapshot tests for every template pass; `formatDate` is tested.
- Style reference: none
- Project rules: none
- Review checklist: `.claude/orchestrator/review-checklist.md` — sections: Always check
- Skills: none · review: none
- Owned files: `reports/**` (40 template files and their snapshots), `src/format/date.ts`, `src/format/date.test.ts`
- Off-limits: every other file
- Commands: test `npm test`, lint `npm run lint`, build `npm run build`
- Base branch: `main` (already contains: nothing extra)
- PR branch: `orch/T8`
- Mode: full
- Risk: normal — UI and helpers only
- Tier: standard — session sonnet / medium
- Orchestrator: desktop
- Report path: the shared notes folder your session instructions name
- Subtasks (files, tier hint, dependencies):
  - A. Add `formatDate()` — `src/format/date.ts`, `src/format/date.test.ts` — fast — depends on: none
  - B. Convert the 40 templates in `reports/**` to `${name}` and update their snapshots — `reports/**` — fast — depends on: A

This is a planning check: the repository is not checked out here, so take the brief as complete. Post your plan, including how the work will be reviewed, then stop before writing code or dispatching anything.
