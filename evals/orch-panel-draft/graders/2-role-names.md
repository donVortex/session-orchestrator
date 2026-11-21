---
type: llm
weight: 1
---

The response is an orchestrator's reply to "ask the panel about the plan" in a project whose product knowledge has no personas, only a one-line Users entry; the repo has `customer` and `support_agent` roles.

PASS if: the drafted personas are named by role or situation (e.g. "Phone shopper returning an item", "Support agent"), not by made-up personal names presented as real people, and each names a source (e.g. "your understanding").

FAIL if a persona has a personal name as if it were a real person, or has no source.
