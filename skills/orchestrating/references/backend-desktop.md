# Desktop backend

Workers are real Claude desktop app sessions, each in its own git worktree. The user can open, watch and steer them from the sidebar.

## When to use it

Use it when `mcp__ccd_session__start_session` can be loaded (ToolSearch `select:mcp__ccd_session__start_session`). Load the session tools you need in one ToolSearch call: `start_session`, `mcp__ccd_session_mgmt__set_session_model`, `mcp__ccd_session_mgmt__set_session_effort`, `mcp__ccd_session_mgmt__list_sessions`, `mcp__ccd_session_mgmt__get_session`, `mcp__ccd_session_mgmt__set_session_title`, `SendMessage`. Record `Backend: desktop` in the ledger header.

## Starting a worker

1. Write the brief to `.orchestration/briefs/T<n>.md` ([brief-template.md](brief-template.md)) with `Orchestrator: desktop`.
2. `start_session` with:
   - `initiation: "user_asked"` — the user's approval of the breakdown is the instruction to start it
   - `context: "fresh"`, `use_worktree: true`
   - `source_branch`: `orch/base-<base>`, a local helper branch you point at GitHub's latest base right before each start: `git fetch origin <base> && git branch -f orch/base-<base> origin/<base>`. The app can only cut worktrees from a local branch, and the user's own `<base>` may be behind; the helper branch never touches their checkout.
   - `branch_name`: `orch-T<n>` (the app adds its own prefix and suffix)
   - `model` and `effort`: the task tier's **worker session** values from [model-tiers.md](model-tiers.md), set here so they apply to the worker's first turn (setting them after the start only applies from the next turn). `model` takes a full model id, not an alias: use the current id of that family (e.g. `claude-sonnet-5-5` for `sonnet`).
   - `title`: `⏳ T<n> · <short task>` (see [Status in the title](#status-in-the-title))
   - `prompt`: the brief
   - `background` (required, 80+ characters): the orchestration goal in one sentence, how this task fits (what it depends on, what depends on it), and "You are a session-orchestrator worker; the brief is your contract."
3. The app only allows a model and effort **at or below this session's own**. If a tier asks for more (e.g. a `deep` task while you run on sonnet), tell the user before starting it: they can raise this session's model, or accept the lower tier.
4. Ledger: session id, the worktree branch name the start result reports, `running`, and an event line.

Because `source_branch` is the helper branch, workers always start from GitHub's latest base, whatever state the user's own checkout is in; briefs need no reset-to-origin step. Check what a worker started from (`git -C <worktree> log -1`) if in doubt.

Start independent ready tasks in the same turn, up to `max_parallel_workers`.

## While workers run

- The app wakes you when a worker ends a turn. The wake-up note is truncated: read the full report (copied to `.orchestration/reports/T<n>.md`, see below).
- A worker with a question writes its report with `Status: blocked` and a `## Question`, then ends its turn, which wakes you. Answer with `SendMessage` to its `local_…` id if you can; if only the user can decide, ask the user, then forward their answer quoting their words.
- Review fixes go back with `SendMessage` to the same worker.
- Liveness: `list_sessions {"linked": true}` or `get_session`. A worker that ended its turn without a report, or errored, counts as a failure round.
- Never poll or sleep; wait for the app's wake-up.

## Status in the title

Each worker's title starts with a symbol for its status, so the user can see the run at a glance in the sidebar.

| Symbol | Set when |
|---|---|
| ⏳ | the worker starts, or resumes with a follow-up: review fixes, an answer, an effort raise, a re-tier |
| ❓ | it is blocked on a question, or stopped at the review round cap and needs the user to rethink |
| ⛔ | the task failed: a second failed round, or an environment problem that stops it |
| 🔀 | its PR is reviewed and the merge request has gone to the user |
| ✅ | its PR is merged |

- Rename only when the status changes, with the same event that updates the ledger: `<symbol> T<n> · <short task>`, replacing a leading symbol and keeping the rest.
- **Only titles you wrote.** Rename a worker only while its title still matches the form you wrote: an optional status symbol, then `T<n> · `. If the user renamed it, leave it alone for the rest of the run.
- **If a rename is refused** or the app asks the user to approve it, stop renaming that session for the run and log `[event] T<n> title: left as is (<why>)`. Never retry.
- A dropped task loses its symbol.
- Rename workers only, never your own session: the user started it, and the sidebar already shows when it waits for them.
- The CLI backend has no session titles; skip all of this there.

## Reports and permissions

The app blocks workers from writing outside their worktree, so the main checkout's `.orchestration/reports/` is closed to them. The app gives the sessions you start a **shared notes folder** that you and they can both read and write; each worker's session instructions name it. Point the brief's Report path there: `<notes>/T<n>-report.md` (the PR body goes beside it). Until you know the folder's absolute path, write the Report path as "the shared notes folder your session instructions name, file `T<n>-report.md`"; the worker's last line names the path it used, so use that absolute path from the next brief on.

When a report arrives, copy it to `$root/.orchestration/reports/T<n>.md` and work from that copy (copy it again after each fix round). A worker that has no notes folder, or whose write is refused, ends with the full report in its final message: save that to `reports/T<n>.md` yourself.

## When the app refuses a start

The app may refuse `start_session` on a turn it triggered itself (not one started by the user's message). Then:
1. Propose each refused start as a card: `start_session` with `initiation: "own_initiative"` and the same brief.
2. Tell the user in one line that T<n> is waiting for them to click Start.
3. Ledger: `blocked` with the event `needs start click`.

The app also refuses starts in a folder the user hasn't trusted yet. Trusting a folder is the user's decision; you cannot do it. Then:
1. Tell the user, once for all refused tasks, that the app needs them to trust `<repo folder>` before workers can start, and that the briefs are ready.
2. Ledger: `blocked` with the event `needs folder trust`. This is not a failure.
3. When they confirm, retry the same starts.

Mention the folder trust when you show the breakdown for approval, so it doesn't come as a surprise.

## Cleanup

Workers' worktrees belong to their sessions. After the user merges a task's PR, you may offer to archive that session; do it only on the user's yes.
