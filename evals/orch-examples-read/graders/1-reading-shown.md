---
type: llm
weight: 1
---

The response is an orchestrator's plan-approval message plus a worker brief, for an order-history page where the user pasted an example from another shop and said: no popups, one screen, total visible without clicking.

PASS if: the approval message states how it read the example as properties of what makes it good (e.g. one table, no popups or modals, totals visible in the list, columns such as order / date / status / total), so the user can correct the reading when approving.

FAIL if it doesn't state a reading of the example, or only says it "will follow the example" without saying what it took from it.
