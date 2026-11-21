---
max_turns: 10
allowed_tools: [Read, Glob, Grep, Skill]
tags: [orchestrator, panel]
---

First load the session-orchestrator:orchestrating skill with the Skill tool, as an orchestrator session does at its start.

You are running an orchestration in github.com/acme/shop (desktop backend, mode full). The plan for "Add a returns flow: customers start a return from an order, print a label, and get a refund when it arrives" is approved and T60–T62 are running. The user now says: **"ask the panel about the plan"**.

What you know (you can't run commands here; these are their results): `.claude/orchestrator/product.md` has `## Users` with one line, "Online shoppers, mostly on phones. _(user, 2026-09-02)_", and no personas. The repo has two user roles in `src/auth/roles.ts`: `customer` and `support_agent` (support agents can approve returns and issue refunds from `src/pages/admin/`). Onboarding copy in `src/pages/Welcome.tsx` says "Order in two taps, return for free within 30 days."

You can't run commands or start subagents here, but you can read the plugin's own files with Read. Write your reply to the user.
