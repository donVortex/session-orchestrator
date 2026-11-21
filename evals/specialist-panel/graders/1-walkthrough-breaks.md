---
type: llm
weight: 1
---

The response is a synthetic user panel's answer about a "bills by email" plan, with two personas: a landlord with three flats and a retired couple whose bills mostly come on paper.

PASS if all of these hold:
- it walks through the feature as each persona and reports where they would get stuck, misunderstand or give up (for example: the landlord can't tell which flat a forwarded bill belongs to; the couple's paper bills aren't covered; the address shown only once is easy to lose), rather than saying whether they like it;
- each item names the persona it comes from;
- it doesn't recommend camera scanning of paper bills, which is out of scope (mentioning that it's out of scope, or that paper bills stay uncovered, is fine).

FAIL if it mostly praises the plan or rates how much they'd like it, items don't say which persona they come from, or it recommends adding camera scanning.
