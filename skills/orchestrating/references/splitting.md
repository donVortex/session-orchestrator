# Splitting work into tasks

## Rules

1. **Disjoint ownership.** Tasks that can run at the same time (neither depends on the other) never own the same file. A glob like `src/api/users/**` owns every file under it.
2. **PR-sized.** A worker task can be reviewed on its own as one PR and described in one brief.
3. **Foundations first.** Anything other tasks build on (schemas and migrations, shared types and interfaces, config) is its own task with no dependencies, done before the tasks that use it.
4. **Tests travel with their code.** A task owns the test files for the code it changes.
5. **Docs follow what they document.** A docs task depends on the task whose behaviour it describes, or is folded into it.

## Placement

| Placement | When |
|---|---|
| `self` | Critical: a foundation other tasks build on; high risk (auth, migrations, data, security); needs back-and-forth with the user; or so small that briefing would cost more than doing it. |
| `subagent` | Read-only research you need now to plan or to answer the user (an `orch-scout`). |
| `worker` | Self-contained, PR-sized, owns disjoint files, can be fully described in a brief. |

## Tier

Pick from [model-tiers.md](model-tiers.md) by the hardest thing in the task. Migrations and performance work are `deep`, even with a clear spec: a clear spec doesn't make hard work easy. Other schema changes and anything security-related are never `fast`.

## Example

Goal: add user profiles (table, endpoints, UI page, API docs).

| id | task | owns | depends | tier | risk | placement |
|---|---|---|---|---|---|---|
| T1 | `profiles` table + migration | `src/db/schema.ts`, `src/db/migrations/**` | — | deep | high | self |
| T2 | GET/PUT profile endpoints + tests | `src/api/users/**` | T1 | standard | normal | worker |
| T3 | profile page + tests | `src/ui/profile/**` | T1 | standard | normal | worker |
| T4 | API docs | `docs/api.md` | T2 | fast | low | worker |

T2 and T3 run at the same time and share no files. T4 waits for T2 because it documents T2's behaviour.

**A split to fix:** if T3 also needed a new `Avatar` prop in `src/ui/components/Avatar.tsx`, and another concurrent task touched that file too, the two would collide. Fix it by giving that change to one task only, or by making it a small `self` task both depend on.
