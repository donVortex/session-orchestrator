---
max_turns: 10
allowed_tools: [Read, Glob, Grep, Skill]
tags: [orchestrator, compatibility]
---

First load the session-orchestrator:orchestrating skill with the Skill tool, as an orchestrator session does at its start.

The plugin was just updated. You are a new session in github.com/acme/shop (desktop backend), and the user writes: **"continue the orchestration"**. `.orchestration/ledger.md`, written by the older plugin version:

```markdown
# Orchestration: session timeout and audit log
Started: 2026-11-04 · Backend: desktop · Base branch: main · Status: running

| id | task | owns (files/globs) | depends | tier | placement | session/run | branch | PR | status |
|----|------|--------------------|---------|------|-----------|-------------|--------|----|--------|
| T3 | idle session timeout | src/auth/session.ts, src/auth/session.test.ts | — | deep | worker | local_c3 | orch/T3 | #50 | in-review |
| T4 | audit log page | src/ui/audit/** | T3 | standard | worker | — | — | — | planned |

## Events
- 09:10 [event] T3 started (local_c3, opus/high)
- 11:40 [event] T3 report received → reports/T3.md
```

PR #50's diff changes only `src/auth/session.ts` and its test. You can't run tools here: describe what you do next, in order.
