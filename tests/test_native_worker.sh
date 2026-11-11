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

finish
