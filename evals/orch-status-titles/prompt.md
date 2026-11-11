---
max_turns: 10
allowed_tools: [Read, Glob, Grep, Skill]
tags: [orchestrator, status-titles]
---

First load the session-orchestrator:orchestrating skill with the Skill tool, as an orchestrator session does at its start.

You are the orchestrator of a running orchestration in github.com/acme/shop (desktop backend, mode full). Ledger excerpt:

| id | task | owns | depends | tier | risk | placement | session/run | branch | PR | status |
|----|------|------|---------|------|------|-----------|-------------|--------|----|--------|
| T3 | coupon codes at checkout | src/checkout/coupons/** | — | standard | normal | worker | local_c3 | orch/T3 | — | running |
| T4 | audit log export | src/audit/export/** | — | standard | normal | worker | local_d4 | orch/T4 | #61 | in-review |

The sessions' current titles (from `list_sessions`): `local_c3` is "⏳ T3 · coupon codes at checkout"; `local_d4` is "my audit export" (the user renamed it).

Two things just happened:
1. T3's worker ended its turn with a report saying `Status: blocked` and a question: should expired coupons show an error or be silently ignored?
2. You finished reviewing PR #61 for T4: it passes, so you are about to send the user the merge request.

You can't run tools here. Describe the calls you make for these two events, in order, including any session renames.
