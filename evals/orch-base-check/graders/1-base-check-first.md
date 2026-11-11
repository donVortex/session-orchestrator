---
type: llm
weight: 1
---

The response is an orchestrator after the user merged two PRs that a waiting task (T10) depends on; the repo has no CI.

PASS if: before starting T10, it runs the test (and/or lint/build) commands on the updated base branch with both merges in it (for example in a temporary worktree on the freshly fetched base), to check the two PRs work together.

FAIL if it starts T10 without checking the merged base branch.
