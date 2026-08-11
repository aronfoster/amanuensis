# Continuity Rules

The `continuity/` folder holds **objective story continuity** — the facts that are true in the
story world independently of what any character believes: chronology, event staging, where things
and people are, who holds what, physical condition, roles and assignments, and unresolved causal
threads. It is the objective-truth complement to the character-relative state M14 records in
`characters/`: M14 records what a character *believes*; `continuity/` records what is *true* in the
fiction, and gives each maintained fact a retrievable pointer to the accepted artifact that
supports it.

`continuity/` files are `role: derived_state`: maintained state derived from accepted prose, not
authored planning. Its single writer is the `continuity_update` step
(`agents/steps/continuity-update.md`); no other step or agent writes it. This is the same
single-writer discipline `knowledge/` has.

## The boundary

Each class of fact has exactly one authority.

- **Objective, evolving story facts** → `continuity/` (this doc). The facts the prose establishes
  and revises as the story advances: what day it is now, who holds the knife now, who is at the
  helm this chapter, where the party is, what was staged at a named event.
- **Character-relative belief** → `characters/<id>/knowledge/` + `timeline.md` + `relationships.md`
  (M14). What a character knows, suspects, believes incorrectly, feels, or has wrong.
- **Stable world truth** → `canon/` (+ `canon/generated/`). Intentionally-stable rules, history,
  and institutions that hold across books and chapters unless deliberately revised
  (`agents/canon.md`).
- **Beat intent / specification** → storyboards. What a beat is *supposed* to do
  (`agents/storyboard-schema.md`).
- **Source of record** → the accepted drafts and the planning artifacts. The prose itself, and the
  outlines/summaries behind it.

`continuity/` is the **sole authority** for maintained objective story facts. It **never restates
or overrides `canon/`.** Canon outranks continuity (`agents/canon.md`, Canon priority): a settled
world rule lives in `canon/` once and continuity does not copy it. Where the prose contradicts
settled canon, that contradiction is **surfaced**, not absorbed — `continuity_update` records it as
a conflict rather than overwriting canon or writing the contradicting value as a fact.

Character files never claim objective authority — a character file records belief and points at
`continuity/` for the true state only where continuity tracking needs it (see
`agents/characters.md`, "Character files record belief, not objective truth"). `continuity/` is the
referent those files defer to.

## Granularity policy — what to maintain

Not every fact in the prose is maintained here. A one-off detail that lives in a single scene and is
never referenced again stays in the prose; lifting it into `continuity/` is noise.

**Maintain a fact iff it is both:**

1. **Relational** — its correctness depends on comparison across scenes (a later scene can agree or
   disagree with it); and
2. **Capable of a reader-visible contradiction** — getting it wrong later would be a mistake a reader
   could catch.

A single-scene throwaway detail (relational to nothing, contradictable by nothing) stays in prose.

### The seven maintained fact-classes

1. **Chronology / time anchors** — day count, date, season, elapsed-time claims. These are
   **additive**: each anchor is permanently true at its own story position, so an advancing anchor
   ("Day 1" at one scene, "Day 12" at a later one) is recorded as a **new** entry, *not* a
   supersession of the earlier one — both stand. An anchor that **asserts the current timeline has
   regressed** (a later scene claiming an earlier time, with no flashback framing) is a **conflict**,
   surfaced rather than written — but an **intentional flashback, recollection, or recounted scene** is
   not a regression: narrative order and story-world time are not always monotonic, so its earlier-time
   anchor is recorded at the story-world time it depicts, not surfaced as a conflict.
   Only genuinely mutable, single-valued state (below) is superseded when it changes.
2. **Event staging** — the canonical staging of named events, for recall/recap fidelity (what was
   said, who was present, how it happened).
3. **Location** — where an entity or party is.
4. **Possession** — who holds what.
5. **Physical condition** — injuries, states of persons or objects.
6. **Role / assignment** — rank, title, post ("who is at the helm").
7. **Open causal threads** — unresolved threads capable of a later contradiction. A thread's status is
   **mutable single-valued state**: when later prose **answers** it, the open entry is superseded by a
   resolved entry — a `## Superseded` transition keeping the open entry's `id`, so a character `truth:`
   pointer to it chases forward — not recorded as an unrelated additive fact.

The **open-thread** class is the natural join key for the character-belief → objective reference
(below): a contested question ("who is the thief?") is one open thread that a character may answer
wrongly while the prose later answers rightly.

## Temporal / provenance / evidence model

`continuity/` reuses M14's temporal idiom without inventing a parallel model. The rules for `id`,
`story-position`, `committed-in`, the non-destruction transition discipline, and derived freshness
are defined once, authoritatively, in `agents/characters.md`'s **"## Temporal character-state
model"** — see it; they are **not** restated here.

Applied to `continuity/`:

- **`id`** — `co-NN` (`co-01`, `co-02`, …), file-scoped, minted once, never changed — the same
  discipline as `kn-`/`tl-`/`rel-`.
- **`story-position`** — canonical folder-style `<book-id>/<chapter-id>/<scene-id>`, reduced to
  `<scene-id>` for `short_story`.
- **`committed-in: draft-vNN.md`** — the accepted draft that committed the fact into the prose.
- **Non-destruction transitions** — a changed fact is never overwritten; the superseded entry moves
  to a `## Superseded` section keeping its `id`, and the new value is recorded as its own new
  stamped entry (see "Diegetic vs. authorial change" below).

**The one added field: `evidence:`.** This is the single field that distinguishes objective fact
from character belief, and the only addition beyond M14's idiom. `evidence:` is a **retrievable
pointer** to the accepted artifact that supports the fact, so a later step can retrieve the original
when a summary is insufficient or disputed. It is the objective-fact counterpart to knowledge's
`basis:` — where `basis:` records the character's *grounds* (witnessed | told | inferred), `evidence:`
records the objective *support on disk*.

The pointer is the **full attempt-qualified draft path**:

```
<chapter-folder>/drafts/<attemptNN>/draft-vNN.md#<scene>
```

plus the storyboard block and/or canon file where they apply. It is a **full path, never a bare
`draft-vNN.md` basename** — one `continuity/book-N.md` accumulates entries from every chapter and
attempt of the book, whose `draft-vNN.md` basenames repeat, so a bare basename names no single file
and would false-fresh on a collision (the one failure a maintained-state artifact must never make).

## Character belief refers to objective fact — never copies it

A character's incorrect belief is recorded in `characters/<id>/knowledge/` (`## Believes
incorrectly`). Its `truth:` field may carry a **qualified** reference to the objective fact the
belief contradicts:

```
truth: continuity/book-N.md#co-NN   # book / series
truth: continuity/story.md#co-NN    # short_story
```

The reference is **qualified** by **this project's** continuity file — `continuity/book-N.md#co-NN`
for `book`/`series`, `continuity/story.md#co-NN` for `short_story` — not a bare `co-NN`, because
`co-NN` ids are file-scoped and repeat across files, so a bare id is ambiguous. (A `book-N` path
written into a `short_story`, whose file is `continuity/story.md`, would not resolve.) The objective
fact lives **once**, in `continuity/`; the character file **points, never copies or overrides**.

The reference is **advisory** and **degrades gracefully**:

- Under a **diegetic supersession**, the target `co-NN` moves to `## Superseded` keeping its id and
  naming its successor, so the pointer chases forward to the record of the fact it named.
- Under an **authorial `revise`**, the target is corrected in place, keeping its id, so the pointer
  still resolves.

The reference is written by `scene_knowledge_update` (the sole writer of `knowledge/`) as a
continuity *read*, never a continuity *write*, and non-fabricating: free-text `truth:` remains the
correct fallback when there is no confident match.

## Diegetic vs. authorial change

A maintained fact can change two ways, and the two are recorded differently. This distinction is
stated **once, here**, because it governs both writers and applies equally to M14's non-destructive
temporal-state files (`knowledge/`, `timeline.md`, `relationships.md`).

- **Diegetic change** — the **story advances** and the fact changes *in the fiction*, so the new
  value appears at a **later story position** (the ship's new captain takes the helm next chapter; the
  next day begins). At the earlier position the earlier value really was the case, so it is preserved:
  a **non-destructive `## Superseded` transition** plus a new stamped entry. **Owned by
  `continuity_update`.**
- **Authorial / draft-level change** — the prose at a story position is **rewritten without the story
  advancing**, so a fact's value changes at the **same story position**: a human **`revise`** changing
  what the fiction says (the day was always meant to be Tuesday; fix it), or a **fix-step rerun or
  branch** producing a new active head that corrects an objective fact where it already stood. The
  earlier value was **never true-in-the-fiction** — it was a draft being corrected, and the archived
  drafts are its record — so the entry is **corrected in place**, keeping its `id`, with its
  `committed-in`/`evidence:` moved to the draft that now carries the fact. **`revise` owns the human
  case; `continuity_update`'s rerun-reconcile owns the draft-correction case.** A transition here would
  fabricate an in-story change that never happened. **The same in-place restamp — no transition —
  applies when a redraft re-commits a fact whose *value is unchanged* but whose entry was stamped in a
  now-superseded attempt:** rerun-reconcile re-confirms the fact against the current active head and
  moves the entry's `committed-in`/`evidence:` to the current draft (a pure **provenance refresh**,
  keeping the `id`), which is what restores freshness under the latest-attempt-qualified predicate
  (below) without recording a change that did not happen. The value was never in question; only the
  draft carrying it advanced.

This mirrors how `revise` already edits the active-head draft in place while leaving superseded
drafts as the record (`agents/revision.md`). Current-state entries carry current truth — edit them
in place under an authorial change. A `## Superseded` transition's **structure** — its `id`, its
held-from/to range, and its `superseded-by` link — is the record of a *diegetic* change and is never
fabricated, re-timed, or deleted by a revision (nor does a revision ever add a transition of its
own). But the **value** a superseded entry stores is still an objective claim, and an authorial
`revise` may correct it **in place, keeping the transition structure**, when the human changes what
was always true at that earlier position — otherwise the rejected value would stay the maintained
answer for that position. An in-place correction follows the corrected prose: the entry's
`committed-in`/`evidence:` move to the draft that now carries the fact (`agents/revision.md` states
the procedure, including new-draft mode).

## Freshness

Freshness is a **derived predicate**, never a stored field and never swept — the M14 freshness rule
(`agents/characters.md`, "Freshness is derived, never stored"), applied to `continuity/`. A
continuity entry is:

- **derived-stale** iff its stamped attempt is not the source chapter's `<latest-attempt>` **or** its
  draft is outside that attempt's active-head lineage — the predicate is **latest-attempt-qualified**:
  an entry stamped in a **superseded (non-latest) attempt is stale** even though it still resolves "in
  lineage" against that superseded attempt's own frozen manifest, the same precision applied to the
  M14 predicate (`agents/characters.md`, "Freshness is derived, never stored"); and
- **derived-unsupported** iff its `evidence:` pointer no longer resolves in the active prose.

Both are resolved against the manifest and prose identified by the entry's **full evidence path**
(`<chapter-folder>/drafts/<attemptNN>/draft-vNN.md`) — unambiguous across chapters *and* attempts (a
bare basename would false-fresh on a collision) — and both are O(1) from facts on disk, never
stored, never swept.

The predicate covers the **prose axis only**: the draft is the one evidence source with a version
model. A change to a **non-prose evidence source (storyboard, canon) or an earlier continuity
entry** does not flip a derived bit — it is handled by **rerun-reconcile** (re-running
`continuity_update` re-confirms each fact against the current prose and canon and surfaces any new
contradiction as a conflict) and by M16 review, not by a stored dependency graph. Proactive /
dispatcher-level detection is a deferred follow-on, exactly as dispatcher-level artifact staleness
is (`agents/orchestrator.md`).
