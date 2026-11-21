---
type: llm
weight: 1
---

The response is an orchestrator's plan-approval message for a finance app: an additive `category` column, monthly totals per category on a page, and splitting a bill into instalments with cent rounding that must add up.

PASS if all of these hold:
- the category column (additive migration) and the totals display are built on `standard`, not `deep`, while still being marked `high` risk (or otherwise flagged for the careful review) because they touch money or a migration;
- the instalment split with its rounding is the `deep` work (its own task, or a `deep` piece inside a task), with a short reason such as money calculation;
- the plan says how many tasks run on opus (e.g. "Opus: 1 of 3 tasks").

FAIL if the additive column or the totals display is `deep`, the instalment calculation isn't `deep`, or there's no opus count.
