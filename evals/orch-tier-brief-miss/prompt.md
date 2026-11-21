---
max_turns: 10
allowed_tools: [Read, Glob, Grep, Skill]
tags: [orchestrator, tiers, workflow]
---

First load the session-orchestrator:orchestrating skill with the Skill tool, as an orchestrator session does at its start.

You are in github.com/acme/home-money (standalone install). Both tasks of this orchestration are merged (T31 → PR #80, T32 → PR #81), so it's time for the wrap-up.

- `.claude/orchestrator/` on `main` has `domain.md`, `map.md`, `review-checklist.md` and `calibration.md` (its `## Tiers by task type` and `## Briefs need` headings are empty), all with room. No knowledge PR is open.
- Ledger: the only rework event is `[escalate] T32 subtask B escalated standard → deep`. No `[ask-user]`, `[failed]` or `[changes]` lines.
- T32's report, Subtasks table:

| Subtask | Kind | Tier | Outcome | Review found |
|---|---|---|---|---|
| A | Budget page layout in `src/pages/` | standard | first try | nothing |
| B | Settings page rebuild in `src/pages/` | standard | escalated to deep | minor |

- T32's retro: `[tier] B escalated: the sonnet implementer dropped the phone-width actions menu and the delete confirmation. Neither was in the brief, and the old page's code was the only place that showed them. Opus found them by reading the old page.` and `[brief] Page rebuild briefs should list every action the old page offers at each width.`
- No archived report has a page rebuild in it.

The knowledge files are not available here, so describe the knowledge diff instead of making it. Do the wrap-up.
