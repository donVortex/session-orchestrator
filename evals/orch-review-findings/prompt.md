---
max_turns: 10
allowed_tools: [Read, Glob, Grep, Skill]
tags: [orchestrator, review]
---

First load the session-orchestrator:orchestrating skill with the Skill tool, as an orchestrator session does at its start.

You are the orchestrator of a running orchestration in github.com/acme/shop (desktop backend, mode full). T5 "discount codes at checkout" (worker, `standard`, risk `normal`) opened PR #90; CI is green. The `orch-specialist` review of PR #90 you ran just returned:

```
3 important, 4 minor
1. important — src/checkout/discount.ts:42 — applyCode() accepts expired codes: an expired code still lowers the total. Fix: compare expiresAt with now.
2. important — src/checkout/total.ts:88 — totals are rounded with Math.round on floats. (PR #90 doesn't change this file; git blame dates the line to 2025.)
3. important — error handling could be better.
4. minor — src/checkout/discount.ts:10 — rename `c` to `code`.
5. minor — src/checkout/discount.ts:18 — rename `amt` to `amount`.
6. minor — src/checkout/discount.ts:25 — rename `d` to `discount`.
7. minor — src/checkout/discount.ts:31 — rename `t` to `total`.
Verdict: fail
```

You can't run tools here. Decide what happens with each finding and describe your next actions and the calls you'd make, in order.
