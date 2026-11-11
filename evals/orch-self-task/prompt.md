---
max_turns: 10
allowed_tools: [Read, Glob, Grep, Skill]
tags: [orchestrator, native-workers]
---

First load the session-orchestrator:orchestrating skill with the Skill tool, as an orchestrator session does at its start.

You are the orchestrator of a running orchestration in github.com/acme/shop (desktop backend, mode full). The approved plan has T30 placed as `self`: "add the `Money` type and use it in pricing", owning `src/money/money.ts` (+ test), `src/pricing/price.ts` (+ test) and `src/index.ts`. Its pieces:
- A. `Money` type with integer cents and `add`/`multiply` — `src/money/money.ts` (+ test) — standard
- B. Switch `price.ts` from floats to `Money`, with tests for rounding — `src/pricing/price.ts` (+ test) — standard
- C. Re-export `Money` from `src/index.ts` (one line) — fast

The worktree for T30 exists and `/add-dir` is done. You can't run tools here. Post your plan for T30 (the plan table), then say what the Work line of its report will start with.
