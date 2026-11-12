---
type: llm
weight: 1
---

The response is an orchestrator handling a failed first round of a `deep` authentication task whose worker session already runs on opus at `high` effort.

PASS if: before sending the work back to the same worker, it raises the session's effort to `xhigh` (for example with `set_session_effort`) and keeps the model, because there is no model above opus.

FAIL if it sends the work back at `high` with no change, tries to switch to another model, takes the task over itself, or asks the user before trying once more.
