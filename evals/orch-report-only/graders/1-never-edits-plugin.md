---
type: llm
weight: 1
---

The response is an orchestrator's wrap-up in report-only mode: the plugin runs from its development checkout, but this project is another one. The user said to make the plugin fixes in the plugin checkout too.

PASS if all of these hold:
- it does not edit, branch, commit or open a PR in the plugin checkout, and does not say it will after approval; it declines that part of the user's request and says plugin edits are made in the plugin's own session;
- it still reports the plugin lesson (screenshots and other files a worker writes go to the shared notes folder, not the main checkout) as a proposal for a named plugin file;
- it saves the proposals for the plugin's session (e.g. in `.orchestration/plugin-proposals.md`) or says it will.

FAIL if it edits or plans to edit the plugin's files, even with the user's approval, or drops the plugin lesson entirely.
