<!-- budget: 60 lines -->
# Review checklist

What every review in this project must check, on top of correctness and tests. Reviews already require `path:line` evidence for each finding, at most 3 minor findings, and a count first; a section here can tighten those.

## What failure looks like here

<!-- The one or two ways a change goes wrong in this project. Example:
- **Docs: it lies.** A doc change that describes behaviour the code doesn't have is `important`. _(bootstrap, 2026-11-03)_
-->

## Always check

<!-- Example:
- **Every write is audit-logged** through `audit.record()`. _(bootstrap, 2026-11-03)_
-->

## When touching <area>

<!-- Rename this heading to the area, e.g. "## When touching src/phi/". Example:
- **Consent is checked before any data leaves the module.** _(user, 2026-11-03)_
-->

## Sensitive paths (always high risk)

<!-- A PR touching these is tagged `high`, and the user is asked to read it. Example:
- `src/billing/**`, `.github/workflows/**` _(bootstrap, 2026-11-03)_
-->

## Don't review

<!-- Paths and points reviews skip. Example:
- Generated files in `src/gen/**`; lockfiles. _(bootstrap, 2026-11-03)_
-->
