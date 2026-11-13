#!/usr/bin/env bash
# "What good looks like": for goals with a visible result, intake offers one optional
# line for examples. The orchestrator reads them as properties (never a template),
# shows its reading in the approval message, carries the properties into briefs and
# the review, and keeps the examples' own data out of briefs, the ledger and knowledge.
. "$(dirname "$0")/lib.sh"

orch=$(cat skills/orchestrating/SKILL.md 2>/dev/null)
ex=$(cat skills/orchestrating/references/examples.md 2>/dev/null)
brief=$(cat skills/orchestrating/references/brief-template.md 2>/dev/null)
learning=$(cat skills/orchestrating/references/workflow-learning.md 2>/dev/null)

# Intake asks it, optionally, and only when it fits
assert_contains "$orch" "**What good looks like**" "intake: examples step"
assert_contains "$orch" "(references/examples.md)" "intake: links the reference"
assert_contains "$ex" "## When to ask" "examples: when section"
assert_contains "$ex" "a visible result" "examples: only for goals with a visible result"
assert_contains "$ex" "Never for refactors, bug fixes, infrastructure or tests" "examples: not for invisible work"
assert_contains "$ex" "never a stop of its own" "examples: no extra stop"
assert_contains "$ex" "or what you don't want" "examples: counter-examples welcome"
assert_contains "$ex" "Never ask again on resume" "examples: not re-asked on resume"

# Read as properties, shown for approval
assert_contains "$ex" "## Reading them" "examples: reading section"
assert_contains "$ex" "properties, never a template" "examples: properties, not a template"
assert_contains "$orch" '`Good looks like: <properties> (from <examples>)`' "approval: shows the reading"
assert_contains "$ex" "Exact text the user wants" "examples: exact wanted text is a goal value, not an example"

# Carried into briefs and review
assert_contains "$brief" "- Good looks like:" "brief: field"
assert_contains "$brief" "never the example itself" "brief: properties only"
assert_contains "$orch" "Good looks like properties" "review: checks the properties"

# Data stays out; persistence only through the knowledge diff
assert_contains "$ex" "## Their data" "examples: data section"
assert_contains "$ex" "never with the example's own values as a sample" "examples: formats in words"
assert_contains "$brief" "its values or its source" "brief: no values or source"
assert_contains "$ex" "names, emails, amounts, record ids" "examples: values never copied"
assert_contains "$ex" "only through the [knowledge diff]" "examples: lasting taste via knowledge diff"
assert_contains "$learning" '`[event] examples:' "learning: examples event line"

# README tells users about it
assert_contains "$(cat README.md 2>/dev/null)" "**Show what good looks like (optional):**" "README: examples step"

finish
