---
step_id: scene_generation
review_required: true
inputs:
  - <story-plan>
  - characters/<character-id>/profile.md
  - characters/<character-id>/knowledge/baseline.md
  - canon/**/*.md
outputs:
  - <chapter-folder>/scene-list.md
  - open-questions.md
---

See `agents/orchestrator.md` for the step workflow contract.

# Scene Generation

## Purpose

Translate the project's story plan into a scene-by-scene plan for the chapter currently in flight. The output, `<chapter-folder>/scene-list.md`, is the bridge between the high-level plan and the storyboarding step that follows: it commits to the sequence, POV, location, conflict, and reveal/concealment shape of each scene without yet committing to beats or prose. Downstream, `agents/steps/storyboarding.md` reads this file as its primary input.

## Inputs

- `<story-plan>` — the project's planning file. Resolved per project_type by `agents/project-layouts.md`. For `short_story` this is `plot/summary.md` by default; for `book` and `series` it is the per-book overview file. The consuming project's local `AGENTS.md` may override the default.
- `characters/<character-id>/profile.md` — stable character core for every character relevant to this chapter. Read all profiles, not only POV characters; supporting characters' motivations and continuity constraints affect scene shape.
- `characters/<character-id>/knowledge/baseline.md` — what each character knows before the story begins. Required to plan reveals and concealments honestly: a scene cannot reveal to a character something they already know, and concealment only matters relative to current knowledge.
- `canon/**/*.md` — world, setting, and rule files. Scenes are grounded in canon. The step may supply a permitted non-load-bearing detail under Rule 1 in `agents/update-rules.md`, but it records load-bearing (reveal/knowledge) or canon-conflicting gaps as open questions rather than inventing them (per `agents/canon.md`).

## Behavior

1. Read `<story-plan>`, every `characters/<character-id>/profile.md` and `characters/<character-id>/knowledge/baseline.md`, and every file under `canon/`.
2. Identify the chapter currently in flight.
   - For `short_story`, there is one chapter and `<chapter-folder>` resolves to `plot/`. The scene list covers the entire story.
   - For `book` and `series`, `<chapter-folder>` resolves to the current chapter's folder per `agents/project-layouts.md`. ("Which chapter is current?" is the dispatcher-level open question deferred to a later milestone; this step body is structured to compose with that mechanism once it lands but is only verified end-to-end for `short_story` in this Sprint.)
3. Produce a scene-by-scene plan covering the chapter (or, for `short_story`, the entire story). Decisions to commit per scene:
   - POV
   - location
   - central conflict
   - emotional turn
   - what is revealed and what is concealed (relative to each present character's current knowledge and to the reader)
   - consequences for downstream scenes
   - which character knowledge files and canon files the scene depends on
   These match the field intent informally described in `agents/chapters.md`. Keep the entries terse — this is scene-level planning, not storyboarding. Beat-level decomposition belongs to `agents/steps/storyboarding.md`.
4. Write the result to `<chapter-folder>/scene-list.md` using the shape under **Outputs** below.
5. For any plan ambiguity that forced a guess, append an entry to project-root `open-questions.md` using the importance-tagged format:

   ```markdown
   ## scene_generation: <one-line subject>

   - importance: critical | important | minor
   - blocker: <what is unresolved, in one or two sentences>
   - needed: <what input or decision would unblock this>
   ```

   Use `important` for plan gaps the step proceeded past with a flagged assumption, `minor` for low-risk cosmetic gaps, and `critical` only for unresolvable contradictions between plan and canon. Logging an open question is the normal path; the step still completes.

### MVP scope

The developer verifies this step end-to-end for `short_story` only. The body uses `<chapter-folder>` consistently so that a `book` or `series` project will compose correctly once the dispatcher solves chapter selection, but those paths are not exercised in this Sprint.

### Idempotency

The step overwrites `<chapter-folder>/scene-list.md` if it already exists. Humans who want to preserve prior output rename or move it before re-running the step. Open-questions entries are appended; the step does not edit existing entries in `open-questions.md`.

## Outputs

- `<chapter-folder>/scene-list.md` — YAML frontmatter followed by one section per scene.

  **Frontmatter fields (required):**

  ```yaml
  ---
  chapter_id: <chapter01 | story for short_story>
  book_id: <book-id>            # omit for short_story
  pov_default: <character_id>   # the chapter's primary POV character, if any; omit if none dominates
  scene_count: <integer>
  ---
  ```

  **Per-scene section.** One section per scene, in order. Heading `## scene01`, `## scene02`, etc. Body is short fields, one per line, terse phrasing — not paragraphs. Cover at minimum:

  - `pov:` POV character_id for this scene
  - `location:` where the scene happens
  - `conflict:` the central conflict (one line)
  - `emotional_turn:` the emotional shift the scene must accomplish
  - `revealed:` what is revealed, and to whom (characters and/or reader)
  - `concealed:` what is actively concealed, and from whom
  - `consequences:` what later scenes inherit from this one
  - `depends_on:` bulleted list of character knowledge files and canon files this scene relies on

  Match the field intent described in `agents/chapters.md`. Add other terse fields if the plan demands them, but do not expand entries into beat plans — that is `agents/steps/storyboarding.md`'s job.

- `open-questions.md` (appended) — one entry per ambiguity logged during this run, in the importance-tagged format above.

## Open questions handling

Normal ambiguities are logged in `open-questions.md` and the step completes. Exit-without-advancing is reserved for the cases where the step genuinely cannot produce a scene list:

- the resolved `<story-plan>` file is missing or unreadable, or
- the `characters/` tree is missing or empty (i.e., `character_extraction` has not run, or its output was deleted).

In those cases, append a `critical` entry to `open-questions.md` describing the missing input and exit without advancing the pipeline marker. Do not fabricate a plan and do not write a partial `scene-list.md`. The next dispatcher invocation will re-run this step after the human resolves the blocker.

## See also

- `agents/chapters.md` — field intent for a scene-list entry.
- `agents/steps/storyboarding.md` — downstream consumer; reads the `scene-list.md` produced here.
- `agents/project-layouts.md` — resolution rules for `<story-plan>` and `<chapter-folder>`.
- `agents/canon.md` — canon priority; this step reads canon and may supply permitted non-load-bearing detail under Rule 1 in `agents/update-rules.md`, recording load-bearing or conflicting gaps as open questions.
