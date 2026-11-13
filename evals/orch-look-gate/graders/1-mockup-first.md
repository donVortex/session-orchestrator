---
type: llm
weight: 1
---

The response is an orchestrator's plan-approval message for a whole-app visual redesign (five pages, light and dark themes).

PASS if all of these hold:
- the first task is a mockup (static, no app code) of the affected screens, covering both themes and a phone width;
- the plan says the user approves the mockup's look before any UI code task starts (a look gate), and that the later page tasks match the approved mockup;
- it asks for approval of the plan and starts nothing.

FAIL if UI code tasks can start before the user approves a mockup, there is no mockup task, or the mockup leaves out a theme or the phone width.
