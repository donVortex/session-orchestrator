---
type: llm
weight: 1
---

The response is an orchestrator after merges, planning a check of the base branch.

PASS if: it says what it does when that check fails — not starting T10 (or anything depending on the merges) until the base is fixed, and fixing or reporting the breakage.

FAIL if it doesn't address a failing base check, or would start T10 regardless.
