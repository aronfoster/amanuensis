# Amanuensis

---

**/əˌmæn.juˈen.sɪs/**: a person employed to write or type what another dictates, or to copy what has been written, acting as a literary assistant, secretary, or scribe.

---

Amanuensis is a workflow harness for long-form writing with LLMs.

It keeps planning, drafting, continuity, reveal timing, and prose-quality review structured as separate passes so long-form projects remain legible across chapters and books.

## Status

**NOT YET WORKING**

## Contents

- `agents/` — reusable workflow guidance for canon, character state, chapter planning, storyboarding, drafting, compliance, prose review, and related passes.
- `agents/metaphor/` — metaphor identification and revision workflow.
- `templates/` — reusable markdown templates for story-state files, prompt examples, and project-integration examples.
- `opencode/` — source templates for OpenCode runtime files. Consuming projects sync these into their root `.opencode/` directory.

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

## Submodule Integration

Recommended consuming project layout:

```text
story-project/
  amanuensis/      # git submodule
  .opencode/      # OpenCode runtime files synced from amanuensis/opencode/
  AGENTS.md       # project-local adapter
  voice.md        # project voice file (started from amanuensis/templates/voice.md)
  canon/
  characters/
  locations/
  plot/
```

Add Amanuensis as a submodule from the consuming project root:

```sh
git submodule add git@github.com:aronfoster/amanuensis.git amanuensis
git add .gitmodules amanuensis
git commit -m "Add Amanuensis as submodule"
git push
```

The local `AGENTS.md` should tell agents where the story files live and point them to `amanuensis/agents/` for reusable workflows. See `templates/project-AGENTS.md`.
