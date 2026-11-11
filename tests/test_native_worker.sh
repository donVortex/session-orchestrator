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
assert_contains "$w" "non-trivial pieces to subagents" "worker: compaction fallback"
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

assert_contains "$wl" "the area's own tasks of that kind from before native workers" "learning: what 'more than the baseline' means"
assert_contains "$wl" "comes before a brief rule or checklist item for the same findings" "learning: Worker plan proposal takes precedence"

# final review fixes
assert_contains "$w" 'A piece whose tier hint is `deep` in a task that isn'"'"'t goes to `specialist (opus)`' "R1: learned deep tiers still apply"
assert_contains "$fmt" "One row per piece, yours included" "R1: tier learning keeps a row per piece"
assert_contains "$w" "A piece you wrote that stays red, or still has a confirmed finding after 3 rounds, goes once to the next tier up" "R2: escalation for your own pieces"
assert_contains "$wl" "show no comparison line" "R3: no comparison without a baseline"
assert_contains "$wl" 'The `Worker plan:` proposals need no baseline from before: two runs with native workers are enough' "R3: back-off works for new projects"
assert_not_contains "$wl" "and no \`Worker plan:\` proposal" "R3: old gate removed"
assert_contains "$wl" 'PR findings come from the ledgers'"'"' `findings:` lines' "R4: source of findings"
assert_contains "$wl" 'compacted before is always `n/a`' "R4: compaction wasn't measured before"
assert_contains "$wl" "subagents counts the delegated pieces" "R4: one definition of subagents"
assert_not_contains "$wl" "never leave them out" "R4: no estimated before-values"
assert_contains "$wl" 'its `findings` still count' "R4: old workers keep their findings"
assert_not_contains "$(cat evals/worker-superpowers/graders/1-batch-plan.md)" "same batch" "R5: superpowers eval expects the native plan"
assert_not_contains "$(cat evals/worker-coexist-foreign/graders/1-batch-plan.md)" "same batch" "R5: foreign-plugin eval expects the native plan"
assert_contains "$w" 'counts as `too big for one context`' "R6: Worker plan subagents hint is an allowed reason"
assert_contains "$w" "If the whole-diff review still has a confirmed" "R7: whole-diff round cap"
assert_contains "$(cat skills/orchestrating/references/reviews.md)" "**worker, for its whole-diff review:**" "R7: reviews.md covers the whole-diff review"
assert_not_contains "$(cat README.md)" "Workers build with subagents whose model is picked by effort" "R8: README tagline"
assert_not_contains "$(cat .claude-plugin/plugin.json)" "tiered parallel subagents" "R8: plugin description"
assert_not_contains "$(cat .claude-plugin/marketplace.json)" "tiered, parallel subagents" "R8: marketplace description"
assert_not_contains "$(cat docs/e2e-checklist.md)" "batch plan" "R8: e2e checklist"

assert_contains "$orch" "logged as \`[escalate] T<n> effort <from> → <to>\`" "failed round: effort escalation is logged"

assert_contains "$orch" "propose its \`Worker plan:\` entry first" "wrap-up: Worker plan proposal first"
assert_contains "$wl" "the same unit on both sides" "learning: delegated pieces are one unit"

# follow-ups: self tasks, CLI tokens, compaction hand-off
cli=$(cat skills/orchestrating/references/backend-cli.md 2>/dev/null)
assert_contains "$orch" "writing only trivial pieces itself" "self: orchestrator keeps its context lean"
assert_contains "$w" '`orchestrator context`' "self: delegation reason for self tasks"
assert_contains "$fmt" "Work: self" "self: Work line marked self"
assert_contains "$wl" 'Tasks whose Work line says `self` count in the run'"'"'s totals but not in the comparison or the `Worker plan:` proposals' "self: left out of the comparison"
assert_contains "$orch" "input and output tokens" "cli: tokens next to cost"
assert_contains "$ledger" ', $<cost>, <tokens>k tokens (<cached>k cached)' "cli: ledger tokens format"
assert_contains "$cli" "summed over the start and every resume" "cli: cost and tokens summed across rounds"
assert_contains "$cli" "cache_read_input_tokens" "cli: cached tokens field named"
assert_contains "$w" "hand the remaining non-trivial pieces to subagents" "compaction: only non-trivial pieces"
assert_contains "$w" "earlier conversation has been replaced by a summary" "compaction: how the worker knows"

assert_contains "$orch" 'in its exact format, compaction included (`compacted n/a → <b> of <n>` when the baseline didn'"'"'t record it)' "wrap-up: exact comparison line"
assert_contains "$orch" "the area's own tasks of that kind from before native workers, or else the project's average per task from before them" "wrap-up: baseline spelled out"
assert_contains "$orch" 'worded exactly `Worker plan: per-piece reviews for <kind> in <area>`' "wrap-up: exact entry wording"

finish
