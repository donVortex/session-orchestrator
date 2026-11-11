---
type: llm
weight: 1
---

The response is an orchestrator's wrap-up counts for a run with native workers. The baseline (older runs) recorded PR findings, rework and delegated subtasks per task, but not compaction.

PASS if the response contains a native-vs-before comparison (a line or a short table) that gives a before value and an after value for each of: PR findings, rework, and subagents/delegated subtasks; and marks compaction before as `n/a` or "not recorded" (an after value such as "1 of 6" is fine).

FAIL if there is no such comparison, one of those three has no before or after value, or compaction before is given as 0.
