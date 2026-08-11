---
role: planning
edit_policy: editable | careful_edit | propose_only | locked
---

# Reveals Ledger

<!--
Forward reveal plan, NOT derived state. This file is HUMAN-AUTHORED planning — a story-level index of
the reveals the reader is meant to come to understand — and has NO pipeline writer (unlike
`continuity/`, which `continuity_update` derives from accepted prose). It is consumed read-only by
`storyboard_review`. It realizes the ledger model in `agents/reveals.md` and reuses the temporal
character-state model in `agents/characters.md` (## Temporal character-state model — `id`,
`story-position`) plus the `block-NNN` qualifier the `compliance:` review-ids use
(`agents/review-grammars.yaml`). See those for the rules; this template shows the shapes. The
`edit_policy` line is optional — a reveals ledger is authored planning, not derived state, so no
pipeline step overwrites it.

It is DISTINCT from the book-level freeform `continuity.md` risk notes (`agents/books.md:59-66`),
which stay freeform, book-level, human-prose reveal-timing / consistency notes. This ledger is the
structured, id-bearing, greppable, STORY-LEVEL index (one per work). Cross-reference the two in
`notes:`; do not merge them.

Story-level: one ledger per work. For a series, positions are book-qualified so one ledger spans
books.

Each entry carries:
- `id:` — durable, file-scoped, minted once, never changed (rv-01, rv-02, …).
- `lands:` — the block-qualified position where the reveal lands.
- `setup:` — an ORDERED list of the block-qualified buildup positions that establish it.
- `concealed-until:` — the block-qualified position before which the reader must not learn it.
- `reveal:` — what the reader comes to understand at the landing position.
- `notes:` — optional; cross-ref to the book-level `continuity.md` risk notes, canon dependencies.

Positions are BLOCK-QUALIFIED: the canonical folder-style `story-position` extended with the
storyboard block number — `<…scene-id>:block-NNN`. Book-qualified for `book`/`series`
(`book1/chapter05/scene02:block-004`); for `short_story` it reduces to `<scene-id>:block-NNN`
(e.g. `scene03:block-002`). Block-qualification is required so the premature-disclosure guard can
order blocks WITHIN a scene (agents/reveals.md).
-->

---

### The captain set the harbor fire
- **id:** rv-01
- **lands:** book1/chapter05/scene02:block-004
- **setup:**
  - book1/chapter02/scene03:block-002
  - book1/chapter04/scene01:block-007
- **concealed-until:** book1/chapter05/scene02:block-004
- **reveal:** The reader understands the captain, not the harbormaster, set the harbor fire — recasting
  the ambush two chapters earlier as deliberate.
- **notes:** Depends on the arsonist staying an open thread until here (cross-ref book-level
  `continuity.md` risk note "harbor-fire timing").

---

### The signet ring is a forgery
- **id:** rv-02
- **lands:** book1/chapter06/scene01:block-011
- **setup:**
  - book1/chapter03/scene02:block-005
- **concealed-until:** book1/chapter06/scene01:block-011
- **reveal:** The reader understands the ring Corvin has carried since chapter 3 is a forgery.
- **notes:** Canon dependency — the forgery must not contradict `canon/world/heraldry.md`.

<!--
short_story reduction: with no book/chapter subdivision, positions collapse to `<scene-id>:block-NNN`.
The same entry in a `short_story` ledger would read, e.g.:

### The narrator was never on the boat
- **id:** rv-03
- **lands:** scene05:block-009
- **setup:**
  - scene02:block-003
  - scene03:block-002
- **concealed-until:** scene05:block-009
- **reveal:** The reader understands the narrator was ashore the whole time.
- **notes:** —
-->
