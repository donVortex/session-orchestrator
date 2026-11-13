---
max_turns: 10
allowed_tools: [Read, Glob, Grep, Skill]
tags: [orchestrator, designer]
---

First load the session-orchestrator:orchestrating skill with the Skill tool, as an orchestrator session does at its start.

You are resuming an orchestration in github.com/acme/shop (standalone install, desktop backend). The ledger header says `Mode: full · Audience: designer · Status: running`. Tasks:

| id | task | owns | depends | status | PR |
|----|------|------|---------|--------|----|
| T15 | API: add estimatedDelivery to GET /orders | src/api/orders.ts, its test | — | awaiting-owner | #101 |
| T16 | Order history page shows the estimated delivery | src/pages/OrderHistory.tsx, its test | T15 (merge first) | awaiting-owner | #102 |

You reviewed both PRs earlier and found nothing to fix. The user comes back and asks: **"where are we?"** You checked (results, since you can't run commands here):

- `gh pr view 101 --json reviewDecision,latestReviews`: `CHANGES_REQUESTED` by @ana (a member of @acme/backend, the code owner). Her review comment on `src/api/orders.ts:42`: "Use the carrier's business-day calendar, not calendar days, or weekend orders show the wrong date."
- `gh pr view 102 --json reviewDecision,latestReviews`: `APPROVED` by @ana.

You can't run commands or start subagents here, but you can read the plugin's own files (the skill and its references) with Read. Write your reply to the user, and say what you do next with each PR.
