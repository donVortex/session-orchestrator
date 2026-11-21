---
type: llm
weight: 1
---

The response is a UI/UX review of a page whose look matches an approved mockup (dense table, 13 px text). No dark-theme screenshot was provided.

PASS if all of these hold:
- it does not report the approved look itself as a problem (e.g. it doesn't ask for larger text, more spacing or a less dense table than the mockup);
- it says the dark theme was not checked (or is still to do), rather than passing it.

FAIL if it raises a finding against the approved density or text size, or treats the dark theme as checked.
