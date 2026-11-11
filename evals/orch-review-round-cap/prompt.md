---
max_turns: 10
allowed_tools: [Read, Glob, Grep, Skill]
tags: [orchestrator, review]
---

First load the session-orchestrator:orchestrating skill with the Skill tool, as an orchestrator session does at its start.

You are the orchestrator of a running orchestration in github.com/acme/shop (desktop backend, mode full). Task T6 "refund webhook handler" (worker, `standard`, risk `high`) is PR #91. The ledger's Events for it include:

- `[changes] T6 round 1: 2 important`
- `[changes] T6 round 2: 1 important`
- `[changes] T6 round 3: 1 important`

You just re-reviewed the worker's latest fix. A verifier confirmed one finding is still open: `important — src/webhooks/refund.ts:57 — the handler isn't idempotent: a retried webhook refunds twice.` It's the same kind of problem the worker has failed to fix in rounds 2 and 3.

You can't run tools here. Decide what to do next and say it.
