Reviewed-draft: draft-v02.md

## Metaphor Report — Scene 01-02

<!-- review-id: metaphor:01-02:figure-01 -->
### fork bends like a wrist

- **Quote:** "the fork bent the way a wrist bends, reluctant and then all at once"
- **Tenor:** the fork deforming under her grip
- **Vehicle:** a wrist giving way
- **Borrowed property:** the two-stage give — resistance, then collapse
- **Uninvited properties:** injury; the suggestion the fork can feel
- **Implication:** the object is half-alive under her hands
- **Register fit:** serves the scene's uncanny domesticity
- **Flag:** CLEAN
- Decision: KEEP
- Decision-note:

<!-- review-id: metaphor:01-02:figure-02 -->
### the pantry breathes

- **Quote:** "the pantry breathed its cold breath over the threshold"
- **Tenor:** cold air moving from the pantry
- **Vehicle:** an exhaling body
- **Borrowed property:** slow, regular outflow
- **Uninvited properties:** lungs, intent, a body in the wall
- **Implication:** the house is animate and watching
- **Register fit:** competes with the scene's stated stillness
- **Flag:** REVIEW
- Decision: REJECT
- Decision-note: the house must stay inert until scene 01-04; entry retained as the audit record — rejection is no longer deletion

<!-- review-id: metaphor:01-02:figure-03 -->
### grief as furniture

- **Quote:** "her grief sat in the corner like a chair no one used"
- **Tenor:** her grief's constant, ignorable presence
- **Vehicle:** an unused chair
- **Borrowed property:** furniture's patient permanence
- **Uninvited properties:** utility; the sense grief could be sat in
- **Implication:** the grief is domesticated, part of the room
- **Register fit:** close, but the chair is too comfortable for this scene
- **Flag:** REVIEW
- Decision: REPLACE: a stopped clock no one winds
- Decision-note: keep the furniture register, lose the comfort

<!-- review-id: metaphor:01-02:figure-04 -->
### moonlight like spilled milk

- **Quote:** "moonlight lay across the floorboards like spilled milk"
- **Tenor:** moonlight on the floor
- **Vehicle:** spilled milk
- **Borrowed property:** pale liquid spread
- **Uninvited properties:** accident, mess, something to clean up
- **Implication:** the light is a small domestic disaster
- **Register fit:** off — the scene wants the light welcome, not wrong
- **Flag:** BROKEN
- Decision: WORKSHOP
- Decision-note: want candidates that keep the dairy paleness without the accident

<!-- review-id: metaphor:01-02:figure-05 -->
### the hallway swallows sound

- **Quote:** "the hallway swallowed the sound of her steps"
- **Tenor:** the hallway's deadened acoustics
- **Vehicle:** a swallowing throat
- **Borrowed property:** sound disappearing without echo
- **Uninvited properties:** appetite; the house consuming her
- **Implication:** the house absorbs what she does
- **Register fit:** overwrought for a transition beat
- **Flag:** REVIEW
- Decision: FLATTEN
- Decision-note:

<!-- review-id: metaphor:01-02:figure-06 -->
### dawn like a verdict

- **Quote:** "dawn came in like a verdict"
- **Tenor:** daybreak ending her deliberation
- **Vehicle:** a courtroom verdict
- **Borrowed property:** finality delivered from outside
- **Uninvited properties:** guilt, judgment, an authority passing sentence
- **Implication:** the day itself has judged her
- **Register fit:** uncertain — may be earning its weight, may be inflating it
- **Flag:** REVIEW
- Decision:
- Decision-note:

### Summary — Scene 01-02

- Figures collected: 6
- CLEAN: 1
- REVIEW: 4
- BROKEN: 1

<!-- Fixture expectation (see examples/review/README.md).
Family metaphor is `pending` until M13, so today the validator rejects
this file, exit 1: not yet adopted, in-step grammar authoritative until
M13. review-ids are short_story form. This fixture exercises all five
tokens, including a `REPLACE: <image>` payload on figure-03 (bare REPLACE
would be an invalid unit — the payload is required and is not normalized
to WORKSHOP) and a non-destructive REJECT on figure-02. The Decision
fields replace the old free-text Human Assessment line; the CLEAN /
REVIEW / BROKEN flags are producer recommendations and never dispose of
an entry. Expected ledger once M13 flips the adoption marker, no manifest
given:
  no findings
  total 6, pending 1, decided 5, inherited-by-bulk 0, skipped 0,
  escalated 0, invalid 0, stale 0
  verdict pending-remain, exit 4
(KEEP, REJECT, REPLACE, WORKSHOP, and FLATTEN all count as decided —
metaphor has no SKIP or ESCALATE tokens; figure-06 is the pending unit.)
-->
