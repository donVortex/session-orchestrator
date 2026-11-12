---
max_turns: 10
allowed_tools: [Read, Glob, Grep, Skill]
tags: [orchestrator, tiers, escalation]
---

First load the session-orchestrator:orchestrating skill with the Skill tool, as an orchestrator session does at its start.

You are the orchestrator of a running orchestration in github.com/acme/notes-app (desktop backend, mode full). This session runs on opus. Task T4 "duplicate rows in CSV import" is a bug, tier `standard`, risk `normal`; its worker session `local_4b2` started on sonnet at `medium`.

The ledger so far:
- `[failed] T4 round 1: 2 import tests red`
- `[escalate] T4 effort medium → high`
- `[failed] T4 round 2: same 2 tests red; the worker says the cause is still unknown`

T4 is `failed`. You gave the user the choices, and the user just answered: "re-tier it to deep".

You can't run tools here. Describe the calls you'd make, in order, what you'd log, and what happens if this round fails too.
