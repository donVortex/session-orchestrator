---
max_turns: 10
allowed_tools: [Read, Glob, Grep, Skill]
tags: [orchestrator, visual]
---

First load the session-orchestrator:orchestrating skill with the Skill tool, as an orchestrator session does at its start.

You are in github.com/acme/home-dashboard (standalone install, desktop backend, mode full). The user's goal: **"Redesign the whole dashboard: a calmer, denser look. Today it feels cluttered and the cards are too big."** The goal is clear enough: you have no clarifying question to ask.

Intake facts (you can't run commands here; these are their results): no `.orchestration/ledger.md`; earlier orchestrations are archived with tasks up to T23; `git remote` and `gh auth status` work; commands `npm test`, `npm run lint`, `npm run build`. Project knowledge exists (`domain.md`, `map.md`, `review-checklist.md`, `calibration.md`, `product.md`); none of it describes the visual style. The app has five pages (`src/pages/Overview.tsx`, `Energy.tsx`, `Climate.tsx`, `Security.tsx`, `Settings.tsx`), a light and a dark theme, and shared styles in `src/styles/`. The expert view is skipped for this goal. No pre-flight entries, no overlapping workflow skills, no examples given.

You can't run commands or start subagents here, but you can read the plugin's own files with Read. Write the message that shows the plan for approval.
