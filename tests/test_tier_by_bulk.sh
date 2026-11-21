#!/usr/bin/env bash
# Opus only where it pays (v0.14.0): a task's tier follows most of its work, not its hardest
# piece; visual work isn't deep; guarded work is reviewed by risk but built by difficulty;
# deep rows give their reason and the plan counts them; tier learning raises on the same
# evidence it lowers on.
. "$(dirname "$0")/lib.sh"

tiers=$(cat skills/orchestrating/references/model-tiers.md 2>/dev/null)
split=$(cat skills/orchestrating/references/splitting.md 2>/dev/null)
orch=$(cat skills/orchestrating/SKILL.md 2>/dev/null)
learn=$(cat skills/orchestrating/references/workflow-learning.md 2>/dev/null)
rev=$(cat skills/orchestrating/references/reviews.md 2>/dev/null)

# What deep is for
assert_contains "$tiers" "software design (architecture, data models, interfaces between parts)" "tiers: deep means software design"
assert_contains "$tiers" "UI work, styling, mockups and page rebuilds" "tiers: UI work is standard"
assert_contains "$tiers" "**A task's tier follows most of its work.**" "tiers: tier by the bulk of the work"
assert_contains "$tiers" "**Visual work is not \`deep\`.**" "tiers: visual work isn't deep"
assert_contains "$tiers" "**Guarded work: the risk sets the review, the difficulty sets the build tier.**" "tiers: guarded build tier by difficulty"

# Splitting picks the tier the same way
assert_contains "$split" "by most of its work, not its hardest piece" "splitting: tier by the bulk"
assert_contains "$split" "Data-changing migrations and performance work are \`deep\`" "splitting: data-changing migrations are deep"
assert_contains "$split" "An additive migration (a new table or column) is \`standard\`" "splitting: additive migrations are standard"
assert_not_contains "$split" "by the hardest thing in the task" "splitting: no hardest-thing rule"

# The plan shows why and how many
assert_contains "$orch" "every \`deep\` row gives its reason" "plan: deep rows give a reason"
assert_contains "$orch" '`Opus: <n> of <m> tasks (<ids>)' "plan: opus count line"

# Risk sets the review, not the build tier
assert_contains "$rev" "The risk tag sets the review, not the build tier" "reviews: risk vs tier"

# Learning raises on the same evidence it lowers on
assert_contains "$learn" "in two runs, or once when the retro shows the model, not a missing brief detail, caused it" "learning: raising needs evidence"

finish
