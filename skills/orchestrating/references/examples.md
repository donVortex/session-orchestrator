# What good looks like

A goal in words leaves taste to guesswork: how dense a screen is, how an error reads, what a report leads with. An example settles that faster than adjectives do. This file covers asking for examples, reading them, and where what you read goes.

## When to ask

- **Only for goals with a visible result**: a screen or flow, copy, a report or export, an API's request and error shapes, messages people read. Never for refactors, bug fixes, infrastructure or tests, where the code already says what good is.
- **Skip it** when the goal already shows what good is (it names an existing screen to match, or attaches an example), or the project's knowledge already has a style entry for this kind of result.
- **One optional line, never a stop of its own.** Put it in your goal clarification if you ask one; otherwise make it one line of the approval message. Word it as an offer that's easy to skip, e.g.: "Optional: paste, link or point to 1–3 examples of what good looks like here (or what you don't want). Skip it and I go by the code."
- Ask once per orchestration. Never ask again on resume, and never again after the user skipped it.
- Examples can be pasted text, a link, a screenshot, or a path in the repo or on disk. Read them at planning time.

## Reading them

Read examples as properties, never a template. A worker given an example copies it; a worker given what makes it good can apply that to a case the example doesn't show.

- For each example, write down what makes it good (or bad, for a counter-example) as short, checkable properties: "one table, no modal dialogs", "errors say what to do next", "amounts right-aligned, two decimals", "summary line before any detail".
- Leave out what is only the example's own: its content, data, product name or branding. Those aren't the user's taste; they're another product's.
- Screenshots: know their devicePixelRatio before you read any size from them (ask, or measure it on the page); CSS px are screenshot px divided by the DPR.
- Describe a format in words ("short dates, amounts with currency and two decimals"), never with the example's own values as a sample.
- When two examples disagree on something, say so and ask in the same message, or leave that property out.
- Exact text the user wants ("the button says *Send refund*") is not an example: it's a value of the goal and goes into the brief's Goal as it is.
- Show your reading in the approval message as `Good looks like: <properties> (from <examples>)`, so a misreading is corrected before any work starts. Approving the plan approves the reading.
- Examples that arrive with the approval: state your reading in one line of your reply and carry on. It shapes the briefs, not the breakdown. If it changes the breakdown, show the plan again.
- Log `[event] examples: <n> given, read as: <properties, shortened>`, or `[event] examples: skipped`.

## Where it goes

- **Briefs:** the brief's **Good looks like** field gets the properties that apply to the task ([brief-template.md](brief-template.md)), never the example itself, its values or where it came from (no source name, no "from your … example"). A worker in its own worktree can't see what was pasted here anyway. A repo file that shows the patterns to follow goes in **Style reference**, as usual.
- **Review:** the PR review checks the diff against the brief's Good looks like properties as it does its acceptance criteria. A result that breaks one is an `important` finding with the property it breaks ([findings](reviews.md#findings)).

## Their data

Pasted screens, exports and documents often hold real data. Never copy their values (names, emails, amounts, record ids, addresses) into briefs, the ledger, PR text or commit messages: describe the property, never the value. Don't save an example anywhere in the repo.

Examples count for this run only. When the user says one holds beyond it ("always like this"), propose its properties as a knowledge entry, only through the [knowledge diff](knowledge.md#knowledge-diff-at-wrap-up) at wrap-up, with the user as its source. Never the example itself, and never its data.
