---
type: llm
weight: 1
---

The response is an orchestrator handling a failed round.

PASS if: it records the failure and the effort change in the ledger (for example `[failed] T9 …` and `[escalate] T9 effort high → xhigh`), or clearly says it logs both.

FAIL if the ledger isn't mentioned.
