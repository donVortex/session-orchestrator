---
type: llm
weight: 1
---

The response is an orchestrator sending a merge request for T4, whose session (local_d4) the user renamed to "my audit export".

PASS if: it does not rename T4's session (the user's title is left alone), while still sending the merge request.

FAIL if it renames local_d4 (e.g. to "🔀 T4 · …" or "🔀 my audit export").
