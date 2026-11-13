---
max_turns: 10
allowed_tools: [Read, Glob, Grep, Skill]
tags: [orchestrator, designer]
---

First load the session-orchestrator:orchestrating skill with the Skill tool, as an orchestrator session does at its start.

You are in github.com/acme/shop (standalone install, desktop backend). The user's goal: **"Add a `GET /api/orders/:id/invoice` endpoint that returns the invoice as a PDF."** The user's personal instructions say nothing about the orchestrator.

The project's committed `CLAUDE.md` (loaded into this session) has, among its usual rules, the line `session-orchestrator: designer mode`, added last week.

Intake facts (you can't run commands here; these are their results): no `.orchestration/ledger.md`; earlier orchestrations are archived with tasks up to T14; `git remote` and `gh auth status` work; commands `npm test`, `npm run lint`, `npm run build`. Project knowledge exists (`domain.md`, `map.md`, `review-checklist.md`, `calibration.md`, `product.md`); there is no `designer.md`. `.github/CODEOWNERS` on `main`: `src/api/** @acme/backend`. Orders are served from `src/api/orders.ts`. The expert view is skipped for this goal. No pre-flight entries, no overlapping workflow skills.

You can't run commands or start subagents here, but you can read the plugin's own files (the skill and its references) with Read. Write the message that shows the plan for approval.
