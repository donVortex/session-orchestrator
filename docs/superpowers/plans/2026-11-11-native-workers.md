# Native workers — Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Worker sessions do their task in their own context by default, delegate only in four named cases, run one fresh review of the whole diff, and report tokens, context and quality so workflow learning can back off where native is worse.

**Architecture:** The worker skill's steps 2–3 are rewritten around a plan table (`Piece | Files | How | Why`); the report gains a Work line; the orchestrator logs it and workflow learning counts it. Everything is markdown instructions, checked by bash string tests and `claude plugin eval` cases.

**Tech Stack:** Markdown skills, bash tests (`tests/lib.sh`, bash 3.2 compatible), `claude plugin eval` with a Sonnet judge.

**Spec:** `docs/superpowers/specs/2026-11-11-native-workers-design.md`

## Global Constraints

- Branch `feat/native-workers`; commit after each task; never push or merge without the user (main is protected).
- Version `0.8.0` in `.claude-plugin/plugin.json` and `tests/test_manifest.sh`.
- Commit messages end with `Co-Authored-By: Claude Opus 5.5 <noreply@anthropic.com>`.
- Plan table header, exactly: `| Piece | Files | How | Why |`. How values: `me`, `scout (haiku)`, `subagents, <n> batches`, `parallel`, `specialist (opus)`. Why values for the four cases: `read-only`, `too big for one context`, `independent, run in parallel`, `harder than the task's tier`.
- Work line, exactly: `- Work: native · subagents: <list or none> · review: <model> ×<n>, <k> round(s) · context at report: <p>% | n/a · compacted: yes | no`.
- Ledger line, exactly: `[event] T<n> work: native, <k> subagents, context <p>%, compacted <yes|no>` (CLI adds `, $<cost>`).
- Counts header, exactly: `| task | recipe | ask-user | approval | prompt | start-click | failed | changes | escalate | worker-q | findings | compacted |`.
- Comparison line, exactly: `Native vs before (per task): PR findings <a> → <b> · rework <a> → <b> · compacted <a> → <b> of <n> · subagents <a> → <b>`.
- Calibration entries, exactly: `Worker plan: per-piece reviews for <kind> in <area>` and `Worker plan: subagents for <kind> in <area>`.
- Whole-diff review model: sonnet for `low` and `normal` risk; opus for `high` risk.
- Retro tag `context` (used as `[context]`).
- The brief's `Subtasks` field keeps its name and format.
- Strings existing tests pin in `skills/working/SKILL.md` must survive the rewrite: `Mode: lite`, `one combined review`, `no nested reviewers`, `the approved brief is the confirmation`, `../orchestrating/references/reviews.md#verify-before-sending-work-back`, `references/reviews.md#rounds`, `give it one and retry on the same tier`, `wait for it in the same turn`, `follow the brief's tier hints`.
- Run tests with `bash tests/run.sh`; evals with `export PATH="/c/Users/Marko/.local/bin:$PATH"; claude plugin eval . --case <name> --judge-model sonnet --no-publish --trust-plugin -j 6`; delete `evals/results/` after reading.

## Review Focus

- A brief carrying a `Worker plan: per-piece reviews for …` hint for the piece's kind and area: the worker gives that piece per-piece reviews even though it writes it itself. Pinned in Task 1 (test).
- Lite mode with a `high`-risk task: the whole-diff review still runs on opus (guarded work keeps full treatment). Pinned in Task 1 (test) and Task 6 (`worker-native-high-risk` uses full mode; the test covers lite wording).
- A worker that delegates a piece with no reason, or a reason outside the four: listed as a common mistake. Pinned in Task 1 (test).
- Desktop context fill can't be read (the tool reports unavailable): the worker writes `n/a`, never an estimate. Pinned in Task 2 (test).
- First run in a project, no archived baseline: no comparison line and no `Worker plan:` proposal. Pinned in Task 3 (test) and Task 6 (`orch-native-counts` grader).

---

### Task 1: The native worker loop

**Files:**
- Modify: `skills/working/SKILL.md` (steps 2–3 at lines 19–52; common-mistakes rows at lines 78 and 83)
- Create: `tests/test_native_worker.sh`

**Interfaces:**
- Produces: worker skill headings `## 2. Plan the pieces`, `## 3. Do the work`, `## 4. Review the whole diff` (later steps renumber: Escalate 5, Verify 6, Open the PR 7, Report 8). Task 2 edits step 8 (Report). Before renaming, grep the repo for links to the old worker anchors (`#2-plan-in-batches`, `#3-run-each-batch`, `#4-escalate` … `#7-report`) and update them in this task.

- [ ] **Step 1: Write the failing test** `tests/test_native_worker.sh` (sources `lib.sh`, ends with `finish`):

```bash
w=$(cat skills/working/SKILL.md 2>/dev/null)
assert_contains "$w" "## 2. Plan the pieces" "worker: plan heading"
assert_contains "$w" "| Piece | Files | How | Why |" "worker: plan table"
assert_contains "$w" '`me` is the default' "worker: native by default"
for why in "read-only" "too big for one context" "independent, run in parallel" "harder than the task's tier"; do
  assert_contains "$w" "\`$why\`" "worker: delegation reason [$why]"
done
assert_contains "$w" "the full suite runs and the piece is committed" "worker: gate after each piece"
assert_contains "$w" "keep per-piece reviews" "worker: delegated pieces keep their reviews"
assert_contains "$w" "Worker plan:" "worker: follows Worker plan hints"
assert_contains "$w" "[context]" "worker: compaction noted"
assert_contains "$w" "hand the remaining pieces to subagents" "worker: compaction fallback"
assert_contains "$w" "## 4. Review the whole diff" "worker: whole-diff review heading"
assert_contains "$w" 'sonnet for `low` and `normal` risk, opus for `high` risk' "worker: review depth by risk"
assert_contains "$w" "opus for \`high\` risk, in lite too" "worker: lite keeps opus for high risk"
assert_contains "$w" "A subagent without one of the four reasons" "worker: mistake row for unexplained delegation"
assert_not_contains "$w" "**Small task**" "worker: small-task path retired"
assert_not_contains "$w" "Two or more subtasks always use the batch loop" "worker: batch loop no longer default"
for s in "Mode: lite" "one combined review" "no nested reviewers" "the approved brief is the confirmation" "../orchestrating/references/reviews.md#verify-before-sending-work-back" "references/reviews.md#rounds" "give it one and retry on the same tier" "wait for it in the same turn" "follow the brief's tier hints"; do
  assert_contains "$w" "$s" "worker: kept [$s]"
done
```

- [ ] **Step 2: Run** `bash tests/test_native_worker.sh`. Expected: FAIL, first line `FAIL: worker: plan heading`.

- [ ] **Step 3: Rewrite steps 2–3 of `skills/working/SKILL.md`** per spec §2:
  - `## 2. Plan the pieces`: the brief's `Subtasks` are the starting pieces; follow the brief's tier hints and `Worker plan:` hints; post the plan table; `me` is the default; the four delegation cases as a table (case → How → model) using the exact Why values; lite: no `deep` piece except guarded work.
  - `## 3. Do the work`: pieces marked `me` test-first, then "the full suite runs and the piece is committed"; delegated pieces run as today's batches (parallel calls in one message, `max_parallel_implementers_per_session`, model passed on every call, scoped test commands, "do not commit") and keep per-piece reviews (spec then quality; one combined review in lite), verification and the round cap, with the existing review-skill and no-nested-reviewers wording; a piece with a `Worker plan: per-piece reviews` hint gets per-piece reviews even when written by `me`; compaction fallback (`[context]` retro point, hand the remaining pieces to subagents). Keep the "Other skills and plugins" paragraph, replacing "your batch plan in step 2" with "your plan in step 2".
  - `## 4. Review the whole diff`: one fresh `orch-specialist` in review mode, sonnet for `low` and `normal` risk, opus for `high` risk, in lite too; review checklist and named review skill in the same pass; verify before fixing; round cap; run it in the foreground and wait for it in the same turn.
  - Renumber Escalate, Verify, Open the PR, Report to 5–8 and fix in-file references to step numbers ("step 5", "step 6", "step 1").
  - Common mistakes: row "Agent calls in separate messages" → "Parallel subagent calls in separate messages | One message per batch of delegated pieces"; replace the "It's tiny" row with "Skipping the whole-diff review | No path has zero reviews"; add row "A subagent without one of the four reasons | Write the piece yourself, or name the reason in the plan".

- [ ] **Step 4: Run** `bash tests/test_native_worker.sh && bash tests/run.sh`. Expected: both exit 0.

- [ ] **Step 5: Commit** `feat: native worker loop with one whole-diff review`.

### Task 2: The Work line, logged by the orchestrator

**Files:**
- Modify: `skills/working/report-format.md` (Result section lines 9–13; Subtasks paragraph line 30; Tags table)
- Modify: `skills/working/SKILL.md` (step 8 Report: read context fill)
- Modify: `skills/orchestrating/SKILL.md` (Track, line 86)
- Modify: `skills/orchestrating/references/ledger.md` (Events bullets)
- Modify: `tests/test_native_worker.sh`

- [ ] **Step 1: Append to `tests/test_native_worker.sh`:**

```bash
fmt=$(cat skills/working/report-format.md 2>/dev/null)
orch=$(cat skills/orchestrating/SKILL.md 2>/dev/null)
ledger=$(cat skills/orchestrating/references/ledger.md 2>/dev/null)
assert_contains "$fmt" "- Work: native · subagents:" "report: Work line"
assert_contains "$fmt" "context at report: <p>% | n/a" "report: context fill or n/a"
assert_contains "$fmt" '| `context` |' "report: context tag"
assert_contains "$fmt" "never an estimate" "report: unavailable context is n/a"
assert_contains "$w" "get_usage" "worker: reads its own context fill (desktop)"
assert_contains "$orch" "the Work line" "orchestrator reads the Work line"
assert_contains "$orch" "total_cost_usd" "orchestrator: CLI cost from the result JSON"
assert_contains "$ledger" "[event] T<n> work: native, <k> subagents, context <p>%, compacted <yes|no>" "ledger: work line"
```

- [ ] **Step 2: Run** `bash tests/test_native_worker.sh`. Expected: FAIL on `report: Work line`.

- [ ] **Step 3: Edit.**
  - `report-format.md`: add the Work line (exact form from Global Constraints) under `## Result`, after Review findings; explain: subagents listed as `<role> <model> ×<n>`, with the piece and reason for non-scout ones; context from the app on desktop, `n/a` on CLI or when the app reports it unavailable — never an estimate. Subtasks-table paragraph: "One row per piece a subagent did". Tags table row `| \`context\` | compaction mid-task, and what was handed off after it |`.
  - Worker step 8: before writing the report, desktop workers read their own context fill with `mcp__ccd_session_mgmt__get_usage` (`session_id: "self"`) when available.
  - Orchestrating SKILL.md Track: after reading a report, log the Work line as the ledger line; on the CLI backend, add the cost from the worker's result JSON (`total_cost_usd`).
  - `ledger.md` Events: one bullet with the exact ledger line.

- [ ] **Step 4: Run** `bash tests/run.sh`. Expected: exit 0.

- [ ] **Step 5: Commit** `feat: workers report work, context and cost; the orchestrator logs it`.

### Task 3: Counting, comparing and backing off

**Files:**
- Modify: `skills/orchestrating/references/workflow-learning.md` (Counts table lines 39–52; Findings to proposals; Using what was learned)
- Modify: `skills/orchestrating/references/knowledge-templates/calibration.md`
- Modify: `skills/orchestrating/SKILL.md` (Wrap up step 2)
- Modify: `skills/orchestrating/references/brief-template.md` (Subtasks field hint line)
- Modify: `tests/test_workflow_learning.sh:12`, `tests/test_native_worker.sh`

- [ ] **Step 1: Tests.** In `tests/test_workflow_learning.sh` line 12, change the expected header to the exact Counts header from Global Constraints. Append to `tests/test_native_worker.sh`:

```bash
wl=$(cat skills/orchestrating/references/workflow-learning.md 2>/dev/null)
cal=$(cat skills/orchestrating/references/knowledge-templates/calibration.md 2>/dev/null)
brief=$(cat skills/orchestrating/references/brief-template.md 2>/dev/null)
assert_contains "$wl" "Native vs before (per task): PR findings <a> → <b>" "learning: comparison line"
assert_contains "$wl" "no comparison line and no \`Worker plan:\` proposal" "learning: nothing without a baseline"
assert_contains "$wl" "Worker plan: per-piece reviews for <kind> in <area>" "learning: back off to per-piece reviews"
assert_contains "$wl" "Worker plan: subagents for <kind> in <area>" "learning: back off to subagents"
assert_contains "$cal" "Worker plan:" "calibration template: Worker plan example"
assert_contains "$brief" "Worker plan:" "brief carries Worker plan hints"
assert_contains "$orch" "comparison line" "wrap-up shows the comparison"
```

- [ ] **Step 2: Run** `bash tests/test_workflow_learning.sh; bash tests/test_native_worker.sh`. Expected: FAIL on `counts table header` and `learning: comparison line`.

- [ ] **Step 3: Edit.**
  - `workflow-learning.md`: new header and example rows with `findings` (critical + important in the orchestrator's PR review) and `compacted` (1 if the worker hit compaction); "not recorded" for tasks with no Work line; a `### Native vs before` subsection: baseline = the project's archived runs from before native workers; the exact comparison line; with no baseline, no comparison line and no `Worker plan:` proposal; two findings-to-proposals rows using the exact `Worker plan:` entries and the two-run rule; "Using what was learned": briefs carry matching `Worker plan:` entries as hints.
  - `calibration.md` template: a commented example `- **Worker plan: per-piece reviews for state machine changes in src/billing/.** _(T12, T19)_`.
  - Wrap-up step 2: show the comparison line after the counts.
  - `brief-template.md` Subtasks line: add "plus any `Worker plan:` entries for these kinds and areas".

- [ ] **Step 4: Run** `bash tests/run.sh`. Expected: exit 0.

- [ ] **Step 5: Commit** `feat: count findings and compaction, compare with before, learn where to back off`.

### Task 4: Lite, tiers, briefs, reviews and recipes follow

**Files:**
- Modify: `skills/orchestrating/references/model-tiers.md:39-40,73`
- Modify: `skills/orchestrating/references/brief-template.md:49`, `splitting.md` (any small-task wording)
- Modify: `skills/orchestrating/references/reviews.md:3`, `coexistence.md:57`
- Modify: `skills/orchestrating/references/knowledge-templates/calibration.md:28`, `workflow-learning.md:59` (recipe examples)
- Modify: `skills/orchestrating/SKILL.md:82` (`self` tasks: "the working skill's small-task path" wording)
- Modify: `tests/test_native_worker.sh`

- [ ] **Step 1: Append:**

```bash
tiers=$(cat skills/orchestrating/references/model-tiers.md 2>/dev/null)
for f in skills/orchestrating/SKILL.md skills/orchestrating/references/*.md skills/orchestrating/references/knowledge-templates/*.md skills/working/*.md; do
  assert_not_contains "$(cat "$f")" "small-task path" "no small-task path left in $f"
done
assert_contains "$tiers" "| Worker plan | native: the worker writes the pieces itself, subagents only for the four cases | the same |" "lite row: worker plan"
assert_contains "$tiers" "| Worker reviews | one whole-diff review; per-piece reviews for delegated pieces |" "lite row: reviews"
assert_contains "$tiers" "delegated pieces" "cap covers delegated pieces"
assert_contains "$(cat skills/orchestrating/references/reviews.md)" "the worker's whole-diff review" "reviews: names the worker review"
```

- [ ] **Step 2: Run** `bash tests/test_native_worker.sh`. Expected: FAIL on `no small-task path left in …` lines.

- [ ] **Step 3: Edit** each listed line: lite table rows exactly as asserted (the lite cell of "Worker reviews" says "one combined review per delegated piece"); the parallelism cap sentence says implementer subagents for delegated pieces; brief-template line 49 and SKILL.md line 82 say "the working skill's loop" / "native"; reviews.md line 3 lists "the worker's whole-diff review, per-piece reviews of delegated pieces, and the orchestrator's PR review"; coexistence.md line 57 says "(for delegated pieces; the working skill's plan and model rules win)"; the two recipe examples say "native" instead of "small-task path".

- [ ] **Step 4: Run** `bash tests/run.sh`. Expected: exit 0.

- [ ] **Step 5: Commit** `refactor: lite, tiers, briefs and reviews follow native workers`.

### Task 5: README and v0.8.0

**Files:**
- Modify: `README.md` (Modes table "Reviews" row; a `### How workers work` subsection after the Modes section)
- Modify: `.claude-plugin/plugin.json`, `tests/test_manifest.sh:15`, `tests/test_readme.sh`

- [ ] **Step 1: Tests.** Manifest: `'"version": "0.8.0"'`, label `plugin version 0.8.0`. Append to `test_readme.sh`:

```bash
assert_contains "$readme" "### How workers work" "README: workers section"
assert_contains "$readme" "one review of the whole change" "README: whole-diff review"
assert_not_contains "$readme" "spec review + quality review per subtask" "README: old review row gone"
```

- [ ] **Step 2: Run** `bash tests/test_manifest.sh; bash tests/test_readme.sh`. Expected: FAIL on version and workers section.

- [ ] **Step 3: Edit.** Modes table Reviews row → `| Reviews | one review of the whole change per task, specialist review of \`deep\` PRs | the same, on sonnet except high-risk work |`. `### How workers work`, end-user voice: a worker does its task in its own session, test-first, full test suite after each piece; subagents only for wide searches, pieces too big for one session, independent pieces worth running at once, or one piece harder than the rest; one fresh review of the whole change before the PR (Opus for high-risk work); each report says how much it delegated, how full its context got and whether it was compacted, and the wrap-up compares this with the project's earlier runs and proposes going back to per-piece reviews or subagents in an area only after two worse runs.

- [ ] **Step 4: Run** `bash tests/run.sh`. Expected: exit 0.

- [ ] **Step 5: Commit** `feat: README for native workers; v0.8.0`.

### Task 6: Evals

**Files:**
- Create: `evals/worker-native-plan/`, `evals/worker-native-delegate/`, `evals/worker-native-compaction/`, `evals/worker-native-high-risk/`, `evals/orch-native-counts/` (format of `evals/worker-older-brief/`)
- Delete: `evals/worker-batches/`, `evals/worker-small-task/`

Worker prompts start "You are a worker session started by session-orchestrator. Load the session-orchestrator:working skill and follow it.", give a full brief in the current template, and end "This is a planning check … post your plan, including how the work will be reviewed, then stop before writing code or dispatching anything." (`max_turns: 8`, `allowed_tools: [Read, Glob, Grep, Skill]`).

| Case | Brief | Graders |
|---|---|---|
| `worker-native-plan` | The T7 settings brief from `evals/worker-batches/prompt.md` (4 subtasks), plus "find every place `getSetting(` is called" | 1: pieces A–D are `me`; 2: the call-site search is a haiku scout; 3: one review of the whole diff before the PR (no per-piece reviews for `me` pieces); 4: no subagent without one of the four reasons |
| `worker-native-delegate` | Subtask "move 40 report templates in `reports/**` from the old placeholder syntax to the new one" plus one small piece | 1: the 40-file piece goes to implementer subagents with "too big for one context"; 2: the small piece is `me`; 3: the delegated piece keeps per-piece reviews |
| `worker-native-compaction` | Mid-task: "Your context was just compacted. Pieces A and B are committed; C and D remain." | 1: notes a `[context]` retro point; 2: hands C and D to subagents |
| `worker-native-high-risk` | `Risk: high — session token handling` change in `src/auth/**` | 1: the whole-diff review runs on opus; 2: pieces are `me` unless a reason applies |
| `orch-native-counts` | Wrap-up of a run with 6 tasks whose reports carry Work lines; the archive has two earlier runs from before native workers with their counts; two tasks in `src/billing/` (state machine changes) had 2 important PR findings each, in this run and in the previous native run | 1: shows the comparison line; 2: proposes `Worker plan: per-piece reviews for state machine changes in src/billing/` (two runs); 3: proposes nothing for areas with one bad run |

- [ ] **Step 1: Write the cases** with a scratchpad Python script (UTF-8, `newline=""`), and `git rm -r evals/worker-batches evals/worker-small-task`.
- [ ] **Step 2: Run** `claude plugin eval . --tag native-workers …` (tag every new case `native-workers`). Expected: every grader passes with the plugin. A failing grader: read the evidence in `aggregate-result.json`; a rule gap gets a failing assertion first, then the fix; a grader mismatch gets a ledgered ruling.
- [ ] **Step 3: Regressions:** `worker-report`, `worker-older-brief`, `orch-lite-plan`. Expected: pass.
- [ ] **Step 4:** `rm -rf evals/results`; `bash tests/run.sh` exit 0.
- [ ] **Step 5: Commit** `test: evals for native workers`.
