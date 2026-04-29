# Agentic Drafting

This workflow drafts a chapter by assigning each scene to a separate subagent, then combining the scene outputs into one chapter draft.

Use this only after the chapter's storyboard files are complete. This workflow does not create, revise, or validate storyboards.

## Purpose

Agentic drafting is for parallel scene drafting from completed storyboard files.

The coordinator manages scene assignment, output paths, ordering, and assembly. Subagents write prose for individual scenes only.

## Inputs

- The project's selected voice file or Amanuensis voice profile
- The chapter storyboard files in `plot/bookN/chapterYY/storyboards/`

## Outputs

Each run should create a dedicated attempt folder under the chapter's `drafts/` directory. Use the existing `attemptXX` naming pattern:

```text
plot/bookN/chapterYY/drafts/attempt01/
  scene01.md
  scene01-notes.md
  scene02.md
  scene02-notes.md
  scene03.md
  scene03-notes.md
  notes.md
  NN-YY-draft.md
```

Scene files and scene notes files are temporary working outputs. The combined draft file is the assembled chapter draft for that run. The run-level `notes.md` is the combined notes record for the chapter generation attempt.

Do not write planning notes into scene files or into the combined draft.

## Coordinator Responsibilities

1. Read this file, `update-rules.md`, `drafting.md`, and the selected voice file or profile.
2. Identify all storyboard files for the chapter.
3. Group storyboard files by scene using their `scene_ref` values.
4. Create a new `attemptXX` run folder under the chapter's `drafts/` directory.
5. Create `notes.md` recording the attempt name, date, model if known, chapter path, and storyboard files assigned to each scene.
6. Dispatch one subagent per scene.
7. Give each subagent only the allowed inputs for its assigned scene.
8. Ensure each subagent writes one scene file and one scene notes file in the attempt folder.
9. Assemble the scene files in scene order into the attempt's combined draft file.
10. Assemble the scene notes files in scene order into the attempt's `notes.md`, broken out by scene.
11. Separate scenes in the combined draft with a horizontal rule: `---`.

The coordinator may inspect storyboard metadata to group files and determine scene order. The coordinator should not rewrite scene prose during assembly except for mechanical fixes required to combine files, such as removing duplicate titles or normalizing scene separators.

## Subagent Responsibilities

Each subagent drafts one scene.

The subagent must:

- read the selected voice file or profile
- read all storyboard files assigned to its scene, in beat order
- treat the assigned storyboard files as production notes for one dramatic arc
- write prose only to its assigned scene file
- write generation notes only to its assigned scene notes file
- preserve required facts, concealments, forms of address, and craft signals from the storyboard files
- avoid adding planning notes, summaries, commentary, or explanations to the scene prose file

The subagent must not:

- read chapter summaries, scene lists, canon files, or character files
- invent canon to fill gaps
- move facts across scenes
- include markdown headings unless the coordinator explicitly requests them
- revise another subagent's scene file
- assemble the chapter draft

## Subagent Prompt Contract

The coordinator should give each subagent a constrained prompt with this shape:

```text
Draft one scene for [chapter path].

Allowed inputs:
- [selected voice file or profile]
- [list of storyboard files for this scene]

Do not read any other project files.

Write prose only to:
[attempt folder]/sceneXX.md

Write generation notes only to:
[attempt folder]/sceneXX-notes.md

Treat the storyboard files as production notes for one continuous dramatic arc. Follow the drafting workflow: pace against the scene arc, not against individual beat boundaries. Preserve Must Preserve, Concealment from reader, Concealment from characters, Canon active, Character state in/out, and Craft signal constraints.

Do not include planning notes, summaries, commentary, or markdown headings in the scene prose file. Do not assemble the chapter.

In the scene notes file, briefly record what you generated, any storyboard constraints that were difficult to satisfy, any uncertainty, and any blockers. Do not add prose to the notes file.
```

## Scene Grouping

Storyboard filenames may represent beats, not scenes. Do not assume one file equals one scene.

Group files by the `scene_ref` field in each storyboard's frontmatter. Draft all storyboard files with the same `scene_ref` as one scene.

Within each scene, order files by `beat_index`. If filenames and `beat_index` disagree, use `beat_index` and record the mismatch in `notes.md`.

## Assembly Rules

The coordinator assembles the chapter after all scene files exist.

Assembly should be mechanical:

1. Read scene files in scene order.
2. Remove any accidental headings, notes, or wrappers that are not prose.
3. Place a horizontal rule between scenes.
4. Write the result to the attempt's combined draft file, such as `01-01-draft.md`.
5. Record assembly notes in `notes.md`, not in the draft.

The combined draft should contain story text only.

## Notes Assembly

Each subagent writes a separate notes file for its scene, such as `scene01-notes.md`.

The coordinator combines those files into the attempt's `notes.md` after scene drafting is complete. The combined notes file should be broken out by scene:

```md
# Attempt Notes

## Run

- Attempt: attempt01
- Chapter: plot/bookN/chapterYY
- Model: openai/gpt-5.5

## Scene 1

[contents of scene01-notes.md]

## Scene 2

[contents of scene02-notes.md]
```

The scene notes should capture generation-relevant information only:

- what was generated
- constraints that were difficult to satisfy
- uncertainty or missing information
- blockers or deviations, if any

Do not put scene prose in notes files. Do not put notes in scene prose files or in the combined draft.

## Failure Handling

If a subagent cannot draft from the storyboard files alone, it should stop and report the missing requirement to the coordinator instead of reading extra files or guessing.

The coordinator should record the blocker in `notes.md`. The fix belongs outside this workflow, usually by improving the storyboard files.

If two scene files conflict in tone, continuity, or repeated exposition, the coordinator should record the issue in `notes.md`. Do not silently solve continuity problems by adding new canon or changing reveal timing.

## Out Of Scope

This workflow does not include:

- storyboarding
- compliance review
- continuity review
- metaphor checks
- anti-AI passes
- character knowledge updates
- aftermath updates

Run those workflows separately after the agentic draft exists.

## Safety Rules

- Do not silently invent canon.
- Protect reveal timing.
- Keep prose files free of planning notes.
- Treat missing information as a storyboard problem, not a drafting problem.
- Preserve the difference between what a character knows, suspects, falsely believes, and does not know.
