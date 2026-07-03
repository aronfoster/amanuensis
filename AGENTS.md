# Amanuensis Agent Guide

## Known issues

- Claude Code for web sessions frequently fail to start when launched against the latest commit on `origin/main`. If a session fails to initialize, retry the session.
- In Claude Code for web sessions, `origin/main` is frequently **stale** — it can lag the true default branch by one or more already-merged PRs, so `origin/main` (and any `git merge-base HEAD origin/main` against it) is an unreliable baseline for "what changed on this branch." A `git fetch origin main` may not refresh it; rather than troubleshoot, anchor diffs and untouched-surface checks at the branch's actual start commit — capture `git rev-parse HEAD` before your first commit and diff against that SHA. This affects subagents given a baseline to diff against, too: pass them the captured start SHA, never `origin/main`. (Not applicable outside Claude Code for web — other hosts fetch `origin/main` normally.)

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

Amanuensis is an orchestrator-driven pipeline for long-form writing. Each project advances one step at a time: a human invokes a specific step with `run-step` (or the recommended next step — the first non-`[x]` entry in the recipe in `pipeline-state.md` — with `next-step`); the host-specific dispatcher validates that the step's machine-readable `required` preconditions resolve to existing files, follows the step body in a fresh agent invocation, and exits. The step body records its own completion in `pipeline-state.md` as its final action. State lives entirely in files — there is no in-memory context carried between steps. Within an attempt, `<latest-draft>` resolves to the attempt manifest's active head (its top-of-file `Active-head:` pointer), and a human can branch a rerun from an earlier draft with `run-step <step_id> from <draft-vNN>`, which overrides that resolution for one invocation (see `agents/project-layouts.md` for the lineage model). Humans review artifacts between steps; the dispatcher does not enforce review. Prose-derived side artifacts (the reports and annotations one step emits and another consumes) carry a derived freshness state — their `Reviewed-draft:` stamp compared to the active head — that the consuming step, not the dispatcher, checks at step start, and their review expectation stays a surfaced-not-enforced signal the dispatcher does not block on (see the Artifact-state section of `agents/orchestrator.md`). Step workflow files declare their inputs, outputs, and review expectations in frontmatter and describe their behavior in the body. Folder layout, including how path placeholders resolve, depends on the project's declared `project_type`.

## Core documents

- `agents/orchestrator.md` — orchestrator contract and dispatcher behavior.
- `agents/project-layouts.md` — folder conventions per project type (`short_story`, `book`, `series`).
- `templates/step-workflow.md` — template for new step files.
- `templates/pipeline-state.md` — template state file.
- `templates/amanuensis-project.yaml` — project-level config template.
- `templates/project-AGENTS.md` — adapter template for consuming repositories.
- `templates/voice.md` — starter voice profile that a consuming project copies to its project-root `voice.md`. The voice-consuming steps read the project-root `voice.md`, not this template; this repo holds only the starter.
- `install.sh` — copies the dispatcher files into a consuming project's `.claude/commands/` and `.opencode/agents/` folders, and installs the pipeline-state check workflow into `.github/workflows/`.
- `templates/dispatcher/.claude/commands/run-step.md` — Claude Code slash command implementing the core dispatcher operation: run a specific step by step_id, with an optional read-from draft argument to branch a rerun from an earlier draft.
- `templates/dispatcher/.claude/commands/next-step.md` — Claude Code slash command implementing the recommended-next convenience layer: resolve the first non-`[x]` step in the recipe and run it through the same machinery as `run-step`.
- `templates/dispatcher/.opencode/agents/run-step.md` — OpenCode agent implementing `run-step` at parity with the Claude Code version.
- `templates/dispatcher/.opencode/agents/next-step.md` — OpenCode agent implementing the recommended-next convenience layer at parity with the Claude Code version.
- `scripts/check-pipeline-state.sh` — consistency check between a `pipeline-state.md` and an `agents/steps/` directory, in resolvable (default) or exhaustive mode.
- `templates/dispatcher/.github/workflows/pipeline-state-check.yml` — consumer-side CI workflow installed by `install.sh`; validates the consumer's `pipeline-state.md` against the installed Amanuensis step files.

## Setup

From the consuming project's root, run `./amanuensis/install.sh` to copy the dispatcher into `.claude/commands/run-step.md`, `.claude/commands/next-step.md`, `.opencode/agents/run-step.md`, and `.opencode/agents/next-step.md`. `install.sh` also installs the pipeline-state check workflow into `.github/workflows/pipeline-state-check.yml`, creating that directory if missing. Prerequisite: Amanuensis must be present at `<project>/amanuensis/` (typically as a git submodule). See `templates/dispatcher/` and `agents/orchestrator.md` for the source-of-truth dispatcher contract.

## Step workflows

This is the catalog of step files this repo *provides to* consuming projects, not a how-to for writing prose. The pipeline's step bodies live in `agents/steps/`. Each file declares its `step_id`, `review_required`, `inputs`, and `outputs` in frontmatter and is dispatched by the orchestrator (see `agents/orchestrator.md`).

- `agents/steps/character-extraction.md` — reads the project's story plan and canon, then bootstraps the minimum `characters/<id>/` folders (profile + baseline knowledge) for every character the plan references.
- `agents/steps/scene-generation.md` — reads the story plan, character profiles and baseline knowledge, and canon, then writes the chapter's `scene-list.md` (or `plot/scene-list.md` for short stories).
- `agents/steps/storyboarding.md` — produces per-beat storyboard blocks from the chapter's scene list, summary, character knowledge, and canon, populating `reader_takeaway` for every block.
- `agents/steps/storyboard-review.md` — advisory, report-only pass over the chapter's storyboard blocks that checks each beat's `reader_takeaway` is supported and its reveals have prior setup, producing `storyboards/storyboard-review.md`.
- `agents/steps/drafting.md` — chapter coordinator that dispatches per-scene subagents and assembles their output into a single draft.
- `agents/steps/compliance-report.md` — checks the draft against storyboard Must-Contain / Must-Not-Contain requirements and canon, producing an annotated `reviewer-actions.md` report.
- `agents/steps/compliance-fix.md` — applies the human-annotated fixes from `reviewer-actions.md` to `<latest-draft>`, producing the next `draft-vNN.md` and appending an entry to the attempt's `draft-manifest.md`.
- `agents/steps/prose-pass.md` — advisory prose-quality pass over `<latest-draft>` that produces a report only, writing an annotated `prose-pass.md` whose human annotations are consumed by `prose_fix`.
- `agents/steps/prose-fix.md` — applies the human-annotated fixes from `prose-pass.md` to `<latest-draft>`, producing the next `draft-vNN.md` and appending an entry to the attempt's `draft-manifest.md`.
- `agents/steps/metaphor-identify.md` — extracts every live metaphor and simile from the latest prose into `metaphors.md`.
- `agents/steps/metaphor-fix.md` — coordinator step that dispatches one subagent per annotated entry in parallel (FLATTEN / REPLACE / WORKSHOP) and reassembles their variants into `metaphors.md`.
- `agents/steps/metaphor-apply.md` — applies the human-selected variant to `<latest-draft>`, producing the next `draft-vNN.md` and appending an entry to the attempt's `draft-manifest.md`.
- `agents/steps/line-pass.md` — chunked line-level voice and rhythm pass over `<latest-draft>`, producing the next `draft-vNN.md` and appending an entry to the attempt's `draft-manifest.md`.
- `agents/steps/anti-ai-report.md` — scans the line-pass output for AI-pattern flags across nine categories plus a flagged-words list, producing the annotated `anti-ai.md` report.
- `agents/steps/anti-ai-fix.md` — applies the human-annotated fixes from `anti-ai.md` to `<latest-draft>`, producing the next `draft-vNN.md` (the final manuscript output) and appending an entry to the attempt's `draft-manifest.md`.

## Support documents

This is the catalog of support files this repo *provides to* consuming projects; they are referenced *by* step workflows, and the dispatcher does not invoke them directly.

- `agents/update-rules.md` — safety rules around canon integrity, reveal timing, and downstream updates.
- `agents/workflows.md` — workflow order for book setup, chapter planning, drafting, continuity review, and post-chapter updates.
- `agents/canon.md` — rules for world-level truth files.
- `agents/books.md` — rules for book-level planning folders.
- `agents/chapters.md` — rules for chapter workflow files.
- `agents/characters.md` — rules for character profiles, knowledge state, timelines, and relationships.
- `agents/storyboard-schema.md` — schema for storyboard blocks.
- The voice file consumed by drafting, prose pass, line pass, and metaphor workshop is **not** kept here. It lives at the consuming project's root as `voice.md` (overridable by a path named in the project's top-level `AGENTS.md`). This repo ships only the starter at `templates/voice.md`.
- `agents/meta.md` — meta notes about the agent guide.
- `agents/metaphor/` — subagent prompt contracts (`metaphor-flatten.md`, `metaphor-replace.md`, `metaphor-workshop.md`) and `README.md` describing the consolidated pipeline. These are dispatched by `agents/steps/metaphor-fix.md`, not by the orchestrator.

**Working on this repo.** Small, self-contained changes — fixing a step body, updating a doc, tweaking a template — can be made directly by an agent: read the relevant Core/Support document above plus the file(s) being changed. Structured work — turning a `ROADMAP.md` milestone into tasks, or executing a full sprint against `SPRINT.md` — is done with the `pm-plan` and `sprint-orchestrator` Claude Code skills; those skills are the canonical protocol for that work, not this file.
