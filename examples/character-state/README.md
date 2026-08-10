# Character-state fixture — temporal reconstruction

> **ILLUSTRATIVE EXAMPLE — NOT REAL PROJECT CANON OR STATE.**
> Per the Amanuensis Repository Boundary rule (`AGENTS.md`), character state
> lives in this tooling repo *only* as a clearly-marked example. Mira, her
> facts, the drafts (`draft-vNN.md`), and the story positions here are all
> invented to demonstrate the model. Nothing in this folder is a real character,
> a real project's state, or anything to reconcile against — do not treat it as
> canon and do not copy it into a story repo as fixtures for a real character.

## What this folder shows

A worked demonstration of the **Temporal character-state model**
(`agents/characters.md`, ## Temporal character-state model) as it is realized in
a `book`-project character `knowledge/` file. It is one character folder:

- `characters/mira/profile.md` — a minimal, clearly-marked example profile, from
  the shape in `templates/profile.md`, so the folder reads as a real one.
- `characters/mira/knowledge/book-1.md` — the artifact. Mira's knowledge about
  who is stealing grain from the keep's stores **changes twice**, and each change
  is recorded **non-destructively**, all under an **active reveal constraint**:
  1. A **suspicion** (kn-01, `## Suspects`) hardens into an
  2. **incorrect belief** (kn-02, `## Believes incorrectly`), which is later
  3. **corrected** to what she actually witnessed (kn-03, `## Knows`).
  - The `## Must not know yet` guardrail — that the captain acts on the baron's
    orders — is active the whole time (it does not lift until
    `book1/chapter09/scene04`, after both positions reconstructed below).

Because this is a `book` project, story-positions are full folder-style
`book1/chapterNN/sceneNN` with zero-padded two-digit chapter/scene numbers, so
**lexical order equals chronological order** (`chapter04/scene01` sorts before
`chapter07/scene02`). That is the only thing the reconstruction below relies on
about the position format.

Each current-state entry the writer step produced carries a
`- **review:** unreviewed` line. That is the `scene_knowledge_update` step's
**provenance stamp** (`agents/steps/scene-knowledge-update.md`): every entry it
writes is marked `unreviewed` until a human audits and clears it. The stamp is
provenance only — a human *can* audit it, but it **does not affect
reconstruction**; the derivation below never reads it.

## How to reconstruct state at a story position

The character Markdown is the **sole authority** — there is no index or
derived-state file. To reconstruct what Mira held at a position `X`, read the
ids, story-positions, and `## Lost or superseded` transitions, and apply one rule:

> An entry is **current as of position `X`** iff its `story-position ≤ X`
> **and** it is not superseded by a transition whose correction position `≤ X`.

The transitions make this mechanical. A superseded entry's `held: A to B` says it
was current for **`A ≤ X < B`** (acquired at `A`, replaced at `B`). A still-current
entry (one still sitting in `## Knows` / `## Suspects` / `## Believes incorrectly`)
is current for `story-position ≤ X` with no upper bound yet. Comparisons are the
plain lexical order of the zero-padded positions.

The file gives us three facts and two transitions:

| id | acquired at | lives in / held range | superseded by |
| --- | --- | --- | --- |
| kn-01 | `book1/chapter02/scene03` | held `chapter02/scene03` → `chapter04/scene01` | kn-02 |
| kn-02 | `book1/chapter04/scene01` | held `chapter04/scene01` → `chapter07/scene02` | kn-03 |
| kn-03 | `book1/chapter07/scene02` | current in `## Knows`, no upper bound | — |

Plus the active guardrail: *captain acts on the baron's orders* — must not be
known until `book1/chapter09/scene04`.

### Position 1 — `book1/chapter05/scene01` (belief formed, not yet corrected)

Walk the three facts against `X = book1/chapter05/scene01`:

- **kn-01** — acquired `chapter02/scene03 ≤ X`, but its transition supersedes it
  at `chapter04/scene01`, and `chapter04/scene01 ≤ X`. Held range
  `chapter02/scene03 → chapter04/scene01` requires `X < chapter04/scene01`;
  `chapter05` is not, so **not current**. (Already superseded by this point.)
- **kn-02** — acquired `chapter04/scene01 ≤ X`. Its transition supersedes it at
  `chapter07/scene02`, and `chapter07/scene02 ≤ X` is **false** (`chapter07 >
  chapter05`). Held range `chapter04/scene01 → chapter07/scene02` includes `X`
  (`chapter04/scene01 ≤ chapter05/scene01 < chapter07/scene02`), so **current**.
- **kn-03** — acquired `chapter07/scene02 ≤ X` is **false** (`chapter07 >
  chapter05`). **Not yet acquired.**
- **Guardrail** — active until `chapter09/scene04`, and `chapter05 < chapter09`,
  so **still active**.

**Reconstructed state at `chapter05/scene01`:** Mira's one current fact is
**kn-02** — she believes, wrongly, that the steward is the thief. kn-01 is
already history; kn-03 does not exist for her yet; and she still does not (and
must not) know the baron is behind it.

### Position 2 — `book1/chapter08/scene01` (after the correction)

Walk the same three facts against `X = book1/chapter08/scene01`:

- **kn-01** — held `chapter02/scene03 → chapter04/scene01`; `chapter08` is not
  `< chapter04/scene01`, so **not current**.
- **kn-02** — held `chapter04/scene01 → chapter07/scene02`; superseded at
  `chapter07/scene02`, and `chapter07/scene02 ≤ chapter08/scene01` is **true**,
  so **not current** (`chapter08` is not `< chapter07`). Corrected away.
- **kn-03** — acquired `chapter07/scene02 ≤ chapter08/scene01`, and nothing
  supersedes it, so **current**.
- **Guardrail** — active until `chapter09/scene04`, and `chapter08 < chapter09`,
  so **still active**.

**Reconstructed state at `chapter08/scene01`:** Mira's one current fact is
**kn-03** — she now *knows* the captain is the thief and the steward was covering
for him. The guardrail is still active — even after the correction, she must not
yet know about the baron.

## The earlier state survives the correction

This is the point of the non-destruction invariant. Reading the **chapter08**
version of the file — the same on-disk file, after both changes — we can *still*
reconstruct Position 1. kn-02 was not overwritten when it was corrected; it was
moved into `## Lost or superseded` **keeping its id**, with `held:
book1/chapter04/scene01 to book1/chapter07/scene02`. So the record that "at
`chapter05/scene01` Mira believed the steward was the thief" is intact and
reconstructable *after* she has learned the truth. A later correction never
deletes an earlier reconstructable state — it appends a transition and a new
stamped entry, and the prior belief stays on disk, addressable by its id.

That is what makes point-in-time reconstruction hold across corrections, and it
is exactly what this fixture exists to demonstrate.
