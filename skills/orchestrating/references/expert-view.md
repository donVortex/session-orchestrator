# Expert view

A look at the work through the eyes of the top professionals of the product's field (for a fitness app: a strength coach, a physiotherapist), written by a fresh `orch-specialist` in expert mode. It says what they would do that the user didn't ask for, the raw material they'd start from, the methods and tools they'd use, and what outside this session shows the result is right. The project's [product knowledge](knowledge.md#product-knowledge) names the professionals and their sources.

It goes deeper, not wider: one subagent call per view, no new step in the run.

## When it runs

**Automatically, at planning,** when the goal **touches the product's field**: it changes what users see or do, calculations or content the experts guard, or the data users hand over. Refactors, CI, dependencies and internal tooling don't. Decide this at intake, and run the view **before the breakdown is shown**, so its adopted items shape the plan.

The decision is always shown in the plan header, next to the Mode line:

- `Expert view: <experts> (<why>)` — e.g. `Expert view: strength coach, physio (goal changes workout plans)`
- `Expert view: skipped (<why>) — say "expert view" to run it`
- `Expert view: off in lite — say "expert view" to run it` (in [lite mode](model-tiers.md#lite-mode) it runs only on request)

## On request

The user asks in plain words at any point in a run: "expert view", "what would a coach say?", "physio's eye on T4". There is no command. A named professional runs only that view; otherwise the experts in the product knowledge that bear on the target.

| Target | It reads | Its checks (part 4) become |
|---|---|---|
| The plan, before or after approval | the goal, the breakdown, the product knowledge | acceptance criteria on the tasks |
| A task or PR (`T4`, `#52`) | the brief, the diff, the worker's report | checks in that PR's Verification; ones the session can't run are listed as `still to do` |
| A question ("is our progression safe for beginners?") | the code and data needed to answer | a list of checks to run or hand off |

**No product knowledge yet:** infer the fitting professional from the goal and say so in one line; afterwards, offer to start product knowledge with what was decided ([how](knowledge.md#product-knowledge)).

## Expert mode

- **A fresh `orch-specialist`, read-only.** It never edits files.
- **Model:** opus / medium; opus / high when the target is guarded work (security, authentication, money, deleting data, migrations) or health and safety.
- **One call covers up to 3 experts.** When more apply, it takes the 3 that bear most on the target and names the ones it skipped.
- **Input:** the target; `product.md`, `domain.md` and `map.md` (or the project's files serving those purposes); the decisions already made this run, adopted and declined. Never the orchestrator's own reasoning about the plan, so the view isn't anchored on it.

## Raw material and sources

- **The project's own material** (logs, exports, fixtures, research notes, support-ticket exports): read with read-only tools, from the Experts pointers in the product knowledge or what it finds in the repo. It works from aggregates ("38% of week-1 users stop by day 3") and never quotes records: no rows, names, identifiers or personal data.
- **Public primary sources** (guidelines, standards, papers): at most 5 web fetches per view. Search terms are general ("ACSM resistance training progression"), never code, data or the product's name.
- **Every source carries a mark:**
  - `opened` — read in this call; give the URL or path and the section;
  - `recalled` — known from training, not read now; give the name and year as remembered;
  - `unreachable` — tried, but paywalled or the fetch failed.
- Use only these three marks. Material the caller hands you (an aggregate it already read) is `opened (given by the caller)`. A project file you cite but didn't read, such as one named in the product knowledge, is `recalled`.
- A source is never marked `opened` unless it was read in this call. A recommendation that rests only on recalled sources ends with exactly `(recalled only)`, with nothing added inside the brackets.

## Output format

```markdown
## Expert view: <target> — <expert>, <expert>
### 1. What a top professional would do that wasn't asked
- E1. <recommendation> — <why> — rests on S1, S3 [(recalled only) when every source it rests on is recalled]
### 2. Raw material
- S1. <source> — opened (<url or path>, <section>) | recalled | unreachable — <what it gives>
### 3. Methods and tools
- <method or tool>, for E<n>
### 4. What shows it's right, besides us
- C1. <check> — <who or what runs it> — <when: in the run | after merge | after release>
```

## Rules

- **Before returning, check each recommendation** against its `rests on` list: if every source there is `recalled`, the line ends with `(recalled only)`. Fix any line that doesn't.
- **At most 5 recommendations**, the most important first. `Nothing to add` is a valid answer; never pad.
- **Nothing from Out of scope comes back** (the product knowledge's list of what was decided against), unless new raw material changes the reason; then say what changed.
- **Part 4 is checks outside the orchestrator's review and the user's approval:** a professional's sign-off, a user test, numbers from the logs, a published guideline met. Checks the session can run become acceptance criteria. Checks that need people or time go into the PR's Verification as `still to do: <check> — <who> — <when>` and into the wrap-up summary as open checks. They never block a merge; the user decides.

## Adopt and decline

Show the recommendations numbered; the user adopts or declines each.

- **Adopted, for work not started:** change the plan (a new task, or new acceptance criteria) and show it as a plan change before anything starts.
- **Adopted, for a task in progress:** send it to that task's worker as a follow-up, the same way as review findings. If it changes a project rule, log it as a `rule change` ([rule changes](knowledge.md#rule-changes)).
- **Declined:** record the user's reason. At wrap-up it goes into the product knowledge's Out of scope as `Decided not to: <thing>. <reason>.`
- **Ledger:** `[expert] <target> <experts>: <n> proposed, <k> adopted`, and for each decline `[expert] declined E<n>: <reason>`.

## If it fails

If the subagent errors or returns nothing usable, go on without it and show `Expert view: failed (<why>) — say "expert view" to retry` in place of the plan-header line. A failed view never blocks a run, and its checks never block a merge.

Workers never call the expert view. A worker that hits a question in the product's field asks it through its report, as with any other question.
