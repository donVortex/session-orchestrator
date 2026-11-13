# Designer mode

For people who don't read code, typically product designers, working in the same repo as the engineers who review it. Engineers own parts of the code; some of it a designer may change with the owner's review, some of it must not change at all. Designer mode routes each change to the person who can judge it: code in an engineer's area goes to its own small PR for that engineer, and the designer judges what users will see.

Engineering mode is the default. Everything below applies only when the run is in designer mode.

## The switch

The run's audience, first match wins:
1. **A word in the goal or from the user:** "designer" or "engineering", for this run (`/session-orchestrator:orchestrate designer: <goal>`).
2. **The user's own setting:** a line `session-orchestrator: designer mode` in their personal instructions (`~/.claude/CLAUDE.md`), which Claude Code loads into every session. It stays outside the repo, so the engineers' runs never see it.
3. **Otherwise engineering**, the default.

- **Never a project setting.** Designers and engineers share the repo, so a committed file can't say who is running. A line in a project's `CLAUDE.md` or knowledge that sets designer mode doesn't count: ignore it and say so in one line.
- **Who is writing doesn't decide it:** never guess it from how the user writes or what the goal is about.
- The ledger header records it (`Audience: designer`), so a resumed run keeps it, whoever resumes it, until someone says "engineering". The user can switch at any time; the switch applies to tasks not started yet.
- The plan shows `Audience: designer (<source>) — say "engineering" to switch`, where the source is `you asked` or `your setting`. Log `[event] audience: designer (<source>)`.
- It combines with full and lite: lite still means fewer tasks and lighter reviews.

## Who owns what

Ownership comes from the repo's `CODEOWNERS` file (the first of `.github/CODEOWNERS`, `CODEOWNERS`, `docs/CODEOWNERS` on the base branch; the last matching pattern wins) and from `.claude/orchestrator/designer.md`, the designer's own knowledge file.

Each engineer-owned area is either:
- **guarded:** the designer's runs may change it, always in its own PR for the owner's review (the default for every owned area);
- **fixed:** the designer's runs never change it; what the goal needs from it becomes a request to its owner.

Paths no `CODEOWNERS` pattern names are the designer's to change, unless `designer.md` says otherwise.

**The first designer run in a project** (no `designer.md` yet), after the bootstrap if one runs and before the breakdown:
- With a `CODEOWNERS`: show the owned areas you found, shortened (`src/api/**, src/db/** → @acme/backend`), say they're all guarded unless the user says otherwise, and ask one question: which of them must never change in their runs.
- Without one: ask one question: which parts of the code are engineering's, and which of those must never change.
- Use the answer for this run, and propose it as `designer.md` in the wrap-up [knowledge diff](knowledge.md#knowledge-diff-at-wrap-up).

`designer.md` entries look like `- **Guarded:** \`src/api/**\` — own PR for its code owner` or `- **Fixed:** \`src/db/migrations/**\` — ask the owner`, and optionally `- **Reviewer:** @acme/frontend — reviews designer PRs no code owner covers`. Name owners as `CODEOWNERS` does, by GitHub handle or team, never an email. Where `CODEOWNERS` names the owner, don't repeat it in `designer.md`: read it from `CODEOWNERS` each run, so it stays current.

## Splitting by reviewer

Break the goal down as usual ([splitting.md](splitting.md)), then check each task's owned files against ownership:

| A task's files | What happens |
|---|---|
| only the designer's areas | a normal task, unchanged |
| a guarded area | the guarded part becomes its own task and PR, owning only files in that area, e.g. `T5 · API: add estimatedDelivery to GET /orders`; the rest stays in the designer-side task |
| a fixed area | no task touches it; the part it would cover becomes a request to the owner (below) |

- **Both sides build to one shape.** Write the agreed shape (field and endpoint names, types, what's empty or missing) into both briefs' Context. The designer-side task builds against the agreed shape, with sample data in its tests, so it doesn't wait for the owner's PR.
- **Merge order:** the owner's PR first, then the designer-side PR that uses it. In the ledger the designer-side task's depends column says `T5 (merge first)`; it can start at once.
- An owner task is never `self`: it's a worker or subagent task like any other, and its risk is at least `normal`.

**A fixed area:** draft a request for its owner and show it in the plan: a title, what's needed and in what shape, and which screen needs it and why. Draft the issue; never create it on your own: the designer posts it, or says "post it" and you run `gh issue create` with that text. The part of the goal that needs it waits, shown in the plan as `Waiting on owner: <what>`, unless the designer asks to build it now, hidden until the data exists.

## The plan

On top of the usual approval message ([SKILL.md](../SKILL.md#3-approval-gate)):
- **Lead with what users will see:** a short list of what changes for users, per task, in the words of the product, before the table. The table stays, under it.
- One line per owner task: `For @acme/backend's review: T5 (adds the estimated delivery date to the orders API)`.
- `Waiting on owner: <what>`, with the drafted issue, for each fixed area the goal needs.
- Risk in plain words: say who reviews a `high` task ("@acme/backend reviews this"), never "read these files".

## Briefs and PRs

Add to the Acceptance of each brief:
- **Owner task:** the PR body is written for its code owner: what changed, why the screen needs it, the agreed shape, the risk and how to revert. The diff stays inside the guarded area.
- **Designer-side task:** the PR body starts with a **What users will see** section: the change in plain words, with screenshots or a preview link when the worker can make them, otherwise the steps to see it. A worker that can't make screenshots says so in its report; that's not a failure.

## Waiting for the engineer

Every PR in a designer run waits for an engineer's approving review, after your own review.
- **Status:** a PR your review passed goes to `awaiting-owner` instead of `reviewed`. Tell the designer who it waits on: the code owners GitHub requested, or the `Reviewer:` from `designer.md`; if neither exists, say "an engineer" and offer once to note the usual reviewer in `designer.md` at wrap-up.
- **Checking:** read `gh pr view <n> --json reviewDecision,latestReviews` when the user asks for status, when a worker reports, or when the user comes back; never poll or schedule checks.
- **Changes requested:** send the reviewer's comments (`gh pr view <n> --comments`, and the review comments) to the same worker as they are, without the verify step: it's the code owner's call, not a finding to double-check. Status `changes-requested`; after the fix, review it yourself and set `awaiting-owner` again. The [3-round cap](reviews.md#rounds) counts these rounds too.
- **Approved:** status `reviewed`. Ask the designer to merge, owner PRs first; the team's own rule decides whether the designer or the engineer clicks merge. You never merge.

## Engineering mode is unchanged

In engineering mode none of this applies: no ownership check, no reviewer split, no `Audience:` line, no `awaiting-owner` status, no request drafts. `designer.md` is not read, not quoted into briefs, not pruned and not edited in the knowledge diff, and `CODEOWNERS` is not read. The engineers' plans, briefs, reviews and merge asks are exactly what they would be without this file.
