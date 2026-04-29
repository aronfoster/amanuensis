# Chapter Folder Rules

Chapter folders are named `chapter01`, `chapter02`, `chapter03`, and so on. Each file within a chapter folder will start with book number (xx) and chapter number (yy)

Each chapter folder is a workflow unit.

## Purpose of a chapter folder

A chapter folder contains the files needed to move a chapter from intent to plan to prose to downstream updates.

## Expected chapter files

### `xx-yy-summary.md`
High-level intent of the chapter.

Use this file for:
- what the chapter must accomplish
- whose chapter it is
- what changes by the end
- what information is introduced, advanced, concealed, or revealed

This file is brief and strategic.

### `xx-yy-scene-list.md`
Covers all the scenes that make up a chapter

Use this file for:
- more detailed description of what, where, why, how
- POV
- location
- conflict
- emotional turn
- reveal or concealment
- consequences

scene lists will also include links to every reference file that should be considered when writing the scene

### `xx-yy-zzz-storyboard.md`
A sequence of independently draftable blocks.

Each block follows the schema defined in `storyboard-schema.md`. The prose generation workflow — how blocks are produced from the scene list and how prose is generated from a single block — is defined in `drafting.md`.

### `draft.md`
Actual prose.

Use this file for story text only.

Planning notes should not live here.

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

Use this file when a chapter surfaces unanswered questions that should not be silently guessed.

## Important distinctions

- `summary.md` = chapter intent
- `storyboard.md` = scene plan
- `draft.md` = prose
- `aftermath.md` = what changed after the chapter
