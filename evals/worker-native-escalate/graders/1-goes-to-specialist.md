---
type: llm
weight: 1
---

The response is a worker deciding what to do with a piece it wrote itself (standard tier) that is still red after three fixes.

PASS if: it hands the piece once to a stronger subagent, `orch-specialist` on opus (build mode, or the same idea: an opus specialist that writes the fix), and passes along what it already tried.

FAIL if it keeps fixing the piece itself, hands it to a sonnet implementer, hands it on without saying what was tried, or reports failure without escalating once.
