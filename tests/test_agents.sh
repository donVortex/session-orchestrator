#!/usr/bin/env bash
# Role agents' frontmatter and the model tier rubric's machine-checked lines.
. "$(dirname "$0")/lib.sh"

# Prints the value of a frontmatter field from an agent file.
field() {
  tr -d '\r' < "$1" 2>/dev/null | awk 'NR==1 && /^---$/ {f=1; next} f && /^---$/ {exit} f' |
    grep -m1 "^$2:" | sed "s/^$2:[[:space:]]*//"
}

check_agent() {
  f="agents/$1.md"
  assert_file "$f" "$1 agent exists"
  assert_eq "$1" "$(field "$f" name)" "$1 name matches filename"
  [ -n "$(field "$f" description)" ] || fail "$1 has a description"
  assert_eq "$2" "$(field "$f" model)" "$1 default model"
}

check_agent orch-scout haiku
check_agent orch-implementer sonnet
check_agent orch-specialist opus

scout_tools=$(field agents/orch-scout.md tools)
[ -n "$scout_tools" ] || fail "orch-scout declares tools"
assert_not_contains "$scout_tools" "Edit" "orch-scout is read-only (no Edit)"
assert_not_contains "$scout_tools" "Write" "orch-scout is read-only (no Write)"

tiers=$(cat skills/orchestrating/references/model-tiers.md 2>/dev/null)
assert_contains "$tiers" '| `fast` | sonnet for edits; haiku for read-only work | sonnet / low |' "fast tier row: haiku only reads"
assert_contains "$tiers" '| `standard` | sonnet | sonnet / medium |' "standard tier row"
assert_contains "$tiers" '| `deep` | opus | opus / medium for design and cross-cutting changes; opus / high for bugs with an unknown cause, security and guarded work |' "deep tier row: effort by kind of work"
assert_contains "$tiers" 'max_parallel_workers: 4' "worker cap"
assert_contains "$tiers" 'max_parallel_implementers_per_session: 3' "implementer cap"

# Model guide (v0.6.1): haiku only reads; escalation climbs check -> effort -> model;
# hard work with a clear spec is still deep
splitting=$(cat skills/orchestrating/references/splitting.md 2>/dev/null)
orch=$(cat skills/orchestrating/SKILL.md 2>/dev/null)
worker=$(cat skills/working/SKILL.md 2>/dev/null)
readme=$(cat README.md 2>/dev/null)
cli=$(cat skills/orchestrating/references/backend-cli.md 2>/dev/null)
assert_contains "$tiers" "**Haiku only reads.**" "tiers: haiku never edits code"
assert_contains "$tiers" "Only read-only subagents drop to haiku" "session floor: only read-only subagents on haiku"
assert_contains "$tiers" "1. **A way to check the work.**" "escalation step 1: a runnable check"
assert_contains "$tiers" "2. **More effort, for worker sessions.**" "escalation step 2: effort first"
assert_contains "$tiers" "3. **The next model up.**" "escalation step 3: then the model"
assert_contains "$tiers" '[escalate] T<n> effort <from> → <to>' "effort escalation logged"
assert_contains "$orch" "one effort step higher" "failed round goes back with more effort"
assert_contains "$cli" "resume <task-id> <session-id> <message-file> [effort [model]]" "CLI resume takes an effort and a model"
assert_contains "$worker" "give it one and retry on the same tier" "worker: a missing check is fixed before escalating"
assert_contains "$splitting" "Migrations and performance work are \`deep\`" "migrations and performance work are deep"
assert_contains "$readme" "### Which model to start the orchestrator on" "README: orchestrator model advice"

finish
