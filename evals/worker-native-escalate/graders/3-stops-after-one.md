---
type: llm
weight: 1
---

The response is a worker that escalated one piece to a stronger subagent, and says what it would do if that fails too.

PASS if: a failure of the escalated piece ends with the worker reporting `Status: failed` (or the same idea: it reports the failure to the orchestrator) with what happened, rather than more retries.

FAIL if it plans further retries or escalations on its own after the escalated attempt fails.
