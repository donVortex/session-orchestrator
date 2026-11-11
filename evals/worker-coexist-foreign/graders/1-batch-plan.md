---
type: llm
weight: 1
---

The response is a worker's plan for a brief with two small independent subtasks (slugify, truncate), in a session where another workflow plugin is also installed.

PASS if: it posts the working skill's plan table (pieces with files, How and Why): the worker writes both small pieces itself (or gives one of the allowed reasons for any delegated piece), and plans one review of the whole diff before the PR.

FAIL if it follows the other plugin's own planning or review flow instead, delegates a piece without a reason, or plans no review before the PR.
