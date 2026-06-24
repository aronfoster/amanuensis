# Prompt File Examples

This file contains copy-paste prompt templates for humans. It is not loaded automatically by agents.

Replace bracketed placeholders before use.

## Create Scene Draft

```text
You are drafting [Scene Name], Chapter [YY] of Book [N]. Follow the project `AGENTS.md`, the drafting workflow, and the selected voice file or profile.

Write to `[chapter-dir]/drafts/[attempt]/draft-vNN.md`.

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
See `agents/steps/metaphor-identify.md` for directions, or the equivalent path in the project's Amanuensis submodule.

Draft: [chapter-dir]/drafts/[attempt]/draft-vNN.md
Storyboards: [chapter-dir]/storyboards/ (all relevant [NN-YY-ZZZ-storyboard.md] files)

Output to: [chapter-dir]/drafts/[attempt]/[NN-YY-metaphors.md]
```

## Metaphor Flatten

```text
See `agents/metaphor/metaphor-flatten.md` for directions, or the equivalent path in the project's Amanuensis submodule.

Working file: [chapter-dir]/drafts/[attempt]/[NN-YY-metaphors.md]
Draft: [chapter-dir]/drafts/[attempt]/draft-vNN.md

Process all FLATTEN-marked entries. Append variants to each entry in the working file.
```

## Metaphor Replace

```text
See `agents/metaphor/metaphor-replace.md` for directions, or the equivalent path in the project's Amanuensis submodule.

Working file: [chapter-dir]/drafts/[attempt]/[NN-YY-metaphors.md]
Draft: [chapter-dir]/drafts/[attempt]/draft-vNN.md

Process all REPLACE-marked entries. Append integration versions to each entry in the working file.
```

## Metaphor Workshop

```text
See `agents/metaphor/metaphor-workshop.md` for directions, or the equivalent path in the project's Amanuensis submodule.

Working file: [chapter-dir]/drafts/[attempt]/[NN-YY-metaphors.md]
Draft: [chapter-dir]/drafts/[attempt]/draft-vNN.md
Storyboards: [chapter-dir]/storyboards/ (all relevant [NN-YY-ZZZ-storyboard.md] files)
Voice: [selected voice file or profile]

Work the next WORKSHOP-marked entry. Append candidates to the working file and stop.
```
## Sprint Orchestrator

```text
You are managing an entire Sprint by spawning subagents per task and merging their work. Follow this protocol exactly.

**Orientation (read first, in order):**
1. `AGENTS.md` — repo conventions and the "Next Task Queueing" workflow.
2. `ROADMAP.md` — milestone context for the Sprint.
3. `SPRINT.md` — the authoritative task list. Note which tasks are already checked.
4. Any task-specific source docs the Sprint references (e.g. `agents/orchestrator.md`).

**Plan before acting.** Produce a short dependency analysis covering, for each unchecked task: which files it creates, which files it modifies, and which other tasks it reads from or conflicts with. Group tasks into **waves**:
- Tasks that touch the same file run sequentially (one agent, or back-to-back).
- Tasks that touch disjoint files run in parallel within a wave.
- A task that consumes another task's output runs in a later wave.

Present the plan and wait for human approval before spawning anything.

**Per wave:**
1. Spawn one subagent per task (or one agent for a sequential bundle). Brief each agent self-containedly: cite the SPRINT.md task block as authoritative, point at the specific source files to read, list verification commands, and instruct the agent to **edit files but not commit** — you commit between waves.
2. After agents return, run verification yourself: `git status`, `git diff` on shared files, spot-read new files, run any acceptance grep the Sprint defines (e.g. `git grep "TBD"` returns nothing).
3. Commit the wave with a descriptive message. One commit per wave is fine; per-task commits are also fine.
4. Update a TodoWrite list as waves complete.

**Branch and push.** Confirm the development branch from the task instructions or create it if missing. Push only after all waves are complete and verified, using `git push -u origin <branch>`. Never force-push.

**Stop after closeout.** Check Sprint boxes, mark milestones complete, and run **PM Sprint Closeout**.

**Output discipline.** Brief status updates between waves: what shipped, what's next. Don't narrate subagent internals — summarize their results in one or two sentences each.
```
