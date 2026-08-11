# Reveals Ledger

The `reveals.md` ledger is the **story-level index of forward reveals** — the things the reader is
meant to come to understand, where each one lands, the buildup that establishes it, and the point
before which the reader must not learn it. It is the maintained index `storyboard_review`'s
reveal-setup check reasons against across chapters, and the plan the premature-disclosure guard
enforces.

## What it is

- **A `role: planning`, human-authored, project-root `reveals.md`.** It lives at the project root
  (story-level: one ledger per work), alongside `open-questions.md` and `pipeline-state.md`
  (`agents/project-layouts.md`).
- **No pipeline writer.** A reveal is forward authorial intent, and `storyboard_review` runs pre-draft
  — there is no accepted prose to derive it from, and a derived writer that read the same storyboards
  it feeds would be near-circular. So the ledger is human-authored, like `outline.md`, the storyboards
  themselves, and the freeform `continuity.md` — and consumed **read-only** by `storyboard_review`.
- **Story-level.** One ledger per work. For a series it spans books through book-qualified positions
  (below), so a single ledger indexes reveals whose buildup and landing cross book boundaries.

## Distinct from the book-level `continuity.md` risk notes

`reveals.md` is **not** the book-level freeform `continuity.md` (`agents/books.md:59-66`). That file
stays as-is: freeform, **book-level** notes on fragile reveal timing, cross-chapter dependencies, and
known consistency risks — human prose for a human reader. `reveals.md` is the **structured,
`id`-bearing, greppable, story-level** ledger a review can query entry by entry. The two are
**cross-referenced, not merged**: a `reveals.md` entry may point at a `continuity.md` risk note in its
`notes:`, but the structured ledger is the review-consumable artifact.

## Entry shape

The ledger reuses the M14/M15 temporal idiom rather than inventing a parallel model. `id` and
`story-position` are defined once, authoritatively, in `agents/characters.md`'s **"## Temporal
character-state model"** — see it; they are **not** restated here. Each entry carries:

- **`id:`** — `rv-NN` (`rv-01`, `rv-02`, …), file-scoped, minted once, never changed — the same
  discipline as `co-`/`kn-`/`tl-`/`rel-`.
- **the reveal content** — what the reader comes to understand.
- **`lands:`** — the block-qualified position where the reveal lands.
- **`setup:`** — an **ordered list** of the block-qualified buildup positions that establish it.
- **`concealed-until:`** — the block-qualified position before which the reader must not learn it.

### Positions are block/beat-qualified

Positions extend the canonical folder-style `story-position` with the storyboard **block number**:

```
<…scene-id>:block-NNN
```

so a `book`/`series` position is `book1/chapter05/scene02:block-004` (book-qualified so one ledger
spans books) and a `short_story` position reduces to `<scene-id>:block-NNN`, e.g. `scene03:block-002`.

The block qualifier is **required**, not cosmetic. The premature-disclosure guard must order blocks
*within* a scene: a bare `<scene-id>` gives every block in the landing scene the same position, so an
earlier block in that same scene could disclose the secret without its position preceding the
`concealed-until:` constraint — the guard could not tell block 003 from block 004. Block-qualifying
the position makes "precedes" well-defined within a scene as well as across scenes.

The `block-NNN` qualifier is the **same one the `compliance:` review-ids already use** — see
`agents/review-grammars.yaml` (the `compliance` family's `review_id_item`); it is not a new numbering
scheme and is not restated here.
