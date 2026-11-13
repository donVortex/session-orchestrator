#!/usr/bin/env bash
# SessionStart hook: development mode only in the plugin's own checkout (.plugin-dev marker); standalone everywhere else.
. "$(dirname "$0")/lib.sh"

HOOK="$PWD/hooks/plugin-mode.sh"
LINE='[session-orchestrator] development mode'

REPORT='[session-orchestrator] report-only mode'

# run_hook <plugin-root> [env assignments...] — the session's project is the plugin root unless CLAUDE_PROJECT_DIR is passed
run_hook() {
  root=$1; shift
  out=$(env -u ORCH_PLUGIN_MODE -u EVAL_ORCH_PLUGIN_MODE CLAUDE_PLUGIN_ROOT="$root" CLAUDE_PROJECT_DIR="$root" "$@" bash "$HOOK" 2>&1)
  code=$?
}

# marker present → development mode line
d=$(make_tmp); touch "$d/.plugin-dev"; run_hook "$d"
assert_eq 0 "$code" "marker: exit 0"
assert_contains "$out" "$LINE" "marker: development mode line"

# no marker (a GitHub install) → silent
d=$(make_tmp); run_hook "$d"
assert_eq "" "$out" "no_marker: silent (standalone)"

# override for testing → silent even with the marker
d=$(make_tmp); touch "$d/.plugin-dev"; run_hook "$d" ORCH_PLUGIN_MODE=standalone
assert_eq "" "$out" "override: silent (standalone)"

# eval form of the override
d=$(make_tmp); touch "$d/.plugin-dev"; run_hook "$d" EVAL_ORCH_PLUGIN_MODE=standalone
assert_eq "" "$out" "eval_override: silent (standalone)"

# path with a space
d="$(make_tmp)/my plugin"; mkdir -p "$d"; touch "$d/.plugin-dev"; run_hook "$d"
assert_contains "$out" "$LINE" "space: development mode line"

# the plugin from its dev checkout, in another project → report-only, never development mode
d=$(make_tmp); touch "$d/.plugin-dev"; p=$(make_tmp); run_hook "$d" CLAUDE_PROJECT_DIR="$p"
assert_eq 0 "$code" "other_project: exit 0"
assert_contains "$out" "$REPORT" "other_project: report-only line"
assert_not_contains "$out" "$LINE" "other_project: no development mode line"

# a worktree of the plugin's own checkout → development mode (the marker is in the main checkout)
d=$(make_tmp); git -C "$d" init -q && git -C "$d" -c user.email=t@t -c user.name=t commit -q --allow-empty -m init
touch "$d/.plugin-dev"; wt="$(make_tmp)/wt"; git -C "$d" worktree add -q --detach "$wt"
run_hook "$d" CLAUDE_PROJECT_DIR="$wt"
assert_contains "$out" "$LINE" "plugin_worktree: development mode line"

# wired into every SessionStart matcher
hooks=$(cat hooks/hooks.json)
n=$(grep -c 'plugin-mode.sh' hooks/hooks.json)
assert_eq 4 "$n" "hooks_json: plugin-mode.sh on startup, clear, compact and resume"

# the marker never reaches GitHub
assert_contains "$(cat .gitignore)" ".plugin-dev" "gitignore lists .plugin-dev"
assert_eq "" "$(git ls-files .plugin-dev)" ".plugin-dev is not tracked"

finish
