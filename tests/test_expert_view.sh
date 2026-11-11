#!/usr/bin/env bash
# Product knowledge and the expert view (v0.7.0): the expert-view reference, the specialist's
# expert mode, product.md, the orchestrator's hooks, and expert checks in briefs and PR bodies.
. "$(dirname "$0")/lib.sh"

ev=$(cat skills/orchestrating/references/expert-view.md 2>/dev/null)
spec=$(cat agents/orch-specialist.md 2>/dev/null)
assert_file skills/orchestrating/references/expert-view.md "expert-view.md exists"
for h in "## When it runs" "## On request" "## Expert mode" "## Raw material and sources" "## Output format" "## Rules" "## Adopt and decline" "## If it fails"; do
  assert_contains "$ev" "$h" "expert-view: heading [$h]"
done
for h in "### 1. What a top professional would do that wasn't asked" "### 2. Raw material" "### 3. Methods and tools" "### 4. What shows it's right, besides us"; do
  assert_contains "$ev" "$h" "expert-view: output part [$h]"
done
assert_contains "$ev" '`opened`' "source mark opened"
assert_contains "$ev" '`recalled`' "source mark recalled"
assert_contains "$ev" '`unreachable`' "source mark unreachable"
assert_contains "$ev" "(recalled only)" "recalled-only label"
assert_contains "$ev" "never marked \`opened\` unless it was read in this call" "no claimed reads"
assert_contains "$ev" "At most 5 recommendations" "5 recommendations"
assert_contains "$ev" "at most 5 web fetches" "5 fetches"
assert_contains "$ev" "up to 3 experts" "3 experts"
assert_contains "$ev" "never code, data or the product's name" "general search terms"
assert_contains "$ev" "never quotes records" "aggregates only"
assert_contains "$ev" "Nothing to add" "empty answer allowed"
assert_contains "$ev" "Out of scope" "declined items not raised again"
assert_contains "$ev" "still to do" "outside checks listed"
assert_contains "$ev" "never block" "checks and failures never block"
assert_contains "$ev" 'Expert view: failed (<why>) — say "expert view" to retry' "failure line"
assert_contains "$ev" "Workers never call" "workers don't call it"
assert_contains "$spec" "**Expert mode**" "specialist: expert mode"
assert_contains "$spec" "references/expert-view.md" "specialist points to expert-view.md"
assert_contains "$spec" "four modes" "specialist: four modes"

k=$(cat skills/orchestrating/references/knowledge.md 2>/dev/null)
p=$(cat skills/orchestrating/references/knowledge-templates/product.md 2>/dev/null)
assert_contains "$k" "## Product knowledge" "knowledge: product section"
assert_contains "$k" '*"Who uses this?"* and *"Whose professional eye matters most here?"*' "bootstrap: two product questions, asked separately"
assert_contains "$k" "[event] product knowledge: declined" "offer declined once"
assert_contains "$k" "by purpose" "product knowledge found by purpose"
assert_contains "$k" "raw material" "bootstrap scouts look for raw material"
assert_contains "$p" "Decided not to:" "template: out of scope entry form"
assert_contains "$p" "assumed" "template: needs name their source"
assert_contains "$p" "never the data" "template: pointers, not data"

orch=$(cat skills/orchestrating/SKILL.md 2>/dev/null)
ledger=$(cat skills/orchestrating/references/ledger.md 2>/dev/null)
tiers=$(cat skills/orchestrating/references/model-tiers.md 2>/dev/null)
assert_contains "$orch" "references/expert-view.md" "orchestrator links expert-view"
assert_contains "$orch" "Expert view: <experts> (<why>)" "plan line: runs"
assert_contains "$orch" 'Expert view: skipped (<why>) — say "expert view" to run it' "plan line: skipped"
assert_contains "$orch" 'Expert view: off in lite — say "expert view" to run it' "plan line: lite"
assert_contains "$orch" "before the breakdown is shown" "runs before the plan"
assert_contains "$orch" "always shown" "decision always shown"
assert_contains "$orch" "references/knowledge.md#product-knowledge" "intake offers product knowledge"
assert_contains "$orch" "as a follow-up" "adopted items reach running workers"
assert_contains "$orch" "open checks" "wrap-up lists open checks"
assert_contains "$ledger" "[expert] <target> <experts>: <n> proposed, <k> adopted" "ledger: expert line"
assert_contains "$ledger" "[expert] declined E<n>: <reason>" "ledger: declined line"
assert_contains "$tiers" "| Expert view | at planning, for goals that touch the product's field | only on request |" "lite row"

finish
