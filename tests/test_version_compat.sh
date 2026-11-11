#!/usr/bin/env bash
# Updating the plugin mid-run: workers accept briefs from an older orchestrator,
# the orchestrator resumes ledgers from an older version, and the README says what to do.
. "$(dirname "$0")/lib.sh"

worker=$(cat skills/working/SKILL.md 2>/dev/null)
orch=$(cat skills/orchestrating/SKILL.md 2>/dev/null)
ledger=$(cat skills/orchestrating/references/ledger.md 2>/dev/null)
readme=$(cat README.md 2>/dev/null)

# Workers: missing newer brief fields get defaults, not a blocking question
assert_contains "$worker" "**A brief from an older plugin version**" "worker: older briefs handled"
assert_contains "$worker" 'no `Risk:` line → `normal`' "worker: default risk"
assert_contains "$worker" 'no `Mode:` line → `full`' "worker: default mode"
assert_contains "$worker" "never block on it" "worker: missing newer fields don't block"
assert_contains "$worker" "[brief] older brief" "worker: notes it in the retro"

# Orchestrator: resuming a ledger from an older version
assert_contains "$ledger" "## A ledger from an older version" "ledger: older-ledger section"
assert_contains "$ledger" 'no `risk` column' "ledger: missing risk column handled"
assert_contains "$ledger" "tag every task right away" "ledger: risk tagged on resume, not later"
assert_contains "$ledger" 'no `Mode:` in the header' "ledger: missing mode handled"
assert_contains "$ledger" "never re-plan" "ledger: no re-planning on upgrade"
assert_contains "$orch" "references/ledger.md#a-ledger-from-an-older-version" "resume links the older-ledger rules"

# README: updating while a run is in progress
assert_contains "$readme" "**Updating while a run is in progress.**" "README: mid-run update note"
assert_contains "$readme" "Don't resume an old session" "README: avoid resuming across an update"

finish
