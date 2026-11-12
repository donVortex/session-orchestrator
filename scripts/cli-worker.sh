#!/usr/bin/env bash
# CLI backend for session-orchestrator: runs a worker as headless `claude -p` in its own worktree.
#   cli-worker.sh start  <task-id> <base-branch> <model> <effort> <brief-file>
#   cli-worker.sh resume <task-id> <session-id> <message-file> [effort [model]]
#   cli-worker.sh remove <task-id>
# Run from anywhere inside the main checkout. Worktree: <repo-root>-wt/<task-id>, branch orch/<task-id>.
# Stdout is claude's JSON result (with session_id); progress goes to stderr.
# Exit: 1 git failure, 2 usage or invalid id, 3 base branch not found,
#       4 directory exists but is not this task's worktree, 5 no worktree (resume/remove);
#       otherwise claude's exit code.
# Env: CLAUDE_BIN (default: claude), ORCH_ALLOWLIST (default: ../settings/worker-allowlist.json).

script_dir=$(cd "$(dirname "$0")" && pwd)
CLAUDE_BIN="${CLAUDE_BIN:-claude}"
ORCH_ALLOWLIST="${ORCH_ALLOWLIST:-$script_dir/../settings/worker-allowlist.json}"

die() {
  echo "cli-worker: $2" >&2
  exit "$1"
}

usage() {
  sed -n '3,5p' "$0" | sed 's/^# //' >&2
  exit 2
}

# Sets root (main checkout), dir (task worktree) and branch for a task id.
locate() {
  printf '%s' "$1" | grep -Eq '^[A-Za-z0-9][A-Za-z0-9_-]*$' || die 2 "invalid task id: $1"
  common=$(git rev-parse --path-format=absolute --git-common-dir 2>/dev/null) || die 2 "not inside a git repository"
  root=$(dirname "$common")
  dir="$root-wt/$1"
  branch="orch/$1"
  effort_file="$root/.orchestration/effort/$1"
}

# claude -p doesn't keep a session's effort: a resume without --effort runs at its default.
# So the launcher saves the last effort it was given for a task and re-sends it on a plain resume.
save_effort() {
  mkdir -p "$(dirname "$effort_file")" && printf '%s
' "$1" > "$effort_file" ||
    echo "cli-worker: could not save the effort for later resumes" >&2
}

# Echoes the saved effort, or nothing (a task started by an older launcher has none).
saved_effort() {
  [ -r "$effort_file" ] || return 0
  head -n 1 "$effort_file" | tr -d '' | grep -E '^[a-z]+$'
}

is_task_worktree() {
  [ -d "$dir" ] && [ "$(git -C "$dir" rev-parse --abbrev-ref HEAD 2>/dev/null)" = "$branch" ]
}

# Echoes the absolute path of a readable file, or exits 2.
abs_file() {
  [ -r "$1" ] || die 2 "file not readable: $1"
  echo "$(cd "$(dirname "$1")" && pwd)/$(basename "$1")"
}

# run_claude <prompt-file> <args...>: the prompt goes in on stdin, so text starting with "-"
# is never parsed as an option and long briefs avoid command-line length limits.
# --add-dir lets the worker write its report to the main checkout's .orchestration/.
run_claude() {
  prompt_file=$1; shift
  state="$root/.orchestration"
  mkdir -p "$state/reports" || die 1 "cannot create $state/reports"
  cd "$dir" || die 1 "cannot enter $dir"
  use_git_bash
  export ORCH_ROLE=worker   # keeps the project-default hook from telling a worker to orchestrate
  # The allowlist's shell rules are Bash(...) rules; PowerShell would match none of them.
  exec "$CLAUDE_BIN" -p "$@" --output-format json --permission-mode acceptEdits \
    --settings "$ORCH_ALLOWLIST" --add-dir "$state" --disallowedTools PowerShell < "$prompt_file"
}

# On Windows, claude started from inside Git Bash can fail to find Git Bash (it picks up
# Git's ucrt64\bin\git.exe first) and then offers only PowerShell. Point it at Git Bash,
# unless the user already set CLAUDE_CODE_GIT_BASH_PATH.
use_git_bash() {
  [ -z "${CLAUDE_CODE_GIT_BASH_PATH:-}" ] || return 0
  command -v cygpath >/dev/null 2>&1 || return 0
  git_root=$(cygpath -w /)
  git_root=${git_root%\\}
  for candidate in "$git_root\\bin\\bash.exe" "$git_root\\usr\\bin\\bash.exe"; do
    if [ -f "$(cygpath -u "$candidate")" ]; then
      export CLAUDE_CODE_GIT_BASH_PATH="$candidate"
      return 0
    fi
  done
}

# Echoes where a new task branch starts: the freshly fetched origin/<base> when the repo has an
# origin and the fetch works, so a stale local base never leaks in; otherwise the local <base>.
start_point() {
  if git -C "$root" remote get-url origin >/dev/null 2>&1 &&
    git -C "$root" fetch --quiet origin "$1" >/dev/null 2>&1 &&
    git -C "$root" rev-parse --verify --quiet "refs/remotes/origin/$1^{commit}" >/dev/null; then
    echo "origin/$1"
  else
    git -C "$root" remote get-url origin >/dev/null 2>&1 &&
      echo "cli-worker: could not fetch origin/$1; starting from local $1" >&2
    echo "$1"
  fi
}

cmd_start() {
  [ $# -eq 5 ] || usage
  locate "$1"
  base=$2 model=$3 effort=$4
  brief=$(abs_file "$5") || exit 2

  git -C "$root" worktree prune
  if [ -e "$dir" ]; then
    is_task_worktree || die 4 "$dir exists but is not the worktree for $branch"
    echo "cli-worker: reusing $dir" >&2
  elif git -C "$root" show-ref --verify --quiet "refs/heads/$branch"; then
    git -C "$root" worktree add "$dir" "$branch" >&2 || die 1 "git worktree add failed"
  else
    start=$(start_point "$base")
    git -C "$root" rev-parse --verify --quiet "$start^{commit}" >/dev/null || die 3 "base branch not found: $base"
    git -C "$root" worktree add -b "$branch" "$dir" "$start" >&2 || die 1 "git worktree add failed"
  fi

  save_effort "$effort"
  run_claude "$brief" --model "$model" --effort "$effort"
}

cmd_resume() {
  [ $# -ge 3 ] && [ $# -le 5 ] || usage
  locate "$1"
  message=$(abs_file "$3") || exit 2
  is_task_worktree || die 5 "no worktree for $1 at $dir"
  [ $# -ge 4 ] && save_effort "$4"
  if [ $# -eq 5 ]; then
    run_claude "$message" --resume "$2" --effort "$4" --model "$5"
  elif [ $# -eq 4 ]; then
    run_claude "$message" --resume "$2" --effort "$4"
  else
    effort=$(saved_effort)
    if [ -n "$effort" ]; then
      run_claude "$message" --resume "$2" --effort "$effort"
    else
      run_claude "$message" --resume "$2"
    fi
  fi
}

cmd_remove() {
  [ $# -eq 1 ] || usage
  locate "$1"
  is_task_worktree || die 5 "no worktree for $1 at $dir"
  git -C "$root" worktree remove "$dir" >&2 || die 1 "git worktree remove failed (uncommitted changes in $dir?)"
  rm -f "$effort_file"
}

command=${1:-}
[ $# -gt 0 ] && shift
case "$command" in
  start) cmd_start "$@" ;;
  resume) cmd_resume "$@" ;;
  remove) cmd_remove "$@" ;;
  *) usage ;;
esac
