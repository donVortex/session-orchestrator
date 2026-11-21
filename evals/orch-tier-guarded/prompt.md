---
max_turns: 10
allowed_tools: [Read, Glob, Grep, Skill]
tags: [orchestrator, tiers]
---

First load the session-orchestrator:orchestrating skill with the Skill tool, as an orchestrator session does at its start.

You are in github.com/acme/home-money (standalone install, desktop backend, mode full), a household finance app. The user's goal: **"Let me tag expenses with a category, show monthly totals per category on the Expenses page, and split a large bill into equal monthly instalments, with the cents rounding so the instalments always add up to the bill."** The goal is clear enough: you have no clarifying question to ask.

Intake facts (you can't run commands here; these are their results): no `.orchestration/ledger.md`; earlier orchestrations are archived with tasks up to T30; `git remote` and `gh auth status` work; commands `npm test`, `npm run lint`, `npm run build`. Project knowledge exists (`domain.md` with the rule "amounts are integer cents", `map.md`, `review-checklist.md`, `calibration.md`, `product.md`); `calibration.md` has no `Tier:` entries. Expenses live in the `expenses` table (`migrations/`, `src/db/expenses.ts`), the API in `src/api/expenses.ts`, the page in `src/pages/Expenses.tsx`. A category needs a new nullable `category` column (an additive migration). The expert view is skipped for this goal. No pre-flight entries, no overlapping workflow skills, no examples given.

You can't run commands or start subagents here, but you can read the plugin's own files with Read. Write the message that shows the plan for approval.
