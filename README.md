# Amanuensis

A workflow harness for long-form writing with LLMs.

Amanuensis keeps planning, drafting, continuity, reveal timing, and prose-quality review structured as separate passes so long-form projects remain legible across chapters and books.

## Contents

- `agents/` — reusable workflow guidance for canon, character state, chapter planning, storyboarding, drafting, compliance, prose review, and related passes.
- `agents/metaphor/` — metaphor identification and revision workflow.
- `agents/templates/` — reusable markdown templates for story-state files.
- `opencode/` — source templates for OpenCode runtime files. Consuming projects sync these into their root `.opencode/` directory.
- `examples/` — prompt examples and project-integration examples.

## Intended Use

A writing project should keep its story content in its own repository and consume Amanuensis as tooling, usually as a submodule.

Story repositories own:

- canon
- characters
- locations
- plot and chapter files
- prose drafts
- project-specific voice or adapter notes

Amanuensis owns:

- workflow contracts
- agent instructions
- prompt templates
- reusable review passes
- OpenCode agent source templates

## OpenCode

OpenCode automatically loads agents from a project's root `.opencode/` directory. Amanuensis keeps canonical source files under `opencode/`; consuming projects should sync or copy those files into their own `.opencode/` runtime directory.

The sync script is planned but not implemented yet.
