# Amanuensis Agent Guide

## What this repository is

This repository **is** the Amanuensis tooling. It is consumed as a git submodule by story-writing projects. The actual prose, character files, scene lists, drafts, and canon all live in those *consuming* projects — never here.

An agent invoked inside this repository is doing one of:

- editing a step workflow file under `agents/steps/`
- editing a support document under `agents/`
- editing a template under `templates/`
- editing the orchestrator contract (`agents/orchestrator.md`)
- otherwise maintaining the framework (sprint/roadmap/process docs)

It is **not** writing a story. Story-author-facing instructions — how to draft a chapter, how to fill out a character profile, project-local naming and reveal-timing rules — do not live in this file. They live in each consuming project's local `AGENTS.md`, which the project maintains as an adapter built from [`templates/project-AGENTS.md`](templates/project-AGENTS.md). If you find yourself wanting to add prose-writing guidance here, you are in the wrong repo: that guidance belongs in the consuming project's adapter.

## Repository Boundary

Amanuensis is tooling, not story canon. Do not add project-specific canon, character state, plot files, or prose drafts to this repository except as clearly marked examples. This is the most important rule in this guide; every other section assumes it.

Consuming story repositories keep a small local `AGENTS.md` adapter that points back to these reusable workflows and defines project-local paths. The canonical starting point for that adapter is [`templates/project-AGENTS.md`](templates/project-AGENTS.md).

## How Amanuensis works

Amanuensis is an orchestrator-driven pipeline for long-form writing. Each project advances one step at a time: a host-specific dispatcher reads `pipeline-state.md` at the project root, locates the next step, runs that step's workflow file as a fresh agent invocation, advances the marker, and exits. State lives entirely in files — there is no in-memory context carried between steps. Humans review artifacts between steps; the dispatcher does not enforce review. Step workflow files declare their inputs, outputs, and review expectations in frontmatter and describe their behavior in the body. Folder layout, including how path placeholders resolve, depends on the project's declared `project_type`.

## Core documents

- `agents/orchestrator.md` — orchestrator contract and dispatcher behavior.
- `agents/project-layouts.md` — folder conventions per project type (`short_story`, `book`, `series`).
- `templates/step-workflow.md` — template for new step files.
- `templates/pipeline-state.md` — template state file.
- `templates/amanuensis-project.yaml` — project-level config template.
- `templates/project-AGENTS.md` — adapter template for consuming repositories.

## Step workflows

This is the catalog of step files this repo *provides to* consuming projects, not a how-to for writing prose. The pipeline's step bodies live in `agents/steps/`. Each file declares its `step_id`, `review_required`, `inputs`, and `outputs` in frontmatter and is dispatched by the orchestrator (see `agents/orchestrator.md`).

- `agents/steps/character-extraction.md` — reads the project's story plan and canon, then bootstraps the minimum `characters/<id>/` folders (profile + baseline knowledge) for every character the plan references.
- `agents/steps/scene-generation.md` — reads the story plan, character profiles and baseline knowledge, and canon, then writes the chapter's `scene-list.md` (or `plot/scene-list.md` for short stories).
- `agents/steps/storyboarding.md` — produces per-beat storyboard blocks from the chapter's scene list, summary, character knowledge, and canon.
- `agents/steps/drafting.md` — chapter coordinator that dispatches per-scene subagents and assembles their output into a single draft.
- `agents/steps/compliance-report.md` — checks the draft against storyboard Must-Contain / Must-Not-Contain requirements and canon, producing an annotated `reviewer-actions.md` report.
- `agents/steps/compliance-fix.md` — applies the human-annotated fixes from `reviewer-actions.md` to the draft, producing `draft-compliance.md`.
- `agents/steps/prose-pass.md` — advisory prose-quality pass that produces a report only; the human applies fixes manually before `metaphor_identify` runs.
- `agents/steps/metaphor-identify.md` — extracts every live metaphor and simile from the latest prose into `metaphors.md`.
- `agents/steps/metaphor-fix.md` — coordinator step that dispatches one subagent per annotated entry in parallel (FLATTEN / REPLACE / WORKSHOP) and reassembles their variants into `metaphors.md`.
- `agents/steps/metaphor-apply.md` — applies the human-selected variant to the prose, producing `draft-metaphor.md`.
- `agents/steps/line-pass.md` — chunked line-level voice and rhythm pass, producing `draft-line.md`.
- `agents/steps/anti-ai.md` — final pass that scans `draft-line.md` for AI-flavored patterns and writes a per-scene report.

## Support documents

This is the catalog of support files this repo *provides to* consuming projects; they are referenced *by* step workflows, and the dispatcher does not invoke them directly.

- `agents/update-rules.md` — safety rules around canon integrity, reveal timing, and downstream updates.
- `agents/workflows.md` — workflow order for book setup, chapter planning, drafting, continuity review, and post-chapter updates.
- `agents/canon.md` — rules for world-level truth files.
- `agents/books.md` — rules for book-level planning folders.
- `agents/chapters.md` — rules for chapter workflow files.
- `agents/characters.md` — rules for character profiles, knowledge state, timelines, and relationships.
- `agents/storyboard-schema.md` — schema for storyboard blocks.
- `agents/voice.md` — voice file consumed by drafting, prose pass, line pass, and metaphor workshop.
- `agents/meta.md` — meta notes about the agent guide.
- `agents/metaphor/` — subagent prompt contracts (`metaphor-flatten.md`, `metaphor-replace.md`, `metaphor-workshop.md`) and `README.md` describing the consolidated pipeline. These are dispatched by `agents/steps/metaphor-fix.md`, not by the orchestrator.

## Next Task Queueing

The prompts below are for maintaining *this* tooling repository — sprint planning, sprint execution, and milestone closeout. They are not invoked inside consuming story projects. After completing a task in this repo, provide the next step text to the user so he can copy-paste it. When starting a new Sprint, use **PM New Sprint**. When uncompleted tasks remain in SPRINT.md, use **Sprint Orchestrator**. After all tasks are complete in SPRINT.md, provide **PM New Sprint**.

### PM New Sprint
You are an expert PM. See AGENTS.md and ROADMAP.md. We're going to work together to turn [next milestone number and title from ROADMAP.md] into a series of Tasks within SPRINT.md. We will focus on requirements, not implementation. However, we will provide specifics if it will answer necessary design decisions for the developer. The goal is that our developers can grab a task and complete it in the way they want, with minimal intervention, and they'll produce a result that meets the project's needs. This is the stage to ask questions.

### Sprint Orchestrator
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

**Closeout.** Personally verify that all sprint objectives have been completed. Check Sprint boxes and mark milestones complete. Do not erase or overwrite SPRINT.md, just mark items completed.

**Output discipline.** Brief status updates between waves: what shipped, what's next. Don't narrate subagent internals — summarize their results in one or two sentences each.
