---
type: llm
weight: 1
---

The response is an orchestrator's plan for a CI upgrade.

PASS if: the plan header says the expert view was skipped, with a reason, and how to run it anyway — e.g. `Expert view: skipped (CI change) — say "expert view" to run it`.

FAIL if the expert view isn't mentioned at all, or the line doesn't say how to run it.
