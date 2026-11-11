---
max_turns: 10
allowed_tools: [Read, Glob, Grep, Skill]
tags: [orchestrator, review]
---

First load the session-orchestrator:orchestrating skill with the Skill tool, as an orchestrator session does at its start.

You are the orchestrator of a running orchestration in github.com/acme/shop (desktop backend, mode full). Three PRs passed review and wait for the user to merge:

- T7 · PR #92 — README section for the new export (risk `low`); changes `README.md`.
- T8 · PR #93 — settings page for export format (risk `normal`); changes `src/ui/settings/export.tsx` and its test.
- T9 · PR #94 — adds an `export_format` column (risk `high`); changes `src/db/migrations/0042_export_format.sql`, `src/db/schema.ts`, and `.github/workflows/ci.yml` (adds a migration check step).

Write the message that asks the user to merge them.
