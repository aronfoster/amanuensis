Reviewed-draft: draft-v04.md

# Prose Pass — Chapter 2

### Top priorities

1. The opening paragraph delays the scene without adding information.
2. The storm metaphor in the crossing passage is broken.
3. The last page leans on abstraction where the scene needs a concrete image.

### Findings

##### fog held at the treeline
- Quote: "The fog stayed where the trees ended, as if it had been told to wait."
- Problem: none — restrained, concrete, in voice
- Why it matters: shows the register the rest of the chapter should hold
- Action: KEEP

<!-- review-id: prose_pass:book1:chapter02:finding-01 -->
##### opening paragraph drags
- Quote: "The morning arrived the way mornings did, without ceremony or particular interest in her plans."
- Problem: throat-clearing; the sentence delays the scene and tells us nothing
- Why it matters: the first paragraph sets the reader's contract with the chapter
- Action: TIGHTEN
- Decision: FIX
- Decision-note:

<!-- review-id: prose_pass:book1:chapter02:finding-02 -->
##### storm metaphor breaks its own image
- Quote: "The argument gathered like a storm that had already decided where to strike."
- Problem: storms do not decide; the personification fights the fatalism the scene wants
- Why it matters: the broken image distracts at the chapter's emotional peak
- Action: FLATTEN
- Decision:
- Decision-note:

<!-- review-id: prose_pass:book1:chapter02:finding-03 -->
##### closing abstraction
- Quote: "Everything that mattered had already changed."
- Problem: pure abstraction where the scene has concrete objects to carry the change
- Why it matters: the chapter's exit image should land in the body, not the summary
- Action: REWRITE
- Decision: SKIP
- Decision-note: the abstraction is doing deliberate work here; leave it

### Chapter-level diagnosis

#### What the prose is already doing well
Concrete restraint in the outdoor passages.

#### Repeated failure modes
Throat-clearing openers; personification that fights the scene's fatalism.

#### Best revision strategy
Sharpen concrete detail.

<!-- Fixture expectation (see examples/review/README.md).
Family prose_pass is `pending` until M12, so today the validator rejects
this file, exit 1: not yet adopted, in-step grammar authoritative until
M12. review-ids are book form (chapter-scoped, no scene segment). This
fixture exercises KEEP handling: the KEEP finding carries no anchor and no
Decision fields — it is not a review unit and must not appear in any
count. No bulk anywhere (locked M5 decision; a BULK header here would be
an invalid-present defect). Expected ledger once M12 flips the adoption
marker, no manifest given:
  no findings
  total 3, pending 1, decided 1, inherited-by-bulk 0, skipped 1,
  escalated 0, invalid 0, stale 0
  verdict pending-remain, exit 4
-->
