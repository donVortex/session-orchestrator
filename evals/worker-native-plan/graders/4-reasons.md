---
type: llm
weight: 1
---

The response is a worker's plan with a table of pieces.

PASS if: every piece not done by the worker itself names a reason (e.g. read-only, too big for one context, independent/parallel, harder than the task's tier).

FAIL if any delegated piece has no reason.
