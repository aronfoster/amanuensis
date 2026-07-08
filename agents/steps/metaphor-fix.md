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

Coordinator step that turns the human-annotated `metaphors.md` working file into a file populated with rewrite variants the human can choose from. Reads the file, runs the shared validator over it (`--round decision`), and walks every entry by its `- Decision:` token; for each entry whose decision is actionable (the `selection_tokens` declared in the `metaphor:` block of `agents/review-grammars.yaml` — `FLATTEN`, `REPLACE: <image>`, or `WORKSHOP`) it inserts a blank selection-field pair and dispatches one subagent in parallel. Each subagent appends its variant section directly below its assigned entry, in the format declared by its prompt contract. The coordinator does not generate prose, does not select among variants, and does not write to the draft. `KEEP` / `REJECT` entries are terminal and stay untouched. Human selection happens after this step exits; `metaphor_apply` then writes the chosen variant into prose.

## Inputs

- **`<chapter-folder>/drafts/<latest-attempt>/metaphors.md`** — the human-reviewed working file produced by `metaphor_identify` and annotated by the human. Each figure is a review unit carrying a `- Decision:` field; the legal token set, payload rules, and blank-means semantics are defined by the `metaphor:` family block in `agents/review-grammars.yaml` (the single grammar source; this step doc does not restate them). The coordinator acts only on entries whose `Decision:` is actionable (`FLATTEN`, `REPLACE: <image>`, or `WORKSHOP` — the family's `selection_tokens`); `KEEP` / `REJECT` entries are terminal and stay in the file untouched. Deletion is no longer a decision signal — a rejected figure carries `Decision: REJECT` and remains as the audit record. Inline round-one corrections to identify fields are carried in the entry's `- Decision-note:`, and the subagent contracts honor those corrections over the original identify fields.
- **`<chapter-folder>/drafts/<latest-attempt>/<latest-draft>`** — the latest prose, resolved at step start via the manifest's active head — or via the read-from override the dispatcher passed — per `agents/project-layouts.md`, not by highest-numbered draft. The step reads the draft only for subagent context: the coordinator extracts the surrounding paragraph for each actionable entry's flagged sentence and passes only that paragraph to the subagent. Subagents do not receive the full draft. The paragraph the coordinator extracts must come from the same draft version stamped at the top of `metaphors.md` (the `Reviewed-draft:` line written by `metaphor_identify`); freshness here is an instance of the general freshness contract in `agents/orchestrator.md`'s **Artifact state** section — `metaphors.md` is `fresh` iff its stamp equals the current `<latest-draft>` and `stale` otherwise, computed at step start and never stored — so if `<latest-draft>` has advanced past that stamp the annotations are `stale` (see Open questions handling). This step does not mint a new draft version.
- **`<chapter-folder>/storyboards/*-storyboard.md`** — passed to `WORKSHOP` subagents only. The coordinator selects the storyboard block for the entry's beat and passes that single block to the workshop subagent. Not passed to flatten or replace subagents.
- **`voice.md`** — the project-root voice file (a sibling of `pipeline-state.md`, not the copy inside the `amanuensis/` submodule). A project may override the location by pointing at a different voice file in its top-level `AGENTS.md`; the coordinator passes whichever path is in effect. Passed to `WORKSHOP` subagents only. Not passed to flatten or replace subagents. If a `WORKSHOP` entry needs the voice file and none can be found, see Open questions handling.

## Behavior

### Coordinator responsibilities

1. **Read `metaphors.md` and check freshness.** Walk the file entry by entry. The `Reviewed-draft: draft-vNN.md` header at the top of `metaphors.md` (written by `metaphor_identify`) is preserved as-is; this step does not rewrite or refresh it (`metaphor_fix` mints no draft and preserves the stamp it inherits). Confirm that resolved `<latest-draft>` matches that stamp — the consumption-time check of the general freshness contract (`agents/orchestrator.md`'s **Artifact state** section); if it does not, the annotations are `stale` (see Open questions handling).
2. **Run the shared validator over `metaphors.md` with `--round decision`.** After the freshness check, and before dispatching any subagent, run:

   ```sh
   sh amanuensis/scripts/validate-review-artifact.sh --round decision <chapter-folder>/drafts/<latest-attempt>/metaphors.md amanuensis/agents/review-grammars.yaml <chapter-folder>/drafts/<latest-attempt>/draft-manifest.md
   ```

   (paths as seen from a consuming project, per `agents/review-validation.md`). Pass the attempt's `draft-manifest.md` when it exists so the script's state layer runs; if none exists yet, omit it — freshness is already established at step start. When the dispatcher passed a read-from draft, additionally pass that draft filename as the validator's fourth argument (the effective draft): the state layer then compares the stamp against the read-from draft rather than the manifest's `Active-head:`. Interpret the ledger and exit code per `agents/review-validation.md`: proceed only on exit 0 — the grammar's `--round decision` proceed state, zero decision-pending units and zero invalid units. Exit 4 (pending-remain) blocks as `review_pending`, copying the validator's `pending-review-ids:` list into the blocker (the deterministic set of remaining units — do not re-enumerate blank `Decision:` fields by eye); exit 3 (invalid-present) blocks as invalid input, naming the validator's findings; exit 5 (stale) blocks as `stale` — `metaphor_fix` mints no draft and carries no override branch. See Open questions handling for the blockers.
3. **Walk entries by `Decision:` token.** Act only on entries whose `Decision:` is `FLATTEN`, `REPLACE: <image>`, or `WORKSHOP` (the family's `selection_tokens`). `KEEP` / `REJECT` entries are terminal — leave them untouched in the file. Presence or deletion is no longer a decision signal; the token in the `Decision:` field is. (The validator has already run — see step 2 — so every entry holds a filled legal decision and the coordinator never encounters a blank or invalid one.)
4. **For each actionable entry, insert the blank selection fields and prepare the subagent payload.** Insert a blank `- Selected:` and `- Selection-note:` among the entry's fields — after `Decision-note:`, before the `#### ` variant heading the subagent will append — so both sit inside the anchored unit. The payload passed to the subagent contains only what its prompt contract requires:
   - The full entry block as it currently appears in `metaphors.md` (including any inline round-one corrections the human recorded in `- Decision-note:`).
   - The surrounding paragraph for the flagged sentence, extracted from `<latest-draft>` (which must match the `Reviewed-draft:` stamp in `metaphors.md`). "Surrounding paragraph" means the paragraph containing the flagged quote, with no additional context.
   - For `WORKSHOP` entries only: the storyboard block for the entry's beat (one storyboard file's contents), plus the path/contents of the voice file.
   Subagents do not read `metaphors.md` as a whole, do not read the rest of the draft, and do not read each other's entries.
5. **Dispatch one subagent per actionable entry, in parallel where the host supports it.** Pick the subagent prompt contract by decision token:
   - `FLATTEN` → `agents/metaphor/metaphor-flatten.md`
   - `REPLACE` → `agents/metaphor/metaphor-replace.md`
   - `WORKSHOP` → `agents/metaphor/metaphor-workshop.md`
6. **Each subagent appends its variant section directly below its assigned entry in `metaphors.md`,** as a `#### ` heading with stable per-variant ids, in the format declared by its prompt contract (`#### Flatten Options`, `#### Replace Options`, or `#### Workshop Candidates`). The `#### ` section sits a level below the figure's `### ` item line, inside the anchored unit. The coordinator does not buffer or transform subagent output; subagents append in place.
7. **The coordinator does not select among variants.** It does not edit the variants, rank them, mark a preferred candidate, or write to the draft. After all subagents finish, the coordinator exits. Human selection happens between this step and `metaphor_apply`: the human records the chosen variant id in the entry's `- Selected:` field (with any inline edit in `- Selection-note:`); the unchosen variants stay in the file as the audit record. `metaphor_apply` then writes the selected variant into prose.

### Subagent isolation

Each subagent receives only the entry block, the surrounding paragraph, and (workshop only) the storyboard block plus the voice file. Do not pass the rest of `metaphors.md`, the rest of the draft, the scene list, canon, or other entries' state. The prompt contracts assume this scope; widening it changes their behavior.

### Annotation parsing

- The `Decision:` token drives dispatch; the coordinator reads the token, not the presence or deletion of the entry. `FLATTEN` and `WORKSHOP` carry no payload; `REPLACE: <image>` carries the target image inline as its payload.
- A bare `REPLACE` (no target image) is **invalid** input, not a request for candidates: the validator rejects it (exit 3) and the step blocks (see Open questions handling). It is not normalized to `WORKSHOP` — `WORKSHOP` is the ask-for-candidates path, `REPLACE` the integrate-this-image path (per the `metaphor:` family's `replace_policy` in `agents/review-grammars.yaml`).
- Inline round-one corrections to the identify fields are read from the entry's `- Decision-note:`. They stay attached to the entry block when it is passed to the subagent; the subagent contracts are written to honor those corrections over the original identify fields.

### After dispatch

The coordinator waits for all subagents to finish appending their variants and then exits. The output file is `metaphors.md` itself, with the appended variants in place.

## Outputs

- **`<chapter-folder>/drafts/<latest-attempt>/metaphors.md`** — the same working file, with a blank `- Selected:` / `- Selection-note:` pair and a `#### ` variant section appended inside every actionable entry. The `Reviewed-draft: draft-vNN.md` header written by `metaphor_identify` is preserved unchanged. Terminal `KEEP` / `REJECT` entries are unchanged. The file remains the audit record of every figurative decision in the chapter and becomes the input to `metaphor_apply` after the human records a chosen variant id in each actionable entry's `Selected:` field.

## Open questions handling

An all-`KEEP`/`REJECT` `metaphors.md` — one with no actionable entries — is **not** a blocker: it is a clean no-op. The coordinator writes nothing, dispatches no subagent, and records completion in `pipeline-state.md` (the successful-run action below). The terminal file passes through to human selection and `metaphor_apply`; `metaphor_fix` has nothing to generate. Open-questions handling fires only when the input itself is unusable.

If `metaphors.md` is missing, append a blocker to the project-root `open-questions.md` and exit without recording completion in `pipeline-state.md`.

The validator (coordinator step 2, `--round decision`) names the remaining input blockers; interpret its exit code per `agents/review-validation.md`:

- **Pending units (`review_pending`, exit 4).** One or more entries carry a blank `Decision:` and so no review evidence. Copy the validator's `pending-review-ids:` list into the `open-questions.md` blocker — the deterministic remaining set, not an eyeball scan of the artifact — and exit without dispatching subagents. An override does not lift this; the human resolves it by filling the blank `Decision:` fields.
- **Invalid input (`invalid`, exit 3).** The validator reports invalid units or grammar defects (invalid takes precedence over pending): a bare `REPLACE` (the payload is required and is **not** normalized to `WORKSHOP`), an orphaned legacy `### ` figure carrying no anchor (a positional/pre-migration report), an illegal decision token, a missing required payload, a duplicate review-id, or a missing anchor or `Decision:` field. Block as invalid input, naming the validator's specific findings (line numbers and defects) in the blocker; an override does not lift it.
- **Stale report (`stale`, exit 5).** See the freshness paragraph below.

If the resolved `<latest-draft>` does not match the `Reviewed-draft:` stamp at the top of `metaphors.md`, the annotations are `stale` (the validator's exit 5): a newer draft has been minted since `metaphor_identify` ran. This is the same general freshness contract the fix/apply steps apply (`agents/orchestrator.md`'s **Artifact state** section; the report→fix freshness invariant is its named worked instance) — but `metaphor_fix` preserves its inherited stamp and mints no draft, so it carries no override branch of its own; the recorded-override path lives in `metaphor_apply`, the draft-minting consumer. Append a blocker to `open-questions.md` describing the mismatch (annotated draft vs. current `<latest-draft>`) and exit without dispatching subagents. The human either re-runs `metaphor_identify` against the new draft or rolls the draft back to the stamped version.

For other ambiguous or missing inputs (the draft is missing, a workshop entry's storyboard cannot be located, the project-root `voice.md` (or the override named in the project's `AGENTS.md`) is needed by a `WORKSHOP` entry but does not exist, etc.), append the blocker to `open-questions.md` and exit without recording completion in `pipeline-state.md`. Do not fabricate inputs and do not write partial variants. The next dispatcher invocation will re-run this step after the human resolves the blocker. On a successful run — including the clean no-op on an all-`KEEP`/`REJECT` file — the step's final action is to mark its own step line `[x]` in `pipeline-state.md` and update `last_updated`.
