---
type: llm
weight: 1
---

The response is a worker's plan for a brief written with an older template (it has no `Risk:` and no `Mode:` line).

PASS if: the worker goes ahead with a plan and does not stop to ask the orchestrator about the missing Risk or Mode fields (no `Status: blocked`, no question about them).

FAIL if it blocks or asks about the missing fields.
