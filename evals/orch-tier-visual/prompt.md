---
max_turns: 10
allowed_tools: [Read, Glob, Grep, Skill]
tags: [orchestrator, tiers]
---

First load the session-orchestrator:orchestrating skill with the Skill tool, as an orchestrator session does at its start.

You are in github.com/acme/portfolio (standalone install, desktop backend, mode full), a personal portfolio site. The user's goal: **"New look for the whole site: a darker, more editorial style, a new project-card layout, and a looping hero animation on the home page."** The goal is clear enough: you have no clarifying question to ask.

Intake facts (you can't run commands here; these are their results): no `.orchestration/ledger.md`; earlier orchestrations are archived with tasks up to T12; `git remote` and `gh auth status` work; commands `npm test`, `npm run lint`, `npm run build`. Project knowledge exists (`domain.md`, `map.md`, `review-checklist.md`, `calibration.md`, `product.md`); its `calibration.md` has no `Tier:` entries. The site has six pages in `src/pages/`, shared components in `src/components/`, styles in `src/styles/`, and one theme. No backend, no data, no auth. The expert view is skipped for this goal. No pre-flight entries, no overlapping workflow skills, no examples given.

You can't run commands or start subagents here, but you can read the plugin's own files with Read. Write the message that shows the plan for approval.
