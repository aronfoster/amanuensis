# Objective-continuity fixture — the *Meridian* crossing

> **ILLUSTRATIVE EXAMPLE — NOT REAL PROJECT CANON OR STATE.**
> Per the Amanuensis Repository Boundary rule (`AGENTS.md`), objective
> continuity lives in this tooling repo *only* as a clearly-marked example. The
> *Meridian*, her crew (Voss, Halden, Rin, the quartermaster, the cook), the
> drafts (`draft-vNN.md`), and the story positions here are all invented to
> demonstrate the model. Nothing in this folder is a real character, a real
> project's state, or anything to reconcile against — do not treat it as canon
> and do not copy it into a story repo as fixtures for a real project.

## What this folder shows

A worked demonstration of the **objective-continuity model**
(`agents/continuity.md`) as it is realized in a `book`-project
`continuity/book-1.md`, spanning multiple chapters of a sea-voyage story. It is
one continuity file plus one character folder:

- `continuity/book-1.md` — the artifact. The objective facts the accepted prose
  committed, in the shapes from `templates/continuity-book.md`, exercising five
  of the seven maintained fact-classes — the four the demonstration turns on,
  plus a possession fact for richness:
  1. **Chronology (advancing).** Day 1 (co-02) at `book1/chapter01/scene01` and
     Day 12 (co-06) at `book1/chapter03/scene01` — each true at its own
     position, no supersession.
  2. **Event staging (recalled).** The night the water casks were found breached
     (co-03) at `book1/chapter02/scene04` — the canonical account a later recap
     must not contradict.
  3. **Role / assignment (changes, recorded non-destructively).** Voss commands
     the *Meridian* (co-01) until he is wounded, then Halden takes command
     (co-05) at `book1/chapter03/scene03` — the changing fact, recorded as a
     `## Superseded` transition plus a new stamped entry, never an overwrite.
  4. **Possession.** The ship's seal and log (co-04) pass to Halden with the
     post at `book1/chapter03/scene03` — the handover made material.
  5. **Open causal thread (the join key).** Who breached the water casks (co-07)
     — objectively the quartermaster.
- `characters/rin/profile.md` and `characters/rin/knowledge/book-1.md` — bosun
  Rin, a character **wrong about an objective fact**: she believes the *cook*
  breached the casks. Her `## Believes incorrectly` entry points at the
  objective fact via a qualified `truth:` reference — it never copies it.

Because this is a `book` project, story-positions are full folder-style
`book1/chapterNN/sceneNN` with zero-padded two-digit chapter/scene numbers, so
**lexical order equals chronological order** (`chapter02/scene02` sorts before
`chapter03/scene03`). Each entry the `continuity_update` step produced carries a
`- **review:** unreviewed` line — its provenance stamp
(`agents/steps/continuity-update.md`): the write is legible and human-auditable,
but the stamp is provenance only and never affects the reconstruction below.

Each entry also carries an `evidence:` pointer — the one field that distinguishes
objective fact from character belief. It is the **full attempt-qualified draft
path** (`plot/book1/chapterNN/drafts/attemptNN/draft-vNN.md#<scene>`, never a
bare basename), so a later step can retrieve the exact prose that supports the
fact when a summary is insufficient or disputed.

## How to answer an objective continuity question at a story position

`continuity/book-1.md` is the **sole authority** for maintained objective facts —
there is no index or derived-state file. To answer a material question at a
position `X`, read the ids, story-positions, and `## Superseded` transitions, and
apply one rule (the same rule the M14 character-state model uses,
`examples/character-state/README.md`):

> An entry is **current as of position `X`** iff its `story-position ≤ X` **and**
> it is not superseded by a transition whose supersession position `≤ X`.

A superseded entry's `held: A to B` says it was current for **`A ≤ X < B`**
(established at `A`, replaced at `B`). A still-current entry (one still sitting in
its fact-class section) is current for `story-position ≤ X` with no upper bound
yet. Comparisons are the plain lexical order of the zero-padded positions.

### (a) "Who commands the *Meridian*?" at two positions

The role fact and its one transition give us:

| id | established at | held / lives | superseded by |
| --- | --- | --- | --- |
| co-01 | `book1/chapter01/scene01` | held `chapter01/scene01` → `chapter03/scene03` | co-05 |
| co-05 | `book1/chapter03/scene03` | current in `## Role / assignment`, no upper bound | — |

#### Position 1 — `book1/chapter02/scene02` → **Voss**

Walk the two facts against `X = book1/chapter02/scene02`:

- **co-01** — established `chapter01/scene01 ≤ X`. Its held range
  `chapter01/scene01 → chapter03/scene03` requires `X < chapter03/scene03`, and
  `chapter02/scene02 < chapter03/scene03`, so **current**.
- **co-05** — established `chapter03/scene03 ≤ X` is **false** (`chapter03 >
  chapter02`), so **not yet in force**.

**Answer:** at `chapter02/scene02`, **Voss commands the *Meridian*** (co-01).

#### Position 2 — `book1/chapter04/scene01` → **Halden**

Walk the same two facts against `X = book1/chapter04/scene01`:

- **co-01** — held `chapter01/scene01 → chapter03/scene03`; `chapter04/scene01`
  is **not** `< chapter03/scene03`, so **not current** — superseded at
  `chapter03/scene03`.
- **co-05** — established `chapter03/scene03 ≤ chapter04/scene01`, and nothing
  supersedes it, so **current**.

**Answer:** at `chapter04/scene01`, **Halden commands the *Meridian*** (co-05,
which names that it supersedes co-01).

### (b) The evidence behind each answer

Each answer is backed by the `evidence:` pointer on the entry that was current —
the retrievable prose that supports it:

- **Position 1 (Voss)** — co-01's evidence:
  `plot/book1/chapter01/drafts/attempt01/draft-v02.md#scene01`. co-01 kept this
  pointer when it moved into `## Superseded`, so the earlier state stays
  verifiable after the handover.
- **Position 2 (Halden)** — co-05's evidence:
  `plot/book1/chapter03/drafts/attempt01/draft-v04.md#scene03` — the scene where
  Halden takes command.

### (c) Objective fact vs. character belief, side by side

This is the boundary `agents/continuity.md` draws — the objective fact lives
**once**, in `continuity/`; a character file records only belief and *points* at
it:

| | objective fact | Rin's belief |
| --- | --- | --- |
| where it lives | `continuity/book-1.md`, co-07 (`## Open causal threads`) | `characters/rin/knowledge/book-1.md`, kn-02 (`## Believes incorrectly`) |
| the claim | the **quartermaster** breached the water casks | the **cook** breached the water casks |
| support | `evidence:` `plot/book1/chapter03/drafts/attempt01/draft-v04.md#scene04` (established in prose at `chapter03/scene04`) | `truth:` `continuity/book-1.md#co-07` — a **qualified** pointer to the objective fact she is wrong about |

The character file never restates or overrides the objective fact: kn-02 carries
only Rin's (wrong) belief and defers, via `truth: continuity/book-1.md#co-07`, to
the one place the true state is maintained. The reference is qualified
(`continuity/book-1.md#co-07`, not a bare `co-07`) because continuity ids are
file-scoped and repeat across per-book files. co-07 is the natural **join key**:
one open thread that a character answers wrongly while the prose answers rightly.

## The earlier state survives the correction

This is the point of the non-destruction invariant. Reading the **chapter04**
version of `continuity/book-1.md` — the same on-disk file, *after* command has
transferred — we can still reconstruct Position 1. co-01 was not overwritten when
Halden took command; it moved into `## Superseded` **keeping its id**, with
`held: book1/chapter01/scene01 to book1/chapter03/scene03` and its `evidence:`
pointer intact. So the record that "at `chapter02/scene02` Voss commanded the
*Meridian*" is still on disk, reconstructable — and its supporting prose still
retrievable — after the handover.

A **diegetic** change (the story advances; command really transfers) never
deletes an earlier reconstructable state — it appends a `## Superseded`
transition and a new stamped entry, and the prior fact stays addressable by its
id. (An **authorial** `revise` — deciding the fiction should have read
differently all along — would instead correct the current entry in place, since
the earlier value was never true-in-the-fiction; that path is `revise`'s, not
`continuity_update`'s. See `agents/continuity.md`, "Diegetic vs. authorial
change.") That is what makes point-in-time reconstruction hold across a change,
and it is exactly what this fixture exists to demonstrate.
