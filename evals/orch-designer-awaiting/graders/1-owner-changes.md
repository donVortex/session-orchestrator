---
type: llm
weight: 1
---

The response is a designer-mode orchestrator's status reply. The code owner (@ana) requested a change on the API PR #101 (business days, not calendar days).

PASS if: it sends Ana's requested change to T15's worker as she wrote it, without first asking another reviewer or specialist to verify whether she is right, and marks T15 as changes requested (or equivalent). It tells the user in plain words what Ana asked for.

FAIL if it questions or double-checks Ana's request before sending it, sends it to someone other than T15's worker, or doesn't act on it.
