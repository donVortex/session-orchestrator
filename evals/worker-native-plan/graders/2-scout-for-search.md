---
type: llm
weight: 1
---

The response is a worker's plan. Piece E is a read-only search for call sites of `getSetting(`.

PASS if: the search goes to a read-only scout (haiku, `orch-scout`) or is done directly with search tools; it is not given to an implementer.

FAIL if an implementer (or anything that can edit) does the search.
