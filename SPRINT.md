# Sprint 11 — Milestone 6: Storyboard reader-reveal coverage

This Sprint teaches storyboards to declare what the reader must *understand*, not only what must be *concealed*, and adds an advisory review pass that flags under-communication before drafting begins. Today `storyboard-schema.md` has a strong `concealment_from_reader` field (what the narrative must not name yet) but no positive counterpart — nothing states what the reader is supposed to grasp by a beat's end, so a storyboard can conceal correctly while silently failing to set up a later reveal. After this Sprint: the schema gains a `reader_takeaway` field held to the same specification-not-prose discipline; `storyboarding` populates it and treats an empty one as a default-to-fill anti-pattern; a new `agents/steps/storyboard-review.md` reads the chapter's storyboard blocks and reports beats whose takeaway is unsupported, whose reveals lack prior setup, or whose takeaway contradicts their own concealment; and `storyboard_review` sits between `storyboarding` and `drafting` in the canonical step list.

This is a documentation/prose-contract milestone, like the sprints before it. The implementation edits are Markdown schema fields, step bodies, the catalog, and the two canonical step-list files; the only script that must keep passing is `scripts/check-pipeline-state.sh` against the updated step list.

## Background — what is and isn't wrong today

Established by inspection during planning; tasks should not re-derive this.

- **The schema has a concealment axis but no comprehension axis.** `concealment_from_reader` lists "what the narrative must not name, explain, or clarify yet" and is called out as "the most important field and the most commonly skipped" (`agents/storyboard-schema.md:92-99`). There is no field for the inverse — what the reader *must* understand, feel, or infer by the beat's end. `knowledge_delta` is close but different: it tracks what each *character* learns (`agents/storyboard-schema.md:119-126`), not what the *reader* takes away. A beat can therefore satisfy every existing field and still under-communicate to the reader.
- **Storyboard fields are markdown sections, not frontmatter.** Frontmatter holds only short structured values — `scene_ref`, `date`, `location`, `beat_index`, `pov`, `beat_type`, `pace` (`agents/storyboard-schema.md:36-45`); "All narrative content belongs in the markdown sections below" (`:61`). `concealment_from_reader`, `knowledge_delta`, and `must_preserve` are all `##` markdown sections referenced in snake_case (`:92`, `:119`, `:128`). `reader_takeaway` follows that pattern: a new `## Reader takeaway` markdown section, not a frontmatter key.
- **Every field is held to one governing discipline: specification, not prose.** "Storyboarding plans what the beat must contain and what it must do; drafting writes the sentences. If a field could appear unedited in the novel, it is mis-filled" (`agents/storyboard-schema.md:14-30`). Each field carries a Specification vs. Prose (do-not-use) example pair. `reader_takeaway` must ship with the same pair and be bound by the same discipline (`:158`).
- **The two-axis disambiguation pattern already exists and is enforced by an anti-pattern.** The schema deliberately separates `concealment_from_reader` (narrative hides from reader) from `concealment_from_characters` (character hides from character), and an explicit anti-pattern forbids collapsing them: "Characters hiding from each other and the narrative hiding from the reader are different axes. Keep them separate" (`agents/storyboard-schema.md:164`). `reader_takeaway` vs `knowledge_delta` is the same shape of distinction (reader comprehension vs character knowledge) and gets the same treatment.
- **`storyboarding` already flags one empty field as an anti-pattern; there is a template to copy.** `storyboarding.md` names "Empty concealment fields" as an anti-pattern and says "Default to filling it" (`agents/steps/storyboarding.md:58`), and the schema echoes it (`agents/storyboard-schema.md:161`). `reader_takeaway`'s default-to-fill anti-pattern mirrors this wording exactly.
- **`compliance_report` is the template for a read-only, report-only review step.** It reads storyboard blocks plus prose, records one entry per block (`CLEAN` or a list of typed violations), appends a per-run summary, and explicitly "does not propose fixes" (`agents/steps/compliance-report.md:16-17`, `:42-62`, `:88-103`, `:109-117`). It reads only its declared inputs and treats a block field it cannot evaluate as a storyboard defect to note, not a reason to reach for source files (`:24`, `:117`). `storyboard_review` mirrors this posture — but reviews the storyboard itself, before any draft exists.
- **`storyboard_review` runs before drafting, so the report→fix machinery does not apply.** It "sits between storyboarding and drafting" (`ROADMAP.md:211`), so there is no `<latest-draft>`, no `drafts/<latest-attempt>/` folder yet, and nothing to stamp. The report→fix adjacency invariant (`agents/orchestrator.md:108-123`) governs report/fix pairs over a *draft*; `storyboard_review` has neither a draft nor a paired fix step, so it is outside that invariant entirely — the same way `line_pass` is outside it for the opposite reason (`agents/orchestrator.md:121`).
- **There is no paired fix step, and there will not be one this Sprint.** `storyboard_review_fix` is explicitly deferred (`ROADMAP.md:214` M6 notes; `ROADMAP.md:264` Deferred list: "storyboard_review_fix apply step (after M6 proves out)"). So `storyboard_review` is the first advisory report step with no automatic consumer. It is purely diagnostic: the human reads it and revises the storyboards (or re-runs `storyboarding`) by hand before drafting.
- **The reveal-setup check is within-chapter only.** The cross-chapter/story-level reveals ledger is deferred (`ROADMAP.md:214` M6 notes: "the cross-chapter reveals ledger are deferred"; `ROADMAP.md:265` Deferred list). For `short_story` projects there is only one chapter, so the question does not even arise (`agents/orchestrator.md:104`). `storyboard_review` reasons only over the current chapter's ordered storyboard set.
- **Beat ordering is already available without new schema.** Each block carries `beat_index` and `scene_ref` in frontmatter (`agents/storyboard-schema.md:38-44`) and the filename encodes scene-id and beat-id (`agents/steps/storyboarding.md:32`, `:64`). `scene-list.md` gives canonical scene order and scene-level intent and is already a `storyboarding` input (`agents/steps/storyboarding.md:5`, `:24`). So the "prior setup" check can order beats from the blocks plus `scene-list.md` — no dependency field needs to be added (M6.1 adds exactly one field).
- **The canonical step list lives in two files that must stay in sync, and the exhaustive check couples the step file to the list.** `templates/pipeline-state.md:16-29` is the default sequence; `examples/smoke/pipeline-state.md:14-27` mirrors it. Both list `storyboarding` immediately followed by `drafting`; `storyboard_review` inserts between them in both. `scripts/check-pipeline-state.sh` resolves every listed step_id to `agents/steps/<step-id-with-dashes>.md` (default/resolvable mode), and in `--exhaustive` mode also requires every step file to appear in the list (`scripts/check-pipeline-state.sh:4-13`, `:120-146`). So the new step file and the two list edits must land together or `--exhaustive` fails.
- **The step-id → filename rule is fixed.** `step_id: storyboard_review` resolves to `agents/steps/storyboard-review.md` (underscores → dashes) per `agents/orchestrator.md:9`, `:61`.
- **The `AGENTS.md` catalog lists step files in pipeline order.** The `storyboarding` entry (`AGENTS.md:52`) is immediately followed by the `drafting` entry (`AGENTS.md:53`). A `storyboard-review` entry belongs between them, mirroring the one-line shape of the surrounding entries. `storyboard-schema.md` already has a support-doc catalog entry (`AGENTS.md:75`) that needs no change.

## Definition of done

The Sprint is complete when:

1. ROADMAP.md tasks M6.1-M6.4 are checked.
2. `agents/storyboard-schema.md` defines a `## Reader takeaway` (`reader_takeaway`) markdown section: what the reader must understand, feel, or infer by the beat's end. It is held to the specification-not-prose discipline with its own Specification vs. Prose example pair, is default-to-fill (not optional), and is explicitly distinguished from `concealment_from_reader` (its inverse) and `knowledge_delta` (character knowledge, not reader comprehension). The Anti-patterns section gains the corresponding entries.
3. `agents/steps/storyboarding.md` instructs the step to populate `reader_takeaway` for every block and names an empty `reader_takeaway` as a default-to-fill anti-pattern, mirroring the existing empty-`concealment_from_reader` anti-pattern.
4. `agents/steps/storyboard-review.md` exists with frontmatter declaring `step_id: storyboard_review`, `review_required: true`, inputs `<chapter-folder>/storyboards/*-storyboard.md` + `<chapter-folder>/scene-list.md`, and output `<chapter-folder>/storyboards/storyboard-review.md`. Its body defines the read-only, report-only, advisory posture and the three checks below, and produces a per-block report plus a summary with no fix proposals and no annotation grammar.
5. The three checks are documented in `storyboard-review.md`:
   - **Takeaway supported** — each beat's `reader_takeaway` is supported by that beat's own content (`beat` description, `must_preserve`, `canon_active`, character-state fields); an asserted takeaway with no on-page support is flagged.
   - **Reveal setup** — for each beat whose takeaway depends on the reader already understanding something (including `beat_type: reveal` beats), an earlier beat in the chapter's ordered set establishes it and it is not still under `concealment_from_reader` at that point; missing setup is flagged.
   - **Takeaway/concealment consistency guard** — a beat's `reader_takeaway` must not require the reader to grasp something the same beat's `concealment_from_reader` forbids naming or clarifying; a contradiction is flagged.
6. `storyboard_review` is inserted after `storyboarding` (and before `drafting`) in both `templates/pipeline-state.md` and `examples/smoke/pipeline-state.md`, and `scripts/check-pipeline-state.sh` passes in both resolvable (default) and `--exhaustive` modes against `templates/pipeline-state.md` and `agents/steps/`.
7. `AGENTS.md` gains a catalog entry for `agents/steps/storyboard-review.md` between the `storyboarding` and `drafting` entries, and the `storyboarding` entry notes it now populates `reader_takeaway`.
8. Verification greps confirm the wiring:
   - `git grep -n "reader_takeaway\|Reader takeaway" -- '*.md'` shows the field in `storyboard-schema.md`, `storyboarding.md`, and `storyboard-review.md`.
   - `git grep -nE "storyboard_review|storyboard-review\.md" -- '*.md'` shows the step referenced from the catalog, both canonical step lists, and its own step file.
9. No prose-advancing or downstream step is edited by this Sprint. `git diff --stat` for `agents/steps/` shows only `storyboarding.md` and the new `storyboard-review.md`; `drafting.md` and everything after it are untouched. The canonical step *order* is unchanged apart from the `storyboard_review` insertion between `storyboarding` and `drafting`.

## Conventions adopted by this Sprint

Locked at the start so individual tasks don't rediscover them.

- **`reader_takeaway` is a markdown section, not frontmatter.** It carries narrative-as-specification content, and the schema mandates that all such content lives in markdown sections while frontmatter stays short and structured (`agents/storyboard-schema.md:61`). It is placed directly after `## Concealment from reader` so the two reader-facing axes sit together.
- **`reader_takeaway` is comprehension, not character knowledge and not canon content.** It states what the *reader* must understand/feel/infer by the beat's end — distinct from `knowledge_delta` (what a *character* learns; a different axis, exactly like the `concealment_from_reader` vs `concealment_from_characters` split) and from `must_preserve` (canon-mandated content that must physically appear in the prose). The schema disambiguates all three explicitly and adds a "reader_takeaway duplicating knowledge_delta" anti-pattern mirroring the existing concealment two-axis anti-pattern (`agents/storyboard-schema.md:164`).
- **`reader_takeaway` is default-to-fill, held to specification-not-prose.** Like `concealment_from_reader`, an empty field is a defect to be justified, not a default (`agents/storyboard-schema.md:94`, `:161`; `agents/steps/storyboarding.md:58`). And like every field, a `reader_takeaway` that reads like prose is rewritten as specification (`agents/storyboard-schema.md:30`, `:158`).
- **`storyboard_review` is advisory-only: report, no annotation grammar, no fix step.** `storyboard_review_fix` is deferred (`ROADMAP.md:214`, `:264`), so there is no consumer for FIX/SKIP/ESCALATE annotations. Per Sprint 10's locked "no unused annotation surface" rule (do not build annotation grammar until a consumer exists — the reasoning that kept bulk headers out of `prose_pass`), the report is pure findings a human reads and acts on by hand. When `storyboard_review_fix` is planned, that milestone adds the grammar — exactly as `prose_pass`'s annotation grammar landed alongside `prose_fix` in Sprint 10, not before.
- **`storyboard_review` is outside the report→fix adjacency invariant.** It reviews a pre-draft artifact: no `<latest-draft>`, no `drafts/<latest-attempt>/` folder, nothing to stamp. The invariant governs report/fix pairs over a draft (`agents/orchestrator.md:108-123`); `storyboard_review` has neither a draft nor a paired fix, so it neither writes a `Reviewed-draft:` stamp nor participates in the invariant. No edit to `agents/orchestrator.md` is required.
- **`storyboard_review` reads only storyboards and the scene list.** It does not read canon source files (each block's fields are self-contained for what it evaluates — a missing field is a storyboard defect to note, mirroring `compliance_report`'s discipline at `agents/steps/compliance-report.md:24`, `:117`) and it does not read any draft (none exists). `scene-list.md` is read only for canonical scene/beat ordering and scene-level reveal intent.
- **The report lives beside the storyboards it reviews.** Output is `<chapter-folder>/storyboards/storyboard-review.md`. The other report steps write into `drafts/<latest-attempt>/` because they review a draft; `storyboard_review` runs before any draft attempt exists, so its report sits in the `storyboards/` folder it reviews.
- **`review_required: true`, but the step never blocks drafting.** The report is the human review artifact; the human decides whether to revise storyboards before drafting. As everywhere in the pipeline, nothing is enforced — the orchestrator does not gate on review (`agents/orchestrator.md:30`, `:127`); judgment is the human's.
- **The reveal-setup check is within-chapter only.** Cross-chapter/story-level reveal tracking is deferred (`ROADMAP.md:214`, `:265`). The check reasons only over the current chapter's ordered storyboard blocks.
- **Report format mirrors `compliance_report`.** Per-block entries (`CLEAN` on one line, or a list of typed findings), a per-run dated header, and a closing summary that tallies findings and may note a pattern-level observation but proposes no fixes (`agents/steps/compliance-report.md:34-103`).

---

## Tasks

### Task 1 — Add the `reader_takeaway` field to `storyboard-schema.md`

- [ ] Done

**Goal.** Give the schema a comprehension axis: what the reader must take away from a beat, as the positive counterpart to `concealment_from_reader`. Closes **M6.1**.

**Requirements.**

- In `agents/storyboard-schema.md`, add a `## Reader takeaway` markdown section (referenced in prose as `reader_takeaway`) directly after `## Concealment from reader` (`agents/storyboard-schema.md:92-99`).
  - Define it as: what the reader must understand, feel, or infer by the beat's end — the reader's comprehension target for the beat.
  - Hold it to the governing specification-not-prose discipline and give it a Specification vs. Prose (do-not-use) example pair in the same format as the surrounding fields.
  - State that it is default-to-fill (an empty field is a defect to justify, not a default), echoing the `concealment_from_reader` language (`:94`).
  - Explicitly distinguish it from `concealment_from_reader` (its inverse — what the reader must *not* understand yet) and from `knowledge_delta` (what a *character* learns, a different axis).
- In the Anti-patterns section (`agents/storyboard-schema.md:154-166`), add entries mirroring the existing ones:
  - **Empty reader_takeaway** — default to filling it; an empty field is only correct after confirming the beat genuinely asks nothing of the reader's understanding (mirror the empty-`concealment_from_reader` anti-pattern at `:161`).
  - **reader_takeaway as prose** — it is a specification of what the reader should grasp, not a sample of the sentences that will make them grasp it (mirror the field-level prose anti-pattern at `:158`).
  - **reader_takeaway duplicating knowledge_delta** — reader comprehension and character knowledge are different axes; keep them separate (mirror the concealment two-axis anti-pattern at `:164`).
- Do **not** add `reader_takeaway` to the YAML frontmatter or add any new frontmatter key; all narrative content stays in markdown sections (`:61`).
- Do **not** add a cross-beat dependency field, reveal-id, or any second field; M6.1 adds exactly one field. `storyboard_review`'s reveal-setup check infers ordering from `beat_index`/`scene_ref` and `scene-list.md` (see Task 3).

**Done when.** `agents/storyboard-schema.md` defines `reader_takeaway` as a default-to-fill markdown section with a Specification/Prose example pair, cleanly distinguished from `concealment_from_reader` and `knowledge_delta`, and the Anti-patterns section carries the three new entries. No frontmatter change and no second field.

---

### Task 2 — Populate `reader_takeaway` in `storyboarding.md`

- [ ] Done

**Goal.** Make the storyboarding step fill the new field for every block and treat an empty one as an anti-pattern. Closes **M6.2**.

**Requirements.**

- In `agents/steps/storyboarding.md`, update the Behavior/What-a-Storyboard-Block-Is discussion (`agents/steps/storyboarding.md:34-48`) so the step is instructed to populate `reader_takeaway` for every block, pointing at `agents/storyboard-schema.md` for the field definition (the step body defers field definitions to the schema — `:40` — so do not restate the full definition here).
- In the Anti-Patterns section (`agents/steps/storyboarding.md:52-60`), add an **Empty reader_takeaway** anti-pattern that mirrors the existing **Empty concealment fields** entry (`:58`): default to filling it; leaving it blank is only correct after confirming the beat asks nothing of the reader's understanding.
- Keep the step's Independent-Draftability framing intact (`:44-48`) — `reader_takeaway` is one more field the block must carry, not a new input dependency.
- Do not change the step's frontmatter inputs/outputs; the field lives inside the storyboard block files the step already writes.

**Done when.** `agents/steps/storyboarding.md` tells the step to populate `reader_takeaway` for every block and flags an empty `reader_takeaway` as a default-to-fill anti-pattern, consistent with the schema's Task 1 wording.

---

### Task 3 — Write `agents/steps/storyboard-review.md`

- [ ] Done

**Goal.** Ship the advisory review step that flags reader-reveal coverage gaps in a chapter's storyboards. Closes **M6.3**.

**Requirements.**

- Create `agents/steps/storyboard-review.md` with frontmatter:
  ```yaml
  ---
  step_id: storyboard_review
  review_required: true
  inputs:
    - <chapter-folder>/storyboards/*-storyboard.md
    - <chapter-folder>/scene-list.md
  outputs:
    - <chapter-folder>/storyboards/storyboard-review.md
  ---
  ```
- Include a `See agents/orchestrator.md for the step workflow contract.` reference line at the top of the body, mirroring the other step files (`agents/steps/compliance-report.md:11`).
- **Purpose.** State that `storyboard_review` is a read-only, report-only, advisory pass over a chapter's storyboard blocks that flags where the reader is under-served: takeaways the storyboard does not support, reveals with no prior setup, and takeaways that contradict their own concealment. It runs after `storyboarding` and before `drafting`. It is purely diagnostic — it proposes no fixes and there is no paired fix step (a `storyboard_review_fix` is a future milestone); the human reads the report and revises the storyboards by hand.
- **Inputs.** Explain each input. Read all storyboard blocks for the chapter and `scene-list.md` for canonical scene/beat ordering and scene-level reveal intent. State explicitly that it does **not** read any draft (none exists at this stage) and does **not** read canon source files — each block's fields are self-contained for what this step evaluates; a field that is missing or unparseable is a storyboard defect to note, not a reason to reach for source files (mirror `agents/steps/compliance-report.md:24`, `:117`).
- **Behavior — the three checks.** Document each, block by block:
  - **Check 1: Takeaway supported.** For each block, confirm the beat's own content — the `beat` description, `must_preserve`, `canon_active`, and character-state fields — gives the drafter the material to land the block's `reader_takeaway`. If the takeaway asserts an understanding the beat provides no on-page support for, record a finding.
  - **Check 2: Reveal setup.** Order the chapter's blocks (by `scene-list.md` scene order, then `beat_index`). For each block whose `reader_takeaway` depends on the reader already understanding something — including every `beat_type: reveal` block — confirm an earlier block establishes that understanding (via its `reader_takeaway` or content) and that the depended-on fact is not still listed under `concealment_from_reader` at the earlier point. If no prior setup exists, record a finding. This check is within-chapter only.
  - **Check 3: Takeaway/concealment consistency guard.** For each block, confirm its `reader_takeaway` does not require the reader to grasp something the same block's `concealment_from_reader` forbids naming or clarifying. If they conflict, record a finding.
- **Output file format.** Mirror `compliance_report` (`agents/steps/compliance-report.md:30-103`): a per-run dated header (`## Storyboard Review — [chapter/scene id], [date]`); one entry per block that is either a single `### Block NNN — CLEAN` line or a list of typed findings; and a closing `### Summary` tallying findings by check and noting any pattern-level observation. Findings only — never record passing checks alongside findings. Use finding labels such as:
  - `UNSUPPORTED (reader_takeaway): [beat] — [takeaway] has no on-page support in the beat's content`
  - `UNSETUP (reveal): [beat] — depends on [understanding] with no prior setup in the chapter`
  - `CONTRADICTION (reader_takeaway vs concealment_from_reader): [beat] — takeaway "[…]" requires naming what concealment forbids "[…]"`
  Do **not** include a `Reviewed-draft:` stamp (there is no draft) and do **not** add any FIX/SKIP/ESCALATE annotation grammar (advisory-only; no consumer exists).
- **Constraints.** Read-only over the storyboards — never rewrite a storyboard block. Propose no fixes; the summary is a diagnostic, not a recommendation (mirror `agents/steps/compliance-report.md:103`). Do not reason across chapters. Do not read the draft or canon source files.
- **Outputs.** `<chapter-folder>/storyboards/storyboard-review.md` — the advisory report, written beside the storyboards it reviews (there is no `drafts/<latest-attempt>/` folder yet). Describe the file the way `compliance_report`'s Outputs section describes `reviewer-actions.md` (`agents/steps/compliance-report.md:105-107`), minus the stamp and the annotation contract.
- **Open questions handling.** Standard blocker path (mirror `agents/steps/compliance-report.md:119-121`): if the step cannot complete — no storyboard blocks, a block whose fields cannot be parsed, or no `scene-list.md` — append the blocker to the project-root `open-questions.md` and exit without advancing the marker. Do not fabricate inputs and do not write a partial report.
- **Anti-patterns.** Include at least: proposing fixes or rewriting storyboards (this step is advisory and read-only); recording passing checks alongside findings (a block entry is either `CLEAN` or findings-only); reaching for canon source files when a block field is thin (that is a storyboard defect to note); reasoning across chapters (within-chapter only); adding a `Reviewed-draft:` stamp or annotation grammar (neither applies to a pre-draft advisory report).

**Done when.** A single `agents/steps/storyboard-review.md` implements the read-only advisory pass with the three checks, mirrors `compliance_report`'s report shape (dated header, per-block `CLEAN`/findings, summary, no fixes), writes its report beside the storyboards, carries no draft stamp or annotation grammar, and honors the standard open-questions blocker path.

---

### Task 4 — Insert `storyboard_review` into the canonical step list and catalog

- [ ] Done

**Goal.** Land the new step in the pipeline order, keep the pipeline-state check green, and make the step discoverable in the catalog. Closes **M6.4**.

**Requirements.**

- Update `templates/pipeline-state.md`: insert `- [ ] storyboard_review` between `storyboarding` and `drafting` (`templates/pipeline-state.md:18-19`). Do not reorder any other step.
- Update `examples/smoke/pipeline-state.md`: same insertion (`examples/smoke/pipeline-state.md:16-17`).
- Update `AGENTS.md`:
  - Add a catalog entry for `agents/steps/storyboard-review.md` between the `storyboarding` entry (`AGENTS.md:52`) and the `drafting` entry (`AGENTS.md:53`), in the one-line shape of the surrounding entries — describe it as an advisory, report-only pass that checks each beat's `reader_takeaway` is supported and its reveals have prior setup, producing `storyboards/storyboard-review.md`.
  - Amend the `storyboarding` entry (`AGENTS.md:52`) to note it now also populates `reader_takeaway`.
- Run `scripts/check-pipeline-state.sh templates/pipeline-state.md agents/steps` (resolvable/default mode) and confirm it exits `OK [resolvable]`. Then run `scripts/check-pipeline-state.sh --exhaustive templates/pipeline-state.md agents/steps` and confirm it exits `OK [exhaustive]` — the new step file must now be present in the step set with no missing-from-list error.
- Do not edit `agents/orchestrator.md`: it points at `templates/pipeline-state.md` as the canonical list (`agents/orchestrator.md:46`), and `storyboard_review` is outside the report→fix invariant, so nothing in the orchestrator contract changes.

**Done when.** Both `templates/pipeline-state.md` and `examples/smoke/pipeline-state.md` list `storyboard_review` between `storyboarding` and `drafting`; `AGENTS.md` has the new catalog entry and the amended `storyboarding` entry; `check-pipeline-state.sh` passes in both resolvable and `--exhaustive` modes.

---

### Task 5 — Verification sweep, ROADMAP / SPRINT check-off

- [ ] Done

**Goal.** Close the Sprint with a documented verification and mark the milestone complete. Closes the residual of **M6** and this Sprint.

**Requirements.**

- Run the following verification greps and review each hit:
  - `git grep -n "reader_takeaway\|Reader takeaway" -- '*.md'` — must show hits in `agents/storyboard-schema.md`, `agents/steps/storyboarding.md`, and `agents/steps/storyboard-review.md`.
  - `git grep -nE "storyboard_review|storyboard-review\.md" -- '*.md'` — must show hits in `agents/steps/storyboard-review.md`, `templates/pipeline-state.md`, `examples/smoke/pipeline-state.md`, `AGENTS.md`, and `ROADMAP.md`.
  - `git grep -nE "Reviewed-draft" -- 'agents/steps/storyboard-review.md'` — must return nothing (the advisory report carries no stamp).
- Confirm `agents/steps/storyboard-review.md` reads cleanly against the shape of `agents/steps/compliance-report.md`: frontmatter, `See agents/orchestrator.md` reference line, Purpose, Inputs, Behavior (three checks), Output file format, Constraints, Outputs, Open questions handling, Anti-patterns.
- Confirm no downstream step was edited: `git diff --stat` for `agents/steps/` shows only `storyboarding.md` and the new `storyboard-review.md`; `drafting.md` and every later step are untouched.
- Run `scripts/check-pipeline-state.sh` in both resolvable and `--exhaustive` modes against `templates/pipeline-state.md` and `agents/steps/`; capture the exit status (`OK [resolvable]` and `OK [exhaustive]`).
- Update `ROADMAP.md` M6.1-M6.4 to `[x]` only after Tasks 1-4 pass verification. Update the M6 notes section if any decision changed from what this SPRINT.md locks (it should not).
- Check this SPRINT.md's per-task `- [ ]` boxes (Tasks 1-5) only after their acceptance conditions hold.

**Done when.** The verification greps return the expected patterns, `check-pipeline-state.sh` passes in both modes, ROADMAP M6 checkboxes are ticked, and SPRINT.md task checkboxes reflect completed work.

---

## Out of scope for this Sprint

- **`storyboard_review_fix` apply step.** Deferred until M6 proves out (`ROADMAP.md:264`). This Sprint ships the advisory report only; there is no automatic consumer and no FIX/SKIP/ESCALATE annotation grammar. Adding that grammar is that future milestone's job.
- **Cross-chapter / story-level reveal tracking.** The reveals ledger with buildup is deferred (`ROADMAP.md:265`). `storyboard_review` reasons within a single chapter only.
- **Any new schema field beyond `reader_takeaway`.** No reveal-id, `depends_on`, or `sets_up` field. Reveal dependencies are inferred from `beat_type`, `reader_takeaway`, `concealment_from_reader`, and `scene-list.md` ordering.
- **Any change to `concealment_from_reader`, `knowledge_delta`, `must_preserve`, or the rest of the schema.** M6 only adds `reader_takeaway` and disambiguates it from the neighbours.
- **Any change to `drafting` or later steps, or to the report→fix adjacency invariant.** `storyboard_review` runs before drafting and is outside that invariant; drafting reads storyboards exactly as before. Verification confirms no downstream edits.
- **Reordering the canonical step list beyond inserting `storyboard_review`.** No other step is renamed, reordered, or split.
- **A `storyboard_review` counterpart in `opencode/`.** M6's tasks do not call for OpenCode host parity; if a consuming OpenCode project needs it, that is follow-up work, tracked separately.
