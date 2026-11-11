---
type: llm
weight: 1
---

The response is an orchestrator handling a worker (T3, session local_c3, title "⏳ T3 · coupon codes at checkout") that is blocked with a question.

PASS if: it renames that session to "❓ T3 · coupon codes at checkout" (the ❓ symbol replacing ⏳, the rest unchanged), alongside updating the ledger and asking the user the question.

FAIL if it doesn't rename T3's session, uses a different symbol, or changes the rest of the title.
