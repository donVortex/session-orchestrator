---
name: working
description: Use when this session was started by session-orchestrator as a worker, or its prompt is a task brief that names session-orchestrator:working.
---

# Working a task

You deliver **one task as one PR**, writing it yourself and using subagents only where they pay, then report back to the orchestrator with a retro. The brief is your contract.

## 1. Read the brief

- If the brief names a canonical file, that file wins wherever the prompt differs from it (the app may turn `@` into `＠`).
- **Project rules** in the brief are binding, like the off-limits list. The full knowledge is in `.claude/orchestrator/` in your worktree; read it when the brief points there.
- **Skills** in the brief: make sure each named skill is used for its subtasks — load it yourself for code you write, and name it in the prompt of each subagent that does that subtask. A named skill missing from your session → carry on without it and note a `[tooling]` retro point.
- **Owned files** are the only files you and your subagents may change. The off-limits list is binding.
- **A brief from an older plugin version** can lack fields this version adds. Use the defaults and never block on it: no `Risk:` line → `normal`, raised to `high` if your diff touches a high-risk path ([risk tags](../orchestrating/references/reviews.md#risk-tags)); no `Mode:` line → `full`; no tier hints → pick tiers yourself. Note it once in the retro as `[brief] older brief: no <fields>`. Missing goal, acceptance criteria or owned files are different: those you ask about.
- Unclear goal, acceptance criteria, or a need to touch a file you don't own → ask; never guess. Write the report with `Status: blocked` and a `## Question` section (see [report-format.md](report-format.md)), then end your turn. Ending the turn wakes the orchestrator; its answer arrives in this same conversation.

## 2. Plan the pieces

Read [model-tiers.md](../orchestrating/references/model-tiers.md). The brief's `Subtasks` are your starting pieces: give each its files, a tier and what it depends on, and follow the brief's tier hints (they carry the project's learned `Tier:` entries): go higher only for a reason you note in the retro, never lower. A piece whose tier hint is `deep` in a task that isn't goes to `specialist (opus)` (`harder than the task's tier`): you can't change your own model. Follow the brief's `Worker plan:` hints the same way: a piece whose kind and area match one gets what it says, and a `Worker plan: subagents …` hint counts as `too big for one context` (learned).

**`me` is the default:** you write each piece yourself, in this session. A piece goes to a subagent only in one of these four cases, and the plan names the case in **Why**:

| Case (Why) | How | Model |
|---|---|---|
| `read-only`: a broad search, lookups, summaries | `scout (haiku)`: `orch-scout` | haiku |
| `too big for one context`: many files, bulk edits, a long migration | `subagents, <n> batches`: `orch-implementer` | the piece's tier, never haiku |
| `independent, run in parallel`: pieces with no shared files or dependencies, worth doing at the same time | `parallel`: `orch-implementer`, one per piece | the piece's tier |
| `harder than the task's tier`: one piece that needs more than your session's model | `specialist (opus)`: `orch-specialist` in build mode | opus |

When the orchestrator works a `self` task with this loop, it writes only trivial pieces itself and gives every other piece to a subagent with the reason `orchestrator context`: its session has to last the whole run.

If the brief says `Mode: lite`: give no piece `deep` unless it touches security, authentication, money, deleting data or migrations, and delegated pieces get one combined review (spec and quality in one pass) instead of two. Escalation on failure stays as it is.

Before writing or dispatching anything, post the plan:

| Piece | Files | How | Why |
|---|---|---|---|
| A. schema change | `src/db/…` | me | |
| C. find every caller of `oldName` | — | scout (haiku) | read-only |

## 3. Do the work

**Pieces marked `me`:** one at a time, test-first: the new test runs and fails for the right reason before any implementation exists, then minimal code, then the test passes. After each piece, the full suite runs and the piece is committed. Not green → fix before the next piece. A piece whose `Worker plan:` hint says `per-piece reviews` gets the per-piece reviews below even though you wrote it.

**Delegated pieces** run as batches, and keep per-piece reviews, so delegating never lowers the bar:
1. **Implement** — send all of a batch's Agent calls **in one message**; that is what runs them in parallel, up to `max_parallel_implementers_per_session`. Every call passes `model` from the table above. Its prompt: the piece's goal, its files (and that nothing else may change), the test command scoped to its own test files (e.g. `node --test <file>`), the skills the brief names for this piece (to load with the Skill tool), "do not commit". Only the gate runs the full suite: parallel siblings' half-written tests would fail it.
2. **Review** — for each finished piece, a spec-compliance review (does exactly what the piece says, only in its files), then a code-quality review that also checks the brief's **Review checklist** (its named sections, or the items quoted in it); in lite, one combined review. Use `orch-specialist` in review mode, model = the piece's tier model but never below sonnet; its findings follow [reviews.md](../orchestrating/references/reviews.md#findings). Wait for every implementer and review subagent in the same turn; never end your turn while one is still running. If the brief names a review skill, the code-quality reviewer applies its criteria with the Review checklist in the same pass — the review skill doesn't add another review on top, and no nested reviewers; if it can't be loaded, the reviewer still reviews with the checklist.
3. **Fix** — first verify each `critical` or `important` finding with `orch-specialist` in verify mode, all in one message ([how](../orchestrating/references/reviews.md#verify-before-sending-work-back)); send only the confirmed ones back, with every place the finding lists. Re-review only the fix. `minor` and `pre-existing` findings don't go back: list them as follow-ups. After [3 rounds](../orchestrating/references/reviews.md#rounds) with a confirmed finding still open, escalate the piece once; if it still doesn't converge, report `Status: blocked` with the open findings.
4. **Gate** — commit the batch, run the full test suite. Not green → fix before the next piece.

**If your context is compacted mid-task** (you can tell: your earlier conversation has been replaced by a summary): note a `[context]` retro point (what was handed off, and why), and hand the remaining non-trivial pieces to subagents (`too big for one context`): details lost to compaction shouldn't decide the rest of the task. Trivial pieces (a few lines in a file you have open) stay with you.

**Other skills and plugins.** The brief is your contract, and the brief is the approved plan: skip other skills' own brainstorming, planning and confirmation steps (the approved brief is the confirmation; your plan in step 2 still applies), and plan documents never go into the PR. You are already in your worktree: never create a worktree, and never merge, discard or remove the worktree — you push and open a PR (step 7). Questions go into the report (step 1), never to the user. Skills that change how a step is done inside your owned files (test-driven development, framework and domain skills) are welcome; the plan and model rules here win ([coexistence.md](../orchestrating/references/coexistence.md)). With or without other skills, every piece — including code you write yourself — runs the new test and sees it fail for the right reason **before** any implementation exists; then minimal code, then the test passes.

## 4. Review the whole diff

Before the PR, run **one** fresh review of the whole change: `orch-specialist` in review mode, sonnet for `low` and `normal` risk, opus for `high` risk, in lite too. It reviews the diff against the brief: spec compliance, code quality, and the brief's **Review checklist** (its named sections, or the items quoted in it), in a single pass. It sees the whole change, so it also catches problems between pieces. If the brief names a review skill, the reviewer applies its criteria and the Review checklist in the same pass — no nested reviewers: if the skill would dispatch its own reviewer, the reviewer does that review itself; if it can't be loaded, the reviewer still reviews with the checklist and you note a `[tooling]` point ([why](../orchestrating/references/coexistence.md#reviews)). Run it in the foreground and wait for it in the same turn: ending your turn while a subagent runs wakes the orchestrator with no report. Findings follow [reviews.md](../orchestrating/references/reviews.md#findings): verify each `critical` or `important` one before fixing it ([how](../orchestrating/references/reviews.md#verify-before-sending-work-back)), fix the confirmed ones, list `minor` and `pre-existing` ones as follow-ups, and stop after [3 rounds](../orchestrating/references/reviews.md#rounds). If the whole-diff review still has a confirmed `critical` or `important` finding after the third round, don't open the PR: report `Status: blocked` with the open findings and that the approach needs rethinking. This review is never skipped, however small the change.

## 5. Escalate

A piece you wrote that stays red, or still has a confirmed finding after 3 rounds, goes once to the next tier up as a delegated piece (`specialist (opus)` for a `standard` or `deep` piece, an `orch-implementer` on sonnet for a `fast` one), with what you tried; note it as a `[tier]` retro point. If that fails too, report `Status: failed` with what happened.

A subagent that fails or returns weak work: if it had no runnable check (a scoped test or build), give it one and retry on the same tier; otherwise retry once on the next tier up ([order](../orchestrating/references/model-tiers.md#escalation)). Note it as a `[tier]` retro point. A second failure: report `Status: failed` with what happened.

## 6. Verify

Run the full test, lint and build commands and read the output. If your worktree's dependencies are linked from the main checkout (a `node_modules` junction or symlink), never run an install there, including a command that would install a missing tool: it writes into the main checkout. Report it as a `[tooling]` point instead. You may only claim done with that output in hand (and a verification skill's checks, if one is installed). Check `git diff --name-only <base>...HEAD` lists only owned files.

## 7. Open the PR

`git push -u origin HEAD:<branch>`, where `<branch>` is the one the brief names (default `orch/<task-id>`; your local branch name may differ). Then write the PR body — Goal, Changes, Verification (commands → results, then the brief's `still to do` checks under that label, never as passed), Risk (the brief's tag, raised if your diff touches a high-risk path, and why), How to revert, Follow-ups (`minor` and `pre-existing` findings) — ([details](../orchestrating/references/reviews.md#risk-tags)) to `<report dir>/T<n>-pr.md` and run `gh pr create --base <base> --head <branch> --title "T<n>: <task>" --body-file <that file>`. Never pass the body inline: a line starting with `#` gets the command rejected. Never force-push, and never push to the base branch.

## 8. Report

Write the report in [report-format.md](report-format.md) to the brief's report path. On the desktop backend, read your own context fill first with `mcp__ccd_session_mgmt__get_usage` (`session_id: "self"`) for its Work line; if the tool isn't there or reports it unavailable, write `n/a`. When the brief names "the shared notes folder your session instructions name" instead of a path, use that folder. Then end your turn with one line: `T<n> done, PR <url>, report at <path>`.

The report path is outside your worktree. If the write is refused, don't route around the refusal with another tool: end your turn with the full report in your final message, then the line `T<n> done, PR <url>, report in final message`. The orchestrator saves it.

Review fixes from the orchestrator arrive in this same conversation: answer each finding, either fixed (in a commit) or not fixed with a reason (intentional, out of scope); fix on the same branch, push, re-verify, and rewrite the report (add new retro points; keep the old ones).

## Common mistakes

| Mistake | Instead |
|---|---|
| Parallel subagent calls in separate messages | One message per batch of delegated pieces, or nothing runs in parallel |
| A subagent without one of the four reasons | Write the piece yourself, or name the reason in the plan |
| Leaving out `model` | Every Agent call passes the rubric's model |
| A subagent changed a file it doesn't own | Revert that change; redo the piece inside its files |
| "Tests should pass" | Run them; quote the real result |
| Implementation written before a red test run | Delete it, run the test, see it fail, then implement |
| Skipping the whole-diff review | No path has zero reviews, however small the change |
| The brief requires exact source text (escapes like `̀`, exact strings) | Grep the file for that text before committing; file-writing tools can turn escapes into the literal characters |
| Changed a test, lint or build script and only saw it pass | Show it failing on a deliberately bad input too |
| Guessing on an unclear brief | Ask (step 1) |
| Retro like "brief could be clearer" | Say exactly what was missing, tagged |
| Learned a project rule or fact and kept it to yourself | Add it as a `[domain]` retro point, so it reaches the project's knowledge |
