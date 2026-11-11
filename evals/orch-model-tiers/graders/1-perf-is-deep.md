---
type: llm
weight: 1
---

The response is an orchestrator's plan. Task 2 (search performance, p95 900 ms → under 200 ms) has a clear spec but is performance work.

PASS if: the search performance task is tiered `deep` (opus), not `standard` or `fast`.

FAIL if it is `standard` or `fast`, or runs on sonnet.
