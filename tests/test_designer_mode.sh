#!/usr/bin/env bash
# Designer mode: a per-person switch (a word in the goal, or the user's own CLAUDE.md),
# never a project setting and never guessed. In designer mode, work in engineer-owned
# code goes to its own PR for the owner's review, fixed areas get a drafted issue, and
# PRs wait for an engineer's approval. Engineering mode (the default) is unchanged.
. "$(dirname "$0")/lib.sh"

orch=$(cat skills/orchestrating/SKILL.md 2>/dev/null)
dm=$(cat skills/orchestrating/references/designer-mode.md 2>/dev/null)
ledger=$(cat skills/orchestrating/references/ledger.md 2>/dev/null)
knowledge=$(cat skills/orchestrating/references/knowledge.md 2>/dev/null)
learning=$(cat skills/orchestrating/references/workflow-learning.md 2>/dev/null)
readme=$(cat README.md 2>/dev/null)

# The switch
assert_contains "$orch" "**Audience:**" "intake: audience step"
assert_contains "$orch" "(references/designer-mode.md)" "intake: links designer mode"
assert_contains "$dm" "## The switch" "designer mode: switch section"
assert_contains "$dm" '`session-orchestrator: designer mode`' "switch: personal setting line"
assert_contains "$dm" "Never a project setting" "switch: per person, not per project"
assert_contains "$dm" "never guess it" "switch: never inferred"
assert_contains "$dm" 'Audience: designer (<source>) — say "engineering" to switch' "switch: approval line"
assert_contains "$ledger" "Audience: engineering|designer" "ledger: header records audience"

# Engineering mode is unchanged
assert_contains "$dm" "## Engineering mode is unchanged" "designer mode: engineering unchanged section"
assert_contains "$orch" 'not read `designer.md`' "intake: engineering runs skip designer.md"
assert_contains "$knowledge" 'except `designer.md`' "knowledge: designer.md read only in designer mode"

# Ownership
assert_contains "$dm" "## Who owns what" "designer mode: ownership section"
assert_contains "$dm" "CODEOWNERS" "ownership: read from CODEOWNERS"
assert_contains "$dm" "**guarded:**" "ownership: guarded areas"
assert_contains "$dm" "**fixed:**" "ownership: fixed areas"
assert_contains "$dm" "never an email" "ownership: no emails in knowledge"

# The reviewer split
assert_contains "$dm" "## Splitting by reviewer" "designer mode: split section"
assert_contains "$dm" "its own task and PR" "split: guarded work in its own PR"
assert_contains "$dm" "the agreed shape" "split: both sides build to one shape"
assert_contains "$dm" "Merge order" "split: owner PR merges first"
assert_contains "$dm" "Draft the issue; never create it" "fixed: issue drafted, posted only on the user's yes"
assert_contains "$dm" "What users will see" "UI PRs: section for the designer"

# Tracking
assert_contains "$ledger" '`awaiting-owner`' "ledger: awaiting-owner status"
assert_contains "$dm" "## Waiting for the engineer" "designer mode: tracking section"
assert_contains "$dm" "never poll" "tracking: no polling"
assert_contains "$dm" "as they are, without the verify step" "tracking: owner's comments go to the worker as they are"
assert_contains "$learning" '`[event] audience:' "learning: audience event line"

# README
assert_contains "$readme" "## Designer mode" "README: designer mode section"

finish
