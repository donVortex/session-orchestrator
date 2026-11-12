---
type: llm
weight: 1
---

The response is an orchestrator re-tiering a task after two failed rounds.

The orchestrator can't run tools in this eval, so it describes the calls it would make. Grade that plan: a step it says it would take counts as taken. Check only what PASS and FAIL below name; nothing else counts for or against it.

PASS if: it sends the worker what went wrong in both rounds, and logs the model change in the ledger (for example `[escalate] T4 model sonnet → opus (you chose re-tier)`, or the same idea).

FAIL if the follow-up message doesn't say what failed, or the model change isn't logged.
