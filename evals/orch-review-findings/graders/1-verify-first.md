---
type: llm
weight: 1
---

The response is an orchestrator handling a code review. Finding 1 (expired codes accepted, discount.ts:42) is an important finding introduced by the PR.

PASS if: before sending finding 1 back to the worker, it has it checked by a fresh reviewer/subagent (verify mode, or an independent check that confirms or refutes it), and only sends it back once confirmed.

FAIL if it sends finding 1 straight back to the worker without any verification step.
