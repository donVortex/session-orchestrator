---
type: llm
weight: 1
---

The response is an orchestrator planning a lite-mode run for a fitness-app goal.

PASS if: step 1 does not run an expert view, and the plan header says it's off in lite and how to ask for it — e.g. `Expert view: off in lite — say "expert view" to run it`.

FAIL if step 1 runs an expert view, or doesn't mention it at all.
