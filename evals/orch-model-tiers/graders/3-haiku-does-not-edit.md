---
type: llm
weight: 1
---

The response is an orchestrator's plan. Task 1 is a mechanical rename across files (a `fast` task).

PASS if: the code-writing subagents for the rename run on sonnet (or above), not haiku. Haiku may be mentioned only for read-only work such as searching.

FAIL if the plan has haiku subagents editing code for the rename.
