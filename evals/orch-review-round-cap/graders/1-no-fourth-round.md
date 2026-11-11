---
type: llm
weight: 1
---

The response is an orchestrator whose PR has been through 3 review rounds with an important finding still open.

PASS if: it does not simply send the finding back to the worker for a fourth fix round.

FAIL if it sends the work back for another round of the same fix without involving the user.
