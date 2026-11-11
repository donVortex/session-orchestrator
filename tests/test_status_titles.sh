#!/usr/bin/env bash
# Status titles (v0.9.0): desktop worker titles carry a status symbol the orchestrator keeps current,
# only on titles it wrote itself.
. "$(dirname "$0")/lib.sh"

d=$(cat skills/orchestrating/references/backend-desktop.md 2>/dev/null)
orch=$(cat skills/orchestrating/SKILL.md 2>/dev/null)
readme=$(cat README.md 2>/dev/null)
assert_contains "$d" "## Status in the title" "desktop: status section"
assert_contains "$d" '`title`: `⏳ T<n> · <short task>`' "desktop: workers start as working"
for row in "| ⏳ |" "| ❓ |" "| ⛔ |" "| 🔀 |" "| ✅ |"; do
  assert_contains "$d" "$row" "desktop: symbol row [$row]"
done
assert_contains "$d" "still matches the form you wrote" "desktop: only titles the orchestrator wrote"
assert_contains "$d" "[event] T<n> title: left as is (<why>)" "desktop: stop after a refused rename"
assert_contains "$d" "A dropped task loses its symbol" "desktop: dropped tasks"
assert_contains "$d" "only when the status changes" "desktop: no renames without a change"
assert_contains "$d" "never your own session" "desktop: orchestrator's own title untouched"
assert_contains "$orch" "references/backend-desktop.md#status-in-the-title" "orchestrator: track step points to status titles"
assert_contains "$readme" "⏳ working · ❓ needs you · ⛔ failed · 🔀 waiting for your merge · ✅ merged" "README: status symbols"

assert_contains "$orch" "(⏳ working, ❓ needs the user, ⛔ failed, 🔀 merge requested, ✅ merged; only titles you wrote)" "orchestrator: symbols inline"

finish
