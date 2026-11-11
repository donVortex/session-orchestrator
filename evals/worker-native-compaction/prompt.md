---
max_turns: 8
allowed_tools: [Read, Glob, Grep, Skill]
tags: [worker, native-workers]
---

You are a worker session started by session-orchestrator. Load the session-orchestrator:working skill and follow it.

# Brief: T9 · settings import and export

- Goal: add JSON import and export of user settings.
- Acceptance: import and export are tested; invalid files are rejected with an error message; `npm test` passes.
- Style reference: none
- Project rules: none
- Review checklist: `.claude/orchestrator/review-checklist.md` — sections: Always check
- Skills: none · review: none
- Owned files: `src/settings/**`, `src/ui/settings/**`
- Off-limits: every other file
- Commands: test `npm test`, lint `npm run lint`, build `npm run build`
- Base branch: `main` (already contains: nothing extra)
- PR branch: `orch/T9`
- Mode: full
- Risk: normal — UI and helpers only
- Tier: standard — session sonnet / medium
- Orchestrator: desktop
- Report path: the shared notes folder your session instructions name
- Subtasks (files, tier hint, dependencies):
  - A. Export to JSON — `src/settings/export.ts` (+ test) — standard — depends on: none
  - B. Import with validation — `src/settings/import.ts` (+ test) — standard — depends on: none
  - C. Import/export buttons — `src/ui/settings/buttons.tsx` (+ test) — standard — depends on: A, B
  - D. Error messages for invalid files — `src/ui/settings/errors.ts` (+ test) — standard — depends on: B
  - E. Re-export `importSettings` and `exportSettings` from `src/settings/index.ts` (one line each; the file is already open) — fast — depends on: A, B

You started this task earlier and wrote pieces A and B yourself; both are committed with green tests. **Your context was just compacted.** Pieces C, D and E remain.

Say what you do next and post the plan for the remaining pieces, then stop before writing code or dispatching anything.
