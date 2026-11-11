#!/usr/bin/env bash
# Native workers (v0.8.0): the worker writes its pieces itself, delegates only in four cases,
# runs one whole-diff review, reports work/context/cost, and learning backs off where it's worse.
. "$(dirname "$0")/lib.sh"

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

tiers=$(cat skills/orchestrating/references/model-tiers.md 2>/dev/null)
for f in skills/orchestrating/SKILL.md skills/orchestrating/references/*.md skills/orchestrating/references/knowledge-templates/*.md skills/working/*.md; do
  assert_not_contains "$(cat "$f")" "small-task path" "no small-task path left in $f"
done
assert_contains "$tiers" "| Worker plan | native: the worker writes the pieces itself, subagents only for the four cases | the same |" "lite row: worker plan"
assert_contains "$tiers" "| Worker reviews | one whole-diff review; per-piece reviews for delegated pieces |" "lite row: reviews"
assert_contains "$tiers" "delegated pieces" "cap covers delegated pieces"
assert_contains "$(cat skills/orchestrating/references/reviews.md)" "the worker's whole-diff review" "reviews: names the worker review"

finish
