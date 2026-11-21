---
type: llm
weight: 1
---

The response is an orchestrator's wrap-up. A page-rebuild subtask escalated once, in one run, and the retro says the cause was a missing brief detail (the old page's actions weren't listed), not the model.

PASS if all of these hold:
- the knowledge diff does NOT propose a `Tier:` entry (or a Tiers by task type entry) making page rebuilds `deep`;
- it proposes the brief fix instead: a "Briefs need" item (or similar) that page-rebuild briefs list every action the old page offers at each width.

FAIL if it proposes raising page rebuilds (or settings pages, or that kind of UI work) to `deep`, or leaves out the brief fix.
