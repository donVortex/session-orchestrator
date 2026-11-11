<!-- budget: 120 lines -->
# Calibration

How work in this project should be done: tiers, task sizes, what briefs must spell out, and the workflows that have proven themselves.

## Tiers by task type

<!-- Example:
- **Anything in `src/billing/` is `deep`**: rounding and currency rules failed twice on `standard`. _(T4 / PR #51, 2026-11-12)_
- **Tier: exercise-data mapping in `scripts/` is `standard`**: passed on the first try with only minor findings on `deep` in two runs. _(T3 / PR #15; T5 / PR #18)_
- **Worker plan: per-piece reviews for state machine changes in `src/billing/`**: the whole-diff review missed transition bugs in two runs. _(T12 / PR #60; T19 / PR #71)_
-->

## Split patterns

<!-- Example:
- **UI and API for one feature split cleanly** once the API contract is fixed in the brief. _(T3 / PR #47, 2026-11-11)_
-->

## Briefs need

<!-- Details workers here keep asking for. Example:
- **The exact error response shape** for every endpoint the task touches. _(T2 / PR #42, 2026-11-10)_
-->

## Recipes

<!-- A proven way to do one kind of task here, with its track record. Example:
- **Money helper** (`src/money/<fn>.js`): one worker, `standard`, native; brief quotes the number-argument and display rules, names `format.js` as style reference, folds the barrel line in. Last 2 runs: 0 attention, 0 rework. _(T1 / PR #10; T4 / PR #12)_
-->

## Learned defaults

<!-- Answers the orchestrator no longer asks; listed under "Assumed from project knowledge" in each plan. Never money, data-handling or safety rules. Example:
- **Export new helpers from the area's `index.js`** unless told otherwise. _(T1 / PR #20; T2 / PR #24)_
-->

## Skills

<!-- Which skills help this project, which steps of other plugins to skip, and how overlapping workflow skills are handled. Example:
- **Use stripe-best-practices for payment endpoints**; it caught a missing idempotency key. _(T2 / PR #31)_
-->

## Mode

<!-- Lite or full by default (see the plugin's lite mode). Example:
- **Mode: lite** — small codebase, changes are low-risk; the user chose lite in two runs. _(T3 / PR #20; T6 / PR #27)_
-->

## Pre-flight

<!-- Checked at intake, before planning. Example:
- **Ask for `/add-dir <repo>-wt` before the first `self` task**; every run without it stalled on prompts. _(T3 / PR #21)_
-->
