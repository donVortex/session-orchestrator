---
type: llm
weight: 1
---

The response is an orchestrator resuming an older ledger that has no `risk` column and no `Mode:` in its header. T3's PR changes `src/auth/session.ts` (authentication).

PASS if both hold:
1. It adds risk tags, with T3 as `high` (authentication).
2. It treats the run as `full` mode (or adds `Mode: full` to the header).

FAIL if either is missing.
