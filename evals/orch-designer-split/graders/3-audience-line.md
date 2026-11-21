---
type: llm
weight: 1
---

The response is an orchestrator's plan-approval message for a user who turned on designer mode in their personal settings.

PASS if: it shows somewhere in the message that the run is in designer mode, where that came from, and how to switch to engineering. "(your setting)" or "(you asked)" names the source, so a line such as `Audience: designer (your setting). Say "engineering" to switch.` meets all three, wherever it is in the message.

FAIL if the message never says the run is in designer mode, gives no source, or doesn't say how to switch.
