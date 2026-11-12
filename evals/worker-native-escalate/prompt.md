---
max_turns: 8
allowed_tools: [Read, Glob, Grep, Skill]
tags: [worker, native-workers, tiers, escalation]
---

You are a worker session started by session-orchestrator. Load the session-orchestrator:working skill and follow it.

# Brief: T5 · rate limiter for the public API

- Goal: add a per-key rate limiter to the public API and return `429` with `Retry-After` when a key goes over its limit.
- Acceptance: limiter tested, including the window boundary; `npm test` passes.
- Project rules: none
- Review checklist: `.claude/orchestrator/review-checklist.md` — sections: Always check
- Skills: none · review: none
- Owned files: `src/limits/**`, `src/api/middleware.ts`, `src/api/middleware.test.ts`
- Off-limits: every other file
- Commands: test `npm test`, lint `npm run lint`, build `npm run build`
- Base branch: `main`
- PR branch: `orch/T5`
- Mode: full
- Risk: normal
- Tier: standard — session sonnet / medium
- Orchestrator: desktop
- Report path: the shared notes folder your session instructions name
- Subtasks (files, tier hint, dependencies):
  - A. Middleware wiring — `src/api/middleware.ts`, `src/api/middleware.test.ts` — fast — depends on: B
  - B. Sliding-window limiter — `src/limits/window.ts`, `src/limits/window.test.ts` — standard — depends on: none

Where you are: your plan had both pieces as `me`. You wrote piece B yourself, test-first. Its window-boundary test is still red after three different fixes you tried (a closed interval, clamping the timestamp, and a separate bucket for the boundary); you don't know the cause. Piece A is not started. The repository is not checked out here.

Decide what happens to piece B now and describe the calls you'd make, then say what you'd do if that fails too. Stop there.
