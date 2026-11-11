---
name: working
description: Use when this session was started by session-orchestrator as a worker, or its prompt is a task brief that names session-orchestrator:working.
---

# Working a task

You deliver **one task as one PR**, using subagents whose model is picked by tier, then report back to the orchestrator with a retro. The brief is your contract.

## 1. Read the brief

- If the brief names a canonical file, that file wins wherever the prompt differs from it (the app may turn `@` into `＠`).
- **Project rules** in the brief are binding, like the off-limits list. The full knowledge is in `.claude/orchestrator/` in your worktree; read it when the brief points there.
- **Skills** in the brief: make sure each named skill is used for its subtasks — load it yourself for code you write, and name it in the prompt of each subagent that does that subtask. A named skill missing from your session → carry on without it and note a `[tooling]` retro point.
- **Owned files** are the only files you and your subagents may change. The off-limits list is binding.
- Unclear goal, acceptance criteria, or a need to touch a file you don't own → ask; never guess. Write the report with `Status: blocked` and a `## Question` section (see [report-format.md](report-format.md)), then end your turn. Ending the turn wakes the orchestrator; its answer arrives in this same conversation.

## 2. Plan in batches

Read [model-tiers.md](../orchestrating/references/model-tiers.md). Split the task into subtasks; give each its files, a tier and what it depends on, and follow the brief's tier hints (they carry the project's learned `Tier:` entries): go higher only for a reason you note in the retro, never lower.

If the brief says `Mode: lite`: give no subtask `deep` unless it touches security, authentication, money, deleting data or migrations; take the small-task path whenever the task fits one subtask; and review each subtask with one combined review (spec and quality in one pass) instead of two. Escalation on failure stays as it is.

- **Same batch**: subtasks whose files don't overlap and that don't depend on each other — up to `max_parallel_implementers_per_session`.
- **Later batch**: a subtask that shares a file with, or depends on, an earlier one.

Before dispatching anything, post the plan:

| Batch | Subtask | Files | Tier | Model |
|---|---|---|---|---|

followed by the line: `The full test suite runs after each batch, before the next one starts.`

**Small task** — the plan has exactly **one** subtask: skip the batch loop below.
1. Post a one-line plan: the subtask, its files, and `small task: I write it; one review`.
2. Write it yourself, test-first (red run before any implementation, then green).
3. Run **one** review subagent: `orch-specialist` in review mode, sonnet or above, covering spec compliance, code quality and the brief's **Review checklist** (its named sections, or the items quoted in it) in a single pass. If the brief names a review skill, the reviewer applies its criteria and the Review checklist in the same pass — no nested reviewers: if the skill would dispatch its own reviewer, the reviewer does that review itself; if it can't be loaded, the reviewer still reviews with the checklist and you note a `[tooling]` point ([why](../orchestrating/references/coexistence.md#reviews)). Run it in the foreground and wait for it in the same turn: ending your turn while a subagent runs wakes the orchestrator with no report. Findings follow [reviews.md](../orchestrating/references/reviews.md#findings): verify each `critical` or `important` one before fixing it ([how](../orchestrating/references/reviews.md#verify-before-sending-work-back)), fix the confirmed ones, list `minor` and `pre-existing` ones as follow-ups, and stop after [3 rounds](../orchestrating/references/reviews.md#rounds).
4. Continue at step 5. Review is never skipped, however small the change.

Two or more subtasks always use the batch loop.

## 3. Run each batch

1. **Implement** — send all of the batch's Agent calls **in one message**; that is what runs them in parallel. Every call passes `model` from the rubric:
   - `fast`, `standard` → `orch-implementer`; `deep` → `orch-specialist` (build mode).
   - Its prompt: the subtask goal, its files (and that nothing else may change), the test command scoped to its own test files (e.g. `node --test <file>`), the skills the brief names for this subtask (to load with the Skill tool), "do not commit". Only the gate runs the full suite: parallel siblings' half-written tests would fail it.
2. **Review** — for each finished subtask, a spec-compliance review (does exactly what the subtask says, only in its files), then a code-quality review that also checks the brief's **Review checklist** (its named sections, or the items quoted in it). Use `orch-specialist` in review mode, model = the subtask's tier model but never below sonnet; its findings follow [reviews.md](../orchestrating/references/reviews.md#findings). Reviews of different subtasks run in parallel. Wait for every implementer and review subagent in the same turn; never end your turn while one is still running. If the brief names a review skill, the code-quality reviewer applies its criteria with the Review checklist in the same pass — the review skill doesn't add another review on top, and no nested reviewers; if it can't be loaded, the reviewer still reviews with the checklist.
3. **Fix** — first verify each `critical` or `important` finding with `orch-specialist` in verify mode, all in one message ([how](../orchestrating/references/reviews.md#verify-before-sending-work-back)); send only the confirmed ones back to an implementer, with every place the finding lists. Re-review only the fix. `minor` and `pre-existing` findings don't go back: list them as follow-ups. After [3 rounds](../orchestrating/references/reviews.md#rounds) with a confirmed finding still open, escalate the subtask once; if it still doesn't converge, report `Status: blocked` with the open findings.
4. **Gate** — commit the batch, run the full test suite. Not green → fix before the next batch.

**Other skills and plugins.** The brief is your contract, and the brief is the approved plan: skip other skills' own brainstorming, planning and confirmation steps (the approved brief is the confirmation; your batch plan in step 2 still applies), and plan documents never go into the PR. You are already in your worktree: never create a worktree, and never merge, discard or remove the worktree — you push and open a PR (step 6). Questions go into the report (step 1), never to the user. Skills that change how a step is done inside your owned files (test-driven development, framework and domain skills) are welcome; the batching and model rules here win ([coexistence.md](../orchestrating/references/coexistence.md)). With or without other skills, every subtask — including code you write yourself — runs the new test and sees it fail for the right reason **before** any implementation exists; then minimal code, then the test passes.

## 4. Escalate

A subagent that fails or returns weak work: retry once on the next tier up and note it as a `[tier]` retro point. A second failure: report `Status: failed` with what happened.

## 5. Verify

Run the full test, lint and build commands and read the output. If your worktree's dependencies are linked from the main checkout (a `node_modules` junction or symlink), never run an install there, including a command that would install a missing tool: it writes into the main checkout. Report it as a `[tooling]` point instead. You may only claim done with that output in hand (and a verification skill's checks, if one is installed). Check `git diff --name-only <base>...HEAD` lists only owned files.

## 6. Open the PR

`git push -u origin HEAD:<branch>`, where `<branch>` is the one the brief names (default `orch/<task-id>`; your local branch name may differ). Then write the PR body — Goal, Changes, Verification (commands → results), Risk (the brief's tag, raised if your diff touches a high-risk path, and why), How to revert, Follow-ups (`minor` and `pre-existing` findings) — ([details](../orchestrating/references/reviews.md#risk-tags)) to `<report dir>/T<n>-pr.md` and run `gh pr create --base <base> --head <branch> --title "T<n>: <task>" --body-file <that file>`. Never pass the body inline: a line starting with `#` gets the command rejected. Never force-push, and never push to the base branch.

## 7. Report

Write the report in [report-format.md](report-format.md) to the brief's report path. When the brief names "the shared notes folder your session instructions name" instead of a path, use that folder. Then end your turn with one line: `T<n> done, PR <url>, report at <path>`.

The report path is outside your worktree. If the write is refused, don't route around the refusal with another tool: end your turn with the full report in your final message, then the line `T<n> done, PR <url>, report in final message`. The orchestrator saves it.

Review fixes from the orchestrator arrive in this same conversation: answer each finding, either fixed (in a commit) or not fixed with a reason (intentional, out of scope); fix on the same branch, push, re-verify, and rewrite the report (add new retro points; keep the old ones).

## Common mistakes

| Mistake | Instead |
|---|---|
| Agent calls in separate messages | One message per batch, or nothing runs in parallel |
| Leaving out `model` | Every Agent call passes the rubric's model |
| A subagent changed a file it doesn't own | Revert that change; redo the subtask inside its files |
| "Tests should pass" | Run them; quote the real result |
| Implementation written before a red test run | Delete it, run the test, see it fail, then implement |
| "It's tiny, I'll skip the review" | One subtask → the small-task path, which still has one review. No path has zero |
| The brief requires exact source text (escapes like `̀`, exact strings) | Grep the file for that text before committing; file-writing tools can turn escapes into the literal characters |
| Changed a test, lint or build script and only saw it pass | Show it failing on a deliberately bad input too |
| Guessing on an unclear brief | Ask (step 1) |
| Retro like "brief could be clearer" | Say exactly what was missing, tagged |
| Learned a project rule or fact and kept it to yourself | Add it as a `[domain]` retro point, so it reaches the project's knowledge |
