---
type: llm
weight: 1
---

The response is an orchestrator logging an expert view where 2 recommendations were proposed, E1 adopted, E2 declined ("our plans are only 8 weeks").

PASS if both hold:
1. It logs a line like `[expert] T11 strength coach: 2 proposed, 1 adopted` (target, expert, counts).
2. It records E2 as declined with the reason (e.g. `[expert] declined E2: our plans are only 8 weeks`) and says it goes into product knowledge's Out of scope at wrap-up (or similar).

FAIL if either is missing.
