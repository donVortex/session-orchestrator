---
type: llm
weight: 1
---

The response is a worker's plan for a change to `.github/workflows/ci.yml` (a CI workflow file), from a brief with no `Risk:` line.

PASS if: the plan says the PR's risk is `high` (or clearly high-risk) because the change touches a CI workflow file.

FAIL if it gives the risk as low or normal, or doesn't state a risk.
