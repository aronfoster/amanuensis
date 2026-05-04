# Amanuensis Roadmap

This roadmap covers turning Amanuensis into an orchestrated drafting pipeline that runs from a story plan through refined prose. Pre-writing (turning vague story ideas into structured plans) is out of scope and lives in the deferred work section at the bottom.

## Goal

A scheduled or human-invoked agent (Claude Code, OpenCode, etc.) advances a project one step at a time through a pipeline defined by Amanuensis. Each step is a fresh agent invocation with no carried context. State lives in the filesystem. The human reviews artifacts between steps and edits files freely.

## Pipeline (MVP)

The orchestrator runs these steps in order, one per invocation:

1. character_extraction
2. scene_generation
3. storyboarding
4. drafting
5. compliance_report
6. compliance_fix
7. prose_pass
8. metaphor_identify
9. metaphor_fix
10. metaphor_apply
11. line_pass
12. anti_ai

Continuity review, scene knowledge update, and post-chapter update are deferred.

## Architecture decisions (locked)

- Each step is a fresh agent invocation. No context carries between steps. State lives in files.
- Each step has a workflow file with frontmatter declaring `step_id`, `review_required`, `inputs`, `outputs`, plus a body that defines the step's behavior.
- The orchestrator is a dispatcher plus a state file. The dispatcher reads the state file, finds the `[>]` marker, runs that step's workflow, advances the marker on completion, exits.
- The state file is markdown with `[x]` / `[>]` / `[ ]` markers and minimal yaml frontmatter for project_type and last_updated.
- The marker advances on step body completion regardless of `review_required`. Human review happens on the artifact between invocations.
- Project type (`short_story` / `book` / `series`) is declared in `amanuensis-project.yaml` at project root. Folder layout adapts to project type. Filename prefixes are dropped; folder paths and frontmatter carry chapter and book identity.
- Highest-numbered attempt folder is the current attempt. No attempt tracking in state file.
- The metaphor pipeline collapses to three orchestrator steps: identify, fix (handles flatten/replace/workshop together based on file annotations), apply.

## Milestones

The roadmap is grouped by Milestone. Milestones are ordered such that finishing a Milestone leaves Amanuensis in a usable state, even if subsequent Milestones are not yet started.

---

### Milestone 1 — Foundations

Goal: define the contract every step workflow must satisfy, and the project structure every consuming repository must have.

1. Write `agents/orchestrator.md` defining the dispatcher behavior, the state file format, the step workflow contract (frontmatter fields, input/output conventions, exit semantics), and the rules for advancing markers and handling errors.
2. Write `agents/templates/step-workflow.md` as the template for individual step workflow files.
3. Write `agents/templates/pipeline-state.md` as the template state file.
4. Write `agents/templates/amanuensis-project.yaml` defining `project_type` and any other project-level configuration the dispatcher needs.
5. Document the project_type-dependent folder conventions in `agents/project-layouts.md`. Cover short_story, book, and series. Include the rule that folder paths replace filename prefixes.
6. Update `AGENTS.md` to reference the new orchestrator and project-layout documents.

---

### Milestone 2 — Refactor existing workflows to the step contract

Goal: every workflow that already exists becomes a conforming step. No new step bodies yet, only contract conformance.

7. Refactor `agents/storyboarding.md` to the step-workflow contract. Add frontmatter, declare inputs and outputs, mark `review_required: true`.
8. Refactor `agents/drafting.md` similarly. Mark `review_required: true`.
9. Refactor `agents/agentic-drafting.md` so the chapter coordinator is invokable as a single orchestrator step that internally dispatches subagents. The orchestrator does not see the subagents; it sees one step that produces a draft.
10. Split `agents/compliance.md` into two step workflows: `compliance_report.md` (`review_required: true`) and `compliance_fix.md` (`review_required: false`, runs against the annotated report).
11. Refactor `agents/prose-pass.md` to the step contract. `review_required: true`.
12. Refactor the metaphor pipeline:
    - `agents/metaphor/metaphor-identify.md` becomes step `metaphor_identify`. `review_required: true`.
    - Create `agents/metaphor/metaphor-fix.md` as a single step that reads the working file, dispatches flatten / replace / workshop logic per entry annotation, and appends variants. `review_required: true`. Remove workshop's Milestone 2 (integration) entirely; integration is metaphor_apply's job.
    - `agents/metaphor/metaphor-apply.md` becomes step `metaphor_apply`. `review_required: false`.
13. Refactor `agents/line-pass.md` to the step contract. `review_required: true`.
14. Refactor `agents/anti-ai.md` to the step contract. `review_required: true`. Anti-AI is always last in the pipeline.

---

### Milestone 3 — Build the missing step bodies

Goal: write the step workflows that don't yet exist.

15. Write `agents/character-extraction.md`. Input: project's story plan (a project-specific input file referenced by the project's local `AGENTS.md`). Output: character files in `characters/<id>/` plus appended entries to `open-questions.md` for unresolved character details. `review_required: true`. Follow the existing character-folder conventions in `agents/characters.md`.
16. Write `agents/scene-generation.md`. Input: story plan plus character files. Output: `scene-list.md` for the chapter (or for the short story, depending on project_type). Plus appended `open-questions.md` entries. `review_required: true`.
17. Both new step workflows must conform to the step contract from Milestone 1.

---

### Milestone 4 — Drop filename prefixes

Goal: rename files across the workflow set to remove `xx-yy-` prefixes; folder paths and frontmatter carry the metadata instead.

18. Update all step workflow files to reference path conventions without `xx-yy-` prefixes. Output paths become `<chapter-folder>/summary.md`, `<chapter-folder>/storyboards/scene01-beat003.md`, etc.
19. Update templates and examples accordingly.
20. Update mgp-story when adopting the new amanuensis version. This is a project-level rename, mechanical but project-wide. Document the migration as a one-time task in mgp-story's local notes.

---

### Milestone 5 — Dispatcher implementation

Goal: a runnable dispatcher that reads state, runs the next step, advances state.

21. Decide host: Claude Code or OpenCode. Per your preference, start with one. Commit to portability later.
22. Implement the dispatcher as the chosen host's native primitive. For Claude Code this is likely a slash command or an agent definition that reads `pipeline-state.md`, identifies the `[>]` step, invokes the corresponding step workflow file, advances the marker, exits.
23. Define the convention for mapping `step_id` to workflow file path (e.g., `step_id: metaphor_identify` → `amanuensis/agents/metaphor/metaphor-identify.md` or `amanuensis/agents/steps/metaphor-identify.md`, whichever organizational choice the orchestrator makes in Milestone 1).
24. Test the dispatcher end-to-end on a trivial project: empty story plan, dispatcher runs character_extraction, exits, run again, advances. No actual prose generation needed for the first test.

---

### Milestone 6 — End-to-end short story

Goal: prove the pipeline by running it on a real short story from plan to refined prose.

25. Pick or write a short story plan. Set up the project with `project_type: short_story`.
26. Run the orchestrator step-by-step. Capture frictions: missing inputs, unclear outputs, step bodies that produce the wrong shape of artifact, places where the human review gate is awkward.
27. Fix issues found in the run. Iterate.
28. Document the short_story end-to-end flow as an example in `examples/short-story-walkthrough.md`.

---

### Milestone 7 — Adopt in mgp-story

Goal: replace mgp-story's current ad-hoc workflow with the orchestrator-driven pipeline.

29. Add updated amanuensis as a submodule in mgp-story (deferred from earlier migration plan).
30. Rewrite `mgp-story/AGENTS.md` as the project adapter, declaring project_type: series and pointing at amanuensis workflows.
31. Set up `pipeline-state.md` for the chapter currently in flight.
32. Run a chapter through the orchestrator. Capture frictions specific to the series project type.
33. Fix issues. Iterate.

---

## Deferred work

These are tracked but explicitly out of scope for the current roadmap:

- **Pre-writing pipeline.** Turning vague story ideas into structured plans through agentic conversation. Discussed extensively but deferred until the drafting pipeline is solid.
- **Multi-host portability.** Make the dispatcher run identically across Claude Code, OpenCode, Gemini CLI. Will be tackled after the first host implementation surfaces concrete portability constraints.
- **Continuity review step.** Compare reveal timing against character knowledge files; flag premature knowledge or contradictions.
- **Scene knowledge update step.** Apply confirmed knowledge deltas to character files after drafting.
- **Post-chapter update step.** Aftermath, relationships, timeline updates.
- **Pass interaction rules.** Define what triggers re-running an earlier pass when a later pass changes prose. Currently: passes run once, in order.
- **Storyboard review step.** A dedicated review pass between storyboarding and drafting. Acceptable risk for now since drafting failure surfaces storyboard problems anyway.
- **Aftermath workflow.** Templates, schema, review pass for `aftermath.md`. Deferred until aftermath is actually used.
- **Improved review-gate UX.** Beyond "edit files freely between invocations." Possibly diff views, structured approval, change tracking.
- **Per-attempt state tracking.** Currently the convention is highest-numbered attempt is current. Revisit if comparing attempts becomes a frequent operation.
- **Multi-work concurrency.** Multiple chapters in flight simultaneously across a series. Currently MVP assumes one work at a time.

## Non-goals

- Reorganizing canon or character files in mgp-story.
- Designing new prose-quality passes beyond what already exists.
- Building the dispatcher as a standalone tool independent of an LLM agent host.
- Solving the "what is good prose" problem. The pipeline is structural; quality judgments stay with the human and the existing review passes.
