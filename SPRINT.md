# Sprint 10 — Milestone 5: Prose fix apply step

This Sprint closes the prose-apply orphan. Today, `prose_pass` is the pipeline's only report step with no paired prose-advancing consumer: the human applies its recommendations by hand via the manual handoff procedure in `agents/chapters.md`, and the pipeline "no-op advances" if they choose not to. After this Sprint: `prose_pass` emits per-entry `FIX` / `FIX: <instruction>` / `SKIP` / `ESCALATE` annotations keyed to its existing KEEP/TIGHTEN/FLATTEN/REWRITE Actions; a new `agents/steps/prose-fix.md` reads the annotated report plus `<latest-draft>` plus `voice.md` and writes `<next-draft>`; `prose_fix` sits between `prose_pass` and `metaphor_identify` in the canonical step list; the manual handoff is retired; and `prose_pass → prose_fix` joins the report→fix adjacency invariant.

This is still a documentation/prose-contract milestone. The implementation edits are Markdown step bodies, support docs, templates, and examples; the only script that needs to keep passing is `scripts/check-pipeline-state.sh` against the updated canonical step list.

## Background — what is and isn't wrong today

Established by inspection during planning; tasks should not re-derive this.

- **`prose_pass` is the only report step in the pipeline with no paired prose-advancing consumer.** Its purpose statement says it produces a report only; a nearby paragraph then hands the human off to the manual copy-then-edit workflow in `agents/chapters.md` "until M5's `prose_fix` step lands" (`agents/steps/prose-pass.md:32`, `:64`, `:315`). `agents/orchestrator.md:120` names the same gap: the `Reviewed-draft:` stamp `prose_pass` records is there for consistency with the report→fix invariant but is not load-bearing until M5 adds `prose_fix` as the consumer.
- **`prose_pass` already emits per-finding severity labels.** Each finding block is `Quote / Problem / Why it matters / Action`, with `Action: KEEP | TIGHTEN | FLATTEN | REWRITE` (`agents/steps/prose-pass.md:249-260`). The pass is deliberately selective — it caps at 5-10 top-priority findings per chapter and explicitly refuses to line-edit everything (`:30`, `:32`, `:249`, `:298`, `:308-309`). This is what justifies the surgical (not chunked) apply model and the omission of bulk headers.
- **A `Reviewed-draft:` stamp already lives at the top of `prose-pass.md`.** The step overwrites the file with a fresh stamp when regenerated against a newer draft, so `prose_fix` can detect stale annotations exactly the way `compliance_fix` / `anti_ai_fix` / `metaphor_apply` already do (`agents/steps/prose-pass.md:48`). No new stamp mechanism is needed.
- **The three existing paired apply steps are the design template.** `compliance_fix` (`agents/steps/compliance-fix.md`), `anti_ai_fix` (`agents/steps/anti-ai-fix.md`), and `metaphor_apply` (`agents/steps/metaphor-apply.md`) all: read a `Reviewed-draft:`-stamped side artifact plus `<latest-draft>`; check the stamp against `<latest-draft>` at step start and exit as a stale-report blocker on mismatch; walk entries and apply per-entry annotations surgically; append `Applied:` / `Escalated:` blocks to the side artifact; write `<next-draft>`; append a per-version entry to `draft-manifest.md`; declare `review_required: false`; forbid rewriting beyond the annotated span. `prose_fix` must mirror this shape.
- **Bare-`FIX` generative behavior has precedent.** `compliance_fix` on a bare `FIX` applies "the obvious local edit implied by the violation type" (`agents/steps/compliance-fix.md:44`). `anti_ai_fix` defines category-specific bare-`FIX` rules and defers to `ESCALATE` where no clean local rule exists (`agents/steps/anti-ai-fix.md:66-82`). `prose_fix`'s severity-keyed bare-`FIX` rules follow this pattern: TIGHTEN and FLATTEN have obvious local moves; REWRITE is generative (the fixer produces a new sentence/paragraph in-voice) because the report diagnoses the failure but does not supply the replacement text.
- **`voice.md` is already loaded as a system-message calibration anchor by `line_pass`.** The line pass sends `voice.md` in full as the system message (`agents/steps/line-pass.md:27`, `:102`, `:105`); the same pattern gives `prose_fix` the voice it needs to generate REWRITE replacements without drifting. `prose_pass` also reads `voice.md` (`agents/steps/prose-pass.md:40`), so the voice file is a familiar input at this stage of the pipeline.
- **The other apply steps deliberately do not read storyboards / canon / voice.** `metaphor_apply` (`agents/steps/metaphor-apply.md:28`) forbids reading storyboard, canon, and voice because the variants were generated and chosen under those constraints upstream. `anti_ai_fix` (`agents/steps/anti-ai-fix.md:30`) refuses everything but its own report and the draft. `compliance_fix` reads storyboards only to confirm what a violation "should have enacted" (`agents/steps/compliance-fix.md:33`). `prose_fix` follows the `metaphor_apply` posture: read only what it needs to substitute — annotated report, current draft, voice.md for REWRITE generation — and trust `prose_pass`'s upstream judgment.
- **The canonical step list lives in two files that must stay in sync.** `templates/pipeline-state.md:16-28` is the default sequence for consuming projects; `examples/smoke/pipeline-state.md:14-26` mirrors it as the smoke fixture. Both list `prose_pass` followed by `metaphor_identify`; `prose_fix` must be inserted between them in both files. `scripts/check-pipeline-state.sh` (`scripts/check-pipeline-state.sh:106-135`) verifies every step_id in the list resolves to an `agents/steps/<step-id-with-dashes>.md` file — so the new step file and the list edits must land together to keep the check green.
- **The manual prose-edit handoff has three touch points.** `agents/chapters.md:61-70` documents the copy-then-edit procedure and a `produced_by: human_prose_edit` manifest marker; `agents/steps/prose-pass.md:32`, `:64`, `:315` reference it; `AGENTS.md:56` describes the step in terms of it. All three retire when `prose_fix` lands; the `human_prose_edit` marker becomes historical and is not documented for use going forward.
- **The report→fix adjacency invariant already anticipates `prose_pass → prose_fix`.** `agents/orchestrator.md:108-122` names it as the currently-unpaired case and says the invariant "will become load-bearing" when M5 lands. Sprint 10 makes it load-bearing: `prose_pass → prose_fix` joins the invariant's list of pairs; the note about the currently-unpaired case is retired.
- **`draft-manifest.md`'s schema does not need to change.** The per-version entry format at `agents/project-layouts.md:21-33` — `produced_by`, `read_from`, side artifacts, apply-log pointer — already covers what `prose_fix` writes.

## Definition of done

The Sprint is complete when:

1. ROADMAP.md tasks M5.1-M5.4 are checked.
2. `agents/steps/prose-pass.md` documents a per-entry annotation grammar keyed to its existing `Action: KEEP | TIGHTEN | FLATTEN | REWRITE` label: an `Annotation:` line taking `FIX` / `FIX: <instruction>` / `SKIP` / `ESCALATE`. `KEEP` findings need no annotation and are treated as `SKIP` by `prose_fix`. No bulk-annotation headers are added.
3. `agents/steps/prose-fix.md` exists with frontmatter declaring `step_id: prose_fix`, `review_required: false`, inputs `<chapter-folder>/drafts/<latest-attempt>/prose-pass.md` + `<chapter-folder>/drafts/<latest-attempt>/<latest-draft>` + `voice.md`, and outputs `<chapter-folder>/drafts/<latest-attempt>/<next-draft>` + `<chapter-folder>/drafts/<latest-attempt>/prose-pass.md` + `<chapter-folder>/drafts/<latest-attempt>/draft-manifest.md`. Its body defines the surgical per-entry apply model, the severity fix rules (including REWRITE's generative bare-`FIX` behavior under `voice.md`), the stale-report blocker check, and the `Applied:` / `Escalated:` log format that appends to `prose-pass.md`.
4. `prose_fix` is inserted after `prose_pass` (and before `metaphor_identify`) in both `templates/pipeline-state.md` and `examples/smoke/pipeline-state.md`, and `scripts/check-pipeline-state.sh` passes against both.
5. `agents/orchestrator.md` lists `prose_pass → prose_fix` in the report→fix adjacency invariant's pairs, and the paragraph noting the currently-unpaired case is retired.
6. The manual prose-edit handoff is retired: the section in `agents/chapters.md:61-70` is deleted, the "until M5" language in `agents/steps/prose-pass.md` (`:32`, `:64`, `:315`) is replaced by references to `prose_fix` as the automatic consumer, and `AGENTS.md`'s prose-pass catalog entry is rewritten. `AGENTS.md` also gains a new catalog entry for `agents/steps/prose-fix.md` between the prose-pass and metaphor-identify entries.
7. Verification greps confirm the retirement:
   - `git grep -n "until M5\|human_prose_edit\|Manual prose-edit handoff" -- '*.md'` returns no surviving live references (any remaining hit is an intentional historical note and is annotated as such).
   - `git grep -nE "prose_fix|prose-fix\.md" -- '*.md'` shows the new step referenced from the catalog, the canonical step list, the invariant, and `prose-pass.md`.
8. `metaphor_identify` behavior is unchanged: it continues to resolve `<latest-draft>` at step start and now happens to see the `prose_fix`-produced draft version. No edits to `metaphor_identify` or downstream steps are required by this Sprint; verification confirms none were made.
9. The canonical step *order* is unchanged apart from the `prose_fix` insertion between `prose_pass` and `metaphor_identify`; nothing else is renamed or reordered.

## Conventions adopted by this Sprint

Locked at the start so individual tasks don't rediscover them.

- **Surgical per-entry apply model.** For each annotated entry: locate the quoted anchor in `<latest-draft>`, apply the smallest local edit that resolves the finding, copy everything else through verbatim. Chosen over chunked-like-`line_pass` because `prose_pass` is deliberately selective at 5-10 findings per chapter; a whole-chapter chunk pass would reprocess mostly untouched prose and give the LLM license to drift into a general polish. Matches the precedent of `compliance_fix`, `anti_ai_fix`, and `metaphor_apply`.
- **Bare `FIX` on `REWRITE` is generative under `voice.md`.** The report diagnoses the failure but does not supply the replacement, so the fixer produces a new sentence or paragraph in-voice. `voice.md` is loaded in full as the system message (mirroring `line_pass`'s calibration pattern); the target paragraph plus one paragraph either side is passed as read-only context so the replacement lands in the local rhythm. The human can still steer with `FIX: <instruction>`; `ESCALATE` remains available when even a directed rewrite is too big for the fixer.
- **Bare `FIX` on `TIGHTEN` / `FLATTEN` is local.** `TIGHTEN` sharpens the flagged sentence in place (compressing clauses, cutting hedges, cleaning emphasis) without expanding scope. `FLATTEN` reduces decoration in place (drop the ornamental clause, replace the fancy image with the literal one). Neither is licensed to touch neighboring sentences beyond the minimum grammar or pronoun repair the edit forces.
- **`KEEP` needs no annotation.** `KEEP` findings — recorded by `prose_pass` to mark imagery worth preserving under the figurative-language rubric — are treated as `SKIP` by `prose_fix` and are not logged. Requiring a redundant `SKIP` annotation on top of `KEEP` would be annotation-grammar noise.
- **No bulk-annotation headers.** `prose_pass`'s selective 5-10-finding output does not justify `anti_ai_fix`'s per-category bulk grammar. Every annotation is per-entry. If future practice shows `prose_pass` reports growing past that cap, bulk grammar can be added later without breaking anything.
- **`prose_fix` reads only its report, its draft, and `voice.md`.** Storyboards and canon are deliberately *not* read (matches `metaphor_apply` and `anti_ai_fix`). `prose_pass` already reviewed against the storyboard and voice; `prose_fix` applies the reviewed judgments without re-evaluating them. If a finding requires storyboard or canon input to fix, the human annotates `ESCALATE` rather than passing that context to the fixer.
- **Apply log lives in `prose-pass.md`, not the draft.** Per-entry `Applied:` and `Escalated:` blocks are appended to `prose-pass.md`, mirroring `compliance_fix`'s log location. The produced prose stays clean (no tally block-comment at the end of the draft file). This differs from `line_pass` and `metaphor_apply` because `prose_pass` findings are individually labeled and enumerable, so a per-entry log is the more auditable record.
- **`review_required: false`.** Human review happens once, at the `prose_pass` annotation stage. Once annotated, `prose_fix` mechanically applies the human's judgments and does not re-gate review on its own output — same as `compliance_fix`, `anti_ai_fix`, and `metaphor_apply`.
- **Stale-report blocker follows the standard pattern.** `prose_fix` reads the `Reviewed-draft:` stamp from `prose-pass.md` at step start; on mismatch with `<latest-draft>` it appends a blocker to project-root `open-questions.md` and exits without advancing the marker. Recovery is the human's decision (rerun `prose_pass` against the current draft, or roll back), exactly as with the three existing pairs. `prose_pass` already overwrites its file with a fresh stamp on regeneration, so no change to `prose_pass` is needed for this path.
- **Manual prose-edit handoff retires with this Sprint.** With `prose_fix` in the pipeline the human no longer needs the copy-then-edit workflow to keep the versioned-draft model honest. The `human_prose_edit` `produced_by` value becomes historical (any manifest entries left over from pre-M5 attempts remain valid; new entries are written by `prose_fix`) and is not documented as a going-forward option.

---

## Tasks

### Task 1 — Add per-entry annotation grammar to `prose_pass` [x]

**Goal.** Give the human a machine-readable way to mark each `prose_pass` finding as `FIX` / `FIX: <instruction>` / `SKIP` / `ESCALATE`, so that `prose_fix` has an unambiguous input. Closes **M5.1**.

**Requirements.**

- In `agents/steps/prose-pass.md`, extend the per-finding template (currently `Quote / Problem / Why it matters / Action`) with an `Annotation:` line the human fills in before dispatching `prose_fix`:
  - Add `Annotation: [FIX | FIX: <instruction> | SKIP | ESCALATE]` beneath the `Action:` line.
  - State that `KEEP` findings need no annotation and are treated as `SKIP` by `prose_fix`; the `Annotation:` line may be omitted for `KEEP` entries.
  - State that a finding with an unrecognized or missing `Annotation:` (and `Action:` other than `KEEP`) is not actionable — `prose_fix` treats it as an unannotated blocker.
- Do **not** add bulk-annotation headers. This is an explicit locked convention; note it in-line so a future reader does not re-litigate.
- Update the Purpose and Output-format sections that reference the manual handoff so they describe `prose_fix` as the automatic consumer (see Task 4 for the retirement wording).
- Preserve the existing `Reviewed-draft: draft-vNN.md` header behavior — no change to the stamp mechanism itself.
- Cross-reference `agents/orchestrator.md`'s report→fix adjacency invariant so the human understands why the `Reviewed-draft` stamp is now load-bearing.

**Done when.** A `prose_pass` report can carry per-entry annotations exactly the way `compliance_report` and `anti_ai_report` reports do; `KEEP` remains a no-annotation-needed short-circuit; the annotation grammar is documented in one place inside `agents/steps/prose-pass.md` so `prose_fix` can point at it rather than restate it.

---

### Task 2 — Write `agents/steps/prose-fix.md` [x]

**Goal.** Ship the new step file. Closes the core of **M5.2** and **M5.3**.

**Requirements.**

- Create `agents/steps/prose-fix.md` with frontmatter:
  ```yaml
  ---
  step_id: prose_fix
  review_required: false
  inputs:
    - <chapter-folder>/drafts/<latest-attempt>/prose-pass.md
    - <chapter-folder>/drafts/<latest-attempt>/<latest-draft>
    - voice.md
  outputs:
    - <chapter-folder>/drafts/<latest-attempt>/<next-draft>
    - <chapter-folder>/drafts/<latest-attempt>/prose-pass.md
    - <chapter-folder>/drafts/<latest-attempt>/draft-manifest.md
  ---
  ```
- Include a `See agents/orchestrator.md for the step workflow contract.` reference line at the top of the body, mirroring the other step files.
- **Purpose.** State that `prose_fix` applies the human-annotated recommendations recorded in `prose-pass.md` to `<latest-draft>`, producing `<next-draft>`. It is surgical: it changes only what is annotated, preserves everything else, and records what it did (and what it could not do) by appending to `prose-pass.md`. Runs after `prose_pass` and after the human has annotated the report.
- **Inputs.** Explain each input, including the stale-report blocker check on the `Reviewed-draft:` header at the top of `prose-pass.md` (identical framing to `compliance_fix` and `anti_ai_fix`, and pointing at the same invariant). Explicitly note that storyboards and canon are *not* inputs — `prose_pass` already reviewed against them.
- **Behavior — resolving the effective annotation.** For each finding, use the per-entry `Annotation:` if present; if the `Action:` is `KEEP` and no `Annotation:` is present, treat as `SKIP`. Any other case with no `Annotation:` is an unannotated finding — handle via Open questions handling (do not guess). This mirrors `anti_ai_fix`'s effective-annotation resolution minus the bulk fallback.
- **Behavior — severity fix rules (bare `FIX`).** Document the default action for a bare `FIX` at each severity:
  - `TIGHTEN` — apply the smallest local edit that sharpens the flagged sentence (compress clauses, cut hedges, clean emphasis) within the sentence itself. No collateral edits beyond punctuation repair the change forces.
  - `FLATTEN` — apply the smallest local edit that reduces decoration in place (drop the ornamental clause, replace the fancy image with the literal one) within the sentence itself. Same collateral discipline.
  - `REWRITE` — generative: produce a new sentence or paragraph in-voice that resolves the diagnosed failure. Load `voice.md` in full as the system message; pass the target paragraph plus one paragraph either side as read-only context (labeled `<<<PRECEDING CONTEXT — READ ONLY>>>` / `<<<TARGET — REWRITE THIS>>>` / `<<<FOLLOWING CONTEXT — READ ONLY>>>`, mirroring `line_pass`'s prompt shape); instruct the LLM to return only the rewritten target. Substitute the rewritten target for the original paragraph in `<next-draft>`; make the smallest collateral adjustments to neighboring sentences that the rewrite forces (pronoun continuity, a conjunction that no longer scans).
- **Behavior — `FIX: <instruction>` / `SKIP` / `ESCALATE`.**
  - `FIX: <instruction>` overrides the severity default; follow the instruction exactly, within the same scope as the severity rule (sentence-local for `TIGHTEN` / `FLATTEN`, paragraph-local for `REWRITE`).
  - `SKIP` — leave the prose as-is; do not append an `Applied:` or `Escalated:` block.
  - `ESCALATE` — do not modify the prose; append an `Escalated:` block noting reason and suggested upstream target (matching `compliance_fix` / `anti_ai_fix`).
- **Behavior — apply log.** After each `FIX` action, append an `Applied:` block to `prose-pass.md` with the entry label, one-line change summary, prose before, and prose after (mirror `compliance_fix`'s format). After each `ESCALATE`, append an `Escalated:` block with reason and suggested upstream target.
- **Constraints.**
  - Fix only what is annotated. Do not improve, tighten, or rewrite prose beyond the flagged span.
  - `TIGHTEN` and `FLATTEN` are sentence-local; `REWRITE` is paragraph-local. No cross-paragraph reshaping.
  - If a fix to one finding would introduce a new finding (e.g., a `REWRITE` that produces broken imagery), stop and append an `Escalated:` block rather than proceeding.
  - Preserve block-comment markers (`<!-- scene x, beat y -->`), scene breaks (`---`), and dialogue formatting exactly as they appear in `<latest-draft>`.
  - Preserve any prior apply-log block-comment at the end of `<latest-draft>` (e.g. from `line_pass` in a later-stage rerun) verbatim; `prose_fix` does not append a tally block-comment to the prose file. Its per-entry log lives in `prose-pass.md`.
  - `<next-draft>` must contain the full chapter prose with `FIX` edits applied — not a diff, not just the changed sections.
- **Outputs.** Three outputs, following the `compliance_fix` template:
  - `<chapter-folder>/drafts/<latest-attempt>/<next-draft>` — the full revised prose (e.g., if `<latest-draft>` is `draft-v03.md`, this writes `draft-v04.md`). `<latest-draft>` is not modified.
  - `<chapter-folder>/drafts/<latest-attempt>/prose-pass.md` — same input file, with `Applied:` / `Escalated:` blocks appended. Pre-existing content (report, `Reviewed-draft:` stamp, human annotations) is not modified.
  - `<chapter-folder>/drafts/<latest-attempt>/draft-manifest.md` — append a per-version entry for `<next-draft>` following the schema in `agents/project-layouts.md:21-33`. Example: `produced_by: prose_fix`, `read_from: [draft-v03.md]`, `side_artifacts: [prose-pass.md]`, `apply_log: apply log appended to prose-pass.md`.
- **Open questions handling.** Named blocker conditions (following `compliance_fix`'s framing):
  - **Unannotated report.** `prose-pass.md` contains findings with non-`KEEP` `Action:` values and no `Annotation:` line.
  - **Missing inputs.** `prose-pass.md` is missing, `<latest-draft>` cannot be resolved (no `draft-vNN.md` in the attempt directory), or `voice.md` cannot be found (project-root `voice.md` or the override named in the project's `AGENTS.md`).
  - **Stale report.** The `Reviewed-draft:` header at the top of `prose-pass.md` names a draft other than `<latest-draft>`. Cross-reference `agents/orchestrator.md`'s report→fix adjacency invariant for the canonical statement.
  - In any of these, append the blocker to project-root `open-questions.md` and exit without advancing the marker. Do not fabricate annotations and do not write a partial `<next-draft>`.
- **Anti-patterns.** Include at least: fixing unannotated findings; rewriting beyond the flagged span; cross-paragraph reshaping on `TIGHTEN` / `FLATTEN`; using `voice.md` as a style ceiling that licenses rewrites of unflagged prose; introducing new figurative language on non-`REWRITE` fixes; touching the prior apply-log block-comment; silently dropping an annotated finding without an `Applied:` or `Escalated:` block.

**Done when.** A single `agents/steps/prose-fix.md` file implements the surgical per-entry apply model, defines the severity fix rules including generative REWRITE, honors the stale-report invariant, logs into `prose-pass.md`, and mirrors the other apply steps' shape closely enough that a downstream reader learns nothing surprising.

---

### Task 3 — Insert `prose_fix` into the canonical step list [x]

**Goal.** Land the new step in the pipeline order and keep the pipeline-state check green. Closes **M5.4**.

**Requirements.**

- Update `templates/pipeline-state.md`: insert `- [ ] prose_fix` between `prose_pass` and `metaphor_identify`. Do not reorder any other step.
- Update `examples/smoke/pipeline-state.md`: same insertion.
- Run `scripts/check-pipeline-state.sh` against `templates/pipeline-state.md` (default resolvable mode) and `agents/steps/`; confirm it exits clean. Then run it in `--exhaustive` mode; confirm the new file is now included in the step file set with no missing-from-list errors.
- Do not change the `agents/orchestrator.md` step-list example (it points at `templates/pipeline-state.md` as the canonical source; the list itself lives there).

**Done when.** Both `templates/pipeline-state.md` and `examples/smoke/pipeline-state.md` include `prose_fix` between `prose_pass` and `metaphor_identify`; the pipeline-state check passes in both modes.

---

### Task 4 — Retire the manual prose-edit handoff and update the invariant [x]

**Goal.** Remove the pre-M5 workaround wording from the docs now that the pipeline has an automatic consumer, and add `prose_pass → prose_fix` to the report→fix adjacency invariant. This closes the doc-sweep half of **M5.3**.

**Requirements.**

- **`agents/chapters.md`.** Delete the `#### Manual prose-edit handoff` subsection (`agents/chapters.md:61-70` at time of planning) in full. Confirm the surrounding `### Versioned drafts (draft-vNN.md)` narrative still reads correctly after deletion; if needed, add one short sentence naming `prose_fix` as the prose-advancing consumer for `prose_pass`, matching the tone of the existing catalog of prose-advancing steps.
- **`agents/steps/prose-pass.md`.** Rewrite the "advisory / until M5" language in the Purpose paragraph (`prose-pass.md:32`), the Output paragraph's "Do not modify the prose file" (`:64`), and the Outputs summary (`:315`) so that `prose_fix` is named as the automatic consumer. Keep the pass itself report-only; the change is only in the framing around what happens *after* the pass. Also remove references to the manual copy-then-edit procedure and the `human_prose_edit` marker.
- **`agents/orchestrator.md`.** In the "Report→fix adjacency invariant" section:
  - Add `prose_pass → prose_fix`, stamped in `prose-pass.md`, to the list of pairs governed by the invariant.
  - Rewrite the paragraph that currently says `prose_pass` "has no paired prose-advancing consumer in this Sprint; M5 will add `prose_fix` as that consumer and the stamp will become load-bearing then" (`agents/orchestrator.md:120`) so that it reflects the current state: `prose_pass`'s stamp is now load-bearing and `prose_fix` is the consumer. Leave the `line_pass` clause of that paragraph unchanged.
- **`AGENTS.md` catalog.**
  - Rewrite the `agents/steps/prose-pass.md` entry (`AGENTS.md:56`) so it no longer mentions the manual handoff. It should describe `prose_pass` as the advisory prose-quality report whose annotated output is consumed by `prose_fix`.
  - Add a new catalog entry for `agents/steps/prose-fix.md` between the `prose-pass` entry and the `metaphor-identify` entry. Mirror the shape of the `compliance-fix` catalog entry (`AGENTS.md:55`): describe it as applying the human-annotated fixes from `prose-pass.md` to `<latest-draft>`, producing the next `draft-vNN.md`, and appending an entry to the attempt's `draft-manifest.md`.
- Do not touch the `Reviewed-draft:` stamp implementation in any of these files — it already exists.

**Done when.** No live doc still teaches the manual handoff; `agents/orchestrator.md` lists `prose_pass → prose_fix` alongside the other pairs; `AGENTS.md` catalog reflects the two-step prose-pass/prose-fix contract; the surrounding narratives read cleanly with those changes.

---

### Task 5 — Verification sweep, ROADMAP / SPRINT check-off [x]

**Goal.** Close the Sprint with a documented verification and mark the milestone complete. Closes the residual of **M5** and this Sprint.

**Requirements.**

- Run the following verification greps and review each hit:
  - `git grep -n "until M5\|human_prose_edit\|Manual prose-edit handoff\|manual prose-edit handoff\|manual prose changes" -- '*.md'` — must return no surviving live references. Any hit that remains must be an explicit historical note (e.g., a ROADMAP note) and marked as such; live doc references should be zero.
  - `git grep -nE "prose_fix|prose-fix\.md" -- '*.md'` — must include hits in `agents/steps/prose-fix.md`, `templates/pipeline-state.md`, `examples/smoke/pipeline-state.md`, `agents/orchestrator.md`, `agents/steps/prose-pass.md`, `AGENTS.md`, and `ROADMAP.md`.
  - `git grep -nE "draft.md|draft-compliance.md|draft-metaphor.md|draft-line.md|draft-anti-ai.md" -- '*.md'` — must produce no new legacy-name hits attributable to this Sprint (a regression guard on M4's convention).
  - `git grep -nE "prose_pass\s*→\s*prose_fix|prose_pass -> prose_fix" -- '*.md'` — must show the pair in `agents/orchestrator.md`.
- Confirm `agents/steps/prose-fix.md` reads cleanly against the shape of `agents/steps/compliance-fix.md`: frontmatter, `See agents/orchestrator.md` reference line, Purpose, Inputs, Behavior, Constraints, Outputs, Open questions handling, Anti-patterns sections all present.
- Confirm `metaphor_identify` and all downstream steps are unedited (`git diff --stat` for `agents/steps/` should show only `prose-pass.md` and the new `prose-fix.md`).
- Run `scripts/check-pipeline-state.sh` in both modes against `templates/pipeline-state.md` and `agents/steps/`; capture the exit status.
- Update `ROADMAP.md` M5.1-M5.4 to `[x]` only after Tasks 1-4 pass verification. Update the M5 notes section if any decision changed from what this SPRINT.md locks (it should not).
- Mark this SPRINT.md's Tasks 1-5 `[x]` only after their acceptance conditions hold.

**Done when.** The verification greps return the expected patterns, `check-pipeline-state.sh` passes, ROADMAP M5 checkboxes are ticked, and SPRINT.md task checkboxes reflect completed work.

---

## Out of scope for this Sprint

- **Chunked or hybrid apply models for `prose_fix`.** Sprint 10 locks the surgical per-entry model. If future practice shows `prose_pass` reports growing well past the 5-10-finding cap or REWRITE-heavy reports drifting under the generative bare-`FIX` rule, a follow-up milestone can revisit.
- **Bulk-annotation headers.** Same reasoning; not added in Sprint 10.
- **Any change to `prose_pass`'s severity taxonomy or diagnosis rubric.** The `KEEP` / `TIGHTEN` / `FLATTEN` / `REWRITE` labels stay identical, and the pass remains selective. Sprint 10 only adds the annotation slot.
- **Any change to `metaphor_identify` or downstream steps.** They already read `<latest-draft>` (per M4). Sprint 10 relies on that resolution being unchanged; verification confirms no downstream edits were made.
- **Storyboard reveal-coverage review (M6) and directional dispatcher (M7).** Independent milestones; Sprint 10 does not touch either.
- **Reordering the canonical step list beyond inserting `prose_fix`.** No other step is renamed, reordered, or split.
- **Backfilling the historical `human_prose_edit` marker.** Existing manifest entries in real projects using that marker remain valid; the marker just isn't documented as a going-forward option.
