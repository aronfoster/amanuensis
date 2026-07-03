# Sprint 13 — Milestone 8: Active draft lineage

This Sprint replaces highest-numbered draft resolution with an explicit **active draft head**, so a human can rerun a prose-advancing step from an earlier draft and create a new active branch without deleting or renumbering prior work. Today `<latest-draft>` is defined as "the highest-numbered `draft-vNN.md` in the latest attempt" (`agents/project-layouts.md:13`), which couples "the draft steps read" to "the highest number on disk" — so there is no way to branch: any rerun that produces a new draft automatically becomes the newest, and any earlier draft is unreachable by the pipeline. After this Sprint: each attempt's `draft-manifest.md` carries a top-of-file `Active-head: draft-vNN.md` pointer; `<latest-draft>` resolves to that pointer (falling back to highest-numbered when no pointer exists, so pre-M8 projects need no migration); `<next-draft>` decouples from it and resolves to `highest existing draft number + 1` so filenames stay monotonic and collision-free; a human branches by passing a read-from argument to `run-step` (`run-step <step_id> from <draft-vNN>`), which overrides which draft `<latest-draft>` resolves to for that one invocation; and on a branch the producing prose-advancing step writes `<next-draft>`, repoints `Active-head`, and stamps each displaced active-lineage draft `superseded_by: <next-draft>`.

This is a documentation/prose-contract milestone. It changes the manifest schema and the `<latest-draft>`/`<next-draft>` resolution rules in `agents/project-layouts.md`, the dispatcher contract and execution-model vocabulary in `agents/orchestrator.md`, the two `run-step` host adapters, and the eleven step bodies that read or write drafts. It does **not** change the step set, so `scripts/check-pipeline-state.sh`, the CI workflows, and both `pipeline-state.md` files are untouched. It does not change draft *content* handling — prose is copied through exactly as today; only which draft a step reads, what it names its output, and what it records in the manifest change.

## Background — what is and isn't wrong today

Established by inspection during planning; tasks should not re-derive this.

- **`<latest-draft>` is defined positionally, and `<next-draft>` is chained to it.** `<latest-draft>` = highest-numbered `draft-vNN.md` in `<latest-attempt>`; `<next-draft>` = one greater than `<latest-draft>` (`agents/project-layouts.md:13-14`). Because the two are chained, a rerun that mints a new draft always extends the newest tip — there is no way to read an earlier draft and branch. M8 breaks the chain: `<latest-draft>` becomes a semantic pointer (what to read); `<next-draft>` stays physical (`max number + 1`, what to write), so branch outputs never collide with existing files.
- **The manifest already exists and is human-legible markdown.** Sprint 9 (M4.3) landed `draft-manifest.md` as the attempt-level provenance record (`agents/project-layouts.md:21-33`): per-version `## draft-vNN.md` sections with `- produced_by:`, `- read_from:`, consulted/side-artifact bullets, and an apply-log pointer. Draft files themselves stay manuscript-only prose — the manifest is the provenance source, not in-file frontmatter (`agents/steps/drafting.md:203-207`, `:131`). M8 extends this schema (top-of-file `Active-head:` pointer; per-entry `timestamp`, `review_gate`, and, when displaced, `superseded_by`) rather than inventing a new file.
- **`drafting` creates the manifest and the first draft.** The drafting coordinator assembles `draft-v01.md` and appends the first manifest entry (`## draft-v01.md`, `produced_by: drafting`, `read_from: []`) (`agents/steps/drafting.md:47-63`, `:203-207`). This is where the `Active-head:` pointer is initialized to `draft-v01.md`.
- **Five prose-advancing fix/apply steps and `line_pass` mint drafts and append manifest entries.** `compliance_fix` (`agents/steps/compliance-fix.md:9-11`, `:92-102`), `prose_fix` (`agents/steps/prose-fix.md:8-11`), `metaphor_apply` (`agents/steps/metaphor-apply.md:7-10`), `line_pass` (`agents/steps/line-pass.md:8-10`), and `anti_ai_fix` (`agents/steps/anti-ai-fix.md:8-10`, `:124`) each read `<latest-draft>`, write `<next-draft>`, and append a per-version manifest entry today. These are the steps that must, after M8, resolve the active head (or the read-from override), repoint the pointer, and supersede a displaced branch.
- **Five steps read `<latest-draft>` without minting a draft.** `compliance_report` (`agents/steps/compliance-report.md:6`, `:31`), `prose_pass` (`agents/steps/prose-pass.md:5`, `:51`), `metaphor_identify` (`agents/steps/metaphor-identify.md:5`, `:30`), `metaphor_fix` (`agents/steps/metaphor-fix.md:6` — reads the draft for subagent context, mints no draft, preserves its inherited stamp), and `anti_ai_report` (`agents/steps/anti-ai-report.md:5`). After M8 these resolve the active head (or read-from override) before reading; the four report-emitters stamp `Reviewed-draft:` against the draft they actually read.
- **`storyboard_review` and the three pre-draft steps read no draft.** `storyboard_review` runs before drafting and explicitly reads no draft (`agents/steps/storyboard-review.md:33`); `character_extraction`, `scene_generation`, and `storyboarding` precede any draft. None of them resolve `<latest-draft>`, so M8 does not touch them, and passing a read-from argument to any of them is a usage error.
- **The report→fix freshness invariant is a filename comparison.** Each fix/apply step reads the paired report's top-of-file `Reviewed-draft: draft-vNN.md` stamp at step start and blocks if it does not equal `<latest-draft>` (`agents/steps/compliance-fix.md:44`, `:112`; `agents/orchestrator.md:137-154`). Because the comparison is by filename, it keeps working unchanged once `<latest-draft>` resolves via the active head: a report stamped against a now-abandoned draft simply fails the equality check and blocks. M8 adds no new stamp field; the existing `Reviewed-draft:` filename plus the manifest's `read_from` chain is what identifies a stale artifact's lineage.
- **The dispatcher checks required-file existence only, and `run-step` takes one argument today.** The `run-step` adapters read `$ARGUMENTS` / the invoking message as a single step_id, confirm it is in the recipe, resolve the step file, verify `required: true` preconditions exist, and become the step body (`templates/dispatcher/.claude/commands/run-step.md:9-19`; `templates/dispatcher/.opencode/agents/run-step.md:18-28`). Existence-checking is the dispatcher's job; freshness stays in step bodies (`agents/orchestrator.md:156-165`; M9.6 is deferred). M8 adds a second, optional argument (the read-from draft) and one existence check for it, keeping that division.
- **`next-step` is the linear convenience layer.** `next-step` resolves the first non-`[x]` step and proceeds exactly as `run-step` for that step_id (`agents/orchestrator.md:96`). It exists to walk the recipe in order; branching is deliberately not part of it, so it does not gain the read-from argument.
- **The step set is unchanged, so the checked artifacts are untouched.** M8 adds and removes no step. `scripts/check-pipeline-state.sh` checks the step list against `agents/steps/` (`scripts/check-pipeline-state.sh`), and neither `templates/pipeline-state.md` nor `examples/smoke/pipeline-state.md` mentions drafts. All three stay byte-for-byte unchanged; CI stays green for free.
- **The smoke fixture already drives a linear draft advance.** Recipe 4 hand-authors `plot/drafts/attempt01/` with `draft-v01.md`/`draft-v02.md` and a `Reviewed-draft: draft-v02.md`-stamped report, then runs `/run-step compliance_fix` and expects `draft-v03.md` plus a first `draft-manifest.md` entry (`examples/smoke/README.md:148-172`). M8.7's branch recipe extends this same untracked-fixture pattern; the existing `git checkout` + `git clean -fd` reset (`examples/smoke/README.md:186-192`) already removes it.

## Definition of done

The Sprint is complete when:

1. ROADMAP.md tasks M8.1–M8.7 are checked.
2. `agents/project-layouts.md` is the single source for draft lineage: it defines the `Active-head:` manifest pointer, the revised `<latest-draft>` resolution (active head, highest-numbered fallback), the revised `<next-draft>` resolution (highest existing number + 1), the extended manifest schema (`Active-head:` plus per-entry `timestamp`, `review_gate`, `superseded_by`), and the lineage/supersession algorithm (how a branching step identifies and stamps displaced drafts). The seven M8.1 terms — `active_head`, `read_from` (the `reads` term), `produced_by`, `supersedes`/`superseded_by`, `lineage`, `abandoned` — are each defined here.
3. `agents/orchestrator.md`'s Execution-model section refines `active` and `superseded` to the manifest-pointer definitions and adds `active_head`/`lineage`/`abandoned` (one-line each, cross-referencing `agents/project-layouts.md` as the owner). Its Dispatcher-behavior section documents the optional read-from argument to `run_step`, the new failure modes (read-from draft does not exist; read-from passed to a step with no `prose_draft` precondition), and the branch completion action for prose-advancing steps (write `<next-draft>`, repoint `Active-head`, supersede the displaced branch). The report→fix freshness section states the active-head interaction with mechanics unchanged.
4. `run-step` on both hosts parses an optional read-from draft after the step_id, validates it (exists in the latest attempt; the target step declares a `prose_draft` precondition), and passes it to the step body; `next-step` on both hosts is unchanged in its argument surface (no read-from). `install.sh` is unchanged (no new files). `AGENTS.md`'s "How Amanuensis works" paragraph reflects active-head resolution and the read-from branch surface.
5. The six prose-advancing steps (`drafting`, `compliance_fix`, `prose_fix`, `metaphor_apply`, `line_pass`, `anti_ai_fix`) resolve their read draft via the active head (or read-from override), write `<next-draft>` as `highest existing number + 1`, append a lineage-preserving manifest entry, repoint `Active-head`, and — on a branch — stamp the displaced drafts `superseded_by`. `drafting` additionally initializes `Active-head: draft-v01.md`. None of them infer the active draft from filenames alone.
6. The five draft-reading steps (`compliance_report`, `prose_pass`, `metaphor_identify`, `metaphor_fix`, `anti_ai_report`) resolve the active head (or read-from override) through the manifest before reading, and the four report-emitters stamp `Reviewed-draft:` against the draft they actually read. `storyboard_review` and the three pre-draft steps are untouched.
7. `examples/smoke/README.md` documents an M8.7 branch recipe: build a linear `v01→v02→v03` chain, run a prose-advancing step with `from draft-v01`, and verify a new `draft-v04` becomes the active head, `v02`/`v03` remain on disk but are stamped superseded, and a subsequent report step reads `v04`.
8. `sh scripts/check-pipeline-state.sh --exhaustive templates/pipeline-state.md agents/steps` and `sh scripts/check-pipeline-state.sh examples/smoke/pipeline-state.md agents/steps` both pass; `git diff --stat` shows no changes to `scripts/check-pipeline-state.sh`, either `.github` workflow yml, `templates/pipeline-state.md`, or `examples/smoke/pipeline-state.md`.
9. Verification greps confirm the sweep:
   - `git grep -n "Active-head" -- agents/project-layouts.md agents/orchestrator.md` shows the pointer defined in project-layouts.md and referenced in orchestrator.md.
   - `git grep -ln "Active-head" -- agents/steps` lists exactly the six prose-advancing steps.
   - `git grep -ln "active head" -- agents/steps` includes the five draft-reading steps (they resolve the active head before reading).
   - `git grep -n "highest-numbered" -- agents/project-layouts.md` returns only the fallback clause of the `<latest-draft>` rule (no longer the primary definition).
   - `git grep -n "superseded_by" -- agents/project-layouts.md agents/steps` shows the schema in project-layouts.md and the stamp write in the six prose-advancing steps.
   - `git grep -ln "from <draft" -- templates/dispatcher AGENTS.md` shows both `run-step` files (and not the `next-step` files) carry the read-from argument.

## Conventions adopted by this Sprint

Locked at planning (the starred item is the owner decision from this Sprint's planning session); tasks don't rediscover them.

- **★ Branch selection is a read-from argument on `run-step`.** `run-step <step_id> from <draft-vNN>` (host-tolerant grammar: Claude Code reads it from `$ARGUMENTS` after the step_id; OpenCode reads it from the invoking message). It overrides which draft `<latest-draft>` resolves to for that one invocation and nothing else. `next-step` never accepts it — it is the linear convenience layer and always advances from the active head. Rationale: the owner chose explicit, discoverable branching at the command over the file-edit default. Rejected alternatives: a manual `Active-head:` manifest edit before rerun (minimal, but undiscoverable — a human staring at the pipeline would not know branching is possible); a separate `set-active-head` command (doubles the command surface and the install/host-parity burden right after Sprint 12 added `run-step`, for a rarely-used operation).
- **The active head is a single top-of-manifest `Active-head: draft-vNN.md` pointer.** One pointer per attempt manifest, written above the per-version entries — the same top-of-file shape as the `Reviewed-draft:` stamp. Not a per-entry `active: true` boolean: two `true`s could drift, and Sprint 12 already rejected duplicating derivable status into a file (`SPRINT.md` Sprint 12 state-grammar convention). "Which draft is active" has exactly one home.
- **`<latest-draft>` and `<next-draft>` decouple.** `<latest-draft>` (the read pointer) = the `Active-head:` draft, resolved at step start; a read-from override substitutes for it for that invocation. `<next-draft>` (the write name) = `highest existing draft-vNN number + 1` in the attempt, zero-padded — kept purely physical so branch outputs never collide with or renumber existing files (M8.3's monotonic-filename requirement). The drafting brand-new-attempt case (`<next-draft>` = `draft-v01.md`) is unchanged.
- **No migration; highest-numbered is the fallback.** A manifest with no `Active-head:` pointer — every pre-M8 project — resolves `<latest-draft>` to the highest-numbered draft, exactly the M4 rule. Existing projects keep working untouched; `drafting` writes the pointer from `draft-v01.md` forward on any fresh attempt. This parallels Sprint 12's tolerance of the legacy `[>]` marker: new writers emit the new form, resolvers tolerate the old.
- **The manifest is the resolution substrate for `<latest-draft>`, not a declared input.** Resolving `<latest-draft>` now entails reading the manifest's `Active-head:` pointer, the way it entailed scanning the attempt directory before. This is folded into the placeholder-resolution rules in `agents/project-layouts.md`; step frontmatter `inputs`/`preconditions` do **not** gain a `draft-manifest.md` entry (that would bloat eleven files and blur "inputs" to mean "resolution machinery"). The prose-advancing steps already list `draft-manifest.md` in `outputs`; repointing the pointer is part of that existing write.
- **Supersession is a per-draft `superseded_by: <new-draft>` stamp; abandonment is derived.** On a branch (read-from ≠ active head), the producing step walks the manifest's active lineage backward from the old head to the read-from draft and stamps each draft strictly after the read-from draft, up to and including the old head, with `superseded_by: <next-draft>`. A linear advance (read-from = active head, the common case) supersedes nothing. Each fact has one home: each draft owns its `superseded_by`; the `Active-head:` pointer owns "which is active." A draft is **abandoned** iff it carries a `superseded_by` stamp and is not the active head — a derived predicate, not a separately recorded field (avoids the drift Sprint 12 guards against). This resolves the M8.1 `superseded` vs `abandoned` fork: `superseded_by` is the recorded edge, `abandoned` is the derived state.
- **The lineage/supersession algorithm is single-sourced in `agents/project-layouts.md`.** The backward-walk and stamping rule is stated once there; the six prose-advancing step bodies reference it rather than each restating the walk (M1 single-sourcing). Step bodies say "repoint `Active-head` and stamp the displaced branch superseded per `agents/project-layouts.md`," not the algorithm inline.
- **The M8.1 design note lands in `agents/project-layouts.md`.** That doc owns the manifest and path-resolution contract, so the lineage model belongs there; `orchestrator.md`'s Execution-model terms are updated to stay consistent and cross-reference it. This follows Sprint 12's precedent that a design note lands in the doc that owns the contract, not a separate design file (single-sourcing).
- **read-from is honored by every `<latest-draft>`-reading step, but only prose-advancing steps repoint and supersede.** A report/reader step invoked with a read-from override reads the named draft and (if it is a report-emitter) stamps `Reviewed-draft:` against it; it moves no pointer and supersedes nothing, because it mints no draft. Passing read-from to a step with no `prose_draft` precondition (`drafting`, `storyboard_review`, `character_extraction`, `scene_generation`, `storyboarding`) is a dispatcher usage error — the dispatcher names the problem and stops.
- **The report→fix freshness invariant keeps its mechanics.** Still a filename comparison of the paired report's `Reviewed-draft:` stamp against `<latest-draft>` at step start; the pairs list, the stamp-overwrite-on-regenerate behavior, and `metaphor_fix`'s stamp-preserving role are unchanged (`agents/orchestrator.md:137-154`). The only difference is that `<latest-draft>` now resolves via the active head, so a report stamped against an abandoned draft is correctly detected as stale.
- **Draft lineage is within-attempt.** Attempts remain the coarse "redraft from scratch" unit; M8's branching is fine-grained *inside* one attempt. Cross-attempt comparison tooling stays deferred (ROADMAP Deferred list). M8 changes no attempt-resolution rule.
- **Dispatcher-level staleness/review blocking and override recording stay deferred.** The dispatcher gains only the read-from existence check. It still does not read `Reviewed-draft:` stamps, does not detect staleness, and does not record overrides — that is M9.5/M9.6. M8 defines lineage; M9 makes the dispatcher enforce freshness on top of it.

---

## Tasks

### Task 1 — Lineage model + manifest schema + resolution rules in `agents/project-layouts.md`

- [ ] Not started

**Goal.** Land the M8.1 design and the M8.2/M8.3 schema and resolution rules as the single source in the doc that owns the manifest. Everything downstream references this file. Closes **M8.1**, **M8.2**, and the resolution side of **M8.3**.

**Requirements.**

- Rewrite the `<latest-draft>` resolution rule (`agents/project-layouts.md:13`): `<latest-draft>` resolves to the attempt manifest's `Active-head: draft-vNN.md` pointer, read at step start; when the manifest has no `Active-head:` line (or no manifest exists), fall back to the highest-numbered `draft-vNN.md`. State that the fallback is the no-migration path for pre-M8 attempts.
- Rewrite the `<next-draft>` resolution rule (`agents/project-layouts.md:14`): `<next-draft>` = one greater than the **highest existing** `draft-vNN.md` number in the attempt (not one greater than `<latest-draft>`), zero-padded to two digits; this keeps filenames monotonic so a branch output never collides with an existing file. Keep the brand-new-attempt case (`<next-draft>` = `draft-v01.md`).
- Extend the manifest schema section (`agents/project-layouts.md:21-33`):
  - Add the top-of-file `Active-head: draft-vNN.md` pointer, written above the per-version entries; define it as the single source of "which draft is active" and the thing `<latest-draft>` resolves to.
  - Add to each per-version entry: `timestamp` (ISO 8601 with timezone offset, same convention as `pipeline-state.md`'s `last_updated`), `review_gate` (the producing step's `review_required` value — feeds M9's review-state work), and `superseded_by: draft-vNN.md` (present only on a displaced draft). Keep `produced_by`, `read_from`, side-artifact bullets, and the apply-log pointer.
  - Show a worked manifest specimen covering a branch: a linear `v01→v02→v03` with `Active-head: draft-v04.md` after a rerun-from-`v01` produced `v04`, with `v02` and `v03` each carrying `superseded_by: draft-v04.md` and `v04`'s entry recording `read_from: [draft-v01.md]`.
- Define the M8.1 vocabulary in this file, each with a one-line definition: `active_head` (the `Active-head:` pointer / `<latest-draft>`), `read_from` (the draft(s) a version was produced from — the `reads` term, already a field), `produced_by` (already a field), `supersedes`/`superseded_by` (the displacement edge), `lineage` (the `read_from` chain from a draft back to `draft-v01`; the *active lineage* is the active head's chain), and `abandoned` (carries a `superseded_by` stamp and is not the active head — derived, not recorded).
- State the **lineage/supersession algorithm** once, as the canonical procedure a branching prose-advancing step follows: given the draft it read (`R` = active head, or the read-from override) and the old active head (`H`), after writing `<next-draft>` (`N`): set `Active-head: N`; if `R ≠ H`, walk `read_from` backward from `H` to `R` and stamp every draft strictly after `R` up to and including `H` with `superseded_by: N`; if `R = H`, supersede nothing.

**Done when.** `agents/project-layouts.md` defines the `Active-head:` pointer, the revised `<latest-draft>`/`<next-draft>` rules, the extended per-entry schema, the seven terms, and the supersession algorithm; the worked specimen shows a branch with a superseded pair; `git grep -n "highest-numbered" agents/project-layouts.md` returns only the fallback clause.

---

### Task 2 — Dispatcher contract + execution-model vocabulary in `agents/orchestrator.md`

- [ ] Not started

**Goal.** Make the orchestrator contract express active-head resolution, the read-from argument, and the branch completion action, cross-referencing `agents/project-layouts.md` as the lineage owner. Closes the dispatcher side of **M8.3** and the contract side of **M8.4**.

**Requirements.**

- Refine the Execution-model terms (`agents/orchestrator.md:13-25`): change `active` to "the draft named by the attempt manifest's `Active-head:` pointer — what `<latest-draft>` resolves to"; change `superseded` to "a draft carrying a `superseded_by:` stamp in the manifest"; add one-line `active_head`, `lineage`, and `abandoned` entries, each pointing to `agents/project-layouts.md` for the full definition. Remove the "M8's to define" hedges now that M8 defines them.
- Update Dispatcher behavior (`agents/orchestrator.md:83-98`): `run_step` takes an optional read-from draft after the step_id (`run_step <step_id> from <draft-vNN>`). When present, the dispatcher (a) confirms the target step declares a `prose_draft` precondition, (b) confirms the named draft exists in the latest attempt, then (c) substitutes it for `<latest-draft>` when checking the `prose_draft` precondition and passes it to the step body as the draft to read. Without it, `<latest-draft>` resolves to the active head as normal. State that `next_recommended_step`/`next-step` never accepts a read-from argument.
- Extend the completion action (`agents/orchestrator.md:96-98`, and the Re-running section `:125-127`): for a prose-advancing step, the final action now also repoints `Active-head` to the new draft and, on a branch, stamps the displaced drafts `superseded_by` — per the algorithm in `agents/project-layouts.md` (reference it, do not restate the walk). Note that a rerun is a branch exactly when the read draft is not the current active head.
- Add failure modes (`agents/orchestrator.md:112-123`): a read-from draft that does not resolve to an existing `draft-vNN.md` in the latest attempt (dispatcher names it and stops); a read-from argument passed to a step with no `prose_draft` precondition (usage error — the step reads no draft, so the override is meaningless).
- Update the report→fix freshness section (`agents/orchestrator.md:137-154`): note that `<latest-draft>` now resolves via the active head, so a report stamped against an abandoned draft is correctly stale; keep the pairs list, stamp-overwrite behavior, and `metaphor_fix`'s stamp-preserving role verbatim. Add one line: a stale artifact's lineage is identifiable from its `Reviewed-draft:` filename plus the manifest's `read_from` chain (satisfying M8's "stale artifacts identify their lineage").
- Update "What the orchestrator does not do" (`agents/orchestrator.md:156-165`) only if needed for consistency: the dispatcher now also validates the read-from draft's existence, but still does not detect staleness or record overrides (M9). Do not overstate the change.

**Done when.** `agents/orchestrator.md` documents the read-from argument, the two new failure modes, and the branch completion action, with the lineage algorithm referenced (not restated); the Execution-model terms match `agents/project-layouts.md`; `git grep -n "Active-head" agents/orchestrator.md` returns hits.

---

### Task 3 — `run-step` read-from argument on both hosts, `next-step` confirmation, `AGENTS.md`

- [ ] Not started

**Goal.** Ship the branch surface at parity on both hosts and catalog it. Closes the host side of **M8.4**.

**Requirements.**

- Edit `templates/dispatcher/.claude/commands/run-step.md`: `$ARGUMENTS` now carries `<step_id> [from <draft-vNN>]`. Parse an optional read-from draft after the step_id (tolerant of `from draft-vNN` / bare `draft-vNN`; the human is writing prose, not a strict CLI). In the Procedure (`:11-19`), after resolving the step file and before precondition checking: if a read-from draft was given, confirm the step's `preconditions:` block contains a `prose_draft` entry and confirm the named draft exists in the latest attempt; substitute it for `<latest-draft>` in the precondition check and hand it to the step body as the draft to read. Add the two new failure modes (`:21-31`) restated from the orchestrator contract. Keep the thin-adapter posture and the "canonical contract lives in orchestrator.md" framing; do not re-derive the lineage algorithm.
- Edit `templates/dispatcher/.opencode/agents/run-step.md`: the same change at parity, reading the read-from draft from the invoking message alongside the step_id (`:18`, `:20-28`). OpenCode frontmatter unchanged.
- Confirm both `next-step` files remain single-argument (no read-from): they resolve the first non-`[x]` step and proceed as `run-step` for it, always from the active head. If a stronger statement helps, add one line noting `next-step` does not branch. Do not otherwise change them.
- `install.sh`: unchanged — no new files; the four dispatcher files already install. State this explicitly so Task 6's untouched-surface check can confirm it.
- `AGENTS.md`: update the "How Amanuensis works" paragraph (`AGENTS.md:29`) so it says `<latest-draft>` resolves to the manifest's active head and a human can branch a rerun with `run-step <step_id> from <draft-vNN>`; keep it to the model shift (do not restate the algorithm). The Core-documents dispatcher entries (`:41-44`) need no change unless a description drifted.
- Host parity is a requirement: the two `run-step` files must express the same read-from parsing, validation, and failure modes.

**Done when.** Both `run-step` files parse, validate, and pass the read-from draft; both `next-step` files are unchanged in argument surface; `AGENTS.md` reflects active-head resolution and the branch surface; `git grep -ln "from <draft" templates/dispatcher AGENTS.md` shows the two `run-step` files (not `next-step`).

---

### Task 4 — Prose-advancing step rewiring (M8.5)

- [ ] Not started

**Goal.** Make every draft-minting step resolve the active head (or read-from override), keep filenames monotonic, and preserve lineage in the manifest. Closes **M8.5**.

**Requirements.**

- `agents/steps/drafting.md`: when it creates the manifest (`:47-63`, `:203-207`), initialize the top-of-file `Active-head: draft-v01.md` pointer and record the `draft-v01.md` entry with the new `timestamp` and `review_gate` fields (per Task 1's schema). `read_from: []` stays. No read-from handling — drafting mints `v01` and reads no prior draft.
- For each of `compliance_fix`, `prose_fix`, `metaphor_apply`, `line_pass`, `anti_ai_fix`:
  - Resolve the draft to read via the active head, or via the read-from override the dispatcher passed. State that `<latest-draft>` = active head is what the step reads (the frontmatter placeholder is unchanged; only its resolution moved to Task 1).
  - Write `<next-draft>` = highest existing draft number + 1 (Task 1's rule); the frontmatter `<next-draft>` placeholder is unchanged.
  - Append the manifest entry with `read_from: [<the draft it read>]`, `timestamp`, `review_gate`, and the existing side-artifact/apply-log fields. Update the worked manifest example each file carries (e.g. `agents/steps/compliance-fix.md:94-102`, `agents/steps/anti-ai-fix.md:124`) so `read_from` names the resolved draft, not a hardcoded `draft-v02.md`.
  - As the completion action, repoint `Active-head` to `<next-draft>` and, on a branch (read draft ≠ old active head), stamp the displaced drafts `superseded_by: <next-draft>` — per the algorithm in `agents/project-layouts.md` (reference it; do not restate the walk). Fold this into the existing "final action marks its own step line `[x]`" boilerplate.
  - No change to prose handling, the `Reviewed-draft:` stamp check, or the open-questions/stale-report blocker paths. `line_pass` has no upstream report, so it has no stamp check — only the resolve/write/repoint changes apply.
- Do not change any frontmatter `inputs`/`outputs`/`preconditions` list — `draft-manifest.md` is already an output on these steps, and the manifest is the resolution substrate, not a new input.

**Done when.** All six steps resolve the active head (or override), write monotonic `<next-draft>`, append lineage-preserving manifest entries, and repoint/supersede on completion; `drafting` initializes `Active-head: draft-v01.md`; `git grep -ln "Active-head" agents/steps` lists exactly these six files; both `check-pipeline-state.sh` modes still pass.

---

### Task 5 — Draft-reading step rewiring (M8.6)

- [ ] Not started

**Goal.** Make every step that reads a draft without minting one resolve the active head (or read-from override) before reading. Closes **M8.6**.

**Requirements.**

- For each of `compliance_report`, `prose_pass`, `metaphor_identify`, `metaphor_fix`, `anti_ai_report`: state that the draft read is resolved via the manifest's active head (or the read-from override the dispatcher passed), not by "highest-numbered draft." Where the Inputs section says the step reads `<latest-draft>` (e.g. `agents/steps/compliance-report.md:31`, `agents/steps/prose-pass.md:51`, `agents/steps/metaphor-identify.md:30`, `agents/steps/anti-ai-report.md:5`, `agents/steps/metaphor-fix.md:6`), add that `<latest-draft>` now resolves to the active head per `agents/project-layouts.md`. Keep the "does not mint a new draft version" statements.
- The four report-emitters (`compliance_report`, `prose_pass`, `metaphor_identify`, `anti_ai_report`) write their `Reviewed-draft:` stamp against the draft they actually read — so a read-from override makes the stamp name that draft (e.g. `agents/steps/compliance-report.md:116`). `metaphor_fix` preserves its inherited stamp and mints no draft; only its draft-read resolution changes.
- Do not change `storyboard_review`, `character_extraction`, `scene_generation`, or `storyboarding` — none reads a draft (`agents/steps/storyboard-review.md:33`).
- No change to frontmatter lists, report content, or stamp mechanics beyond which draft is resolved.

**Done when.** The five draft-reading steps resolve the active head (or override) before reading and stamp against the read draft where they stamp; the pre-draft steps are untouched; `git grep -ln "active head" agents/steps` includes the five reading steps.

---

### Task 6 — Smoke branch recipe, verification sweep, ROADMAP / SPRINT check-off

- [ ] Not started

**Goal.** Document a runnable branch verification and close the milestone. Closes **M8.7** and the residual of **M8**.

**Requirements.**

- Add an M8.7 branch recipe to `examples/smoke/README.md`, in the style of Recipes 3–4 (`:103-172`) and using only untracked files under `plot/drafts/attempt01/`. Hand-author a `draft-manifest.md` with `Active-head: draft-v03.md` and a linear `v01→v02→v03` chain (`read_from` edges `v01←v02←v03`), plus the three `draft-vNN.md` files and an annotated, `Reviewed-draft: draft-v01.md`-stamped `reviewer-actions.md`. Run `/run-step compliance_fix from draft-v01` and document the expected outcome: the freshness check passes (stamp `draft-v01.md` = the read-from draft), the step writes `draft-v04.md` (highest existing + 1), appends a `## draft-v04.md` manifest entry with `read_from: [draft-v01.md]`, repoints `Active-head: draft-v04.md`, stamps `v02` and `v03` `superseded_by: draft-v04.md`, and marks `compliance_fix` `[x]`. Add a follow-on line: a subsequent `/run-step compliance_report` (no override) now reads `draft-v04.md` (the active head) — confirming reader steps follow the pointer. Update the fixture's "Not committed" layout note (`:23-29`) to mention the hand-authored manifest and the branch outputs. State the OpenCode parity line as the existing recipes do (`:174-183`).
- Confirm the reset procedure (`:186-192`) already covers the new untracked files (it removes the whole `plot/drafts/attempt01/` tree); commit nothing new under `examples/smoke/` except the README edit.
- Run and review every check in Definition of done items 8–9 (both `check-pipeline-state.sh` modes, the `git diff --stat` untouched-surface check, and the six greps).
- Confirm cross-file consistency by reading: the two `run-step` files against the updated `agents/orchestrator.md` dispatcher contract (no drift, no re-derived algorithm); the six prose-advancing steps and five reading steps against Task 1's resolution/schema/algorithm; `AGENTS.md` against the actual surface.
- Update `ROADMAP.md`: check M8.1–M8.7 only after Tasks 1–5 pass verification; amend the M8 notes only if a decision drifted from what this SPRINT.md locks (it should not).
- Check this SPRINT.md's per-task boxes (Tasks 1–6) only after their acceptance conditions hold.

**Done when.** The branch recipe is documented with expected outcomes and the reset covers it; all greps and script runs return the expected results; the untouched-surface check is clean; ROADMAP M8 checkboxes are ticked; SPRINT.md task boxes reflect completed work.

---

## Out of scope for this Sprint

- **Dispatcher-level staleness/review blocking and override recording.** The dispatcher gains only the read-from existence check. It still does not read `Reviewed-draft:` stamps, detect staleness, or record overrides — that is **M9.5/M9.6** (`ROADMAP.md:171-177`).
- **A standardized artifact-state model** (`fresh`/`stale`/`review_pending`/`reviewed`/…) and generalized freshness stamps across all side artifacts — **M9** (`ROADMAP.md:145-186`). M8 touches only the `Active-head:` pointer and the `superseded_by` stamp; the existing `Reviewed-draft:` stamps are unchanged.
- **Cross-attempt lineage or comparison tooling.** Branching is within one attempt; attempts remain the coarse redraft unit. Per-attempt comparison stays deferred (`ROADMAP.md` Deferred list).
- **Changes to the step set, `scripts/check-pipeline-state.sh`, either CI workflow, or either `pipeline-state.md`.** M8 adds and removes no step; these artifacts stay byte-for-byte unchanged.
- **A `set-active-head` command or a manual-manifest-edit branch procedure.** Branch selection is the read-from argument on `run-step`; the pointer is written by step bodies, not hand-edited as the primary path.
- **Reverse ingestion, pre-writing, multi-work concurrency, `storyboard_review_fix`** — later milestones (`ROADMAP.md:188-205`, Deferred list).
