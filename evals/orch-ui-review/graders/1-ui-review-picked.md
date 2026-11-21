---
type: llm
weight: 1
---

The response is an orchestrator's review plan for two PRs: T41 changes a page users see (with screenshots), T42 changes only an API and its test.

PASS if all of these hold:
- T41 gets a UI/UX review by a specialist on sonnet (not opus), started alongside its usual review (in parallel / the same message);
- that reviewer is given the brief's Good looks like properties and the screenshots (and ideally the base branch's version of the screen);
- T42 gets no UI/UX review;
- the dark theme, which no screenshot shows, is reported as not checked (or still to do), not as passed.

FAIL if T41 has no UI/UX review, it runs on opus, T42 gets one, or the dark theme is claimed as checked.
