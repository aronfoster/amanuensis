# Amanuensis Agent Guide

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

The pipeline's step bodies live in `agents/steps/`. Each file declares its `step_id`, `review_required`, `inputs`, and `outputs` in frontmatter and is dispatched by the orchestrator (see `agents/orchestrator.md`).

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

`character-extraction.md` and `scene-generation.md` are pending in Milestone 3.

## Support documents

These docs are referenced *by* step workflows; the dispatcher does not invoke them directly.

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

## Repository Boundary

Amanuensis is tooling, not story canon. Do not add project-specific canon, character state, plot files, or prose drafts here except as clearly marked examples.

Consuming story repositories should keep a small local `AGENTS.md` adapter that points back to these reusable workflows and defines project-local paths.

## Next Task Queueing

After completing a task, provide the next step text to the user so he can copy-paste it. When starting a new Sprint, use **PM New Sprint**. When uncompleted tasks remain in SPRINT.md, use **Developer Step for Sprint Task**. When all tasks are complete in SPRINT.md, use **PM Sprint Closeout**. After the closeout, provide **PM New Sprint**.

### PM New Sprint
You are an expert PM. See AGENTS.md and ROADMAP.md. We're going to work together to turn [next milestone number and title from ROADMAP.md] into a series of Tasks within SPRINT.md. We will focus on requirements, not implementation. However, we will provide specifics if it will answer necessary design decisions for the developer. The goal is that our developers can grab a task and complete it in the way they want, with minimal intervention, and they'll produce a result that meets the project's needs. This is the stage to ask questions.

### Developer Step for Sprint Task
See AGENTS.md and SPRINT.md. Complete Sprint [Sprint number from SPRINT.md header] Task [First incomplete task in SPRINT.md].

### PM Sprint Closeout
Complete Sprint [Sprint number from SPRINT.md header] from SPRINT.md. See AGENTS.md for additional guidance. Close out the Sprint, ensuring that all files referencing updated files have been updated, and all objectives have been met. Do not erase or overwrite SPRINT.md, just mark items completed.
