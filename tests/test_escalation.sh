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
assert_contains "$t" "[escalate] T<n> model <from> → <to> (you chose re-tier)" "tiers: re-tier logged"
assert_contains "$t" "The re-tiered round gets one try" "tiers: no loop after a re-tier"
assert_contains "$t" "A task already \`deep\` can't be re-tiered" "tiers: deep tasks re-split instead"
assert_contains "$t" "[escalate] T<n> effort high → xhigh" "tiers: top-tier first step"
assert_contains "$t" "who can re-tier it to \`deep\` ([how](#re-tier))" "tiers: step 3 links the re-tier"

assert_contains "$orch" "(from \`high\`, to \`xhigh\`)" "orchestrator: top-tier send-back"
assert_contains "$orch" "re-tier to \`deep\` (re-split, for a task already \`deep\`)" "orchestrator: deep tasks re-split"
assert_contains "$orch" "references/model-tiers.md#re-tier" "orchestrator: links the re-tier"

assert_contains "$cli" "<message-file> [effort [model]]" "cli: resume takes a model"
assert_contains "$script" "<message-file> [effort [model]]" "script: usage names the model"
assert_contains "$d" "an effort raise, a re-tier" "desktop: re-tier sets working"

for e in worker-native-escalate orch-retier orch-top-tier-escalation; do
  assert_file "evals/$e/prompt.md" "eval $e"
done

finish
