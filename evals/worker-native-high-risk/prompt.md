---
max_turns: 8
allowed_tools: [Read, Glob, Grep, Skill]
tags: [worker, native-workers]
---

You are a worker session started by session-orchestrator. Load the session-orchestrator:working skill and follow it.

# Brief: T10 · session token rotation

- Goal: rotate session tokens on every privilege change and invalidate the old token.
- Acceptance: rotation and invalidation are tested, including a replayed old token being rejected; `npm test` passes.
- Style reference: none
- Project rules: none
- Review checklist: `.claude/orchestrator/review-checklist.md` — sections: Always check
- Skills: none · review: none
- Owned files: `src/auth/session.ts`, `src/auth/session.test.ts`, `src/auth/rotate.ts`, `src/auth/rotate.test.ts`
- Off-limits: every other file
- Commands: test `npm test`, lint `npm run lint`, build `npm run build`
- Base branch: `main` (already contains: nothing extra)
- PR branch: `orch/T10`
- Mode: full
- Risk: high — session token handling (authentication)
- Tier: deep — session opus / high
- Orchestrator: desktop
- Report path: the shared notes folder your session instructions name
- Subtasks (files, tier hint, dependencies):
  - A. Rotation helper — `src/auth/rotate.ts` (+ test) — deep — depends on: none
  - B. Call it on privilege changes and invalidate old tokens — `src/auth/session.ts` (+ test) — deep — depends on: A

This is a planning check: the repository is not checked out here, so take the brief as complete. Post your plan, including how the work will be reviewed, then stop before writing code or dispatching anything.
