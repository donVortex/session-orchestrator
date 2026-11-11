---
type: llm
weight: 1
---

The response is an orchestrator describing the report of a `self` task.

PASS if: it says the Work line starts with `Work: self` (or clearly marks the task as self in the Work line).

FAIL if the Work line is described as a normal native worker line, or not mentioned.
