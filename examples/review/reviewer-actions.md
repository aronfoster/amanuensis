Reviewed-draft: draft-v02.md

## Compliance Report — Scene 01-01, 2026-07-06

### Block 002 — CLEAN

### Block 011
<!-- review-id: compliance:01-01:block-011-v01 -->
- MISSING (must_preserve): Fork demonstration — the fork is required to visibly bend during the meal; the prose range never shows it bending
  - Decision: FIX
  - Decision-note:
<!-- review-id: compliance:01-01:block-011-v02 -->
- VIOLATED (concealment_from_reader): "the machine had been listening all along" names the surveillance before the reveal beat. Prose: "the machine had been listening all along"
  - Decision: FIX: cut the clause; imply the hum under the floorboards without naming the machine
  - Decision-note: keep the surrounding kitchen imagery untouched
<!-- review-id: compliance:01-01:block-011-v03 -->
- INCONSISTENT (canon): Resonance lag — "the echo answered at once" violates rule: "echoes return only after a full breath"
  - Decision: ESCALATE
  - Decision-note: the storyboard block may be wrong here, not the prose

### Block 014
<!-- review-id: compliance:01-01:block-014-v01 -->
- NOT ENACTED (character_state_out): Mara — closing state "resolved to leave before dawn" not reached
  - Decision:
  - Decision-note:
<!-- review-id: compliance:01-01:block-014-v02 -->
- DEGRADED (must_preserve): Latch ritual — required as a two-handed gesture, written one-handed. Prose: "she flicked the latch"
  - Decision: SKIP
  - Decision-note: one-handed reads better in this rhythm; accepting the drift
<!-- review-id: compliance:01-01:block-014-v03 -->
- VIOLATED (concealment_from_characters): Mara's departure plan accessible to Tovan — "you're leaving, then"
  - Decision: KEEP
  - Decision-note: deliberately illegal token — KEEP is a metaphor-family token, not a compliance one; this unit is the fixture's invalid specimen

### Summary

- Must-Contain violations: 2
- Must-Not-Contain violations: 2
- Canon violations: 1
- Blocks fully clean: 1 of 3

Violations cluster in blocks 011 and 014.

<!-- Fixture expectation (see examples/review/README.md).
This is the adopted family, so the validator parses and counts it. The
CLEAN block (002) carries no anchor and no fields and must not appear in
any count. review-ids are short_story form. Expected against
agents/review-grammars.yaml, no manifest given:
  state, not checked (no manifest file given)
  one finding, the illegal KEEP token on compliance:01-01:block-014-v03
  total 6, pending 1, decided 2, inherited-by-bulk 0, skipped 1,
  escalated 1, invalid 1, stale 0
  pending-review-ids: compliance:01-01:block-014-v01
  verdict invalid-present, exit 3
(pending is nonzero, so the validator lists the one pending unit under
pending-review-ids: even though the verdict is invalid-present — invalid
takes precedence, but the pending unit is still named.)
Filling block-014-v01 and correcting block-014-v03 to a legal token yields
verdict proceed, exit 0.
-->
