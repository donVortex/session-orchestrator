#!/usr/bin/env bash
# UI/UX review (v0.15.0): a PR that changes what users see gets a Sonnet review of the result,
# not only the code, next to the usual review: against the brief's Good looks like properties,
# the approved mockup and the PR's screenshots; states, phone width, themes, copy and basic
# accessibility. Taste the user already approved isn't a finding.
. "$(dirname "$0")/lib.sh"

orch=$(cat skills/orchestrating/SKILL.md 2>/dev/null)
rev=$(cat skills/orchestrating/references/reviews.md 2>/dev/null)
spec=$(cat agents/orch-specialist.md 2>/dev/null)
brief=$(cat skills/orchestrating/references/brief-template.md 2>/dev/null)
tiers=$(cat skills/orchestrating/references/model-tiers.md 2>/dev/null)

# When it runs and on what model
assert_contains "$orch" "UI/UX review" "review step: UI/UX review"
assert_contains "$orch" "(references/reviews.md#uiux-review)" "review step: links the section"
assert_contains "$rev" "## UI/UX review" "reviews: UI/UX section"
assert_contains "$rev" "changes what users see" "reviews: runs for user-facing changes"
assert_contains "$rev" "never for a backend-only diff" "reviews: not for backend-only"
assert_contains "$rev" "on sonnet, never opus" "reviews: sonnet"
assert_contains "$rev" "in parallel with" "reviews: alongside the code review"

# What it checks
assert_contains "$rev" "empty, loading and error states" "checks: states"
assert_contains "$rev" "phone width" "checks: phone width"
assert_contains "$rev" "every action the old screen had" "checks: rebuild parity"
assert_contains "$rev" "labels, keyboard focus, text contrast" "checks: basic accessibility"
assert_contains "$rev" "Taste the user already approved is not a finding" "checks: no re-litigating approved look"
assert_contains "$rev" '"not checked"' "checks: unseen visuals are not checked"

# The specialist has the mode
assert_contains "$spec" "**UI review mode**" "specialist: UI review mode"
assert_contains "$spec" "six modes" "specialist: mode count"

# Workers provide what it needs
assert_contains "$brief" "screenshots of each screen it changes" "brief: screenshots for UI tasks"

# Lite keeps it cheap
assert_contains "$tiers" "| UI/UX review |" "lite table: UI/UX review row"

finish
