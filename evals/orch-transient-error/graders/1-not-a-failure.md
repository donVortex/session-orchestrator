---
type: llm
weight: 1
---

The response is an orchestrator's handling of a worker turn that died on a transient API error (a 403 challenge page), with two commits made and one file uncommitted.

PASS if all of these hold:
- it treats this as an environment problem, not a failed round: logged as `[env]` (not `[failed]`), with no effort raise or tier change;
- it resumes the same worker session (not a new one), once;
- the message to the worker says what is done (the two commits, or subtasks A and B), what is uncommitted (`src/pages/OrderHistory.css`), and what comes next (styles, then empty and error states).

FAIL if it counts a failure, raises the effort or tier, starts a new worker, or the message leaves out what's done, what's uncommitted or what's next.
