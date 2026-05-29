# Amanuensis dispatcher smoke fixture

## What this is

This directory is a minimal `short_story` project committed inside the Amanuensis repo for one purpose: smoke-testing the dispatcher (`/next-step` for Claude Code, `next-step` agent for OpenCode) end-to-end against a real `character_extraction` step body. It is not a real story, not a tutorial, and not exercised by any automated test suite. The story plan in `plot/summary.md` is a single sentence — just enough that `character_extraction` has at least one named character to consider.

The goal of running the recipe below is to confirm that the dispatcher itself works: it locates `pipeline-state.md`, resolves the `[>]` step, loads the workflow file at `amanuensis/agents/steps/character-extraction.md`, follows the step body in the same session, and either advances the marker or stops with a question. Validating the literary quality of the step body's output is **not** a goal here.

## Layout

Committed in this directory:

- `amanuensis-project.yaml` — `project_type: short_story`.
- `pipeline-state.md` — canonical step list with `[>]` on `character_extraction`, all others `[ ]`.
- `plot/summary.md` — one-sentence story plan.
- `voice.md` — project-root voice file (started from `templates/voice.md`); the voice-consuming steps read it here. Committed so `install.sh` skips it and the fixture stays a valid consuming project, even though the `character_extraction` smoke step does not read it.
- `open-questions.md` — empty placeholder; step bodies append here when they block.
- `README.md` — this file.
- `.gitignore` — blocks accidental commits of the install artifacts and symlink listed below.

**Not** committed (produced by the recipe, ignored by `.gitignore`):

- `.claude/commands/next-step.md` — copied in by `install.sh`.
- `.opencode/agents/next-step.md` — copied in by `install.sh`.
- `amanuensis` — symlink to the Amanuensis repo root (this repo). Lets the dispatcher resolve `amanuensis/agents/steps/<step>.md` exactly as it would under a real submodule install.
- `characters/` — written by `character_extraction` on a successful run.

## Setup

From the Amanuensis repo root:

```sh
cd examples/smoke
ln -s ../.. amanuensis
./amanuensis/install.sh .
```

The symlink lets the dispatcher resolve `amanuensis/agents/steps/<step>.md` exactly as it would under a real submodule install at `<project>/amanuensis/`. The `install.sh` invocation copies the dispatcher source files into `.claude/commands/next-step.md` and `.opencode/agents/next-step.md` under this directory.

After setup, this directory should contain:

```
.claude/commands/next-step.md
.opencode/agents/next-step.md
amanuensis -> ../..
amanuensis-project.yaml
open-questions.md
pipeline-state.md
plot/summary.md
voice.md
README.md
.gitignore
```

## Run — Claude Code

```sh
# In a new Claude Code session, with cwd = examples/smoke:
/next-step
```

Two acceptable observable outcomes:

1. **Advance.** The dispatcher reads `pipeline-state.md`, loads `amanuensis/agents/steps/character-extraction.md`, the step body identifies at least the lighthouse-keeper character (`rao`) plus the unnamed replacement, writes `characters/<id>/profile.md` and `characters/<id>/knowledge/baseline.md` for each, possibly appends `important` or `minor` entries to `open-questions.md` for stub fields, and as its final action flips `[>] character_extraction` to `[x] character_extraction`, sets `[>] scene_generation`, and updates `last_updated`. The dispatcher exits cleanly.
2. **Stop and ask.** The step body decides the one-sentence plan is too thin to proceed safely, appends a `critical` blocker to `open-questions.md` describing what could not be resolved, and exits without advancing. `[>]` stays on `character_extraction`. The dispatcher exits cleanly.

Either outcome confirms the dispatcher is wired correctly. A third outcome — the dispatcher itself errors before reaching the step body — indicates a real defect in the dispatcher source, the install script, or the orchestrator contract, and is the failure mode this smoke test is designed to surface.

## Run — OpenCode

```sh
# In a new OpenCode session, with cwd = examples/smoke:
# Invoke the next-step agent — e.g. via OpenCode's primary-agent dispatch
# (`/agent next-step` or the host's equivalent for selecting a primary agent).
```

The two acceptable observable outcomes are identical to the Claude Code list above. The OpenCode dispatcher source is held to behavioral parity with the Claude Code one; only host-specific frontmatter and invocation differ.

## Reset between runs

```sh
git checkout examples/smoke/
git clean -fd examples/smoke/
```

`git checkout` restores `pipeline-state.md`, `open-questions.md`, and any other tracked file the run modified. `git clean -fd` removes the untracked install artifacts (`.claude/`, `.opencode/`), the `amanuensis` symlink, and any `characters/` tree the step body wrote. After both commands the fixture is back to the committed baseline.

To rerun, repeat the **Setup** section.

## What success looks like

The dispatcher located `pipeline-state.md`, parsed it, resolved `character_extraction` to `amanuensis/agents/steps/character-extraction.md`, and started executing that step's body in the same session. From there one of:

- The step body completed, wrote its declared outputs, and as its final action advanced the marker to `scene_generation` with a fresh `last_updated`.
- The step body decided it could not proceed, wrote a `critical` blocker to `open-questions.md`, and exited without touching the marker.

Failure modes — missing `pipeline-state.md`, malformed state, no `[>]` marker, missing step file — should print a clear human-readable error and exit without modifying any project file. Surfacing one of those errors here would mean the fixture is misconfigured or one of Tasks 1–4 has a defect; report it.
