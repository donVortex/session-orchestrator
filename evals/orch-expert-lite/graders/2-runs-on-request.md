---
type: llm
weight: 1
---

The response is an orchestrator in a lite run; the user then asks for an expert view.

PASS if: in step 2 it runs the expert view (an `orch-specialist` in expert mode, with the strength coach and/or physiotherapist) on the plan before work starts.

FAIL if it refuses, says lite doesn't allow it, or starts work without it.
