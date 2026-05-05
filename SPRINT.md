# Sprint 3 — Milestone 3: Build the missing step bodies

This Sprint writes the two step bodies missing from the pipeline (`character_extraction` and `scene_generation`), introduces the supporting profile template they reference, and repositions `AGENTS.md` so its audience — agents maintaining the Amanuensis tooling repo — is unambiguous. After this Sprint, every entry in `templates/pipeline-state.md` resolves to a real file in `agents/steps/`, and a fresh consuming project can run the pipeline from the very first step.

## Definition of done

The Sprint is complete when:

1. Every Milestone 3 task in `ROADMAP.md` (15, 16, 17) is checked.
2. `agents/steps/character-extraction.md` and `agents/steps/scene-generation.md` exist with valid YAML frontmatter (`step_id`, `review_required`, `inputs`, `outputs`) and a body conforming to the step contract in `agents/orchestrator.md`.
3. ~~`templates/profile.md` exists.~~
4. `AGENTS.md` clearly frames this repository as Amanuensis tooling consumed as a submodule by story projects. Agents reading it understand they are maintaining tooling, not writing fiction. Story-author-facing instructions are explicitly delegated to each consuming project's local `AGENTS.md` (built from `templates/project-AGENTS.md`).
5. Cross-references in `agents/workflows.md` and any other support doc that mentions these two new steps point at the new `agents/steps/` paths.
6. `git grep "agents/character-extraction\|agents/scene-generation"` returns nothing in tracked text outside of historical commit messages — i.e., nobody references the legacy roadmap path.

## Conventions adopted by this Sprint

These choices are locked at the start of the Sprint so individual tasks don't rediscover them.

**Step file location.** `agents/steps/<step-id-with-dashes>.md`, per the convention locked in Sprint 2. ROADMAP.md tasks 15–16 use the older path (`agents/character-extraction.md`); ignore that wording — the new locations are `agents/steps/character-extraction.md` and `agents/steps/scene-generation.md`.

**Project-type scope for MVP.** Both step bodies must be written so they work for `short_story` projects end-to-end. For `book` and `series`, write the body so the structure is compatible (path placeholders, frontmatter, behavior shape) but treat "which chapter is current?" as the deferred open question already noted in `agents/orchestrator.md`. A book/series project should be able to invoke these steps once the dispatcher solves chapter selection in a later milestone — but no Sprint 3 task needs to *prove* that path.

**Story plan placeholder.** Both step bodies read a project-specific planning file. Use a new placeholder `<story-plan>` resolved per project_type with sensible defaults, overridable in the consuming project's local `AGENTS.md`:

- `short_story` default: `plot/summary.md`
- `book` default: `plot/<book-folder>/overview.md`
- `series` default: `plot/<book-folder>/overview.md` (per book in flight)

Document the placeholder and its resolution rules in `agents/project-layouts.md` as part of the step body that introduces it (or in a dedicated short edit if the developer prefers — see Task 1).

**Open-questions entry format.** Steps that block or surface unresolved details append entries to project-root `open-questions.md` using a light, consistent shape. Each entry carries an importance marker — not a date. Suggested shape:

```markdown
## <step_id>: <one-line subject>

- importance: critical | important | minor
- blocker: <what is unresolved, in one or two sentences>
- needed: <what input or decision would unblock this>
```

Importance values are fixed at three levels: `critical` (pipeline cannot proceed safely without an answer), `important` (proceed-but-flag — the step did its best with assumptions), `minor` (cosmetic or low-risk gap). Both new steps use this format. Earlier steps in the pipeline are *not* retrofitted in this Sprint.

**Idempotency.** Following the convention used by every other step: a step overwrites whatever sits at its declared output paths when re-run. Humans who want to preserve prior output rename or move it before re-running the step. This applies equally to character folders (character_extraction) and scene-list files (scene_generation).

**Stub characters.** When the story plan names a character role without a settled name (e.g., "the protagonist's mother"), the step creates a stub folder using a generated snake_case `character_id`, populates `profile.md` with `status: stub`, leaves unknown fields explicitly blank, and appends an `important`-level open question requesting a canonical name and missing details.

**Canon as auxiliary input.** Both step bodies read `canon/**/*.md` in addition to the story plan, so extracted characters and generated scenes are grounded in world rules and don't silently invent canon. This is consistent with the priority order in `agents/canon.md`.

---

## Tasks

### ~~Task 1 — `character_extraction` step~~ Done

**Goal.** Write `agents/steps/character-extraction.md` as a contract-conforming step that reads the project's story plan plus canon and bootstraps the minimum character folders described in `agents/characters.md`.

**Requirements.**

- Frontmatter:
  - `step_id: character_extraction`
  - `review_required: true`
  - `inputs:` — `<story-plan>`, `canon/**/*.md`
  - `outputs:` — `characters/<character-id>/profile.md`, `characters/<character-id>/knowledge/baseline.md`, `characters/<character-id>/knowledge/book-N.md` (one per book the character appears in, for `book`/`series` projects), and appended entries in project-root `open-questions.md`.
- Body responsibilities:
  1. Read the story plan and all canon files.
  2. Identify every character the plan references — named characters and stub roles alike.
  3. For each character, create the folder at `characters/<character-id>/` and write the **minimum** required files per `agents/characters.md`: `profile.md` plus `knowledge/baseline.md`. For `book` and `series` projects, also create `knowledge/book-N.md` scaffolds for each book the character appears in. Do **not** create `timeline.md` or `relationships.md` in this step.
  4. Populate `profile.md` from `templates/profile.md` (created in Task 3). Fill fields the story plan or canon support; leave unknown fields explicitly blank rather than invented. For unnamed roles, set `status: stub` and use a descriptive snake_case `character_id` (e.g., `protagonist_mother`).
  5. Populate `knowledge/baseline.md` with what the character plausibly knows before the story begins, drawn from canon and plan context. Leave `book-N.md` files as empty scaffolds — they fill during the scene knowledge update workflow, not here.
  6. Append open-questions entries (using the format under "Conventions") for: missing canonical names of stub characters (`important`), unresolvable contradictions between plan and canon (`critical`), and notable blank profile fields the plan implies but does not specify (`minor`).
- Overwrite behavior: the step overwrites any existing files at the output paths. Humans preserve prior work by renaming folders before re-running.
- Add the standard "Open questions handling" section from `templates/step-workflow.md`. Note that for this step, *unanswered* details are normal — they are appended via the format above and the step still completes. Open-questions-handling-with-exit applies only when the *story plan itself* is missing or unreadable.
- If the developer is introducing the `<story-plan>` placeholder for the first time, also extend `agents/project-layouts.md` with the resolution rules listed in this Sprint's Conventions section. (Task 2 also uses the placeholder; whichever task lands first does the project-layouts edit.)

**Done when.** `agents/steps/character-extraction.md` exists with valid frontmatter, the body covers identification → folder creation → file population → open-questions, and a fresh `short_story` project with a populated `plot/summary.md` and `canon/` would produce a usable `characters/` tree on first run.

---

### ~~Task 2 — `scene_generation` step~~ Done

**Goal.** Write `agents/steps/scene-generation.md` as a contract-conforming step that reads the story plan, character files, and canon, and produces the chapter's `scene-list.md`.

**Requirements.**

- Frontmatter:
  - `step_id: scene_generation`
  - `review_required: true`
  - `inputs:` — `<story-plan>`, `characters/<character-id>/profile.md`, `characters/<character-id>/knowledge/baseline.md`, `canon/**/*.md`
  - `outputs:` — `<chapter-folder>/scene-list.md`, plus appended entries in project-root `open-questions.md`.
- Body responsibilities:
  1. Read the story plan, all character profiles and baseline knowledge, and canon.
  2. Produce a scene-by-scene plan covering the chapter (or, for `short_story`, the entire story).
  3. Write the result to `<chapter-folder>/scene-list.md`. For `short_story` this resolves to `plot/scene-list.md`.
  4. Append open-questions entries for any plan ambiguity that forced a guess (per the importance-tagged format in Conventions).
- Output shape: `scene-list.md` is YAML frontmatter followed by one section per scene. The schema is informal but the body must specify it:
  - **Frontmatter fields** (required): `chapter_id` (e.g., `chapter01`, or `story` for short_story), `book_id` if applicable, `pov_default` (the chapter's primary POV character if there is one), and `scene_count`.
  - **Per-scene section** (one per scene): a heading like `## scene01`, followed by short fields covering POV, location, conflict, emotional turn, what is revealed or concealed, consequences for downstream scenes, and links to any character knowledge files or canon files the scene depends on. Match the field set described informally in `agents/chapters.md`. Keep entries terse — this is scene-level planning, not storyboarding.
- MVP scope: the step body is written assuming `short_story` is the project_type the developer can fully verify. The body must still reference `<chapter-folder>` correctly so it composes with `book` and `series` once chapter selection is solved; the developer does not need to test those paths.
- Overwrite behavior: the step overwrites `<chapter-folder>/scene-list.md` if it already exists.
- Add the standard "Open questions handling" section. As with character_extraction, normal ambiguities are logged in `open-questions.md` and the step completes; exit-without-advancing is reserved for an unreadable story plan or character set.
- Cross-reference: link to `agents/chapters.md` for the field intent of a scene-list entry and to `agents/steps/storyboarding.md` as the downstream consumer that reads the produced `scene-list.md`.

**Done when.** `agents/steps/scene-generation.md` exists with valid frontmatter, the body specifies the frontmatter and per-scene section format, and a `short_story` project that has just completed `character_extraction` would produce a valid `plot/scene-list.md` on first run.

---

### ~~Task 3 — `templates/profile.md` stub~~ Done

**Goal.** Create the file `templates/profile.md` as an empty placeholder. The human will paste contents from a separate project via the GitHub web UI; this Sprint just makes the file exist so Task 1 can reference it.

**Requirements.**

- Create `templates/profile.md` containing only a single placeholder comment line (e.g., `<!-- profile template contents pending; see PR comment -->`) so the file is non-empty and tracked.
- Do not invent template contents. The human is supplying them.
- Task 1's body references this file as the template `profile.md` is populated from. Make sure that reference resolves to the file this task creates.

**Done when.** `templates/profile.md` exists, is tracked by git, and contains only a placeholder marker the human can replace.

---

### ~~Task 4 — Reposition `AGENTS.md` for the tooling-repo audience~~ Done

**Goal.** Rewrite `AGENTS.md` so its audience is unambiguous: agents working in *this* repository are maintaining the Amanuensis tooling, not writing fiction. The current document mixes "what Amanuensis is" with "how to use Amanuensis to write" — that ambiguity is what this task removes.

**Requirements.**

- Open the document with a clear framing block. State explicitly:
  - This repository is the Amanuensis tooling. It is consumed as a git submodule by story-writing projects.
  - The actual prose, character files, scene lists, drafts, and canon live in *those* consuming projects, not here.
  - An agent invoked inside this repository is doing one of: editing step workflow files, editing support documents, editing templates, editing the orchestrator contract, or otherwise maintaining the framework. It is not writing a story.
  - Story-writing projects each have their own local `AGENTS.md` (the adapter), built from `templates/project-AGENTS.md`. That file is where story-author-facing instructions live. This `AGENTS.md` deliberately does not host them.
- Keep the existing index of step workflows and support documents, but reframe its purpose: it is the catalog of files this repo *provides to* consuming projects, not a how-to for writing prose. One sentence at the top of each section is enough to make this clear.
- Keep the "Next Task Queueing" prompts (PM New Sprint, Developer Step for Sprint Task, PM Sprint Closeout). Those prompts are about maintaining this repo and belong here. If any of them currently read as if they could be invoked in a story project, tighten the wording.
- Move or expand the "Repository Boundary" section so its rule ("Amanuensis is tooling, not story canon") sits near the top of the document, not at the end. It is the most important rule for an agent reading this file.
- The existing `templates/project-AGENTS.md` is the canonical adapter starting point for consuming projects. Mention it explicitly and link to it from this file's framing block.
- Do not introduce new sections beyond what the framing requires. Keep the file scannable.

**Done when.** A reader who has never seen this repo before, opening `AGENTS.md` cold, can answer in their first read: (a) what this repo is, (b) what it is *not*, (c) where prose-writing instructions live (in consuming projects), (d) what kind of work an agent is expected to do here.

---

### ~~Task 5 — Sprint wrap-up: cross-references, indexing, verification~~ Done

**Goal.** After Tasks 1–4 land, update the support documents that index or cross-reference step files, verify the Definition of done, and check the relevant ROADMAP boxes.

**Requirements.**

- Update `AGENTS.md`'s step-workflow index (already touched in Task 4) so `character-extraction.md` and `scene-generation.md` appear with one-line descriptions and the "pending in Milestone 3" note is removed.
- Update `agents/workflows.md`. The current "Workflow: chapter planning" section describes scene-list creation as a manual workflow; add a one-line pointer to `agents/steps/scene-generation.md` as the step that automates this for projects on the orchestrator. Likewise, if any support doc references character extraction informally, point at `agents/steps/character-extraction.md`.
- Update `templates/project-AGENTS.md` if useful to reference the two new step files in its "Where To Look" section, so consuming projects bootstrapped from the template see them.
- Confirm `templates/pipeline-state.md` already lists `character_extraction` and `scene_generation` as the first two steps; if so, no edit needed. (Per Sprint 2's leftovers, it should already be correct.)
- Run the verification commands from the Definition of done:
  - `ls agents/steps/` should now list twelve step files (the ten from Sprint 2 plus the two from this Sprint).
  - Each new step file should have a frontmatter block with the four required fields.
  - `git grep "agents/character-extraction\|agents/scene-generation"` should return nothing in tracked text. (References should use `agents/steps/character-extraction.md` / `agents/steps/scene-generation.md`.)
- Check ROADMAP.md tasks 15, 16, and 17 as complete.
- Mark each completed task in this Sprint file as `[x]`.

**Done when.** All cross-references point at the new step paths, `AGENTS.md` and `templates/project-AGENTS.md` index the new steps, ROADMAP.md Milestone 3 tasks are checked, and the verification commands all pass.

---

## Out of scope for this Sprint

- Solving "which chapter is the current chapter" for `book` and `series` projects. Both new step bodies are written so they will compose correctly once that question is solved, but the dispatcher mechanism for chapter selection is deferred.
- Implementing the dispatcher (Milestone 5).
- Renaming files to drop `xx-yy-` prefixes inside consuming projects (Milestone 4).
- Retrofitting earlier step bodies to the new open-questions importance format. Earlier steps continue to use whatever convention they already had; the new format applies only to the two steps written in this Sprint.
- Filling `templates/profile.md` with finalized content. The Sprint creates the file; the human supplies contents via GitHub web after Task 3 lands.
- Creating `timeline.md` or `relationships.md` skeletons during character_extraction. Those are optional-at-creation per `agents/characters.md` and remain so.
- Writing a formal `agents/scene-list-schema.md`. Sprint 3 keeps the scene-list schema informal, embedded in the step body.
- Resolving the deferred `agents/orchestrator.md` TODOs about canon invention and centralized human questions.
