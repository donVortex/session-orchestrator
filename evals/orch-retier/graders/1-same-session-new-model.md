---
type: llm
weight: 1
---

The response is an orchestrator carrying out a re-tier of a failed `standard` task to `deep`. The worker session is `local_4b2` (sonnet), and the orchestrator runs on opus.

The orchestrator can't run tools in this eval, so it describes the calls it would make. Grade that plan: a step it says it would take counts as taken. Check only what PASS and FAIL below name; nothing else counts for or against it.

PASS if: it keeps the same worker session `local_4b2` and switches its model to opus with `set_session_model` (a full opus model id, such as `claude-opus-5-5`), and has it run at effort `high`, the effort for a bug whose cause is unknown (setting it with `set_session_effort`, or keeping it because the session is already at `high`, both pass).

FAIL if it starts a new session for the re-tier, never switches the model, or takes the task over itself.
