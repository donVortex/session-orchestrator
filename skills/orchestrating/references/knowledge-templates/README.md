# Orchestrator knowledge

What the session-orchestrator plugin has learned about this project. It reads this folder at the start of every orchestration and uses it to plan, brief workers and review their work.

| File | Holds |
|---|---|
| `domain.md` | Business and regulatory rules; terms that mean something specific here |
| `map.md` | Where things live; how a typical feature flows through the code |
| `review-checklist.md` | What every review must check; extra checks per area |
| `product.md` | Who the users are, what they need, what's out of scope, and whose professional eye matters, with their sources |
| `calibration.md` | Which work needs which model tier; typical task sizes; what briefs must spell out; proven recipes, learned defaults (applied automatically and listed in every plan as "Assumed from project knowledge") and pre-flight checks |

## How it grows

At the end of each orchestration, the orchestrator proposes additions, edits and removals here, each with where it came from. After you approve them, it opens a pull request for the team to review, like any code change. Each file has a line budget (first line), so old entries get merged or retired instead of piling up. Each run also records which entries it used; entries that go unused, or only repeat what the code shows, are proposed for removal.

## Editing by hand

Welcome. What's on the base branch is what the orchestrator uses, so hand edits always win.

## Rules

- **Never put secrets, credentials, records, personal data or record identifiers here** (patient, customer, account or claim numbers). Entries describe rules and structure, never real data; code names such as `redact()` or `src/phi/` are fine.
- **Write only what Claude would otherwise get wrong**: rules the code doesn't show, gotchas, local terms, decisions. Not what the folder structure or file names already say. Give each rule its reason in a few words.
- **Don't copy `CLAUDE.md`.** Link to it instead.
- **If sources disagree:** a task's brief wins for that task, then `CLAUDE.md`, then these files.
