#!/usr/bin/env bash
# Lessons from a 13-task redesign run in another project (v0.13.0): other projects only
# report plugin lessons; worker files stay out of the main checkout; titles are read back;
# screenshot sizes carry their DPR; visual goals get a look gate; parallel batches are
# tested together before the merge ask; transient API errors aren't failures; stated
# checks name their evidence; corrections get their own tag; Windows worker habits.
. "$(dirname "$0")/lib.sh"

orch=$(cat skills/orchestrating/SKILL.md 2>/dev/null)
work=$(cat skills/working/SKILL.md 2>/dev/null)
brief=$(cat skills/orchestrating/references/brief-template.md 2>/dev/null)
desk=$(cat skills/orchestrating/references/backend-desktop.md 2>/dev/null)
ex=$(cat skills/orchestrating/references/examples.md 2>/dev/null)
split=$(cat skills/orchestrating/references/splitting.md 2>/dev/null)
rev=$(cat skills/orchestrating/references/reviews.md 2>/dev/null)
learn=$(cat skills/orchestrating/references/workflow-learning.md 2>/dev/null)

# Other projects only report plugin lessons, whatever the user approves
assert_contains "$orch" "**Report-only**" "wrap-up: report-only mode"
assert_contains "$orch" "never edit, branch, commit or open a PR in the plugin's checkout" "report-only: never edits the plugin"
assert_contains "$orch" "even when the user approves them or asks" "report-only: approval doesn't unlock edits"
assert_contains "$orch" '`.orchestration/plugin-proposals.md`' "report-only: proposals saved for the plugin's session"

# 6.1 Worker files stay out of the main checkout
assert_contains "$brief" "and every file it points to" "brief: report and its files go to notes"
assert_contains "$brief" "**Shared brief files**" "brief check: shared brief files"
assert_contains "$desk" '`<notes>/T<n>/`' "desktop: copy the task's notes folder too"
assert_contains "$work" "try the shared notes folder your session instructions name" "worker: notes folder before final message"
assert_contains "$work" "never with Bash, node or another tool" "worker: no writing around a refused path"

# 6.2 Titles are read back
assert_contains "$desk" "read the title back" "desktop: title read back after start"

# 6.3 Screenshot sizes carry their DPR
assert_contains "$brief" "devicePixelRatio" "brief check: sizes in CSS px with DPR"
assert_contains "$ex" "devicePixelRatio" "examples: screenshots carry their DPR"

# 6.4 Look gate for visual goals
assert_contains "$split" "## Visual work" "splitting: visual work section"
assert_contains "$split" "look gate" "splitting: look gate"
assert_contains "$orch" "The look gate of a visual goal" "stops: look gate"
assert_contains "$learn" "the look gate of a visual goal" "learning: look gate is an expected stop"

# 6.5 Parallel batches are tested together before the merge ask
assert_contains "$rev" "## Check a parallel batch before asking to merge" "reviews: batch check section"
assert_contains "$rev" "tree == tested" "reviews: tree hash skips the re-run"

# 6.6 Transient API errors aren't failures
assert_contains "$orch" "transient API error" "failures: transient API error row"
assert_contains "$orch" "continue: done <commits>" "failures: resume message"
assert_contains "$desk" "transient API error" "desktop: points to the row"

# 6.7 Stated checks name their evidence
assert_contains "$orch" "names its evidence from this turn" "track/review: evidence for every stated check"
assert_contains "$orch" '"not checked"' "track/review: unmeasured is not checked"
assert_contains "$rev" "names its evidence from this turn" "reviews: same rule for review notes"

# 6.8 Corrections get a tag; retros from final-message reports are kept
assert_contains "$learn" '`[correction]`' "learning: correction tag"
assert_contains "$learn" "### Which tag" "learning: which-tag table"
assert_contains "$orch" "including reports you saved from a final message" "track: every retro appended"

# 6.9 Windows worker habits
assert_contains "$work" "MSYS_NO_PATHCONV=1" "worker: Git Bash path conversion"
assert_contains "$work" "its port is free" "worker: dev servers stopped"
assert_contains "$work" "never a shell heredoc" "worker: escapes through the Edit tool"

finish
