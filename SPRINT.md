# Sprint 12 — Milestone 7: Selective step execution

This Sprint replaces the linear `next-step` cursor model with explicit, selective step invocation. Today the dispatcher is cursor-driven: exactly one `[>]` line in `pipeline-state.md` decides what runs, the step body's final action moves the cursor forward, and redoing anything means hand-editing markers backward (`agents/orchestrator.md:58-66`, `:91-98`). After this Sprint: `pipeline-state.md` is a recipe/status file — each step is `[x]` (completed at least once) or `[ ]` (not yet), with no cursor; a human invokes any specific step with `/run-step <step_id>` (Claude Code) or the `run-step` agent (OpenCode); the dispatcher validates that the step's machine-readable required preconditions resolve to existing files before following the step body; `/next-step` survives as a convenience layer that resolves the first non-`[x]` step and runs it through the same machinery; and the report→fix pairing is stated as an artifact-freshness rule (the `Reviewed-draft:` stamp), not as a position-in-the-list rule.

This is a documentation/prose-contract milestone plus two small shell-adjacent edits (`install.sh` gains two copies; `scripts/check-pipeline-state.sh` needs **no** change — its grammar already accepts `[ ]`/`[>]`/`[x]` without requiring a cursor, `scripts/check-pipeline-state.sh:18-22`, `:87`). Draft lineage is deliberately untouched: `<latest-draft>` remains the highest-numbered `draft-vNN.md` per M4; active heads and superseded branches are M8 (`ROADMAP.md:63-67`).

## Background — what is and isn't wrong today

Established by inspection during planning; tasks should not re-derive this.

- **The cursor is the control model.** `pipeline-state.md` requires a single `[>]` line; the dispatcher locates it, resolves the step file, and becomes the step body (`agents/orchestrator.md:58-66`; `templates/dispatcher/.claude/commands/next-step.md:11-17`). A missing `[>]` is a hard failure mode (`agents/orchestrator.md:86`). Redo = move `[>]` up and un-check downstream `[x]` markers (`agents/orchestrator.md:91-98`, `templates/pipeline-state.md:10`).
- **Marker advancement is the step body's final action.** On success the step flips `[>]`→`[x]`, next `[ ]`→`[>]`, and updates `last_updated` (`agents/orchestrator.md:66`). Every one of the 15 step files carries one "exit without advancing the pipeline marker" line in its open-questions boilerplate; `character-extraction.md:84-86` and `metaphor-fix.md:66` carry additional marker language. There is also a latent inconsistency to fix: `agents/orchestrator.md:48` says `last_updated` is "updated by the dispatcher on every advance" while `:66` correctly assigns it to the step body.
- **The freshness machinery M7.6 asks for already exists — only the framing is positional.** Each fix/apply step already checks its paired report's `Reviewed-draft:` stamp against `<latest-draft>` at step start and blocks on mismatch (`agents/steps/compliance-fix.md:31`, `agents/steps/prose-fix.md:26`). The orchestrator section that states the rule is titled and framed as *adjacency* — "No prose-advancing step may run between a report and its paired fix" (`agents/orchestrator.md:108-123`). M7.6 is a reframing of that section plus a name-sweep, not new machinery. The name "report→fix adjacency invariant" is referenced in `agents/steps/prose-pass.md:277`, `agents/steps/prose-fix.md:26`, `agents/steps/compliance-fix.md:99`, and several other step files (`git grep -n adjacency agents/`).
- **Step frontmatter is descriptive, not machine-readable.** `inputs`/`outputs` are explicitly "descriptive; nothing enforces it" (`agents/orchestrator.md:32`). Nothing distinguishes a required file from an optional one, a prose draft from a side artifact, or an input that carries human annotations (`templates/step-workflow.md:9-16`). ROADMAP M7.3 says preconditions are declared "**in addition to** descriptive `inputs` / `outputs`" (`ROADMAP.md:31-34`) — an additive block, not a rewrite of `inputs`.
- **The check script and CI tolerate the grammar change for free.** `check-pipeline-state.sh` parses list items with marker `[ ]`, `[>]`, or `[x]` and never requires a `[>]` (`scripts/check-pipeline-state.sh:18-22`, `:87`). The repo's own CI runs the exhaustive check on the template, the resolvable check on the smoke fixture, and an ordered-equality diff of the two step lists (`.github/workflows/pipeline-state-check.yml:14-34`); the consumer CI template runs resolvable-only (`templates/dispatcher/.github/workflows/pipeline-state-check.yml`). None of these parse the marker semantics, so retiring `[>]` costs zero script/CI edits — but the two state files must keep identical ordered step lists.
- **The dispatcher surface is two host files installed by `install.sh`.** `templates/dispatcher/.claude/commands/next-step.md` and `templates/dispatcher/.opencode/agents/next-step.md` are thin adapters over the orchestrator contract, copied (always overwritten) by `install.sh:66-109`. New command files must be added to `install.sh`'s source list, destination copies, and printfs, and to the smoke README's expected-layout listing (`examples/smoke/README.md:40-53`).
- **`AGENTS.md` describes the cursor model in three places.** The "How Amanuensis works" paragraph says the dispatcher "locates the next step … advances the marker, and exits" (`AGENTS.md:25`); the Core documents list names the two dispatcher files (`AGENTS.md:37-38`); Setup names the two installed copies (`AGENTS.md:44`).
- **The smoke fixture only exercises the happy path.** `examples/smoke/README.md` runs `/next-step` once against `character_extraction` and resets with `git checkout` + `git clean -fd` (`examples/smoke/README.md:65-98`). M7.9's rerun/stale/out-of-order verifications need hand-authored artifacts (a fake `drafts/attempt-01/` with stamped `reviewer-actions.md`); those land in untracked paths so the existing reset procedure already cleans them.
- **`review_required` stays a signal, not a gate.** The dispatcher explicitly does not enforce review (`agents/orchestrator.md:30`, `:71`); M7 does not change that. Dispatcher-level stale/review blocking is M9.6 (`ROADMAP.md:145-146`), and override recording is M9.5 (`ROADMAP.md:141-143`) — M7 defines the *terms* and leaves those mechanisms deferred.

## Definition of done

The Sprint is complete when:

1. ROADMAP.md tasks M7.1–M7.9 are checked.
2. `agents/orchestrator.md` opens its dispatcher story with an **Execution model** section defining, in one place: `runnable`, `blocked`, `stale`, `superseded`, `active`, `recommended next`, and `explicit override` (definitions locked in Conventions below). No section of the file requires a single `[>]` cursor, describes moving a marker forward/backward, or describes redo-by-rewinding; the "Re-running a step" section is replaced by selective-rerun semantics (`run_step` any step whose preconditions hold; completed steps stay `[x]`).
3. The orchestrator's step workflow contract defines the `preconditions:` frontmatter block (schema locked in Conventions) alongside the still-descriptive `inputs`/`outputs`, and the dispatcher contract specifies: two entry points (`run_step <step_id>` and the recommended-next convenience), required-precondition existence checking before the step body loads, the updated failure-mode list, and the new completion action (step marks its own line `[x]` and updates `last_updated`; blocked exit touches nothing).
4. The `## Report→fix adjacency invariant` section is renamed to `## Report→fix freshness invariant` with a "(formerly the report→fix adjacency invariant)" note, and its body states the rule in artifact-freshness terms: a fix/apply step may consume its paired report only when the report's `Reviewed-draft:` stamp names the current `<latest-draft>`, unless the human explicitly overrides. Stamp mechanics, the pairs list, and the overwrite-on-regenerate behavior are unchanged.
5. `templates/pipeline-state.md` and `examples/smoke/pipeline-state.md` are reframed as recipe/status files: header prose describes `[x]`/`[ ]` semantics and selective execution, the redo-by-marker instructions are gone, every step line is `[ ]`, and the two ordered step lists remain identical.
6. `templates/step-workflow.md` and all 15 `agents/steps/*.md` files declare a `preconditions:` block; no step file says "advancing the pipeline marker" (or any marker-advance variant) — the blocked-exit boilerplate says the step exits without recording completion; no step file references the invariant by its old "adjacency" name.
7. Four dispatcher files exist under `templates/dispatcher/`: `run-step` and `next-step` for each host, with `run-step` holding the core procedure and `next-step` a thin recommended-next layer over it. `install.sh` copies all four (always overwrite). Behavior and safety checks match across hosts (M7.8).
8. `AGENTS.md`'s "How Amanuensis works" paragraph, Core documents list, and Setup section reflect the selective model and the four installed files.
9. `examples/smoke/README.md` documents the M7.9 recipes: (a) default recipe runs in order via `/next-step`; (b) rerun of a completed step via `/run-step`; (c) a fix step blocks on a stale report; (d) a non-dependent step runs out of recipe order when its inputs are valid.
10. `sh scripts/check-pipeline-state.sh --exhaustive templates/pipeline-state.md agents/steps` and `sh scripts/check-pipeline-state.sh examples/smoke/pipeline-state.md agents/steps` both pass, and the CI ordered-equality diff of the two step lists is empty.
11. Verification greps confirm the sweep:
    - `git grep -n "\[>\]" -- templates examples agents` returns hits only where `[>]` is described as a deprecated/legacy marker.
    - `git grep -nE "advanc(e|es|ing) the (pipeline )?marker" -- agents templates` returns nothing.
    - `git grep -c "preconditions:" agents/steps/*.md` shows all 15 step files.
    - `git grep -n "adjacency" -- agents templates` returns only the "(formerly …)" note in `agents/orchestrator.md`.
    - `git grep -ln "run-step" -- install.sh AGENTS.md templates examples` shows `install.sh`, `AGENTS.md`, both new dispatcher files, both rewritten `next-step` files, and the smoke README.

## Conventions adopted by this Sprint

Locked at planning (the three starred items are owner decisions from this Sprint's planning session); tasks don't rediscover them.

- **★ State grammar: `[x]`/`[ ]` only; `[>]` is retired.** A step line is `[x]` (completed at least once) or `[ ]` (never completed). `[>]` in a pre-M7 file is read as a deprecated synonym of `[ ]` — which is exactly what recommended-next resolution yields for it — so existing consuming projects need no migration and `check-pipeline-state.sh` (which already accepts all three markers) needs no change. Richer status tokens (stale/superseded markers) were rejected: they duplicate artifact-derived state into a file where it can drift, and M9 puts freshness in artifact stamps instead. Templates and docs stop emitting `[>]`; parsers keep tolerating it.
- **Recommended next = the first non-`[x]` step in the recipe list**, resolved at invocation time. No cursor, no stored pointer. The recipe order in `pipeline-state.md` remains the recommended happy path, not the only legal path.
- **★ Command surface: add `run-step`, keep `next-step`.** `/run-step <step_id>` (Claude Code, argument via the slash-command argument mechanism) and a `run-step` OpenCode agent (step_id taken from the invoking message) are the core mechanism. `/next-step` / the `next-step` agent survive as the convenience layer: resolve the first non-`[x]` step, then proceed exactly as `run-step` would for that step_id — same precondition checks, same failure modes, one step per invocation. This preserves installed muscle memory and matches ROADMAP's two-entry-point wording (`ROADMAP.md:36-43`). A single command with an optional argument was rejected: it buries the model shift and makes OpenCode parity clunkier.
- **★ The M7.1 design note lands inside `agents/orchestrator.md`** as the new Execution model section, not as a separate design doc. orchestrator.md is already the canonical contract and M7.7 rewrites it anyway; a separate note would become a second source of truth, which M1's single-sourcing rule exists to prevent. (Sets the default for M8.1/M9.1 design notes: design lands in the doc that owns the contract, unless that doc doesn't exist yet.)
- **Vocabulary (M7.1), locked definitions.**
  - `runnable` — every `required: true` precondition of the step resolves to at least one existing file.
  - `blocked` — not runnable; at least one required precondition is missing. The dispatcher reports what's missing and stops without loading the step body.
  - `stale` — a side artifact whose `Reviewed-draft:` stamp names a draft other than the current `<latest-draft>`. Detected by the consuming step body at step start (as today), not by the dispatcher (that is M9.6).
  - `superseded` — a draft version other than `<latest-draft>`, and any side artifact stamped against one. (Full lineage semantics — active heads, abandoned branches — are M8.1's to define; M7 uses only this minimal sense.)
  - `active` — the draft currently resolved by `<latest-draft>` and the side artifacts stamped against it.
  - `recommended next` — the first non-`[x]` step in the recipe list.
  - `explicit override` — a deliberate human instruction to proceed despite a stale or blocked condition, always human-visible and never assumed. M7 defines the term; the recording mechanism (where the override is written down) is deferred to M9.5, and until then the existing path stands: the step blocks to `open-questions.md` and the human resolves it there (`agents/orchestrator.md:123`).
- **`preconditions:` schema (M7.3).** An additive frontmatter block — `inputs`/`outputs` stay descriptive prose-facing lists (ROADMAP: "in addition to", `ROADMAP.md:31-34`). One entry per input, all keys explicit (no defaults — the block exists to be machine-read, so explicitness beats brevity):

  ```yaml
  preconditions:
    - path: <chapter-folder>/drafts/<latest-attempt>/reviewer-actions.md
      kind: side_artifact        # source | prose_draft | side_artifact
      required: true
      review_sensitive: true
  ```

  - `kind: prose_draft` — a versioned draft resolved via `<latest-draft>`; `kind: side_artifact` — a report/annotation artifact produced by another step (carries or inherits a `Reviewed-draft:` stamp); `kind: source` — everything else the step reads (plans, scene lists, storyboards, canon, voice, config).
  - `required: true` means the step cannot start safely without it; `required: false` marks conditional-use inputs (canonical example: `metaphor_fix` needs `voice.md` only when a `WORKSHOP` entry exists, `agents/steps/metaphor-fix.md:26`).
  - `review_sensitive: true` marks inputs expected to carry human annotations/review before consumption (the annotated reports consumed by `compliance_fix`, `prose_fix`, `metaphor_fix`, `metaphor_apply`, `anti_ai_fix`).
  - Existence semantics: a glob pattern resolves if ≥1 file matches; a `<latest-draft>` path resolves if ≥1 `draft-vNN.md` exists in the latest attempt; placeholder resolution follows `agents/project-layouts.md` as today.
- **The dispatcher checks existence only.** `runnable` is purely "required files exist". Freshness (`Reviewed-draft:` stamps), annotation-completeness, and review state remain step-body checks exactly as today — lifting machine-checkable ones into the dispatcher is M9.6 (`ROADMAP.md:145-146`). This keeps M7's dispatcher change small and honest.
- **Completion action replaces marker advancement.** On success the step body's final action is to edit `pipeline-state.md`: set its own step line to `[x]` (a no-op if already `[x]` — reruns don't move anything) and update `last_updated`. On a blocked exit it touches `pipeline-state.md` not at all. Rerunning a step never un-checks downstream steps; artifact freshness (stamps now, M9 generally) is what protects downstream consumers, not checkbox state.
- **`run_step` for a step_id not listed in the recipe is a stop-and-ask failure mode.** The dispatcher does not guess and does not run unlisted steps: the human either mistyped or needs to add the step line to the recipe first. This matches the existing no-guessing posture (`agents/orchestrator.md:80-89`). Likewise, `next-step` with every step `[x]` reports the recipe complete and stops.
- **The invariant is renamed, not weakened.** "Report→fix freshness invariant (formerly the report→fix adjacency invariant)": a fix/apply step may consume its paired report only when the report was produced against the current `<latest-draft>`, verified via the `Reviewed-draft:` stamp at step start, human override excepted. The pairs list, stamp-overwrite-on-regenerate behavior, and `metaphor_fix`'s stamp-preserving role (`agents/orchestrator.md:119`) carry over verbatim. The full generalization to an artifact-state model is M9 (`ROADMAP.md:152-154`); ROADMAP's historical mentions of "adjacency" in completed milestones are left as history.
- **Draft lineage is out of scope.** `<latest-draft>` remains the highest-numbered `draft-vNN.md` (M4 rule). No manifest-head resolution, no supersession marking — that is M8 (`ROADMAP.md:63-67`).
- **Smoke recipes may hand-author untracked fixture artifacts.** The stale/out-of-order recipes fabricate a minimal `drafts/attempt-01/` (drafts plus a stamped, annotated `reviewer-actions.md`) inside `examples/smoke/`; these live in untracked paths so the existing `git checkout` + `git clean -fd` reset (`examples/smoke/README.md:89-98`) already removes them. Nothing new is committed to the fixture.

---

## Tasks

### Task 1 — Rewrite `agents/orchestrator.md` around the selective execution model

- [ ] Done

**Goal.** Land the M7.1 design as the orchestrator contract: execution-model vocabulary, recipe/status state semantics, two-entry-point dispatcher behavior with precondition checking, the preconditions schema, and the freshness reframe of the invariant. Closes **M7.1**, **M7.7**, and the contract side of **M7.2/M7.3/M7.6**.

**Requirements.**

- Add an **Execution model** section (before the current "Step workflow contract", after "Components") defining the seven locked terms exactly as the Conventions section above states them, and stating the model in one paragraph: correctness is governed by artifact preconditions, not by sequence position; the recipe order is the recommended path, not the only legal one; judgment lives with the human and the step bodies.
- Rework **State file format** (`agents/orchestrator.md:44-52`): `[x]`/`[ ]` semantics, no cursor, `[>]` documented once as a deprecated legacy marker read as `[ ]`, recommended-next = first non-`[x]`. Fix the `last_updated` attribution inconsistency (`:48` vs `:66`) — the step body updates it.
- Rework **Dispatcher behavior** (`:54-89`) around `run_step <step_id>` as the core operation: resolve the step workflow file (same underscore→dash rule, `:9`), parse its `preconditions:` block, verify every `required: true` entry resolves to at least one existing file, then follow the step body in the same session (still one step per invocation, still no review enforcement, still no multi-step runs). Define `next_recommended_step` as the layer that resolves the first non-`[x]` step_id and proceeds identically. Update the **Failure modes** list: drop the "no `[>]` marker" mode; add — requested step_id not listed in the recipe; a required precondition missing (dispatcher names the missing file(s) and stops); recipe complete (next-step with all `[x]`). Keep missing/malformed state file and missing step file modes.
- Replace marker advancement with the **completion action** (Conventions above) and replace the **Re-running a step** section (`:91-98`): rerun = invoke `run_step` for that step; completed steps stay `[x]`; downstream checkboxes are never rewound; freshness stamps protect downstream consumers.
- Extend the **Step workflow contract** section (`:13-42`) with the `preconditions:` schema exactly as locked in Conventions (keys, kind values, required/optional meaning, review_sensitive meaning, existence semantics), keeping `inputs`/`outputs` descriptive.
- Rename and reword the invariant section (`:108-123`) per Conventions ("Report→fix freshness invariant (formerly the report→fix adjacency invariant)"). Keep the pairs list, the stamp-overwrite rules, and the stale-exit-is-a-human-decision paragraph; strip the position-based framing ("No prose-advancing step may run between…" becomes a freshness statement).
- Update **What the orchestrator does not do** (`:125-133`): it now *does* check required-input existence at dispatch, but still does not enforce review, does not detect staleness at the dispatcher level (M9.6), does not enforce the recipe as the only order, and does not coordinate concurrent work.
- Remove all forward/back/redo movement language file-wide (M7.7).

**Done when.** `agents/orchestrator.md` reads as a selective-execution contract: the seven terms are defined once, no text requires or moves a cursor, the dispatcher contract covers both entry points with existence-checking and the updated failure modes, the preconditions schema is normative, and `git grep -n "adjacency" agents/orchestrator.md` returns only the "(formerly …)" note.

---

### Task 2 — Reframe both `pipeline-state.md` files as recipe/status files

- [ ] Done

**Goal.** Make the canonical state template and the smoke fixture match the new model. Closes the file side of **M7.2**.

**Requirements.**

- `templates/pipeline-state.md`: rewrite the header prose (`:8-10`) — the file is the project's recipe (recommended order) and status record (`[x]` completed at least once, `[ ]` not yet); steps are invoked selectively with `run-step`, or in recommended order with `next-step`; remove the redo-by-marker instructions entirely. Change `- [>] character_extraction` (`:16`) to `- [ ] character_extraction`. Keep the canonical-step-set comment (`:14`) and the frontmatter unchanged.
- `examples/smoke/pipeline-state.md`: identical reframing (`:8-14`); the fixture's list already mirrors the template — keep the ordered lists identical (the CI ordered-equality check, `.github/workflows/pipeline-state-check.yml:25-34`, must stay green).
- Do not rename, add, or reorder any step line in either file.

**Done when.** Neither file contains `[>]` or redo instructions; both describe recipe/status semantics; `sh scripts/check-pipeline-state.sh --exhaustive templates/pipeline-state.md agents/steps` and `sh scripts/check-pipeline-state.sh examples/smoke/pipeline-state.md agents/steps` pass; the two ordered step lists are identical.

---

### Task 3 — Preconditions block + completion-language sweep across the step contract files

- [ ] Done

**Goal.** Give every step machine-readable preconditions and retire marker-advance language from the step bodies. Closes **M7.3** and the step-file side of **M7.6**.

**Requirements.**

- `templates/step-workflow.md`: add a commented `preconditions:` block to the frontmatter template (mirroring the existing commented style, `:1-17`) documenting the schema keys; update the Open questions boilerplate (`:39-41`) to the new blocked-exit wording (exit without recording completion in `pipeline-state.md`).
- For each of the 15 files in `agents/steps/`: derive the `preconditions:` block from the existing frontmatter `inputs` list and the body's Inputs section, classifying each entry per the locked schema. Worked example for `compliance-fix.md` (from `agents/steps/compliance-fix.md:4-7`, `:24-35`):

  ```yaml
  preconditions:
    - path: <chapter-folder>/drafts/<latest-attempt>/reviewer-actions.md
      kind: side_artifact
      required: true
      review_sensitive: true
    - path: <chapter-folder>/drafts/<latest-attempt>/<latest-draft>
      kind: prose_draft
      required: true
      review_sensitive: false
    - path: <chapter-folder>/storyboards/*-storyboard.md
      kind: source
      required: false
      review_sensitive: false
  ```

  Classification anchors: annotated reports consumed by fix/apply steps (`reviewer-actions.md`, `prose-pass.md`, `metaphors.md`, `anti-ai.md`) are `side_artifact` + `review_sensitive: true`; `<latest-draft>` inputs are `prose_draft`; plans, scene lists, storyboards, canon, character files, `voice.md`, and config are `source`; conditional-use inputs are `required: false` (locked example: `metaphor_fix`'s `voice.md`, `agents/steps/metaphor-fix.md:26`; use body language like `compliance_fix`'s "read only the blocks referenced by FIX entries", `:33`, to judge others). Do not change any `inputs`/`outputs` list — the new block is additive.
- Sweep completion language in the same files: every "exit without advancing the pipeline marker" (one per step file; see also `character-extraction.md:84-86`, `scene-generation.md:97-102`, `metaphor-fix.md:66`) becomes the new wording — on a blocker the step exits without recording completion in `pipeline-state.md`; on success its final action marks its own step line `[x]` and updates `last_updated`. Keep the surrounding boilerplate shape (open-questions append, no fabricated inputs, re-run after the human resolves).
- Sweep invariant-name references in step files (`prose-pass.md:277`, `prose-fix.md:26`, `compliance-fix.md:99`, and the other hits of `git grep -n adjacency agents/steps`) to "report→fix freshness invariant", keeping each cross-reference pointed at `agents/orchestrator.md` as the canonical statement.
- No other body changes: step behavior, inputs read, outputs written, and stamp checks are all unchanged this Sprint.

**Done when.** All 15 step files and the template carry a schema-conformant `preconditions:` block; `git grep -nE "advanc(e|es|ing) the (pipeline )?marker" -- agents templates` returns nothing; `git grep -n adjacency agents/steps` returns nothing; both check-pipeline-state.sh modes still pass.

---

### Task 4 — `run-step` dispatchers, `next-step` as convenience layer, `install.sh`, `AGENTS.md`

- [ ] Done

**Goal.** Ship the host command surface: explicit invocation on both hosts, the recommended-path convenience on both hosts, installed by `install.sh` and cataloged in `AGENTS.md`. Closes **M7.4**, **M7.5**, **M7.8**.

**Requirements.**

- Create `templates/dispatcher/.claude/commands/run-step.md`: a thin adapter in the exact style of the current `next-step.md` (`templates/dispatcher/.claude/commands/next-step.md:5-7` — defer to `agents/orchestrator.md`, do not re-derive). It takes the step_id as the slash-command argument; procedure: read `pipeline-state.md`, confirm the step_id appears in the recipe list, resolve the workflow file (underscore→dash), parse `preconditions:`, verify `required: true` entries exist, then become the step body. Failure modes restated from the updated orchestrator contract (missing/malformed state file, step_id not in recipe, missing step file, missing required precondition — name the missing files and stop). Restate the completion action so a human reading the prompt knows what to expect (mirroring current `:17`).
- Create `templates/dispatcher/.opencode/agents/run-step.md`: same contract at parity, with the OpenCode frontmatter copied from the existing agent (`templates/dispatcher/.opencode/agents/next-step.md:1-12`); the step_id arrives in the invoking message.
- Rewrite both `next-step` files as the convenience layer: resolve the first non-`[x]` step in the recipe (treating a legacy `[>]` as `[ ]`), report which step was selected, then proceed identically to `run-step` for that step_id. If every step is `[x]`, report the recipe complete and stop. Keep the thin-adapter posture and the "canonical contract lives in orchestrator.md" framing.
- `install.sh`: add the two new files as always-overwrite dispatcher sources/destinations alongside the existing pair (`install.sh:66-109` — source vars, existence loop, `cp`s, printfs).
- `AGENTS.md`: update the "How Amanuensis works" paragraph (`:25`) to the selective model (dispatcher validates preconditions and runs the selected or recommended step; no marker advancement); add the two new dispatcher files to Core documents (`:37-38`); update Setup (`:44`) to name all four installed files.
- Host parity is a requirement, not an aspiration: the two `run-step` files must express the same checks and failure modes, as the two `next-step` files do today (M7.8).

**Done when.** All four dispatcher files exist under `templates/dispatcher/`; `sh install.sh <tmpdir>` copies all four (verify against a scratch directory); `AGENTS.md` reflects the new surface; the Claude and OpenCode variants of each command match in behavior and safety checks.

---

### Task 5 — Smoke coverage for selective execution

- [ ] Done

**Goal.** Document runnable verification recipes for the four M7.9 behaviors in the smoke fixture. Closes **M7.9**.

**Requirements.**

- Update `examples/smoke/README.md` throughout for the new command surface: the expected post-install layout (`:40-53`) gains `.claude/commands/run-step.md` and `.opencode/agents/run-step.md`; the existing run instructions (`:65-88`) describe `/next-step` as the recommended-path convenience; the fixture's `pipeline-state.md` description (`:14`) drops cursor language.
- Add four recipes (each with expected observable outcomes, in the style of the existing Run section):
  1. **Default recipe in order.** `/next-step` on the fresh fixture selects `character_extraction` (first non-`[x]`), runs it, and marks it `[x]`. Identical in intent to today's smoke run.
  2. **Rerun a completed step.** After recipe 1, `/run-step character_extraction` runs the step again; the line stays `[x]`; no downstream checkbox changes. (The mechanism under test is rerun-of-a-completed-step; using the fixture's only cheaply runnable step is deliberate.)
  3. **Fix step blocks on a stale report.** Hand-author, untracked inside the fixture: `plot/drafts/attempt-01/draft-v01.md`, `draft-v02.md` (a line or two of filler prose each), and a `reviewer-actions.md` stamped `Reviewed-draft: draft-v01.md` containing one `FIX`-annotated violation entry (shape per `agents/steps/compliance-fix.md:24-31`). `/run-step compliance_fix` must detect the stale stamp, append the stale-report blocker to `open-questions.md`, write no `draft-v03.md`, and record no completion. (Follow `agents/project-layouts.md` for the short_story chapter-folder path; adjust the path above if it differs.)
  4. **Non-dependent step runs out of recipe order.** Same fixture as recipe 3 but with the stamp reading `Reviewed-draft: draft-v02.md`: `/run-step compliance_fix` — with every upstream step still `[ ]` — passes the existence checks and the freshness check, applies the annotated fix, writes `draft-v03.md`, appends the manifest entry, and marks `compliance_fix` `[x]` out of order.
- State that recipes 3–4 rely only on untracked files, so the existing reset (`git checkout` + `git clean -fd`, `:89-98`) restores the baseline; commit nothing new under `examples/smoke/` except the README (and the `pipeline-state.md` change owned by Task 2).
- OpenCode section: state the same four recipes hold with the `run-step`/`next-step` agents at parity.

**Done when.** `examples/smoke/README.md` documents all four recipes with expected outcomes and the reset procedure covers them; no new tracked fixture files beyond the README edit.

---

### Task 6 — Verification sweep, ROADMAP / SPRINT check-off

- [ ] Done

**Goal.** Close the Sprint with documented verification and mark the milestone complete. Closes the residual of **M7**.

**Requirements.**

- Run and review every check in Definition of done items 10–11 (both check-pipeline-state.sh modes, the ordered-equality diff, and the five greps).
- Run `sh install.sh` against a scratch directory and confirm all four dispatcher files land.
- Confirm cross-file consistency by reading: the four dispatcher files against the updated `agents/orchestrator.md` contract (no drift, no re-derived rules); the `preconditions:` blocks of the five fix/apply steps against the Conventions classification anchors; `AGENTS.md` against the actual installed surface.
- Confirm the untouched-surface claims: `git diff --stat` shows no changes to `scripts/check-pipeline-state.sh`, either `.github` workflow yml, `agents/project-layouts.md`, or any draft-lineage language (M8's territory).
- Update `ROADMAP.md`: check M7.1–M7.9 only after Tasks 1–5 pass verification; amend the M7 notes if any decision drifted from what this SPRINT.md locks (it should not).
- Check this SPRINT.md's per-task boxes (Tasks 1–6) only after their acceptance conditions hold.

**Done when.** All greps and script runs return the expected results, ROADMAP M7 checkboxes are ticked, and SPRINT.md task boxes reflect completed work.

---

## Out of scope for this Sprint

- **Draft lineage changes.** `<latest-draft>` stays highest-numbered `draft-vNN.md`; active heads, `supersedes`/`superseded_by`, and non-destructive rerun lineage are **M8** (`ROADMAP.md:71-111`).
- **Dispatcher-level staleness/review blocking and override recording.** The dispatcher checks required-file existence only; stamp checks stay in step bodies. Surfacing machine-checkable stale/review blockers at dispatch is **M9.6**; override recording is **M9.5** (`ROADMAP.md:141-146`).
- **New freshness stamps or artifact-state markers.** Only the existing `Reviewed-draft:` stamps participate; the standardized artifact-state model (fresh/stale/review_pending/…) is **M9**.
- **Changes to `scripts/check-pipeline-state.sh` or either CI workflow.** The grammar already tolerates the new state files; the marker semantics are not parsed there.
- **Step behavior changes.** No step reads or writes anything new besides its frontmatter block and the reworded boilerplate; prose handling, stamps, and outputs are byte-for-byte in spirit.
- **Renaming `next-step`.** It survives as the convenience command; only its internals become a layer over the `run-step` procedure.
- **Reverse ingestion, pre-writing, multi-work concurrency** — later milestones (`ROADMAP.md:158-173`, Deferred list).
