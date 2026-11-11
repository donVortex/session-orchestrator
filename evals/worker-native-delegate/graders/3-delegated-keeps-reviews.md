---
type: llm
weight: 1
---

The response is a worker's plan with a delegated piece B.

PASS if: the delegated piece gets its own review (spec/quality review of that piece), and there is still one review of the whole diff before the PR.

FAIL if the delegated piece has no review of its own, or there is no whole-diff review.
