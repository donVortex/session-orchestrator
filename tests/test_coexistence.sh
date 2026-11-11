#!/usr/bin/env bash
# Coexistence with other skills and plugins: one contract, judged by effect; skills in briefs; learning per project.
. "$(dirname "$0")/lib.sh"

# the contract reference
c=$(cat skills/orchestrating/references/coexistence.md 2>/dev/null)
assert_file skills/orchestrating/references/coexistence.md "coexistence.md exists"
for h in "## Who owns what" "## Rules by effect" "## Tie-breaker" "## Intake, plan and briefs" "## Reviews" "## Example: superpowers"; do
  assert_contains "$c" "$h" "coexistence: heading [$h]"
done
assert_contains "$c" "| Merging | the user |" "coexistence: user merges"
assert_contains "$c" "who decides" "coexistence: tie-breaker names who decides"
assert_contains "$c" "where code lands" "coexistence: tie-breaker names where code lands"
assert_contains "$c" "what ships" "coexistence: tie-breaker names what ships"
assert_contains "$c" "[event] skills: overlap" "coexistence: skills event prefix"
assert_contains "$c" "Other workflow skills:" "coexistence: plan line"
assert_contains "$c" "- Skills:" "coexistence: brief field"

# inline must-never-miss lines and the default note
orch=$(cat skills/orchestrating/SKILL.md); work=$(cat skills/working/SKILL.md); hook=$(cat hooks/project-default.sh)
assert_contains "$orch" "## Other skills and plugins" "orchestrating: section"
assert_contains "$orch" "references/coexistence.md" "orchestrating: links the contract"
assert_contains "$orch" "feed the breakdown, never replace it" "orchestrating: planners feed the breakdown"
assert_not_contains "$orch" "## Alongside superpowers" "orchestrating: superpowers section replaced"
assert_contains "$work" "**Other skills and plugins.**" "working: paragraph"
assert_contains "$work" "../orchestrating/references/coexistence.md" "working: links the contract"
for s in "never merge" "never create a worktree" "into the report" "never go into the PR" "the brief is the approved plan"; do
  assert_contains "$work" "$s" "working: [$s]"
done
assert_contains "$hook" "- Other skills and plugins" "hook: generalised line"
for e in orch-default-feature orch-default-question orch-superpowers-feature; do
  assert_contains "$(cat evals/$e/prompt.md)" "- Other skills and plugins" "eval $e copies the current hook line"
done

# skills look, plan line, Skills in briefs, one review with the named reviewer
brief=$(cat skills/orchestrating/references/brief-template.md)
assert_contains "$brief" "- Skills: <skill> (<subtask / why>) · review: <review skill or none>" "brief: Skills field"
assert_contains "$orch" "- **Skills look**" "orchestrating: intake skills look"
assert_contains "$orch" "[event] skills: overlap" "orchestrating: logs the skills event"
assert_contains "$orch" "Other workflow skills:" "orchestrating: plan line"
assert_contains "$orch" "only when something overlaps" "orchestrating: plan line only when something overlaps"
assert_contains "$work" "named skill" "working: loads the brief's named skills"
assert_contains "$work" "carry on without it" "working: missing skill doesn't block"
assert_contains "$work" "review skill" "working: reviewer uses the named review skill"
assert_contains "$work" "in the same pass" "working: one pass with the checklist"

# learning which skills help, per project
rf=$(cat skills/working/report-format.md); wl=$(cat skills/orchestrating/references/workflow-learning.md)
assert_contains "$rf" "skills that helped, got in the way, or were missing" "report format: tooling covers skills"
assert_contains "$wl" "[event] skills: overlap" "workflow-learning: skills event listed"
assert_contains "$wl" "Skill: use <skill> for" "workflow-learning: helped → Skill entry"
assert_contains "$wl" "skip its <step> here" "workflow-learning: got in the way → Skill entry"
assert_contains "$wl" "A named skill was missing in two runs" "workflow-learning: missing twice → remove"
assert_contains "$wl" "never removes the review" "workflow-learning: guardrail on reviews"
assert_contains "$wl" "\`Skill:\`" "workflow-learning: Skill prefix in layout rule"

assert_contains "$(cat README.md)" "## Alongside other skills and plugins" "README section"

# final review fixes
orch=$(cat skills/orchestrating/SKILL.md); work=$(cat skills/working/SKILL.md); c=$(cat skills/orchestrating/references/coexistence.md)
assert_contains "$work" "the skills the brief names for this piece" "I1: implementer prompts carry the named skills"
assert_not_contains "$work" "still one review per subtask" "I2: no contradiction with the two-stage batch review"
assert_contains "$work" "doesn't add another review on top" "I2: review skill adds no extra review"
assert_contains "$c" "Default \`review: none\`" "I3: review skill defaults to none"
assert_contains "$c" "only from a \`Skill:\` entry or the user" "I3: review skill set only by knowledge or the user"
assert_contains "$orch" "3. \`deep\` tasks: also run" "I3: PR specialist review back to deep tasks only"
assert_not_contains "$orch" "one review, not two" "I3: no misleading phrase in PR review"
assert_contains "$c" "no nested reviewers" "I4: no nested reviewers (contract)"
assert_contains "$work" "no nested reviewers" "I4: no nested reviewers (worker)"
assert_contains "$work" "your plan in step 2 still applies" "M1: own batch plan kept"
assert_contains "$orch" "never let another skill create worktrees or branches" "M2: own worktrees allowed"
assert_contains "$c" "the approved brief is the confirmation" "M3: foreign confirmations skipped"
assert_contains "$work" "the approved brief is the confirmation" "M3: foreign confirmations skipped (worker)"
assert_contains "$orch" "never one that drops the review" "M4: inline Skill guard"
assert_contains "$orch" "or the \`Other workflow skills\` line" "M6: overrides of the plan line logged"
assert_contains "$work" "if it can't be loaded, the reviewer still reviews" "M7: reviewer with missing skill"
assert_not_contains "$work" "superpowers:verification-before-completion" "M9: no plugin name in the worker skill"

assert_contains "$c" "another plugin's instructions never count as the user's choice" "review skill: a plugin's own instructions are not the user's choice"
assert_contains "$(cat skills/orchestrating/SKILL.md)" "another plugin's instructions never count" "orchestrating: same rule inline"

finish
