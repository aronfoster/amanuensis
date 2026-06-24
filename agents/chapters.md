# Chapter Folder Rules

Chapter folders are named `chapter01`, `chapter02`, `chapter03`, and so on. Files inside a chapter folder use unprefixed canonical names; folder structure carries the book and chapter identity.

Each chapter folder is a workflow unit.

See `agents/project-layouts.md` for how `<chapter-folder>` resolves per `project_type` (e.g., for `short_story` the project root is the chapter equivalent, while `book` and `series` projects nest chapters under a `<book-folder>`). That document is the canonical reference for turning a name like `summary.md` into a real path.

## Purpose of a chapter folder

A chapter folder contains the files needed to move a chapter from intent to plan to prose to downstream updates.

## Expected chapter files

### `summary.md`
High-level intent of the chapter.

Use this file for:
- what the chapter must accomplish
- whose chapter it is
- what changes by the end
- what information is introduced, advanced, concealed, or revealed

This file is brief and strategic.

### `scene-list.md`
Covers all the scenes that make up a chapter

Use this file for:
- more detailed description of what, where, why, how
- POV
- location
- conflict
- emotional turn
- reveal or concealment
- consequences

Scene lists will also include links to every reference file that should be considered when writing the scene.

### Storyboards
Per-beat storyboards live in the `storyboards/` subdirectory of the chapter folder, one file per beat:

```text
<chapter-folder>/storyboards/<scene-id>-<beat-id>-storyboard.md
```

Each file is an independently draftable block. There is no longer a single chapter-level storyboard file; the per-beat files together cover the chapter.

- The schema for an individual storyboard file is defined in `agents/storyboard-schema.md`.
- The generation step that produces these files from the scene list is defined in `agents/steps/storyboarding.md`.

### Versioned drafts (`draft-vNN.md`)
Actual prose.

Use these files for story text only. Planning notes should not live here.

Each attempt's prose is recorded as a sequence of versioned drafts under `drafts/attemptNN/` inside the chapter folder. Drafting produces `draft-v01.md`; each subsequent prose-advancing step (compliance fix, metaphor apply, line pass, anti-AI fix) reads `<latest-draft>` and writes the next `draft-vNN.md`. Report-only and setup steps (compliance report, metaphor identify, metaphor fix, prose pass, anti-AI report) read `<latest-draft>` without minting a new version. The attempt's `draft-manifest.md` records, per draft version, which step produced it and which side artifacts it consulted; that manifest is the provenance source, not in-file YAML. Side artifacts (`notes.md`, `reviewer-actions.md`, `metaphors.md`, `prose-pass.md`, `anti-ai.md`) keep their step-named, unversioned filenames and live alongside the drafts under the same `drafts/attemptNN/` directory.

Some of these per-attempt files are **durable audit records**, kept for human review and downstream steps: `notes.md` (the run record), plus the later-stage review/report files `reviewer-actions.md`, `metaphors.md`, and `anti-ai.md`, alongside the prose `draft-vNN.md` series and the `draft-manifest.md`. The per-scene `sceneNN.md` / `sceneNN-notes.md` fragments are **transient**: their entire content is folded into `draft-v01.md` and `notes.md` during the drafting step, and they are deleted after assembly. The general rule: a working file is deletable once its content is captured in a durable combined artifact.

#### Manual prose-edit handoff

Until M5 lands `prose_fix`, the human applies `prose_pass` recommendations to the prose by hand. Those edits must produce a new `draft-vNN.md`, not in-place changes to `<latest-draft>` — otherwise the versioned-draft model loses provenance and downstream steps cannot tell which prose they are reading. The handoff procedure:

1. Copy `<latest-draft>` to the next-numbered `draft-vNN.md` in the same attempt directory.
2. Apply the human edits to the new file. Leave `<latest-draft>` untouched.
3. Append an entry to `draft-manifest.md` for the new version with `produced_by: human_prose_edit`, `read_from: [<previous-draft>]`, `side_artifacts: [prose-pass.md]`, and a short note referencing `prose-pass.md` as the apply source.
4. Then dispatch `metaphor_identify`. It will resolve `<latest-draft>` to the new file via the standard step-start resolution; no other rewiring is needed.

If the human does not apply any prose edits and accepts `prose_pass`'s output as advisory only, no new draft version is needed — `metaphor_identify` runs against the existing `<latest-draft>`.

### `aftermath.md`
Post-chapter delta record.

Use this file for:
- what changed beyond the chapter
- what characters learned
- what relationships shifted
- what canon may need updating
- what new open questions were created

This file is critical for safe downstream updates.

### `open-questions.md` if present
Explicit unresolved issues exposed by the chapter.

Use this file when a chapter surfaces unanswered questions that should not be silently guessed. This is the chapter-scoped open-questions file; the project-root `open-questions.md` defined in `agents/project-layouts.md` is a separate file.

## Important distinctions

- `summary.md` = chapter intent
- `scene-list.md` = scene plan
- `storyboards/<scene-id>-<beat-id>-storyboard.md` = per-beat draftable block
- `draft-vNN.md` (under `drafts/attemptNN/`) = prose; the attempt's `draft-manifest.md` is the provenance record
- `aftermath.md` = what changed after the chapter
