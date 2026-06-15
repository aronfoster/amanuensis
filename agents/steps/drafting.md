---
step_id: drafting
review_required: true
inputs:
  - <chapter-folder>/storyboards/*-storyboard.md
  - voice.md
outputs:
  - <chapter-folder>/drafts/<latest-attempt>/draft.md
  - <chapter-folder>/drafts/<latest-attempt>/notes.md
---

See `agents/orchestrator.md` for the step workflow contract.

# Drafting

## Purpose

This step drafts a chapter by assigning each scene to a separate subagent, then combining the scene outputs into one chapter draft. The body of this step is the chapter coordinator: it groups storyboard files into scenes, dispatches one subagent per scene, and assembles the per-scene prose into a single chapter draft.

Use this step only after the chapter's storyboard files are complete. This step does not create, revise, or validate storyboards. The coordinator manages scene assignment, output paths, ordering, and assembly. Subagents write prose for individual scenes only.

## Inputs

- **`<chapter-folder>/storyboards/*-storyboard.md`** — every storyboard file for the chapter being drafted. Each file represents one beat. Multiple beat files share a `scene_ref` value when they belong to the same scene; the coordinator groups by that value. Each file's frontmatter also carries `beat_index`, used to order beats within a scene.
- **`voice.md`** — the project-root voice file. The coordinator reads `voice.md` from the consuming project's root (a sibling of `pipeline-state.md`), not from inside the `amanuensis/` submodule. A project may override the location by pointing at a different voice file in its top-level `AGENTS.md`; the coordinator passes whichever path is in effect to every subagent. Subagents place the full contents of the voice file in their LLM system message so it can be cached. If no voice file can be found, see Open questions handling.

## Behavior

### Coordinator responsibilities

1. Identify all storyboard files in `<chapter-folder>/storyboards/`.
2. Group storyboard files by scene using their `scene_ref` frontmatter value. Within each scene, order files by `beat_index`. If filenames and `beat_index` disagree, use `beat_index` and record the mismatch in `notes.md`.
3. Resolve `<latest-attempt>`. If no `attemptNN` directory exists under `<chapter-folder>/drafts/`, create `attempt01`. Otherwise create the next-numbered `attemptNN` directory for this run. The created directory is `<latest-attempt>` for the rest of the step.
4. Create `<chapter-folder>/drafts/<latest-attempt>/notes.md` recording the attempt name, date, model if known, chapter path, and which storyboard files were assigned to each scene.
5. Dispatch one subagent per scene, in parallel where the host supports it. Give each subagent only the allowed inputs for its assigned scene (see Subagent prompt contract).
6. Wait for all subagents to write their scene file (`sceneNN.md`) and scene notes file (`sceneNN-notes.md`) into `<chapter-folder>/drafts/<latest-attempt>/`.
7. Assemble the scene files in scene order into `<chapter-folder>/drafts/<latest-attempt>/draft.md` (see Assembly rules).
8. Assemble the scene notes files into `<chapter-folder>/drafts/<latest-attempt>/notes.md`, broken out by scene (see Notes assembly).
9. Delete each `sceneNN.md` and `sceneNN-notes.md` from `<chapter-folder>/drafts/<latest-attempt>/` once their entire contents are in the chapter draft and notes files — the scene prose in `draft.md`, the scene notes in `notes.md`. The deletion is gated on that capture: delete a fragment only after confirming its content is present in the durable combined file (`sceneNN.md` → `draft.md`, `sceneNN-notes.md` → `notes.md`); it is not an unconditional `rm`. On any failure path — a subagent reports a blocker, a scene file is missing, assembly is not completed or is abandoned, or the step takes the Open-questions exit with no `draft.md` written — do not delete the fragments. Preserve them for diagnosis and record the blocker in `notes.md`.

The coordinator may inspect storyboard frontmatter to group files and determine scene order. The coordinator must not rewrite scene prose during assembly except for mechanical fixes required to combine files, such as removing duplicate titles or normalizing scene separators.

### Scene grouping

Storyboard filenames represent beats, not scenes. Do not assume one file equals one scene. Group files by the `scene_ref` field in each storyboard's frontmatter; draft all storyboard files with the same `scene_ref` as one scene.

### Subagent responsibilities

Each subagent drafts one scene from the storyboard files for that scene plus the voice file. Nothing else.

The subagent must:

- read the voice file passed in by the coordinator
- read all storyboard files assigned to its scene, in beat order
- treat the assigned storyboard files as production notes for one continuous dramatic arc; pace against the scene arc, not against individual beat boundaries
- write prose only to its assigned `sceneNN.md` file
- write generation notes only to its assigned `sceneNN-notes.md` file
- preserve required facts, concealments, forms of address, character state, and craft signals from the storyboard files
- preserve the distinction between what a character knows, suspects, falsely believes, and does not know

The subagent must not:

- read chapter summaries, scene lists, canon files, character files, or any file outside the inputs handed in by the coordinator
- dump full canon files or other reference files into the prompt — anything the prose needs from canon must already be in a storyboard block's `canon_active` field
- invent canon to fill gaps
- move facts across scenes
- include markdown headings, planning notes, summaries, or commentary in the scene prose file
- revise another subagent's scene file
- assemble the chapter draft

Each scene's prose begins with `<!-- scene X, beat Y -->` markers and ends with `<!-- end scene X, beat Y -->` markers around each beat block, matching the structure of the storyboard files it was drafted from. Scene breaks within the assembled draft are indicated by a horizontal rule (`---`); the coordinator inserts those during assembly.

### Subagent prompt contract

The coordinator gives each subagent a constrained prompt with this shape:

```text
Draft one scene for [chapter path].

Allowed inputs:
- [voice file path]
- [list of storyboard files for this scene, in beat order]

Do not read any other project files. Do not request any canon, character, or summary file — anything you need from canon is already extracted into the storyboard blocks' canon_active fields.

Write prose only to:
[attempt folder]/sceneNN.md

Write generation notes only to:
[attempt folder]/sceneNN-notes.md

Treat the storyboard files as production notes for one continuous dramatic arc. Pace against the arc, not against beat boundaries. Preserve Must Preserve, Concealment from reader, Concealment from characters, Canon active, Character state in / Character state out, and Craft signal constraints.

Place the full contents of the voice file in your LLM system message. Place the storyboard blocks for the scene, in beat order, in your user message. Do not paste canon files, scene lists, or summaries into the user message.

Do not include planning notes, summaries, commentary, or markdown headings in the scene prose file. Do not assemble the chapter.

In the scene notes file, briefly record what you generated, any storyboard constraints that were difficult to satisfy, any uncertainty, and any blockers. Do not put prose in the notes file.
```

### Assembly rules

The coordinator assembles the chapter after all scene files exist.

Assembly is mechanical:

1. Read scene files in scene order.
2. Strip any accidental headings, notes, or wrappers that are not prose.
3. Place a horizontal rule (`---`) between scenes.
4. Write the result to `<chapter-folder>/drafts/<latest-attempt>/draft.md`.
5. Record assembly notes in `notes.md`, not in the draft.

The combined draft contains story text only.

### Notes assembly

After scene drafting completes, the coordinator combines the per-scene notes files into `<chapter-folder>/drafts/<latest-attempt>/notes.md`, broken out by scene:

```md
# Attempt Notes

## Run

- Attempt: <latest-attempt>
- Chapter: <chapter-folder>
- Model: <model id if known>

## Scene 1

[contents of scene01-notes.md]

## Scene 2

[contents of scene02-notes.md]
```

Scene notes capture generation-relevant information only: what was generated, constraints that were difficult to satisfy, uncertainty or missing information, and blockers or deviations. Do not put scene prose in notes files; do not put notes in scene prose files or in the combined draft.

### Failure handling

If a subagent cannot draft from the storyboard files alone, it stops and reports the missing requirement to the coordinator instead of reading extra files or guessing. The coordinator records the blocker in `notes.md`. The fix belongs outside this step, usually by improving the storyboard files.

If two scene files conflict in tone, continuity, or repeated exposition, the coordinator records the issue in `notes.md`. The coordinator must not silently solve continuity problems by adding new canon or changing reveal timing.

When the run cannot complete assembly — a blocker is raised, a scene file is missing, or the step is abandoned — the per-scene fragments are preserved, not deleted, so the partial run can be diagnosed.

### Out of scope

This step does not include storyboarding, compliance review, continuity review, metaphor checks, anti-AI passes, character knowledge updates, or aftermath updates. Those are separate steps that run after this one.

### Safety rules

- Do not silently invent canon.
- Protect reveal timing.
- Keep prose files free of planning notes.
- Treat missing information as a storyboard problem, not a drafting problem.
- Preserve the difference between what a character knows, suspects, falsely believes, and does not know.

## Outputs

The durable outputs of a completed run are `draft.md` and `notes.md`:

- **`<chapter-folder>/drafts/<latest-attempt>/draft.md`** — the assembled chapter draft. Contains story text only, with scenes separated by `---`. Beats within a scene retain their `<!-- scene X, beat Y -->` / `<!-- end scene X, beat Y -->` markers.
- **`<chapter-folder>/drafts/<latest-attempt>/notes.md`** — the combined run notes. Run metadata (attempt name, chapter path, model) plus the per-scene notes broken out by scene heading. Also captures any beat-index/filename mismatches, assembly notes, and blockers raised by subagents.

The per-scene `sceneNN.md` and `sceneNN-notes.md` files are transient working files written by subagents during the run. Their content is folded into `draft.md` and `notes.md` during assembly, and the coordinator deletes them afterward (see Coordinator responsibilities, step 9), so they are not part of the durable output set. They are preserved only when a run cannot complete assembly.

## Open questions handling

If the step cannot complete because of missing or ambiguous inputs — for example, the chapter has no storyboard files, storyboards are missing `scene_ref` or `beat_index` frontmatter required to group and order them, the project-root `voice.md` (or the override named in the project's `AGENTS.md`) does not exist, or a subagent reports that its storyboard files do not contain enough to draft from — append the blocker to the project root `open-questions.md` and exit without advancing the pipeline marker. Do not fabricate inputs and do not write a partial `draft.md`. The next dispatcher invocation will re-run this step after the human resolves the blocker (typically by editing storyboards).
