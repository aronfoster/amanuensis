# Prompt File
This file contains text for copy-pasting as prompts. It is intended for use by humans, not agents.

## Create Scene Draft

```
You are drafting Chapter 1 of Book 1. See `agents/drafting.md` and `agents/voice.md` for directions.

Write to `plot/book1/chapter01/drafts/attempt07/01-01-draft.md`.

Do not read any other files. Do not consult the scene list, canon files, or earlier draft attempts. If something feels missing from the storyboards, note it in `plot/book1/chapter01/drafts/attempt07/notes.md` after drafting rather than reaching for other files.

Storyboard files:
- plot/book1/chapter01/01-01-001-storyboard.md
- plot/book1/chapter01/01-01-002-storyboard.md
- plot/book1/chapter01/01-01-003-storyboard.md
- plot/book1/chapter01/01-01-004-storyboard.md

After writing the prose, write your model name and any observations about what the storyboards gave you versus what you had to infer to `plot/book1/chapter01/drafts/attempt07/notes.md`.
```

```
You are drafting Scene 1, Chapter 1 of Book 1. See `agents/drafting.md` and `agents/voice.md` for directions.

Write to your standard output stream, despite what `agents/drafting.md` says.

Storyboard files:
- plot/book1/chapter01/01-01-001-storyboard.md
- plot/book1/chapter01/01-01-002-storyboard.md

After writing the prose, write your model name and any observations about what the storyboards gave you versus what you had to infer to the end of your output.
```


## Create Storyboard

```
See agents/storyboarding.md, plot/book1/chapter01/01-01-storyboards-planning.md, plot/book1/chapter01/01-01-scene-list.md, and any other files you deem appropriate. Create the storyboard.md file for Book 1 Chapter 1 SB 004 — The Memory of Last Time of Scene 1 — Managed Morning. Break this into a few steps: plan the whole file contents, write the first part of the file, check it in, write the remainder of the file, review the file and update anything that needs alignment or revision, and finish with your last check in.
```


## Metaphor Identify

```
See agents/metaphor/metaphor-identify.md for directions.

Draft: plot/book1/chapter01/drafts/attempt09/01-01-draft.md
Storyboards: plot/book1/chapter01/ (all 01-01-*-storyboard.md files)

Output to: plot/book1/chapter01/drafts/attempt09/01-01-metaphors.md
```


## Metaphor Flatten

```
See agents/metaphor/metaphor-flatten.md for directions.

Working file: plot/book1/chapter01/drafts/attempt09/01-01-metaphors.md
Draft: plot/book1/chapter01/drafts/attempt09/01-01-draft.md

Process all FLATTEN-marked entries. Append variants to each entry in the working file.
```


## Metaphor Replace

```
See agents/metaphor/metaphor-replace.md for directions.

Working file: plot/book1/chapter01/drafts/attempt09/01-01-metaphors.md
Draft: plot/book1/chapter01/drafts/attempt09/01-01-draft.md

Process all REPLACE-marked entries. Append integration versions to each entry in the working file.
```


## Metaphor Workshop

```
See agents/metaphor/metaphor-workshop.md for directions.

Working file: plot/book1/chapter01/drafts/attempt09/01-01-metaphors.md
Draft: plot/book1/chapter01/drafts/attempt09/01-01-draft.md
Storyboards: plot/book1/chapter01/ (all 01-01-*-storyboard.md files)
Voice: agents/voice.md

Work the next WORKSHOP-marked entry. Append candidates to the working file and stop.
```


## Metaphor Apply

```
See agents/metaphor/metaphor-apply.md for directions.

Working file: plot/book1/chapter01/drafts/attempt09/01-01-metaphors.md
Draft: plot/book1/chapter01/drafts/attempt09/01-01-draft.md

Output to: plot/book1/chapter01/drafts/attempt09/01-01-draft-metaphor.md
```
