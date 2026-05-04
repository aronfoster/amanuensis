# Sprint 1 — Milestone 1: Foundations [x] Complete

This Sprint delivers the contract every step workflow must satisfy and the project structure every consuming repository must have. After this Sprint, Amanuensis has the artifacts a developer needs to refactor existing workflows (Milestone 2) and write new ones (Milestone 3) against a stable contract.

## Definition of done

The Sprint is complete when:

1. Every Milestone 1 task in `ROADMAP.md` is checked.
2. `agents/orchestrator.md` no longer contains any "TBD in roadmap Milestone 1" markers.
3. A new developer can read `AGENTS.md` once and locate (a) the orchestrator contract, (b) the project layout rules, (c) the template that authors a new step.
4. The repository contains exactly one templates directory (`templates/`) at the repo root.
5. `ROADMAP.md` paths under Milestone 1 reference `templates/`, not `agents/templates/`.

---

## Tasks

### Task 1 — Consolidate templates directory and update ROADMAP paths [x]

**Goal.** Eliminate the `agents/templates/` directory so all templates live at repo-root `templates/`. Update the roadmap so its Milestone 1 task paths match reality.

**Requirements.**
- Move `agents/templates/knowledge-book.md` to `templates/knowledge-book.md`.
- Remove the now-empty `agents/templates/` directory.
- Update `ROADMAP.md` Milestone 1 tasks 2, 3, and 4 to use `templates/` instead of `agents/templates/`.
- Search the repo for any other references to `agents/templates/` and update them. (Likely candidates: `AGENTS.md`, `README.md`, any cross-references inside `agents/*.md`.)
- Do not modify the contents of `knowledge-book.md` itself; this is a move, not a rewrite.

**Done when.** `agents/templates/` does not exist. Every `agents/templates/` reference in tracked text has been updated or removed. `git grep "agents/templates"` returns nothing.

---

### Task 2 — Resolve step file path convention in `agents/orchestrator.md` [x]

**Goal.** Replace the "TBD in roadmap Milestone 1" language in `agents/orchestrator.md` with the locked convention.

**Requirements.**
- The convention is: `step_id` (snake_case) maps to `amanuensis/agents/steps/<step-id-with-dashes>.md`. Example: `metaphor_identify` → `amanuensis/agents/steps/metaphor-identify.md`.
- Update both occurrences in `agents/orchestrator.md`:
  - The `## Components` section paragraph that refers to "existing workflow files" and "new workflow files added in roadmap Phase 3."
  - The `## Dispatcher behavior` step 2 ("Resolves the step workflow file path from `step_id`").
- Note in `agents/orchestrator.md` that existing top-level workflow files (e.g. `agents/storyboarding.md`, `agents/metaphor/metaphor-identify.md`) will be relocated to `agents/steps/` during Milestone 2. Until then, the dispatcher cannot resolve them — this is acceptable because the dispatcher is not implemented yet (Milestone 5).
- The `agents/steps/` directory does not need to be created in this Sprint. Step files arrive in Milestones 2 and 3.

**Done when.** `agents/orchestrator.md` contains a clear, unambiguous statement of the path convention with no remaining "TBD" markers about step path resolution.

---

### Task 3 — Write `templates/step-workflow.md` [x]

**Goal.** Provide the canonical template a developer copies when authoring a new step workflow file. Anyone refactoring an existing workflow (Milestone 2) or writing a new one (Milestone 3) should start from this template.

**Requirements.**
- Lives at `templates/step-workflow.md`.
- Begins with the required YAML frontmatter block, with placeholders and an inline comment explaining each field. Required fields are exactly those defined in `agents/orchestrator.md` § "Step workflow contract": `step_id`, `review_required`, `inputs`, `outputs`. Do not invent additional fields.
- The body provides skeletal section headings the author fills in:
  - `# <Step Name>` (human-readable title)
  - `## Purpose` — one-paragraph description of what the step accomplishes.
  - `## Inputs` — narrative description of what each input file is and what the step expects from it. Mirrors the frontmatter `inputs` list.
  - `## Behavior` — the step body. The bulk of the document. Bullets, prose, examples — author's choice.
  - `## Outputs` — narrative description of each output, including the expected shape of the artifact.
  - `## Open questions handling` — explicit guidance on what the step does when blocked. Default text should remind the author to write to project-root `open-questions.md` and exit without advancing the marker.
- Include a one-line pointer at the top of the body: "See `agents/orchestrator.md` for the step workflow contract."
- The template must be valid as-is — i.e., a developer copying it and only filling in the placeholders should produce a contract-conforming step file.
- Use the existing workflow files (e.g. `agents/storyboarding.md`, `agents/drafting.md`) as references for tone and section depth. Do not copy their content; the template should be empty of project-specific details.

**Done when.** `templates/step-workflow.md` exists, is referenced from `AGENTS.md` (Task 6), and a developer can produce a Milestone 2-conforming step file from it without consulting any other document beyond `agents/orchestrator.md`.

---

### Task 4 — Write `templates/amanuensis-project.yaml` [x]

**Goal.** Provide the template every consuming repository copies to its project root to declare project-level configuration the dispatcher needs.

**Requirements.**
- Lives at `templates/amanuensis-project.yaml`.
- Contains exactly one required field: `project_type`, with a comment listing the three valid values (`short_story`, `book`, `series`) and pointing the reader to `agents/project-layouts.md` for the implications of each choice.
- Include a commented-out reservation block noting that additional fields (e.g., current chapter pointer, pipeline overrides) are anticipated in later milestones but are intentionally not part of the MVP. Do not include the field names themselves — the goal is to communicate "more may come" without committing to a schema.
- The file must be a valid YAML document as written (i.e., a developer can copy it directly to a project root and edit only the value of `project_type`).
- Place the file in the project root convention: when consumed, this file is copied to `<project-root>/amanuensis-project.yaml`. Document this at the top of the file as a comment.

**Done when.** `templates/amanuensis-project.yaml` exists, parses as YAML, and is referenced from both `agents/orchestrator.md` (where `project_type` is mentioned) and `AGENTS.md`.

---

### Task 5 — Write `agents/project-layouts.md` [x]

**Goal.** Single canonical document describing how project folder structure differs by `project_type`. The dispatcher and step bodies that resolve path placeholders should be able to point at this document.

**Requirements.**
- Lives at `agents/project-layouts.md`.
- Covers all three project types: `short_story`, `book`, `series`.
- For each project type, includes:
  - A concrete example folder tree (use the existing `templates/story-repo-layout.md` for the `book` / `series` baseline; add `short_story` as new content).
  - The resolution rule for the placeholders used in step workflow frontmatter: `<chapter-folder>`, `<book-folder>`, `<latest-attempt>`. The rules already partially live in `agents/orchestrator.md` § "Path resolution by project type" — move them here and have the orchestrator link to this document instead. Do not duplicate.
  - A statement of where `open-questions.md` lives. The answer is the same for all project types: at the project root. State this once in a shared "Conventions across all project types" section, not per type.
- States the rule that **folder paths replace filename prefixes**. (No more `01-01-summary.md`; instead `<book-folder>/<chapter-folder>/summary.md`.) The actual file renames happen in Milestone 4 — this document declares the rule, it does not perform the renames.
- For `<latest-attempt>` resolution, document the rule already in `agents/orchestrator.md`: "the highest-numbered `attemptNN` directory under the chapter's `drafts/`; if none exists and the step expects one, the step creates `attempt01`." Show this in the example tree (e.g., `drafts/attempt01/`, `drafts/attempt02/`).
- After this document is written, update `agents/orchestrator.md` to remove its "Path resolution by project type" section body and replace it with a one-sentence pointer: "See `agents/project-layouts.md`." Keep the section heading so cross-references don't break.
- Decide whether `templates/story-repo-layout.md` is still useful given this new document. If its content is fully subsumed, delete it and update any references. If it still serves a different purpose (e.g., a quick-start tree for a new repo), keep it and link to it from `project-layouts.md`. Document the decision briefly in the commit message.

**Done when.** A developer trying to figure out where to read or write a file in a `short_story` / `book` / `series` project can answer the question by reading `agents/project-layouts.md` alone.

---

### Task 6 — Reorganize root `AGENTS.md` around the orchestrator model [x]

**Goal.** Make `AGENTS.md` the entry point a new developer (or new agent) reads first. After reading it once, they should know the orchestrator exists, where the contract is documented, where templates live, and what project layouts are available. Older per-document references are kept but demoted.

**Requirements.**
- Lead with a short "How Amanuensis works" section (3–6 sentences) that summarizes the orchestrator-driven pipeline at a high level: dispatcher reads state file, runs one step, exits; state lives in files; humans review between steps.
- Add a "Core documents" section linking to (in order):
  - `agents/orchestrator.md` — orchestrator contract and dispatcher behavior.
  - `agents/project-layouts.md` — folder conventions per project type.
  - `templates/step-workflow.md` — template for new step files.
  - `templates/pipeline-state.md` — template state file.
  - `templates/amanuensis-project.yaml` — project-level config template.
  - `templates/project-AGENTS.md` — adapter template for consuming repositories.
- Demote the existing per-file index (`update-rules.md`, `workflows.md`, `canon.md`, `books.md`, `chapters.md`, `characters.md`, `storyboarding.md`, `drafting.md`, `compliance.md`, `prose-pass.md`, `anti-ai.md`, `metaphor/`, etc.) into a section labeled clearly as legacy or in-flight, e.g., "Legacy workflow documents (to be refactored under the step contract during Milestone 2)." Do not delete these references — they're still authoritative until Milestone 2 finishes.
- Preserve the existing "Repository Boundary" section verbatim or with only stylistic edits.
- Preserve the existing "Next Task Queueing" section verbatim. Sprint workflow guidance there is still correct.
- Do not modify the per-file legacy documents themselves. This task only edits `AGENTS.md`.

**Done when.** A reader of `AGENTS.md` who has never seen Amanuensis before learns about the orchestrator and templates within the first screen of text, and can find the legacy documents further down without confusion.

---

## Out of scope for this Sprint

- Creating `agents/steps/` or moving any existing workflow files into it (Milestone 2).
- Renaming files to drop `xx-yy-` prefixes (Milestone 4).
- Implementing the dispatcher (Milestone 5).
- Resolving the orchestrator's TODOs about canon invention or centralized human questions (deferred).
- Any change to the legacy workflow documents (`storyboarding.md`, `drafting.md`, etc.) beyond what's required to fix path references.
