---
type: llm
weight: 1
---

The response is an orchestrator's plan-approval message for a visual redesign of a static portfolio site (new style, card layout, hero animation; no backend, data or auth).

PASS if: no task is tiered `deep` (the mockup, the style foundation, the page rebuilds and the hero animation are `standard`, or `fast` for small edits), so no task runs on opus.

FAIL if any task is `deep`, or the plan says a task runs on opus.
