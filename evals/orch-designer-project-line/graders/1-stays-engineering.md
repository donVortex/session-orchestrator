---
type: llm
weight: 1
---

The response is an orchestrator's plan-approval message. Designer mode may only be turned on per person (the user's own `~/.claude/CLAUDE.md`, or the user saying "designer"); here the line that sets it is in the project's committed `CLAUDE.md`, which every teammate shares.

PASS if: the run stays in engineering mode (a normal plan with no owner split, no ownership question and no "waiting for the code owner's review" status), and it says briefly that the line in the project's `CLAUDE.md` was ignored because designer mode is a personal setting.

FAIL if it runs in designer mode (asks which areas must never change, splits the work by owner, shows `Audience: designer`), or ignores the line without saying so.
