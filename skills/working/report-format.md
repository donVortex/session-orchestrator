# Worker report format

Every worker ends with exactly one report, written to the path in its brief (`<main checkout>/.orchestration/reports/<task-id>.md` in CLI mode, the app's shared notes folder in desktop mode). The orchestrator reads these headings, so keep them exactly.

```markdown
# T<n> report
Status: done | blocked | failed
PR: <url, or "none">

## Result
- Changed: <files and what changed, one line each>
- Verified by: <command> → <real outcome>   (one line per command: tests, lint, build)
- Risks / follow-ups: <anything the reviewer should look at, plus the `minor` and `pre-existing` review findings; "none" if none>
- Review findings: fixed <n> · refuted <n> · answered <n> · pre-existing <n> · minor <n>   (the `critical` and `important` findings of all your reviews, by what happened to them; [reviews.md](../orchestrating/references/reviews.md#finding-outcomes))
- Work: native · subagents: <list or none> · review: <model> ×<n>, <k> round(s) · context at report: <p>% | n/a · compacted: yes | no

## Subtasks
| Subtask | Kind | Tier | Outcome | Review found |
|---|---|---|---|---|
| A | <kind of work, in a few words: "pure data mapping", "state machine change", "UI wiring"> | fast / standard / deep | first try / escalated to <tier> / failed | nothing / minor / important |

## Retro
### Went well
- [tag] <what helped, concretely>
### Went badly
- [tag] <what cost time or quality, concretely>
### Improve
- [tag] <a concrete change to a brief, the split, the rubric, tooling or the codebase>
```

**Work** says how the task was done, so the orchestrator can compare native work across runs. List subagents as `<role> <model> ×<n>` (`scout haiku ×2`), adding the piece and its reason for anything but a scout (`implementer sonnet ×3 (D: too big)`); `review` is the whole-diff review. **Context at report** is your context window's fill as the app reports it; write `n/a` on the CLI backend or when the app reports it unavailable, never an estimate. **Compacted** is `yes` if your context was compacted during the task.

One row per piece, yours included: **Tier** is the tier the piece ran on (your session's tier for a piece you wrote), so the orchestrator keeps learning tiers per kind of work. **Tier** is the tier it started on; **Outcome** says whether that tier passed its review on the first try; **Review found** is the most serious finding of its review. The orchestrator learns subtask tiers from this table, so keep the kind of work comparable across tasks.

For `Status: blocked`, add a `## Question` section after `## Result` with the one question you need answered and the options you see.

## Tags

| Tag | Use for |
|---|---|
| `brief` | the brief was unclear, wrong or missing something |
| `split` | the task boundary or file ownership was wrong |
| `tier` | a model was too weak or more than needed; escalations |
| `parallelism` | parallel batches helped, or collided |
| `context` | your context was compacted mid-task, and what you handed off after it |
| `tooling` | commands, permissions, scripts, CI, and skills that helped, got in the way, or were missing — e.g. "stripe-best-practices caught a missing idempotency key", "X tried to write a plan file; skipped", "named skill X not available in this session" |
| `codebase` | the code itself made the work harder or easier |
| `process` | anything about the working loop itself |
| `domain` | a rule, term or codebase fact the project's knowledge (`.claude/orchestrator/`) should record — state the rule, not the value: "MRNs may contain dashes", never a real record ID or personal data |

## Rules

- One point per line, tag first.
- Every "Went badly" point gets a matching "Improve" point with the same tag.
- Concrete beats general: "brief didn't say errors are `{code, message}`" — not "brief could be clearer".
- An empty section is `- none`, never omitted.
