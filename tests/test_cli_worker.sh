#!/usr/bin/env bash
# CLI worker launcher: worktree handling and the claude command it builds.
. "$(dirname "$0")/lib.sh"

CW="$PWD/scripts/cli-worker.sh"
export CLAUDE_BIN="$PWD/tests/stub-claude.sh"
chmod +x "$CLAUDE_BIN"

new_repo() {
  mkdir -p "$1"
  git -C "$1" init -q -b main
  git -C "$1" config core.autocrlf false
  echo hi > "$1/f"
  git -C "$1" add f
  git -C "$1" -c user.name=t -c user.email=t@t commit -qm init
}

# Resolves a directory to its git top level, so bash-style and Windows-style paths compare equal.
toplevel() {
  git -C "$1" rev-parse --show-toplevel 2>/dev/null
}

# Value of the argument that follows <flag> in the stub log.
arg_after() {
  grep -A1 "^ARG=$1\$" "$STUB_LOG" | sed -n '2p' | sed 's/^ARG=//'
}

# cw <repo> <args...>: runs the launcher from inside <repo>; sets out, code.
cw() {
  r=$1; shift
  out=$(cd "$r" && bash "$CW" "$@" 2>/dev/null < /dev/null)
  code=$?
}

setup() {
  base=$(make_tmp)
  repo="$base/${1:-repo}"
  new_repo "$repo"
  export STUB_LOG="$base/stub.log"
  : > "$STUB_LOG"
  printf 'Implement T1: the brief text\n' > "$base/brief.md"
}

check_started() {
  label=$1
  wt="$repo-wt/T1"
  assert_eq 0 "$code" "$label: exit 0"
  [ -d "$wt" ] || fail "$label: worktree dir created"
  assert_eq "orch/T1" "$(git -C "$wt" rev-parse --abbrev-ref HEAD 2>/dev/null)" "$label: on branch orch/T1"
  assert_contains "$out" '"session_id":"s-1"' "$label: stdout is claude's JSON"
  log=$(cat "$STUB_LOG")
  stub_pwd=$(grep -m1 '^PWD=' "$STUB_LOG" | sed 's/^PWD=//')
  assert_eq "$(toplevel "$wt")" "$(toplevel "$stub_pwd")" "$label: claude runs in the worktree"
  assert_contains "$log" "ARG=-p" "$label: -p"
  assert_contains "$log" "STDIN=Implement T1: the brief text" "$label: brief arrives on stdin"
  assert_not_contains "$log" "ARG=Implement T1" "$label: brief is not an argument"
  assert_contains "$(arg_after --add-dir)" "/.orchestration" "$label: state dir added for the report"
  [ -d "$repo/.orchestration/reports" ] || fail "$label: reports dir exists in the main checkout"
  assert_eq "sonnet" "$(arg_after --model)" "$label: model"
  assert_eq "medium" "$(arg_after --effort)" "$label: effort"
  assert_eq "json" "$(arg_after --output-format)" "$label: output format"
  assert_eq "acceptEdits" "$(arg_after --permission-mode)" "$label: permission mode"
  assert_contains "$(arg_after --settings)" "worker-allowlist.json" "$label: allowlist settings"
  assert_not_contains "$log" "bypassPermissions" "$label: never bypass"
  assert_eq "PowerShell" "$(arg_after --disallowedTools)" "$label: PowerShell tool off (allow rules are Bash rules)"
  assert_contains "$log" "ORCH_ROLE=worker" "$label: worker role set (project-default hook stays silent)"
  if command -v cygpath >/dev/null 2>&1; then
    gb=$(grep -m1 '^GIT_BASH_PATH=' "$STUB_LOG" | sed 's/^GIT_BASH_PATH=//')
    [ -n "$gb" ] || fail "$label: Git Bash path set for the worker on Windows"
    [ -n "$gb" ] && { [ -f "$(cygpath -u "$gb")" ] || fail "$label: Git Bash path exists ($gb)"; }
  fi
}

# start_creates_worktree
setup
cw "$repo" start T1 main sonnet medium "$base/brief.md"
check_started start_creates_worktree

# start_rejects_bad_id
setup
cw "$repo" start ../x main sonnet medium "$base/brief.md"
assert_eq 2 "$code" "start_rejects_bad_id: exit 2"
[ -e "$repo-wt" ] && fail "start_rejects_bad_id: nothing created"

# start_missing_base
setup
cw "$repo" start T1 nope sonnet medium "$base/brief.md"
assert_eq 3 "$code" "start_missing_base: exit 3"
[ -e "$repo-wt/T1" ] && fail "start_missing_base: no worktree"

# start_reuses_existing_worktree
setup
cw "$repo" start T1 main sonnet medium "$base/brief.md"
cw "$repo" start T1 main sonnet medium "$base/brief.md"
assert_eq 0 "$code" "start_reuses_existing_worktree: second start exit 0"
assert_eq 2 "$(git -C "$repo" worktree list | wc -l | tr -d ' ')" "start_reuses_existing_worktree: one task worktree"

# start_reuses_branch_without_worktree
setup
git -C "$repo" branch orch/T1
cw "$repo" start T1 main sonnet medium "$base/brief.md"
assert_eq 0 "$code" "start_reuses_branch: exit 0"
assert_eq "orch/T1" "$(git -C "$repo-wt/T1" rev-parse --abbrev-ref HEAD 2>/dev/null)" "start_reuses_branch: on orch/T1"

# start_rejects_foreign_dir
setup
mkdir -p "$repo-wt/T1"
cw "$repo" start T1 main sonnet medium "$base/brief.md"
assert_eq 4 "$code" "start_rejects_foreign_dir: exit 4"

# start_in_path_with_space
setup "my repo"
cw "$repo" start T1 main sonnet medium "$base/brief.md"
check_started start_in_path_with_space

# start_from_subdirectory
setup
mkdir -p "$repo/sub"
cw "$repo/sub" start T1 main sonnet medium "$base/brief.md"
assert_eq 0 "$code" "start_from_subdirectory: exit 0"
[ -d "$repo-wt/T1" ] || fail "start_from_subdirectory: worktree next to the repo root"

# resume_runs_in_worktree
setup
cw "$repo" start T1 main sonnet medium "$base/brief.md"
: > "$STUB_LOG"
printf 'Answer: use 404\n' > "$base/msg.txt"
cw "$repo" resume T1 s-1 "$base/msg.txt"
assert_eq 0 "$code" "resume_runs_in_worktree: exit 0"
stub_pwd=$(grep -m1 '^PWD=' "$STUB_LOG" | sed 's/^PWD=//')
assert_eq "$(toplevel "$repo-wt/T1")" "$(toplevel "$stub_pwd")" "resume_runs_in_worktree: in worktree"
assert_eq "s-1" "$(arg_after --resume)" "resume_runs_in_worktree: --resume id"
assert_contains "$(cat "$STUB_LOG")" "STDIN=Answer: use 404" "resume_runs_in_worktree: message arrives on stdin"
assert_contains "$(arg_after --add-dir)" "/.orchestration" "resume_runs_in_worktree: state dir added"

# resume_with_effort
: > "$STUB_LOG"
cw "$repo" resume T1 s-1 "$base/msg.txt" high
assert_eq 0 "$code" "resume_with_effort: exit 0"
assert_eq "high" "$(arg_after --effort)" "resume_with_effort: --effort passed"

# resume_without_effort
: > "$STUB_LOG"
cw "$repo" resume T1 s-1 "$base/msg.txt"
assert_eq "" "$(arg_after --effort)" "resume_without_effort: no --effort"

# resume_with_model: a re-tier switches the model on the same conversation
: > "$STUB_LOG"
cw "$repo" resume T1 s-1 "$base/msg.txt" high opus
assert_eq 0 "$code" "resume_with_model: exit 0"
assert_eq "high" "$(arg_after --effort)" "resume_with_model: --effort passed"
assert_eq "opus" "$(arg_after --model)" "resume_with_model: --model passed"
assert_eq "s-1" "$(arg_after --resume)" "resume_with_model: same conversation"

# resume_without_model
: > "$STUB_LOG"
cw "$repo" resume T1 s-1 "$base/msg.txt" high
assert_eq "" "$(arg_after --model)" "resume_without_model: no --model"

# resume_too_many_args
cw "$repo" resume T1 s-1 "$base/msg.txt" high opus extra
assert_eq 2 "$code" "resume_too_many_args: exit 2"

# resume_message_starting_with_dash
setup
cw "$repo" start T1 main sonnet medium "$base/brief.md"
: > "$STUB_LOG"
printf -- '- fix the null check\n--dangerously-skip-permissions\n' > "$base/msg.txt"
cw "$repo" resume T1 s-1 "$base/msg.txt"
assert_eq 0 "$code" "resume_dash_message: exit 0"
assert_contains "$(cat "$STUB_LOG")" "STDIN=- fix the null check" "resume_dash_message: message on stdin"
assert_not_contains "$(cat "$STUB_LOG")" "ARG=- fix" "resume_dash_message: not parsed as an option"
assert_not_contains "$(cat "$STUB_LOG")" "ARG=--dangerously-skip-permissions" "resume_dash_message: no flag injection"

# start_after_worktree_dir_deleted
setup
cw "$repo" start T1 main sonnet medium "$base/brief.md"
rm -rf "$repo-wt/T1"
cw "$repo" start T1 main sonnet medium "$base/brief.md"
assert_eq 0 "$code" "start_after_dir_deleted: exit 0"
assert_eq "orch/T1" "$(git -C "$repo-wt/T1" rev-parse --abbrev-ref HEAD 2>/dev/null)" "start_after_dir_deleted: worktree recreated"
assert_eq "acceptEdits" "$(arg_after --permission-mode)" "resume_runs_in_worktree: permission mode"

# resume_without_worktree
setup
printf 'x\n' > "$base/msg.txt"
cw "$repo" resume T1 s-1 "$base/msg.txt"
assert_eq 5 "$code" "resume_without_worktree: exit 5"

# start_uses_fresh_origin_base: local main is behind origin; the task starts from origin's newest commit
setup
git clone -q --bare "$repo" "$base/remote.git"
git -C "$repo" remote add origin "$base/remote.git"
git -C "$repo" fetch -q origin
git clone -q "$base/remote.git" "$base/other"
git -C "$base/other" -c user.name=t -c user.email=t@t commit -q --allow-empty -m "newer on origin"
git -C "$base/other" push -q origin HEAD:main
newest=$(git -C "$base/remote.git" rev-parse main)
[ "$(git -C "$repo" rev-parse main)" != "$newest" ] || fail "start_uses_fresh_origin_base: fixture has a stale local main"
cw "$repo" start T1 main sonnet medium "$base/brief.md"
assert_eq 0 "$code" "start_uses_fresh_origin_base: exit 0"
assert_eq "$newest" "$(git -C "$repo-wt/T1" rev-parse HEAD 2>/dev/null)" "start_uses_fresh_origin_base: worktree starts at origin/main"

# remove_deletes_worktree
setup
cw "$repo" start T1 main sonnet medium "$base/brief.md"
cw "$repo" remove T1
assert_eq 0 "$code" "remove_deletes_worktree: exit 0"
[ -e "$repo-wt/T1" ] && fail "remove_deletes_worktree: dir gone"
git -C "$repo" show-ref --verify --quiet refs/heads/orch/T1 || fail "remove_deletes_worktree: branch kept"

# usage
setup
cw "$repo" start T1
assert_eq 2 "$code" "usage: wrong arg count exits 2"
cw "$repo" frobnicate
assert_eq 2 "$code" "usage: unknown command exits 2"

# allowlist
allow=$(cat settings/worker-allowlist.json 2>/dev/null)
assert_contains "$allow" '"allow"' "allowlist: has allow rules"
assert_contains "$allow" 'Bash(gh pr create *)' "allowlist: gh pr create"
assert_contains "$allow" 'Bash(gh pr diff *)' "allowlist: gh pr diff"
assert_not_contains "$allow" 'Bash(git push *)' "allowlist: no blanket git push"
assert_not_contains "$allow" '"Write"' "allowlist: no blanket Write (acceptEdits scopes edits to the worktree)"
assert_not_contains "$allow" '"Edit"' "allowlist: no blanket Edit"

# keeps_existing_git_bash_path
setup
CLAUDE_CODE_GIT_BASH_PATH='X:\custom\bash.exe' cw "$repo" start T1 main sonnet medium "$base/brief.md"
assert_eq 'X:\custom\bash.exe' "$(grep -m1 '^GIT_BASH_PATH=' "$STUB_LOG" | sed 's/^GIT_BASH_PATH=//')" "keeps_existing_git_bash_path: user's setting wins"
assert_contains "$allow" 'Bash(git push -u origin HEAD:orch/*)' "allowlist: push to orch/ branches"
assert_contains "$allow" '"deny"' "allowlist: has deny rules"
assert_contains "$allow" 'Bash(git push --force*)' "allowlist: denies force push"
assert_contains "$allow" 'Bash(git push *:main*)' "allowlist: denies pushing to main"
assert_contains "$allow" '"Skill"' "allowlist: workers may load skills"
assert_contains "$allow" '"Agent"' "allowlist: workers may run subagents"
if command -v node >/dev/null 2>&1; then
  node -e "JSON.parse(require('fs').readFileSync('settings/worker-allowlist.json','utf8'))" 2>/dev/null || fail "allowlist: valid JSON"
fi

finish
