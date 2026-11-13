#!/usr/bin/env bash
# SessionStart hook: tells the orchestrator how it may treat plugin lessons at wrap-up.
# - Installs from GitHub have no .plugin-dev marker: standalone, print nothing.
# - The plugin runs from its development checkout (git-ignored .plugin-dev marker):
#   - and this session's project is that checkout (or a worktree of it): "development mode",
#     where wrap-ups may propose plugin edits;
#   - in any other project: "report-only mode", where wrap-ups only report plugin lessons for
#     the plugin's own session and never edit the plugin.
# ORCH_PLUGIN_MODE=standalone (or EVAL_ORCH_PLUGIN_MODE, the only form plugin eval cases may set)
# forces standalone.

[ "${ORCH_PLUGIN_MODE:-${EVAL_ORCH_PLUGIN_MODE:-}}" = "standalone" ] && exit 0
[ -f "${CLAUDE_PLUGIN_ROOT:-}/.plugin-dev" ] || exit 0

dir="${CLAUDE_PROJECT_DIR:-$PWD}"
# A worktree's main checkout holds the git-ignored marker.
if common=$(git -C "$dir" rev-parse --path-format=absolute --git-common-dir 2>/dev/null); then
  dir=$(dirname "$common")
fi

if [ -f "$dir/.plugin-dev" ]; then
  echo "[session-orchestrator] development mode: this is the plugin's development checkout, so wrap-ups may propose plugin edits."
else
  echo "[session-orchestrator] report-only mode: the plugin runs from its development checkout, but this project is not the plugin, so wrap-ups only report plugin lessons and never edit the plugin."
fi
exit 0
