# Sprint 5 — Milestone 5: Dispatcher implementation

This Sprint delivers a runnable dispatcher for both Claude Code and OpenCode, an `install.sh` that places the dispatcher into a consuming project's host folders, and an end-to-end smoke test on a trivial `short_story` fixture committed to this repo. After this Sprint, a human can clone a consuming project, run `./amanuensis/install.sh`, type `/next-step` (or its OpenCode equivalent), and watch the pipeline state advance one step per invocation.

## Definition of done

The Sprint is complete when:

1. ROADMAP.md tasks 20–23 (Milestone 5) are checked.
2. `agents/orchestrator.md` documents the locked dispatcher behavior: same-session model, stop-and-ask on malformed state, marker advancement as the step body's final action, blocked-step path writes to `open-questions.md` and exits without advancing.
3. `templates/dispatcher/.claude/commands/next-step.md` exists and is a working Claude Code slash command that implements the orchestrator's dispatcher behavior end-to-end.
4. `templates/dispatcher/.opencode/agents/next-step.md` exists and is a working OpenCode agent definition that implements the same behavior at parity with the Claude Code version.
5. `install.sh` exists at the repo root, is idempotent, copies both dispatcher files into a target project's `.claude/commands/` and `.opencode/agents/` folders, creates missing parents, and is invocable as `./amanuensis/install.sh` from a consuming project root.
6. `examples/smoke/` contains a minimal `short_story` fixture (project config, pipeline state, empty story plan, `open-questions.md`) sufficient to exercise the dispatcher running `character_extraction`.
7. The smoke-test recipe documented in `examples/smoke/README.md` runs cleanly: install dispatcher into the smoke project; first invocation runs `character_extraction` (or stops with a question if blocked); a second invocation advances the marker accordingly. The recipe describes both Claude Code and OpenCode invocations.
8. `AGENTS.md` references the dispatcher source files and `install.sh` in its Core documents / setup section so a future agent can locate them without searching.

## Conventions adopted by this Sprint

These choices are locked at the start of the Sprint so individual tasks don't rediscover them.

**Hosts at parity.** Both Claude Code and OpenCode are first-class for MVP. The two dispatcher files have equivalent behavior; only host-specific frontmatter and invocation details differ. Neither host is a stub.

**Dispatcher model: same-session.** The dispatcher *is* the step body. When the human invokes `/next-step` in a fresh host session, the dispatcher prompt reads `pipeline-state.md`, loads the resolved step workflow file, follows that file's body in the same session, then advances the marker before exiting. The dispatcher does not spawn a subagent for the step body. The "fresh agent invocation" guarantee is honored because the human invokes the dispatcher fresh, not by host-side context isolation.

**Marker advancement is the step body's final action.** The step body, on successful completion, edits `pipeline-state.md` itself: flips the current `[>]` to `[x]`, flips the next `[ ]` to `[>]`, updates `last_updated`. If the step exits early (blocked, error), the marker is not advanced and the next dispatcher invocation re-runs the same step. The dispatcher does not advance the marker on the step body's behalf; nor does the step body advance it speculatively before the work is done.

**Blocked-step path.** A step that cannot complete writes a question to the project-root `open-questions.md` and exits without advancing the marker. The human resolves the blocker by editing files; the next dispatcher invocation re-runs the same step.

**Stop and ask on confusion.** If `pipeline-state.md` is missing, malformed, has no `[>]` marker, or the resolved step file does not exist on disk, the dispatcher stops and asks the human. It does not guess, does not invent state, does not advance anything. No automatic recovery.

**Step-id → file path.** `step_id` snake_case is converted to dashes and resolves to `amanuensis/agents/steps/<step-id-with-dashes>.md`. This is already documented in `agents/orchestrator.md`; this Sprint treats it as an existing convention to be referenced consistently, not a new design decision.

**Slash-command / agent name.** `next-step`. The Claude Code human types `/next-step`. The OpenCode equivalent is invoked under the same name.

**Source of truth: mirror destination paths.** Dispatcher source files live at:
- `templates/dispatcher/.claude/commands/next-step.md`
- `templates/dispatcher/.opencode/agents/next-step.md`

The install script copies these verbatim into the target project at the same relative paths under the project root. Mirroring keeps the install step a near-trivial copy and makes the destination obvious from the source location.

**Install script.** `install.sh` at the repo root, POSIX-sh-compatible, idempotent. Default target is the current working directory; the consuming-project flow is `cd <project-root> && ./amanuensis/install.sh`. Re-running refreshes the copies (overwrite). No symlink mode in MVP. No uninstall.

**Smoke fixture lives in this repo.** `examples/smoke/` is a committed `short_story` project with the bare minimum to invoke `character_extraction`. The dispatcher files copied in by `install.sh` are *not* committed inside `examples/smoke/.claude/` or `examples/smoke/.opencode/` — running the install script is part of the smoke-test recipe and proves the script works.

**Timezone.** `last_updated` uses whatever local timezone the host produces, with offset, in ISO 8601. Not normalized to UTC.

**No re-run convenience.** Re-running a step is the human editing `pipeline-state.md` by hand, as already documented in `agents/orchestrator.md`. No `--redo` flag, no extra slash command.

**No concurrency safety.** MVP does not address concurrent dispatcher invocations. Out of scope.

**Idempotency, scope.** This Sprint adds files (dispatcher sources, install script, smoke fixture, README) and edits a small number of docs (`agents/orchestrator.md`, `AGENTS.md`, `ROADMAP.md`). No renames, no migrations, no changes to existing step workflow bodies.

---

## Tasks

### Task 1 — Lock dispatcher behavior in `agents/orchestrator.md` [ ]

**Goal.** Bring `agents/orchestrator.md` into alignment with the locked Conventions above so that the implementation tasks have a single authoritative spec to point at.

**Requirements.**

- The "Dispatcher behavior" section currently describes the dispatcher as if it advances the marker after the step body completes. Rewrite it to match the same-session, step-body-owns-the-advance model:
  - Dispatcher reads `pipeline-state.md`, locates `[>]`.
  - Resolves step file path via the existing `step_id` → dashes convention.
  - Loads the step file and follows its body in the same session.
  - The step body's last successful action is to edit `pipeline-state.md` (flip `[>]` to `[x]`, flip next `[ ]` to `[>]`, update `last_updated`).
  - On block, the step writes to `open-questions.md` and exits without touching the marker.
- Add an explicit "Failure modes" subsection listing the stop-and-ask conditions: missing or malformed `pipeline-state.md`, no `[>]` marker, resolved step file does not exist. The dispatcher surfaces the problem to the human and exits; it does not attempt recovery.
- Resolve the existing `TODO: create centralized and organized location for questions to the human` by either (a) confirming `open-questions.md` at the project root is that location and removing the TODO, or (b) leaving the TODO with a note that this Sprint did not address it. Pick (a) unless there is a reason to defer.
- The `TODO` about agents inventing missing canon (in the step workflow contract section) is **not** in scope for this Sprint. Leave it as-is.
- The step_id → path mapping paragraph is already correct. Confirm it reads cleanly after the edits and that the dispatcher source files (Tasks 2 and 3) will be able to cite it verbatim.
- Do not introduce a host-specific section. The orchestrator doc stays host-agnostic; host wiring lives in the dispatcher source files.

**Done when.** `agents/orchestrator.md` reflects the locked Conventions with no contradictions, the failure-modes subsection exists, and the open-questions TODO is either resolved or explicitly deferred.

---

### Task 2 — Claude Code dispatcher [ ]

**Goal.** Author `templates/dispatcher/.claude/commands/next-step.md` as a working Claude Code slash command that implements the dispatcher behavior locked in Task 1.

**Requirements.**

- File path is exactly `templates/dispatcher/.claude/commands/next-step.md` so the install script's copy operation is structurally trivial.
- File uses Claude Code's slash-command format (markdown, optional frontmatter as the host expects). The developer chooses the exact frontmatter; what matters is that typing `/next-step` in Claude Code from a project where this file has been installed at `.claude/commands/next-step.md` runs the dispatcher.
- The body of the file must, at a minimum:
  - Read `pipeline-state.md` from the project root, parse its frontmatter and the step list, locate the `[>]` line.
  - Stop and ask the human on any of the failure-mode conditions from Task 1.
  - Read `amanuensis-project.yaml` for `project_type` if path resolution requires it.
  - Resolve the step workflow file at `amanuensis/agents/steps/<step-id-with-dashes>.md`. Stop and ask if missing.
  - Load and follow that step file's body in the same session.
  - Specify that the step body's final action is to edit `pipeline-state.md` (flip `[>]` to `[x]`, flip next `[ ]` to `[>]`, update `last_updated`) before exiting.
  - On a blocked step, append to project-root `open-questions.md` and exit without touching the marker.
- The file must point readers at `agents/orchestrator.md` for the canonical contract; it does not redefine the contract. Treat the dispatcher source as a thin host adapter over the orchestrator spec.
- Keep the file short. The goal is a clear procedure the host can follow, not a re-derivation of orchestrator.md.

**Done when.** The file exists at the specified path; invoking `/next-step` in a Claude Code session inside a project that has installed it advances the pipeline by one step (or stops cleanly per the failure modes). Verified during Task 5's smoke test, not during this task.

---

### Task 3 — OpenCode dispatcher [ ]

**Goal.** Author `templates/dispatcher/.opencode/agents/next-step.md` as a working OpenCode agent that implements the same dispatcher behavior at parity with Task 2.

**Requirements.**

- File path is exactly `templates/dispatcher/.opencode/agents/next-step.md`.
- File uses OpenCode's agent definition format. Existing prior art under `opencode/agents/` (chapter-coordinator, scene-drafter) is the reference for frontmatter shape; match its style.
- Behavior is identical to Task 2's Claude Code dispatcher. Same procedure, same stop-and-ask conditions, same hand-off to the resolved step file's body in the same session, same final-action contract for marker advancement.
- Any host-specific differences (model selection, mode, tool grants) are the developer's call. They must not change the dispatcher's observable behavior.
- The file must point readers at `agents/orchestrator.md` for the canonical contract; it does not redefine the contract.
- Where the Claude Code and OpenCode dispatcher bodies overlap (the procedural steps), the wording should be substantially the same so a future maintainer reading both files sees them as parallel implementations of one spec.

**Done when.** The file exists at the specified path; invoking `next-step` in an OpenCode session inside a project that has installed it advances the pipeline by one step (or stops cleanly). Verified during Task 5's smoke test, not during this task.

---

### Task 4 — `install.sh` [ ]

**Goal.** Write `install.sh` at the repo root that copies both dispatcher files into a consuming project's host folders, creating parent directories as needed, idempotent on re-run.

**Requirements.**

- Path: `install.sh` at the repo root. Executable (`chmod +x`).
- POSIX-sh-compatible (`#!/bin/sh`). Avoid bashisms unless there is a clear reason. The script will be run inside consuming projects with unknown shell environments.
- Usage:
  - `./amanuensis/install.sh` (no argument) installs into the current working directory.
  - `./amanuensis/install.sh <target-dir>` installs into `<target-dir>`.
  - The script resolves its own location to find the source files; it must work whether the user runs it from inside the Amanuensis repo, from inside a consuming project that has Amanuensis as a submodule, or via an absolute path.
- Behavior:
  - Locate `templates/dispatcher/.claude/commands/next-step.md` and `templates/dispatcher/.opencode/agents/next-step.md` relative to the script's own location.
  - Create `<target>/.claude/commands/` and `<target>/.opencode/agents/` if missing.
  - Copy each dispatcher file to its mirrored destination under `<target>`. Overwrite if present (idempotent refresh).
  - Print a short summary of what was copied where.
  - Exit non-zero on any error (missing source files, target dir not writable, etc.).
- Error handling:
  - If a source file is missing, fail loudly with an explicit message naming the missing path. Do not partially install.
  - If `<target-dir>` does not exist, fail with a message; do not create the project root.
- No flags beyond the optional positional `<target-dir>`. No `--symlink`, no `--dry-run`, no `--uninstall` for MVP.
- The script does **not** install Amanuensis itself, set up git submodules, or modify the consuming project's `AGENTS.md`. It only copies the two dispatcher files.

**Done when.** Running `./install.sh /tmp/test-target` (with `/tmp/test-target` as an empty pre-existing directory) creates `/tmp/test-target/.claude/commands/next-step.md` and `/tmp/test-target/.opencode/agents/next-step.md` matching the source files byte-for-byte. Re-running the same command succeeds without error and leaves the destination unchanged. Running with a missing target fails with a clear message.

---

### Task 5 — Smoke fixture and end-to-end test [ ]

**Goal.** Create `examples/smoke/` as a minimal committed `short_story` fixture and document the smoke-test recipe in `examples/smoke/README.md`. Run the recipe and confirm the dispatcher advances the marker as specified.

**Requirements.**

- Create `examples/smoke/` with the minimum content required for the dispatcher to invoke `character_extraction`:
  - `amanuensis-project.yaml` with `project_type: short_story`. Copy from `templates/amanuensis-project.yaml` and adjust as needed.
  - `pipeline-state.md` with the canonical step list, `[>]` on `character_extraction`, all others `[ ]`. Copy from `templates/pipeline-state.md`.
  - `plot/summary.md` — the project's story plan. May be near-empty (a single sentence is fine; the goal is to exercise the dispatcher's plumbing, not to produce real prose).
  - `open-questions.md` — empty (or with a single placeholder header) at the project root.
  - Any other directories the `short_story` layout in `agents/project-layouts.md` declares as required at `character_extraction` time. If the layout doc says they are created on demand, do not create them.
- Do **not** commit `examples/smoke/.claude/` or `examples/smoke/.opencode/`. The dispatcher copies are produced by running `install.sh` as part of the smoke-test recipe; committing them would bypass the test.
- Do **not** commit a copy of the `amanuensis/` submodule under `examples/smoke/`. The recipe instead documents how to run the dispatcher with this repo as the Amanuensis source. The simplest workable approach is fine — for example, running `install.sh` from this repo into `examples/smoke/`, then symlinking or expecting `examples/smoke/amanuensis` to point at the repo root during the test. The developer chooses; document what they chose.
- Author `examples/smoke/README.md` describing:
  - What the fixture is for (smoke-testing the dispatcher; not a real story).
  - The recipe to run the test once for Claude Code, once for OpenCode. Include the exact commands the human types.
  - The expected observable result: first invocation either runs `character_extraction` to completion and advances the marker to `scene_generation`, or stops with a question (if the trivial story plan is too thin for the step body to make progress). Both are acceptable outcomes for a smoke test; the goal is to confirm the dispatcher itself works, not to validate the step body.
  - How to reset the fixture between runs (`git checkout examples/smoke/`).
- Run the recipe. Confirm the dispatcher behaves as specified for both hosts. If `character_extraction` blocks on the trivial plan, that is acceptable as long as the block is the documented stop-and-ask path (writes to `open-questions.md`, marker not advanced).
- If the smoke run surfaces a defect in Task 1, 2, 3, or 4, fix the underlying file. The smoke test is the integration check.

**Done when.** `examples/smoke/` is committed with the minimum fixture; `examples/smoke/README.md` documents the recipe; running the recipe end-to-end on both hosts produces the observable result the README predicts; and the smoke run does not require ad-hoc edits to the dispatcher source files or the install script.

---

### Task 6 — Sprint wrap-up: `AGENTS.md`, ROADMAP, verification [ ]

**Goal.** After Tasks 1–5 land, do residual cleanup and check the relevant boxes.

**Requirements.**

- Update `AGENTS.md`:
  - Add the dispatcher source files (`templates/dispatcher/.claude/commands/next-step.md`, `templates/dispatcher/.opencode/agents/next-step.md`) and `install.sh` to the Core documents section, with a one-line description each.
  - Add a one-paragraph "Setup" or "Installation" section pointing consuming-project authors at `install.sh`. State the one-line invocation and the prerequisite (Amanuensis must be present at `<project>/amanuensis/`, typically as a submodule).
  - Confirm the rest of the file is still accurate. Do not rewrite sections that did not change.
- Update `ROADMAP.md`:
  - Check tasks 20, 21, 22, and 23 (Milestone 5) as complete.
  - Verify that Milestone 4's tasks 18 and 19 are also checked. If they are not — Sprint 4's wrap-up was supposed to do this — check them now and note the fix in the commit message. Do not silently leave them unchecked.
  - Do not edit any other roadmap content.
- Run the acceptance checks from the Definition of done:
  - `templates/dispatcher/.claude/commands/next-step.md` exists.
  - `templates/dispatcher/.opencode/agents/next-step.md` exists.
  - `install.sh` exists at the repo root, is executable, runs successfully against an empty target dir, and is idempotent on re-run.
  - `examples/smoke/README.md` exists and the recipe in it has been executed at least once successfully against both hosts.
  - `agents/orchestrator.md` describes the locked dispatcher behavior with no contradictions.
- Mark each completed task in this Sprint file as `[x]`.

**Done when.** `AGENTS.md` lists the new artifacts; ROADMAP.md M4 (18, 19) and M5 (20–23) boxes are checked; the smoke recipe is verified runnable; all Sprint tasks are checked.

---

## Out of scope for this Sprint

- Multi-host portability beyond Claude Code and OpenCode. Other hosts (Gemini CLI, etc.) are deferred per ROADMAP.
- A subagent-based dispatcher model (Option 2b from the Sprint planning discussion). MVP is same-session only.
- A re-run convenience for the dispatcher (e.g., `--redo storyboarding`). Re-running remains the human editing `pipeline-state.md` directly.
- Concurrency safety for simultaneous dispatcher invocations.
- Symlink installation, uninstall, or dry-run modes for `install.sh`.
- Resolving the `agents/orchestrator.md` TODO about agents inventing missing canon. That is a separate design question.
- Building out `examples/smoke/` into a real short story or running any pipeline step beyond `character_extraction`. Milestone 6 is the end-to-end short-story milestone; this Sprint stops at smoke-testing the dispatcher itself.
- Documenting the dispatcher's behavior in any consuming project's local AGENTS.md adapter. The template at `templates/project-AGENTS.md` may be lightly updated if Task 6's `AGENTS.md` edits make a parallel change obvious; otherwise leave it.
