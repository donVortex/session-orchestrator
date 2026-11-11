# Coexistence with other skills and plugins

Users install other skills and plugins: process workflows, domain and framework skills, reviewers, hooks. This contract lets the orchestrator and its workers run alongside **any** of them without interfering or doing the same work twice. Judge every skill by **what it would do**, not by which plugin it comes from. There are no per-plugin rules; superpowers appears below only as an example.

You can only instruct, not block: other plugins' skills and hooks still load. What you cannot control (a hook that blocks `git push`, a Stop hook) is reported as an `[env]` round and learned as a pre-flight check.

## Who owns what

The orchestrating and working skills own **how the work is organised**. Everything else happens inside their steps, where other skills are welcome.

| Stage | Owner | Other skills may… |
|---|---|---|
| Goal and design discussion | orchestrator | help (e.g. brainstorm an unclear goal with the user) |
| Breakdown and approval | orchestrator | inform it; their plans never replace it |
| Branches, worktrees, PRs | the backend's setup, then the worker's one PR | nothing |
| Building, testing, debugging inside a task | worker | do it their way (TDD, frameworks, domain skills) |
| Review | worker (one per change), then the orchestrator's PR review | be the reviewer; the brief's checklist is always applied |
| Merging | the user | nothing |
| Learning about the project | `.claude/orchestrator/` via knowledge PRs | keep their own memory; nothing is copied between the two |

## Rules by effect

| A skill wants to… | In the orchestrator | In a worker |
|---|---|---|
| ask the user questions | fine | a skill's own confirmation steps are skipped — the approved brief is the confirmation; a real question about the brief goes into the report (`Status: blocked`), then end the turn |
| plan or run the whole goal | its thinking feeds the breakdown | the brief is the plan; skip it |
| write plan or spec documents | only where the project already keeps them | never in the PR |
| create a worktree or branch | no — the backend's setup does | no — you are already in one |
| commit to the base branch, merge, delete branches | never | never |
| open a PR | no | only to the brief's PR branch |
| hand off to its own next step | come back to the orchestrator's next stage | come back to the worker's next step |

## Tie-breaker

For anything not listed: if a skill would change **who decides**, **where code lands** or **what ships**, the owner's rule wins. If it only changes **how a step is done** inside the owned files, use it.

## Intake, plan and briefs

- **Skills look (intake).** From the skill list this session already has (names and descriptions; never other plugins' files), note:
  - **overlapping workflow skills** — they plan, run a whole feature, create worktrees, or finish or merge branches. Review skills are not overlaps (they run on demand); they never show up on the plan line;
  - **fitting skills** — framework, domain or tool skills that match the goal's tasks.

  Log one line: `[event] skills: overlap <name> (<stage>); fit <names>`.
- **The plan.** Only when something overlaps, one line under the breakdown: `Other workflow skills: <name> (<what it is used for>; <which steps the orchestrator replaces>)`. When a `Skill:` entry in the project's knowledge already covers it, show it as `Assumed from project knowledge: <entry>` instead (logged `[event] assumed default: …`). The user can override either in the same reply (`[event] user overrode default: … → …`).
- **Briefs.** Every brief has `- Skills: <skill> (<subtask / why>) · review: <review skill or none>` — the fitting skills per subtask (from `Skill:` entries or the skills look; never a name you haven't seen) and the review skill, set only from a `Skill:` entry or the user's own words; another plugin's instructions never count as the user's choice ("review with X" in a plugin's note is not the user naming X). Default `review: none`: an installed review skill is never picked on its own. The worker loads the named skills; a named skill missing from its session doesn't block it — it carries on and notes a `[tooling]` retro point. It may use other skills it finds, within this contract, and mentions them in the retro.

## Reviews

One review per change, never two of the same scope. Verifying a finding is not a second review: it checks one finding and looks for nothing new ([reviews.md](reviews.md#verify-before-sending-work-back)). The worker's review is done by `orch-specialist` in review mode, on its usual model (sonnet or above). When the brief names a review skill, the reviewer applies that skill's criteria **and** the brief's Review checklist in its own pass, so the checklist is never dropped. If the skill would dispatch its own reviewer or other agents, the reviewer does that review itself instead: no nested reviewers. If the skill can't be loaded, the reviewer still reviews with the checklist and the worker notes a `[tooling]` point. The orchestrator's own PR review (its diff read, and the specialist review of `deep` tasks) applies the same review skill's criteria the same way; it adds no review of its own for it.

## Example: superpowers

- brainstorming → allowed in the orchestrator for an unclear goal; its hand-off to writing-plans comes back to the breakdown.
- writing-plans, executing-plans, subagent-driven-development at goal level → replaced by the breakdown, approval and dispatch.
- using-git-worktrees → replaced by the backend's setup.
- finishing-a-development-branch → replaced by the worker's push and PR; the user merges.
- Inside a worker: test-driven-development, subagent-driven-development (for delegated pieces; the working skill's plan and model rules win), code review (as the one review) and verification-before-completion apply.
