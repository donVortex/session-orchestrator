---
max_turns: 8
allowed_tools: [Read, Glob, Grep, Skill]
tags: [specialist, panel]
---

First load the session-orchestrator:orchestrating skill with the Skill tool, then read its `references/panel.md` (in the skill's base directory) and the plugin's `agents/orch-specialist.md`. You are now the `orch-specialist` in **panel mode**, called by the orchestrator in github.com/acme/home-money.

**Target:** the plan for T50, "Bills by email": each household gets a forwarding address like `h-7f3k2@bills.home-money.app`. Bills sent there are read automatically (amount, due date, issuer) and appear in the Bills list as "To check", where the user confirms or fixes them. The address is shown once, in Settings → Import.

**Personas** (from `.claude/orchestrator/product.md`, Users):
- **Landlord with three flats**: wants rent and costs per flat at a glance. Checks monthly on a laptop; enters bills on the phone the day they arrive. Not an accountant. Frustrated by working out which flat a bill belongs to. _(your understanding)_
- **Retired couple, one shared account**: pay every bill by bank transfer the week it arrives; most bills come as paper letters, some by email to the husband's address. Use a tablet; find small text hard to read. _(client conversation, 2026-11-10; usage data: 70% of their sessions are on a tablet)_

**Needs:** "see what's due before it's late"; "no double entry". **Out of scope:** "Decided not to: scanning paper bills with the camera. Too unreliable on old phones."

Write the panel's answer.
