#!/usr/bin/env bash
# Plugin manifest, marketplace and line-ending rules.
. "$(dirname "$0")/lib.sh"

assert_file .claude-plugin/plugin.json "plugin.json exists"
assert_file .claude-plugin/marketplace.json "marketplace.json exists"

plugin=$(cat .claude-plugin/plugin.json 2>/dev/null)
market=$(cat .claude-plugin/marketplace.json 2>/dev/null)
attrs=$(cat .gitattributes 2>/dev/null)

assert_contains "$plugin" '"name": "session-orchestrator"' "plugin name"
assert_contains "$market" '"name": "session-orchestrator"' "marketplace name"
assert_contains "$market" '"source": "./"' "plugin source is the repo root"
assert_contains "$plugin" '"version": "0.6.2"' "plugin version 0.6.2"
readme=$(cat README.md 2>/dev/null)
assert_contains "$readme" "claude plugin marketplace add donVortex/session-orchestrator" "README installs from GitHub"
assert_not_contains "$readme" 'marketplace add D:' "README has no local-path install"
assert_contains "$attrs" '*.sh text eol=lf' "shell scripts forced to LF"
assert_contains "$plugin" '"homepage": "https://github.com/donVortex/session-orchestrator"' "plugin homepage"
assert_file LICENSE "LICENSE file exists"
assert_not_contains "$(cat .claude-plugin/plugin.json README.md CONTRIBUTING.md 2>/dev/null)" "donVortex/claude-orchestrator" "no links to the old repo name"
assert_contains "$(cat LICENSE 2>/dev/null)" "MIT License" "LICENSE is MIT, matching plugin.json"
assert_not_contains "$readme" "repo is private" "README has no private-repo install step"
assert_not_contains "$readme" "gh auth setup-git" "README install needs no git credential setup"

if command -v node >/dev/null 2>&1; then
  for f in .claude-plugin/plugin.json .claude-plugin/marketplace.json; do
    node -e "JSON.parse(require('fs').readFileSync('$f','utf8'))" 2>/dev/null || fail "$f is valid JSON"
  done
fi

if command -v claude >/dev/null 2>&1; then
  validate=$(claude plugin validate . 2>&1) || fail "claude plugin validate ."
  assert_not_contains "$validate" "ICON_MISSING" "directory icon present (validator)"
  assert_contains "$validate" "These checks found nothing to report" "no plugin directory warnings"
else
  echo "SKIP: claude plugin validate (claude CLI not on PATH)"
fi

cmd=$(cat commands/orchestrate.md 2>/dev/null)
assert_contains "$cmd" 'argument-hint: "[lite] <goal>"' "command frontmatter: argument-hint quoted (YAML)"

finish
