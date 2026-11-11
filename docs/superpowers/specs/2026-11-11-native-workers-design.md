# Native workers — Design

Date: 2026-11-11
Status: approved, not implemented (target v0.8.0)
Builds on: [plugin](2026-11-03-orchestrator-plugin-design.md) · [workflow learning](2026-11-03-workflow-learning-design.md) · reviews v2 (v0.6.0, [reviews.md](../../../skills/orchestrating/references/reviews.md))
Source: [Solving code review at Anthropic](https://claude.dev/blog/solving-code-review-at-anthropic/)

## 1. Intent

Today a worker session splits a multi-piece task into subtasks and runs the **batch loop**: an implementer subagent per subtask, then two review subagents per subtask (spec, then quality), plus verifiers. Only a one-subtask task takes the **small-task path**, where the worker writes the code itself and runs one review.

The orchestrator already gives each worker what the inner layer is meant to buy: a fresh context, a PR-sized task, a model and effort matched to the tier, and a review of the whole PR. The inner layer repeats that at smaller scale and pays for it again: every subagent re-reads the code, details thin out over two handoffs, and reviews stack up.

**Native workers:** a worker does its task in its own context by default, with subagents only where they pay, and one fresh review of the whole diff before the PR.

**Success is measured on three things, not tokens alone:**
- **Tokens:** subagent calls per task by model (both backends); cost and tokens per worker (CLI only — the desktop app reports context fill, not cumulative spend).
- **Context:** whether a worker's context was compacted mid-task, and its fill at report time.
- **Quality:** `critical`/`important` findings in the orchestrator's PR review, review rounds, red CI, failed rounds, bugs reaching the base branch. Native must not be worse.

### Decisions made with the user

| Topic | Decision |
|---|---|
| Evidence | **Build it as the default and measure from real use** — not a separate experiment first, not an opt-in option. |
| Worker review | **Tests after every piece, then one fresh review of the whole diff** before the PR — in line with the article: the author runs tests/build/lint and shows output, then "a second agent reviews the diff in a fresh context"; depth matched to risk; many passes cause noise and rounds that don't converge. |
| Who decides delegation | **The worker, at planning**, with a reason per delegated piece. |

### Non-goals

- No change to the orchestrator's PR review, verification, rounds or risk tags.
- No change to how the orchestrator splits work into tasks or places them.
- Nothing measured leaves the project.

## 2. The native worker loop

### Plan

After reading the brief, the worker posts its plan:

```markdown
| Piece | Files | How | Why |
|---|---|---|---|
| A. schema change | src/db/… | me | |
| B. API handler | src/api/… | me | |
| C. find every caller of oldName | — | scout (haiku) | read-only |
| D. migrate 40 report files | reports/** | subagents, 2 batches | too big for one context |
```

- The brief's `Subtasks` field (unchanged name and format) is the worker's starting list of pieces, with tier hints.
- **`me` is the default.** Every other value of How carries one of the four reasons below; a read-only scout needs none.

### Writing a piece

Test-first as today: the new test fails for the right reason before any implementation, then minimal code, then green. After each piece, the full suite runs and the piece is committed. Not green → fix before the next piece.

### Delegation — only these four cases

| Case | How | Model |
|---|---|---|
| Broad read-only search, lookups, summaries | `orch-scout` | haiku |
| A piece too big for one context (many files, bulk edits, long migrations) | `orch-implementer` subagents in batches | per tier, never haiku |
| Independent pieces worth running at the same time | parallel `orch-implementer` calls, in one message | per tier |
| One piece harder than the task's tier | `orch-specialist` in build mode | opus |

- Parallel calls go in one message, as today; `max_parallel_implementers_per_session` caps them.
- **Delegated pieces keep today's per-piece review** (spec and quality; one combined pass in lite), so delegation never lowers the bar.
- **Compaction fallback:** if the worker's context is compacted mid-task, it notes a `[context]` retro point and hands the remaining non-trivial pieces to subagents.

### The whole-diff review

Before the PR, one fresh `orch-specialist` in review mode reviews **the whole diff** against the brief: spec compliance, code quality, and the brief's review checklist (and a named review skill, in the same pass, as today).
- **Model:** sonnet for `low` and `normal` risk; opus for `high` risk.
- Findings follow [reviews.md](../../../skills/orchestrating/references/reviews.md): verify `critical`/`important` findings before fixing, cap of 3 rounds, `minor` and `pre-existing` become follow-ups.
- Run in the foreground and wait for it in the same turn (as today).

Then verify, PR, report — unchanged.

### Retired

- The batch loop as the default for two or more subtasks (it remains as the way delegated pieces run).
- The two reviews per subtask for pieces the worker writes itself.
- The separate small-task path: native covers it. Lite's "small-task path whenever it fits" becomes native in both modes.

## 3. Measuring it

### Per task

The report gets a **Work** line:

```
- Work: native · subagents: scout haiku ×2, implementer sonnet ×3 (D: too big) ·
  review: sonnet ×1, 1 round · context at report: 58% · compacted: no
```

- Desktop: the worker reads its own context fill when it writes the report. CLI: `context at report: n/a`; the orchestrator adds cost and tokens from that worker's result JSON (`cli-worker.sh` already returns it).
- Ledger: `[event] T<n> work: native, <k> subagents, context <p>%, compacted <yes|no>` (plus `, $<cost>` on CLI).
- An older worker's report has no Work line: counted as "not recorded".

### Per run

The counts table gains two columns: **findings** (`critical` + `important` in the orchestrator's PR review) and **compacted** (1 if the worker hit compaction).

When the project has archived runs from before native workers, the wrap-up shows one comparison line, per task:

`Native vs before (per task): PR findings 0.4 → 0.6 · rework 0.8 → 0.5 · compacted 0 → 1 of 6 · subagents 7.2 → 2.1`

### Backing off where native is worse

Workflow learning's two-run rule:
- More PR findings or rework for the same kind of work in the same area, in two runs → propose `Worker plan: per-piece reviews for <kind> in <area>`.
- Compaction for the same kind of work in the same area, twice → propose `Worker plan: subagents for <kind> in <area>`.

Entries go into the project's calibration through the knowledge diff, like `Tier:` entries, and briefs carry them as hints the worker follows.

## 4. Compatibility

- Brief format unchanged (`Subtasks` keeps its name), so older and newer orchestrators and workers keep understanding each other during a mid-run update.
- An older worker given a newer brief runs the batch loop; its report lacks the Work line.
- Workers already running finish on their own version.

## 5. Changes

| File | Change |
|---|---|
| `skills/working/SKILL.md` | Steps 2–3 rewritten: plan table, native loop, delegation cases, compaction fallback, whole-diff review; small-task path and default batch loop retired; common-mistakes table updated |
| `skills/working/report-format.md` | Work line |
| `skills/orchestrating/SKILL.md` | Track: Work line → ledger, CLI cost; wrap-up: comparison line |
| `skills/orchestrating/references/workflow-learning.md` | `findings` and `compacted` columns; comparison; `Worker plan:` entries and their two-run rule |
| `skills/orchestrating/references/model-tiers.md` | Lite table rows for worker plan and reviews; parallelism cap covers delegated pieces |
| `skills/orchestrating/references/brief-template.md`, `splitting.md` | Drop the small-task-path wording; `Worker plan:` hints |
| `skills/orchestrating/references/reviews.md`, `coexistence.md` | The worker's whole-diff review; batch-plan wording |
| `skills/orchestrating/references/knowledge-templates/calibration.md` | Example `Worker plan:` entry |
| `README.md` | Modes table Reviews row; short "How workers work" note |
| `.claude-plugin/plugin.json`, `tests/test_manifest.sh` | v0.8.0 |

## 6. Testing

**Unit:** `tests/test_native_worker.sh` for the new rules; existing tests that assert batch-loop or small-task wording are updated (each watched failing first).

**Evals** (with and without the plugin):

| Case | Checks |
|---|---|
| `worker-native-plan` | 3-piece task: worker writes the pieces itself, scout for the search, one whole-diff review, no subagent without a reason |
| `worker-native-delegate` | A 40-file migration piece goes to subagents with "too big" as the reason |
| `worker-native-compaction` | After compaction: remaining pieces to subagents, `[context]` noted |
| `worker-native-high-risk` | Auth change: the whole-diff review runs on opus |
| `orch-native-counts` | Wrap-up with a baseline: comparison line; `Worker plan:` proposed only after two bad runs |

`worker-batches` and `worker-small-task` are replaced. Regressions: `worker-report`, `worker-older-brief`, `orch-lite-plan`.
