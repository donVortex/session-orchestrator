---
max_turns: 10
allowed_tools: [Read, Glob, Grep, Skill]
tags: [orchestrator, native-workers]
---

First load the session-orchestrator:orchestrating skill with the Skill tool, as an orchestrator session does at its start.

You are the orchestrator of github.com/acme/shop (desktop backend, mode full, standalone install), at wrap-up. Every task is merged. You can't run tools here; these are the facts:

**This run (T20–T25), workers on the native loop.** Reports' Work lines and the PR reviews:

| task | area / kind | subagents | compacted | PR review: critical + important | rework |
|---|---|---|---|---|---|
| T20 | `src/billing/` state machine change | 1 | no | 2 | 1 |
| T21 | `src/billing/` state machine change | 0 | no | 2 | 1 |
| T22 | `src/ui/cart/` UI wiring | 2 | no | 0 | 0 |
| T23 | `src/ui/cart/` UI wiring | 1 | no | 0 | 0 |
| T24 | `src/search/` ranking | 3 | yes | 1 | 1 |
| T25 | `docs/` | 0 | no | 0 | 0 |

**Archived runs:**
- The previous run (T14–T19) also used native workers. Its `src/billing/` state machine tasks (T15, T17) each had 2 important PR findings and 1 rework. No search task compacted.
- Two older runs (T1–T13), from before native workers: their reports have no Work line. Per task they averaged 0.4 PR findings (critical + important), 0.9 rework, 0 compacted, and 7.0 subagents (implementers plus their per-subtask reviews).

Write the counts part of your wrap-up message and the knowledge-diff proposals that come from these numbers. Don't write the rest of the wrap-up.
