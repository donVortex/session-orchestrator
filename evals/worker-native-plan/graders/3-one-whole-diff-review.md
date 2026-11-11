---
type: llm
weight: 1
---

The response is a worker's plan, including how the work will be reviewed.

PASS if: it plans one fresh review of the whole diff before the PR (an `orch-specialist` in review mode), and does not plan separate spec/quality reviews for each piece it writes itself.

FAIL if it plans per-piece reviews for its own pieces, or no review before the PR.
