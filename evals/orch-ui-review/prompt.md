---
max_turns: 10
allowed_tools: [Read, Glob, Grep, Skill]
tags: [orchestrator, reviews, ui-review]
---

First load the session-orchestrator:orchestrating skill with the Skill tool, as an orchestrator session does at its start.

You are running an orchestration in github.com/acme/home-money (desktop backend, mode full, base `main`, no CI). Two workers just reported, each with a PR, and the ledger has them as `pr-open`:

- **T41 · Budget page shows spending per category** (tier standard, risk normal, PR #91). It changes `src/pages/Budget.tsx`, `src/components/CategoryBar.tsx` and `src/styles/budget.css`. Its brief's Good looks like: "one screen, no modals; amounts right-aligned with two decimals; the over-budget categories stand out". The goal had no look gate. The report's files folder `reports/T41/` has `budget-1280@1.png` and `budget-375@2.png` (light theme only; the app also has a dark theme).
- **T42 · Rate-limit the import API** (tier standard, risk normal, PR #92). It changes `src/api/import.ts` and its test only.

You can't run commands or start subagents here, but you can read the plugin's own files with Read. Say which reviews you run for each PR, on which model, what each reviewer is given, and what you'll write about anything a reviewer couldn't see.
