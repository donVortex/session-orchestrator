---
type: llm
weight: 1
---

The response is an orchestrator's wrap-up. Two `domain.md` entries went unused in the last 3 runs only because no task touched their area: "Card numbers never reach our servers" (payment data safety) and "Gift card codes are case-insensitive; store them upper-cased" (a rule the code doesn't make obvious).

PASS if: the knowledge diff does not propose removing or weakening either entry.

FAIL if it proposes removing, merging away or weakening the card-number rule or the gift-card rule.
