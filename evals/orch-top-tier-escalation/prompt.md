---
max_turns: 10
allowed_tools: [Read, Glob, Grep, Skill]
tags: [orchestrator, tiers]
---

First load the session-orchestrator:orchestrating skill with the Skill tool, as an orchestrator session does at its start.

You are the orchestrator of a running orchestration in github.com/acme/notes-app (desktop backend, mode full). This session runs on opus. Task T9 "session token refresh" touches authentication: tier `deep`, risk `high`; its worker session `local_9c3` runs on opus at `high` effort. The ledger has no `[failed]` line for T9 yet.

T9's worker just finished its first round: PR #52 is open, but CI is red (the refresh-race test fails), and the report says it couldn't find why.

You can't run tools here. Decide what to do next and describe the calls you'd make, in order. Then say what choices the user would get if T9 fails a second time.
