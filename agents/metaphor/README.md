# Metaphor Subsystem

The metaphor pipeline consists of three orchestrator steps and three subagent prompt contracts.

---

## Roles

**Step workflows** (invoked by the dispatcher; live under `agents/steps/`):

- `agents/steps/metaphor-identify.md` — extracts every live metaphor and simile from the latest prose into `<chapter-folder>/drafts/<latest-attempt>/metaphors.md`. `review_required: true`.
- `agents/steps/metaphor-fix.md` — coordinator step. Reads the human-annotated `metaphors.md`, dispatches one subagent per annotated entry in parallel against the contracts below, and appends each subagent's variants to its entry. `review_required: true`.
- `agents/steps/metaphor-apply.md` — applies the human-selected variant to the prose, producing `<chapter-folder>/drafts/<latest-attempt>/draft-metaphor.md`. `review_required: false`.

**Subagent prompt contracts** (not steps; live in this directory and are dispatched by `metaphor_fix`):

- `metaphor-flatten.md` — generates literal rewrites for `FLATTEN`-annotated entries.
- `metaphor-replace.md` — integrates a human-supplied target image for `REPLACE: [target image]`-annotated entries.
- `metaphor-workshop.md` — generates replacement candidates for `WORKSHOP`-annotated entries where the human has not supplied an image. The integration phase that previously lived in this contract has been removed; integration is `metaphor_apply`'s job.

---

## Pipeline

1. **`metaphor_identify`** runs against the latest prose and writes `metaphors.md` with one entry per live figure.
2. **Human review.** The human edits `metaphors.md` directly. For each entry, they:
   - Delete it (the figure is sound, no action).
   - Add `FLATTEN` (remove the figure).
   - Add `REPLACE: [target image]` (the human supplies the replacement image).
   - Add `WORKSHOP` (the human wants candidates generated).
   Inline corrections to identify fields (tenor, implication, register fit) are accepted; the fix subagents will use them.
3. **`metaphor_fix`** runs as a coordinator. It reads `metaphors.md`, identifies every annotated entry, and dispatches one subagent per entry in parallel — `FLATTEN` against `metaphor-flatten.md`, `REPLACE` against `metaphor-replace.md`, `WORKSHOP` against `metaphor-workshop.md`. Each subagent receives only what its prompt contract requires (the entry block, the surrounding paragraph from the latest prose, and — for workshop — the storyboard block plus the voice file). Each subagent appends variants directly below its assigned entry.
4. **Human selection.** The human deletes the variants they are not using, leaving exactly one variant per entry — the one to be written into the draft.
5. **`metaphor_apply`** runs against the post-selection `metaphors.md`, applies the surviving variants to the latest prose, and writes `draft-metaphor.md`. Workshop entries arrive as bare sentences (since workshop's integration phase was removed); the apply step's existing sentence-variant branch handles them.

---

## Working document

`metaphors.md` is the working document for the entire pipeline. It begins as the identify output, accumulates variants in the fix step, and becomes the apply input after human selection. Do not discard it after the pipeline completes — it is the audit record of every figurative decision made in the chapter.
