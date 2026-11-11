---
max_turns: 10
allowed_tools: [Read, Glob, Grep, Skill]
tags: [orchestrator, expert-view]
---

First load the session-orchestrator:orchestrating skill with the Skill tool, as an orchestrator session does at its start.

You are the orchestrator of a running orchestration in github.com/acme/fitapp (desktop backend, mode full). Ledger excerpt:

| id | task | owns | depends | tier | risk | placement | session/run | branch | PR | status |
|----|------|------|---------|------|------|-----------|-------------|--------|----|--------|
| T10 | plan picker UI | src/ui/plans/** | — | standard | normal | worker | local_c10 | orch/T10 | #51 | merged |
| T11 | weekly progression logic | src/plans/progression.ts, src/plans/progression.test.ts | — | deep | normal | worker | local_d11 | orch/T11 | #52 | in-review |

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

The user writes: **"get the coach's eye on T11"**. You ran the expert view; it returned:

```markdown
## Expert view: T11 / PR #52 — strength coach
### 1. What a top professional would do that wasn't asked
- E1. Cap weekly load increase at 10% and repeat the week after two missed sessions — beginners stall or get hurt with faster jumps — rests on S1
- E2. Add a deload every 4th week — rests on S1 (recalled only)
### 2. Raw material
- S1. ACSM resistance-training position stand — recalled — progression rates for novices
### 3. Methods and tools
- RPE-based progression, for E1
### 4. What shows it's right, besides us
- C1. A certified coach signs off on the progression table — after merge
```

The user answers: **"adopt E1, decline E2 — our plans are only 8 weeks."**

You can't run tools here. Describe what you do next, in order, with the ledger lines you write.
