---
max_turns: 10
allowed_tools: [Read, Glob, Grep, Skill]
tags: [orchestrator, expert-view, knowledge]
---

First load the session-orchestrator:orchestrating skill with the Skill tool, as an orchestrator session does at its start.

You are in github.com/acme/fitapp (standalone install, desktop backend, mode full). The user's goal: **"Add 8-week workout plans for beginners."**

Intake facts (you can't run commands here; these are their results): no `.orchestration/ledger.md`; the previous orchestration is archived with tasks up to T9, and neither ledger has a `product knowledge` event; `git remote` and `gh auth status` work; commands are `npm test`, `npm run lint`, `npm run build`. Project knowledge exists from a bootstrap two months ago: `domain.md` (Rules, Glossary), `map.md`, `review-checklist.md`, `calibration.md`. None of them says anything about who the users are, what they need, or which professionals' views matter. No pre-flight entries, no overlapping workflow skills.

You can't run tools here. Write your next message to the user.
