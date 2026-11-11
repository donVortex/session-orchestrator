# Worker brief template

The brief is the worker's whole contract; it sees nothing else from this conversation. Workers block and ask on anything missing or contradictory, so fill every field. Save each brief to `.orchestration/briefs/T<n>.md` before sending it.

```markdown
# Brief: T<n> · <short task>

Load the session-orchestrator:working skill and follow it.
Canonical brief: `<$root>/.orchestration/briefs/T<n>.md`. The app may deliver `@` as `＠` in this prompt; where the prompt and the file differ, the file wins.

- Goal: <one or two sentences, with the concrete names and values the work needs: field names, setting names, request/response and error shapes>
- Acceptance: <checkable criteria, each with how it is verified>
- Style reference: <an existing file whose patterns to follow, or "none">
- Project rules: <the project's rule entries relevant to this task, quoted (never one that contradicts `CLAUDE.md`, never a stale one, and only the new version of a rule the goal changes), or "none"> (binding, like the off-limits list)
- Review checklist: <the project's checklist file — sections: its always-check section, the areas this task touches; plus `REVIEW.md` if the project has one>; if the knowledge isn't on the base branch yet, quote the items themselves; "none" if the project has no knowledge
- Skills: <skill> (<subtask / why>) · review: <review skill or none> — only skills from the skills look or the project's `Skill:` entries; the review skill only from a `Skill:` entry or the user (default `none`)
- Owned files: <files/globs, including their test files>
- Off-limits: every other file (name tempting neighbours explicitly, e.g. `src/db/schema.ts`)
- Commands: test `<cmd>`, lint `<cmd>`, build `<cmd>`
- Base branch: `<branch>` (already contains: <merged dependency PRs, or "nothing extra">)
- PR branch: `orch/T<n>` (or `orch/T<n>-<slug>` if that name was taken; see ledger.md). Your worktree folder and local branch may have other names (the app picks them, and may reuse an old folder); this PR branch is the one that counts.
- Tier: <fast|standard|deep> — session <model> / <effort>
- Risk: low | normal | high — <why, in a few words> ([risk tags](reviews.md#risk-tags)); goes into the PR body with How to revert
- Mode: full | lite — lite: no `deep` subtasks except guarded work (security, authentication, money, deleting data, migrations); one combined review per subtask; the small-task path whenever the task fits one subtask ([lite mode](model-tiers.md#lite-mode))
- Orchestrator: desktop | CLI mode
- Report path: CLI mode: `<$root>/.orchestration/reports/T<n>.md` (absolute; `$root` as resolved in ledger.md). Desktop: `<notes>/T<n>-report.md` in the app's shared notes folder ([backend-desktop.md](backend-desktop.md#reports-and-permissions)). It is outside your worktree: if the write is refused, put the full report in your final message instead, and the orchestrator saves it.
- Subtasks (files, tier hint, dependencies):
  - A. <what> — <files> — <tier> — depends on: none
  - B. <what> — <files> — <tier> — depends on: A
- Context: <what earlier tasks produced that this one uses: signatures, table columns, endpoints, with file paths>
- Lessons from earlier tasks: <retro points that apply here, or "none">

Report in the format of the working skill's report-format.md, then send: `T<n> done, PR <url>, report at <path>`.
```

## Check before sending

| Check | Why |
|---|---|
| Every test the acceptance criteria require has its test file in **Owned files** | Otherwise the worker can't write the tests and blocks |
| Test, lint and build commands are given | Otherwise the worker can't verify and blocks |
| Every subtask lists its files and dependencies (`none` is a value) | Workers batch on these; a missing dependency gets guessed |
| Skills names only skills seen in the skills look or in `Skill:` entries | A made-up skill name makes the worker hunt for it |
| Names, shapes and values the work needs are written out | "use the settings from the goal" fails when the goal has none |
| Owned files don't overlap any task that can run at the same time | See [splitting.md](splitting.md) |
| Report path: CLI → absolute, in the main checkout's `.orchestration/reports/`; desktop → the app's shared notes folder | Workers run in their own worktrees, and the desktop app blocks their writes to the main checkout |
| The brief names its canonical file path | The desktop app rewrites `@` in prompts |
| Project rules quote the `domain.md` entries for this task's area | Workers can't follow rules they weren't given |
| A dependent change of a few lines (a re-export, a barrel line) is folded into the subtask it depends on | A one-subtask plan takes the working skill's small-task path (one implementer, one review) instead of the full batch loop |
