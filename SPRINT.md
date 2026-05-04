# Sprint 2 — Milestone 2: Refactor existing workflows to the step contract

This Sprint converts every existing workflow into a contract-conforming step file under `agents/steps/`. After this Sprint the orchestrator's step list resolves to real files on disk, every step declares its inputs, outputs, and review expectation in frontmatter, and the legacy per-document index in `AGENTS.md` gives way to an index of step files. No new step bodies are introduced; this Sprint is contract conformance plus the body cleanup the move forces.

## Definition of done

The Sprint is complete when:

1. Every Milestone 2 task in `ROADMAP.md` is checked.
2. Every step in `templates/pipeline-state.md` whose body already exists has a corresponding file at `agents/steps/<step-id-with-dashes>.md`. (Steps `character_extraction` and `scene_generation` remain unfilled — they belong to Milestone 3.)
3. Every step file has valid YAML frontmatter with `step_id`, `review_required`, `inputs`, and `outputs`. Each path placeholder used resolves under the rules in `agents/project-layouts.md`.
4. Every step file has an "Open questions handling" section describing what to do when the step is blocked.
5. The pre-step legacy locations (`agents/storyboarding.md`, `agents/drafting.md`, `agents/agentic-drafting.md`, `agents/compliance.md`, `agents/prose-pass.md`, `agents/line-pass.md`, `agents/anti-ai.md`, `agents/metaphor/metaphor-identify.md`, `agents/metaphor/metaphor-apply.md`) no longer exist as workflow files. Cross-references to them in tracked text have been updated.
6. `AGENTS.md` "Legacy workflow documents" section is replaced by an index of the new step files; non-step support docs (`update-rules.md`, `canon.md`, `chapters.md`, etc.) stay listed under a clearly labeled support-documents section.
7. `git grep "agents/storyboarding\|agents/agentic-drafting\|agents/compliance.md\|agents/prose-pass\|agents/line-pass\|agents/anti-ai\|agents/metaphor/metaphor-identify\|agents/metaphor/metaphor-apply"` returns nothing in tracked text outside of historical commit messages.

## Conventions adopted by this Sprint

These choices are locked at the start of the Sprint so individual tasks don't rediscover them.

**Step file location.** Step bodies live at `agents/steps/<step-id-with-dashes>.md`. Example: `metaphor_identify` → `agents/steps/metaphor-identify.md`. Non-step support docs (`update-rules.md`, `canon.md`, `chapters.md`, `characters.md`, `workflows.md`, `voice.md`, `storyboard-schema.md`, `meta.md`, `books.md`) stay in `agents/`.

**Per-attempt artifacts.** All per-attempt step outputs live at `<chapter-folder>/drafts/<latest-attempt>/`:

- `draft.md` — drafting output
- `reviewer-actions.md` — compliance_report output, compliance_fix appendix
- `draft-compliance.md` — compliance_fix output
- `prose-pass.md` — prose_pass report
- `metaphors.md` — metaphor_identify output, metaphor_fix appendix
- `draft-metaphor.md` — metaphor_apply output
- `draft-line.md` — line_pass output
- `anti-ai.md` — anti_ai report

**Prose-revision chain.** Suffix chain. Each prose-revising step reads the most recent prose file in the attempt folder and writes a new suffixed file. Order: `draft.md` → `draft-compliance.md` → (prose_pass report; no prose change) → `draft-metaphor.md` → `draft-line.md`. `anti_ai` reads `draft-line.md` (the latest prose).

**Body editing scope.** Path-and-cleanup. Update path references to the new placeholder conventions (`<chapter-folder>`, `<latest-attempt>`); update cross-file references that break due to the moves; delete or fix internal sections that are now wrong (e.g., the bash setup snippet in `drafting.md`'s "Experimental Mode," any lingering `xx-yy-` prose in the body). Do not introduce new behaviors, new checks, new severity levels, or new output shapes beyond what the step contract requires.

**Drafting step.** `agents/agentic-drafting.md` becomes the `drafting` step at `agents/steps/drafting.md`. The legacy `agents/drafting.md` is deleted; relevant per-scene constraints from it are folded into the new step body or its subagent prompt contract.

**Metaphor fix subagent pattern.** `metaphor_fix` is a coordinator step. It reads `metaphors.md`, identifies every entry annotated FLATTEN / REPLACE / WORKSHOP, dispatches one subagent per entry in parallel, and reassembles their appended variants. The three files `agents/metaphor/metaphor-flatten.md`, `agents/metaphor/metaphor-replace.md`, `agents/metaphor/metaphor-workshop.md` remain at their current location as subagent prompt contracts (not steps); the coordinator picks the right one based on the entry's annotation. Workshop's Phase 2 (Integration) is removed entirely — integration work belongs to `metaphor_apply`. The "one entry per session" workshop constraint is removed; parallel subagents make the constraint unnecessary.

**Deferred TODOs in `agents/orchestrator.md`** (canon invention, centralized human questions) remain deferred. No task in this Sprint touches them.

---

## Tasks

### Task 1 — `storyboarding` step [ ]

**Goal.** Move `agents/storyboarding.md` to `agents/steps/storyboarding.md` as a contract-conforming step.

**Requirements.**
- Add the frontmatter block from `templates/step-workflow.md`:
  - `step_id: storyboarding`
  - `review_required: true`
  - `inputs:` — the files the body actually reads. At minimum: `<chapter-folder>/scene-list.md`, `<chapter-folder>/summary.md`, `<chapter-folder>/storyboards-planning.md` (if used), the relevant character knowledge files under `characters/<id>/knowledge/`, and any canon files referenced by the scene list.
  - `outputs:` — `<chapter-folder>/storyboards/<scene-id>-<beat-id>-storyboard.md` (one file per storyboard block; document the file naming convention used today, dropping the `xx-yy-` prefix per the path conventions in `agents/project-layouts.md`).
- Add an "Open questions handling" section that follows the template default: append to project-root `open-questions.md`, exit without advancing.
- Update cross-references: any link inside the body to `agents/storyboard-schema.md` keeps pointing at `agents/storyboard-schema.md` (it remains a support doc).
- Body cleanup: replace `xx-yy-` filename references with the new path conventions. Do not change any storyboarding behavior, anti-pattern guidance, or the storyboard-block schema.

**Done when.** `agents/steps/storyboarding.md` exists with valid frontmatter, the body uses the new path conventions, and `agents/storyboarding.md` no longer exists. A grep for `agents/storyboarding.md` in tracked text returns no live references.

---

### Task 2 — `drafting` step (replaces both legacy drafting files) [ ]

**Goal.** Collapse `agents/agentic-drafting.md` and `agents/drafting.md` into a single contract-conforming step at `agents/steps/drafting.md`. The chapter coordinator that dispatches per-scene subagents *is* the drafting step.

**Requirements.**
- The new file's frontmatter:
  - `step_id: drafting`
  - `review_required: true`
  - `inputs:` — the chapter's storyboard files (`<chapter-folder>/storyboards/*-storyboard.md`) and the project's voice file (default `agents/voice.md`, overridable by the consuming project's local AGENTS.md).
  - `outputs:` — `<chapter-folder>/drafts/<latest-attempt>/draft.md` plus the run's per-scene working files (`scene01.md`, `scene01-notes.md`, …) and `notes.md`. Declare the per-scene files as outputs; they are real artifacts the step produces, not internal state.
- Body content comes from `agents/agentic-drafting.md` as the spine (coordinator behavior, subagent dispatch, scene grouping, assembly rules, notes assembly, failure handling). Fold in the per-scene constraints from `agents/drafting.md` that the subagents must follow — voice in system message, storyboard blocks in user message, no canon-file dumps, no extra-file reads — either inline or as the subagent prompt contract.
- Delete `agents/drafting.md` and `agents/agentic-drafting.md` after the new file is in place.
- Body cleanup: drop the "Experimental Mode" bash snippet from `agents/drafting.md`. Replace `xx-yy-draft.md` references with `<chapter-folder>/drafts/<latest-attempt>/draft.md`. Drop `plot/bookN/chapterYY/...` literals in favor of the path placeholders.
- Update cross-references in support docs. `agents/workflows.md` and `agents/update-rules.md` likely reference `drafting.md` and `agentic-drafting.md` directly — repoint at `agents/steps/drafting.md`.
- Add "Open questions handling" per the template default.

**Done when.** `agents/steps/drafting.md` exists with valid frontmatter and a body that fully covers what both legacy files covered (chapter coordinator + per-scene contract). Both legacy files are deleted. No live cross-references to either legacy path remain.

---

### Task 3 — `compliance_report` step [ ]

**Goal.** Split `agents/compliance.md` Phase 1 into its own step at `agents/steps/compliance-report.md`.

**Requirements.**
- Frontmatter:
  - `step_id: compliance_report`
  - `review_required: true`
  - `inputs:` — `<chapter-folder>/storyboards/*-storyboard.md`, `<chapter-folder>/drafts/<latest-attempt>/draft.md`.
  - `outputs:` — `<chapter-folder>/drafts/<latest-attempt>/reviewer-actions.md`.
- Body content is `compliance.md` Phase 1 verbatim (with path-and-cleanup edits). Includes the three checks (Must-Contain, Must-Not-Contain, Canon), the per-block entry format, the summary block, and the relevant Anti-Patterns ("Fixing during reporting," "Recording passing items," "Collapsing blocks," "Consulting files not listed as inputs").
- Drop Phase 2 from this file entirely. Phase 2 lives in Task 4.
- Add "Open questions handling" per the template default.

**Done when.** `agents/steps/compliance-report.md` exists, declares only Phase 1 inputs and the report output, and contains no fixing/applying behavior.

---

### Task 4 — `compliance_fix` step [ ]

**Goal.** Split `agents/compliance.md` Phase 2 into its own step at `agents/steps/compliance-fix.md`.

**Requirements.**
- Frontmatter:
  - `step_id: compliance_fix`
  - `review_required: false`
  - `inputs:` — `<chapter-folder>/drafts/<latest-attempt>/reviewer-actions.md` (annotated by the human), `<chapter-folder>/drafts/<latest-attempt>/draft.md`, the storyboard files for any FIX items (`<chapter-folder>/storyboards/*-storyboard.md`).
  - `outputs:` — `<chapter-folder>/drafts/<latest-attempt>/draft-compliance.md` plus appended `Applied:` / `Escalated:` blocks in `reviewer-actions.md`.
- Body content is `compliance.md` Phase 2 with one path change: the revised prose is written to `draft-compliance.md`, **not** back into `draft.md`. Update the "Output" section accordingly. The "do not improve beyond the violation," "preserve block comment markers," and "stop and append a note" constraints remain.
- The "Fixing unannotated violations" and "Rewriting beyond the violation" Anti-Patterns belong here.
- After Tasks 3 and 4 land, `agents/compliance.md` is deleted.
- Add "Open questions handling" per the template default. Note specifically that `ESCALATE`-annotated items are not blockers — the step appends an Escalated block and continues. Open-questions-handling is for when the input itself is unusable (e.g., reviewer-actions has no annotations at all).

**Done when.** `agents/steps/compliance-fix.md` exists, writes only `draft-compliance.md` and the appendix, and `agents/compliance.md` is deleted.

---

### Task 5 — `prose_pass` step [ ]

**Goal.** Move `agents/prose-pass.md` to `agents/steps/prose-pass.md` as a contract-conforming step. This step produces a report only — it does not modify prose.

**Requirements.**
- Frontmatter:
  - `step_id: prose_pass`
  - `review_required: true`
  - `inputs:` — the latest prose (`<chapter-folder>/drafts/<latest-attempt>/draft-compliance.md`), the chapter's storyboards (`<chapter-folder>/storyboards/*-storyboard.md`), the voice file (`agents/voice.md` or project-local override).
  - `outputs:` — `<chapter-folder>/drafts/<latest-attempt>/prose-pass.md`.
- Body cleanup: the current "Inputs" list says "chapter draft, storyboards, voice.md, optional outputs from other passes." Tighten to the declared inputs. The "optional outputs from other passes" line is removed — the step contract requires explicit inputs. Note in the body that the `KEEP / TIGHTEN / FLATTEN / REWRITE` recommendations are advisory; the step does not write to the prose. The human applies fixes manually before `metaphor_identify` runs.
- The body's existing structure (Top priorities, Findings template, Chapter-level diagnosis, Lines worth preserving) stays.
- Add "Open questions handling" per the template default.

**Done when.** `agents/steps/prose-pass.md` exists, declares the report file as its sole output, and `agents/prose-pass.md` no longer exists.

---

### Task 6 — `metaphor_identify` step [ ]

**Goal.** Move `agents/metaphor/metaphor-identify.md` to `agents/steps/metaphor-identify.md` as a contract-conforming step.

**Requirements.**
- Frontmatter:
  - `step_id: metaphor_identify`
  - `review_required: true`
  - `inputs:` — the latest prose (`<chapter-folder>/drafts/<latest-attempt>/draft-compliance.md`), the chapter's storyboards (`<chapter-folder>/storyboards/*-storyboard.md`).
  - `outputs:` — `<chapter-folder>/drafts/<latest-attempt>/metaphors.md`.
- Body cleanup: replace `xx-yy-draft.md` and `xx-yy-metaphors.md` with the new paths. Behavior, format, flag definitions (CLEAN / REVIEW / BROKEN), and Anti-Patterns are unchanged.
- Add "Open questions handling" per the template default.

**Done when.** `agents/steps/metaphor-identify.md` exists with valid frontmatter and `agents/metaphor/metaphor-identify.md` no longer exists.

---

### Task 7 — `metaphor_fix` step (subagent coordinator) [ ]

**Goal.** Create a single new step at `agents/steps/metaphor-fix.md` that consolidates flatten / replace / workshop logic. The step body is a coordinator that dispatches one subagent per annotated entry in parallel, then assembles the appended variants back into `metaphors.md`.

**Requirements.**
- Frontmatter:
  - `step_id: metaphor_fix`
  - `review_required: true`
  - `inputs:` — `<chapter-folder>/drafts/<latest-attempt>/metaphors.md` (human-reviewed working file), `<chapter-folder>/drafts/<latest-attempt>/draft-compliance.md` (for paragraph context), `<chapter-folder>/storyboards/*-storyboard.md` (for WORKSHOP entries only), `agents/voice.md` or project-local override (for WORKSHOP entries only).
  - `outputs:` — `<chapter-folder>/drafts/<latest-attempt>/metaphors.md` (appended variants).
- Body responsibilities for the coordinator:
  1. Read `metaphors.md`. Identify every entry annotated `FLATTEN`, `REPLACE: [target image]`, or `WORKSHOP`. Skip entries with no action word (the human has accepted them as-is) and any entry the human deleted entirely.
  2. For each annotated entry, dispatch one subagent in parallel. Pick the subagent prompt contract by annotation type:
     - `FLATTEN` → `agents/metaphor/metaphor-flatten.md`
     - `REPLACE` → `agents/metaphor/metaphor-replace.md`
     - `WORKSHOP` → `agents/metaphor/metaphor-workshop.md`
  3. Each subagent receives only what its prompt contract requires: the entry block, the surrounding paragraph extracted from `draft-compliance.md`, and (for workshop) the storyboard block for that beat plus the voice file. Subagents do not read the rest of the draft, the working file, or other entries.
  4. Each subagent writes its variants directly below its assigned entry in `metaphors.md`, in the format declared by its prompt contract.
  5. The coordinator does not select among variants. Human selection happens after the step exits.
- Update the three subagent prompt files in `agents/metaphor/`:
  - `metaphor-flatten.md` — keep behavior; add a brief header noting the file is a subagent prompt contract used by the `metaphor_fix` step, not a top-level workflow.
  - `metaphor-replace.md` — same.
  - `metaphor-workshop.md` — **delete Phase 2 (Integration) entirely**; integration is `metaphor_apply`'s job. **Remove the "one entry per session" rule**; subagent parallelization removes the constraint. Add the same subagent-prompt-contract header.
- Update `agents/metaphor/README.md` to describe the consolidated pipeline: identify → human review → metaphor_fix coordinator → human selection → metaphor_apply. Clearly state the new file roles.
- Add "Open questions handling" to the coordinator: if `metaphors.md` is missing or has no annotated entries, append to project-root `open-questions.md` and exit without advancing.

**Done when.** `agents/steps/metaphor-fix.md` exists as a coordinator step with subagent dispatch, the three subagent prompt files reflect their new role and have Phase 2/per-session constraints stripped from `metaphor-workshop.md`, and `agents/metaphor/README.md` describes the consolidated pipeline.

---

### Task 8 — `metaphor_apply` step [ ]

**Goal.** Move `agents/metaphor/metaphor-apply.md` to `agents/steps/metaphor-apply.md` as a contract-conforming step.

**Requirements.**
- Frontmatter:
  - `step_id: metaphor_apply`
  - `review_required: false`
  - `inputs:` — `<chapter-folder>/drafts/<latest-attempt>/metaphors.md` (post-human-selection), `<chapter-folder>/drafts/<latest-attempt>/draft-compliance.md`.
  - `outputs:` — `<chapter-folder>/drafts/<latest-attempt>/draft-metaphor.md`.
- Body cleanup: replace `xx-yy-draft.md` / `xx-yy-metaphors.md` / `xx-yy-draft-metaphor.md` with the new paths. The variant-handling logic, locate-the-change rules, and apply-log block are unchanged.
- Note in the body that surviving WORKSHOP variants are now individual sentences (since workshop's integration phase was removed). The "sentence variant" branch of Step 3 covers this case; no behavior change required, but the body should mention it explicitly so an agent isn't surprised that workshop entries arrive as bare sentences instead of integration-version paragraphs.
- Add "Open questions handling" per the template default.

**Done when.** `agents/steps/metaphor-apply.md` exists with valid frontmatter and `agents/metaphor/metaphor-apply.md` no longer exists.

---

### Task 9 — `line_pass` step [ ]

**Goal.** Move `agents/line-pass.md` to `agents/steps/line-pass.md` as a contract-conforming step.

**Requirements.**
- Frontmatter:
  - `step_id: line_pass`
  - `review_required: true`
  - `inputs:` — `<chapter-folder>/drafts/<latest-attempt>/draft-metaphor.md`, `<chapter-folder>/drafts/<latest-attempt>/draft-line.md` (read for already-finalized chunks once the step is partway through), `agents/voice.md` or project-local override.
  - `outputs:` — `<chapter-folder>/drafts/<latest-attempt>/draft-line.md`.
- Body cleanup: replace `xx-yy-draft-metaphor.md` and `xx-yy-draft-line.md` with the new paths. Chunking, context-window rules, seam policy, apply-log format, and Anti-Patterns are unchanged.
- Note that `draft-line.md` appears in both inputs and outputs because the step writes chunk-by-chunk and reads previously-finalized chunks as preceding-context. This is the same behavior the legacy doc describes; the frontmatter just makes it explicit.
- Add "Open questions handling" per the template default.

**Done when.** `agents/steps/line-pass.md` exists with valid frontmatter and `agents/line-pass.md` no longer exists.

---

### Task 10 — `anti_ai` step [ ]

**Goal.** Move `agents/anti-ai.md` to `agents/steps/anti-ai.md` as a contract-conforming step.

**Requirements.**
- Frontmatter:
  - `step_id: anti_ai`
  - `review_required: true`
  - `inputs:` — `<chapter-folder>/drafts/<latest-attempt>/draft-line.md` (the latest prose).
  - `outputs:` — `<chapter-folder>/drafts/<latest-attempt>/anti-ai.md`.
- Body cleanup: replace `xx-yy-draft.md` and `xx-yy-anti-ai.md` with the new paths. The eight pattern categories, the flagged-words list, the per-scene summary, and Anti-Patterns are unchanged.
- The current body says "This pass runs after compliance and metaphor check." Update to match the locked pipeline order: anti_ai is the last step; it reads the line-pass output.
- Add "Open questions handling" per the template default. (Anti-AI is unusual in that it is a context-free pass against a single file; blockers are rare.)

**Done when.** `agents/steps/anti-ai.md` exists with valid frontmatter and `agents/anti-ai.md` no longer exists.

---

### Task 11 — Sprint wrap-up: AGENTS.md, cleanup, verification [ ]

**Goal.** After Tasks 1–10 land, update `AGENTS.md` to reflect the new layout, remove now-empty directories and stale cross-references, and verify the Sprint's Definition of done holds.

**Requirements.**
- Replace the "Legacy workflow documents" section in `AGENTS.md` with two sections:
  - **"Step workflows"** — index of files in `agents/steps/` with one-line descriptions: `storyboarding.md`, `drafting.md`, `compliance-report.md`, `compliance-fix.md`, `prose-pass.md`, `metaphor-identify.md`, `metaphor-fix.md`, `metaphor-apply.md`, `line-pass.md`, `anti-ai.md`. Note that `character-extraction.md` and `scene-generation.md` are pending in Milestone 3.
  - **"Support documents"** — the docs that remain in `agents/`: `update-rules.md`, `workflows.md`, `canon.md`, `books.md`, `chapters.md`, `characters.md`, `storyboard-schema.md`, `voice.md`, `meta.md`, plus `agents/metaphor/` (the subagent prompt contracts and README). Make clear these are referenced *by* step workflows; they are not invoked by the dispatcher.
- Update `agents/workflows.md` if it references any of the moved files. Repoint at the new `agents/steps/` paths or call out the legacy reference if rewriting is out of scope. (`agents/workflows.md` is itself a candidate for retirement, but that is a Milestone 4-or-later decision; for this Sprint just keep its references current.)
- Update `agents/update-rules.md` cross-references the same way.
- If `agents/metaphor/` ends up containing only the three subagent prompt files plus `README.md`, leave it. If the README is no longer accurate after Task 7's edits, fix it. Do not delete the directory.
- Run the verification commands from the Definition of done:
  - `git grep "agents/storyboarding\|agents/agentic-drafting\|agents/compliance.md\|agents/prose-pass\|agents/line-pass\|agents/anti-ai\|agents/metaphor/metaphor-identify\|agents/metaphor/metaphor-apply"` should return nothing in tracked text.
  - `ls agents/steps/` should list the ten step files Task 1–10 produced.
  - Each step file should have a frontmatter block with the four required fields.
- Check the boxes for Milestone 2 tasks 7–14 in `ROADMAP.md`. Mark each completed task in this Sprint file as `[x]`.

**Done when.** `AGENTS.md` reflects the new layout, no live cross-references to legacy step paths remain, all ten step files are present and frontmatter-valid, and `ROADMAP.md` Milestone 2 tasks are checked.

---

## Out of scope for this Sprint

- Writing the bodies of `character_extraction` and `scene_generation` (Milestone 3).
- Renaming files to drop `xx-yy-` prefixes inside consuming projects (Milestone 4). This Sprint adopts the new path placeholder conventions for step files; the file-rename pass against real project repos is not in scope.
- Implementing the dispatcher (Milestone 5).
- Resolving the `agents/orchestrator.md` TODOs about canon invention and centralized human questions (deferred).
- Introducing new behaviors, checks, severity levels, or output formats in any step body. Body edits are limited to path conventions, dead cross-references, and internal consistency fixes the move forces.
- Retiring or rewriting `agents/workflows.md`, `agents/update-rules.md`, or other support docs beyond updating their cross-references.
- Deleting `agents/metaphor/` or relocating the three subagent prompt contracts. They stay where they are.
