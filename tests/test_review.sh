#!/usr/bin/env bash
# Reviews (v0.6.0): finding severities and evidence, verifying findings before work goes back,
# a cap on review rounds, risk tags with revert notes, a base-branch check after merges,
# REVIEW.md support and learning from review outcomes.
. "$(dirname "$0")/lib.sh"

reviews=$(cat skills/orchestrating/references/reviews.md 2>/dev/null)
orch=$(cat skills/orchestrating/SKILL.md 2>/dev/null)
worker=$(cat skills/working/SKILL.md 2>/dev/null)
spec=$(cat agents/orch-specialist.md 2>/dev/null)
brief=$(cat skills/orchestrating/references/brief-template.md 2>/dev/null)
format=$(cat skills/working/report-format.md 2>/dev/null)
learning=$(cat skills/orchestrating/references/workflow-learning.md 2>/dev/null)
knowledge=$(cat skills/orchestrating/references/knowledge.md 2>/dev/null)
checklist=$(cat skills/orchestrating/references/knowledge-templates/review-checklist.md 2>/dev/null)
coexist=$(cat skills/orchestrating/references/coexistence.md 2>/dev/null)
tiers=$(cat skills/orchestrating/references/model-tiers.md 2>/dev/null)
ledger=$(cat skills/orchestrating/references/ledger.md 2>/dev/null)

assert_file skills/orchestrating/references/reviews.md "reviews.md exists"

# 1. Findings: severity, pre-existing, evidence, verification
assert_contains "$reviews" "## Findings" "reviews: findings section"
assert_contains "$reviews" '`pre-existing`' "reviews: pre-existing tag"
assert_contains "$reviews" "A finding without evidence is dropped" "reviews: path:line evidence required"
assert_contains "$reviews" "At most 3 \`minor\` findings" "reviews: nits capped"
assert_contains "$reviews" "Name the class" "reviews: flag the bug class"
assert_contains "$reviews" "Nothing to fix." "reviews: summary starts with a count"
assert_contains "$reviews" "never a reason to send work back" "reviews: minor findings don't block"
assert_contains "$reviews" "## Verify before sending work back" "reviews: verification section"
assert_contains "$reviews" "it is not a second review" "reviews: verification is not a second review"
assert_contains "$reviews" "never you yourself" "reviews: verification is independent"
assert_contains "$orch" "not by re-reading the code yourself" "orchestrator: verification by a fresh subagent"
assert_contains "$spec" "**Verify mode**" "specialist: verify mode"
assert_contains "$spec" "references/reviews.md" "specialist follows the review rules"
assert_contains "$worker" "../orchestrating/references/reviews.md#verify-before-sending-work-back" "worker verifies findings first"
assert_contains "$orch" "references/reviews.md#verify-before-sending-work-back" "orchestrator verifies findings first"
assert_contains "$coexist" "Verifying a finding is not a second review" "coexistence: one review per change still holds"

# 2. Rounds
assert_contains "$reviews" "## Rounds" "reviews: rounds section"
assert_contains "$reviews" "**Cap: 3 rounds.**" "reviews: round cap"
assert_contains "$reviews" "re-review only the fix" "reviews: diff-only re-review"
assert_contains "$reviews" "Never repeat a finding" "reviews: no repeated findings"
assert_contains "$worker" "references/reviews.md#rounds" "worker: round cap"
assert_contains "$orch" "references/reviews.md#rounds" "orchestrator: round cap"
assert_contains "$learning" '[changes] T<n> round <k>' "ledger line per review round"

# 3. Risk tags and revert notes
assert_contains "$reviews" "## Risk tags" "reviews: risk tags section"
assert_contains "$reviews" "the change sets it, not the author" "reviews: the diff decides the risk"
assert_contains "$reviews" "CI and workflow files" "reviews: CI files are high risk"
assert_contains "$reviews" "the reviews don't replace your reading" "reviews: agent review never replaces the user's"
assert_contains "$orch" "| id | task | owns | depends | tier | risk | placement |" "plan table has a risk column"
assert_contains "$ledger" "| tier | risk | placement |" "ledger table has a risk column"
assert_contains "$brief" "- Risk: low | normal | high" "brief carries the risk tag"
assert_contains "$worker" "How to revert" "PR body: how to revert"
assert_contains "$worker" "Follow-ups" "PR body: follow-ups"

# 4. Base branch after merges
assert_contains "$reviews" "## Check the base branch after merges" "reviews: base check section"
assert_contains "$reviews" "[event] base check: green @ <sha>" "base check logged"
assert_contains "$orch" "references/reviews.md#check-the-base-branch-after-merges" "orchestrator runs the base check"

# 5. REVIEW.md, checklist template, learning from outcomes
assert_contains "$reviews" "REVIEW.md" "reviews: project REVIEW.md"
assert_contains "$knowledge" "REVIEW.md" "knowledge: REVIEW.md read at intake"
assert_contains "$checklist" "## What failure looks like here" "checklist template: failure definition"
assert_contains "$checklist" "## Sensitive paths (always high risk)" "checklist template: sensitive paths"
assert_contains "$checklist" "## Don't review" "checklist template: paths to skip"
assert_contains "$format" "- Review findings:" "report: finding outcomes"
assert_contains "$learning" "A bug reached the base branch" "learning: escaped bugs become checklist entries"
assert_contains "$learning" "Reviews were noisy" "learning: noisy reviews narrow the checklist"
assert_contains "$tiers" "only for guarded work" "lite: verification only for guarded work"

finish
