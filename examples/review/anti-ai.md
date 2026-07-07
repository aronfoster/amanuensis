Reviewed-draft: draft-v03.md

## Anti-AI Report — Scene 02-01

### Em Dashes

<!-- review-id: anti_ai:book1:chapter02:02-01:em-dashes-01 -->
- "The kitchen was quiet — the kind of quiet that waited."
  - Decision: FIX: rewrite
  - Decision-note: category decision — fix all em dashes, rewrite around them
<!-- review-id: anti_ai:book1:chapter02:02-01:em-dashes-02 -->
- "She counted the chairs — four, as always — before she sat."
  - Decision: FIX: rewrite
  - Decision-note: category decision — fix all em dashes, rewrite around them
<!-- review-id: anti_ai:book1:chapter02:02-01:em-dashes-03 -->
- "He reached for the fork — slowly, as if it might object."
  - Decision: SKIP
  - Decision-note: per-entry exception to the category decision; the mid-gesture interruption reads right here

### Negative Parallelism

<!-- review-id: anti_ai:book1:chapter02:02-01:negative-parallelism-01 -->
- "It wasn't the cold that stopped her — it was the silence." (two-beat)
  - Decision: FIX: recast as a single positive image of the silence
  - Decision-note:
<!-- review-id: anti_ai:book1:chapter02:02-01:negative-parallelism-02 -->
- "Not a warning. Not a welcome. Something older than either." (three-beat)
  - Decision:
  - Decision-note:

### Synonym Cycling

<!-- review-id: anti_ai:book1:chapter02:02-01:synonym-cycling-01 -->
- Passage: paragraphs 4-6, the kitchen table
  - Cycled terms: table, surface, expanse
  - Decision: ESCALATE
  - Decision-note: may be deliberate register drift; needs the author's call

## Anti-AI Report — Scene 02-02

No flags.

<!-- Fixture expectation (see examples/review/README.md).
This is an adopted family (M11), so the validator parses and counts it.
review-ids are book form. The fixture exercises the fan-out era: Em Dashes
is a fanout_categories category adjudicated by one human statement — the
companion wrote the identical FIX: rewrite decisions with category-decision
audit notes — plus one per-entry SKIP exception; Negative Parallelism is not
fan-out eligible and is decided per entry, with one unit still blank;
Synonym Cycling shows the single-top-level-entry-line unit shape (Cycled
terms nested beneath the Passage line) and an ESCALATE; scene 02-02 is the
No-flags audit record and contributes no units. There is no eligibility
block, no BULK header, and no Summary tally — all retired in Sprint 16.
Expected against agents/review-grammars.yaml, no manifest given:
  state, not checked (no manifest file given)
  findings, none
  total 6, pending 1, decided 3, inherited-by-bulk 0, skipped 1,
  escalated 1, invalid 0, stale 0
  pending-review-ids: anti_ai:book1:chapter02:02-01:negative-parallelism-02
  verdict pending-remain, exit 4
(negative-parallelism-02 is the pending unit — the validator lists it under
pending-review-ids: because pending is nonzero; deciding it yields verdict
proceed, exit 0, and the pending-review-ids section disappears.)
-->
