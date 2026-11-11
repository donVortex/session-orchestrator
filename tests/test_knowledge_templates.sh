#!/usr/bin/env bash
# Project knowledge templates: budget headers, section headings, no entries; wiring into briefs and reports.
. "$(dirname "$0")/lib.sh"

T=skills/orchestrating/references/knowledge-templates

# check_template <file> <budget> <heading>...
check_template() {
  name=$1; f="$T/$1"; budget=$2; shift 2
  assert_file "$f" "$name exists"
  [ -f "$f" ] || return
  assert_eq "<!-- budget: $budget lines -->" "$(head -n 1 "$f" | tr -d '\r')" "$(basename "$f") budget header"
  body=$(cat "$f")
  for h in "$@"; do
    assert_contains "$body" "$h" "$(basename "$f") has heading [$h]"
  done
  # Example entries inside <!-- --> comments are allowed; real entries are not.
  awk '/<!--/{c=1} !c{print} /-->/{c=0}' "$f" | grep -q '^- \*\*' && fail "$(basename "$f") has no entries (template only)"
}

check_template domain.md 150 "## Rules" "## Glossary"
check_template map.md 100 "## Areas" "## Feature flows"
check_template review-checklist.md 60 "## Always check" "## When touching <area>"
check_template product.md 80 "## Users" "## Needs" "## Out of scope" "## Experts"
check_template calibration.md 120 "## Tiers by task type" "## Split patterns" "## Briefs need" "## Recipes" "## Learned defaults" "## Skills" "## Pre-flight"

readme=$(cat "$T/README.md" 2>/dev/null)
assert_file "$T/README.md" "README.md exists"
for f in domain.md map.md review-checklist.md calibration.md product.md; do
  assert_contains "$readme" "$f" "README mentions $f"
done

# the project-rules skill template points to the knowledge, never copies it
ps=$(cat "$T/project-rules-skill.md" 2>/dev/null)
assert_file "$T/project-rules-skill.md" "project-rules skill template exists"
assert_contains "$ps" "name: project-rules" "project-rules skill name"
assert_contains "$ps" "description: Use when" "project-rules skill description starts with Use when"
assert_contains "$ps" ".claude/orchestrator/domain.md" "project-rules skill points to domain.md"
assert_contains "$ps" "review checklist" "project-rules skill points to the review checklist"
awk '/<!--/{c=1} !c{print} /-->/{c=0}' "$T/project-rules-skill.md" 2>/dev/null | grep -q '^- \*\*' && fail "project-rules skill copies no rule entries"
assert_contains "$(cat skills/orchestrating/references/knowledge.md)" "project skill: declined" "knowledge.md remembers a declined project skill"

# identifiers mean record IDs, not code names
assert_contains "$readme" "record identifiers" "README says record identifiers"
assert_contains "$readme" "code names" "README says code names are fine"

# knowledge PR lookup is exact, and several open PRs are handled
knowledge=$(cat skills/orchestrating/references/knowledge.md 2>/dev/null)
filter='startswith("orch/knowledge-")'
assert_contains "$knowledge" "$filter" "knowledge.md filters PR branches by exact prefix"
assert_contains "$(cat skills/orchestrating/SKILL.md 2>/dev/null)" "$filter" "SKILL.md filters PR branches by exact prefix"
assert_contains "$knowledge" "More than one is open" "knowledge.md handles several open knowledge PRs"

# workers state the rule, not the value, in [domain] points
assert_contains "$(cat skills/working/report-format.md 2>/dev/null)" "state the rule, not the value" "report format: domain points state the rule"

# wiring into briefs, reports and the worker skill
brief=$(cat skills/orchestrating/references/brief-template.md 2>/dev/null)
assert_contains "$brief" "- Project rules:" "brief has a Project rules field"
assert_contains "$brief" "- Review checklist:" "brief has a Review checklist field"
assert_contains "$(cat skills/working/report-format.md 2>/dev/null)" '| `domain` |' "report format has the domain tag"
assert_contains "$(cat skills/working/SKILL.md 2>/dev/null)" "Review checklist" "worker skill passes the review checklist to reviews"

# the layout table gives new calibration files a 120-line budget
assert_contains "$(grep '^| `calibration.md`' skills/orchestrating/references/knowledge.md 2>/dev/null)" "| 120 |" "knowledge.md: calibration budget 120"

# the layout table gives new product files an 80-line budget
assert_contains "$(grep '^| `product.md`' skills/orchestrating/references/knowledge.md 2>/dev/null)" "| 80 |" "knowledge.md: product budget 80"

finish
