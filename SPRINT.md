# Sprint 9 — Milestone 4: Versioned draft naming

This Sprint decouples prose-bearing draft filenames from the step that produced them. After this Sprint: `drafting` creates `draft-v01.md`; every prose-advancing step writes the next numbered `draft-vNN.md`; report-only and setup steps read `<latest-draft>` without incrementing it; side artifacts stay step-named; and the attempt records provenance in a manifest so later capture annotations and implementation agents can answer which draft version a fact came from.

This is still a documentation/prose-contract milestone. The implementation edits will be Markdown step bodies, support docs, templates, and examples. No runtime dispatcher code is required unless verification shows a script or template has a hard-coded prose filename that would leave the docs inconsistent.

## Background — what is and isn't wrong today

Established by inspection during planning; tasks should not re-derive this.

- **The canonical step order is fixed in `templates/pipeline-state.md`.** The current sequence is `drafting`, `compliance_report`, `compliance_fix`, `prose_pass`, `metaphor_identify`, `metaphor_fix`, `metaphor_apply`, `line_pass`, `anti_ai_report`, `anti_ai_fix` (`templates/pipeline-state.md:18-30`). M4 changes the prose artifact names those steps read/write; it does **not** reorder the step list.
- **`<latest-attempt>` already means highest-numbered attempt directory.** `agents/project-layouts.md:14` defines it as the highest-numbered `attemptNN` directory under the chapter's `drafts/`; drafting currently creates a new attempt at `agents/steps/drafting.md:35`. M4 adds `<latest-draft>` / `<next-draft>` inside that existing attempt, not a new attempt model.
- **Drafting currently creates `draft.md` and treats it as prose only.** Frontmatter outputs name `<chapter-folder>/drafts/<latest-attempt>/draft.md` (`agents/steps/drafting.md:9-11`), assembly writes that file (`agents/steps/drafting.md:39`, `:128`), and the output description says the combined draft contains story text only (`agents/steps/drafting.md:131`, `:179-182`). This is the main constraint against putting provenance YAML inside every draft file.
- **The prose chain is currently step-named and brittle.** `compliance_report` reads `draft.md` (`agents/steps/compliance-report.md:7-10`, `:23-24`); `compliance_fix` reads `draft.md` and writes `draft-compliance.md` (`agents/steps/compliance-fix.md:6-12`, `:31`, `:76-79`); `prose_pass` reads `draft-compliance.md` and writes `prose-pass.md` (`agents/steps/prose-pass.md:6-12`, `:40`, `:46-49`); metaphor identify/fix/apply are wired to `draft-compliance.md` and `draft-metaphor.md` (`agents/steps/metaphor-identify.md:6-10`, `agents/steps/metaphor-fix.md:6-12`, `agents/steps/metaphor-apply.md:6-10`, `:23-25`, `:97-99`); `line_pass` reads `draft-metaphor.md` and writes `draft-line.md` (`agents/steps/line-pass.md:6-12`, `:24-28`, `:178-180`); and anti-AI reads `draft-line.md` / writes `draft-anti-ai.md` (`agents/steps/anti-ai-report.md:6-10`, `agents/steps/anti-ai-fix.md:6-12`, `:24-29`, `:110-113`). This is exactly the coupling M4 removes.
- **Report-only steps already have durable side artifacts.** Compliance writes `reviewer-actions.md`, prose pass writes `prose-pass.md`, metaphor identify/fix write `metaphors.md`, and anti-AI report/fix write `anti-ai.md` (`agents/steps/compliance-report.md:103-105`, `agents/steps/prose-pass.md:46-49`, `agents/steps/metaphor-identify.md:99-101`, `agents/steps/metaphor-fix.md:62-64`, `agents/steps/anti-ai-report.md:143-145`, `agents/steps/anti-ai-fix.md:110-113`). These remain step-named audit/review files; only prose-bearing drafts become versioned.
- **`prose_pass` is an intentional report-only gap until M5.** It currently says the human applies its recommendations manually before `metaphor_identify` (`agents/steps/prose-pass.md:34`, `:60-64`). M4 should not invent the `prose_fix` apply step; M5 owns that. For M4, `prose_pass` reads `<latest-draft>` and writes `prose-pass.md`, and `metaphor_identify` still reads `<latest-draft>` after any human/manual edits. M5 will make that transition explicit with a new prose-advancing step.
- **The orchestrator contract is file-state based.** Step frontmatter declares inputs/outputs (`agents/orchestrator.md:15-36`), steps read/write only declared files (`agents/orchestrator.md:38-44`), and marker advancement is the step body's final action (`agents/orchestrator.md:68`). M4 therefore belongs in step contracts and docs, not in hidden runtime state.
- **The chapter docs and layouts still teach `draft.md` as the durable draft.** `agents/chapters.md:54-61` and `agents/project-layouts.md:44-49`, `:88-100`, `:141-156` show `draft.md` under attempts. These must be swept so consuming projects learn the versioned convention.

## Definition of done

The Sprint is complete when:

1. ROADMAP.md tasks M4.1-M4.5 are checked.
2. `<latest-draft>` and `<next-draft>` are defined in one source-of-truth support doc: `<latest-draft>` is the highest-numbered `draft-vNN.md` in the current `<latest-attempt>`; `<next-draft>` is one greater than that; drafting creates `draft-v01.md` in its newly created attempt.
3. Prose-advancing steps write `<next-draft>`: `drafting`, `compliance_fix`, `metaphor_apply`, `line_pass`, and `anti_ai_fix`. M5 will add `prose_fix`; do not add it in this Sprint.
4. Report/setup steps read `<latest-draft>` without incrementing it: `compliance_report`, `prose_pass`, `metaphor_identify`, `metaphor_fix`, and `anti_ai_report`.
5. Side artifacts stay step-named: `notes.md`, `reviewer-actions.md`, `prose-pass.md`, `metaphors.md`, and `anti-ai.md` are not renamed to versioned draft filenames.
6. An attempt-level provenance manifest is specified and all prose-advancing/report-only steps know when to append to it. It records each draft version, producer step, input draft(s), side artifacts consulted/written, and any judgment-log pointer. It is the source M3 capture annotations can reference once they need a draft-version stamp.
7. The report->fix adjacency invariant is documented: a paired report/fix must consume the same `<latest-draft>` unless the fix itself is the step that increments it. No unrelated prose-advancing step may sit between a report and its paired fix/apply.
8. Docs and examples that hard-code `draft.md`, `draft-compliance.md`, `draft-metaphor.md`, `draft-line.md`, or `draft-anti-ai.md` as the current prose are swept or explicitly marked legacy/background.
9. The canonical state list remains the same step order unless a named task says otherwise; M4 is a naming/provenance change, not a pipeline-order change.

## Conventions adopted by this Sprint

Locked at the start so individual tasks don't rediscover them.

- **Attempt-level manifest, not per-draft frontmatter.** `drafting.md` says assembled prose is story text only (`agents/steps/drafting.md:131`), and downstream apply steps preserve prose plus block-comment logs. A manifest keeps provenance machine-readable without contaminating manuscript files.
- **Only prose-bearing files are versioned.** Review reports, notes, apply logs embedded in side artifacts, and working files keep their semantic names. This preserves existing human review habits and avoids turning every audit artifact into a draft version.
- **`<latest-draft>` is resolved at step start.** A report step reads the highest existing `draft-vNN.md` and does not create a new one. A fix/apply step reads the report's target draft and writes the next version.
- **Paired report/fix inputs are stable.** A fix step consumes the same draft the report reviewed; if `<latest-draft>` has advanced since the report was produced, that is a blocker or stale-report condition, not permission to apply old annotations to new prose.
- **M4 does not add `prose_fix`.** The prose-pass orphan is recognized in ROADMAP M5. M4 makes the naming convention ready for that step, but does not implement the step or solve its apply strategy.

---

## Tasks

### Task 1 — Define draft-version placeholders and manifest contract [x]

**Goal.** Establish the naming/provenance vocabulary every later task uses. Closes **M4.1** and the core of **M4.3**.

**Requirements.**

- Add a single source-of-truth definition for `<latest-draft>` and `<next-draft>` in the path-resolution docs, near the existing `<latest-attempt>` definition in `agents/project-layouts.md`.
- Define `<latest-draft>` as the highest-numbered `draft-vNN.md` in the current `<latest-attempt>` directory. Define `<next-draft>` as the next zero-padded number after `<latest-draft>`; if none exists in a newly created attempt, drafting writes `draft-v01.md`.
- Define an attempt-level manifest file, recommended name: `<chapter-folder>/drafts/<latest-attempt>/draft-manifest.md`. The manifest records, at minimum, per draft version:
  - draft file (`draft-v01.md`, `draft-v02.md`, etc.)
  - produced_by step
  - read_from draft version(s)
  - side artifacts consulted or updated (`reviewer-actions.md`, `metaphors.md`, `anti-ai.md`, etc.)
  - short note / log pointer when the producing step already has an apply log
- State that the manifest, not frontmatter inside draft files, is the provenance source because the prose files remain manuscript text.
- Cross-reference the manifest from the M3 capture/provenance wording if needed so capture annotations can later cite a draft version without embedding provenance in canon writes prematurely.

**Done when.** `<latest-draft>`, `<next-draft>`, and `draft-manifest.md` are defined once; later tasks can update step files by reference rather than re-explaining the convention.

---

### Task 2 — Convert drafting to produce `draft-v01.md` and initialize provenance [x]

**Goal.** Make the first prose output versioned from birth. Closes the drafting part of **M4.1-M4.3**.

**Requirements.**

- In `agents/steps/drafting.md`, change frontmatter outputs from `draft.md` to `draft-v01.md` plus `notes.md` and `draft-manifest.md`.
- Update coordinator responsibility step 7 and Assembly rules so assembly writes `<chapter-folder>/drafts/<latest-attempt>/draft-v01.md`, not `draft.md`.
- Preserve the existing invariant that the assembled prose file contains story text only. Do not add YAML frontmatter or planning notes to `draft-v01.md`.
- Initialize `draft-manifest.md` during the completed assembly path with an entry for `draft-v01.md`: `produced_by: drafting`, `read_from: []`, storyboard inputs, and a pointer to `notes.md` for run details.
- Update fragment deletion language so `sceneNN.md` content is folded into `draft-v01.md`, while `sceneNN-notes.md` content is folded into `notes.md`.
- Update output descriptions and open-question examples that still say `draft.md`.

**Done when.** Drafting creates an attempt whose durable prose is `draft-v01.md`, whose run record is `notes.md`, and whose provenance index is `draft-manifest.md`; no prose-only invariant is broken.

---

### Task 3 — Convert report-only/read-only steps to `<latest-draft>` [x]

**Goal.** Make every non-prose-writing step follow the latest version without minting one. Closes the read-only half of **M4.2**.

**Requirements.**

- Update these step frontmatters and body text to read `<chapter-folder>/drafts/<latest-attempt>/<latest-draft>` instead of a step-named prose file:
  - `agents/steps/compliance-report.md`
  - `agents/steps/prose-pass.md`
  - `agents/steps/metaphor-identify.md`
  - `agents/steps/metaphor-fix.md`
  - `agents/steps/anti-ai-report.md`
- Preserve each step's side-artifact output name: `reviewer-actions.md`, `prose-pass.md`, `metaphors.md`, and `anti-ai.md`.
- For report files that gate later fixes (`reviewer-actions.md`, `metaphors.md`, `anti-ai.md`), require the report to record the draft version it reviewed, either in a header or a manifest-linked metadata line. The paired fix/apply task must use that recorded version, not blindly apply to a newer draft.
- In `prose_pass`, keep the report-only behavior and explicitly say M5's future `prose_fix` will be the prose-advancing consumer; until then, any manual prose application must result in a new draft version recorded in the manifest or the pipeline should not advance as if prose was applied.

**Done when.** Report-only steps read the current version and do not create one; their reports carry enough draft-version identity for downstream apply/fix steps to avoid stale annotations.

---

### Task 4 — Convert prose-advancing fix/apply steps to `<next-draft>` [x]

**Goal.** Make every current prose-writing step produce a numbered draft version. Closes the write half of **M4.2** and most of **M4.3**.

**Requirements.**

- Update these step frontmatters, Inputs, Behavior, Outputs, and open-question handling:
  - `agents/steps/compliance-fix.md`: read the draft version recorded by `reviewer-actions.md`; write `<next-draft>`.
  - `agents/steps/metaphor-apply.md`: read the draft version recorded by `metaphors.md`; write `<next-draft>`.
  - `agents/steps/line-pass.md`: read `<latest-draft>` at step start; write `<next-draft>` chunk-by-chunk; when it needs preceding context from already-finalized output, read from the in-progress `<next-draft>` rather than a hard-coded `draft-line.md`.
  - `agents/steps/anti-ai-fix.md`: read the draft version recorded by `anti-ai.md`; write `<next-draft>`.
- Remove step-named prose outputs from these steps (`draft-compliance.md`, `draft-metaphor.md`, `draft-line.md`, `draft-anti-ai.md`) except where mentioned as legacy examples.
- Append/update `draft-manifest.md` in each prose-advancing step with `produced_by`, `read_from`, side artifacts used, and log pointer. Existing block-comment apply logs may remain inside the produced prose draft where the step already requires them, but the manifest must identify which draft version they live in.
- Preserve each step's existing behavioral scope: compliance and anti-AI fixes remain surgical; metaphor apply only applies selected variants; line pass remains chunked and figuratively inert.

**Done when.** Every prose-changing step writes the next `draft-vNN.md`, records the provenance entry, and no longer depends on semantic draft filenames to identify current prose.

---

### Task 5 — Document report->fix adjacency and stale-report handling [x]

**Goal.** Prevent annotations from being applied to the wrong draft version once drafts are numbered. Closes **M4.4**.

**Requirements.**

- Add the report->fix adjacency invariant to `agents/orchestrator.md` or the path/provenance section in `agents/project-layouts.md`, then reference it from the affected step bodies rather than restating it in full everywhere.
- State the invariant precisely: no prose-advancing step may run between a report and its paired fix/apply unless that report is regenerated against the new `<latest-draft>`.
- Apply the invariant to the three current pairs:
  - `compliance_report` -> `compliance_fix`
  - `metaphor_identify` / `metaphor_fix` -> `metaphor_apply`
  - `anti_ai_report` -> `anti_ai_fix`
- Define stale-report handling: if a fix/apply step sees that its report references a draft version that is not the expected input version for that pair, it appends a blocker to project-root `open-questions.md` and exits without advancing the marker. Do not silently apply old annotations to a newer draft.
- Mention `prose_pass` separately: until M5 adds `prose_fix`, it is advisory and does not have a paired fixer in this Sprint.

**Done when.** The invariant is documented once, referenced where needed, and each affected fix/apply step knows to block on stale annotations.

---

### Task 6 — Sweep docs, examples, catalog text, and verification invariants [x]

**Goal.** Bring the visible project docs into the versioned-draft model and close the Sprint cleanly. Closes **M4.5**.

**Requirements.**

- Update support docs and examples that teach hard-coded prose names, including at least:
  - `agents/chapters.md`
  - `agents/project-layouts.md`
  - `agents/workflows.md`
  - `agents/orchestrator.md` examples/frontmatter snippets if they show `draft.md`
  - `AGENTS.md` step catalog entries that name step-specific prose outputs
  - `templates/step-workflow.md` if its placeholder path is misleading
- Search for hard-coded prose filenames and decide each hit:
  - replace with `<latest-draft>` / `<next-draft>` / `draft-vNN.md`, or
  - mark as a deliberate legacy/background reference if it describes old behavior.
- Required verification greps:
  - `git grep -n "draft.md\|draft-compliance.md\|draft-metaphor.md\|draft-line.md\|draft-anti-ai.md" -- '*.md'`
  - `git grep -n "<latest-draft>\|<next-draft>\|draft-manifest.md" -- '*.md'`
  - `git grep -n "draft-v01.md\|draft-vNN.md" -- '*.md'`
- Confirm side-artifact names remain stable and are not accidentally versioned: `notes.md`, `reviewer-actions.md`, `prose-pass.md`, `metaphors.md`, and `anti-ai.md`.
- Update ROADMAP.md M4.1-M4.5 to `[x]` only after Tasks 1-6 pass verification. Add a short M4 note recording the manifest choice and the fact that `prose_fix` remains deferred to M5.
- Mark this SPRINT.md's tasks `[x]` only after the implementation work is complete.

**Done when.** The repo no longer teaches step-named prose drafts as the current model; verification greps have been reviewed; ROADMAP and SPRINT checkboxes reflect the completed implementation.

---

## Out of scope for this Sprint

- **Adding `prose_fix`.** M5 owns the prose-pass annotation grammar, apply strategy, and new pipeline step.
- **Reordering the canonical step list.** M4 changes artifact naming and provenance; it does not move pipeline stages.
- **Directional redo/backtracking.** M7 owns archive-on-redo, downstream staleness beyond paired report/fix adjacency, and back/forward dispatcher semantics.
- **Executable enforcement of draft manifests.** This Sprint documents the contract. Scripts/tests may be updated only if existing verification or templates are already hard-coded to old names.
- **Changing story text format.** Draft files remain prose-bearing manuscript files; provenance lives beside them, not inside them.
