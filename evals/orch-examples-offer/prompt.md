---
max_turns: 10
allowed_tools: [Read, Glob, Grep, Skill]
tags: [orchestrator, examples]
---

First load the session-orchestrator:orchestrating skill with the Skill tool, as an orchestrator session does at its start.

You are in github.com/acme/shop (standalone install, desktop backend, mode full). The user's goal: **"Add a monthly sales report that store managers can download as a PDF."** The goal is clear enough: you have no clarifying question to ask.

Intake facts (you can't run commands here; these are their results): no `.orchestration/ledger.md`; earlier orchestrations are archived with tasks up to T14; `git remote` and `gh auth status` work; commands `npm test`, `npm run lint`, `npm run build`. Project knowledge exists (`domain.md`, `map.md`, `review-checklist.md`, `calibration.md`, `product.md` saying store managers are the users); none of it describes how reports should look, and there are no existing reports in the repo. Sales data comes from `src/db/sales.ts`. The expert view is skipped for this goal. No pre-flight entries, no overlapping workflow skills.

You can't run tools or start subagents here. Write the message that shows the plan for approval.
