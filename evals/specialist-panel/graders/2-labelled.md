---
type: llm
weight: 1
---

The response is a synthetic user panel's answer. One persona's source is only "your understanding"; the other rests on a client conversation and usage data.

PASS if both hold:
- it says the answer is synthetic (e.g. a header like "Panel: … — synthetic, from …");
- an item that rests only on the landlord persona (source: your understanding) is marked as such, e.g. "(your understanding only)".

FAIL if it doesn't say it's synthetic, or presents the landlord-only items without marking that they rest on the user's understanding only.
