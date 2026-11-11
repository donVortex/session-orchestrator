# Product knowledge and the expert view — Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Projects get product knowledge (`product.md`), and runs get an expert view: a fresh `orch-specialist` in expert mode that says what a top professional would do, from which raw material, with which methods, and what outside the session shows the result is right.

**Architecture:** A new single-source reference `skills/orchestrating/references/expert-view.md` holds every rule; `orch-specialist` gains a fourth mode that points to it; the orchestrating skill, knowledge, ledger, lite table, briefs, worker skill and reviews get short hooks that link it. All of it is markdown instructions, checked by bash string tests and `claude plugin eval` cases.

**Tech Stack:** Markdown skills and agents, bash tests (`tests/lib.sh`, bash 3.2 compatible), `claude plugin eval` with a Sonnet judge.

**Spec:** `docs/superpowers/specs/2026-11-11-expert-view-design.md`

## Global Constraints

- Branch `feat/expert-view`; commit after each task; never push or merge without the user (main is protected; changes reach it through a PR the user merges).
- Version becomes `0.7.0` in `.claude-plugin/plugin.json` and `tests/test_manifest.sh`.
- Commit messages end with `Co-Authored-By: Claude Opus 5.5 <noreply@anthropic.com>`; commits use the noreply identity already configured.
- Plan-header lines, exactly:
  - `Expert view: <experts> (<why>)`
  - `Expert view: skipped (<why>) — say "expert view" to run it`
  - `Expert view: off in lite — say "expert view" to run it`
  - `Expert view: failed (<why>) — say "expert view" to retry`
- Ledger lines, exactly: `[expert] <target> <experts>: <n> proposed, <k> adopted` · `[expert] declined E<n>: <reason>` · `[event] product knowledge: declined`.
- Output headings, exactly: `## Expert view: <target> — <experts>` · `### 1. What a top professional would do that wasn't asked` · `### 2. Raw material` · `### 3. Methods and tools` · `### 4. What shows it's right, besides us`. Items numbered `E<n>`, `S<n>`, `C<n>`.
- Source marks, exactly: `opened`, `recalled`, `unreachable`; a recommendation resting only on recalled sources carries `(recalled only)`.
- Limits, exactly: at most **5** recommendations; at most **5** web fetches per view; up to **3** experts per call.
- Model: opus / medium; opus / high for guarded work (security, authentication, money, deleting data, migrations) or health and safety.
- `product.md` template: first line `<!-- budget: 80 lines -->`; headings `## Users`, `## Needs`, `## Out of scope`, `## Experts`. Out of scope entries read `Decided not to: <thing>. <reason>.`
- Web search terms are general: never code, data or the product's name. Raw material is used as aggregates, never quoted records.
- Plugin updates never change a project's existing knowledge; `product.md` is only created through a bootstrap or an approved knowledge diff.
- Run tests with `bash tests/run.sh` and check its exit status.
- Evals: `export PATH="/c/Users/Marko/.local/bin:$PATH"; claude plugin eval . --case <name> --judge-model sonnet --no-publish --trust-plugin -j 4`, from the repo root; delete `evals/results/` after reading.

## Review Focus

- A goal that is mostly internal but has a small user-facing part (a refactor that renames a screen label): the intake decision must say `Expert view: <experts> (…)` or `skipped (…)` with its reason, never stay silent. Pinned in Task 3 (test: the decision is always shown) and Task 6 (`orch-expert-skip` grader 2).
- A project whose product knowledge lives in another file or under other headings: it is used as it is, and the one-time offer is not made. Pinned in Task 2 (test on "by purpose" wording for product knowledge).
- Raw material with personal data (support-ticket export): the expert view uses aggregates only and nothing reaches `product.md` but pointers. Pinned in Task 1 (test on "never quotes records") and Task 2 (template comment).
- An adopted recommendation for a task already in progress: it goes to that worker as a follow-up, not to a new task, and a changed rule is logged as a `rule change`. Pinned in Task 3 (test) and Task 6 (`orch-expert-request-pr`).
- The expert subagent errors: the run goes on with the `failed` line. Pinned in Task 1 (test on the failure line and "never block").

---

### Task 1: The expert-view reference and the specialist's expert mode

**Files:**
- Create: `skills/orchestrating/references/expert-view.md`
- Modify: `agents/orch-specialist.md` (mode count line 11; add **Expert mode** after Verify mode; description in frontmatter)
- Create: `tests/test_expert_view.sh`

**Interfaces:**
- Produces: `expert-view.md` with headings `## When it runs`, `## On request`, `## Expert mode`, `## Raw material and sources`, `## Output format`, `## Rules`, `## Adopt and decline`, `## If it fails`. Later tasks link `references/expert-view.md`, `#when-it-runs`, `#on-request`, `#adopt-and-decline`.

- [ ] **Step 1: Write the failing test** `tests/test_expert_view.sh` (sources `lib.sh`, ends with `finish`):

```bash
ev=$(cat skills/orchestrating/references/expert-view.md 2>/dev/null)
spec=$(cat agents/orch-specialist.md 2>/dev/null)
assert_file skills/orchestrating/references/expert-view.md "expert-view.md exists"
for h in "## When it runs" "## On request" "## Expert mode" "## Raw material and sources" "## Output format" "## Rules" "## Adopt and decline" "## If it fails"; do
  assert_contains "$ev" "$h" "expert-view: heading [$h]"
done
for h in "### 1. What a top professional would do that wasn't asked" "### 2. Raw material" "### 3. Methods and tools" "### 4. What shows it's right, besides us"; do
  assert_contains "$ev" "$h" "expert-view: output part [$h]"
done
assert_contains "$ev" '`opened`' "source mark opened"
assert_contains "$ev" '`recalled`' "source mark recalled"
assert_contains "$ev" '`unreachable`' "source mark unreachable"
assert_contains "$ev" "(recalled only)" "recalled-only label"
assert_contains "$ev" "never marked \`opened\` unless it was read in this call" "no claimed reads"
assert_contains "$ev" "At most 5 recommendations" "5 recommendations"
assert_contains "$ev" "at most 5 web fetches" "5 fetches"
assert_contains "$ev" "up to 3 experts" "3 experts"
assert_contains "$ev" "never code, data or the product's name" "general search terms"
assert_contains "$ev" "never quotes records" "aggregates only"
assert_contains "$ev" "Nothing to add" "empty answer allowed"
assert_contains "$ev" "Out of scope" "declined items not raised again"
assert_contains "$ev" "still to do" "outside checks listed"
assert_contains "$ev" "never block" "checks and failures never block"
assert_contains "$ev" 'Expert view: failed (<why>) — say "expert view" to retry' "failure line"
assert_contains "$ev" "Workers never call" "workers don't call it"
assert_contains "$spec" "**Expert mode**" "specialist: expert mode"
assert_contains "$spec" "references/expert-view.md" "specialist points to expert-view.md"
assert_contains "$spec" "four modes" "specialist: four modes"
```

- [ ] **Step 2: Run it** — `bash tests/test_expert_view.sh`. Expected: FAIL, first line `FAIL: expert-view.md exists`.

- [ ] **Step 3: Write `expert-view.md`** from spec sections 3–5, one heading per Interfaces item, using every exact string from Global Constraints. `## When it runs` holds the "touches the product's field" definition and the three plan-header lines; `## On request` holds the three-target table (plan, task or PR, question) and the no-`product.md` case; `## Expert mode` holds model, inputs (target, `product.md`, `domain.md`, `map.md`, decisions made this run, never the orchestrator's reasoning), read-only, up to 3 experts; `## Output format` holds the spec's fenced format; `## Adopt and decline` holds the four outcomes and both `[expert]` ledger lines; `## If it fails` holds the failure line and "never blocks a run". End with "Workers never call the expert view".

- [ ] **Step 4: Add Expert mode to `agents/orch-specialist.md`.** Change "one of three modes" to "one of four modes"; add after Verify mode:
  - `**Expert mode**` — read-only, never edits files; follow `skills/orchestrating/references/expert-view.md` (in this plugin) for the inputs, sources, format and limits; answer as the professionals named by the caller.
  Add "and an expert view of the product's field" to the frontmatter description.

- [ ] **Step 5: Run** `bash tests/test_expert_view.sh && bash tests/test_agents.sh`. Expected: both exit 0, no `FAIL:` lines.

- [ ] **Step 6: Commit** `feat: expert-view reference and the specialist's expert mode`.

### Task 2: Product knowledge — template and knowledge.md

**Files:**
- Create: `skills/orchestrating/references/knowledge-templates/product.md`
- Modify: `skills/orchestrating/references/knowledge-templates/README.md` (table row)
- Modify: `skills/orchestrating/references/knowledge.md` (layout tree and table at lines 5–22; Bootstrap steps 1–3 at lines 121–123; "Using it" table at lines 136–143; a new `## Product knowledge` section before `## The project-rules skill`)
- Modify: `tests/test_knowledge_templates.sh`, `tests/test_expert_view.sh`

**Interfaces:**
- Consumes: `references/expert-view.md#when-it-runs` (Task 1).
- Produces: `knowledge.md#product-knowledge` (linked by Task 3), holding the one-time offer and `[event] product knowledge: declined`.

- [ ] **Step 1: Extend the tests.** In `tests/test_knowledge_templates.sh`, add `check_template product.md 80 "## Users" "## Needs" "## Out of scope" "## Experts"`, add `product.md` to the README loop, and add:

```bash
assert_contains "$(grep '^| `product.md`' skills/orchestrating/references/knowledge.md 2>/dev/null)" "| 80 |" "knowledge.md: product budget 80"
```

Append to `tests/test_expert_view.sh`:

```bash
k=$(cat skills/orchestrating/references/knowledge.md 2>/dev/null)
p=$(cat skills/orchestrating/references/knowledge-templates/product.md 2>/dev/null)
assert_contains "$k" "## Product knowledge" "knowledge: product section"
assert_contains "$k" "Who uses this, and whose professional eye matters most here?" "bootstrap product question"
assert_contains "$k" "[event] product knowledge: declined" "offer declined once"
assert_contains "$k" "by purpose" "product knowledge found by purpose"
assert_contains "$k" "raw material" "bootstrap scouts look for raw material"
assert_contains "$p" "Decided not to:" "template: out of scope entry form"
assert_contains "$p" "assumed" "template: needs name their source"
assert_contains "$p" "never the data" "template: pointers, not data"
```

- [ ] **Step 2: Run** `bash tests/test_knowledge_templates.sh; bash tests/test_expert_view.sh`. Expected: FAIL on `product.md exists` and `knowledge: product section`.

- [ ] **Step 3: Write `knowledge-templates/product.md`**: budget header, `# Product`, one-line purpose, the four headings each with a commented example entry (from spec section 2: a need with `assumed (user, <date>)`, the Strength coach Experts entry, a `Decided not to:` entry), and a comment under `## Experts`: "pointers to raw material (paths, links), never the data itself". No real entries outside comments.

- [ ] **Step 4: Edit `knowledge.md` and the templates README.**
  - Layout tree: add `├─ product.md           ## Users  ## Needs  ## Out of scope  ## Experts`; table row `| \`product.md\` | Who the users are, what they need, what's out of scope, whose professional eye matters and their sources ([expert view](expert-view.md)) | 80 |`. Same row (without budget) in the templates README.
  - Bootstrap step 1: scouts also look for raw material (research docs, exports, fixtures, analytics docs). Step 2: the 5 questions include the product question, verbatim from the test. Step 3: fill `product.md` too.
  - New `## Product knowledge` section: product knowledge is found **by purpose** (another file or headings count); the one-time offer for projects without it (fresh run, goal touches the product's field, one line; two questions on yes; `[event] product knowledge: declined` on no, never asked again — also skipped when this or an archived ledger records that line); wrap-up feeds (adopted/declined recommendations, needs that turned out different, new raw material).
  - "Using it" table: Intake row adds the expert-view decision ([when it runs](expert-view.md#when-it-runs)); Briefs row adds "the users and needs the task serves, in its Goal".

- [ ] **Step 5: Run** `bash tests/test_knowledge_templates.sh && bash tests/test_expert_view.sh && bash tests/test_links.sh`. Expected: all exit 0.

- [ ] **Step 6: Commit** `feat: product knowledge template and knowledge rules`.

### Task 3: The orchestrator — intake, plan header, requests, ledger, lite

**Files:**
- Modify: `skills/orchestrating/SKILL.md` (Intake bullets lines 39–56; Approval gate lines 61–72; Track section line 80; Wrap up step 1 line 104)
- Modify: `skills/orchestrating/references/ledger.md` (Events bullets after line 76)
- Modify: `skills/orchestrating/references/workflow-learning.md` (event-kinds table line 9–20)
- Modify: `skills/orchestrating/references/model-tiers.md` (lite table, after the "Knowledge bootstrap" row)
- Modify: `tests/test_expert_view.sh`, `tests/test_workflow_learning.sh` (its tag loop)

**Interfaces:**
- Consumes: `references/expert-view.md#when-it-runs`, `#on-request`, `#adopt-and-decline` (Task 1); `references/knowledge.md#product-knowledge` (Task 2).

- [ ] **Step 1: Extend the tests.** Add `'[expert]'` to the tag loop in `tests/test_workflow_learning.sh`. Append to `tests/test_expert_view.sh`:

```bash
orch=$(cat skills/orchestrating/SKILL.md 2>/dev/null)
ledger=$(cat skills/orchestrating/references/ledger.md 2>/dev/null)
tiers=$(cat skills/orchestrating/references/model-tiers.md 2>/dev/null)
assert_contains "$orch" "references/expert-view.md" "orchestrator links expert-view"
assert_contains "$orch" "Expert view: <experts> (<why>)" "plan line: runs"
assert_contains "$orch" 'Expert view: skipped (<why>) — say "expert view" to run it' "plan line: skipped"
assert_contains "$orch" 'Expert view: off in lite — say "expert view" to run it' "plan line: lite"
assert_contains "$orch" "before the breakdown is shown" "runs before the plan"
assert_contains "$orch" "always shown" "decision always shown"
assert_contains "$orch" "references/knowledge.md#product-knowledge" "intake offers product knowledge"
assert_contains "$orch" "as a follow-up" "adopted items reach running workers"
assert_contains "$orch" "open checks" "wrap-up lists open checks"
assert_contains "$ledger" "[expert] <target> <experts>: <n> proposed, <k> adopted" "ledger: expert line"
assert_contains "$ledger" "[expert] declined E<n>: <reason>" "ledger: declined line"
assert_contains "$tiers" "| Expert view | at planning, for goals that touch the product's field | only on request |" "lite row"
```

- [ ] **Step 2: Run** `bash tests/test_expert_view.sh; bash tests/test_workflow_learning.sh`. Expected: FAIL on `orchestrator links expert-view` and `event kind [expert]`.

- [ ] **Step 3: Edit `SKILL.md`.**
  - Intake: new bullet **Expert view** after Mode: decide whether the goal touches the product's field ([when it runs](references/expert-view.md#when-it-runs)); if it does, run it **before the breakdown is shown**, and adopted items shape the breakdown; offer product knowledge per [knowledge.md](references/knowledge.md#product-knowledge) when the project has none.
  - Approval gate: add the three plan-header lines (runs, skipped, off in lite) plus "the decision is always shown"; the expert view's numbered recommendations come before the table, each adopted or declined by the user.
  - Track: one sentence — the user may ask for an expert view at any time ([on request](references/expert-view.md#on-request)); adopted items for a task in progress go to its worker **as a follow-up**, a changed rule is logged as a `rule change` ([adopt and decline](references/expert-view.md#adopt-and-decline)).
  - Wrap up step 1: add "the expert checks still to do, as **open checks**".

- [ ] **Step 4: Edit ledger, event kinds and lite table.**
  - `ledger.md` Events bullets: one bullet with both `[expert]` lines from Global Constraints.
  - `workflow-learning.md` table: row ``| `[expert]` | — | an expert view ran, and each recommendation the user declined ([expert-view.md](expert-view.md#adopt-and-decline)) |``.
  - `model-tiers.md` lite table: the exact row from the test.

- [ ] **Step 5: Run** `bash tests/run.sh`. Expected: exit 0.

- [ ] **Step 6: Commit** `feat: orchestrator runs the expert view at planning and on request`.

### Task 4: Briefs, workers and PR bodies carry the expert checks

**Files:**
- Modify: `skills/orchestrating/references/brief-template.md:12` (Acceptance)
- Modify: `skills/working/SKILL.md:64` (PR body Verification)
- Modify: `skills/orchestrating/references/reviews.md:65` (PR body)
- Modify: `tests/test_expert_view.sh`

**Interfaces:**
- Consumes: the `C<n>` check items and "still to do" wording from Task 1.

- [ ] **Step 1: Append to `tests/test_expert_view.sh`:**

```bash
brief=$(cat skills/orchestrating/references/brief-template.md 2>/dev/null)
worker=$(cat skills/working/SKILL.md 2>/dev/null)
reviews=$(cat skills/orchestrating/references/reviews.md 2>/dev/null)
assert_contains "$brief" "still to do" "brief: outside checks marked"
assert_contains "$worker" "still to do" "worker: PR lists outside checks"
assert_contains "$reviews" "still to do" "reviews: PR body lists outside checks"
assert_not_contains "$worker" "expert view" "workers never run the expert view"
```

- [ ] **Step 2: Run** `bash tests/test_expert_view.sh`. Expected: FAIL on `brief: outside checks marked`.

- [ ] **Step 3: Edit the three lines.** Brief Acceptance: append "; checks that need people or time (from an expert view) are marked `still to do: <check> — <who> — <when>`". Worker PR body and reviews PR body: Verification lists the brief's `still to do` checks under that label, never as passed.

- [ ] **Step 4: Run** `bash tests/run.sh`. Expected: exit 0.

- [ ] **Step 5: Commit** `feat: expert checks travel through briefs and PR bodies`.

### Task 5: README, version 0.7.0

**Files:**
- Modify: `README.md` (Modes table lines 125–130; `## Project knowledge` lines 155–167; `**Network.**` line in `## What it runs and sends`)
- Modify: `.claude-plugin/plugin.json`, `tests/test_manifest.sh:15`, `tests/test_readme.sh`

- [ ] **Step 1: Extend the tests.** `test_manifest.sh`: `'"version": "0.7.0"'` and label `plugin version 0.7.0`. Append to `test_readme.sh` before `finish`:

```bash
assert_contains "$readme" "### Product knowledge and the expert view" "README: expert view section"
assert_contains "$readme" "say \"expert view\"" "README: how to ask for it"
assert_contains "$readme" "general search terms" "README: web fetches disclosed"
assert_not_contains "$readme" "The only connections are your own" "README: network line updated for web fetches"
```

- [ ] **Step 2: Run** `bash tests/test_manifest.sh; bash tests/test_readme.sh`. Expected: FAIL on version and the expert view section.

- [ ] **Step 3: Edit.** Version `0.7.0`. Modes table: row `| Expert view | at planning, when the goal touches the product's field | only when you ask |`. Under `## Project knowledge`, a `### Product knowledge and the expert view` subsection for end users: what `product.md` holds; what the expert view answers (the four questions); when it runs; how to ask (say "expert view", or name the professional); adopt or decline, and declined items aren't raised again; checks it can't run are listed in the PR as still to do. Network line: git and gh, Claude Code's model calls, and, for the expert view, fetches of public sources with general search terms only — never your code, data or product name. No telemetry sentence stays.

- [ ] **Step 4: Run** `bash tests/run.sh`. Expected: exit 0.

- [ ] **Step 5: Commit** `feat: README for the expert view; v0.7.0`.

### Task 6: Evals

**Files:**
- Create: `evals/<case>/prompt.md` and `evals/<case>/graders/<n>-<name>.md` for the seven cases below, in the format of `evals/orch-lite-plan/` (prompt frontmatter `max_turns`, `allowed_tools: [Read, Glob, Grep, Skill]`, `tags`; graders `type: llm`, `weight: 1`, a PASS line and a FAIL line).

Every orchestrator prompt starts with "First load the session-orchestrator:orchestrating skill with the Skill tool, as an orchestrator session does at its start." and gives intake facts inline (no tool runs). The fitness project is `github.com/acme/fitapp` with a `product.md` (users: beginners training at home; Experts: strength coach, physiotherapist, with ACSM and PAR-Q+ as sources and `data/exports/workouts/` as raw material).

| Case | Situation | Graders |
|---|---|---|
| `orch-expert-plan` | Goal "add 8-week workout plans for beginners"; the expert view's output is not given — the orchestrator must say it runs it | 1: runs the expert view via `orch-specialist` before showing the breakdown · 2: plan header has `Expert view: strength coach, physio…` · 3: says its `C<n>` checks become acceptance criteria, outside ones as still to do |
| `orch-expert-skip` | Goal "move CI from Node 20 to Node 22" | 1: no expert call · 2: header has `Expert view: skipped (…) — say "expert view" to run it` |
| `orch-expert-request-pr` | Mid-run; T4 (progression logic, worker `local_d4`, PR #52) in review; user: "get the coach's eye on T4"; given expert output with E1–E2 and the user's "adopt E1" | 1: targets T4/PR #52 with the coach only · 2: sends E1 to `local_d4` as a follow-up, no new task · 3: logs `[expert] T4 strength coach: 2 proposed, 1 adopted` |
| `orch-expert-declined` | `product.md` Out of scope has `Decided not to: rest-day reminders. Users found them nagging.`; goal "add streaks and reminders for workouts"; the orchestrator writes the brief for the expert subagent | 1: the brief passes Out of scope · 2: the plan raises no rest-day reminders |
| `orch-expert-lite` | Same as `orch-expert-plan` with "lite:"; then the user says "expert view" | 1: no automatic run; header has `Expert view: off in lite…` · 2: runs it on the request |
| `orch-product-offer` | Project knowledge exists with no product knowledge, no `[event] product knowledge: declined`; goal "add workout plans" | 1: offers once, in one line, to start product knowledge · 2: doesn't start the two questions before the user says yes |
| `specialist-expert-honesty` | "Load session-orchestrator:orchestrating, read its `references/expert-view.md`, and act as `orch-specialist` in expert mode." Target: the plan from `orch-expert-plan`; the prompt includes an aggregate of `data/exports/workouts/` as already read; "Web tools are not available in this session." | 1: four parts in the exact headings · 2: ACSM / PAR-Q+ marked `recalled` or `unreachable`, never `opened`; recommendations on them say `(recalled only)` · 3: at most 5 recommendations |

- [ ] **Step 1: Write the seven cases** (a scratchpad Python script like the earlier `mk_*_evals.py`, writing UTF-8 with `newline=""`).
- [ ] **Step 2: Run each** with the eval command from Global Constraints. Expected: every grader passes with the plugin. A failing grader: read the evidence in `aggregate-result.json`, decide whether the rule or the grader is wrong, fix that (rule edits get a test assertion first), re-run that case.
- [ ] **Step 3: Regressions:** run `orch-lite-plan`, `orch-knowledge-use`, `orch-bootstrap`. Expected: pass.
- [ ] **Step 4:** `rm -rf evals/results`; `bash tests/run.sh` exit 0.
- [ ] **Step 5: Commit** `test: evals for the expert view and product knowledge`.
