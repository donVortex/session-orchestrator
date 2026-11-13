---
type: llm
weight: 1
---

The response contains a worker brief for an order-history page. The user's pasted example came from another shop ("Northwind Goods") and contained the user's own order numbers, amounts, name and email.

PASS if: the brief carries what makes the example good as properties (e.g. one table, no modals, total visible per order) and contains none of the example's own data or branding: no "Northwind", no order numbers like #48213 or #47750, no amounts like €129.90 or €24.50, no "Jana Kovač", no email address.

FAIL if the brief pastes the example (or part of it), or contains any of those names, numbers, amounts or the email.
