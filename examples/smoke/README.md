# Amanuensis dispatcher smoke fixture

## What this is

This directory is a minimal `short_story` project committed inside the Amanuensis repo for one purpose: smoke-testing the dispatcher surface (`/run-step` and `/next-step` for Claude Code, the `run-step` and `next-step` agents for OpenCode) end-to-end against real step bodies. It is not a real story, not a tutorial, and not exercised by any automated test suite. The story plan in `plot/summary.md` is a single sentence — just enough that `character_extraction` has at least one named character to consider.

The goal of running the recipes below is to confirm that the dispatcher itself works: it locates `pipeline-state.md`, confirms the requested (or recommended-next) step_id appears in the recipe list, resolves the workflow file at `amanuensis/agents/steps/<step>.md`, verifies the step's `required: true` preconditions resolve to existing files, and follows the step body in the same session — the step body then either records its own completion or stops with a question. Validating the literary quality of the step bodies' output is **not** a goal here.

Four recipes cover the four selective-execution behaviors: the default recipe run in order (Recipe 1), rerunning a completed step (Recipe 2), a fix step blocking on a stale report (Recipe 3), and a non-dependent step running out of recipe order (Recipe 4). See `agents/orchestrator.md` for the canonical contract the dispatcher follows.

## Layout

Committed in this directory:

- `amanuensis-project.yaml` — `project_type: short_story`.
- `pipeline-state.md` — the project's recipe and status record: the canonical step list with every step `[ ]`.
- `plot/summary.md` — one-sentence story plan.
- `voice.md` — project-root voice file (started from `templates/voice.md`); the voice-consuming steps read it here. Committed so `install.sh` skips it and the fixture stays a valid consuming project, even though the smoke steps do not read it.
- `open-questions.md` — empty placeholder; step bodies append here when they block.
- `README.md` — this file.
- `.gitignore` — blocks accidental commits of the install artifacts and symlink listed below.

**Not** committed (produced by the recipes, removed by the reset procedure):

- `.claude/commands/run-step.md` and `.claude/commands/next-step.md` — copied in by `install.sh`.
- `.opencode/agents/run-step.md` and `.opencode/agents/next-step.md` — copied in by `install.sh`.
- `amanuensis` — symlink to the Amanuensis repo root (this repo). Lets the dispatcher resolve `amanuensis/agents/steps/<step>.md` exactly as it would under a real submodule install.
- `characters/` — written by `character_extraction` on a successful run (Recipes 1–2).
- `plot/drafts/attempt01/` — hand-authored for Recipes 3–4 (two filler drafts and a stamped `reviewer-actions.md`); on Recipe 4's success the fix step also writes `draft-v03.md` and `draft-manifest.md` here.

## Setup

From the Amanuensis repo root:

```sh
cd examples/smoke
ln -s ../.. amanuensis
./amanuensis/install.sh .
```

The symlink lets the dispatcher resolve `amanuensis/agents/steps/<step>.md` exactly as it would under a real submodule install at `<project>/amanuensis/`. The `install.sh` invocation copies the four dispatcher source files into `.claude/commands/run-step.md`, `.claude/commands/next-step.md`, `.opencode/agents/run-step.md`, and `.opencode/agents/next-step.md` under this directory.

After setup, this directory should contain:

```
.claude/commands/next-step.md
.claude/commands/run-step.md
.opencode/agents/next-step.md
.opencode/agents/run-step.md
amanuensis -> ../..
amanuensis-project.yaml
open-questions.md
pipeline-state.md
plot/summary.md
voice.md
README.md
.gitignore
```

## Verify the fixture (optional)

The smoke fixture's `pipeline-state.md` is a checked artifact. From the Amanuensis repo root, you can confirm every listed step resolves to an installed step file with:

```sh
sh scripts/check-pipeline-state.sh examples/smoke/pipeline-state.md agents/steps
```

This is a convenience for maintainers, not a required step of the smoke test — the same check runs in CI.

## Run — Claude Code

All recipes assume Setup is done and each dispatcher invocation happens in a fresh Claude Code session with cwd = `examples/smoke`. Recipe 2 follows directly from Recipe 1; Recipes 3 and 4 each start from a freshly reset fixture (see **Reset between runs**) plus the hand-authored files described inline.

### Recipe 1 — default recipe in order

```sh
# In a new Claude Code session, with cwd = examples/smoke:
/next-step
```

`/next-step` is the recommended-path convenience layer: it resolves the first non-`[x]` step in the recipe list — on the fresh fixture, `character_extraction` — reports its selection, and then proceeds exactly as `/run-step character_extraction` would: same precondition checks, same failure modes, one step per invocation. This recipe is identical in intent to the original single-step smoke run.

Two acceptable observable outcomes:

1. **Success.** The dispatcher reads `pipeline-state.md`, selects `character_extraction`, loads `amanuensis/agents/steps/character-extraction.md`, the step body identifies at least the lighthouse-keeper character (`rao`) plus the unnamed replacement, writes `characters/<id>/profile.md` and `characters/<id>/knowledge/baseline.md` for each, possibly appends `important` or `minor` entries to `open-questions.md` for stub fields, and as its final action flips `[ ] character_extraction` to `[x] character_extraction` and updates `last_updated`. No other checkbox changes — there is no marker to move. The dispatcher exits cleanly.
2. **Stop and ask.** The step body decides the one-sentence plan is too thin to proceed safely, appends a `critical` blocker to `open-questions.md` describing what could not be resolved, and exits without recording completion: the `character_extraction` line stays `[ ]` and `pipeline-state.md` is untouched (`last_updated` unchanged). The dispatcher exits cleanly.

Either outcome confirms the dispatcher is wired correctly. A third outcome — the dispatcher itself errors before reaching the step body — indicates a real defect in the dispatcher source, the install script, or the orchestrator contract, and is the failure mode this smoke test is designed to surface.

### Recipe 2 — rerun a completed step

Run after Recipe 1 succeeds (the `character_extraction` line is `[x]`):

```sh
# In a new Claude Code session, with cwd = examples/smoke:
/run-step character_extraction
```

The mechanism under test is rerun-of-a-completed-step. Using `character_extraction` is deliberate: it is the fixture's only cheaply runnable step, so it stands in for the fix/pass steps a real project would rerun.

Expected observable outcome: the dispatcher confirms `character_extraction` appears in the recipe, resolves the step file, checks preconditions, and runs the step body again. The existing `characters/` outputs are overwritten. The completion action is a no-op on the already-checked line — it stays `[x]`, `last_updated` refreshes, and **no downstream checkbox changes**: every other line stays `[ ]`. Rerunning never rewinds anything.

### Recipe 3 — fix step blocks on a stale report

Reset the fixture and repeat Setup. Then hand-author the following three untracked files. Per the `short_story` layout in `agents/project-layouts.md`, `<chapter-folder>` resolves to `plot/` and attempt directories are named `attemptNN`, so the attempt folder is `plot/drafts/attempt01/`.

`plot/drafts/attempt01/draft-v01.md`:

```markdown
The lamp went dark and Rao climbed the stair without a light.

He told no one what he found at the top.
```

`plot/drafts/attempt01/draft-v02.md`:

```markdown
The lamp went dark and Rao climbed the stair without a light.

He told no one what he found at the top, and by morning he had talked himself out of telling anyone at all.
```

`plot/drafts/attempt01/reviewer-actions.md` — a minimal compliance report stamped against `draft-v01.md`, carrying one `FIX`-annotated violation entry (shape per the Inputs section of `agents/steps/compliance-fix.md`):

```markdown
Reviewed-draft: draft-v01.md

## Compliance Report — Scene 001, 2026-07-02

### Block 001
- DEGRADED (must_preserve): Lamp failure cause — the block requires the lamp to fail on its own; the prose leaves the cause unstated. Prose: "The lamp went dark and Rao climbed the stair without a light." FIX: change "The lamp went dark" to "The lamp guttered out on its own"
```

Then:

```sh
# In a new Claude Code session, with cwd = examples/smoke:
/run-step compliance_fix
```

Expected observable outcome — a clean blocked exit, not a dispatcher error:

- The dispatcher's existence checks pass: `reviewer-actions.md` exists and `<latest-draft>` resolves (`draft-v02.md` is the highest-numbered draft in `plot/drafts/attempt01/`), so the step body loads. The storyboard precondition is `required: false`, so the absence of `plot/storyboards/` does not block dispatch.
- At step start, the step body compares the report's `Reviewed-draft: draft-v01.md` stamp against the current `<latest-draft>` (`draft-v02.md`), detects the mismatch, and appends the stale-report blocker to `open-questions.md`, recording the stamped draft and the current one.
- No `plot/drafts/attempt01/draft-v03.md` is written.
- No completion is recorded: the `compliance_fix` line stays `[ ]` and `pipeline-state.md` is untouched (`last_updated` unchanged).

### Recipe 4 — non-dependent step runs out of recipe order

Reset the fixture, repeat Setup, and hand-author the same three files as Recipe 3, with one difference: stamp the report against the current latest draft, so the first line of `plot/drafts/attempt01/reviewer-actions.md` reads:

```markdown
Reviewed-draft: draft-v02.md
```

The quoted prose anchor in the violation entry appears verbatim in `draft-v02.md`, so the fix step can locate it. Note that every upstream step in the recipe (`drafting`, `compliance_report`, etc.) is still `[ ]` — the point of this recipe is that recipe position does not gate execution; preconditions do.

```sh
# In a new Claude Code session, with cwd = examples/smoke:
/run-step compliance_fix
```

Expected observable outcome:

- The existence checks pass, and the step-start freshness check passes: the stamp names `draft-v02.md`, which is the current `<latest-draft>`.
- The step applies the single annotated fix and writes the full revised prose to `plot/drafts/attempt01/draft-v03.md` (the first sentence now opens "The lamp guttered out on its own…"; the untouched paragraph is copied through verbatim).
- An `Applied:` block is appended to `reviewer-actions.md`, and a `## draft-v03.md` entry is appended to `plot/drafts/attempt01/draft-manifest.md` (created here, since the hand-authored fixture has none).
- The step's final action flips `[ ] compliance_fix` to `[x] compliance_fix` and updates `last_updated` — out of recipe order, while every upstream line stays `[ ]`.

### Recipes 3–4 touch only untracked files

The hand-authored `plot/drafts/attempt01/` tree, and everything the fix step writes into it, lives entirely in untracked paths. Nothing new is committed under `examples/smoke/`, and the existing reset procedure below restores the committed baseline.

## Run — OpenCode

```sh
# In a new OpenCode session, with cwd = examples/smoke:
# Invoke the run-step or next-step agent — e.g. via OpenCode's primary-agent
# dispatch (`/agent next-step` or the host's equivalent for selecting a
# primary agent). For run-step, the step_id goes in the invoking message.
```

The same four recipes hold, with the `next-step` agent standing in for `/next-step` (Recipe 1) and the `run-step` agent standing in for `/run-step <step_id>` (Recipes 2–4). The expected observable outcomes are identical to the Claude Code lists above. The OpenCode dispatcher sources are held to behavioral parity with the Claude Code ones; only host-specific frontmatter and invocation differ.

## Reset between runs

```sh
git checkout examples/smoke/
git clean -fd examples/smoke/
```

`git checkout` restores `pipeline-state.md`, `open-questions.md`, and any other tracked file the run modified. `git clean -fd` removes the untracked install artifacts (`.claude/`, `.opencode/`), the `amanuensis` symlink, any `characters/` tree written by Recipes 1–2, and the entire hand-authored `plot/drafts/attempt01/` tree from Recipes 3–4 — including anything the fix step wrote into it (`draft-v03.md`, `draft-manifest.md`, the appended `reviewer-actions.md`). After both commands the fixture is back to the committed baseline.

To rerun, repeat the **Setup** section.

## What success looks like

For each recipe: the dispatcher located `pipeline-state.md`, confirmed the step_id appears in the recipe list (selecting the first non-`[x]` step in `/next-step`'s case), resolved the step workflow file under `amanuensis/agents/steps/`, verified every `required: true` precondition resolves to an existing file, and started executing the step body in the same session. From there one of:

- The step body completed, wrote its declared outputs, and as its final action marked its own step line `[x]` and updated `last_updated`. No other checkbox moved.
- The step body decided it could not proceed (a `critical` blocker in Recipe 1's stop-and-ask outcome, the stale-report blocker in Recipe 3), appended the blocker to `open-questions.md`, and exited without recording completion — `pipeline-state.md` untouched.

Failure modes — a missing or malformed `pipeline-state.md`, a requested step_id that does not appear in the recipe list, a missing step workflow file, a `required: true` precondition that resolves to no existing file (the dispatcher names the missing files and stops), or `/next-step` finding every step `[x]` (recipe complete) — should print a clear human-readable message and exit without modifying any project file. Surfacing one of those where a recipe does not expect it would mean the fixture is misconfigured or the dispatcher/orchestrator work has a defect; report it.
