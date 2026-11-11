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
assert_contains "$ev" "at most 5 web requests (searches and fetches together)" "5 web requests"
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
assert_contains "$tiers" "| Expert view | at planning, for goals that touch the product's field | only on request |" "lite row"

brief=$(cat skills/orchestrating/references/brief-template.md 2>/dev/null)
worker=$(cat skills/working/SKILL.md 2>/dev/null)
reviews=$(cat skills/orchestrating/references/reviews.md 2>/dev/null)
assert_contains "$brief" "still to do" "brief: outside checks marked"
assert_contains "$worker" "still to do" "worker: PR lists outside checks"
assert_contains "$reviews" "still to do" "reviews: PR body lists outside checks"
assert_not_contains "$worker" "expert view" "workers never run the expert view"

# from the eval run: rules the orchestrator and the specialist missed
assert_contains "$orch" "become the tasks' acceptance criteria" "plan: expert checks become acceptance criteria"
assert_contains "$orch" "log it as \`[expert]" "track: expert ledger lines named in the skill"
assert_contains "$orch" "wait for the user's yes before asking the product questions" "intake: offer first, questions after yes"
assert_contains "$ev" "Use only these three marks" "only three source marks"
assert_contains "$ev" "opened (given by the caller)" "caller-supplied material"

assert_contains "$orch" "offer once, in one line of the approval message, to start its product knowledge" "intake: the offer names product knowledge"
assert_contains "$ev" "ends with exactly \`(recalled only)\`" "recalled-only label is exact"

assert_contains "$ev" "rests on S1, S3 [(recalled only) when every source it rests on is recalled]" "format template carries the recalled-only label"

assert_contains "$spec" "Before you return, check each recommendation" "specialist: final label self-check"

assert_contains "$ev" "Before returning, check each recommendation" "expert-view: final label self-check"


# final review fixes
readme=$(cat README.md 2>/dev/null)
assert_contains "$ev" ".orchestration/expert/" "I1: each view is saved and linked"
assert_contains "$ev" '[expert] declined <target> E<n> "<thing>": <reason>' "I1: decline line names what was declined"
assert_contains "$ledger" '[expert] declined <target> E<n> "<thing>": <reason>' "I1: ledger decline line"
assert_contains "$k" 'the `[expert]` lines' "I1: wrap-up candidates include expert lines"
assert_contains "$ev" "sent to the worker with the follow-up" "I1: still-to-do checks for an open PR reach it"
assert_contains "$orch" "the absolute path of \`references/expert-view.md\`" "I2: the orchestrator hands the subagent its rules"
assert_contains "$spec" "never code, data or the product's name" "I2: privacy rules inline in expert mode"
assert_contains "$spec" "never quote records" "I2: aggregates only, inline"
assert_contains "$spec" "at most 5 web requests" "I2: request limit inline"
assert_contains "$orch" "in the same message as the breakdown" "I3: adopt/decline is part of the one routine stop"
assert_not_contains "$readme" "never sends anything anywhere" "README no longer says nothing is sent"
assert_contains "$k" "Projects bootstrapped before" "offer only to projects with older knowledge"
assert_contains "$k" "never in lite" "no offer in lite"
assert_not_contains "$ev" "afterwards, offer" "no second offer from the expert view"


# deferred minors from the v0.7.0 review
tiers=$(cat skills/orchestrating/references/model-tiers.md 2>/dev/null)
assert_contains "$k" 'When the user declined product knowledge, declines go into the rules file as `Decided not to:` entries' "M1: declines have a home without product knowledge"
assert_contains "$k" "and product's \`## Out of scope\`" "M1: bootstrap keeps an empty Out of scope"
assert_contains "$tiers" '| `orch-specialist` (expert mode) | the expert view | opus, in lite too |' "M2: expert model in the roles table"
assert_not_contains "$ev" "opus / medium" "M2: no effort setting for a subagent"
assert_contains "$ev" "model-tiers.md#roles" "M2: expert-view points to the roles table"
assert_contains "$readme" "two of them about your users and experts" "M3: README interview count"
assert_contains "$readme" "*recalled* (not read now:" "M3: README recalled definition"
assert_contains "$readme" "up to 5 web requests" "M3: README request limit"
assert_contains "$readme" "except an expert view you ask for" "M3: README lite table exception"
assert_contains "$ev" "reviewed but not merged" "M4: adopt for a reviewed task"
assert_contains "$ev" "already merged" "M4: adopt for a merged task"
assert_contains "$ev" 'logged as `[expert]`, not `[changes]`' "M4: expert follow-ups aren't rework"
assert_contains "$ev" "every other running worker whose brief quotes the old rule" "M4: rule change reaches all running workers"
assert_contains "$orch" 'Expert view: failed (<why>)' "M5: SKILL.md lists the failed line"
assert_contains "$k" "[product.md](knowledge-templates/product.md)" "M5: starter list includes product.md"
assert_contains "$k" "a raw-material path" "M5: entry format allows raw-material sources"
assert_contains "$k" '`expert view, declined by user`' "M5: entry format allows expert-view declines"
assert_contains "$brief" "for whom: the users and needs" "M5: brief Goal names the users"
assert_contains "$k" "the product answers" "M5: plural product answers"

finish
