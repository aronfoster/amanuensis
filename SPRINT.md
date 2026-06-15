# Sprint 6 — Milestone 1: Pipeline step-list consistency

This Sprint makes every step list in the repository agree with the actual step
workflow files in `agents/steps/`, designates `templates/pipeline-state.md` as the
single canonical source of the default step sequence, removes the duplicated
enumeration from `agents/orchestrator.md`, and adds an executable consistency check
guarded by CI in this repo. It also ships a portable version of that check to
consuming projects: `install.sh` installs a CI workflow that validates the
consuming project's own `pipeline-state.md` against the step files installed via the
Amanuensis submodule.

After this Sprint, a maintainer cannot merge a change that adds, removes, or
renames a step workflow file without either updating the canonical list to match or
failing CI; and a consuming project gets the same protection against a
`pipeline-state.md` that references a step the installed Amanuensis version does not
provide.

## Background — what is and isn't wrong today

Established by inspection during planning; tasks should not re-derive this:

- `templates/pipeline-state.md` is **already correct**: its 13 steps
  (`character_extraction` … `anti_ai_report`, `anti_ai_fix`) match the 13 files in
  `agents/steps/` exactly. This file becomes the canonical source; it is not being
  rewritten, only annotated and pointed-to.
- `examples/smoke/pipeline-state.md:25` is **stale**: it ends with the monolithic
  `anti_ai` instead of the `anti_ai_report` / `anti_ai_fix` split. This is the only
  fixture edit M1.1 requires.
- `agents/orchestrator.md:60-74` embeds the full step list as part of its "State
  file format" example, ending with the same stale monolithic `anti_ai`. Removing
  this enumeration (M1.2) eliminates that stale reference as a side effect, so it is
  not separately patched.
- No **other** file embeds an ordered or monolithic step list. `README.md` has only
  prose; `agents/workflows.md` uses prose plus file links and already references
  `anti-ai-report.md` / `anti-ai-fix.md` correctly; `templates/project-AGENTS.md`
  carries an unordered partial catalog of step files with no `anti_ai` entry;
  `examples/smoke/README.md` says "canonical step list" as a reference, not an
  enumeration. M1.3 is therefore a **verification sweep**, not a set of edits —
  fix anything a fresh grep turns up, but expect to find nothing.

## Definition of done

The Sprint is complete when:

1. ROADMAP.md tasks M1.1, M1.2, and M1.3 are checked.
2. `examples/smoke/pipeline-state.md` lists `anti_ai_report` and `anti_ai_fix`
   instead of `anti_ai`, and its step list matches `templates/pipeline-state.md`
   exactly (same steps, same order).
3. `agents/orchestrator.md` contains **no** enumerated step list. Its "State file
   format" section points to `templates/pipeline-state.md` as the canonical example
   of both the file format and the default step sequence, retaining only prose that
   describes the frontmatter fields and the `[>]` / `[x]` / `[ ]` marker semantics.
4. `templates/pipeline-state.md` carries a short note declaring it the canonical
   default sequence and stating that its step set must match `agents/steps/`.
5. `scripts/check-pipeline-state.sh` exists, is executable, is POSIX-sh-compatible,
   and implements the two modes specified in Task 3. It exits non-zero with a clear,
   path-naming message on any mismatch and zero on success.
6. A CI workflow in this repo (`.github/workflows/`) runs the check on push and pull
   request and would fail if the template, the smoke fixture, or the `agents/steps/`
   set drifted out of agreement.
7. `install.sh` installs a consumer-side CI workflow
   (`templates/dispatcher/.github/workflows/pipeline-state-check.yml` →
   `<project>/.github/workflows/pipeline-state-check.yml`) in addition to the two
   dispatcher files, idempotently, creating `.github/workflows/` if missing. The
   installed workflow invokes `amanuensis/scripts/check-pipeline-state.sh` in
   resolvable mode against the consuming project's `pipeline-state.md`.
8. A fresh grep confirms no other hard-coded step list remains
   (`git grep -n "anti_ai\b" -- '*.md' '*.yaml' '*.sh'` returns nothing outside
   ROADMAP/SPRINT planning prose).
9. `AGENTS.md` lists the new script and the consumer workflow template in its Core
   documents, and its Setup section notes that `install.sh` now also installs the
   check workflow.

## Conventions adopted by this Sprint

Locked at the start so individual tasks don't rediscover them.

**Canonical source.** `templates/pipeline-state.md` is the single source of the
**default** step sequence. "Canonical list" everywhere in this Sprint means the
ordered step list in that file. The ground truth for *which steps exist* is the set
of files in `agents/steps/`; the canonical list must equal that set.

**Consuming projects may legitimately differ.** Per `agents/orchestrator.md`, a
consuming project customizes its own `pipeline-state.md` (steps may be omitted or
reordered per project or project type). Therefore the consumer-facing check is
**resolvable-only** — every listed step must resolve to an installed step file — and
is **never** exhaustive. Only this repo's own template and fixture are held to
exhaustive, ordered agreement.

**Two check modes.** The script supports:
- *resolvable* (default): every `step_id` in a given `pipeline-state.md` resolves to
  `<steps-dir>/<step-id-with-dashes>.md`. Used for consuming projects and for the
  smoke fixture.
- *exhaustive*: resolvable, **plus** every `<steps-dir>/*.md` basename appears in the
  list (no step file omitted). Used for `templates/pipeline-state.md`.

**Order vs set.** Membership is the rule against the step-files directory (the
filesystem has no inherent order). Ordered equality is enforced only between the
smoke fixture and the template (both are ordered lists in this repo).

**step_id → file path.** `step_id` snake_case → dashes → `<steps-dir>/<…>.md`, the
existing convention documented in `agents/orchestrator.md`. The script reuses it; it
does not invent a new mapping.

**Script style.** `scripts/check-pipeline-state.sh`, `#!/bin/sh`, no bashisms,
executable, clear error messages that name the offending path, non-zero exit on
failure — consistent with the existing `install.sh`.

**Mirror destination paths for installable files.** The consumer CI workflow source
lives at `templates/dispatcher/.github/workflows/pipeline-state-check.yml` and is
copied verbatim to the same relative path under the consuming project root. This
extends the Sprint-5 dispatcher convention (mirror source path == destination path)
to a third installed file.

**Revisiting the Sprint-5 minimal-install decision.** Sprint 5 locked "`install.sh`
copies only the two dispatcher files" and "does not modify the consuming project's
`.github`." This Sprint deliberately revises that: `install.sh` now also installs the
namespaced check workflow into the consumer's `.github/workflows/`. The file name is
Amanuensis-specific so it cannot clobber a consumer's unrelated workflows. No other
Sprint-5 install behavior changes.

**Submodule checkout in the consumer workflow.** The shipped workflow checks out
submodules (`actions/checkout` with `submodules: recursive`) so that
`amanuensis/scripts/check-pipeline-state.sh` and `amanuensis/agents/steps/` are
present when it runs. This is a hard requirement of the workflow, not optional.

**Scope.** This Sprint adds files (the script, the internal CI workflow, the consumer
workflow template) and edits a small number of existing files (`orchestrator.md`,
`templates/pipeline-state.md`, `examples/smoke/pipeline-state.md`, `install.sh`,
`AGENTS.md`, `ROADMAP.md`, and the smoke README). No step workflow bodies change. No
renames of existing step files.

---

## Tasks

### Task 1 — Fix the stale step in the smoke fixture [x]

**Goal.** Bring `examples/smoke/pipeline-state.md` into agreement with the canonical
list (M1.1).

**Requirements.**

- In `examples/smoke/pipeline-state.md`, replace the single `- [ ] anti_ai` line with
  the two lines `- [ ] anti_ai_report` and `- [ ] anti_ai_fix`, in that order, so the
  fixture's full step list matches `templates/pipeline-state.md` step-for-step and
  order-for-order.
- Do not change the marker position (`[>]` stays on `character_extraction`) or the
  frontmatter beyond what an honest edit requires. Leave `last_updated` as-is unless
  the developer chooses to refresh it; it is not load-bearing for this milestone.
- Confirm `examples/smoke/README.md` still reads correctly afterward. Its line about a
  "canonical step list with `[>]` on `character_extraction`" is a reference, not an
  enumeration, and should need no change — verify, don't rewrite.

**Done when.** `examples/smoke/pipeline-state.md` ends with `anti_ai_report` then
`anti_ai_fix`, and a diff of its step list against `templates/pipeline-state.md`'s
step list is empty.

---

### Task 2 — Make `templates/pipeline-state.md` canonical; strip the orchestrator's list [x]

**Goal.** Single-source the default sequence (M1.2, documentation half): the template
is canonical, and `agents/orchestrator.md` stops duplicating it.

**Requirements.**

- In `agents/orchestrator.md`, remove the enumerated step list from the "State file
  format" section (currently the fenced example containing `- [>] character_extraction`
  … `- [ ] anti_ai`). Per the locked decision, **remove the list entirely** — do not
  leave an elided skeleton of real step_ids.
  - Replace it with a pointer: `templates/pipeline-state.md` is the canonical example
    of both the file format and the default step sequence.
  - Retain (as prose, not as an enumeration) the description of the frontmatter fields
    (`project_type`, `last_updated`) and the `[>]` / `[x]` / `[ ]` marker semantics,
    plus the existing note that a project's list may be customized and the dispatcher
    reads whatever list is present. None of that surrounding prose names specific
    steps, so it stays.
  - After the edit, `agents/orchestrator.md` must contain zero step_id enumerations.
    The `step_id → path` mapping paragraph stays; it references the convention, not a
    list.
- In `templates/pipeline-state.md`, add a short note (a sentence or two, e.g. under
  the `## Steps` heading or in a comment) stating that this file is the canonical
  default step sequence and that its step set must match the files in
  `amanuensis/agents/steps/`. Keep it brief; this is a signpost, not a spec.
- Do not change the actual step lines in the template — they are already correct.

**Done when.** `agents/orchestrator.md` enumerates no steps and points to the
template as canonical; `templates/pipeline-state.md` declares itself canonical; the
two files do not contradict each other.

---

### Task 3 — Consistency-check script [x]

**Goal.** Provide the executable check that backs both the internal CI (Task 4) and
the consumer workflow (Task 5). This is the M1.2 "add a check" deliverable.

**Requirements.**

- Path: `scripts/check-pipeline-state.sh`, `#!/bin/sh`, executable, no bashisms,
  error-loud and non-zero on failure — matching `install.sh`'s style.
- Invocation (the developer chooses exact flag spelling; this is the required
  behavior):
  - `check-pipeline-state.sh <pipeline-state-file> <steps-dir>` — **resolvable** mode:
    parse the `## Steps` list from `<pipeline-state-file>`, extract each `step_id`
    (the snake_case token after the `- [ ]` / `- [>]` / `- [x]` marker), convert
    snake → dashes, and assert `<steps-dir>/<step-id-with-dashes>.md` exists. Fail,
    naming the offending `step_id` and the path it expected, if any does not.
  - `check-pipeline-state.sh --exhaustive <pipeline-state-file> <steps-dir>` —
    **exhaustive** mode: everything resolvable mode does, **plus** assert that every
    `<steps-dir>/*.md` basename (dashes → snake) appears in the list. Fail, naming any
    step file that is missing from the list.
- Parsing contract: step lines are list items whose marker is `[ ]`, `[>]`, or `[x]`
  followed by a single snake_case token. The `## Steps` heading delimits the block;
  lines outside it are ignored. The developer may tighten this, but it must handle the
  template and the smoke fixture as written.
- On success, exit 0 and print a one-line confirmation naming the file checked and the
  mode. On any failure, exit non-zero. Do not modify any file — this is read-only.
- The script must be runnable both from the repo root and from a consuming project via
  the submodule path (`amanuensis/scripts/check-pipeline-state.sh`). It must not assume
  its own location relative to the target files — both paths are passed as arguments.

**Done when.** Running the script in exhaustive mode on `templates/pipeline-state.md`
against `agents/steps/` exits 0; running resolvable mode on
`examples/smoke/pipeline-state.md` against `agents/steps/` exits 0; temporarily
introducing a bogus step line, or hiding a step file, makes the relevant mode exit
non-zero with a message naming the discrepancy.

---

### Task 4 — Internal CI workflow [x]

**Goal.** Guard this repo against step-list drift on every push and pull request
(M1.2 "add a check," CI half). Depends on Tasks 1–3.

**Requirements.**

- Add a GitHub Actions workflow under `.github/workflows/` in this repo (name is the
  developer's call, e.g. `pipeline-state-check.yml`). This repo has no existing CI;
  this introduces it. Keep it minimal — a single job on `push` and `pull_request`.
- The job must run, at minimum:
  - `scripts/check-pipeline-state.sh --exhaustive templates/pipeline-state.md agents/steps`
  - `scripts/check-pipeline-state.sh examples/smoke/pipeline-state.md agents/steps`
    (resolvable; the fixture may in principle omit steps, though today it does not)
  - An ordered-equality assertion between the smoke fixture's step list and the
    template's step list (e.g. `diff` of the two extracted, ordered step-id
    sequences). Fail if they differ. The extraction can reuse the script's parsing or
    a small inline `grep`/`sed`; the developer decides, but the property — fixture
    order == template order — must be enforced.
- The workflow needs no secrets and no submodule checkout (everything it reads lives
  in this repo). Use a stock `actions/checkout`.
- A red run must be a real signal: verify locally that breaking any of the three
  invariants (add/remove a step file without updating the template; desync the
  fixture from the template; reorder the fixture) makes the job fail.

**Done when.** The workflow exists, runs the three checks, and passes on the current
(post-Task-1/2) tree; a deliberately introduced drift fails it.

---

### Task 5 — Ship the consumer validator via `install.sh` [x]

**Goal.** Give consuming projects a rolldown path: a CI workflow, installed by
`install.sh`, that validates their own `pipeline-state.md` against the step files in
their installed Amanuensis submodule (M1.2 consumer-facing extension). Depends on
Task 3.

**Requirements.**

- Author the consumer workflow source at
  `templates/dispatcher/.github/workflows/pipeline-state-check.yml`, mirroring the
  dispatcher source-path convention so the install copy is structurally trivial.
  - The workflow runs on the consumer's `push` / `pull_request`.
  - It checks out the consumer repo **with submodules** (`actions/checkout` with
    `submodules: recursive`) so `amanuensis/` is populated.
  - It invokes `sh amanuensis/scripts/check-pipeline-state.sh pipeline-state.md
    amanuensis/agents/steps` (resolvable mode) against the consumer's project-root
    `pipeline-state.md`. Resolvable, never exhaustive — the consumer's list may
    legitimately be a subset or reordering.
  - Keep it self-contained and host-agnostic; it is a plain GitHub Actions file the
    consumer can edit after install.
- Update `install.sh`:
  - In addition to the two dispatcher files, copy
    `templates/dispatcher/.github/workflows/pipeline-state-check.yml` to
    `<target>/.github/workflows/pipeline-state-check.yml`, creating
    `<target>/.github/workflows/` if missing.
  - Keep the existing behavior intact: idempotent overwrite, fail loud and non-zero if
    a source file is missing (now three source files, not two), do not create the
    target project root, print a summary listing all copied files.
  - Preserve POSIX-sh compatibility and the self-locating behavior already in the
    script. The new copy is one more of the same operation, not a new mechanism.
- Do not have `install.sh` run the check, modify the consumer's other workflows, or
  touch anything beyond the three namespaced files. It installs; it does not execute.

**Done when.** `./install.sh /tmp/test-target` (empty pre-existing dir) creates all
three files including `/tmp/test-target/.github/workflows/pipeline-state-check.yml`
matching the source byte-for-byte; re-running is a clean no-op-equivalent overwrite;
a missing source file fails loudly; the installed workflow, read by eye, calls the
submodule script in resolvable mode against the consumer's `pipeline-state.md`.

---

### Task 6 — Sweep, docs, ROADMAP, verification [x]

**Goal.** Close M1.3, update the catalogs, and check the boxes. Depends on Tasks 1–5.

**Requirements.**

- **M1.3 verification sweep.** Run `git grep -n "anti_ai\b"` and
  `git grep -ln "\[>\] \|\[ \] "` across `*.md` / `*.yaml` and confirm no hard-coded
  ordered or monolithic step list survives outside `templates/pipeline-state.md` and
  `examples/smoke/pipeline-state.md`. Background says you should find nothing else; if
  you do (a list in `README.md`, `agents/workflows.md`, or
  `templates/project-AGENTS.md`), replace it with a reference to the canonical
  template rather than re-enumerating. Record in the commit message what the sweep
  found.
- **`AGENTS.md`.** Add `scripts/check-pipeline-state.sh` and
  `templates/dispatcher/.github/workflows/pipeline-state-check.yml` to the Core
  documents section with a one-line description each. In the Setup section, note that
  `install.sh` now also installs the pipeline-state check workflow into the consuming
  project's `.github/workflows/`. Do not rewrite unrelated sections.
- **`examples/smoke/README.md`.** Optionally add one line to the recipe showing the
  maintainer how to run `scripts/check-pipeline-state.sh` against the fixture, since
  the smoke fixture is now a checked artifact. Keep it short; this is a convenience,
  not a required step of the smoke test.
- **`ROADMAP.md`.** Check M1.1, M1.2, and M1.3. Update the milestone's "Done when" is
  satisfied; if it helps a future reader, add a one-line Note that the milestone also
  shipped a consumer-side validator (an intentional extension beyond the original
  three bullets). Do not edit other milestones.
- **Acceptance run.** Execute, and confirm green:
  - `scripts/check-pipeline-state.sh --exhaustive templates/pipeline-state.md agents/steps` → exit 0.
  - `scripts/check-pipeline-state.sh examples/smoke/pipeline-state.md agents/steps` → exit 0.
  - Ordered equality of the smoke fixture and template step lists.
  - `./install.sh /tmp/test-target` produces all three files; re-run clean.
  - `git grep -n "anti_ai\b" -- '*.md' '*.yaml' '*.sh'` returns nothing outside
    ROADMAP/SPRINT planning prose.
  - `agents/orchestrator.md` contains no enumerated step list.
- Mark each completed task in this Sprint file as `[x]`.

**Done when.** The sweep is clean, `AGENTS.md` lists the new artifacts, ROADMAP M1.1–
M1.3 are checked, the acceptance commands pass, and all Sprint tasks are checked.

---

## Out of scope for this Sprint

- Holding consuming projects' `pipeline-state.md` to the *exhaustive* canonical list.
  Consumers customize their sequence; only resolvability is checked downstream.
- Per-project-type canonical lists (separate `book` / `series` default sequences).
  There is one template today; multiple canonical lists are a future concern.
- Auto-running the check inside `install.sh`, or having `install.sh` modify any
  consumer file other than the three namespaced ones.
- Any change to step workflow bodies in `agents/steps/`, or renaming step files.
- Reworking the smoke test itself (Milestone-5 territory) beyond the optional
  one-line check note.
- The `agents/orchestrator.md` TODO about agents inventing missing canon (Milestone 3).
