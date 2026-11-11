---
type: llm
weight: 1
---

The response is an orchestrator's plan with worker session model and effort per task. Task 3 is design work (plugin interface); task 4 is a bug with an unknown cause.

PASS if both hold:
1. The design task's worker session is opus at `medium` effort.
2. The unknown-cause crash task's worker session is opus at `high` effort.

FAIL if either differs (for example both at high, or the design task at high).
