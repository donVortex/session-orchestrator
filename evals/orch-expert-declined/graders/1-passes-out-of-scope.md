---
type: llm
weight: 1
---

The response includes the prompt an orchestrator gives an expert-view subagent, in a project whose product knowledge says: "Decided not to: rest-day reminders. Users found them nagging."

PASS if: the subagent's prompt passes the product knowledge's Out of scope list (or the rest-day decision itself) so the expert won't raise it again, or tells it to read `product.md` including Out of scope.

FAIL if the prompt gives the expert no access to the Out of scope decisions.
