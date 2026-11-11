---
type: llm
weight: 1
---

The response is an orchestrator handling a failed first round of a deep design task whose worker session runs on opus at medium effort.

PASS if: before sending the work back, it raises the worker session's effort one step (to `high`, e.g. with set_session_effort) and keeps the same model; it sends the failure back to the same worker.

FAIL if it sends the work back without raising effort, jumps to a different model or tier first, takes the task over itself, or asks the user before trying once more.
