Reviewed-draft: draft-v03.md

## Anti-AI Report — Scene 02-01

BULK eligibility:
- Em Dashes: BULK permitted (recommended default: FIX: rewrite)
- Flagged Words: BULK permitted (recommended default: FIX)
- Negative Parallelism: BULK not permitted

### Em Dashes
BULK: FIX: rewrite

<!-- review-id: anti_ai:book1:chapter02:02-01:em-dashes-01 -->
- "The kitchen was quiet — the kind of quiet that waited."
  - Decision:
  - Decision-note:
<!-- review-id: anti_ai:book1:chapter02:02-01:em-dashes-02 -->
- "He reached for the fork — slowly, as if it might object."
  - Decision: SKIP
  - Decision-note: per-entry override under the bulk header; mid-gesture interruption reads right here

### Flagged Words
BULK: SKIP

<!-- review-id: anti_ai:book1:chapter02:02-01:flagged-words-01 -->
- "something *shifted* in the room" (shifted)
  - Decision:
  - Decision-note:

### Negative Parallelism

<!-- review-id: anti_ai:book1:chapter02:02-01:negative-parallelism-01 -->
- "It wasn't the cold that stopped her — it was the silence." (two-beat)
  - Decision: FIX: recast as a single positive image of the silence
  - Decision-note:
<!-- review-id: anti_ai:book1:chapter02:02-01:negative-parallelism-02 -->
- "Not a warning. Not a welcome. Something older than either." (three-beat)
  - Decision:
  - Decision-note:

### Summary — Scene 02-01

- Em dashes: 2
- Negative parallelism: 2 (two-beat: 1, three-beat: 1)
- Flagged words: 1
- Total flags: 5

<!-- Fixture expectation (see examples/review/README.md).
Family anti_ai is `pending` until M11, so today the validator rejects this
file, exit 1: not yet adopted, in-step grammar authoritative until M11.
review-ids are book form. This fixture exercises: a bulk-permitted category
under `BULK: FIX: rewrite` with a per-entry SKIP override beneath the
header, a second permitted category under `BULK: SKIP`, and a
`BULK not permitted` category decided per entry. Expected ledger once M11
flips the adoption marker, no manifest given:
  no findings
  total 5, pending 1, decided 1, inherited-by-bulk 2, skipped 1,
  escalated 0, invalid 0, stale 0
  verdict pending-remain, exit 4
(em-dashes-01 and flagged-words-01 inherit their category bulk defaults;
negative-parallelism-02 is the pending unit — its category grants no bulk
cover.)
-->
