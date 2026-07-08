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
- Selected: B
- Selection-note:

#### Replace Options
- **Original:** "her grief sat in the corner like a chair no one used"
- **Target image:** "a stopped clock no one winds"
- **Version A (minimal):** "her grief stood in the corner like a stopped clock no one wound"
- **Version B (balanced):** "her grief kept its corner the way a stopped clock keeps its hour, patient and unwound"
- **Version C (fuller):** "her grief had settled into the corner like a clock stopped mid-week, its hands fixed, no one left to wind it"

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
- Selected:
- Selection-note:

#### Workshop Candidates

**Group 1 — Restrained (3 candidates)**

A. "moonlight lay across the floorboards pale as skimmed cream"
   - Vehicle: skimmed cream
   - Borrowed property: cool, even paleness
   - Uninvited properties: none of note
B. "moonlight lay across the floorboards like the inside of a shell"
   - Vehicle: a shell's interior
   - Borrowed property: soft, lined pallor
   - Uninvited properties: enclosure
C. "moonlight lay across the floorboards the color of pared bone"
   - Vehicle: pared bone
   - Borrowed property: dry white
   - Uninvited properties: death

**Group 2 — Image-family (3 candidates)**

D. "moonlight lay across the floorboards like flour off a sifted loaf"
   - Vehicle: sifted flour
   - Borrowed property: pale settling
   - Uninvited properties: none of note
   - Family: kitchen / larder
E. "moonlight lay across the floorboards white as a rinsed dish"
   - Vehicle: a rinsed dish
   - Borrowed property: clean pallor
   - Uninvited properties: chore
   - Family: kitchen / larder
F. "moonlight lay across the floorboards like salt spread to dry"
   - Vehicle: drying salt
   - Borrowed property: granular white
   - Uninvited properties: preservation
   - Family: kitchen / larder

**Group 3 — Near-literal (2 candidates)**

G. "pale light lay across the floorboards, evenly, edge to edge"
   - Vehicle: none (near-literal)
   - Borrowed property: even spread
   - Uninvited properties: none
H. "the floorboards held a thin white light"
   - Vehicle: none (near-literal)
   - Borrowed property: thin pallor
   - Uninvited properties: none

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
- Selected: A
- Selection-note: use variant A but keep "her steps" rather than "her footsteps"

#### Flatten Options
- **Original:** "the hallway swallowed the sound of her steps"
- **Variant A (plain):** "the hallway gave back no sound of her footsteps"
- **Variant B (textured):** "her footsteps fell without echo down the long boards of the hallway"
- **Variant C (rhythmic):** "the hallway took each step and returned nothing, not even its echo"

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

<!-- Fixture expectation (see examples/review/README.md).
Family metaphor is `adopted` (M13), a two-evidence-layer family. review-ids are
short_story form. Six anchored figures, each with `- Decision:` / `-
Decision-note:` fields (no free-text `Human Assessment:` line, no `### Summary`
count block — the validator's ledger is the count). Terminal figures: figure-01
`KEEP`, figure-02 a non-destructive `REJECT` (retained as the audit record).
Actionable figures (Decision in selection_tokens = FLATTEN REPLACE WORKSHOP)
each carry a blank/filled `- Selected:` / `- Selection-note:` pair and a `#### `
variant section: figure-03 `REPLACE: <image>` with a filled `Selected: B`;
figure-04 `WORKSHOP` with a blank `Selected:` (selection-pending); figure-05
`FLATTEN` with a filled `Selected: A` plus a `Selection-note:` inline edit
(read by metaphor_apply, never parsed by the validator). figure-06 has a blank
`Decision:` (decision-pending). The `#### ` variant headings sit a level below
the figure `### ` item line, so they never read as an item line or trip the
orphan-item check; the CLEAN / REVIEW / BROKEN flags are producer
recommendations and never dispose of an entry.

Decision round (metaphor_fix gate), no manifest given:
  no findings
  total 6, pending 1, decided 5, inherited-by-bulk 0, skipped 0,
  escalated 0, invalid 0, stale 0
  verdict pending-remain, exit 4
  pending-review-ids: metaphor:01-02:figure-06
(KEEP, REJECT, REPLACE, WORKSHOP, and FLATTEN all count as decided — metaphor
has no SKIP or ESCALATE; figure-06 is the one decision-pending unit. The
`Selected:` fields are not parsed in the decision round.)

Selection round (`--round selection`, metaphor_apply gate), no manifest given:
  no findings
  total 6, pending 1, decided 5, inherited-by-bulk 0, skipped 0,
  escalated 0, invalid 0, stale 0, selection-pending 1, selected 2
  verdict pending-remain, exit 4
  pending-review-ids: metaphor:01-02:figure-06
  selection-pending-review-ids: metaphor:01-02:figure-04
(selection-pending / selected count over actionable entries only: figure-03 and
figure-05 are selected, figure-04 is selection-pending; terminal figure-01 /
figure-02 carry no selection; figure-06's blank Decision is still
decision-pending and blocks this round too. Both a decision-pending and a
selection-pending unit remain, so exit 4.)
-->
