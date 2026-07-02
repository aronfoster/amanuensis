---
step_id: metaphor_fix
review_required: true
inputs:
  - <chapter-folder>/drafts/<latest-attempt>/metaphors.md
  - <chapter-folder>/drafts/<latest-attempt>/<latest-draft>
  - <chapter-folder>/storyboards/*-storyboard.md
  - voice.md
outputs:
  - <chapter-folder>/drafts/<latest-attempt>/metaphors.md
preconditions:
  - path: <chapter-folder>/drafts/<latest-attempt>/metaphors.md
    kind: side_artifact
    required: true
    review_sensitive: true
  - path: <chapter-folder>/drafts/<latest-attempt>/<latest-draft>
    kind: prose_draft
    required: true
    review_sensitive: false
  - path: <chapter-folder>/storyboards/*-storyboard.md
    kind: source
    required: false
    review_sensitive: false
  - path: voice.md
    kind: source
    required: false
    review_sensitive: false
---

See `agents/orchestrator.md` for the step workflow contract.

# Metaphor Fix

## Purpose

Coordinator step that turns the human-annotated `metaphors.md` working file into a file populated with rewrite variants the human can choose from. Reads the file, identifies every entry annotated `FLATTEN`, `REPLACE: [target image]`, or `WORKSHOP`, and dispatches one subagent per annotated entry in parallel. Each subagent appends its variants directly below its assigned entry, in the format declared by its prompt contract. The coordinator does not generate prose, does not select among variants, and does not write to the draft. Human selection happens after this step exits; `metaphor_apply` then writes the chosen variant into prose.

## Inputs

- **`<chapter-folder>/drafts/<latest-attempt>/metaphors.md`** — the human-reviewed working file produced by `metaphor_identify` and annotated by the human. Each entry the human wants acted on carries an action word (`FLATTEN`, `REPLACE: [target image]`, or `WORKSHOP`) below the flag line and may carry inline corrections to identify fields. Entries the human accepted as-is have no action word; entries the human rejected have been deleted from the file.
- **`<chapter-folder>/drafts/<latest-attempt>/<latest-draft>`** — the latest prose, resolved at step start. The coordinator extracts the surrounding paragraph for each annotated entry's flagged sentence and passes only that paragraph to the subagent. Subagents do not receive the full draft. The paragraph the coordinator extracts must come from the same draft version stamped at the top of `metaphors.md` (the `Reviewed-draft:` line written by `metaphor_identify`); if `<latest-draft>` has advanced past that stamp the annotations are stale — see Open questions handling. This step does not mint a new draft version.
- **`<chapter-folder>/storyboards/*-storyboard.md`** — passed to `WORKSHOP` subagents only. The coordinator selects the storyboard block for the entry's beat and passes that single block to the workshop subagent. Not passed to flatten or replace subagents.
- **`voice.md`** — the project-root voice file (a sibling of `pipeline-state.md`, not the copy inside the `amanuensis/` submodule). A project may override the location by pointing at a different voice file in its top-level `AGENTS.md`; the coordinator passes whichever path is in effect. Passed to `WORKSHOP` subagents only. Not passed to flatten or replace subagents. If a `WORKSHOP` entry needs the voice file and none can be found, see Open questions handling.

## Behavior

### Coordinator responsibilities

1. **Read `metaphors.md`.** Walk the file entry by entry. Identify every entry annotated with an action word: `FLATTEN`, `REPLACE: [target image]`, or `WORKSHOP`. Skip entries with no action word — the human has accepted them as-is. Entries the human deleted are not present in the file and require no handling. The `Reviewed-draft: draft-vNN.md` header at the top of `metaphors.md` (written by `metaphor_identify`) is preserved as-is; this step does not rewrite or refresh it. Confirm that resolved `<latest-draft>` matches that stamp; if it does not, the annotations are stale (see Open questions handling).
2. **For each annotated entry, prepare the subagent payload.** The payload contains only what the subagent's prompt contract requires:
   - The full entry block as it currently appears in `metaphors.md` (including any inline corrections or notes the human added below the action word).
   - The surrounding paragraph for the flagged sentence, extracted from `<latest-draft>` (which must match the `Reviewed-draft:` stamp in `metaphors.md`). "Surrounding paragraph" means the paragraph containing the flagged quote, with no additional context.
   - For `WORKSHOP` entries only: the storyboard block for the entry's beat (one storyboard file's contents), plus the path/contents of the voice file.
   Subagents do not read `metaphors.md` as a whole, do not read the rest of the draft, and do not read each other's entries.
3. **Dispatch one subagent per annotated entry, in parallel where the host supports it.** Pick the subagent prompt contract by annotation type:
   - `FLATTEN` → `agents/metaphor/metaphor-flatten.md`
   - `REPLACE` (with or without an inline target image) → `agents/metaphor/metaphor-replace.md`
   - `WORKSHOP` → `agents/metaphor/metaphor-workshop.md`
4. **Each subagent writes its variants directly below its assigned entry in `metaphors.md`,** in the format declared by its prompt contract (`### Flatten Options`, `### Replace Options`, or `### Workshop Candidates`). The coordinator does not buffer or transform subagent output; subagents append in place.
5. **The coordinator does not select among variants.** It does not edit the variants, rank them, mark a preferred candidate, or write to the draft. After all subagents finish, the coordinator exits. Human selection happens between this step and `metaphor_apply`: the human deletes the variants they do not want, leaving exactly one variant per entry. `metaphor_apply` then writes the surviving variant into prose.

### Subagent isolation

Each subagent receives only the entry block, the surrounding paragraph, and (workshop only) the storyboard block plus the voice file. Do not pass the rest of `metaphors.md`, the rest of the draft, the scene list, canon, or other entries' state. The prompt contracts assume this scope; widening it changes their behavior.

### Annotation parsing

- `FLATTEN` may appear alone or with inline notes/corrections on subsequent lines.
- `REPLACE: [target image]` carries the target image inline. If the human wrote `REPLACE` without a target image, treat the entry as `WORKSHOP` and dispatch the workshop subagent — the human is asking for candidates, not integration of a chosen image.
- `WORKSHOP` may appear alone or with inline notes/corrections.
- Any inline corrections below the action word stay attached to the entry block when it is passed to the subagent. The subagent contracts are written to honor those corrections over the original identify fields.

### After dispatch

The coordinator waits for all subagents to finish appending their variants and then exits. The output file is `metaphors.md` itself, with the appended variants in place.

## Outputs

- **`<chapter-folder>/drafts/<latest-attempt>/metaphors.md`** — the same working file, with rewrite variants appended below every annotated entry. The `Reviewed-draft: draft-vNN.md` header written by `metaphor_identify` is preserved unchanged. Entries with no action word are unchanged. The file remains the audit record of every figurative decision in the chapter and becomes the input to `metaphor_apply` after the human selects one variant per entry.

## Open questions handling

If `metaphors.md` is missing, append a blocker to the project-root `open-questions.md` and exit without recording completion in `pipeline-state.md`. If `metaphors.md` exists but contains no annotated entries (every entry was either accepted as-is or deleted), append a blocker to `open-questions.md` noting that `metaphor_fix` was invoked with nothing to do — either the human intended to proceed directly to `metaphor_apply` (invoke that step instead) or annotation is incomplete — and exit without recording completion.

If the resolved `<latest-draft>` does not match the `Reviewed-draft:` stamp at the top of `metaphors.md`, the annotations are stale: a newer draft has been minted since `metaphor_identify` ran. Append a blocker to `open-questions.md` describing the mismatch (annotated draft vs. current `<latest-draft>`) and exit without dispatching subagents. The human either re-runs `metaphor_identify` against the new draft or rolls the draft back to the stamped version.

For other ambiguous or missing inputs (the draft is missing, a workshop entry's storyboard cannot be located, the project-root `voice.md` (or the override named in the project's `AGENTS.md`) is needed by a `WORKSHOP` entry but does not exist, etc.), append the blocker to `open-questions.md` and exit without recording completion in `pipeline-state.md`. Do not fabricate inputs and do not write partial variants. The next dispatcher invocation will re-run this step after the human resolves the blocker. On a successful run, the step's final action is to mark its own step line `[x]` in `pipeline-state.md` and update `last_updated`.
