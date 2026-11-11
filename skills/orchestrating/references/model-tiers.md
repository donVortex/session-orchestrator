# Model tiers

The single source for which model and effort each piece of work gets. Edit this file to retune; nothing else hard-codes models. Agent files only carry a default `model`, and every caller passes the model from this table explicitly, which overrides that default.

## Tiers

| Tier | Subagent model | Worker session model / effort | Use for |
|---|---|---|---|
| `fast` | haiku | sonnet / low | search, lookups, renames, boilerplate, docs, mechanical edits |
| `standard` | sonnet | sonnet / medium | features with a clear spec, tests, bugs with a known cause |
| `deep` | opus | opus / high | design, cross-cutting changes, bugs with an unknown cause, security, reviewing deep work |

- **Subagent model**: the `model` passed on every Agent call for a subtask of this tier.
- **Worker session model / effort**: what the orchestrator sets on a worker session (desktop: `set_session_model` + `set_session_effort`; CLI: `--model` + `--effort`) for a task of this tier.
- A task's tier sets its session. Each subtask inside it gets its own tier, so one worker can mix models.
- The orchestrator session keeps whatever model the user started it with.
- A project's `calibration.md` → **Tiers by task type** (`Tier:` entries) refines these per kind of work; it is learned at each wrap-up from the workers' Subtasks tables ([how](workflow-learning.md#findings-to-proposals)).

## Lite mode

For projects and runs where speed matters more than depth: a simple codebase, a small change, a time crunch. The user turns it on; the orchestrator never turns it on by itself.

**Turning it on and off**
- **One run:** the goal or the user says "lite" (`/session-orchestrator:orchestrate lite: <goal>`); "full" forces the normal mode.
- **A project:** a `Mode: lite` entry in `calibration.md` makes every run lite unless the user says "full" (by section or prefix, like other calibration entries).
- **During a run:** the user can say "lite" or "full" at any time. The switch applies to tasks not started yet and to reviews from then on; running workers finish on their current tier. Update the ledger header and log `[event] mode: <lite|full> from T<n> on`.
- The ledger header records the mode (`Mode: full|lite`), so a resumed run keeps it. The plan shows it with its source and how to switch: `Mode: lite (from project knowledge) — say "full" to switch` or `Mode: lite (you asked)`; log it as `[event] mode: <lite|full> (<source>)`.
- If the orchestrator session runs on opus, say once, in the plan, that a sonnet session is cheaper for lite runs (only the user can change it).

**What changes in lite**

| | Full | Lite |
|---|---|---|
| Tiers | as planned | `deep` runs as `standard` (sonnet subagents, sonnet / medium session); `fast` unchanged |
| Split | PR-sized tasks | as few tasks as the work allows: one PR per coherent change, not one per layer |
| Placement | per [splitting.md](splitting.md#placement) | small and sequential tasks as `self`; `worker` only for tasks too big for this session or ones that should run in parallel |
| Worker plan | batch loop, or the small-task path for one subtask | the small-task path whenever the task fits one subtask |
| Subtask reviews | spec review, then code-quality review | one combined review (spec and quality in one pass), never below sonnet |
| Verifying findings | every `critical` or `important` finding, before it goes back | only for guarded work ([reviews.md](reviews.md#verify-before-sending-work-back)) |
| `orch-specialist` review of the PR | every `deep` task | only guarded work (below) |
| Knowledge bootstrap | when the project has none | no bootstrap; at wrap-up, say in one line that a full run would set up project knowledge |

**Guarded work keeps the full treatment:** a task or subtask that touches security, authentication, money, deleting data or migrations keeps its planned tier and the `orch-specialist` review, in lite too.

**Escalation is unchanged:** a subtask that fails or returns weak work is retried once on the next tier up, opus included.

**Lite never skips:** tests, lint and build; one PR per task; the plan approval; the user merging; at least one review of every change; the retro and the knowledge diff (kept short); the content rules of project knowledge.

## Session floor

Worker sessions coordinate, plan and review, so they never run below **sonnet**, even for `fast` tasks. Only the subagents doing the work drop to haiku.

## Roles

| Agent | Role | Typical tiers |
|---|---|---|
| `orch-scout` | read-only search and summaries | `fast` |
| `orch-implementer` | implement one subtask test-first | `fast`, `standard` |
| `orch-specialist` | design, hard debugging, security, code review | `deep` (and reviews of `standard` work when asked) |

## Parallelism caps

```
max_parallel_workers: 4
max_parallel_implementers_per_session: 3
```

- `max_parallel_workers`: worker sessions the orchestrator runs at the same time.
- `max_parallel_implementers_per_session`: implementer subagents one session runs at the same time. Read-only scouts and reviews are not counted.

## Escalation

1. A subagent that fails, or returns weak work, is retried **once** on the next tier up (`fast` → `standard` → `deep`).
2. Record it in the retro with the `[tier]` tag: what failed, on which model, what fixed it.
3. A second failure is not retried again: the worker reports it to the orchestrator, which counts it toward the task's two-failure limit.
