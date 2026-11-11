---
type: llm
weight: 1
---

The response is a worker whose context was compacted, with pieces C and D remaining.

PASS if: it hands C and D to subagents (implementers), giving the compaction (lost detail / too big for one context) as the reason.

FAIL if it continues writing C and D itself.
