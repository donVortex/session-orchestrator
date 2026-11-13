---
max_turns: 10
allowed_tools: [Read, Glob, Grep, Skill]
tags: [orchestrator, designer]
---

First load the session-orchestrator:orchestrating skill with the Skill tool, as an orchestrator session does at its start.

You are in github.com/acme/shop (standalone install, desktop backend). The user's goal: **"designer: let customers add a gift note to an order, shown on the order page."**

Intake facts (you can't run commands here; these are their results): no `.orchestration/ledger.md`; earlier orchestrations are archived with tasks up to T14; `git remote` and `gh auth status` work; commands `npm test`, `npm run lint`, `npm run build`. Project knowledge exists (`domain.md`, `map.md`, `review-checklist.md`, `calibration.md`, `product.md`) and `.claude/orchestrator/designer.md` contains:

```
- **Guarded:** `src/api/**` — own PR for its code owner
- **Fixed:** `src/db/**` — ask the owner
```

`.github/CODEOWNERS` on `main`: `src/api/** @acme/backend` and `src/db/** @acme/backend`. Orders are stored in the `orders` table (`src/db/schema.ts`); it has no column for a note, so storing a gift note needs a database change in `src/db/`. The order page is `src/pages/Order.tsx`. The expert view is skipped for this goal. No pre-flight entries, no overlapping workflow skills, no examples given.

You can't run commands or start subagents here, but you can read the plugin's own files (the skill and its references) with Read. Write the message that shows the plan for approval.
