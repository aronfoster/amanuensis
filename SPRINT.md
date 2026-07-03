# Sprint 14 — Milestone 9: Stale artifacts and review gates

This Sprint turns the report→fix freshness invariant into a **general artifact-state model** and makes review state **legible without enforcing it**, so a human can invoke any step in any order and the consuming step bodies protect prose from stale or unreviewed side artifacts. Today freshness is handled correctly but only for the four report→fix pairs, and only as a special-cased "invariant" in `agents/orchestrator.md:145-164`; review is declared (`review_sensitive` in frontmatter, `review_gate` in the manifest) but has no named model; and the vocabulary M9 needs (`fresh`, `review_pending`, `reviewed`, `override`, `discarded`, `regenerated`) is undefined. After this Sprint: `agents/orchestrator.md` carries a single **Artifact state** section that defines freshness as a *derived predicate* (`Reviewed-draft:` stamp equals the manifest's active head → fresh, otherwise stale), computed by the consuming step at step start and **never stored, never swept**; review as a *surfaced-not-enforced* signal read off the already-declared `review_sensitive`/`review_gate`; and **override** as a recorded, source-specific, human-visible decision written into the consuming step's apply log. The report→fix invariant survives verbatim as the named special case of that general contract.

This is a documentation/prose-contract milestone in the same shape as Sprint 13 (M8). It changes no step set and adds no frontmatter or manifest field: `scripts/check-pipeline-state.sh`, both CI workflows, and both `pipeline-state.md` files stay byte-for-byte unchanged. The one genuinely new behavior in a step body is an **explicit override branch** in the four fix/apply steps (proceed against a stale/review-pending input *only* when the human recorded an override, and record that override) — everything else is naming and single-sourcing behavior that already ships.

The owner decision that shapes this Sprint: **staleness is a derived predicate, not stored state.** No process makes an update walk every artifact to mark it stale; a consuming step computes staleness for its own declared inputs, at the moment it would consume them, from two facts already on disk (the artifact's stamp and the manifest's `Active-head:`). This is the M8 precedent — `abandoned` was made a derived predicate rather than a recorded field (`agents/project-layouts.md:88`) — applied to the whole artifact-state model.

## Background — what is and isn't wrong today

Established by inspection during planning; tasks should not re-derive this.

- **Freshness already works, but only as a special case.** The report→fix freshness invariant (`agents/orchestrator.md:145-164`) is already lazy/pull: a report-emitting step writes a top-of-file `Reviewed-draft: draft-vNN.md` stamp; the paired fix/apply step compares that stamp to `<latest-draft>` at *its own* step start and blocks on mismatch (`agents/steps/compliance-fix.md:44`, `:114`). Nothing walks other artifacts when a draft advances — the check is local to one consumer. M9 generalizes this into a named contract; it does **not** replace it or add a sweep.
- **Exactly four prose-derived side artifacts carry the stamp**, and they are all the prose-derived report/annotation artifacts that exist: `reviewer-actions.md` (compliance), `prose-pass.md`, `metaphors.md`, `anti-ai.md` (`agents/orchestrator.md:155-158`). `line_pass` is prose-advancing with no upstream report, so the invariant does not apply to it (`:162`); `storyboard_review` is pre-draft and reads no draft. So "generalize freshness stamps to prose-derived side artifacts" (M9.2) is consolidation of a pattern already present on all four instances, not the addition of many new stamped artifacts.
- **`stale`, `active`, `superseded`, `abandoned` are already defined** in the Execution-model vocabulary (`agents/orchestrator.md:21-26`); `abandoned` is explicitly a *derived predicate, not a recorded field* (`agents/project-layouts.md:88`). M9 adds `fresh`, `review_pending`, `reviewed`, `override`, `discarded`, `regenerated` to the same list and keeps the derived-not-stored discipline.
- **Review is declared but not enforced, by design.** `review_required` is "a signal to the human… nothing enforces this" (`agents/orchestrator.md:47`, `:107`, `:169`); `review_sensitive: true` marks inputs "expected to carry human annotations/review before consumption" (`agents/orchestrator.md:65`, `templates/step-workflow.md:27-28`); the manifest copies each draft's `review_gate` (`agents/project-layouts.md:35`). These three are the review-expectation declaration M9 makes legible — no new field is needed.
- **The fix/apply steps already gate on review evidence for the reports.** An *unannotated* report (no `FIX`/`SKIP`/`ESCALATE`) is a named blocker in `compliance_fix` (`agents/steps/compliance-fix.md:112`, `:120`): the step refuses to run because the human has not reviewed/annotated it. Annotation *is* the review evidence for the four reports. M9 names this as the review-evidence check and makes it uniform across the four fix/apply steps; it does not invent a positive "reviewed" stamp.
- **`discarded` and `regenerated` already happen, unnamed.** On a rerun against a newer draft, the report-emitting step **overwrites** its side artifact with a fresh stamp and the prior findings "against the superseded draft are discarded, because their prose anchors no longer apply" (`agents/orchestrator.md:160`; `agents/steps/compliance-report.md:41`). M9.1 names this behavior (`regenerated`/`discarded`); it does not change the mechanics.
- **Override is described as a human decision but has no recorded branch.** The stale-report exit "is a human decision point" and the human may choose "accepting a stale apply with an explicit override" (`agents/orchestrator.md:164`), but no fix/apply step body has an explicit branch that recognizes a recorded override and proceeds. M9.5 defines the recorded, source-specific override and Task 3 adds the branch.
- **The dispatcher is existence-only and stays that way this Sprint.** The dispatcher checks required-file existence (and, since M8, read-from existence) and does *not* detect staleness or record overrides (`agents/orchestrator.md:166-170`). Lifting freshness/review into the dispatcher is M9.6; per this Sprint's owner decision it is **deferred to a follow-on** so the state model proves out in the step bodies first. The dispatcher and both `run-step`/`next-step` adapters are untouched.
- **The step set is unchanged, so the checked artifacts are untouched.** M9 adds and removes no step. `scripts/check-pipeline-state.sh`, `templates/dispatcher/.github/workflows/pipeline-state-check.yml`, `templates/pipeline-state.md`, and `examples/smoke/pipeline-state.md` all stay byte-for-byte unchanged; CI stays green for free (same guarantee M8 relied on).
- **The smoke fixture already drives a stale/regenerate cycle.** `examples/smoke/README.md` hand-authors `plot/drafts/attempt01/` with versioned drafts and a `Reviewed-draft:`-stamped report as untracked files, cleaned by the existing `git checkout` + `git clean -fd` reset. M9.7's recipes extend that same pattern.

## Definition of done

The Sprint is complete when:

1. ROADMAP.md tasks M9.1–M9.5 and M9.7 are checked; M9.6 is annotated as deferred to a follow-on sprint (dispatcher lift), with the Sprint-14 note recording why.
2. `agents/orchestrator.md` carries a single **Artifact state** section that is the source for the model: it defines freshness as a derived predicate (stamp = active head → fresh; else stale), computed at consumption and never stored/swept; defines review as surfaced-not-enforced (declared by `review_sensitive`/`review_gate`, evidenced by annotation where applicable, surfaced as a non-blocking notice, hard-blocking only via the pre-existing unannotated-report path); and defines override as a recorded, source-specific, human-visible apply-log entry. The report→fix invariant survives inside this section as the named special case, mechanics verbatim.
3. The seven M9.1 terms — `fresh`, `stale`, `review_pending`, `reviewed`, `override`, `discarded`, `regenerated` — are each defined once, in `agents/orchestrator.md`'s Execution-model / Artifact-state vocabulary, with `stale`/`active`/`superseded`/`abandoned` refined for consistency and no term recorded as stored state where it can be derived.
4. The four report-emitting steps (`compliance_report`, `prose_pass`, `metaphor_identify`, `anti_ai_report`) reference the general freshness contract and use the named `regenerated`/`discarded` behavior; no stamp mechanic changes.
5. The four fix/apply steps (`compliance_fix`, `prose_fix`, `metaphor_apply`, `anti_ai_fix`) document the dual-check (freshness stamp + review-evidence annotation) as instances of the general contract and add an explicit override branch: proceed against a stale or unannotated input only when the human recorded an override, and record that override source-specifically in the apply log; absent an override, the existing block-to-`open-questions.md` paths stand. `metaphor_fix`'s stale check is aligned to the same framing. No silent stale or unreviewed apply.
6. Review stays signal-only: no new frontmatter field, no new manifest field, no positive "reviewed" stamp is added; `review_sensitive`/`review_gate` remain the declaration; a review-sensitive input's consumption emits at most a non-blocking notice (the sole hard block on review is the pre-existing unannotated-report path). `AGENTS.md`'s "How Amanuensis works" paragraph and `templates/step-workflow.md`'s `review_sensitive` note reflect the model.
7. The dispatcher is unchanged: both `run-step` and both `next-step` adapters, `install.sh`, and the "What the orchestrator does not do" list still describe an existence-only dispatcher; the deferred-work pointer names the follow-on (not "M9.5/M9.6" as a this-sprint promise).
8. `examples/smoke/README.md` documents M9.7 recipes exercising: stale-report detection, an unannotated (review-pending) report block, regeneration against the active head (fresh stamp, prior findings discarded), and an explicit override that lets a stale apply proceed and is recorded in the apply log — all with untracked fixture files the existing reset removes.
9. `sh scripts/check-pipeline-state.sh --exhaustive templates/pipeline-state.md agents/steps` and `sh scripts/check-pipeline-state.sh examples/smoke/pipeline-state.md agents/steps` both pass; `git diff --stat` shows no changes to `scripts/check-pipeline-state.sh`, either `.github` workflow yml, `templates/pipeline-state.md`, `examples/smoke/pipeline-state.md`, or any dispatcher adapter under `templates/dispatcher/`.
10. Verification greps confirm the sweep:
    - `git grep -n "Artifact state" -- agents/orchestrator.md` shows the new section.
    - `git grep -n "regenerated" -- agents/orchestrator.md` and `git grep -n "discarded" -- agents/orchestrator.md` show the named behaviors.
    - `git grep -ln "override" -- agents/steps` lists the four fix/apply steps that carry the override branch.
    - `git grep -n "derived" -- agents/orchestrator.md` returns the freshness-is-derived statement.
    - `git grep -c "review_sensitive\|review_gate" -- agents` shows the declaration surface unchanged in count from before the Sprint except for the model prose (no new precondition field introduced).

## Conventions adopted by this Sprint

Locked at planning (the starred item is the owner decision from this Sprint's planning session); tasks don't rediscover them.

- **★ Staleness is a derived predicate, never stored, never swept.** An artifact is `fresh`/`stale` by *computing* `Reviewed-draft: stamp == manifest Active-head` at the moment a specific consumer would use it — not by a stored field that some step maintains. No prose-advancing step walks other artifacts to mark them; no "stale" bit exists to drift. Rationale: the owner rejected "every update goes through every artifact and checks for staleness" as non-viable in practice; a derived predicate keeps the cost of an update O(1) in artifacts and removes the drift class entirely. Rejected alternative: a stored `fresh|stale` field invalidated on each draft advance (the O(artifacts)-per-update sweep — forces every prose step to know every artifact type, and the stored state drifts from the stamps). This applies the M8 precedent (`abandoned` is derived, not recorded — `agents/project-layouts.md:88`) to the whole model.
- **Review is surfaced, not enforced.** M9 keeps today's stance that review is the human's responsibility and the dispatcher does not block (`agents/orchestrator.md:169`). The expectation is *declared* by `review_sensitive` (frontmatter) and `review_gate` (manifest); *evidence*, where it naturally exists, is the human's annotation on the four reports; consumption *surfaces* a non-blocking notice for a review-sensitive input. The only hard block on the review axis is the pre-existing unannotated-report blocker. Rationale: a mandatory positive "reviewed" tick on every review-required output is the same friction, on the review axis, that the owner rejected on the freshness axis. Rejected alternative: enforce review as a hard gate with a positive marker the human must set — reverses the non-enforcement philosophy and adds a review-marking obligation to every gate.
- **Freshness/review checks stay in the consuming step body; the dispatcher lift (M9.6) is deferred.** Each check lives where it already lives — the consuming step, at step start — keeping the check local to its one consumer. The dispatcher stays existence-only (as M7 and M8 both deferred). Rationale: the model should prove out in the step bodies before it is lifted; M8 just loaded the dispatcher with the read-from argument, and duplicating stamp-reading into two `run-step` adapters now buys little over the step-body check. M9.6 becomes a mechanical follow-on.
- **No new frontmatter or manifest field.** The model is expressible from what already exists: `Reviewed-draft:` (freshness), `Active-head:` (the comparison target), `review_sensitive`/`review_gate` (review expectation), and annotations (review evidence). Override is recorded in the consuming step's apply log, not a new field. Each fact keeps one home; the Sprint adds vocabulary and one step-body branch, not schema.
- **The design note lands in `agents/orchestrator.md`.** That doc owns the freshness invariant (`:145-164`) and the execution-model vocabulary (`:17-28`), so the general artifact-state model belongs there; `agents/project-layouts.md` is referenced for the manifest fields it reads (`Active-head:`, `review_gate`) but not duplicated. This follows the Sprint 12/13 precedent that a design note lands in the doc that owns the contract, not a separate design file.
- **The report→fix invariant is preserved verbatim as the named special case.** M9 generalizes; it does not rewrite the invariant's mechanics. The pairs list, the stamp-overwrite-on-regenerate behavior, `metaphor_fix`'s stamp-preserving role, and the stale-report blocker path are unchanged (`agents/orchestrator.md:153-164`). The general contract is stated above the invariant; the invariant remains its canonical worked instance.
- **Override is recorded, source-specific, and human-visible.** An override names the specific stale-or-review-pending artifact and the draft mismatch it overrides, and is written into the consuming step's apply log alongside the `Applied:` blocks (the same place the fix step already records what it did — `agents/steps/compliance-fix.md:59`, `:116`). No stale or unreviewed apply happens silently; the absence of a recorded override means the step blocks as today.
- **`discarded` and `regenerated` are named, not changed.** `regenerated` = a report re-emitted against the current active head (the stale-blocker recovery path), overwriting the stale artifact with a fresh stamp; `discarded` = the prior run's findings against the superseded draft, dropped in that overwrite because their prose anchors no longer apply. Both are the existing behavior at `agents/orchestrator.md:160`, given names for the M9.1 vocabulary.

---

## Tasks

Wave order: **Task 1** defines the model and must land first (Tasks 2–4 reference it). **Tasks 2, 3, 4** touch disjoint file sets (report steps / fix-apply steps / catalog docs) and can run in parallel after Task 1. **Task 5** verifies and closes out, last.

### Task 1 — Artifact-state model + vocabulary + override behavior in `agents/orchestrator.md`

- [ ] Todo

**Goal.** Land the M9.1 design note and the M9.2/M9.3/M9.5 model as the single source in the doc that owns the freshness invariant. Everything downstream references this section. Closes **M9.1**, the model side of **M9.2**, **M9.3**, and **M9.5**.

**Requirements.**

- Introduce an **Artifact state** section in `agents/orchestrator.md` (generalize the existing "Report→fix freshness invariant" heading at `:145` into it, or place the general contract immediately above and keep the invariant as a labelled subsection — either way the invariant's prose survives verbatim as the named special case). The section states:
  - **Freshness is a derived predicate.** A prose-derived side artifact carries a top-of-file `Reviewed-draft: draft-vNN.md` stamp; it is `fresh` iff that stamp equals the current `<latest-draft>` (the manifest's active head, per `agents/project-layouts.md`), and `stale` otherwise. This is *computed by the consuming step at step start*, over two facts already on disk (the stamp and `Active-head:`); it is never stored as a field and no step ever walks other artifacts to maintain it. State the owner rationale in one line (avoid the O(artifacts)-per-update sweep; no drift class).
  - **Review is surfaced, not enforced.** The expectation is declared by `review_sensitive` (frontmatter) and `review_gate` (manifest); evidence, where it exists, is the human's annotation on the four reports; a consuming step surfaces a non-blocking notice for a review-sensitive input and hard-blocks only via the pre-existing unannotated-report path. No positive "reviewed" field is added.
  - **Override.** A human may authorize consuming a stale or review-pending artifact by recording an override; the override names the specific artifact and the draft mismatch and is written into the consuming step's apply log. No stale/unreviewed apply happens silently; absent a recorded override, the step blocks as today.
- Add the seven terms to the Execution-model vocabulary (`agents/orchestrator.md:17-28`), each one line, consistent with the above: `fresh`, `review_pending` (a review-sensitive artifact with no review evidence — an unannotated report, or any review-required output the human has not confirmed; surfaced, blocking only on the unannotated-report path), `reviewed` (a review-sensitive artifact carrying evidence — annotations for the reports — asserted by the human, not a stored positive stamp), `override`, `discarded`, `regenerated`. Refine `stale`/`active`/`superseded`/`abandoned` only for wording consistency; do not restate `agents/project-layouts.md`'s lineage definitions (cross-reference them).
- Preserve the report→fix invariant's pairs list, stamp-overwrite behavior, `metaphor_fix` stamp-preserving role, and stale-report blocker path verbatim (`:153-164`); frame them as the canonical worked instance of the general freshness contract.
- Update "What the orchestrator does not do" (`agents/orchestrator.md:166-170`): the dispatcher still does not detect staleness or record overrides; change the deferred-work pointer so it reads that override *definition and recording in step bodies/artifacts* is delivered by this milestone, while *dispatcher-level* staleness detection and override lifting are a deferred follow-on (do not promise it as "M9.6 in this sprint").

**Done when.** `agents/orchestrator.md` has an Artifact-state section defining derived freshness, signal-only review, and recorded override; the seven terms are each defined once; the report→fix invariant survives verbatim as the named special case; `git grep -n "Artifact state" agents/orchestrator.md` and `git grep -n "derived" agents/orchestrator.md` both hit.

---

### Task 2 — Freshness-stamp contract adoption in the four report-emitting steps

- [ ] Todo

**Goal.** Point each report-emitting step at the named general freshness contract and use the named `regenerated`/`discarded` behavior, with no mechanics change. Closes the step side of **M9.2**.

**Requirements.**

- For each of `compliance_report` (`agents/steps/compliance-report.md:41`, `:116`), `prose_pass` (`agents/steps/prose-pass.md:290`), `metaphor_identify` (`agents/steps/metaphor-identify.md:47-50`), and `anti_ai_report` (`agents/steps/anti-ai-report.md:37-40`): where the step documents its top-of-file `Reviewed-draft:` stamp and its overwrite-on-regenerate behavior, add a cross-reference to the general freshness contract in `agents/orchestrator.md`'s Artifact-state section and use the named terms — the overwrite path is `regenerated`, the dropped prior findings are `discarded`.
- Do not change any stamp mechanic, the stamp's placement, the overwrite/append decision, or any report content. This is a naming/cross-reference edit only.
- Do not touch frontmatter (`inputs`/`outputs`/`preconditions`) — no field changes.

**Done when.** The four report steps reference the general contract and use `regenerated`/`discarded`; `git diff` shows no mechanic change; both `check-pipeline-state.sh` modes still pass.

---

### Task 3 — Dual-check + override branch in the four fix/apply steps (+ `metaphor_fix`)

- [ ] Todo

**Goal.** Frame the freshness and review-evidence checks the fix/apply steps already perform as instances of the general contract, make the review-evidence gate uniform, and add an explicit recorded-override branch. Closes **M9.4** and the step side of **M9.5**.

**Requirements.**

- For each of `compliance_fix` (`agents/steps/compliance-fix.md:44`, `:106-116`), `prose_fix` (`agents/steps/prose-fix.md:39`), `metaphor_apply` (`agents/steps/metaphor-apply.md:34`), and `anti_ai_fix` (`agents/steps/anti-ai-fix.md:36`):
  - **Freshness check (already present):** reframe the `Reviewed-draft:` stamp-vs-`<latest-draft>` check as the consumption-time check of the general contract; cross-reference `agents/orchestrator.md`'s Artifact-state section as the canonical statement (keep the existing mechanics and the block-to-`open-questions.md` path).
  - **Review-evidence check (make uniform):** the unannotated-report blocker present in `compliance_fix` (`agents/steps/compliance-fix.md:112`, `:120`) is the review-evidence gate — an input with no `FIX`/`SKIP`/`ESCALATE` annotation is `review_pending` and blocks. State this consistently across the four steps, citing `compliance_fix` as the model; do not invent a positive "reviewed" stamp.
  - **Override branch (new):** add a branch that recognizes a human-recorded override (per Task 1's definition) for a stale or review-pending input and, only then, proceeds — and records the override in the step's apply log, naming the specific artifact and the draft mismatch, alongside the `Applied:` blocks (`agents/steps/compliance-fix.md:59`). Absent a recorded override, the stale and unannotated paths block exactly as today. No silent stale/unreviewed apply.
- Align `metaphor_fix`'s existing stale-annotation check (`agents/steps/metaphor-fix.md:52`, `:85`) to the same general-contract framing. `metaphor_fix` preserves its inherited stamp and mints no draft; only the framing/cross-reference changes.
- Do not change prose handling, `<next-draft>` naming, the manifest append, the `Active-head:` repoint, or any frontmatter list. `line_pass` has no upstream report and is out of scope for the dual-check (`agents/orchestrator.md:162`).

**Done when.** The four fix/apply steps document the freshness + review-evidence dual-check as instances of the general contract and carry an override branch that records overrides in the apply log; `metaphor_fix` is aligned; `git grep -ln "override" agents/steps` lists the four fix/apply steps; both `check-pipeline-state.sh` modes pass.

---

### Task 4 — Review-legibility surface: `AGENTS.md`, step-workflow template

- [ ] Todo

**Goal.** Make the signal-only review model and the derived-freshness model legible in the catalog docs, single-sourced to `agents/orchestrator.md`. Closes the catalog side of **M9.3**.

**Requirements.**

- `AGENTS.md` "How Amanuensis works" (`AGENTS.md:29`): add a clause that prose-derived side artifacts carry a *derived* freshness state (their `Reviewed-draft:` stamp compared to the active head) that the consuming step checks at step start, and that review remains a surfaced-not-enforced signal (the dispatcher does not block on it). Keep to the model shift; do not restate the contract.
- `templates/step-workflow.md` (`:27-28`): update the `review_sensitive` comment to note that it *declares* a review expectation that a consuming step surfaces as a non-blocking notice (per `agents/orchestrator.md`'s Artifact-state section) — it is not dispatcher-enforced. Keep the frontmatter shape unchanged (no new key).
- Confirm no consuming step gains a hard review block beyond the pre-existing unannotated-report path; the non-blocking-notice rule is stated once in `agents/orchestrator.md` (Task 1) and referenced, not re-specified per step.

**Done when.** `AGENTS.md` and `templates/step-workflow.md` reflect derived freshness and signal-only review with wording single-sourced to `agents/orchestrator.md`; no new frontmatter key; no new hard gate.

---

### Task 5 — Smoke coverage, verification sweep, ROADMAP / SPRINT check-off

- [ ] Todo

**Goal.** Document runnable verification of the state model and close the milestone. Closes **M9.7** and the residual of **M9**.

**Requirements.**

- Add M9.7 recipes to `examples/smoke/README.md`, in the style of the existing recipes and using only untracked files under `plot/drafts/attempt01/`, covering:
  - **Stale-report detection:** a `Reviewed-draft:`-stamped report against `draft-v01.md` with the manifest's `Active-head:` at a newer draft → the paired fix step blocks to `open-questions.md` (extend/reference the existing stale-report coverage rather than duplicating it).
  - **Review-pending (unannotated) block:** an existing but unannotated report → the fix step blocks as `review_pending`.
  - **Regeneration against the active head:** rerun the report-emitting step against the active head → it overwrites with a fresh stamp (`regenerated`) and the prior findings are `discarded`; the paired fix step then runs clean.
  - **Recorded override:** a human-recorded override on a stale/review-pending input → the fix step proceeds and records the override in its apply log; verify the override names the artifact and the draft mismatch.
- Confirm the existing reset procedure removes the new untracked fixture files; commit nothing new under `examples/smoke/` except the README edit.
- Run and review every check in Definition of done items 9–10 (both `check-pipeline-state.sh` modes, the `git diff --stat` untouched-surface check across `scripts/`, both `.github` ymls, both `pipeline-state.md` files, and `templates/dispatcher/`, and the greps).
- Confirm cross-file consistency by reading: the four report steps and four fix/apply steps against Task 1's Artifact-state section (no drift, no re-specified model); `AGENTS.md` and the template against the actual model.
- Update `ROADMAP.md`: check M9.1–M9.5 and M9.7 only after Tasks 1–4 pass verification; annotate M9.6 deferred; keep the Sprint-14 note accurate to what shipped.
- Check this SPRINT.md's per-task boxes (Tasks 1–5) only after their acceptance conditions hold.

**Done when.** The recipes are documented with expected outcomes and the reset covers them; all greps and script runs return the expected results; the untouched-surface check is clean; ROADMAP M9.1–M9.5/M9.7 are ticked and M9.6 is annotated deferred; SPRINT.md task boxes reflect completed work.

---

## Out of scope for this Sprint

- **Dispatcher-level staleness/review lift (M9.6).** The dispatcher stays existence-only; it does not read stamps, detect staleness, or record overrides. Lifting the checks into `run-step` on both hosts is a deferred follow-on, to be planned once the step-body state model proves out (`ROADMAP.md` M9 notes and Deferred list).
- **A stored `fresh|stale` field or a positive "reviewed" marker.** Rejected: freshness is derived and review is signal-only. No new frontmatter or manifest field is introduced.
- **New review-enforcement hard gates** beyond the pre-existing unannotated-report block. Review is surfaced, not enforced.
- **Any change to the step set, `scripts/check-pipeline-state.sh`, either CI workflow, either `pipeline-state.md`, or any dispatcher adapter under `templates/dispatcher/`.** M9 adds and removes no step and does not touch the dispatcher; these stay byte-for-byte unchanged.
- **Cross-attempt lineage or comparison tooling; reverse ingestion; pre-writing; multi-work concurrency** — later milestones and the Deferred list (`ROADMAP.md:188-205`, Deferred list).
