---
max_turns: 8
allowed_tools: [Read, Glob, Grep, Skill]
tags: [orchestrator, knowledge, pruning]
---

First load the session-orchestrator:orchestrating skill with the Skill tool, as an orchestrator session does at its start.

You are in github.com/acme/shop (standalone install). The one task of this orchestration is merged (T11 → PR #90, "show order totals on the receipt page"), so it's time for the wrap-up.

- No knowledge PR is open. The knowledge files on `main`:
  - `map.md` (40 of 100 lines), among its entries:
    - "**`src/api/`** — HTTP routes, one file per resource. _(bootstrap, 2026-08-01)_"
  - `domain.md` (55 of 150 lines), among its entries:
    - "**Prices are integer cents**: the tax service rounds floats. _(bootstrap, 2026-08-01)_"
    - "**Card numbers never reach our servers.** Checkout posts them straight to the provider's iframe in `src/checkout/card-frame.tsx`. _(bootstrap, 2026-08-01)_"
    - "**Gift card codes are case-insensitive**; store them upper-cased. _(T4 / PR #51, 2026-09-12)_"
- The two archived orchestrations before this one each logged a `knowledge used:` line, and neither names the `src/api/` map entry, the card-number rule or the gift-card rule. No task in those runs or this one touched checkout or gift cards.
- This run: T11's brief quoted the integer-cents rule; T11 added a route in `src/api/receipts.ts`.
- `retros.md`:

```markdown
## T11 (worker, standard)
### Went well
- [brief] The integer-cents rule saved a rounding bug on the receipt total.
### Improve
- [domain] Routes live in `src/api/`, one file per resource.
- [domain] Order totals are recomputed on the server at checkout; the total the client sends is for display only and is never charged.
```

The knowledge files are not available here, so describe the knowledge diff instead of making it. Do the wrap-up.
