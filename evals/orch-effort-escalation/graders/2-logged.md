---
type: llm
weight: 1
---

The response is an orchestrator handling a failed round.

PASS if: it records the failure and the effort change in the ledger (for example `[failed] T7 …` and `[escalate] T7 effort medium → high`), or clearly says it logs both.

FAIL if the ledger isn't mentioned.
