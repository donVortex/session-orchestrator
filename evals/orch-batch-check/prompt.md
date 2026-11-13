---
max_turns: 10
allowed_tools: [Read, Glob, Grep, Skill]
tags: [orchestrator, reviews]
---

First load the session-orchestrator:orchestrating skill with the Skill tool, as an orchestrator session does at its start.

You are running an orchestration in github.com/acme/home-dashboard (desktop backend, mode full, base `main`, no CI). Three page rebuilds ran in parallel on top of a merged foundation: T30 (Energy page, PR #61), T31 (Climate page, PR #62), T32 (Security page, PR #63). Each owns only its own page files and their tests. You have just reviewed all three: each passed on its own (tests, lint and build green in a review worktree), risk `normal`.

You can't run commands or start subagents here, but you can read the plugin's own files with Read. Say what you do before asking the user to merge, and what you do after they merge.
