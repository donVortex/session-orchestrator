#!/usr/bin/env bash
# Knowledge stays small and useful: an entry must say what Claude would otherwise get
# wrong, rules carry their reason, each run records which entries it used, and entries
# unused for several runs are put to the value test (never removed for that alone).
. "$(dirname "$0")/lib.sh"

knowledge=$(cat skills/orchestrating/references/knowledge.md 2>/dev/null)
learning=$(cat skills/orchestrating/references/workflow-learning.md 2>/dev/null)
orch=$(cat skills/orchestrating/SKILL.md 2>/dev/null)
map=$(cat skills/orchestrating/references/knowledge-templates/map.md 2>/dev/null)
readme=$(cat skills/orchestrating/references/knowledge-templates/README.md 2>/dev/null)

# The value test is a content rule
assert_contains "$knowledge" "**Only what Claude would otherwise get wrong.**" "content rule: value test"
assert_contains "$knowledge" "what the code, file names or folder structure already show" "content rule: nothing the repo already shows"
assert_contains "$knowledge" "**A rule says why**" "content rule: rules carry their reason"
assert_contains "$knowledge" "don't ask the user for one just to fill it in" "content rule: a missing reason costs no question"

# Bootstrap drafts apply it from the start
assert_contains "$knowledge" "only what the code doesn't already show" "bootstrap scan: no structure dumps"

# Usage is recorded, and pruning follows from it
assert_contains "$knowledge" "## Pruning" "knowledge: pruning section"
assert_contains "$knowledge" '[event] knowledge used:' "knowledge: usage line"
assert_contains "$learning" '[event] knowledge used: <entries, shortened>' "learning: usage line is a learning line"
assert_contains "$knowledge" "the last 3 runs" "pruning: three runs of evidence"
assert_contains "$knowledge" "Never remove an entry only for being unused" "pruning: unused alone is not enough"
assert_contains "$knowledge" "safety, data handling, money, regulation or destructive actions" "pruning: guarded rules stay"
assert_contains "$knowledge" "plus the pruning candidates" "diff: candidates include pruning candidates"
assert_contains "$orch" '`[event] knowledge used:' "wrap-up logs which entries the run used"
assert_contains "$orch" "references/knowledge.md#pruning" "wrap-up links pruning"

# Template and README say the same
assert_contains "$map" "What the folder structure doesn't tell you" "map template: only what the tree doesn't show"
assert_contains "$readme" "what Claude would otherwise get wrong" "README: value test for hand edits too"

# One list of sources, not two that disagree
assert_not_contains "$knowledge" 'Sources: `bootstrap`, `user`, or `T<n> / PR #<n>`.' "knowledge: no second, shorter sources list"

finish
