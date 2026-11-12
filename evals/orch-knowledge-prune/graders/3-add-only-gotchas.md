---
type: llm
weight: 1
---

The response is an orchestrator's wrap-up. T11's retro has two `[domain]` points: "Routes live in `src/api/`, one file per resource" (already visible in the folder structure, and already in map.md) and "Order totals are recomputed on the server at checkout; the client total is display only and never charged" (a rule the code doesn't make obvious).

PASS if: the knowledge diff adds an entry for the server-side order total, and does not add a new entry saying routes live in `src/api/`.

FAIL if it leaves out the order-total rule, or adds a routes-live-in-`src/api/` entry.
