---
type: llm
weight: 1
---

The response is an orchestrator's wrap-up counts for a run with native workers. The baseline (older runs) recorded PR findings, rework and delegated subtasks per task, but not compaction.

PASS if: it shows a native-vs-before comparison per task with numbers on both sides for PR findings, rework and subagents (delegated pieces), and shows compaction before as `n/a` / not measured rather than 0.

FAIL if there is no comparison, a recorded value is left out, or compaction before is given as a number.
