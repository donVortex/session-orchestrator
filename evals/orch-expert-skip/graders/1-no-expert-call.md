---
type: llm
weight: 1
---

The response is an orchestrator planning a CI/Node-version upgrade in a fitness app.

PASS if: it does not run an expert view (no `orch-specialist` in expert mode, no strength-coach or physio recommendations).

FAIL if it runs an expert view or gives domain recommendations about training.
