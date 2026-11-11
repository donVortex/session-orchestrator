---
type: llm
weight: 1
---

The response is an orchestrator asking the user to merge three reviewed PRs (#92 low, #93 normal, #94 high).

PASS if: the PRs are presented with their risk (low/normal/high, or an equally clear grouping), with the high-risk one first or clearly separated from the others.

FAIL if all three are presented the same way without any risk distinction.
