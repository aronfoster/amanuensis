# Character Folder Rules

Each character folder represents one character's canonical identity and changing story state.

## Purpose of a character folder

Character folders exist to separate stable character facts from evolving character state.

## Expected character files

### `profile.md`
Stable character core.

Use this file for:
- identity
- role in story
- motivations
- fear
- flaw
- wound
- strengths
- limits
- voice
- arc shape
- continuity constraints

Do not use this file for chapter-by-chapter updates.

### `timeline.md`
Chronological record for the character.

Use this file for:
- life events
- important pre-story events
- major story events affecting the character

### `relationships.md`
Relationship dynamics.

Use this file for:
- important connections
- changing interpersonal dynamics
- power balance
- misunderstandings
- loyalties and fractures

### `knowledge/`
Knowledge-state tracking. One file per book, plus a baseline file for pre-story state.

- `baseline.md` — what the character knows before the story begins
- `book-1.md`, `book-2.md`, etc. — knowledge acquired or changed during each book

Each file contains structured entries, not flat bullets. See **Knowledge file format** below.

This is one of the most important systems in the repository.

## Knowledge file format

Each knowledge entry is a discrete fact with a short searchable heading and structured fields. Its fields — `id`, `story-position`, `committed-in`, `basis` — realize the **Temporal character-state model** defined below, which governs `knowledge/`, `timeline.md`, and `relationships.md` alike. See the [knowledge-book.md](templates/knowledge-book.md) template for the field shapes.

Knowledge items are only written to these files by the `scene_knowledge_update` step (`agents/steps/scene-knowledge-update.md`), the sole writer of `knowledge/`, after drafting confirms what the scene committed. Storyboarding reads these files as inputs; it does not write to them.

## Temporal character-state model

Character state changes as the story advances. This section defines, once and authoritatively, how that change is recorded across a character's `knowledge/` files, `timeline.md`, and `relationships.md`. All three realize this one model. The templates (`templates/knowledge-book.md`, `templates/timeline.md`, `templates/relationships.md`) show the field shapes at each altitude, but the rules below are the source of truth and are not restated per file.

**Character files record belief, not objective truth.** A character file records what the character *believes* to be true — character-relative state — as of a point in the story. Objective facts (what actually happened, world continuity) are deferred to their own authority: stable world truth to `canon/`, and evolving objective story facts to `continuity/`, whose model is defined in `agents/continuity.md`. A character file never claims objective authority. This is the M15 boundary, and `agents/continuity.md` is the authority it resolves to: a character may hold something false, and the file records the belief, noting the true state only where continuity tracking needs it (the `truth:` field on an incorrect belief, which may carry a qualified `continuity/book-N.md#co-NN` reference to the objective fact — see `agents/continuity.md`).

**Sole authority.** The character Markdown files are the sole authority for character-relative state. No parallel index, database, or derived-state file is introduced. Reconstructing what a character knew, felt, or experienced at any story point is done by reading these files, and nothing else.

**Canonical story-position reference.** Every entry that cites where a change occurred uses one format: folder-style `<book-id>/<chapter-id>/<scene-id>` (for example `book1/chapter02/scene03`), ordered lexically book → chapter → scene. For `short_story` — no book, no chapter subdivision — it reduces to `<scene-id>` (for example `scene03`). This is the same citation the knowledge delta uses (`agents/workflows.md`). The deprecated `xx-yy` numeric-prefix form is retired; do not use it.

**Durable id.** Each entry carries a visible, human-readable `id` field — a normal structured field, not an HTML-comment anchor — scoped to the character's file, minted once and never changed. Knowledge entries use `kn-01`, `kn-02`, …; timeline entries `tl-01`, …; relationship entries `rel-01`, …. Later steps and transitions cite the id to refer to an entry without depending on its position in the file.

**Provenance stamp.** Each entry carries `committed-in:`, naming the accepted draft that committed the fact into the prose **by its full attempt-qualified path** — `<chapter-folder>/drafts/<attemptNN>/draft-vNN.md` (for example `plot/book1/chapter02/drafts/attempt01/draft-v03.md`), never a bare `draft-vNN.md` basename. The story position says *where in the story* the change happened; the provenance stamp says *which draft* established it. A bare basename is ambiguous: for `book`/`series` one `knowledge/book-N.md` aggregates entries across chapters *and* attempts whose `draft-vNN.md` basenames repeat, so a bare basename names no single file and would mark an entry **false-fresh on a collision** — the same reason M15's `continuity/` `evidence:` pointer is a full path (`agents/continuity.md`, **## Temporal / provenance / evidence model**). Where that full path lives depends on file type: the **character-state files** (`knowledge/`, `timeline.md`, `relationships.md`) have no separate evidence field, so `committed-in:` itself carries the full attempt-qualified path and freshness resolves against it; `continuity/` instead carries the full path in its `evidence:` field and keeps `committed-in:` a bare label (`agents/continuity.md`).

**Basis.** Each knowledge or experience entry carries `basis:` — one of `witnessed` | `told` | `inferred` — recording how the character came to hold it. "Remembered" is not a separate basis: a remembered fact is one `witnessed` at its source scene (held by direct experience of a prior scene) and still held later. The basis is the character's grounds, not the fact's truth — an `inferred` or `told` fact may be wrong.

**Current, historical, and prospective state.** The knowledge sections map the three, and the other two files carry the same distinction at their altitude:

- **Current state** — what the character holds now: `## Knows`, `## Suspects`, `## Believes incorrectly`.
- **Historical transitions** — states once held and since corrected or lost: `## Lost or superseded`.
- **Prospective constraints** — reveal-timing guardrails on what the character must *not* yet hold: `## Must not know yet`.

`timeline.md` records current vs. corrected events; `relationships.md` records a current dynamic vs. a superseded prior loyalty — the same current/historical split.

**Non-destruction invariant (hard).** A later update never deletes or overwrites an earlier reconstructable state. A correction moves the superseded entry into the file's transition section (`## Lost or superseded` for knowledge; the parallel superseded section in `timeline.md`/`relationships.md`) — carrying its `id`, its held-from/held-to story positions, its `committed-in`, and what changed — and records the corrected state as its **own** new stamped entry with a new `id` in the appropriate current-state section, naming the entry it supersedes. This is the same append-don't-destroy discipline draft lineage uses (superseded drafts stay on disk unmodified, `agents/project-layouts.md`), and it is what makes point-in-time reconstruction possible.

**Freshness is derived, never stored.** An entry's full attempt-qualified `committed-in:` path makes its freshness a derived predicate — but a full path removes basename ambiguity without by itself establishing that the stamped attempt is still the source chapter's `<latest-attempt>`: an entry stamped `…/attempt01/draft-vNN.md` still resolves "in lineage" against `attempt01`'s own frozen manifest even after the chapter is redrafted into `attempt02` (`agents/project-layouts.md`). So the predicate is **latest-attempt-qualified**: an entry is **fresh** iff **both** (a) its stamped attempt equals the source chapter's `<latest-attempt>` **and** (b) its draft is in that attempt's active-head lineage; it is **stale** otherwise. In particular an entry stamped in a **superseded (non-latest) attempt is stale**, because its basis prose is no longer the chapter's current prose — even though it still resolves in lineage against that superseded attempt's own frozen manifest. This stays computed O(1) from the entry stamp and the attempt manifest. It mirrors the Artifact-state / `Reviewed-draft:` freshness contract (`agents/orchestrator.md`, "Artifact state"): freshness is never written as a field, and no step sweeps the character files to maintain it. The workflow that computes this predicate and reconciles a stale entry is defined separately; the model states only the rule so that workflow can reference it.

## Character update expectations

When chapter events change:
- knowledge
- belief
- suspicion
- relationship state
- timeline facts

update the relevant character files or note the missing update explicitly, following the workflows in `agents/workflows.md`.

## Creating a new character folder

When a character is expected to appear in an upcoming scene and no character folder exists yet, create the folder and base files before storyboarding that scene.

**Minimum required files:**

- `profile.md` — fill in identity, role, and any continuity constraints known at this time; leave unknown fields explicitly blank rather than invented
- `knowledge/baseline.md` — what the character knows before the story begins
- `knowledge/book_n.md` for each book they appear in — create as empty scaffolds; fill during scene knowledge updates

**Optional at creation, required before the character affects plot:**

- `timeline.md`
- `relationships.md`

**Where to create:** `characters/<character_id>/`

Use the character's `character_id` (snake_case) as the folder name. If the character is named but their role is not yet settled, create a minimal profile and mark `status: stub` in the frontmatter.

Invention here is governed by Rule 1 in `agents/update-rules.md`. A character's identity and other character-knowledge-load-bearing fields are load-bearing, so Rule 1 forbids inventing them: leave a genuinely-unknown such field uncertain rather than invented, and record that uncertainty explicitly.
