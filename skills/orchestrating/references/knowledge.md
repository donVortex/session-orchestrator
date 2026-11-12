# Project knowledge

Each project keeps what the orchestrator has learned about it in `.claude/orchestrator/`, committed to the repo and shared by the whole team. You read it on every run, use it to plan, brief and review, and propose changes to it at every wrap-up. It is the project's expertise; the plugin stays generic.

## Layout a new bootstrap creates

```
.claude/orchestrator/
├─ README.md            for humans
├─ domain.md            ## Rules  ## Glossary
├─ map.md               ## Areas  ## Feature flows
├─ review-checklist.md  ## Always check  ## When touching <area>
├─ product.md           ## Users  ## Needs  ## Out of scope  ## Experts
└─ calibration.md       ## Tiers by task type  ## Split patterns  ## Briefs need
                        ## Recipes  ## Learned defaults  ## Skills  ## Pre-flight
```

| File | Holds | Budget written into a new file (lines) |
|---|---|---|
| `domain.md` | Business and regulatory rules; terms that mean something specific here | 150 |
| `map.md` | Where things live; how a typical feature flows through the layers | 100 |
| `review-checklist.md` | What every review must check; extra checks per area | 60 |
| `product.md` | Who the users are, what they need, what's out of scope, whose professional eye matters and their sources ([expert view](expert-view.md)) | 80 |
| `calibration.md` | Which task types need which tier here; typical split sizes; brief details workers keep needing; proven recipes, learned defaults and pre-flight checks ([workflow learning](workflow-learning.md)) | 120 |

A new file's first line states its budget: `<!-- budget: N lines -->`. Starter files are in [knowledge-templates/](knowledge-templates/README.md): [domain.md](knowledge-templates/domain.md), [map.md](knowledge-templates/map.md), [review-checklist.md](knowledge-templates/review-checklist.md), [calibration.md](knowledge-templates/calibration.md), [product.md](knowledge-templates/product.md).

## The project owns it

The knowledge belongs to the project, not to the plugin. Plugin updates never change it. Once the folder exists, its own files are the layout:

- **Read every file in the folder**, whatever its name, headings or extra files. Map each to the purpose it serves (rules, map, checklist, product, calibration) by its content, not its name.
- **A file's budget is the one in its own first line.** A file without a budget header has no budget: never apply the table's numbers to it, and never trim it for length.
- **Add entries to the existing file whose purpose fits**, under its existing headings. If no file fits, say so and ask the user whether to add one. Never create a template file in an existing folder on your own.
- **Never migrate.** Don't rename, reformat, restructure, re-template or add budget headers to existing knowledge, and don't propose it, even if the plugin's templates have changed. A layout change happens only when the user asks for it.
- **Bootstrap only when no folder exists anywhere** — not on the base branch, and not in an open knowledge PR (see Bootstrap).
- **Changes only through the knowledge diff**, approved by the user, for content the retros justify or a contradiction flagged at intake.

## Entry format

One line, or a short block, ending with its source and date:

```markdown
- **PHI never appears in logs.** Use `redact()` from `src/phi/redact.ts`. _(bootstrap, 2026-11-03)_
- **Premiums are integer cents**, never floats: the payment provider rejects fractions. _(T2 / PR #42, 2026-11-10)_
```

A source is `bootstrap`, `user`, `T<n> / PR #<n>`, a raw-material path (`docs/research/interviews-2026-10.md`) for a need, or `expert view, declined by user` for an Out of scope entry.

## Content rules

Apply to everything that goes into the repo or onto GitHub: entries, their sources and reasons, PR titles and bodies, and commit messages.

1. **No secrets, credentials, records or personal data, and no record identifiers** (patient, customer, account or claim numbers; code names like `redact()` or `src/phi/` are fine). State the rule, never the value: "MRNs may contain dashes", not "MRN 4471-882 failed". Drop such values wherever you find them, and tell the user what kind of value you left out ("an MRN"), without repeating it.
2. **Don't copy `CLAUDE.md`.** If a rule is already there, refer to it (`see CLAUDE.md: <rule>`) instead of restating it, in every file. A checklist item for such a rule reads `Check CLAUDE.md: <rule>`; add only what `CLAUDE.md` doesn't say (e.g. "also in error messages").
3. **Respect each file's own budget.** If a file has a budget header and an addition would push it over, the same proposal merges or removes entries in that file. Files without a header have no budget.
4. **Only what Claude would otherwise get wrong.** An entry earns its place when a careful engineer new to this repo would likely miss it: a rule the code doesn't show, a gotcha, a term with a local meaning, a decision. Leave out what the code, file names or folder structure already show ("`src/api/` holds the routes") and what anyone does without being told ("write tests"). Every entry is read on every run and can pull against the task at hand, so a few sharp entries beat a complete list.
5. **A rule says why**, in a few words: "integer cents: the payment provider rejects fractions". The reason lets a worker judge a case the rule didn't foresee, and lets a later run see when the rule stops applying. Take the reason from the source or the retros; when they give none, write the rule without one. Never invent a reason, and don't ask the user for one just to fill it in.

## Precedence

A task's brief > `CLAUDE.md` > knowledge files. When knowledge contradicts `CLAUDE.md` or the code:
- say so to the user at intake, and record it in the ledger's Events so it survives until wrap-up;
- follow `CLAUDE.md` or the code; **never quote the contradicted entry into a brief's Project rules** — quote `CLAUDE.md`'s version instead;
- fix the entry in the next knowledge diff.

A goal that changes a project rule is not a contradiction to flag but a change to confirm: see [Rule changes](#rule-changes).

## Rule changes

Rules change as the product does: feature X needed Y at first, now it needs Z. Handle it so the knowledge keeps saying one thing:

- **At intake**, compare the goal with the rule entries. When the goal changes one, show it on the plan as `Changes rule: <old entry> → <new rule>`; the user's approval of the plan confirms it (or they correct it). Log `[event] rule change: <old> → <new>`. If it's unclear whether the goal means to change the rule, ask; don't guess.
- **Briefs** quote only the new version, never the old one, not even as background.
- **At wrap-up**, each `rule change` event, and each entry this run's merged work made untrue, becomes an **edit of the existing entry**, shown as old → new, with the new source and date. Never add a second entry beside the old one, and never keep both "for history": git history (the knowledge PRs, `git log -p` on the file) is the record of what a rule used to be. The files say only what is true now.
- **One rule, one place.** When the same rule appears in two entries or two files, the diff merges them into one entry; other files refer to it.

## Stale entries

At intake, check what the entries name in backticks against the base branch: paths with `git cat-file -e origin/<base>:<path>` (for a glob, its folder), functions and other names with `git grep -q '<name>' origin/<base>`. An entry whose path or name no longer exists is **stale**:

- tell the user in one line, and log `[event] stale entry: <entry, shortened> (<what's missing>)`;
- never quote it into a brief as fact;
- in the next knowledge diff, propose updating it (the new path or name, if this run found where it went) or removing it.

## Pruning

Knowledge that only grows turns into noise: entries Claude would follow anyway, rules that pull against each other, constraints that no longer fit. Each run records what it used, and the wrap-up prunes from that.

- **At wrap-up, log** `[event] knowledge used: <entries, shortened>`: the entries this run quoted into a brief, followed at breakdown, or that a review finding relied on; `none` if it used none.
- **Pruning candidates** are entries that no `knowledge used:` line names in the last 3 runs (this ledger and the archived ones that have the line; older runs don't count), and entries this run used whose content the task's code showed anyway.
- **Put each candidate to the value test** ([content rule 4](#content-rules)). Propose removing one that fails, with the reason: what the code already shows, or what Claude does without being told. One that passes stays, without comment. A rule that passes but has no reason: propose adding it, if its source or the retros give one.
- **Never remove an entry only for being unused:** an area the last runs didn't touch still has its rules. Never propose removing an entry about safety, data handling, money, regulation or destructive actions as unused or obvious; those change only by a [rule change](#rule-changes) or by the user.
- A removal the user declines is logged as `[event] knowledge kept: <entry, shortened>`; don't propose it again while this or an archived ledger records that line. Git history keeps every removed entry.

## Reading from the base branch

Read the knowledge as the base branch has it, not as your local checkout happens to be:

```bash
git fetch origin <base>
git ls-tree --name-only origin/<base> .claude/orchestrator/      # which files exist (empty: no folder)
MSYS_NO_PATHCONV=1 git show "origin/<base>:.claude/orchestrator/<file>"   # one file's content
```

`MSYS_NO_PATHCONV=1` matters on Windows: Git Bash otherwise rewrites `origin/<base>:.claude/…` into a Windows path and `git show` fails. It is harmless elsewhere.

An open knowledge PR's branch is read the same way, with `origin/<branch>` in place of `origin/<base>`.

## Working in a worktree

Never `cd` into a worktree under `$root-wt/` in your own shell: it moves your session's working directory there, and the worktree then can't be removed until you move back. Point commands at it instead — `git -C "<dir>" …`, `npm --prefix "<dir>" test` — or run them in a subshell: `(cd "<dir>" && npm test)`.

## Linked dependencies

A new worktree has no installed dependencies (`node_modules`, a virtualenv). Linking them from the main checkout (a junction or symlink) is fine for running tests, with two rules:
- never run an install in that worktree (`npm install`, or a script that installs, such as a lint command that adds its own tool): it writes through the link into the main checkout's dependencies;
- remove the link itself before removing the worktree: `cmd //c rmdir "<dir>\node_modules"` for a Windows junction, `rm "<dir>/node_modules"` for a symlink, then `git worktree remove "<dir>"`. Never use `git worktree remove --force` (it leaves the folder behind), and never `rm -r` the link or the worktree folder: a recursive delete can follow the link into the main checkout.

## Bootstrap

Only at the intake of a **fresh** orchestration (never on resume), and only when the base branch has no `.claude/orchestrator/`. It needs no goal: when the user starts the orchestrator without one, bootstrap first and ask for the goal after the drafts are approved. First check for an open knowledge PR:

```bash
gh pr list --state open --search "head:orch/knowledge-" --json number,headRefName,createdAt \
  --jq '[.[] | select(.headRefName | startswith("orch/knowledge-"))] | sort_by(.createdAt) | reverse'
```

GitHub's `head:` search can match more loosely than the prefix; the `--jq` filter keeps only branches that really start with `orch/knowledge-`, newest first.

- **One is open** (from an earlier bootstrap or wrap-up): don't bootstrap. Read its branch's files (see Reading from the base branch), use them for this run, tell the user the PR is still awaiting merge, and quote the checklist items into briefs (workers' worktrees won't have the file).
- **More than one is open:** treat the newest as the knowledge PR (as above), and list the others to the user, suggesting they merge or close them. Never open another knowledge PR while any is open.
- **None is open:** bootstrap.

1. **Scan.** In one message, start parallel `orch-scout` subagents to read the README, `docs/`, `CLAUDE.md`, the folder structure, the test layout and the last 50 commits. Ask each for draft entries with `path:line` sources, only what the code doesn't already show ([content rules](#content-rules)), and also for the project's **raw material** (research notes, data exports, fixtures, analytics docs) as pointers for the product knowledge.
2. **Interview.** Ask the user at most **5** questions, **one at a time** — each one thing to answer, never a bundle of sub-questions. Two of them are always the product questions, asked separately: *"Who uses this?"* and *"Whose professional eye matters most here?"* Pick the rest from: rules that aren't written down; risky or regulated areas; terms with a specific meaning here; what reviewers must always check; work that has gone wrong before.
3. **Draft.** Fill `README.md` and the five files from the templates (`product.md` from the product answers and the scouts' raw material), applying the content rules. Remove a template heading that ends up with no entries (e.g. an unused `## When touching <area>`), except calibration's `## Recipes`, `## Learned defaults` and `## Pre-flight`, and product's `## Out of scope`, which stay for workflow learning to fill. Also offer the [project-rules skill](#the-project-rules-skill) as part of the same PR; the user may decline it.
4. **Approve.** Show the drafts and ask the user to approve or edit them. Write nothing to the repo before they do.
5. **PR.** The worktree sits outside your working directories: if the user hasn't run `/add-dir <$root>-wt` yet, ask them to now. Then:
   ```bash
   git worktree add -b orch/knowledge-bootstrap "$root-wt/knowledge-bootstrap" origin/<base>
   ```
   Write the approved content into `.claude/orchestrator/` there, commit, push, and open the PR with its body in `$root/.orchestration/knowledge-pr.md` (`gh pr create --body-file`). Remove the worktree afterwards. If the branch name is taken (an earlier bootstrap PR was closed), use `orch/knowledge-bootstrap-<YYYY-MM-DD>`.
6. **Continue.** Feature work waits until that PR is merged, unless the user says to use the approved draft now. Then work from the draft, mention the open PR in every brief's Project rules field, and quote the checklist items into briefs.

`$root` is the main checkout, resolved as in [ledger.md](ledger.md#setup-once-per-repo).

If the user declines the bootstrap, run without knowledge for this orchestration. At the next fresh orchestration, ask once, in one line, whether to bootstrap now; don't start the interview unless they say yes.

## Using it

| Step | Use |
|---|---|
| Intake | Read every file in the folder from the base branch. Decide whether the goal gets an [expert view](expert-view.md#when-it-runs). Tell the user which entries bear on the goal. Flag contradictions (see Precedence), the rules the goal changes ([rule changes](#rule-changes)) and [stale entries](#stale-entries). If the project has a `REVIEW.md` (repo root or `.claude/`), read it too: it joins the review checklist and wins where they differ ([reviews](reviews.md#the-projects-own-review-rules)). |
| Breakdown | The map's feature flows for where the change belongs; the calibration's tiers and split sizes. |
| Briefs | **Goal:** the users and needs the task serves, from the product knowledge. **Project rules:** quote the rule entries relevant to the task (never a contradicted or stale one, and only the new version of a rule the goal changes). **Review checklist:** name the project's checklist file and the sections that apply; when the knowledge isn't on the base branch yet (open bootstrap PR, approved draft), quote the checklist items themselves. Write the calibration's "briefs need" items into the brief's fields, plus a matched recipe's must-haves and the learned defaults the task relies on ([workflow learning](workflow-learning.md#using-what-was-learned)). |
| Reviews | Your own review and every `orch-specialist` pass, `deep` tasks included, check the same checklist items (and `REVIEW.md`), with the finding rules in [reviews.md](reviews.md). |

## Product knowledge

Who the users are, what they need, what was decided against, and whose professional eye matters, with their sources: what the [expert view](expert-view.md) works from. New bootstraps write it as `product.md` ([template](knowledge-templates/product.md)).

- **Found by purpose.** A project that keeps this in another file, or under other headings, has product knowledge: use it as it is, and don't offer to start one.
- **Projects bootstrapped before product knowledge existed** (they have knowledge, but none of it is product knowledge): at the intake of a fresh full-mode orchestration (never in lite, and never to a project with no knowledge at all) whose goal touches the product's field ([when](expert-view.md#when-it-runs)), offer once, in one line of the approval message, to start it. On yes, once the plan is approved, ask the two product questions, one at a time (*"Who uses this?"*, then *"Whose professional eye matters most here?"*), and add the draft `product.md` to this run's knowledge diff (the user's yes is what allows a new file here). On no, log `[event] product knowledge: declined` and never offer again; skip the offer too when this or an archived ledger records that line.
- **At wrap-up,** the knowledge diff carries: adopted expert recommendations that are product decisions (a hard rule goes to the rules file instead); declined ones, as Out of scope entries; needs that turned out different (an edit of the entry, as with [rule changes](#rule-changes)); new raw material found this run, as pointers. When the user declined product knowledge, declines go into the rules file as `Decided not to:` entries (a product decision is a rule there), with no new file and no new offer.
- **Content rules apply in full:** pointers to raw material, never the data; interview findings summarised without names; no personal or health records.

## The project-rules skill

Only the orchestrator reads `.claude/orchestrator/`. Sessions that don't orchestrate — quick fixes, questions, a teammate without the plugin — would not know the project's rules. A small project skill fixes that: `.claude/skills/project-rules/SKILL.md`, from [this template](knowledge-templates/project-rules-skill.md). Claude Code loads it whenever code in the repo is changed, with or without the plugin. It only **points** to `domain.md` and the review checklist; it never copies rules, so it can't drift.

- **When to offer it:** in the bootstrap PR, and at a wrap-up when the project has knowledge but no `.claude/skills/project-rules/` — unless this or an archived ledger records `[event] project skill: declined`.
- **How:** as one more file in the knowledge diff, clearly optional. If the user declines, log `[event] project skill: declined` and never offer it again.
- **Ownership:** once added, it belongs to the project like the knowledge: never rewritten or reformatted by plugin updates; the team may edit or delete it.

## Knowledge diff at wrap-up

1. Group the retros by tag; `[domain]` points are knowledge candidates, and so are repeated `[brief]`, `[split]` and `[tier]` patterns, plus contradictions recorded at intake, plus the `rule change` and `stale entry` events, plus the `[expert]` lines (each decline becomes an Out of scope entry, taken from the saved view in `.orchestration/expert/`) and the open checks, plus the workflow findings from the [counts](workflow-learning.md#findings-to-proposals) (recipes, learned defaults, pre-flight checks), plus the [project-rules skill](#the-project-rules-skill) if it's missing and was never declined, plus the pruning candidates ([pruning](#pruning)).
2. Find an open knowledge PR (same `gh pr list` as in Bootstrap). If one is open, read its branch's files: you will draft against them, not against the base branch. If more than one is open, use the newest and list the others to the user, suggesting they merge or close them.
3. Draft the **knowledge diff**: additions, edits and removals, each in the existing file whose purpose fits (see The project owns it), with its source and a one-line reason. A changed rule, an entry this run made untrue and a stale entry are edits of the existing entry, shown as old → new, never a second entry ([rule changes](#rule-changes)). Apply the content rules. For files with a budget header, show the line count against it.
4. Ask the user to approve or edit the diff. Change nothing before they do.
5. Apply it:
   - **Extending an open PR** — check out its branch in its own worktree and apply the approved changes there as **edits to the existing entries**, never by writing whole files (that would undo the PR's pending changes and teammates' review commits):
     ```bash
     git fetch origin <branch>
     git worktree add -B <branch> "$root-wt/knowledge-pr" origin/<branch>
     ```
     Commit, push, tell the user which PR you extended, and remove the worktree.
   - **No open PR** — `git worktree add -b orch/knowledge-<YYYY-MM-DD> "$root-wt/knowledge-<YYYY-MM-DD>" origin/<base>` (add `-2` if the name is taken), apply the edits, commit, push, and open a PR whose body (in `$root/.orchestration/knowledge-pr.md`) lists each change and its reason. Remove the worktree.
6. The team reviews and merges it. You never merge it.

Project knowledge never leaves the project. Plugin edits are separate and exist only in development mode (see the orchestrating skill's wrap-up).

## When things go wrong

| Situation | Do |
|---|---|
| A knowledge PR is open at the next intake | Use the base branch's knowledge, plus the PR's if the base has none; mention the PR; extend it at wrap-up |
| A file with a budget header would go over it | Propose merges or removals in the same diff |
| Knowledge contradicts `CLAUDE.md` or the code | Flag it, record it in the ledger, follow `CLAUDE.md` or the code, fix it in the next diff |
| The goal changes a project rule | Show `Changes rule: old → new` on the plan, quote only the new rule, edit the entry in place at wrap-up |
| An entry is unused in the last 3 runs, or restates the code | Put it to the value test; propose removal only if it fails, never for a safety, data, money or regulatory rule ([pruning](#pruning)) |
| An entry names a path or function that no longer exists | Flag it as stale, don't quote it as fact, update or remove it in the next diff |
| User declines the bootstrap | Run without knowledge; ask once, in one line, at the next fresh orchestration |
| A drafted entry, reason or PR text contains a secret, record identifier or personal data | Drop the value, tell the user what kind of value you left out |
