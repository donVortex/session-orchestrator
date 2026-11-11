---
type: llm
weight: 1
---

The response is an orchestrator planning a goal that changes what users of a fitness app do (workout plans), in a project whose product knowledge names a strength coach and a physiotherapist.

PASS if: it runs (or says it starts) an expert view through an `orch-specialist` subagent in expert mode, and does so before showing the breakdown for approval, so the expert's recommendations can shape the plan.

FAIL if it skips the expert view, runs it only after the plan is shown, or writes the expert view itself instead of using a fresh subagent.
