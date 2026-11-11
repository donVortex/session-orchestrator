# Product knowledge and the expert view — Design

Date: 2026-11-11
Status: approved, not implemented (target v0.7.0)
Builds on: [project knowledge](2026-11-03-project-knowledge-design.md) · [reviews v2 (v0.6.0)](../../../skills/orchestrating/references/reviews.md) · [model tiers](../../../skills/orchestrating/references/model-tiers.md)

## 1. Intent

Project knowledge today records the project's rules and terms (`domain.md`), where things live (`map.md`), what reviewers check and how work is sized. It has no place for **the product**: who the users are, what they need, what is deliberately out of scope. And nothing in a run looks at the work the way a top professional of the product's field would (for a fitness app: a strength coach, a physiotherapist).

The feature adds both, **deeper, not bigger**: no new agent, no new run step, one new knowledge file, and one subagent call per goal that touches the product's field. The depth comes from what the expert view must say, not from how much of it there is.

**Success looks like:**
- Workers build for the project's actual users without the user restating them each run.
- At planning, the user hears what a top professional would do that they didn't ask for, grounded in primary sources, with checks from outside the session that show the result is right.
- A recommendation the user declined doesn't come back every run.
- Nothing claims a source was read when it wasn't.

### Decisions made with the user

| Topic | Decision |
|---|---|
| Scope | **Both**: product knowledge as the base, an expert view on top of it. |
| Depth | Every expert view answers four things: (1) what a top professional would do here that the user didn't ask for; (2) the raw material they'd start from, not digested summaries; (3) the specific methods and tools they'd use; (4) what, other than the user and Claude, shows the result is right. |
| When it runs | **Automatically at planning** for goals that touch the product's field, **plus on request** at any time. No per-PR expert pass. In lite mode: only on request. |
| Raw material | **Open what it can**: the project's own material always; public primary sources fetched from the web; anything not opened is marked *recalled*. Web search terms are general, never code, data or the product's name. |
| Shape | **A fourth mode of `orch-specialist`** (expert mode), run as a fresh subagent; a new knowledge file `product.md`. Not a separate agent, not the orchestrator itself. |

### Assumptions and non-goals

- The model already knows a lot about most fields; the value is in applying it to this goal, naming sources, and being honest about which were read.
- Not in scope: workers calling the expert view; one agent per expert; automatically learning which experts get declined (possible later via workflow learning).
- Expert checks never block a merge; the user decides.

## 2. Product knowledge: `product.md`

A new knowledge file, owned by the project like the others (plugin updates never change it). Starter template `knowledge-templates/product.md`:

```markdown
<!-- budget: 80 lines -->
# Product
## Users        who uses it, in what situation, at what level
## Needs        what they come for, each with where that's known from
## Out of scope what we decided not to do, and why
## Experts      whose eye matters, what they guard, their primary sources,
                and where the project's own raw material is
```

- **Every need names its source**: interviews, support tickets, analytics, or `assumed (user, <date>)`. An assumed need is usable, but the expert view treats it as a gap and may propose how to check it.
- **Experts** entries name the role, what it guards, primary sources (with links) and pointers to the project's raw material (paths). Example: `**Strength coach** — guards progression and load. Sources: ACSM resistance-training position stand (link). Our material: data/exports/workouts/ (anonymised logs).`
- **Out of scope** entries read `Decided not to: <thing>. <reason>. _(source, date)_`.
- The existing content rules apply: pointers to raw material, never the data; interview quotes summarised without names; no personal or health records.
- Adopted advice goes where it fits: a product decision into `product.md`, a hard rule into `domain.md`'s Rules, each with the usual source line. Rule changes and stale entries are handled as today (edit in place).
- The orchestrator maps files by purpose, so a project that keeps product knowledge under another name or inside another file is used as it is.

### Filling it

- **Bootstrap:** the scouts also look for raw material (research docs, exports, fixtures, analytics docs). The interview stays at **at most 5 questions** and includes one product question: *"Who uses this, and whose professional eye matters most here?"*
- **Projects bootstrapped earlier:** at the intake of a fresh run whose goal touches the product's field and whose knowledge has no product knowledge, offer once, in one line, to start it. On yes: two questions, one at a time (users, then experts); the draft joins this run's knowledge diff. On no: log `[event] product knowledge: declined` and never ask again (same as the project-rules skill).
- **Each wrap-up:** adopted and declined recommendations, needs that turned out different, and newly found raw material go into the knowledge diff.

## 3. When the expert view runs

### Automatically, at planning

At intake the orchestrator decides whether the goal **touches the product's field**: it changes what users see or do, calculations or content the experts guard, or the data users hand over. Refactors, CI, dependencies and internal tooling don't. The decision is shown in the plan header, next to the Mode line:

- `Expert view: strength coach, physio (goal changes workout plans)`
- `Expert view: skipped (CI change) — say "expert view" to run it`
- `Expert view: off in lite — say "expert view" to run it`

When it runs, it runs **before the breakdown is shown**, and its adopted items shape the plan.

### On request

The user asks in plain words at any point ("expert view", "what would a coach say?", "physio's eye on T4"). No new command. A named professional runs only that view; otherwise the experts in `product.md` that bear on the target.

| Target | It reads | Its "what shows it's right" becomes |
|---|---|---|
| The plan (before or after approval) | goal, breakdown, product knowledge | acceptance criteria on tasks |
| A task or PR (`T4`, `#52`) | brief, diff, the worker's report | checks in that PR's Verification; ones the session can't run are listed as still to do |
| A question | the code and data needed to answer | a list of checks to run or hand off |

Without `product.md`: it infers the fitting professional from the goal, says so in one line, and afterwards offers to start `product.md` with what was decided.

## 4. Expert mode (`orch-specialist`)

- **Fresh subagent, read-only.** Never edits files.
- **Model:** opus / medium; opus / high when the target is guarded work (security, authentication, money, deleting data, migrations) or health and safety.
- **One call covers every applicable expert, up to 3.** More than 3 apply: it takes the 3 that bear most and names the skipped ones.
- **Input:** the target; `product.md`, `domain.md`, `map.md`; decisions already made this run (adopted and declined). Not the orchestrator's reasoning.
- **Project raw material:** read with read-only tools from the Experts pointers or what it finds; works from aggregates, never quotes records.
- **Web:** at most **5 fetches** per view; search terms are general.
- **Source marks:** every source is *opened* (URL or path, plus section), *recalled* (name and year as remembered) or *unreachable* (paywalled, fetch failed). A recommendation resting only on recalled sources says `(recalled only)`. A source is never marked *opened* unless it was read in this call.

### Output format

```markdown
## Expert view: <target> — <expert>, <expert>
### 1. What a top professional would do that wasn't asked
- E1. <recommendation> — <why> — rests on S1, S3
### 2. Raw material
- S1. <source> — opened (<url or path>, <section>) | recalled | unreachable — <what it gives>
### 3. Methods and tools
- <method or tool>, for E<n>
### 4. What shows it's right, besides us
- C1. <check> — <who or what runs it> — <when: in the run | after merge | after release>
```

Rules:
- **At most 5 recommendations**, most important first. "Nothing to add" is a valid answer.
- **Nothing from Out of scope comes back** unless new raw material changes the reason; then it says what changed.
- Checks the session can run become acceptance criteria; checks needing people or time go to the PR's Verification as **still to do** and to the wrap-up summary as open checks.
- **Failure** (error, nothing usable): the plan goes on with `Expert view: failed (<why>) — say "expert view" to retry`. It never blocks a run.

## 5. Adopt and decline

Each recommendation is numbered; the user adopts or declines each.

- **Adopted, work not started:** the plan changes (new task or acceptance criteria), shown as a plan change before anything starts.
- **Adopted, task in progress:** sent to that worker as a follow-up, like review findings; if it changes a rule, logged as a `rule change`.
- **Declined:** recorded with the user's reason; at wrap-up it goes into `product.md`'s Out of scope.
- **Ledger:** `[expert] <target> <experts>: <n> proposed, <k> adopted` and, per decline, `[expert] declined E<n>: <reason>`.

Workers never call the expert view; a product-field question goes to the user through the report, as today.

## 6. Changes

| File | Change |
|---|---|
| `skills/orchestrating/references/expert-view.md` | **New, single source**: when it runs, targets, format, source marks, limits, adopt/decline, failure |
| `agents/orch-specialist.md` | Fourth mode: Expert mode, pointing to expert-view.md |
| `skills/orchestrating/references/knowledge-templates/product.md` | **New** starter |
| `knowledge-templates/README.md` | Lists the new template |
| `skills/orchestrating/references/knowledge.md` | Layout table row; bootstrap scan and product question; one-time offer for older projects; Using it table |
| `skills/orchestrating/SKILL.md` | Intake decision; `Expert view:` plan-header line; requests mid-run; adopt/decline |
| `skills/orchestrating/references/ledger.md` | `[expert]` lines; `[event] product knowledge: declined` |
| `brief-template.md`, `skills/working/SKILL.md`, `references/reviews.md` | Acceptance may carry expert checks; PR Verification lists still-to-do checks |
| `references/model-tiers.md` | Lite table row: "Expert view: only on request" |
| `README.md` | Product knowledge and the expert view; "What it runs and sends": public sources fetched with general search terms |
| `.claude-plugin/plugin.json`, `tests/test_manifest.sh` | v0.7.0 |

## 7. Testing

**Unit:** `tests/test_expert_view.sh` asserts the key rules are present (four parts, source marks, the 5/5/3 limits, out-of-scope rule, lite row, plan-header lines, ledger lines, template sections, README disclosure).

**Evals** (with and without the plugin):

| Case | Checks |
|---|---|
| `orch-expert-plan` | Fitness goal + `product.md`: expert view runs at planning, four-part format, its checks land in acceptance criteria |
| `orch-expert-skip` | CI goal: `skipped` line, no expert call |
| `orch-expert-request-pr` | Mid-run "coach's eye on T4": targets the PR; adopted items go to the worker |
| `orch-expert-declined` | An Out of scope item isn't raised again |
| `orch-expert-lite` | Lite: nothing automatic; a request still works |
| `orch-product-offer` | Older project without product knowledge + domain goal: one-line offer, once |
| `specialist-expert-honesty` | No web in the sandbox: web sources marked *recalled* or *unreachable*, never *opened* |
