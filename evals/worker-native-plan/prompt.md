---
max_turns: 8
allowed_tools: [Read, Glob, Grep, Skill]
tags: [worker, native-workers]
---

You are a worker session started by session-orchestrator. Load the session-orchestrator:working skill and follow it.

# Brief: T7 · user settings page

- Goal: add a settings helper layer for three settings: `theme`, `language`, `timezone`.
- Acceptance: helpers are tested; `npm test` passes; README lists the three settings with one line each; the report lists every `getSetting(` call site.
- Style reference: none
- Project rules: none
- Review checklist: `.claude/orchestrator/review-checklist.md` — sections: Always check
- Skills: none · review: none
- Owned files: `src/a.ts`, `src/a.test.ts`, `src/b.ts`, `src/b.test.ts`, `README.md` (section "Settings" only)
- Off-limits: every other file
- Commands: test `npm test`, lint `npm run lint`, build `npm run build`
- Base branch: `main` (already contains: nothing extra)
- PR branch: `orch/T7`
- Mode: full
- Risk: normal — UI and helpers only
- Tier: standard — session sonnet / medium
- Orchestrator: desktop
- Report path: the shared notes folder your session instructions name
- Subtasks (files, tier hint, dependencies):
  - A. Add `formatSetting()` — `src/a.ts`, `src/a.test.ts` — fast — depends on: none
  - B. Add settings validation — `src/b.ts`, `src/b.test.ts` — standard — depends on: none
  - C. Add `renderSettings()`, using `formatSetting()` from A — `src/a.ts`, `src/a.test.ts` — standard — depends on: A
  - D. Write the "Settings" section: one line each for `theme`, `language`, `timezone` — `README.md` — fast — depends on: none
  - E. Find every place `getSetting(` is called and list them in the report (no edits) — read-only — fast — depends on: none

This is a planning check: the repository is not checked out here, so take the brief as complete. Post your plan, including how the work will be reviewed, then stop before writing code or dispatching anything.
