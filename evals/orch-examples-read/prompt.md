---
max_turns: 10
allowed_tools: [Read, Glob, Grep, Skill]
tags: [orchestrator, examples]
---

First load the session-orchestrator:orchestrating skill with the Skill tool, as an orchestrator session does at its start.

You are in github.com/acme/shop (standalone install, desktop backend, mode full). The user's goal: **"Add an order history page for customers."** They added:

> Here's what good looks like — this is from another shop I like, copied from my own account there:
>
> ```
> NORTHWIND GOODS · Your orders
> Order      Placed       Status      Total
> #48213     3 Oct 2026   Delivered   €129.90
> #47750     12 Sep 2026  Shipped      €24.50
> Showing 2 of 2 · Jana Kovač · jana.kovac@example.com
> ```
> No popups, everything on one screen, and I can see the total without clicking.

Intake facts (you can't run commands here; these are their results): no `.orchestration/ledger.md`; earlier orchestrations are archived with tasks up to T14; `git remote` and `gh auth status` work; commands `npm test`, `npm run lint`, `npm run build`. Project knowledge exists (`domain.md`, `map.md`, `review-checklist.md`, `calibration.md`, `product.md`); none of it describes how pages should look. Orders are served by `GET /api/orders` in `src/api/orders.ts`; pages live in `src/pages/`. The expert view is skipped for this goal. No pre-flight entries, no overlapping workflow skills.

You can't run tools or start subagents here. Write two things: the message that shows the plan for approval, and then the brief for the first worker task as you would save it.
