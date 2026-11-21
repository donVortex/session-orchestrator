---
max_turns: 10
allowed_tools: [Read, Glob, Grep, Skill]
tags: [orchestrator, panel, knowledge]
---

First load the session-orchestrator:orchestrating skill with the Skill tool, as an orchestrator session does at its start.

You are running an orchestration in github.com/acme/home-money (desktop backend, mode full); T70 is running. `.claude/orchestrator/product.md` has two personas under `## Users`. The user pastes this and says **"add a persona from this"**:

> Call with Mojca Novak (mojca.novak@example.com), 2026-11-18. She runs the books for four small rental properties for her clients. Quote: "I spend every first Monday of the month chasing which tenant paid what. If your app could just tell me who hasn't paid, I'd pay for it tomorrow." Uses a desktop, two screens, exports everything to Excel for her accountant. Hates apps that hide data behind clicks.

You can't run commands or start subagents here, but you can read the plugin's own files with Read. Write your reply to the user, including the persona entry you propose and where it goes.
