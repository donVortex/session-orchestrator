---
type: llm
weight: 1
---

The response is an orchestrator's plan-approval message for a goal where the user already gave an example of what good looks like.

PASS if: it shows the plan for approval and does not ask the user for more examples or for what good looks like (they already gave one). Asking one question about a genuine conflict in the example is fine.

FAIL if it asks the user for (more) examples, or holds the plan back until the user answers a question about examples.
