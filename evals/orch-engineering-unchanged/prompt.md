---
max_turns: 10
allowed_tools: [Read, Glob, Grep, Skill]
tags: [orchestrator, designer, default]
---

First load the session-orchestrator:orchestrating skill with the Skill tool, as an orchestrator session does at its start.

You are in github.com/acme/shop (standalone install, desktop backend). The user's goal: **"Show the estimated delivery date for each order on the order history page."** The user's personal instructions say nothing about the orchestrator.

Intake facts (you can't run commands here; these are their results): no `.orchestration/ledger.md`; earlier orchestrations are archived with tasks up to T14; `git remote` and `gh auth status` work; commands `npm test`, `npm run lint`, `npm run build`. Project knowledge exists (`domain.md`, `map.md`, `review-checklist.md`, `calibration.md`, `product.md`), and the folder also has a `designer.md` that a designer on the team created. `.github/CODEOWNERS` on `main`: `src/api/** @acme/backend` and `src/db/** @acme/backend`. The order history page is `src/pages/OrderHistory.tsx`. `GET /api/orders` (`src/api/orders.ts`) returns orders without any delivery estimate; the estimate can be computed in `src/api/orders.ts` from the existing `shippedAt` and `carrier` columns. The project's `calibration.md` has the split pattern "a small API field and the page that shows it go in one task". The expert view is skipped for this goal. No pre-flight entries, no overlapping workflow skills, no examples given.

You can't run commands or start subagents here, but you can read the plugin's own files (the skill and its references) with Read. Write the message that shows the plan for approval.
