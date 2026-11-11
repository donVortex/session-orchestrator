#!/usr/bin/env bash
# Workflow-learning reference: event kinds, counts table, plan labels, headings; ledger uses the tags.
. "$(dirname "$0")/lib.sh"

ref=$(cat skills/orchestrating/references/workflow-learning.md 2>/dev/null)
assert_file skills/orchestrating/references/workflow-learning.md "workflow-learning.md exists"

for tag in '[ask-user]' '[approval]' '[prompt]' '[start-click]' '[failed]' '[changes]' '[escalate]' '[worker-q]' '[expert]' '[event]'; do
  assert_contains "$ref" "$tag" "event kind $tag"
done

assert_contains "$ref" "| task | recipe | ask-user | approval | prompt | start-click | failed | changes | escalate | worker-q |" "counts table header"
assert_contains "$ref" "Assumed from project knowledge:" "plan label for learned defaults"
assert_contains "$ref" "Following recipe:" "plan label for recipes"

for h in "## Event kinds" "## Counts table" "## Findings to proposals" "## Using what was learned" "## Guardrails"; do
  assert_contains "$ref" "$h" "heading [$h]"
done

assert_contains "$ref" '[env]' "event kind [env] for environment-lost rounds"
for prefix in '[event] pre-flight:' 'following recipe:' '[event] assumed default:' '[event] user overrode default:'; do
  assert_contains "$ref" "$prefix" "fixed-prefix event line [$prefix]"
done
assert_contains "$ref" ".orchestration/counts.md" "full counts table goes to a file"
assert_contains "$ref" "Don't propose what's already there" "dedupe rule"
assert_contains "$(cat skills/orchestrating/references/knowledge.md)" 'except calibration'"'"'s `## Recipes`' "bootstrap keeps the workflow sections"

assert_contains "$ref" "no attention except product decisions" "new-recipe rule allows product decisions recorded as domain rules"

assert_contains "$(cat skills/working/SKILL.md)" "wait for it in the same turn" "worker waits for its review subagents before ending the turn"

ledger=$(cat skills/orchestrating/references/ledger.md 2>/dev/null)
assert_contains "$ledger" "[ask-user]" "ledger.md shows a tagged event"
assert_contains "$ledger" "starts with a kind tag" "ledger.md requires kind tags"
assert_contains "$ledger" "left unanswered in the previous run" "branch question is not repeated once left unanswered"

# Tier learning: per-subtask outcomes in reports, findings rows both ways, guardrail
format=$(cat skills/working/report-format.md 2>/dev/null)
tmpl=$(cat skills/orchestrating/references/knowledge-templates/calibration.md 2>/dev/null)
tiers=$(cat skills/orchestrating/references/model-tiers.md 2>/dev/null)
assert_contains "$format" "## Subtasks" "report has a Subtasks section"
assert_contains "$format" "| Subtask | Kind | Tier | Outcome | Review found |" "Subtasks table columns"
assert_contains "$ref" 'Tier: <kind of subtask> in <area> is <tier>' "tier entry format"
assert_contains "$ref" "escalated, or a \`[tier]\` point says the model was too weak" "raise row"
assert_contains "$ref" "passed on the first try with at most minor review findings" "lower row: clean first-try passes"
assert_contains "$ref" "for the same kind of subtask in two runs" "lower row needs two runs"
assert_contains "$ref" "one tier down" "lower one step at a time"
assert_contains "$ref" "on a tier lowered by a \`Tier:\` entry escalated" "revert row"
assert_contains "$ref" "A \`Tier:\` entry never lowers the tier of work that" "tier guardrail"
assert_contains "$ref" '`Skill: …`, `Tier: …`' "Tier prefix in the layout rule"
assert_contains "$ref" "the \`Tier:\` entries for its subtasks" "briefs carry tier entries"
assert_contains "$tmpl" "**Tier:" "calibration example uses the Tier prefix"
assert_contains "$tiers" "Tiers by task type" "model-tiers points at project calibration"
assert_contains "$(cat skills/working/SKILL.md)" "follow the brief's tier hints" "worker follows the brief's tier hints"

finish
