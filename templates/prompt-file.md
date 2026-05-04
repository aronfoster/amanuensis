# Prompt File Examples

This file contains copy-paste prompt templates for humans. It is not loaded automatically by agents.

Replace bracketed placeholders before use.

## Create Scene Draft

```text
You are drafting [Scene Name], Chapter [YY] of Book [N]. Follow the project `AGENTS.md`, the drafting workflow, and the selected voice file or profile.

Write to `[chapter-dir]/drafts/[attempt]/[NN-YY-draft.md]`.

Do not read any other files. Do not consult the scene list, canon files, or earlier draft attempts. If something feels missing from the storyboards, note it in `[chapter-dir]/drafts/[attempt]/notes.md` after drafting rather than reaching for other files.

Storyboard files:
- [chapter-dir]/storyboards/[NN-YY-ZZZ-storyboard.md]
- [chapter-dir]/storyboards/[NN-YY-ZZZ-storyboard.md]

After writing the prose, write your model name and any observations about what the storyboards gave you versus what you had to infer to `[chapter-dir]/drafts/[attempt]/notes.md`.
```

## Create Storyboard

```text
Follow the project `AGENTS.md` and the storyboarding workflow.

Inputs:
- Chapter summary: [chapter-dir]/[NN-YY-summary.md]
- Scene list: [chapter-dir]/[NN-YY-scene-list.md]
- Storyboard planning notes: [chapter-dir]/[NN-YY-storyboards-planning.md]
- Relevant character knowledge files: [paths]
- Relevant canon or reference files linked from the scene list: [paths]

Create storyboard block [NN-YY-ZZZ] for [scene name / beat name].

Break this into steps: plan the file contents, write the file, review it against the storyboard schema, revise anything that needs alignment, and finish with a short report of uncertainties.
```

## Metaphor Identify

```text
See `agents/metaphor/metaphor-identify.md` for directions, or the equivalent path in the project's Amanuensis submodule.

Draft: [chapter-dir]/drafts/[attempt]/[NN-YY-draft.md]
Storyboards: [chapter-dir]/storyboards/ (all relevant [NN-YY-ZZZ-storyboard.md] files)

Output to: [chapter-dir]/drafts/[attempt]/[NN-YY-metaphors.md]
```

## Metaphor Flatten

```text
See `agents/metaphor/metaphor-flatten.md` for directions, or the equivalent path in the project's Amanuensis submodule.

Working file: [chapter-dir]/drafts/[attempt]/[NN-YY-metaphors.md]
Draft: [chapter-dir]/drafts/[attempt]/[NN-YY-draft.md]

Process all FLATTEN-marked entries. Append variants to each entry in the working file.
```

## Metaphor Replace

```text
See `agents/metaphor/metaphor-replace.md` for directions, or the equivalent path in the project's Amanuensis submodule.

Working file: [chapter-dir]/drafts/[attempt]/[NN-YY-metaphors.md]
Draft: [chapter-dir]/drafts/[attempt]/[NN-YY-draft.md]

Process all REPLACE-marked entries. Append integration versions to each entry in the working file.
```

## Metaphor Workshop

```text
See `agents/metaphor/metaphor-workshop.md` for directions, or the equivalent path in the project's Amanuensis submodule.

Working file: [chapter-dir]/drafts/[attempt]/[NN-YY-metaphors.md]
Draft: [chapter-dir]/drafts/[attempt]/[NN-YY-draft.md]
Storyboards: [chapter-dir]/storyboards/ (all relevant [NN-YY-ZZZ-storyboard.md] files)
Voice: [selected voice file or profile]

Work the next WORKSHOP-marked entry. Append candidates to the working file and stop.
```
