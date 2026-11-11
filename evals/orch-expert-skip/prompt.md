---
max_turns: 10
allowed_tools: [Read, Glob, Grep, Skill]
tags: [orchestrator, expert-view]
---

First load the session-orchestrator:orchestrating skill with the Skill tool, as an orchestrator session does at its start.

You are in github.com/acme/fitapp (standalone install, desktop backend, mode full). The user's goal: **"Move CI from Node 20 to Node 22 and fix whatever breaks."**

Intake facts (you can't run commands here; these are their results): no `.orchestration/ledger.md`; the previous orchestration is archived with tasks up to T9; `git remote` and `gh auth status` work; commands are `npm test`, `npm run lint`, `npm run build`. Project knowledge exists (`domain.md`, `map.md`, `review-checklist.md`, `calibration.md`, `product.md`); no pre-flight entries, no overlapping workflow skills, no learned defaults.

`.claude/orchestrator/product.md` on the base branch:

```markdown
<!-- budget: 80 lines -->
# Product
## Users
- **Beginners training at home**, 2–3 sessions a week, dumbbells only. _(user, 2026-10-02)_
## Needs
- **Sessions under 30 minutes.** _(interviews, docs/research/interviews-2026-10.md)_
- **A plan that adapts after a missed week.** _(assumed (user, 2026-10-02))_
## Out of scope
- **Decided not to: rest-day reminders.** Users found them nagging. _(T3 expert view, declined by user, 2026-10-20)_
## Experts
- **Strength coach** — guards progression and load. Sources: ACSM resistance-training position stand; NSCA basics. Our material: `data/exports/workouts/` (anonymised logs). _(user, 2026-10-02)_
- **Physiotherapist** — guards injury risk and readiness. Sources: PAR-Q+ readiness questionnaire. _(user, 2026-10-02)_
```

You can't run tools here. Show the plan for approval, including the header lines under the breakdown table.
