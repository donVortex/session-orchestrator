# Model tiers

The single source for which model and effort each piece of work gets. Edit this file to retune; nothing else hard-codes models. Agent files only carry a default `model`, and every caller passes the model from this table explicitly, which overrides that default.

## Tiers

| Tier | Subagent model | Worker session model / effort | Use for |
|---|---|---|---|
| `fast` | sonnet for edits; haiku for read-only work | sonnet / low | renames, boilerplate, docs, mechanical edits; search and lookups |
| `standard` | sonnet | sonnet / medium | features with a clear spec, tests, bugs with a known cause |
| `deep` | opus | opus / medium for design and cross-cutting changes; opus / high for bugs with an unknown cause, security and guarded work | design, cross-cutting changes, migrations and performance work, bugs with an unknown cause, security, reviewing deep work |

- **Subagent model**: the `model` passed on every Agent call for a subtask of this tier.
- **Haiku only reads.** It runs search, lookups, log reading and summaries (`orch-scout`). Every code edit runs on sonnet or above, `fast` subtasks included: a weak edit costs a retry, which is more than the stronger model saves.
- **`deep` effort follows the kind of work.** Design and cross-cutting changes start at medium and climb on a failed round (see [Escalation](#escalation)); bugs with an unknown cause, security and guarded work (security, authentication, money, deleting data, migrations) start at high.
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
| Worker plan | native: the worker writes the pieces itself, subagents only for the four cases | the same |
| Worker reviews | one whole-diff review; per-piece reviews for delegated pieces | one whole-diff review; one combined review (spec and quality in one pass) per delegated piece, never below sonnet |
| Verifying findings | every `critical` or `important` finding, before it goes back | only for guarded work ([reviews.md](reviews.md#verify-before-sending-work-back)) |
| `orch-specialist` review of the PR | every `deep` task | only guarded work (below) |
| Expert view | at planning, for goals that touch the product's field | only on request |
| Knowledge bootstrap | when the project has none | no bootstrap; at wrap-up, say in one line that a full run would set up project knowledge |

**Guarded work keeps the full treatment:** a task or subtask that touches security, authentication, money, deleting data or migrations keeps its planned tier and the `orch-specialist` review, in lite too.

**Escalation is unchanged:** a subtask that fails or returns weak work is retried once on the next tier up, opus included.

**Lite never skips:** tests, lint and build; one PR per task; the plan approval; the user merging; at least one review of every change; the retro and the knowledge diff (kept short); the content rules of project knowledge.

## Session floor

Worker sessions coordinate, plan and review, so they never run below **sonnet**, even for `fast` tasks. Only read-only subagents drop to haiku.

## Roles

| Agent | Role | Typical tiers |
|---|---|---|
| `orch-scout` | read-only search and summaries | `fast` |
| `orch-implementer` | implement one subtask test-first | `fast`, `standard` |
| `orch-specialist` | design, hard debugging, security, code review | `deep` (and reviews of `standard` work when asked) |
| `orch-specialist` (expert mode) | the expert view | opus, in lite too |

## Parallelism caps

```
max_parallel_workers: 4
max_parallel_implementers_per_session: 3
```

- `max_parallel_workers`: worker sessions the orchestrator runs at the same time.
- `max_parallel_implementers_per_session`: implementer subagents one session runs at the same time, for delegated pieces. Read-only scouts and reviews are not counted.

## Escalation

When work fails or comes back weak, climb one step at a time, in this order:

1. **A way to check the work.** If it had no runnable check (a scoped test, a build, a script), give it one and retry on the same tier. A model that can check its own work does far better; often that's the whole fix.
2. **More effort, for worker sessions.** When the orchestrator sends a failed round back to a worker, it first raises that session's effort one step (low → medium → high): desktop with `set_session_effort`, CLI with `resume`'s effort argument. Log it as `[escalate] T<n> effort <from> → <to>`. Above high, effort costs about as much as the next model, so move up a model instead. **Already at high** (a `deep` task on opus / high): there is no model above opus, so the one step left is `xhigh`; log it as `[escalate] T<n> effort high → xhigh`. Subagents have no effort setting, so they skip this step.
3. **The next model up.** A subagent that fails or returns weak work is retried **once** on the next tier up (`fast` → `standard` → `deep`). A worker task that fails a second time goes to the user, who can re-tier it to `deep` ([how](#re-tier)).

Record each step in the retro with the `[tier]` tag: what failed, on which model and effort, and what fixed it. A subagent's second failure is not retried again: the worker reports it to the orchestrator, which counts it toward the task's two-failure limit.

### Re-tier

When the user chooses a re-tier after a task's second failure:

- **Keep the same worker session.** Its worktree, its commits and the record of both failed rounds stay; a new session would have to find them all again.
- **Set the `deep` worker session values:** opus; effort medium for design and cross-cutting changes, high for bugs with an unknown cause, security and guarded work. Desktop: `set_session_model` with the full model id, then `set_session_effort`. CLI: `resume`'s effort and model arguments. Then send what went wrong in both rounds.
- **The app asks the user** to approve the more expensive model. It never sets a model above this session's own ([backend-desktop.md](backend-desktop.md)): if you run below opus, tell the user before trying, as at the start.
- Log it as `[escalate] T<n> model <from> → <to> (you chose re-tier)`.
- **The re-tiered round gets one try.** If it fails, the task is `failed` again, and the user chooses between re-split, `self` and drop.

A task already `deep` can't be re-tiered: its options are re-split, `self` or drop.
