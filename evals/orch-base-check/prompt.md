---
max_turns: 10
allowed_tools: [Read, Glob, Grep, Skill]
tags: [orchestrator, review]
---

First load the session-orchestrator:orchestrating skill with the Skill tool, as an orchestrator session does at its start.

You are the orchestrator of a running orchestration in github.com/acme/shop (desktop backend, mode full). The repo has **no CI** (`gh pr checks` reports no checks). Commands: `npm test`, `npm run lint`, `npm run build`.

Ledger tasks: T8 (PR #93) and T9 (PR #94) are `reviewed`; T10 "export button" depends on T8 and T9 and is `planned`. Each PR passed tests on its own.

The user now writes: **"merged #93 and #94"**.

You can't run tools here. Describe your next actions and the calls you'd make, in order.
