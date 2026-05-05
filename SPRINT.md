# Sprint 4 — Milestone 4: Drop filename prefixes

This Sprint finishes the rename Milestone 4 promises: support docs and metaphor subagent contracts catch up to the unprefixed convention the step bodies in `agents/steps/` already use. After this Sprint, no tracked text in this repo refers to `xx-yy-`, `zzz-`, or `01-`/`02-` book-numbered planning files; every chapter-folder file is documented under its canonical unprefixed name; and `ROADMAP.md` no longer references the consuming project `mgp-story`, whose adoption is its own concern.

## Definition of done

The Sprint is complete when:

1. ROADMAP.md tasks 18 and 19 (Milestone 4) are checked. Task 20 has been deleted from the roadmap as part of the mgp-story cleanup; it is not a thing to mark done.
2. `git grep -nE 'xx-yy-|\bzzz-'` returns nothing in tracked text.
3. `git grep -nE '01-beats|01-cast|01-outline|01-open-questions|01-continuity'` returns nothing in tracked text.
4. `git grep -n 'mgp-story\|mgp_story'` returns nothing in tracked text.
5. `agents/chapters.md` and `agents/books.md` describe their files using the unprefixed canonical names. Storyboarding is documented as per-beat files inside `<chapter-folder>/storyboards/`, not as a single chapter-level file.
6. The metaphor subagent contracts (`agents/metaphor/metaphor-flatten.md`, `metaphor-replace.md`, `metaphor-workshop.md`) describe their inputs conceptually, not as legacy prefixed paths.
7. `agents/workflows.md` and `agents/steps/anti-ai.md` use the unprefixed conventions: canonical chapter-folder paths, fuller scene citations, and `Scene <scene-id>` labels in report content.
8. `agents/project-layouts.md` no longer carries the "until then existing projects retain their prefixed filenames" caveat — Milestone 4 has landed.

## Conventions adopted by this Sprint

These choices are locked at the start of the Sprint so individual tasks don't rediscover them.

**Canonical chapter-folder filenames.** Inside any `<chapter-folder>/`, files use unprefixed names. Files that contain prose all start with `draft`. The full list of canonical names this Sprint will lock into the support docs:

- `summary.md` — chapter intent.
- `scene-list.md` — scene-by-scene plan.
- `storyboards/<scene-id>-<beat-id>-storyboard.md` — one storyboard file per beat, inside the `storyboards/` subdirectory. There is no longer a single chapter-level `*-storyboard.md` file.
- `drafts/attemptNN/draft.md` — assembled chapter prose for the attempt.
- `drafts/attemptNN/sceneNN.md` and `drafts/attemptNN/sceneNN-notes.md` — per-scene working artifacts inside the attempt folder.
- `drafts/attemptNN/notes.md` — combined run notes for the attempt.
- `drafts/attemptNN/reviewer-actions.md` — compliance report.
- `drafts/attemptNN/draft-compliance.md` — prose after compliance fixes.
- `drafts/attemptNN/prose-pass.md` — advisory prose-quality report.
- `drafts/attemptNN/metaphors.md` — metaphor working file.
- `drafts/attemptNN/draft-metaphor.md` — prose after metaphor apply.
- `drafts/attemptNN/draft-line.md` — prose after line pass.
- `drafts/attemptNN/anti-ai.md` — anti-AI report.
- `aftermath.md` — post-chapter delta record.
- `open-questions.md` — chapter-scoped questions, if used. (The project-root `open-questions.md` defined in `agents/project-layouts.md` is unchanged.)

This Sprint does not invent new files; it only reconciles the support-doc names with what the step files already produce. If a support doc lists a file the step files do not produce (or vice versa), defer to the step files.

**Canonical book-folder planning files.** Inside any `<book-folder>/`, the optional planning artifacts documented in `agents/books.md` lose their `01-` prefix and become:

- `beats.md`
- `cast.md`
- `outline.md`
- `open-questions.md` (book-scoped; distinct from project-root and chapter-scoped)
- `continuity.md`

`overview.md` and `outline.md` are the strategic files and were already unprefixed. Note: the old doc had both `01-outline.md` (planning) and `outline.md` (strategic); under the new convention there is one `outline.md` per book — the sequential plan. Projects that want a separate scratch file for early planning may keep one under any name they like; the support doc no longer prescribes one.

**Scene citations in cross-file references.** Where the old convention used `xx-yy` as a scene tag (e.g., the knowledge-delta example in `agents/workflows.md`), the new form is a folder-style citation: `[from <book-id>/<chapter-id>/<scene-id>]`, e.g. `[from book1/chapter02/scene03]`. For `short_story` projects, `<book-id>` is omitted: `[from <chapter-id>/<scene-id>]`. This is a documentation convention; nothing in the pipeline parses it.

**Anti-AI report scene labels.** Headers inside the anti-AI report use `Scene <scene-id>` (e.g., `Scene 01`) rather than `Scene xx-yy`. The chapter context lives in the file path; the headers identify only the scene within the chapter.

**Metaphor subagent contracts: conceptual inputs.** The flatten, replace, and workshop contracts under `agents/metaphor/` are subagent prompts dispatched by `metaphor_fix`, not standalone steps. Their `Inputs` sections will describe what the subagent receives conceptually ("the working metaphors entry block", "the surrounding paragraph from the latest prose", and for workshop "the storyboard block for the entry's beat") rather than naming legacy paths. The coordinator (`agents/steps/metaphor-fix.md`) is where canonical paths are declared, and that's where they stay.

**No mgp-story.** This repo is pure tooling. References to the consuming project `mgp-story` are removed from `ROADMAP.md` in this Sprint's wrap-up task. mgp-story has its own migration path independent of this repo's roadmap. Nothing in this Sprint depends on, blocks, or coordinates with mgp-story.

**Idempotency.** This Sprint edits documentation only. No file renames, no project state, no migrations of consuming projects. The work is purely textual within `agents/` and `ROADMAP.md`.

---

## Tasks

### Task 1 — Update `agents/chapters.md` [x]

**Goal.** Rewrite `agents/chapters.md` so it documents chapter-folder files under their canonical unprefixed names and describes storyboarding as per-beat files inside `storyboards/`, matching what the step bodies in `agents/steps/` already produce.

**Requirements.**

- Replace section headings that use `xx-yy-` prefixes with their unprefixed canonical names. At minimum:
  - `### xx-yy-summary.md` → `### summary.md`
  - `### xx-yy-scene-list.md` → `### scene-list.md`
  - `### xx-yy-zzz-storyboard.md` → rewrite as a `### Storyboards` (or equivalent) section that describes the per-beat-file convention: one file per beat at `storyboards/<scene-id>-<beat-id>-storyboard.md` inside the chapter folder, schema in `agents/storyboard-schema.md`, generation defined in `agents/steps/storyboarding.md`. There is no single chapter-level storyboard file.
- Drop the opening sentence "Each file within a chapter folder will start with book number (xx) and chapter number (yy)" (or equivalent wording) — the new convention is that folder structure carries that identity.
- Confirm the existing sections for `draft.md`, `aftermath.md`, and `open-questions.md` remain accurate. If their wording implies any prefix or numbering, fix it.
- Add a brief note (one or two sentences) cross-referencing `agents/project-layouts.md` for how `<chapter-folder>` resolves per project_type. The reader should be able to resolve `summary.md` to a real path without leaving the documentation.
- Do not introduce new files or sections beyond what the canonical-filename list in this Sprint's Conventions section enumerates.

**Done when.** `agents/chapters.md` describes the chapter-folder contents using only unprefixed names; the storyboard section describes the per-beat-file layout under `storyboards/`; and `git grep -nE 'xx-yy-|\bzzz-' agents/chapters.md` returns nothing.

---

### Task 2 — Update `agents/books.md` [x]

**Goal.** Rewrite `agents/books.md` so book-level planning artifacts are documented with unprefixed names, and remove the paragraph prescribing `xx-yy-` chapter-file naming.

**Requirements.**

- Replace the "Numbered planning artifacts (`01-*.md` for Book 1, `02-*.md` for Book 2, etc.)" section with an unprefixed enumeration. Keep the same set of optional files, just drop the `01-`:
  - `beats.md`
  - `cast.md`
  - `outline.md` (note: this is the same name as the strategic `outline.md` already documented above; clarify in one sentence that under the new convention there is a single `outline.md` per book — the sequential plan — and projects that want a separate early-planning scratch file may keep one under any name they like)
  - `open-questions.md` (book-scoped)
  - `continuity.md`
- Delete the "Naming convention note" paragraph (the one that says "The leading two digits identify the book…" and "Chapter-level files use `xx-yy-...`"). That convention is gone. Replace with one sentence stating that book and chapter identity come from folder structure, with a pointer to `agents/project-layouts.md`.
- The strategic `overview.md` and `outline.md` sections at the top stay; no edit needed beyond resolving the duplicate `outline.md` reference described above.
- The "Book folder expectations" section already describes chapter folders as `chapter01`, `chapter02`, etc. Confirm it does not imply any file-prefix convention.

**Done when.** `agents/books.md` enumerates book-level planning artifacts without prefixes; the chapter-file naming paragraph is gone; and `git grep -nE 'xx-yy-|01-(beats|cast|outline|open-questions|continuity)' agents/books.md` returns nothing.

---

### Task 3 — Update metaphor subagent contracts [x]

**Goal.** Rewrite the `Inputs` sections of `agents/metaphor/metaphor-flatten.md`, `metaphor-replace.md`, and `metaphor-workshop.md` to describe inputs conceptually rather than as legacy `xx-yy-...md` paths. Body references to the working file are reworded the same way.

**Requirements.**

- For each of the three subagent contracts, replace `xx-yy-metaphors.md`, `xx-yy-draft.md`, and (workshop only) `xx-yy-zzz-storyboard.md` references with conceptual phrasing such as:
  - "the entry block from the working metaphors file"
  - "the surrounding paragraph from the latest prose, supplied by the coordinator"
  - (workshop only) "the storyboard block for the entry's beat, supplied by the coordinator"
- Make the conceptual phrasing consistent across the three files so a reader switching between them sees the same vocabulary.
- In the `Output` and body sections, replace any remaining `xx-yy-metaphors.md` mentions with "the working metaphors file" (or an equivalent neutral phrase). The subagents append to that file in place; what matters is the location of their output relative to the assigned entry, not the filename.
- Do **not** add canonical paths to these contracts. The canonical paths live in `agents/steps/metaphor-fix.md` (the coordinator), which is the authoritative declaration. The contracts intentionally stay path-agnostic.
- Preserve all existing behavior, format specifications, anti-pattern guidance, and step-by-step instructions. This task is a vocabulary swap, not a behavioral rewrite.
- The opening "subagent prompt contract" framing block at the top of each file is correct as-is; do not remove it.

**Done when.** The three contracts no longer reference `xx-yy-` paths anywhere; their `Inputs` sections describe what the coordinator supplies in conceptual terms; and `git grep -nE 'xx-yy-|\bzzz-' agents/metaphor/` returns nothing.

---

### Task 4 — Update `agents/workflows.md` and `agents/steps/anti-ai.md` [x]

**Goal.** Clean up the last two files that still mix legacy prefix conventions into otherwise current text: `agents/workflows.md` (one filename mention, one knowledge-delta citation example) and `agents/steps/anti-ai.md` (output report headers).

**Requirements.**

- In `agents/workflows.md`:
  - Replace the line "Write `xx-yy-metaphors.md` to list all metaphors and similes of the chapter…" so it no longer carries a prefixed filename. Keep the descriptive sentence about what the file contains; if a filename is retained at all, it is the canonical `metaphors.md` at `<chapter-folder>/drafts/<latest-attempt>/metaphors.md`. Add a one-line pointer to `agents/steps/metaphor-identify.md` as the step that produces the file for projects on the orchestrator.
  - In the "Workflow: storyboarding" knowledge-delta example, replace `[from xx-yy]` with the fuller citation form locked in this Sprint's Conventions: `[from <book-id>/<chapter-id>/<scene-id>]`. Note that for `short_story` projects `<book-id>` is omitted, giving `[from <chapter-id>/<scene-id>]`. Show one literal example like `[from book1/chapter02/scene03]` so the convention is unambiguous.
- In `agents/steps/anti-ai.md`:
  - Replace `## Anti-AI Report — Scene xx-yy` with `## Anti-AI Report — Scene <scene-id>`.
  - Replace `### Summary — Scene xx-yy` with `### Summary — Scene <scene-id>`.
  - Anywhere else in the body that uses `Scene xx-yy` as a label, update to `Scene <scene-id>`.
  - Do not change behavior, scope, or what the report flags. This is a label swap.
- The frontmatter, inputs, outputs, and behavior sections of `anti-ai.md` should not need changes — they already use `<chapter-folder>/drafts/<latest-attempt>/...` paths. Confirm this; if anything slipped through, fix it.

**Done when.** Neither file contains `xx-yy` in any form; the knowledge-delta example shows the new fuller citation; and the anti-AI report section headers use `Scene <scene-id>`.

---

### Task 5 — Sprint wrap-up: `project-layouts.md`, ROADMAP cleanup, verification [x]

**Goal.** After Tasks 1–4 land, do the residual cleanup, remove all `mgp-story` references from `ROADMAP.md`, run the acceptance greps, and check the relevant boxes.

**Requirements.**

- Update `agents/project-layouts.md` line 11. The current sentence reads: "The actual file renames happen in Milestone 4; until then existing projects retain their prefixed filenames." Drop the time-bound caveat — Milestone 4 has landed. Reword to state the rule plainly: folder paths replace filename prefixes, period. Do not mention milestones in this support doc.
- Edit `ROADMAP.md` to remove all `mgp-story` references. Specifically:
  - Delete Task 20 from Milestone 4. Milestone 4's task list becomes 18 and 19.
  - Delete Milestone 7 ("Adopt in mgp-story") in its entirety, including its goal line and tasks 29–33.
  - Verify task numbering across the roadmap stays internally consistent. If removing Task 20 leaves a numbering gap (e.g., 21 follows 19), close the gap by renumbering downstream tasks in place. If renumbering is too noisy because of cross-references, leave the gap and add a one-line note in the roadmap explaining the gap so future agents don't think a task is missing. Either choice is fine; just be consistent.
  - Remove the non-goal line "Reorganizing canon or character files in mgp-story." The surrounding non-goals stay.
  - In the "Proposed roadmap improvements" section, the bullet about "Explicit task dependencies" gives mgp-story as an example. Remove the mgp-story example clause; the dependency-annotation idea itself stays. Replacing with a different example task is fine; dropping the example clause entirely is also fine.
- Check ROADMAP.md tasks 18 and 19 (Milestone 4) as complete.
- Run the acceptance greps from the Definition of done and confirm each returns nothing in tracked text:
  - `git grep -nE 'xx-yy-|\bzzz-'`
  - `git grep -nE '01-beats|01-cast|01-outline|01-open-questions|01-continuity'`
  - `git grep -n 'mgp-story\|mgp_story'`
- Mark each completed task in this Sprint file as `[x]`.

**Done when.** `agents/project-layouts.md` no longer carries the milestone caveat; `ROADMAP.md` contains no reference to mgp-story and Milestone 7 is gone; all three acceptance greps return empty; and ROADMAP Milestone 4 is checked.

---

## Out of scope for this Sprint

- Any work inside the consuming project `mgp-story`. That project has its own migration path; this Sprint deliberately removes mgp-story references from this repo and does not coordinate with it.
- Renaming actual files inside any consuming project. This Sprint is purely documentation cleanup within the Amanuensis tooling repo. Step bodies already use the canonical unprefixed paths; consuming projects rename their own files when they adopt.
- Implementing the dispatcher (Milestone 5).
- Inventing new files in the chapter folder or book folder beyond the canonical lists locked in this Sprint's Conventions section. Reconciling the support docs with what the step files already produce is the scope; expanding the schema is not.
- Filling `templates/profile.md` with finalized content. That remains the human's responsibility from Sprint 3.
- Resolving the deferred `agents/orchestrator.md` TODO about canon invention.
