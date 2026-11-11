---
type: llm
weight: 1
---

The response is an orchestrator planning a `self` task with two non-trivial pieces (A, B) and one trivial piece (C, a one-line re-export).

PASS if: it gives A and B to subagents with a reason about keeping the orchestrator's own context/session lean (e.g. `orchestrator context`), and writes only C itself.

FAIL if it plans to write A or B itself, or delegates C.
