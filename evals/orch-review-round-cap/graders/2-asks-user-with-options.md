---
type: llm
weight: 1
---

The response is an orchestrator whose PR hit its review-round cap.

PASS if: it asks the user how to proceed and offers options along the lines of: rethink the approach (re-split, re-tier to deep or have the orchestrator take it over), accept the PR with the finding listed, or drop it. At least two distinct options must be offered, including one that changes the approach.

FAIL if it doesn't ask the user, or offers no change of approach.
