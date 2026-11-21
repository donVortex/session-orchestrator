---
max_turns: 8
allowed_tools: [Read, Glob, Grep, Skill]
tags: [specialist, ui-review]
---

First load the session-orchestrator:orchestrating skill with the Skill tool, then read its `references/reviews.md` (in the skill's base directory) and the plugin's `agents/orch-specialist.md`. You are now the `orch-specialist` in **UI review mode**, called by the orchestrator for PR #95 in github.com/acme/home-money. You can't open images here, so the orchestrator describes them.

**Brief, T44 · Expenses page rebuilt on the new design.** Goal: the Expenses page in the new style, same features. Good looks like: "a dense table, no modals; amounts right-aligned with two decimals; filters in a left sidebar on desktop, behind a Filters button on phones". The goal had a look gate; the approved mockup (`mockups/expenses.png`) shows a compact table with 13 px text and a filter sidebar.

**Base branch's Expenses page** (old screen): a table, a search box, a "Filters" panel, a row menu with Edit and Delete, and an **Export CSV** button above the table on every width.

**Screenshots in `reports/T44/`** (described):
- `expenses-1280@1.png`, light theme: the table with 13 px text, filter sidebar on the left, amounts right-aligned with two decimals, search box. No Export CSV button anywhere. Matches the mockup otherwise.
- `expenses-375@2.png`, light theme: the table scrolls sideways; a "Filters" button opens the filters. No Export CSV button.
- No dark-theme screenshot, and no screenshot of the page with no expenses.

**Diff excerpt** (`src/pages/Expenses.tsx`):
```tsx
<button className="icon-btn" onClick={openRowMenu}><DotsIcon /></button>
...
{expenses.length === 0 && null}
```

Write your review.
