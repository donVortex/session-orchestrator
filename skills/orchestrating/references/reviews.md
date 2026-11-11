# Reviews

How every review in a run works: the worker's whole-diff review, per-piece reviews of delegated pieces, and the orchestrator's PR review. The same rules apply at every level. The aim is to catch real bugs in as few rounds as possible, and to spend the user's attention where a missed bug costs most.

## Findings

Each finding has a severity:

| Severity | Use for |
|---|---|
| `critical` | breaks for users: wrong data, lost data, a security hole, a crash on a normal path |
| `important` | wrong behaviour, a change with no test that exercises it, a broken project rule or checklist item |
| `minor` | worth fixing but changes no behaviour: naming, readability, a small gap in a test |

- **`pre-existing`** is added to any finding whose problem is already on the base branch, so this change didn't introduce it. Check the base version of the file or `git blame` before tagging it. It is never the author's job to fix.
- **Evidence:** every finding names `path:line` and what goes wrong, concretely. A finding without evidence is dropped.
- **Don't report** style points the project's linter or checklist doesn't ask for, diagnostics, or cleanup outside the change.
- **At most 3 `minor` findings** per review (the most useful ones), unless the project's checklist sets another cap.
- **Name the class:** when the same mistake appears in several places, one finding lists every place ("unchecked `findUser()` result: `a.ts:12`, `b.ts:40`, `c.ts:7`"), so the fix covers all of them.
- **The review starts with a count:** `2 important, 1 minor, 1 pre-existing`, or `Nothing to fix.` It ends with `Verdict: pass`, or `Verdict: fail` when a `critical` or `important` finding that isn't `pre-existing` remains.

What each finding leads to:

| Finding | Leads to |
|---|---|
| `critical` or `important`, introduced by the change | verified (next section), then sent back for a fix |
| `minor` | listed in the report's Risks / follow-ups and the PR body's Follow-ups; fixed only when it's a small change in owned files; never a reason to send work back |
| `pre-existing` | listed as a follow-up in the report and the PR body; never the author's job; at wrap-up it can become a task or a backlog note |

## Verify before sending work back

Before any `critical` or `important` finding sends work back, one fresh `orch-specialist` in **verify mode** checks it, never the one who found it and never you yourself, because the point is an independent second opinion: it reads the code at the cited lines, runs a test when one can show the problem, and answers `confirmed` or `refuted` with its evidence.

- Verify every such finding of one review in parallel, in one message, on the reviewed work's tier model, never below sonnet.
- Only confirmed findings go back. Count the refuted ones (see [Finding outcomes](#finding-outcomes)).
- This checks findings; it is not a second review of the change, and it looks for nothing new ([coexistence](coexistence.md#reviews)).
- Lite mode verifies only findings on guarded work ([lite mode](model-tiers.md#lite-mode)).

## Rounds

A round is one review and the fix it asks for.

- After the first round, re-review only the fix (`git diff <reviewed commit>..HEAD`), and check that each finding sent back is fixed.
- **Never repeat a finding** already reported. A finding the author answered with a reason (intentional, out of scope) stays closed, unless the reason is wrong: then it comes back once, as a new finding with that evidence.
- **Cap: 3 rounds.** When a `critical` or `important` finding is still open after the third review, stop sending the work back:
  - **worker, for its whole-diff review:** don't open the PR; report `Status: blocked` with the open findings and that the approach needs rethinking;
  - **worker, for a piece:** escalate it once ([escalation](model-tiers.md#escalation)); if it still doesn't converge, report `Status: blocked` with the open findings and that the approach needs rethinking;
  - **orchestrator, for a PR:** ask the user, with the open findings: rethink the approach (re-split, re-tier to `deep`, take it as `self`), accept the PR with the findings listed in its body, or drop it. Log it as `[ask-user]`.
- Log each round that sends work back as `[changes] T<n> round <k>: <count line>`.

## Risk tags

Every task has a risk tag, and the change sets it, not the author:

| Risk | Covers |
|---|---|
| `low` | docs, copy, tests only, purely additive code that nothing calls yet |
| `normal` | ordinary product changes |
| `high` | guarded work (security, authentication, money, deleting data, migrations), CI and workflow files, build, deploy and dependency changes, and every path the project's review checklist lists as sensitive |

- Set it at breakdown. At review, check it again against the actual diff and raise it when the diff touches a high-risk path; never lower it.
- **Merge requests group PRs by risk**, highest first:
  - `high`: one PR at a time, with "read this diff yourself, especially <files>", because the reviews don't replace your reading of a high-risk change;
  - `normal`: skim the diff;
  - `low`: safe to merge after a glance.
- **The PR body** has Goal, Changes, Verification (commands → results, then the brief's `still to do` checks under that label, never as passed), Risk (the tag and why), How to revert (revert the merge commit, plus any data or migration steps; just "revert the merge commit" when nothing else is needed), and Follow-ups (the `minor` and `pre-existing` findings).

## Check the base branch after merges

Each PR is tested on its own; after merges, check that they work together, which is what a merge queue would do.

- **When:** after the user merges PRs, before starting the tasks they unblock, and once more at wrap-up.
- **How:** if the base branch has CI, read its latest run for the merge commit (`gh run list --branch <base> --limit 1 --json headSha,status,conclusion`). Otherwise fetch the base and run the test, lint and build commands in a temporary detached worktree, exactly as in the review step, then remove it.
- **Green:** log `[event] base check: green @ <sha>`, and start the unblocked tasks.
- **Red:** log `[failed] base red after merging T<n>, T<m>`. Start nothing that depends on it. Find which change broke it, fix it as a `self` task (its risk set by its own diff), and tell the user; ask them only when the cause isn't clear.

## The project's own review rules

- The project's review checklist (`.claude/orchestrator/review-checklist.md` or the file that serves that purpose) applies to every review.
- If the project has a `REVIEW.md` (at the repo root or in `.claude/`), every review also reads it. Where the two disagree, `REVIEW.md` wins, because the team wrote it. Briefs name it in their Review checklist field. Never rewrite it.

## Finding outcomes

Count what happened to the `critical` and `important` findings, so the reviews can get less noisy over time:

- **fixed**, **refuted** (by verification), **answered** (the author gave a reason, such as intentional or out of scope), plus the `pre-existing` and `minor` findings listed as follow-ups.
- Workers put the counts in their report (`- Review findings:`). The orchestrator adds its own PR review's counts and logs `[event] T<n> findings: fixed <n>, refuted <n>, answered <n>, pre-existing <n>, minor <n>`.
- At wrap-up these feed the learning ([findings to proposals](workflow-learning.md#findings-to-proposals)).
