#!/usr/bin/env bash
# Escalation gaps (v0.9.2): how a re-tier runs, the step for tasks already at opus / high,
# and the CLI resume that can switch models.
. "$(dirname "$0")/lib.sh"

t=$(cat skills/orchestrating/references/model-tiers.md 2>/dev/null)
orch=$(cat skills/orchestrating/SKILL.md 2>/dev/null)
cli=$(cat skills/orchestrating/references/backend-cli.md 2>/dev/null)
d=$(cat skills/orchestrating/references/backend-desktop.md 2>/dev/null)
script=$(cat scripts/cli-worker.sh 2>/dev/null)

assert_contains "$t" "### Re-tier" "tiers: re-tier section"
assert_contains "$t" "Keep the same worker session" "tiers: re-tier keeps the session"
assert_contains "$t" '`set_session_model` with the full model id' "tiers: desktop switches the model"
assert_contains "$t" "resume\`'s effort and model arguments" "tiers: CLI switches the model on resume"
assert_contains "$t" "[escalate] T<n> model <model>/<effort> → <model>/<effort> (you chose re-tier)" "tiers: re-tier logged with effort"
assert_contains "$t" "The re-tiered round gets one try" "tiers: no loop after a re-tier"
assert_contains "$t" "A task whose worker session already runs on opus can't be re-tiered" "tiers: opus tasks re-split instead"
assert_contains "$t" "can still be re-tiered" "tiers: a deep task on sonnet can move up"
assert_contains "$t" "[escalate] T<n> effort high → xhigh" "tiers: top-tier first step"
assert_contains "$t" "who can re-tier it to \`deep\` ([how](#re-tier))" "tiers: step 3 links the re-tier"

assert_contains "$orch" "(from opus / \`high\`, to \`xhigh\`)" "orchestrator: top-tier send-back"
assert_contains "$orch" "re-tier to \`deep\` (re-split, for a task already on opus)" "orchestrator: opus tasks re-split"
assert_contains "$orch" "references/model-tiers.md#re-tier" "orchestrator: links the re-tier"
assert_contains "$orch" "switch it to opus with \`set_session_model\`" "orchestrator: re-tier steps inline"
assert_contains "$orch" "[escalate] T<n> model <model>/<effort> → <model>/<effort> (you chose re-tier)" "orchestrator: re-tier log line inline"
assert_contains "$orch" "one try: if it fails, the task is \`failed\` again" "orchestrator: re-tier gets one try"

assert_contains "$cli" "<message-file> [effort [model]]" "cli: resume takes a model"
assert_contains "$cli" "The model only comes after an effort" "cli: model needs an effort"
assert_contains "$script" "<message-file> [effort [model]]" "script: usage names the model"
assert_contains "$d" "an effort raise, a re-tier" "desktop: re-tier sets working"

rv=$(cat skills/orchestrating/references/reviews.md 2>/dev/null)
# review fixes: round-cap path, the app's approval gate, the ledger row
assert_contains "$rv" "re-tier to \`deep\` unless its session already runs on opus" "reviews: round cap re-splits deep tasks"
assert_contains "$t" "after a task's second failure or at the review round cap" "tiers: re-tier covers the round cap"
assert_contains "$t" "**Ledger:** the row's tier becomes \`deep\` and its status \`running\`" "tiers: re-tier updates the ledger row"
assert_contains "$t" "tell the worker its tier is now \`deep\`" "tiers: worker learns its new tier"
assert_contains "$t" "above this session's own, the app asks the user to approve it" "tiers: approval gate stated"
assert_not_contains "$t" "It never sets a model above this session's own" "tiers: no contradictory gate wording"
assert_contains "$t" "[escalate] T<n> effort high (xhigh declined)" "tiers: declined xhigh fallback"
assert_contains "$t" "If the user declines the re-tier's model, the task stays \`failed\`" "tiers: declined re-tier fallback"
assert_contains "$orch" "effort high for a bug with an unknown cause, security or guarded work, medium for design" "orchestrator: re-tier effort values inline"
assert_contains "$orch" "set its ledger row to \`deep\` and \`running\`" "orchestrator: re-tier ledger row inline"

assert_file "evals/orch-retier/graders/4-title.md" "eval orch-retier: title grader"

for e in worker-native-escalate orch-retier orch-top-tier-escalation; do
  assert_file "evals/$e/prompt.md" "eval $e"
done

finish
