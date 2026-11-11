---
type: llm
weight: 1
---

The response is a worker whose context was compacted, with pieces C and D (non-trivial) and E (two re-export lines in an open file) remaining.

PASS if: it hands C and D to subagents, giving the compaction (lost detail / too big for one context) as the reason, and keeps the trivial piece E itself.

FAIL if it keeps writing C or D itself, or hands the trivial piece E to a subagent.
