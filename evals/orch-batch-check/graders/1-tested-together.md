---
type: llm
weight: 1
---

The response is an orchestrator's plan for three parallel PRs that each passed review on their own.

PASS if all of these hold:
- before asking the user to merge, it merges the three PRs together onto the freshly fetched `main` in a temporary worktree and runs the test, lint and build commands there;
- it records something that identifies the tested result (such as the tree hash) and says in the merge ask that the batch was tested together;
- after the merges, it compares the merged `main` with what it tested (e.g. the tree hash) and skips the re-run if they match, or runs the normal base check if not.
It never merges a PR itself.

FAIL if it asks for the merges without testing the three PRs together first, or merges anything itself.
