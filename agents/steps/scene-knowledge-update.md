---
step_id: scene_knowledge_update
review_required: false
inputs:
  - <chapter-folder>/storyboards/*-storyboard.md
  - <chapter-folder>/drafts/<latest-attempt>/<latest-draft>
  - characters/<character-id>/knowledge/*.md
  - continuity/book-N.md
  - continuity/story.md
outputs:
  - characters/<character-id>/knowledge/book-N.md
  - characters/<character-id>/knowledge/story.md
preconditions:
  - path: <chapter-folder>/storyboards/*-storyboard.md
    kind: source
    required: true
    review_sensitive: false
  - path: <chapter-folder>/drafts/<latest-attempt>/<latest-draft>
    kind: prose_draft
    required: true
    review_sensitive: false
  - path: characters/<character-id>/knowledge/*.md
    kind: source
    required: false
    review_sensitive: false
  - path: continuity/book-N.md
    kind: source
    required: false
    review_sensitive: false
---

See `agents/orchestrator.md` for the step workflow contract.

# Scene Knowledge Update

## Purpose

Reconcile the character knowledge that the accepted chapter prose committed into each character's `knowledge/` files. This step is the **sole writer of `knowledge/`**: it reads the scene storyboards' knowledge deltas, confirms each delta against the drafted prose, and applies the confirmed facts to the project-type-appropriate knowledge file — a new fact as a stamped entry, a changed fact as a non-destructive transition plus the corrected state. It writes `knowledge/` and nothing else; `timeline.md`, `relationships.md`, `profile.md`, and canon are capture's or the human's to write, never this step's.

It runs at the **end** of the recipe, after `anti_ai_fix`, so it reads the *accepted* (final) chapter prose and produces the character state the next chapter's planning (`scene_generation` / `storyboarding`) reads. Its writes are capture-style — provenance-stamped, marked `unreviewed`, and non-destructive — but carry **no human gate** (`review_required: false`): applying a confirmed scene delta to a knowledge file is mechanical enough that no approval blocks the pipeline. "Reviewable" here means the writes are legible, traceable, and non-destructive — a human *can* audit any `unreviewed` entry and reconstruct any earlier state — not that a human must approve each one.

The temporal model these writes realize — the canonical story-position reference, the durable `id`, the `committed-in` provenance stamp, `basis`, the current / historical-transition / prospective-constraint sections, and the non-destruction invariant — is defined once in `agents/characters.md` (**## Temporal character-state model**). This step follows that model and does not restate it; the field shapes are in `templates/knowledge-book.md`.

## Inputs

- `<chapter-folder>/storyboards/*-storyboard.md` — the chapter's storyboard blocks. Each block's `## Knowledge Delta` section (`agents/storyboard-schema.md`) and the compact per-scene delta attached at the end of storyboarding (`agents/workflows.md`) are the mechanical input this step confirms and applies. The delta lines use the form `[CharacterName] now knows: <fact> [from <story-position>]` and `[CharacterName] falsely believes: <fact> [from <story-position>]`, with the canonical story-position citation (`<book-id>/<chapter-id>/<scene-id>`, reduced to `<scene-id>` for `short_story`).
- `<chapter-folder>/drafts/<latest-attempt>/<latest-draft>` — the accepted chapter prose. Resolved at step start via the attempt manifest's `Active-head:` pointer per `agents/project-layouts.md`, not by highest-numbered draft. This step reads a draft but does not mint one.
- `characters/<character-id>/knowledge/*.md` — the character knowledge files this step reconciles into. Read to locate the reconcile target, respect its `edit_policy`, and match already-recorded entries by `id`. Not required to pre-exist: the step creates the project-type target if it is absent.
- `continuity/book-N.md` (`book` / `series`) or `continuity/story.md` (`short_story`) — the objective-continuity file, read `required: false` for one purpose only: to resolve the objective fact a `## Believes incorrectly` entry contradicts and write a qualified `truth: continuity/book-N.md#co-NN` reference to it (see Behavior). The precondition names `continuity/book-N.md`; for `short_story` it resolves to `continuity/story.md`. This is a continuity **read**, never a write — `continuity/` has one writer, the `continuity_update` step (`agents/steps/continuity-update.md`), which runs just before this step. Because the input is `required: false`, when `continuity/` is absent or the steps run out of order the step falls back to a free-text `truth:` and does not block.

## Behavior

Run in this order:

1. **Extract each character's knowledge delta.** Read the scene's storyboard blocks in order and collect, per character, the knowledge-delta lines (the block `## Knowledge Delta` section and the scene's attached delta, in the `agents/workflows.md` format above). Each delta line names a character, a fact, its kind (newly knows / falsely believes), and the source story-position.

2. **Confirm each delta against the drafted prose.** Read the accepted `<latest-draft>` and check that the prose actually committed the fact the delta claims. If the prose committed something different from the delta, **correct the delta to what the prose committed** before applying it — the drafted prose is what happened, and the storyboard delta is a forecast that drafting may have revised (this mirrors `compliance_report`'s "confirm against prose"). A delta the prose did **not** commit is not applied at all.

3. **Reconcile the confirmed deltas into the project-type target.** The target is `characters/<character-id>/knowledge/book-N.md` for `book` and `series` projects and `characters/<character-id>/knowledge/story.md` for `short_story` projects (create the target if absent; `baseline.md` stays pre-story only and is never written by this step). Before writing, read the target's frontmatter `edit_policy` (Rule 7, `agents/update-rules.md:62-108`): a `locked` or `propose_only` target is **not** written — record an open question describing the fact, the target, and the routing decision, exactly as capture does for a blocked target. For a writable target:

   - A **new** fact appends a stamped entry to the right current-state section — `## Knows`, `## Suspects`, or `## Believes incorrectly` — carrying `id` (the next unused `kn-NN` for the file, minted once), `story-position` (canonical format), `committed-in` set to the resolved active-head draft's **full attempt-qualified path** `<chapter-folder>/drafts/<attemptNN>/draft-vNN.md` (**not** a bare `<latest-draft>` basename — a bare basename repeats across chapters *and* attempts and would false-fresh on a collision, mirroring how `continuity_update` writes `evidence:` as a full path), `basis` (`witnessed` | `told` | `inferred`), and the `unreviewed` marker `- **review:** unreviewed`. An incorrect belief also carries `truth:` for continuity tracking, per the template. When it writes a `## Believes incorrectly` entry, the step resolves the objective fact the belief contradicts from the continuity file read above — matching the belief to the objective fact it contradicts by subject — and writes a **qualified** `truth:` reference to it, naming **this project's** continuity file — `continuity/book-N.md#co-NN` for a `book`/`series` project, `continuity/story.md#co-NN` for a `short_story` (never a `book-N` path in a short story, whose file is `continuity/story.md` — that pointer would not resolve; qualified because `co-NN` ids are file-scoped, so a bare `co-NN` is ambiguous). This reference is **advisory** and **non-fabricating**: it is written only on a confident match; absent one — or when `continuity/` is absent (the input is `required: false`) or the steps ran out of order — the step falls back to a **free-text `truth:`** (the M14 behavior, per the template) and **never invents a pointer**. This is a continuity **read**, never a continuity **write** — the objective fact lives once, in `continuity/`; this step points at it and reconciles into `knowledge/` only. Reveal timing is unaffected: `truth:` is continuity-tracking metadata, not character knowledge (it already held objective-truth text in M14), so writing a pointer instead of prose changes no reveal-timing behavior. The reference degrades gracefully as the fact evolves: a diegetic supersession moves the target `co-NN` to `## Superseded` keeping its id and naming its successor (the pointer chases forward to the record), and an authorial `revise` corrects the target in place keeping its id (the pointer still resolves) — see `agents/continuity.md`.
   - A **changed** fact (a correction of an entry already in the file) appends a `## Lost or superseded` transition that cites the **prior entry's** `id` — with `held` (from/to story positions), the prior entry's `committed-in` (its own full attempt-qualified path, carried unchanged), `superseded-by` (the new entry's `id`), and `what changed` — **and** appends the corrected state as its **own** new stamped entry (new `id`) in the appropriate current-state section, stamped with the resolved active-head draft's full attempt-qualified `committed-in` path exactly as a new fact is, naming the entry it supersedes. The superseded entry is **never** overwritten or deleted; it is moved into the transition section, keeping its `id`. This is the non-destruction invariant (`agents/characters.md`, **## Temporal character-state model**) and it is a hard rule of this step.

   The step does **not** author `## Must not know yet`. Prospective reveal-timing constraints are authored by planning, not derived from committed prose.

4. **Reveal-timing safety.** The step records only what committed prose *already established* — it is recording history, never forecasting a premature reveal (Rule 2, `agents/update-rules.md:29-37`). Because it writes what a character learned from prose that already happened, and never writes the prospective `## Must not know yet` constraints, its `review_required: false` write is safe re: reveal timing.

5. **Completion.** The step's final action is to mark its own step line `[x]` in `pipeline-state.md` and update `last_updated`. It mints **no** draft and does **not** touch the attempt manifest's `Active-head:` (it is not a prose-advancing step; the lineage/supersession algorithm in `agents/project-layouts.md` does not run).

## Idempotency / rerun

Re-running this step against the **current active head** appends corrections as transitions and duplicates nothing. Before appending, match the confirmed delta against the file's existing entries by `id` and by `(story-position + fact)`:

- a fact already recorded against the current active head (its `committed-in` in the active-head lineage of the source chapter's `<latest-attempt>`) is **not** re-appended;
- a fact that **corrects** an existing entry (its value changed) is recorded once as a transition plus a new stamped entry, not re-appended on every run;
- a fact whose value is **unchanged** but whose matched entry's `committed-in` is stamped in a **superseded (non-latest) attempt** — so the entry has gone **derived-stale** under the latest-attempt-qualified predicate (see Freshness) even though nothing in the fiction changed — is **restamped in place**: re-confirm it against the current active head and refresh its `committed-in` to the current attempt's full draft path, **keeping the entry's `id`** and appending **no** new entry and **no** `## Lost or superseded` transition. This is a **provenance refresh**, the knowledge analog of continuity's authorial/draft-level in-place restamp (`agents/continuity.md`, "Diegetic vs. authorial change"), and it is the operation a rerun performs to clear the superseded-attempt **state** defect `compliance_report` surfaces for an otherwise-valid entry after a redraft.

A rerun therefore converges — it never accumulates duplicate entries or duplicate transitions for the same committed fact, and it leaves no otherwise-current fact stranded on a superseded-attempt stamp.

This **contrasts** with `character_extraction`'s overwrite-on-rerun (`agents/steps/character-extraction.md`, **### Idempotency**): that step regenerates its output paths and discards hand-edits, whereas this step is append-only and non-destructive — a rerun never overwrites or deletes an accumulated entry, and prior state always survives.

## Freshness

Freshness of a knowledge entry is a **derived predicate**, never a stored field and never swept. Resolved against the entry's **full attempt-qualified `committed-in:` path** (`<chapter-folder>/drafts/<attemptNN>/draft-vNN.md`), a knowledge entry is **fresh** iff **both** (a) its stamped attempt equals the source chapter's `<latest-attempt>` **and** (b) its draft is in that attempt's active-head lineage; it is **derived-stale** otherwise. In particular an entry stamped in a **superseded (non-latest) attempt is stale** even though it still resolves "in lineage" against that superseded attempt's own frozen manifest — a full path removes basename ambiguity but does not by itself establish the stamped attempt is still current. This is computed O(1) from the entry's full-path stamp and the attempt manifest's `Active-head:` / `read_from` chain (`agents/project-layouts.md`, "Attempt-level provenance"). It mirrors the `Reviewed-draft:` freshness predicate for prose-derived side artifacts (`agents/orchestrator.md`, **## Artifact state**): freshness is computed from facts already on disk (the entry stamp and the manifest's active lineage), written as no field, and maintained by no sweep over the knowledge tree.

The full rule lives in `agents/characters.md` (**## Temporal character-state model**, "Freshness is derived, never stored"); this step computes the predicate but does not restate the model. Correction of a stale entry is the rerun-reconcile above: a rerun against the current active head reconciles what the accepted prose committed and — when the fact **changed** — appends the correction as a transition, or — when the fact is **unchanged** but its provenance points at a superseded attempt — **restamps its `committed-in` in place** (a provenance refresh; see Idempotency). Either way a rerun clears the stale bit without leaving the fact stranded.

**Dispatcher-level staleness detection is out of scope** — a deliberate non-goal, exactly as dispatcher-level artifact staleness is (`agents/orchestrator.md:187`). This step defines the predicate; nothing walks the character tree to enforce it.

## Outputs

- `characters/<character-id>/knowledge/book-N.md` (`book` / `series`) or `characters/<character-id>/knowledge/story.md` (`short_story`) — the reconciled knowledge file, created if absent. Confirmed new facts appended as stamped entries (`id`, `story-position`, `committed-in` as the resolved active-head draft's full attempt-qualified path `<chapter-folder>/drafts/<attemptNN>/draft-vNN.md` [not a bare `<latest-draft>` basename], `basis`, `- **review:** unreviewed`) in the appropriate current-state section; confirmed corrections appended as `## Lost or superseded` transitions plus their new stamped corrected-state entries. Pre-existing entries are never modified or removed. `baseline.md` is not written by this step.
- `pipeline-state.md` — this step's own line set to `[x]` and `last_updated` refreshed, as the completion action. No draft is minted; the manifest's `Active-head:` is untouched.

## Anti-Patterns

**Writing anything but `knowledge/`.** This step is the sole writer of `knowledge/` and writes *only* `knowledge/`. `timeline.md`, `relationships.md`, `profile.md`, and canon belong to capture or the human — touching them here is a boundary violation.

**Overwriting or deleting an accumulated entry.** A **value** correction is always a `## Lost or superseded` transition plus a new stamped entry, never an in-place value rewrite. Overwriting or deleting a prior entry's fact destroys point-in-time reconstruction and breaks the non-destruction invariant. (A **provenance refresh** — restamping an unchanged fact's `committed-in` to the current draft after a redraft, per Idempotency — is **not** a value rewrite: it changes only the provenance pointer, preserves the fact, its `story-position`, and its `id`, and destroys no reconstructable state, so it does not breach this invariant. It is the same in-place discipline continuity applies to an authorial/draft-level change, `agents/continuity.md`.)

**Applying an unconfirmed delta.** A storyboard delta is a forecast. If the drafted prose committed something different, correct the delta first; if the prose committed nothing, do not apply the delta at all. Applying a delta the prose did not enact records a fact the character never actually acquired.

**Authoring `## Must not know yet`.** Prospective reveal-timing constraints are planning's, not derived from committed prose. This step records what a character learned, never what they must not yet learn.

**Re-appending an already-recorded fact.** A rerun matches existing entries by `id` / `(story-position + fact)` and appends only genuinely new facts and corrections. Re-appending a fact already recorded against the current active head inflates the file with duplicates.

**Writing into a locked or propose-only target.** A `locked` / `propose_only` knowledge file is not written; record an open question instead (Rule 7). No silent write into an edit-policy-protected target, ever.

## Open questions handling

If the step cannot complete because of missing or ambiguous inputs — no storyboard files, no resolvable `<latest-draft>`, a delta whose character has no resolvable folder, or a reconcile target whose `edit_policy` is `locked` / `propose_only` — append the blocker (or the recorded open question for the blocked target) to the project-root `open-questions.md` and exit without recording completion in `pipeline-state.md`. Do not fabricate deltas, do not invent facts the prose did not commit, and do not write into a protected target. The next dispatcher invocation re-runs this step after the human resolves the blocker. On a successful run, the step's final action is to mark its own step line `[x]` in `pipeline-state.md` and update `last_updated`.
