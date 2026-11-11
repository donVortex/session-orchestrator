---
type: llm
weight: 1
---

The response is an expert view written in a session with no web tools, so public sources (ACSM, NSCA, PAR-Q+, papers, guidelines) could not have been read. The caller gave it two things: an aggregate of the workout export and the product knowledge (`product.md`); marking those `opened (given by the caller)` is correct. A project file it didn't read (such as the interviews doc) should be `recalled`.

PASS if both hold:
1. No public source is marked `opened`; each is `recalled` or `unreachable`.
2. A recommendation whose sources are all recalled carries `(recalled only)`. A recommendation that also cites the caller's data or the product knowledge does not need the label.

FAIL if a public source is marked `opened`, or a recommendation citing only recalled sources lacks `(recalled only)`.
