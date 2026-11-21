#!/usr/bin/env bash
# Personas and the user panel (v0.16.0): 2-4 personas in product knowledge, each with its
# source; they come from the product questions, a draft at the first panel request, the
# user's own notes, or corrections. The panel runs on request, on sonnet, looks for where
# each persona gets stuck, labels itself synthetic, and is adopted or declined like the
# expert view.
. "$(dirname "$0")/lib.sh"

orch=$(cat skills/orchestrating/SKILL.md 2>/dev/null)
panel=$(cat skills/orchestrating/references/panel.md 2>/dev/null)
know=$(cat skills/orchestrating/references/knowledge.md 2>/dev/null)
tmpl=$(cat skills/orchestrating/references/knowledge-templates/product.md 2>/dev/null)
learn=$(cat skills/orchestrating/references/workflow-learning.md 2>/dev/null)
rev=$(cat skills/orchestrating/references/reviews.md 2>/dev/null)
spec=$(cat agents/orch-specialist.md 2>/dev/null)
readme=$(cat README.md 2>/dev/null)

# Personas: format, sources, privacy
assert_contains "$panel" "## Personas" "panel: personas section"
assert_contains "$panel" "2–4 personas" "personas: a few"
assert_contains "$panel" '`your understanding`' "personas: default source"
assert_contains "$panel" '`client conversation, <date>`' "personas: client source"
assert_contains "$panel" '`usage data: <what>`' "personas: data source"
assert_contains "$panel" "never a real person's name" "personas: composites, no names"
assert_contains "$tmpl" "_(your understanding)_" "template: persona example with its source"

# How they get in
assert_contains "$panel" "### How personas get in" "panel: sources section"
assert_contains "$panel" "before the panel runs" "first request: drafts approved before running"
assert_contains "$panel" '`[correction]`' "corrections update personas"
assert_contains "$know" "draft 2–4 personas" "product questions: answer becomes personas"

# Asking the panel
assert_contains "$panel" "## Asking the panel" "panel: asking section"
assert_contains "$panel" "Only on request" "panel: on request only"
assert_contains "$panel" "on sonnet" "panel: sonnet"
assert_contains "$panel" "never whether they like it" "panel: looks for breakage, not approval"
assert_contains "$panel" "synthetic" "panel: labelled synthetic"
assert_contains "$panel" "(your understanding only)" "panel: marks guess-only items"
assert_contains "$orch" "(references/panel.md)" "SKILL: links the panel"

# Adopt, decline, log
assert_contains "$panel" "## Adopt and decline" "panel: adopt and decline"
assert_contains "$panel" '`[panel] <target> <personas>: <n> proposed, <k> adopted' "panel: ledger line"
assert_contains "$learn" '`[panel]`' "learning: panel tag"

# The specialist and the UI review
assert_contains "$spec" "**Panel mode**" "specialist: panel mode"
assert_contains "$spec" "six modes" "specialist: mode count"
assert_contains "$rev" "walks the screens as each persona" "UI review: persona walk-through"

# README
assert_contains "$readme" "### Personas and the user panel" "README: panel section"

finish
