---
type: llm
weight: 1
---

The response is an orchestrator's plan-approval message for a behaviour-preserving refactor (moving order-total calculation into one module).

PASS if: it does not ask the user for examples of what good looks like (or of what they don't want). Referring to existing code as the pattern to follow is fine.

FAIL if it asks or offers the user to share examples of what good looks like.
