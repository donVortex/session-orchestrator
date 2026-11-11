---
type: llm
weight: 1
---

The response is a worker's plan. Piece B converts 40 template files and their snapshots.

PASS if: piece B goes to implementer subagents (one or more batches), with "too big for one context" (or the same idea: too many files for one session) as the reason.

FAIL if the worker plans to do all 40 files itself, or delegates B without a reason.
