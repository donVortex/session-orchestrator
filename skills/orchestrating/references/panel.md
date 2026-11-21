# User panel

The expert view asks professionals. The panel asks the people who use or pay for the product: personas kept in the product knowledge, each walking through a plan, a task or PR, or screens, and saying where they'd get stuck. It's a cheap way to find problems before building, not user research: personas are synthetic, and the panel says so every time.

## Personas

The product knowledge's Users section holds 2–4 personas, a few lines each:

```markdown
- **Landlord with three flats**: wants rent and costs per flat at a glance. Checks it monthly on a laptop; enters bills on the phone the day they arrive. Not an accountant. Frustrated by having to find which flat a bill belongs to. _(your understanding)_
```

- **Goal, context, constraints, frustration**, in a sentence or two each. The [value test](knowledge.md#content-rules) applies: what Claude would otherwise get wrong about these users, not a generic profile.
- **Every persona names its source:** `your understanding` (the default), `client conversation, <date>`, or `usage data: <what>` ("80% of sessions are on phones"). Several sources are listed together.
- **Composites, never a real person's name**, no quotes that would identify anyone, and no records: the [content rules](knowledge.md#content-rules) for personal data apply in full.
- More than 4 personas: propose merging the closest ones in the knowledge diff, rather than adding a fifth.

### How personas get in

1. **The product questions.** When the user answers *"Who uses this?"* ([product knowledge](knowledge.md#product-knowledge)), draft 2–4 personas from the answer and show them in that run's knowledge diff.
2. **The first panel request with none.** Draft them from the product knowledge and what the repo shows (user roles and permissions, onboarding copy, which screens exist for whom), each marked `your understanding`, and show them for approval before the panel runs. Approved ones go into the wrap-up's knowledge diff.
3. **The user, any time:** "add a persona: …", or notes pasted from a client call or a usage report. Turn them into a composite with its source and date, and add it to the knowledge diff.
4. **Corrections.** A `[correction]` about how users behave ("no, landlords never do that monthly") becomes, at wrap-up, an edit of the persona it contradicts.

## Asking the panel

- **Only on request:** "ask the panel about T4", "what would the client say about this pricing?", "panel on the plan". There is no command. A named persona answers alone; otherwise all of them do.
- **Targets:** the plan, a task or PR, screens (their screenshots or the mockup), or a question, as with the [expert view](expert-view.md#on-request).
- **One `orch-specialist` in panel mode, on sonnet**, read-only, one call for all personas. Give it the target, the personas, and the product knowledge's Needs and Out of scope. Never your own reasoning about the plan, so the panel isn't anchored on it.
- **Each persona walks through it** step by step, in its own situation, and says where it would get stuck, what it would misunderstand, where it would give up, and what it would want instead. It is asked to find where things break, never whether they like it.
- **Output:** a header `Panel: <target> — synthetic, from <sources>`, then at most 5 items, P1…P5, the most important first, each naming the persona, what happens to them, and what would fix it. An item that rests only on personas whose source is `your understanding` ends with `(your understanding only)`. `Nothing to add` is a valid answer; never pad. Nothing from Out of scope comes back.

## Adopt and decline

Save each panel answer to `.orchestration/panel/<target>.md` and link it. Show the items numbered; the user adopts or declines each, the same way as [expert recommendations](expert-view.md#adopt-and-decline): adopted items change the plan or go to the running worker as a follow-up (not rework), and a declined item's reason goes into Out of scope at wrap-up when the user calls it a decision.

- **Ledger:** `[panel] <target> <personas>: <n> proposed, <k> adopted → panel/<target>.md`, and for each decline `[panel] declined <target> P<n> "<thing>": <reason>`.
- **Never as user feedback.** In plans, PR bodies and the wrap-up, panel items are labelled "panel (synthetic)". Real conversations and data outrank it: when they disagree, they win.
- If the panel call fails, go on without it and say so in one line; it never blocks a run.

## In the UI/UX review

When the product knowledge has personas, the [UI/UX review](reviews.md#uiux-review) also walks the screens as each persona, in the same pass, and reports where one would get stuck as a finding under the usual grading. No extra reviewer.
