---
max_turns: 10
allowed_tools: [Read, Glob, Grep, Skill]
tags: [orchestrator, tiers]
---

First load the session-orchestrator:orchestrating skill with the Skill tool, as an orchestrator session does at its start.

You are the orchestrator of a running orchestration in github.com/acme/notes-app (desktop backend, mode full). Task T7 "plugin interface for exporters" is design work, tier `deep`, risk `normal`; its worker session `local_7a1` runs on opus at `medium` effort. The ledger has no `[failed]` line for T7 yet.

T7's worker just finished its first round: PR #40 is open, but CI is red (3 tests fail in `src/export/registry.test.ts`), and the report says it ran out of ideas on the registry ordering bug.

You can't run tools here. Decide what to do next and describe the calls you'd make, in order.
