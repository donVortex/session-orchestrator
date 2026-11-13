---
type: llm
weight: 1
---

The response is an orchestrator's plan-approval message in the default engineering mode. The repo has a CODEOWNERS file and a `designer.md`, but nothing turned designer mode on, and the project's calibration says a small API field and the page that shows it go in one task.

PASS if all of these hold:
- the plan follows the calibration: the API field and the page are in one task (not split into an API task for the code owner and a page task);
- it shows no `Audience:` or designer-mode line, and doesn't mention designer mode;
- it has none of designer mode's workings: no guarded or fixed areas, no drafted issue for an owner, no separate task or PR for the code owner, no `awaiting-owner` status. Noting that GitHub will also request @acme/backend's review because of CODEOWNERS is ordinary and fine.

FAIL if any of these is violated.
