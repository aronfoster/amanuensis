---
role: planning
edit_policy: editable
---

# Reveals Ledger

<!--
ILLUSTRATIVE EXAMPLE — NOT REAL PROJECT CANON OR STATE.

A worked demonstration input for the reveal-timing checks of `storyboard_review`
(`agents/reveals.md`), mirroring the shapes in `templates/reveals.md`. Human-
authored planning, NOT derived state — consumed read-only by `storyboard_review`.
The *Cormorant*, her crew, and the story positions are invented for the example.
See the folder README at `examples/relational-review/README.md`.

Positions are BLOCK-QUALIFIED (`<…scene-id>:block-NNN`), book-qualified for this
`book` project so one ledger spans the work. The load-bearing entry is rv-01: a
chapter-3 storyboard block discloses it to the reader before its `concealed-until:`
window, which `storyboard_review` catches as a PREMATURE (reveal) storyboard
defect (per the reveal-timing carve-out `canon > reveals.md > storyboard > prose`,
the storyboard is the defect, never the ledger).
-->

---

### Captain Fenn forged the manifest
- **id:** rv-01
- **lands:** book1/chapter04/scene02:block-005
- **setup:**
  - book1/chapter02/scene03:block-002
  - book1/chapter03/scene01:block-002
- **concealed-until:** book1/chapter04/scene02:block-005
- **reveal:** The reader understands Captain Fenn altered the *Cormorant*'s manifest himself, to hide the four casks he sold ashore at Kettle Cove — recasting the short tally Wick found as deliberate, not clerical.
- **notes:** The buildup plants the short count (setup block-002 of chapter02/scene03) and Wick's unease (setup block-002 of chapter03/scene01) WITHOUT naming the forgery. The reader must not learn Fenn is responsible until the agent's letter arrives at chapter04/scene02:block-005. Cross-ref the book-level `continuity.md` risk note "manifest reveal timing."

---

### The relief ship is a blockade runner
- **id:** rv-02
- **lands:** book1/chapter05/scene03:block-008
- **setup:**
  - book1/chapter03/scene03:block-001
- **concealed-until:** book1/chapter05/scene03:block-008
- **reveal:** The reader understands the ship that hails the *Cormorant* off the Teeth is running a blockade, not a rescue.
- **notes:** Present only to show the ledger holds more than one entry; no storyboard in the reviewed chapter touches it.
