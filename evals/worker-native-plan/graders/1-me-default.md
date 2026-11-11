---
type: llm
weight: 1
---

The response is a worker's plan for a task with pieces A–E. A–D are small code and docs changes; E is a read-only search.

PASS if: the worker plans to write pieces A, B, C and D itself (marked `me` or clearly "I write it"), not through implementer subagents.

FAIL if any of A–D goes to an implementer or specialist subagent.
