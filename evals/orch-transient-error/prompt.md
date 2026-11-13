---
max_turns: 10
allowed_tools: [Read, Glob, Grep, Skill]
tags: [orchestrator, failures]
---

First load the session-orchestrator:orchestrating skill with the Skill tool, as an orchestrator session does at its start.

You are running an orchestration in github.com/acme/shop (desktop backend, mode full). The ledger has T7 (`Order history page`, tier standard, worker `local_7a1f`, effort medium) as `running`, with no failed rounds so far.

The app just woke you: T7's worker ended its turn without a report. Its last message is an API error: `API Error: 403 — <html><title>Just a moment...</title>` (a challenge page). You checked its worktree (results, since you can't run commands here):
- `git log --oneline -3`: `c41e2aa add order history table`, `9b03d1f order history route and test`, then the base commit;
- `git status`: `src/pages/OrderHistory.css` modified, not committed;
- the brief's subtasks are A (route + test), B (table), C (styles), D (empty and error states).

You can't run commands or start subagents here, but you can read the plugin's own files with Read. Say what you log and what you do next, and write the message you send the worker.
