---
type: llm
weight: 1
---

The response says what choices the user gets if a task that is already `deep` fails a second time.

PASS if: the choices are along the lines of re-split, the orchestrator takes it over as `self`, or drop it, and re-tiering to `deep` is not offered (the task is already `deep`).

FAIL if re-tiering to `deep` is offered as a choice.
