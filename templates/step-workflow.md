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

If the step cannot complete because of missing or ambiguous inputs, append the blocker to the project root `open-questions.md` and exit without advancing the pipeline marker. Do not fabricate inputs and do not write partial outputs. The next dispatcher invocation will re-run this step after the human resolves the blocker.
