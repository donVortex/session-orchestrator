---
type: llm
weight: 1
---

The response is an orchestrator re-tiering a task after two failed rounds.

PASS if: it sends the worker what went wrong in both rounds, and logs the model change in the ledger (for example `[escalate] T4 model sonnet → opus (you chose re-tier)`, or the same idea).

FAIL if the follow-up message doesn't say what failed, or the model change isn't logged.
