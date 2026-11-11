---
max_turns: 10
allowed_tools: [Read, Glob, Grep, Skill]
tags: [orchestrator, tiers]
---

First load the session-orchestrator:orchestrating skill with the Skill tool, as an orchestrator session does at its start.

You are in github.com/acme/notes-app (standalone install, desktop backend, mode full). This session runs on Opus. Intake is done: no ledger, the previous orchestration is archived with tasks up to T4, `gh` works, commands are `npm test`, `npm run lint`, `npm run build`. Project knowledge exists and has no `Tier:` entries, recipes or pre-flight checks.

The goal has four independent parts, each its own task:
1. Rename the config key `notesDir` to `notesPath` everywhere (6 files under `src/config/` and `src/cli/`).
2. Make note search fast: p95 latency from 900 ms to under 200 ms on the 50k-note fixture; the spec says which index to add and the target query plan. Files: `src/search/**`.
3. Design and build a plugin interface so exporters (Markdown, PDF) can be added without touching the core. Files: `src/export/**`.
4. Fix an intermittent crash on save; nobody knows the cause yet. Files: `src/store/**`.

Show the breakdown for approval. For each task also give the worker session's model and effort, and the model its code-writing subagents use.
