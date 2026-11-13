# Workflow learning

Project knowledge makes you expert in the project's domain. Workflow learning makes you better at **how work gets done** there: each kind of task should need less of the user's attention and less rework over time, with the same output. You measure both from the ledger, and turn what you find into proposals in the knowledge diff. Everything lands in the project's `calibration.md` (or `review-checklist.md`), and only through the approved knowledge PR.

## Event kinds

Every line in the ledger's Events list starts with one of these tags:

| Tag | Counts toward | Log it when |
|---|---|---|
| `[ask-user]` | attention | you ask the user something you need answered (interview, product decision, a worker question you forward). **One line per question:** `[ask-user] <question> → <answer>`; add `→ <answer>` to that same line when it comes, never a second line. |
| `[approval]` | attention | the user must approve something beyond the expected stops: a re-split, a scope change, a tier above your own model |
| `[prompt]` | attention | the user hits a permission prompt or a folder-trust stop **mid-run**, unannounced |
| `[start-click]` | attention | a refused worker start becomes a card the user must click |
| `[failed]` | rework | a round fails because of the work: broken code, red tests or CI, a worker error, no report |
| `[changes]` | rework | review sends work back as changes requested |
| `[escalate]` | rework | a tier escalation, or you take a task over as `self` |
| `[worker-q]` | rework | a worker blocks with a question to you |
| `[env]` | — (feeds pre-flight) | a round lost to the environment, not the work: missing tool or login, permissions, an untrusted folder, a stale branch. Not a failure, not rework. |
| `[expert]` | — | an expert view ran, and each recommendation the user declined ([expert-view.md](expert-view.md#adopt-and-decline)) |
| `[event]` | — | everything else: started, report received, merge requested, merged, archived |

**Expected stops are `[event]`, not `[approval]`:** the one breakdown approval, each merge request, and the knowledge-diff approval.

**Lines the learning depends on**, all `[event]`, written with these exact prefixes so a resumed or later run can read them:
- `[event] pre-flight: <what you asked or checked up front>` — an up-front pre-flight ask is planned, not an interruption;
- `[event] T<n> following recipe: <name>` — at the approval gate, per matched task;
- `[event] assumed default: <default>` — at the approval gate, per default relied on;
- `[event] user overrode default: <default> → <what they chose>`;
- `[changes] T<n> round <k>: <count line>` — each review round that sends work back ([reviews.md](reviews.md#rounds));
- `[event] T<n> findings: fixed <n>, refuted <n>, answered <n>, pre-existing <n>, minor <n>` — when a task's PR is reviewed ([reviews.md](reviews.md#finding-outcomes));
- `[event] base check: green @ <sha>` and `[failed] base red after merging T<n>, T<m>` — after merges ([reviews.md](reviews.md#check-the-base-branch-after-merges));
- `[event] rule change: <old> → <new>` — at the approval gate, per project rule the goal changes ([knowledge.md](knowledge.md#rule-changes));
- `[event] stale entry: <entry, shortened> (<what's missing>)` — at intake ([knowledge.md](knowledge.md#stale-entries));
- `[event] knowledge used: <entries, shortened>` — at wrap-up, and `[event] knowledge kept: <entry, shortened>` per removal the user declined ([knowledge.md](knowledge.md#pruning));
- `[event] examples: <n> given, read as: <properties, shortened>` or `[event] examples: skipped` — at intake ([examples.md](examples.md#reading-them));
- `[event] skills: overlap <name> (<stage>); fit <names>` — at intake, from the skills look ([coexistence.md](coexistence.md#intake-plan-and-briefs)).

Add the task id after the tag when an event belongs to one task: `[failed] T2 tests red on the PR head`.

## Counts table

At wrap-up, count the tags per task and for the whole run. Write the full table to `.orchestration/counts.md`; in your message show only the `run` row and the rows of tasks with any non-zero count, and link the file:

```markdown
| task | recipe | ask-user | approval | prompt | start-click | failed | changes | escalate | worker-q | findings | compacted |
|------|--------|----------|----------|--------|-------------|--------|---------|----------|----------|----------|-----------|
| T1   | Money helper | 0 | 0 | 1 | 0 | 0 | 0 | 0 | 0 | 0 | 0 |
| run  |        | 1 | 0 | 1 | 0 | 0 | 0 | 0 | 0 | 0 | 0 |
```

The `run` row is the total over all events; events with no task id (intake, the interview) appear only there. Attention is the sum of ask-user, approval, prompt and start-click; rework the sum of failed, changes, escalate and worker-q. **findings** counts the `critical` and `important` findings of the orchestrator's PR review of the task; **compacted** is 1 when the task's Work line says `compacted: yes`. A task whose report has no Work line (an older worker) shows `—` in `compacted`, not 0; its `findings` still count, since they come from your own PR review. The recipe column comes from the `following recipe:` lines.

If the ledger has untagged lines (an orchestration started before tags existed and resumed after), say the counts are partial, and propose no recipe or track-record update from them.

### Native vs before

Workers write their pieces themselves since v0.8.0. The baseline is the project's archived runs from before that (their workers' reports have no Work line). When a baseline exists, show one line after the counts, each value averaged per task:

`Native vs before (per task): PR findings <a> → <b> · rework <a> → <b> · compacted <a> → <b> of <n> · subagents <a> → <b>`

Where each value comes from, on both sides:
- PR findings come from the ledgers' `findings:` lines of your PR reviews (since v0.6.0); a run without them gives `n/a`.
- **rework** from the counts table (or the archived ledger's tags).
- **compacted before is always `n/a`**: it wasn't measured before native workers.
- **subagents counts the delegated pieces**: before, the old reports' Subtasks rows; now, the Subtasks rows a subagent did. Both are pieces of work done by a subagent: the same unit on both sides, so compare them. Scouts and reviews aren't counted on either side, since old runs didn't record them.
- Never fill a missing value with an estimate: write `n/a`.

With no archived run from before, show no comparison line: there is nothing to compare with. The `Worker plan:` proposals need no baseline from before: two runs with native workers are enough. A run that mixed older and native workers (one updated mid-run) counts on neither side. Tasks whose Work line says `self` count in the run's totals but not in the comparison or the `Worker plan:` proposals: they measure your session, not a worker's.

## Recipes

A recipe is a proven way to do one kind of task in this project, kept in `calibration.md` → Recipes:

```markdown
- **Money helper** (`src/money/<fn>.js`): one worker, `standard`, native; brief quotes the number-argument and display rules, names `format.js` as style reference, folds the barrel line in. Last 2 runs: 0 attention, 0 rework. _(T1 / PR #10; T4 / PR #12)_
```

- **Match by area and kind of change.** At breakdown, match each task to at most one recipe. A task in the same area but of a different kind (an export instead of a helper) has no recipe.
- **Track record:** the last runs' attention and rework totals, updated at wrap-up.
- **Same output is the bar.** Propose, change or credit a recipe only for tasks that passed review with the same acceptance criteria and checklist.

## Findings to proposals

At wrap-up, compare each task's counts with its recipe (or with zero if it had none). Turn each cause into **one** concrete proposal in the knowledge diff, with its source:

| Finding | Proposal | Lands in |
|---|---|---|
| The user was asked the same question and gave the same answer in two or more runs (this ledger's `[ask-user]` lines against the archived ledgers' `[ask-user]` lines) — except bootstrap interview questions (their answers belong in `domain.md`), the plugin's own confirmations (merges, branch deletion, the bootstrap offer, the knowledge diff), and any answer that decides safety, data handling, money or a destructive action ([what counts](#guardrails)) | A **learned default**: "<answer> unless told otherwise" | `calibration.md` → Learned defaults |
| A stall from the environment: a `[prompt]`, a `[start-click]`, or an `[env]` round | A **pre-flight check** for intake, with what to tell the user up front | `calibration.md` → Pre-flight |
| A `[failed]`, `[changes]` or `[worker-q]` caused by the work or the brief | A **brief rule** (what the worker needed to be told) or a **checklist item** (what review should catch earlier) | `calibration.md` → Briefs need, or `review-checklist.md` |
| A task with zero rework and no attention except product decisions that this same diff records as `domain.md` rules, of a kind with no recipe | A **new recipe** | `calibration.md` → Recipes |
| More PR findings or rework than the baseline for the same kind of work in the same area, in two runs with native workers. The baseline is the area's own tasks of that kind from before native workers, or else the project's average per task from before native workers; in a project that started with native workers, the project's average per task across its runs. Never the area's own earlier native runs: those are what is being judged. This proposal comes before a brief rule or checklist item for the same findings: propose the `Worker plan:` entry, and add those only as well, never instead | `Worker plan: per-piece reviews for <kind> in <area>` | `calibration.md` → Tiers by task type (or where `Tier:` entries live) |
| A worker compacted on the same kind of work in the same area, in two runs | `Worker plan: subagents for <kind> in <area>` | `calibration.md`, next to the `Tier:` entries |
| A task that followed its recipe and did as well or better | Update the recipe's track record | `calibration.md` → Recipes |
| A task that did clearly worse than its recipe | The cause, and a fix to the recipe or the brief | as above |
| A skill helped on a task that passed with no rework (a `[tooling]` retro point) | `Skill: use <skill> for <area / kind of task>`; also add it to a matching recipe's must-haves | `calibration.md` → Skills |
| A skill got in the way: it caused rework, a failure, or a step the worker skipped | `Skill: <skill> — skip its <step> here`, or `Skill: don't use <skill> for <kind of task>` | `calibration.md` → Skills |
| An overlapping workflow skill was handled (the `Other workflow skills:` line) and the user didn't override it | `Skill: <skill> — <used for>; <replaced steps>`, shown as Assumed next run | `calibration.md` → Skills |
| A hook or plugin blocked something (e.g. `git push`), logged as `[env]` | A **pre-flight check**, not a `Skill:` entry | `calibration.md` → Pre-flight |
| A named skill was missing in two runs (`[tooling]` "not available" points in this and archived retros) | Remove its `Skill:` entry | `calibration.md` → Skills |
| A subtask escalated, or a `[tier]` point says the model was too weak (the report's Subtasks table and its retro) | `Tier: <kind of subtask> in <area> is <tier>`, one tier above the one that failed | `calibration.md` → Tiers by task type |
| A subtask passed on the first try with at most minor review findings, for the same kind of subtask in two runs (this run's Subtasks tables and the archived reports'; a `[tier]` "more than needed" point counts as one run) | `Tier: <kind of subtask> in <area> is <tier>`, one tier down, never below `fast` for subagents ([guardrail](#guardrails)) | `calibration.md` → Tiers by task type |
| A subtask on a tier lowered by a `Tier:` entry escalated | Raise the entry back to the tier it had before | `calibration.md` → Tiers by task type |
| The user chose lite mode for this project in two runs (`[event] mode: lite (you asked)` in this and the archived ledgers) | `Mode: lite` — every run is lite unless the user says "full" | `calibration.md` → Mode |
| The user forced full on a project with `Mode: lite` in two runs | Remove the `Mode: lite` entry | `calibration.md` → Mode |
| A bug reached the base branch: a red base check, or a later task fixing merged work | A checklist entry for its class of bug, with where it slipped through | `review-checklist.md` → the area it touched, or Always check |
| Reviews were noisy: a third or more of the run's `critical` and `important` findings were refuted or answered (the `findings:` lines) | Narrow the checklist items they came from, or add a "don't flag" note for what keeps coming up | `review-checklist.md` |
| A learned default the user overrode in two runs (the `user overrode default:` lines in this and the archived ledgers) | Remove it | `calibration.md` → Learned defaults |

- **Don't propose what's already there.** If an existing recipe, default, pre-flight check or brief rule already covers a finding, don't propose it again; if it's there and the problem still happened, propose a fix to that entry.
- **Older ledgers without tags:** skip their untagged lines. Never guess a question or an answer from prose.
- **The project's own layout wins:** if `calibration.md` lacks a section, put the entry under the closest existing heading with its kind as a prefix — `Recipe: …`, `Learned default: …`, `Pre-flight: …`, `Skill: …`, `Tier: …`, `Mode: …` — or ask the user once whether to add the section. If they say no, use prefixed entries from then on without asking again. Respect the file's own budget, or none if it has no header ([the project owns it](knowledge.md#the-project-owns-it)).
- **Plugin lessons** (tooling, scripts, the skills, how other plugins coexist): in development mode they become plugin edits (including to [coexistence.md](coexistence.md)); standalone, they become project entries (a pre-flight check, a "briefs need" item) only where they help this project, and are otherwise left out (see the orchestrating skill's wrap-up).

## Using what was learned

- **`Worker plan:` entries** go into the briefs of matching tasks as hints, next to the `Tier:` hints; the worker follows them.

| Step | Use |
|---|---|
| Reading | Read entries by section **or** by prefix: a `Pre-flight:`, `Recipe:`, `Learned default:`, `Skill:`, `Tier:` or `Mode:` entry under another heading counts the same. |
| Intake | Run every **Pre-flight** check before planning. Fix what you can; tell the user up front what they'll need to do (e.g. `/add-dir`, trusting the folder), and log it as `[event] pre-flight: …`. |
| Breakdown | Match tasks to **Recipes** by area **and** kind of change; a different kind of change in the same area matches nothing. Follow a recipe's split, tier and placement unless the goal needs otherwise. Give each subtask the tier hint its `Tier:` entry names, when one matches its kind of work. |
| The plan the user approves | One line per learned default you rely on — `Assumed from project knowledge: <default>` — and per matched task — `Following recipe: <name>`; a `Skill:` entry that covers an overlapping workflow skill is shown the same way, as `Assumed from project knowledge: <entry>`. Never assume a default that decides safety, data handling, money or a destructive action ([what counts](#guardrails)), or contradicts `CLAUDE.md`, a project rule or the goal: ask or flag it instead. Log each line as its `[event]` (see Event kinds); an override as `user overrode default:`. |
| Briefs | Carry the recipe's must-haves, the "Briefs need" items, every learned default the task relies on, the `Skill:` entries that fit the task, in its **Skills** field, and the `Tier:` entries for its subtasks, as their tier hints. |

## Guardrails

- Nothing is learned without the user's approval of the knowledge diff.
- Never apply a learned default that contradicts `CLAUDE.md`, a project rule or the goal: flag the contradiction and follow `CLAUDE.md` (precedence: brief > `CLAUDE.md` > knowledge).
- Learned defaults never decide safety, data handling, money or destructive actions — not when proposing them, and not when applying them, even if one was added by hand. Those are rules (`domain.md`) or the user's call. What counts is what the default decides (an amount, rounding, a currency, who may see data, deleting something), not where the code lives: a file-placement, naming or export default still applies inside a payments or patient-data folder.
- A default the user overrides twice is proposed for removal.
- The content rules of project knowledge apply unchanged: no secrets, record identifiers or personal data; state the rule, never the value.
- A `Tier:` entry never lowers the tier of work that touches security, authentication, money or deleting data — not when proposing it, and not when applying one added by hand; raising is always allowed. Tiers move one tier down at a time, each step proposed only after two clean runs, and the worker session's own tier never drops below sonnet ([model-tiers.md](model-tiers.md#session-floor)).
- A `Skill:` entry never removes the review, the review checklist, tests or a project rule, and never overrides `CLAUDE.md` — not when proposing it, and not when applying one added by hand. One observation is enough to propose a `Skill:` entry; the user approves every entry.
