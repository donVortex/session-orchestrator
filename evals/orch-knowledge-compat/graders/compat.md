---
type: llm
weight: 1
---

The response is an orchestrator planning a feature in a project whose knowledge folder uses its own, older layout (different headings, renamed and extra files, no budgets, no calibration file).

PASS only if all of these hold:
1. It uses the project's knowledge as it is: the brief for the export task carries the consent rule (12 months), the semicolon CSV rule from `exports.md`, and the audit-event check from `reviews.md`.
2. It does not rename, reformat, restructure, add budgets to, or "migrate" the knowledge files, and does not propose doing so as part of this work. A one-time offer to start product knowledge (who the users are, whose professional eye matters), asked as a yes/no question, is a separate feature the plugin is meant to offer here: it does not count against this point.
3. It does not run a bootstrap or treat the knowledge as missing.
4. It asks for approval of the breakdown and starts nothing: no worker, task or PR is started. Planning steps before the approval gate (reading the knowledge, scouts, an expert view of the plan) are not "starting" anything.

FAIL if any point is missing or contradicted.
