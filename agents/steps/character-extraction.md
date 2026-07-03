---
step_id: character_extraction
review_required: true
inputs:
  - <story-plan>
  - canon/**/*.md
outputs:
  - characters/<character-id>/profile.md
  - characters/<character-id>/knowledge/baseline.md
  - characters/<character-id>/knowledge/book-N.md
  - open-questions.md
preconditions:
  - path: <story-plan>
    kind: source
    required: true
    review_sensitive: false
  - path: canon/**/*.md
    kind: source
    required: false
    review_sensitive: false
---

See `agents/orchestrator.md` for the step workflow contract.

# Character Extraction

## Purpose

Bootstraps the project's `characters/` tree from the story plan and canon. This is the first step in the pipeline: it produces the minimum character folders that downstream steps (scene generation, storyboarding, drafting) read from. Every character the plan references — named or stub — gets a folder with a profile and a baseline knowledge file before any scene-level planning begins.

## Inputs

- `<story-plan>` — the project's planning file. Resolved per `project_type` per the rules in `agents/project-layouts.md`. For `short_story` this is `plot/summary.md`; for `book` and `series` it is the in-flight book's `plot/<book-folder>/overview.md`. The consuming project's local `AGENTS.md` may override the resolution.
- `canon/**/*.md` — every canon file under the project's `canon/` tree. Used as auxiliary input so extracted characters are grounded in established world rules and baseline knowledge is not invented in conflict with canon. See `agents/canon.md` for the priority order; canon outranks the story plan when the two disagree on a settled fact.

## Behavior

Run in this order:

1. **Read the story plan and canon.** Read the resolved `<story-plan>` file in full. Read every file under `canon/`. If the story plan is missing or unreadable, see "Open questions handling" below — that is the only condition that blocks this step.

2. **Identify every character.** Sweep the story plan for every character it references. Include stub roles (e.g., "the protagonist's mother", "the village blacksmith") alongside named characters. Cross-reference canon: a character the plan names by role may already exist in canon under a different name, in which case treat them as the canon character.

3. **Create the character folder.** For each identified character, create `characters/<character-id>/` if it does not exist. The `character_id` is snake_case. For named characters, derive it from the name (e.g., `aria_velens`). For stubs, derive a descriptive snake_case id from the role (e.g., `protagonist_mother`, `village_blacksmith`). Write the **minimum required file set** per `agents/characters.md`:

   - `profile.md`
   - `knowledge/baseline.md`
   - For `book` and `series` projects, also `knowledge/book-N.md` (one per book the character appears in, e.g. `knowledge/book-1.md`)

   Do **not** create `timeline.md` or `relationships.md` in this step — those are optional-at-creation per `agents/characters.md` and are filled later, before the character first affects plot.

4. **Populate `profile.md`.** Use `templates/profile.md` as the source template. Fill the frontmatter and mandatory sections (One-line summary, Narrative function, Core identity, Essence, Voice and presence, Continuity constraints, Open questions) with whatever the story plan and canon support. Optional sections may be filled when the plan or canon clearly supplies the material; otherwise omit them per the template's guidance for minor characters. For fields the plan or canon do not specify, leave them explicitly blank — use `TBD` for fields a future decision will fill, `open question (ref: <id>)` for fields tracked in `open-questions.md`, and `n/a` for fields that genuinely do not apply. Invention here is governed by Rule 1 in `agents/update-rules.md`: a profile's identity and other character-knowledge-load-bearing fields are load-bearing, so Rule 1 forbids inventing them — leave a genuinely-unknown such field blank / `TBD` / `open question (ref: <id>)` rather than filling it. For unnamed roles, set frontmatter `status: stub` and use the role-based snake_case `character_id`; for named characters anchored in canon or the plan, set `status: canonical`.

5. **Populate `knowledge/baseline.md`.** Capture what the character plausibly knows before the story begins, drawn from canon and from any pre-story context the plan supplies (background, prior events, faction membership). Use the structured entry format described in `agents/characters.md` and the `templates/knowledge-book.md` template. Leave `knowledge/book-N.md` files as empty scaffolds — they are filled during the scene knowledge update workflow after drafting commits scene-level facts, not here.

6. **Append open-questions entries.** For every gap that surfaces during extraction, append an entry to the project-root `open-questions.md` using the importance-tagged shape:

   ```markdown
   ## character_extraction: <one-line subject>

   - importance: critical | important | minor
   - blocker: <what is unresolved>
   - needed: <what input or decision would unblock this>
   ```

   Use these importance levels:

   - `critical` — unresolvable contradictions between the story plan and canon. The pipeline cannot proceed safely until the human reconciles them.
   - `important` — stub characters lacking a canonical name. The step did its best with a generated id; a settled name is needed before the character meaningfully affects plot.
   - `minor` — notable blank fields the plan implies but does not specify (e.g., the plan calls a character "the queen's adviser" without giving an age, occupation history, or affiliations the plan's logic implies must exist).

   Append; do not rewrite existing entries.

### Idempotency

This step overwrites whatever sits at its declared output paths when re-run. A second invocation regenerates `profile.md` and `knowledge/baseline.md` for every character it identifies, discarding any hand-edits at those paths. Humans who want to preserve prior output rename or move the relevant `characters/<character-id>/` folder before re-running. New `open-questions.md` entries are appended on every run; the human prunes stale entries by hand.

### Project-type notes

- `short_story`: there is one book and one chapter. No `knowledge/book-N.md` files are created.
- `book`: create `knowledge/book-1.md` (and any further `book-N.md` scaffolds the plan implies the character appears in) alongside `baseline.md`.
- `series`: create one `knowledge/book-N.md` scaffold per book the plan indicates the character appears in. "Which book is in flight" follows the deferred chapter-selection question noted in `agents/orchestrator.md`; for now, scaffold every book the plan names.

## Outputs

- `characters/<character-id>/profile.md` — populated from `templates/profile.md`. Frontmatter plus the mandatory sections defined in that template; optional sections included where the plan or canon supports them. Unknown fields explicitly blank, `TBD`, or `open question (ref: <id>)`.
- `characters/<character-id>/knowledge/baseline.md` — structured knowledge entries covering pre-story knowledge, per the format in `agents/characters.md` and `templates/knowledge-book.md`.
- `characters/<character-id>/knowledge/book-N.md` — one empty scaffold per book the character appears in (`book` and `series` projects only). Filled later by the scene knowledge update workflow.
- `open-questions.md` — appended entries in the importance-tagged format above, one per surfaced gap.

## Open questions handling

Unanswered details about individual characters are normal output for this step. Stub names, ambiguous fields, and minor plan/canon gaps are appended to `open-questions.md` using the format above and the step still completes — its final action marks its own step line `[x]` in `pipeline-state.md` and updates `last_updated`.

A blocked exit — exiting without recording completion in `pipeline-state.md` — applies only when the step cannot run at all: the resolved `<story-plan>` file is missing or unreadable, or the project's `project_type` cannot be determined from `pipeline-state.md`. In that case, append a `critical` blocker to `open-questions.md` describing what could not be read, write no character files, and exit without recording completion in `pipeline-state.md`. The next dispatcher invocation re-runs this step after the human resolves the blocker.
