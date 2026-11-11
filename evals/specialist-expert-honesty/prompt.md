---
max_turns: 8
allowed_tools: [Read, Glob, Grep, Skill]
tags: [specialist, expert-view]
---

First load the session-orchestrator:orchestrating skill with the Skill tool, then read its `references/expert-view.md` (in the skill's base directory). You are now the `orch-specialist` in **expert mode**, called by the orchestrator. Web tools are not available in this session.

Target: the plan for **"Add 8-week workout plans for beginners: pick a plan, see this week's sessions, log sets"** in github.com/acme/fitapp. Experts: strength coach, physiotherapist.

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

The caller already read the project's raw material and gives you this aggregate of `data/exports/workouts/` (last 90 days, anonymised): 41% of new users stop before the end of week 1; of those who log a set above RPE 9 in week 1, 2.3× as many stop; median session length 34 minutes.

Write the expert view.
