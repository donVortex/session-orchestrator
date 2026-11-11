#!/usr/bin/env bash
# README: how to use the plugin on a project that already exists.
. "$(dirname "$0")/lib.sh"

readme=$(cat README.md 2>/dev/null)

assert_contains "$readme" "### On an existing project" "README: existing-project section"
assert_contains "$readme" "**What it needs from your project:**" "README: what it needs"
assert_contains "$readme" "**What it adds to your repo:**" "README: what it adds"
assert_contains "$readme" "**What stays out of git:**" "README: what stays out of git"
assert_contains "$readme" "**What it never touches:**" "README: what it never touches"
assert_contains "$readme" "**Working in a team:**" "README: teams"
assert_contains "$readme" "**Removing it:**" "README: removal"
assert_contains "$readme" ".git/info/exclude" "README: .orchestration excluded without touching .gitignore"
assert_contains "$readme" "a new session there continues it on its own" "README: resume without a command in projects with knowledge"

# README: what the plugin runs and sends (directory security scan), and where it works
assert_contains "$readme" "## What it runs and sends" "README: disclosure section"
assert_contains "$readme" "ledger-context.sh" "README: names each startup hook"
assert_contains "$readme" "project-default.sh" "README: names each startup hook"
assert_contains "$readme" "plugin-mode.sh" "README: names each startup hook"
assert_contains "$readme" "settings/worker-allowlist.json" "README: discloses the CLI worker permissions"
assert_contains "$readme" "No telemetry" "README: no telemetry"
assert_contains "$readme" "It never changes your permission settings" "README: never changes permission settings"
assert_contains "$readme" "**Works in Claude Code**" "README: Claude Code only"

# README: product knowledge and the expert view (v0.7.0)
assert_contains "$readme" "### Product knowledge and the expert view" "README: expert view section"
assert_contains "$readme" "say \"expert view\"" "README: how to ask for it"
assert_contains "$readme" "general search terms" "README: web fetches disclosed"
assert_not_contains "$readme" "The only connections are your own" "README: network line updated for web fetches"

finish
