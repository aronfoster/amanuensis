Reviewed-draft: draft-v04.md

# Prose Pass — Chapter 2

#### Top priorities

1. The opening paragraph delays the scene without adding information.
2. The storm metaphor in the crossing passage is broken.
3. The last page leans on abstraction where the scene needs a concrete image.

#### Findings

<!-- review-id: prose_pass:book1:chapter02:finding-01 -->
##### fog held at the treeline
- Quote: "The fog stayed where the trees ended, as if it had been told to wait."
- Problem: none — restrained, concrete, in voice
- Why it matters: shows the register the rest of the chapter should hold
- Action: KEEP
- Decision: SKIP
- Decision-note: agreed — this line sets the register; keep it

<!-- review-id: prose_pass:book1:chapter02:finding-02 -->
##### opening paragraph drags
- Quote: "The morning arrived the way mornings did, without ceremony or particular interest in her plans."
- Problem: throat-clearing; the sentence delays the scene and tells us nothing
- Why it matters: the first paragraph sets the reader's contract with the chapter
- Action: TIGHTEN
- Decision: FIX
- Decision-note:

<!-- review-id: prose_pass:book1:chapter02:finding-03 -->
##### storm metaphor breaks its own image
- Quote: "The argument gathered like a storm that had already decided where to strike."
- Problem: storms do not decide; the personification fights the fatalism the scene wants
- Why it matters: the broken image distracts at the chapter's emotional peak
- Action: FLATTEN
- Decision:
- Decision-note:

<!-- review-id: prose_pass:book1:chapter02:finding-04 -->
##### closing abstraction
- Quote: "Everything that mattered had already changed."
- Problem: pure abstraction where the scene has concrete objects to carry the change
- Why it matters: the chapter's exit image should land in the body, not the summary
- Action: REWRITE
- Decision: ESCALATE
- Decision-note: this may be a storyboard problem, not prose; raise it

### Chapter-level diagnosis

#### What the prose is already doing well
Concrete restraint in the outdoor passages.

#### Repeated failure modes
Throat-clearing openers; personification that fights the scene's fatalism.

#### Best revision strategy
Sharpen concrete detail.

#### Lines worth preserving
"The fog stayed where the trees ended, as if it had been told to wait."

<!-- Fixture expectation (see examples/review/README.md).
Family prose_pass is `adopted` as of M12, so the validator parses and counts
this file. review-ids are book form (chapter-scoped, no scene segment). Every
finding is an anchored review unit, KEEP included: finding-01 is a KEEP
finding the human confirmed with SKIP (its explicit SKIP is the review
evidence that the human agreed with the producer's keep), finding-02 a decided
FIX, finding-03 a blank pending unit, finding-04 an ESCALATE. The
`#### Findings` container holds only anchored findings; the sibling
`#### Top priorities` / `### Chapter-level diagnosis` / `#### Lines worth
preserving` headings legitimately hold no units. No bulk and no fan-out
anywhere (locked M5 decision; a BULK header here would be an invalid-present
defect). Expected against agents/review-grammars.yaml, no manifest given:
  state, not checked (no manifest file given)
  findings, none
  total 4, pending 1, decided 1, inherited-by-bulk 0, skipped 1,
  escalated 1, invalid 0, stale 0
  pending-review-ids: prose_pass:book1:chapter02:finding-03
  verdict pending-remain, exit 4
Deciding finding-03 yields verdict proceed, exit 0, and the
pending-review-ids section disappears.
-->
