---
# step_id: canonical name of this step. snake_case. Must match the entry in pipeline-state.md exactly.
step_id: <snake_case_id>

# review_required: true if a human is expected to review this step's output before the next step runs.
# The dispatcher does not enforce this; the value is a signal to the human reading the state file.
review_required: <true|false>

# inputs: files this step reads. Use <chapter-folder>, <book-folder>, and <latest-attempt> placeholders
# where appropriate; see agents/project-layouts.md for resolution rules.
inputs:
  - <chapter-folder>/<input-file>.md

# outputs: files this step writes. Same placeholder conventions as inputs.
outputs:
  - <chapter-folder>/<latest-attempt>/<output-file>.md

# preconditions: machine-readable declaration of this step's inputs, one entry per input, checked
# by the dispatcher before the step body runs (every required: true entry must resolve to at least
# one existing file). Additive: the inputs/outputs lists above stay descriptive. All keys are
# explicit on every entry; there are no defaults.
#   kind: one of source | prose_draft | side_artifact.
#     prose_draft — a versioned draft resolved via <latest-draft>.
#     side_artifact — a report/annotation artifact produced by another step.
#     source — everything else the step reads (plans, scene lists, storyboards, canon, voice, config).
#   required: true — the step cannot start safely without it; false — a conditional-use input.
#   review_sensitive: true — the input is expected to carry human annotations/review before this
#     step consumes it; false — otherwise.
preconditions:
  - path: <chapter-folder>/<input-file>.md
    kind: <source|prose_draft|side_artifact>
    required: <true|false>
    review_sensitive: <true|false>
---

See `agents/orchestrator.md` for the step workflow contract.

# <Step Name>

## Purpose

<One paragraph: what this step accomplishes and why it exists in the pipeline.>

## Inputs

<For each file in the frontmatter `inputs` list, describe what it is and what this step expects from it. One bullet or short paragraph per input.>

## Behavior

<The bulk of the document. Describe what the step does, in the order it does it. Use bullets, prose, or examples. Be specific enough that an agent running this body produces the declared outputs without consulting other documents.>

## Outputs

<For each file in the frontmatter `outputs` list, describe what the step writes and the expected shape of the artifact (sections, frontmatter, structure). One bullet or short paragraph per output.>

## Open questions handling

If the step cannot complete because of missing or ambiguous inputs, append the blocker to the project root `open-questions.md` and exit without recording completion in `pipeline-state.md`. Do not fabricate inputs and do not write partial outputs. The next dispatcher invocation will re-run this step after the human resolves the blocker. On a successful run, the step's final action is to mark its own step line `[x]` in `pipeline-state.md` and update `last_updated`.
