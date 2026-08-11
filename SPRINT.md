# Sprint 22 — Milestone 18: Unreviewed generated-state confirmation

This Sprint closes a loop Amanuensis has promised since Rule 1 but never wired up: permitted
invention "is recorded into the appropriate canonical files so it stops being a guess and
becomes reviewable truth" (`agents/update-rules.md:23-27`) — but nothing ever reviews it.
Three systems each write an `unreviewed` marker and stop there: the M3 capture agent stamps
`canon/generated/*` entries `status: invented, unreviewed`; M15's `continuity_update` stamps
new `continuity/` entries `- **review:** unreviewed`; M14's `scene_knowledge_update` stamps
new `knowledge/` entries the same way. No step or workflow ever flips one to confirmed. An
entry sits flagged indefinitely until something downstream trips over it — and M16's
retrofitted `compliance_report` can cite one of these as if it were settled truth, producing
an overconfident finding instead of a hedged one.

This is not a hypothetical gap. It is what happened on `the-course-he-kept`, surfaced live
during an `amanuensis-review` companion session on `plot/drafts/attempt02/reviewer-actions.md`.
`block-015-v02` reports "INCONSISTENT (canon)" against a voyage-timeline figure ("these six
weeks") — but that figure is not settled canon. It is the drafter's own invention, sitting in
`canon/generated/attempt02-voyage-log.md` under Scene 8, tagged `invented, unreviewed`, with
the drafter's own flag attached: *"storyboard says only 'for weeks' — adjust if canon fixes
the interval differently."* `block-011-v01`'s "three weeks" finding rests on the same kind of
unconfirmed inference. The checker contradicted the prose against its own unreviewed guess and
reported it with the same confidence as a real violation, and the human reviewer — who has
outside knowledge that could confirm or correct the figure — had no in-flow way to see that the
premise was shaky or to act on it without leaving the structured review entirely.

The fix is narrower than it first looks, because most of the mechanism already exists.
`/revise` (`agents/revision.md`) already does the collaborative, in-session, human-present
correction this class of problem needs — it edits `canon/` and `continuity/` current-state
entries in place and is designed to ask the human directly when something is ambiguous. What's
missing is three small, well-precedented pieces: `compliance_report` flagging when a finding's
premise is itself unconfirmed; `compliance_fix`'s already-defect-type-aware escalation routing
naming `/revise` as the concrete next action; and `/revise` gaining the ability to flip an
entry's marker to confirmed, whether it corrects the value or the human simply confirms it as
already right.

## Background — what is and isn't wrong today

Established by inspection during planning, with file:line cites; tasks should not re-derive
this.

- **Rule 1 promises review that no step delivers.** `agents/update-rules.md:23-27`: permitted
  invention "must be *captured, not hidden*: it is recorded into the appropriate canonical
  files so it stops being a guess and becomes reviewable truth." Nothing in the pipeline ever
  performs that review — `canon/generated/*` entries are written once (M3) and never revisited
  by any step.
- **Three systems share the same marker shape, and none has a confirmation workflow.**
  `canon/generated/attempt02-voyage-log.md` carries file-level `status: invented, unreviewed`
  frontmatter plus a per-entry inline tag, e.g. *"The Cape lies about six weeks astern at this
  dinner. (invented, unreviewed — scene 8, beat 2, attempt02; drafter flagged: storyboard says
  only 'for weeks' — adjust if canon fixes the interval differently.)"* `continuity_update`
  stamps each new fact `- **review:** unreviewed` (`agents/steps/continuity-update.md:65`).
  `scene_knowledge_update` stamps each new fact the same way
  (`agents/steps/scene-knowledge-update.md:61`). All three steps' own docs say a human *can*
  audit an unreviewed entry (`agents/steps/continuity-update.md:42`,
  `agents/steps/scene-knowledge-update.md:40`) — none says how that audit gets recorded, or
  what changes when it happens. An entry that is actually correct has no way to ever stop being
  flagged `unreviewed`.
- **`compliance_report`'s M16 relational/canon checks already resolve these referents for
  citation, but not for confidence.** Check 3 (Canon) reads `canon_active` first and escalates
  to *named* `canon/**` files (`agents/steps/compliance-report.md:135-141`); Check 4
  (Relational) resolves `continuity/` and `knowledge/` entries "by unambiguous,
  latest-attempt-qualified provenance" before citing them (`:149`,`:203-207`). Both checks
  already read the field they'd need to detect an `unreviewed` marker — they just don't look
  at it. A finding's violation line already carries a `[defect: <type>] [ref: <referent>]` tag
  when relational (`:106`,`:113`); this Sprint adds one more optional tag to that same line, it
  does not invent a new line shape.
- **`compliance_fix`'s escalation routing is already defect-type-aware — it just names the
  artifact class, not the concrete action.** Non-prose decisions are routed via an `Escalated:`
  block naming a "Suggested upstream target" by defect type — `storyboard` → the storyboard
  block; `state` → `continuity_update` / `revise` (continuity), `scene_knowledge_update` /
  `revise` (knowledge), or the human (reveals.md); `canon` → the named canon file
  (`agents/steps/compliance-fix.md:57-85`, especially `:79-85`). `revise` is *already* named as
  a target in the abstract for `state` defects. This Sprint sharpens that: when the referent is
  specifically `unreviewed`, name `/revise` against the exact entry, not the artifact class.
- **`/revise` already has the mechanism this needs; it just doesn't touch the marker.**
  `agents/revision.md:13` puts `canon/` files and `continuity/`'s current-state entries in its
  "always edited in place" scope. `:32` (Procedure step 1) has it "restate the change... old
  truth → new truth" and says "the revision command runs with the human present: ask directly,
  in-session." `:34` (step 3) has it "fix the source of truth first" in the canon/character
  file "before touching anything downstream." `:24` already draws the current-state-vs-record
  distinction this Sprint's marker-flip must respect: "a current-state entry carries current
  truth, so an authorial revision corrects it **in place**, keeping its `id`" — a confirmation
  is the same shape of in-place update, just without a content change. None of this needs to be
  invented; `/revise` needs one additional invocation shape (confirm-only, no content change)
  and one additional side effect (flip the marker) on both its existing and new paths.
- **The grammar and validator are out of this Sprint's touch set.** The new finding tag rides
  inside the existing violation line's free text, exactly as M16's `[defect:][ref:]` tag does
  (`agents/review-grammars.yaml`'s `compliance:` family keys off `^- ` item lines and the
  anchor/`Decision:` scheme, not the line's prose content). `scripts/validate-review-artifact.sh`
  parses structure, not violation-line prose. No family's `tokens`, `container_pattern`, or
  ledger fields are touched by anything this Sprint does.
- **This project is mid-recipe, which is why the gap is live rather than theoretical.**
  `pipeline-state.md` shows `compliance_report` done (`[x]`) and `compliance_fix`,
  `continuity_update`, `scene_knowledge_update` all not yet run (`[ ]`) — so
  `continuity/story.md` does not exist yet for this project, and the only unreviewed
  generated-state artifact currently in play is `canon/generated/attempt02-voyage-log.md`. That
  makes it a live, real fixture for M18.3/M18.4, but per the locked scope decision below, this
  Sprint does not touch it — a follow-up run does, after this Sprint ships.

## Definition of done

The Sprint is complete when:

1. `agents/update-rules.md` states the confirmation lifecycle once, in terms that cover all
   three marker systems' differing surface forms, and ROADMAP M18.1–M18.5 are checked.
2. `agents/revision.md` supports a confirm-only invocation (no content change, entry marked
   confirmed) alongside its existing correct-and-change flow, and both paths flip the cited
   entry's provenance marker on write, without disturbing the current-state-vs-record
   distinction already stated there.
3. `agents/steps/compliance-report.md` Checks 3 and 4 tag a finding distinctly when its cited
   referent (`canon_active`, a named `canon/**` file, or a `continuity/`/`knowledge/` entry)
   carries an unreviewed marker — an unconfirmed premise reads differently from a settled-truth
   citation.
4. `agents/steps/compliance-fix.md`'s upstream-target routing names `/revise` against the
   specific unreviewed entry (file + entry id) when a routed finding's referent is unreviewed,
   rather than naming the artifact class alone.
5. A synthetic fixture demonstrates the full round trip: an unreviewed-premise finding tagged
   distinctly, `ESCALATE` routing naming `/revise` against the specific entry, and both of
   `/revise`'s confirm and correct-and-confirm paths flipping the marker.
6. Verification passes: `agents/review-grammars.yaml` and `scripts/validate-review-artifact.sh`
   are byte-for-byte unchanged; the four families' fixtures under `examples/review/` are
   byte-for-byte unchanged; no pipeline step is added or removed and `pipeline-state.md` /
   `examples/smoke/pipeline-state.md` are untouched; no change lands outside the five touched
   docs (`agents/update-rules.md`, `agents/revision.md`,
   `agents/steps/compliance-report.md`, `agents/steps/compliance-fix.md`) plus the new fixture
   and `ROADMAP.md`/`SPRINT.md`.
7. `the-course-he-kept`'s actual `canon/generated/attempt02-voyage-log.md` and
   `reviewer-actions.md` are untouched by this Sprint (locked scope decision 3) — confirmed by
   `git diff --stat` against the project repo showing no changes there.

## Conventions adopted by this Sprint

Locked at planning (2026-08-11, prompted by the live companion session); tasks don't
rediscover them.

- **★ Scope is unified across all three unreviewed-marker systems, not `canon/generated/`
  alone (owner decision).** Rejected: ship `canon/generated/` first and extend to
  `continuity/`/`knowledge/` in later sprints, mirroring the M10→M11–M13 one-family-per-sprint
  precedent. The owner chose unified scope because the three systems already share identical
  marker shape and `compliance_report`'s relational checks already read all three for
  citation — a narrow fix would leave the exact same failure mode live on two of the three
  inputs the retrofit already consults, for no real savings (the lifecycle definition, the
  `/revise` extension, and the `compliance_report` detection logic are the same shape across
  all three; only the marker's surface syntax differs).
- **★ `/revise` is extended to own the write, for both confirmation and correction (owner
  decision).** Rejected: teach `compliance_fix` to write the confirmation itself. That would
  keep the write inside the review-decision flow, but it widens `compliance_fix`'s write
  surface beyond the draft + `reviewer-actions.md` it touches today, and duplicates a write
  path `/revise` already owns for exactly this class of file (`agents/revision.md:13`
  already lists `canon/` and `continuity/` current-state entries in its edit scope).
  `compliance_fix`'s only change this Sprint is what it *names* in its escalation routing, not
  what it writes.
- **★ This Sprint is definitional only — no live application to `the-course-he-kept` (owner
  decision).** Rejected: also resolve the actual voyage-timeline entries in
  `canon/generated/attempt02-voyage-log.md` via `/revise` and regenerate `reviewer-actions.md`
  as this Sprint's demonstration, dogfooding immediately. The owner chose to ship the mechanism
  first and apply it as a separate follow-up, matching how M15/M16 shipped their demonstrations
  against fixtures rather than live projects. The parked `reviewer-actions.md` review session
  (block-011 onward) stays parked through this Sprint and resumes separately afterward.
- **Marker vocabulary: `unreviewed` → `confirmed`, one terminal state covers both paths.** A
  `canon/generated/*` entry's `invented, unreviewed` becomes `invented, confirmed`; a
  `continuity/`/`knowledge/` entry's `- **review:** unreviewed` becomes `- **review:**
  confirmed`. No separate state is defined for "confirmed as originally written" vs.
  "corrected then confirmed" — the entry's stored value already reflects whichever happened
  (unchanged or edited), so the marker alone need only say the entry has been through a human
  confirmation pass. Rejected: a three-state marker (`unreviewed` / `confirmed-as-is` /
  `corrected`) — no consumer needs the distinction, since `/revise`'s existing report (step 8,
  `agents/revision.md:39`) already names what changed when something did.
- **Finding-tag convention: `[premise: unreviewed]`, appended only when the check actually
  resolved an unreviewed referent.** Rides the same violation line as the existing
  `[defect: <type>] [ref: <referent>]` tag from M16, appended after it, only on Check 3/4
  findings whose resolved referent carries the marker. Local checks (1–2) never carry it — they
  don't cite maintained state or named canon files. This is additive text inside the grammar's
  existing `^- ` item line, so no grammar or validator change is needed (see Background).
- **Detection is a read of a field already being resolved, not a new lookup pass.** M16 already
  requires `compliance_report` to resolve each cited `continuity/`/`knowledge/` entry and named
  canon file for the citation itself (`agents/steps/compliance-report.md:149`,`:203-207`); this
  Sprint's detection is reading that same resolved entry's marker field, immediately available
  at the point the citation is already being formed. No separate scan of `canon/generated/`,
  `continuity/`, or `knowledge/` is added.

---

## Tasks

Wave order: **Task 1** defines the lifecycle and vocabulary — Task 2 depends on it. **Task 2**
extends `/revise` and retrofits the two compliance steps against Task 1's definitions. **Task
3** demonstrates, verifies, and closes out, last. Run in order. Capture the Sprint-start SHA
(`git rev-parse HEAD`) before the first commit; the untouched-surface diff anchors there.

### Task 1 — Define the confirmation lifecycle

- [ ] Todo

**Goal.** State once, authoritatively, how an `unreviewed` entry becomes `confirmed` across
`canon/generated/*`, `continuity/`, and `knowledge/` — the marker vocabulary, the citation/
detection rule `compliance_report` follows, and the confirm-vs-correct distinction `/revise`
follows. Closes **M18.1**.

**Requirements.**

- Extend `agents/update-rules.md` Rule 1 (immediately after the existing `:23-27` "captured,
  not hidden" paragraph) with a short **Confirmation** subsection stating: the marker
  vocabulary locked in Conventions above (`unreviewed` → `confirmed`, surface form per system);
  that confirmation happens via `/revise` (either path — confirm-only or correct-and-confirm);
  and that a `compliance_report` finding citing an `unreviewed` entry is tagged `[premise:
  unreviewed]` per the Conventions above, so the human sees the premise's confidence at review
  time rather than needing to separately check the source file.
- Do not restate the per-system marker mechanics (`canon/generated/*`'s frontmatter status,
  `continuity/`/`knowledge/`'s `- **review:**` field) — those stay defined where M3/M14/M15
  already define them; this task adds only the confirmation half and cross-references the
  existing write-side definitions.
- Do not edit `agents/revision.md`, either compliance step, or any fixture in this task — those
  are Task 2.

**Done when.** `agents/update-rules.md` states the lifecycle, vocabulary, and citation rule in
one place; nothing downstream needs to re-derive them.

---

### Task 2 — Extend `/revise`; retrofit `compliance_report` and `compliance_fix`

- [ ] Todo

**Goal.** Give `/revise` a confirm-only path and a marker-flipping side effect on both paths;
teach `compliance_report` to tag a finding when its resolved referent is unreviewed; teach
`compliance_fix`'s escalation routing to name `/revise` against the specific entry. Closes
**M18.2**, **M18.3**, **M18.4**.

**Requirements.**

- **Extend `agents/revision.md`:**
  - Add a confirm-only invocation to `## Invocation` (`:7-9`): parsed the same tolerant,
    prose-not-CLI way as the existing change-description invocation — a request that names an
    entry and states it should be confirmed as correct, with no proposed change. If the request
    is ambiguous about whether it's a confirmation or a correction, ask (per the existing
    ambiguity-resolution rule at `:32`).
  - In `## Procedure` step 1 (`:32`), add: on a confirm-only request, restate what is being
    confirmed and proceed once the human confirms, skipping steps 3/6 (nothing to fix or
    apply) but still running step 4 (Sweep) read-only if useful context, and closing with step
    8's report.
  - Both the correct-and-change flow (existing) and the new confirm-only flow flip the target
    entry's marker to `confirmed` (per Task 1's vocabulary) as part of the same edit (or, for
    confirm-only, as the sole edit) — stated as a new sentence in `## Edit scope` or `##
    Procedure` step 6, wherever it reads most naturally alongside the existing in-place-edit
    language at `:13`,`:24`.
  - Do not touch the transition-structure prohibitions at `:22` — a confirmation is a
    current-state-entry update, never a fabricated `## Superseded` / `## Lost or superseded`
    transition.
- **Retrofit `agents/steps/compliance-report.md`:**
  - In Check 3 (Canon, `:135-141`) and Check 4 (Relational, `:143-157`), when the check resolves
    a cited referent (a named `canon/**` file, or a `continuity/`/`knowledge/` entry per the
    provenance resolution already required at `:149`), read that referent's marker. If it is
    `unreviewed`, append `[premise: unreviewed]` to the violation line, after the existing
    `[defect: <type>] [ref: <referent>]` tag where present (Check 4) or standing alone where
    Check 3 has no defect tag today.
  - No change to Checks 1–2 (Must-Contain, Must-Not-Contain) — they don't cite maintained state
    or named canon files.
  - No change to the `### Summary` or `## Context consulted` sections beyond what already names
    the consulted entries — the tag lives on the violation line only.
- **Retrofit `agents/steps/compliance-fix.md`'s escalation routing (`:57-85`):** when a unit
  routed upstream (`ESCALATE`, or a non-prose `FIX`) carries the `[premise: unreviewed]` tag on
  its violation line, the `Escalated:` block's "Suggested upstream target" names `/revise`
  against the specific entry (file path + entry id, read from the `[ref: <referent>]` tag
  already present) rather than the defect-type-only target it names today. Where a unit has no
  `[ref: <referent>]` tag (a Check 3 canon finding predating M16's relational-only referent
  citation), name `/revise` against the named canon file instead of a specific entry id.
- **Verify the grammar/validator are untouched:** run
  `sh scripts/validate-review-artifact.sh examples/review/reviewer-actions.md
  agents/review-grammars.yaml` (and the other three fixtures) after the retrofit and confirm
  identical ledgers/exit codes to before this task — the new tags are additive prose inside
  existing violation lines, per the Conventions above.

**Done when.** `/revise` accepts a confirm-only request and flips the target entry's marker on
either path; `compliance_report` tags a finding whose resolved referent is unreviewed;
`compliance_fix` names `/revise` against the specific entry when routing such a finding
upstream; all four `examples/review/` fixtures validate identically to before this task.

---

### Task 3 — Demonstration, verification, and close-out

- [ ] Todo

**Goal.** Prove the round trip end-to-end against a synthetic fixture, run the verification
sweep, and close the milestone. Closes **M18.5** and the residual of **M18**.

**Requirements.**

- Add a synthetic fixture (a small hand-authored chapter-folder slice, not a full project —
  mirror the scale of `examples/relational-review/` from Sprint 21) with: one `canon/generated/`
  entry (or `continuity/`/`knowledge/` entry — cover at least one of the three systems, note in
  the README that the mechanism is identical across all three per Task 1/2) stamped
  `unreviewed`; a `compliance_report` finding citing it, showing the `[premise: unreviewed]`
  tag; the `Escalated:` block naming `/revise` against the specific entry; and a worked
  `/revise` confirm-only pass and a separate correct-and-confirm pass, each showing the marker
  flip. Place it under `examples/` with a README, clearly marked as an example per
  `AGENTS.md:22-26`.
- Run the verification sweep: `git diff --stat` against the captured Sprint-start SHA shows
  changes confined to `agents/update-rules.md`, `agents/revision.md`,
  `agents/steps/compliance-report.md`, `agents/steps/compliance-fix.md`, the new fixture
  directory, `ROADMAP.md`, and `SPRINT.md` — nothing else; `agents/review-grammars.yaml` and
  `scripts/validate-review-artifact.sh` show no diff; the four `examples/review/` fixtures show
  no diff; `pipeline-state.md` and `examples/smoke/pipeline-state.md` show no diff; both
  `scripts/check-pipeline-state.sh` modes still pass.
- Confirm (separately, against the consuming project, not as a commit in this Sprint) that
  `the-course-he-kept`'s `canon/generated/attempt02-voyage-log.md` and
  `plot/drafts/attempt02/reviewer-actions.md` are untouched — locked scope decision 3.
- Update `ROADMAP.md`: check M18.1–M18.5 only after Tasks 1–2 pass verification. Check this
  SPRINT.md's per-task boxes (Tasks 1–3) only after their acceptance conditions hold.

**Done when.** The synthetic fixture demonstrates the full round trip (unreviewed citation →
tagged finding → routed escalation naming `/revise` → confirm or correct-and-confirm flipping
the marker); the verification sweep and both `check-pipeline-state.sh` modes pass; ROADMAP
M18.1–M18.5 and the SPRINT task boxes reflect completed work.

---

## Out of scope for this Sprint

- **Live application to `the-course-he-kept`.** Resolving the actual voyage-timeline entries in
  `canon/generated/attempt02-voyage-log.md` and regenerating `reviewer-actions.md` is a
  follow-up the human runs after this Sprint ships (locked decision 3). The parked
  `reviewer-actions.md` review session resumes separately, not as part of this Sprint.
- **Any change to `agents/review-grammars.yaml`, `scripts/validate-review-artifact.sh`,
  `agents/review-validation.md`, or the `amanuensis-review` companion skill.** The new finding
  tag is additive prose inside an existing violation line; no family's token set, container
  pattern, or ledger field changes. No new review family.
- **New pipeline step, recipe change, or dispatcher change.** This Sprint retrofits existing
  step docs (`compliance_report`, `compliance_fix`) and a host command (`/revise`) already
  outside the recipe. `pipeline-state.md`, both CI workflow ymls, and `install.sh` are
  untouched.
- **A third marker state for "confirmed as originally written" vs. "corrected then
  confirmed."** One terminal `confirmed` state covers both, per Conventions above.
- **OpenCode parity for `/revise` or the compliance steps.** Unrelated to and untouched by this
  Sprint; OpenCode companion parity is tracked separately under M17.
- **Dispatcher-level detection of unreviewed entries.** Matches the standing dispatcher-stays-
  thin non-goal already recorded in `agents/orchestrator.md` for staleness and overrides;
  detection here stays in the step bodies (`compliance_report`) exactly as those do.
- **Revise coverage of M14 temporal-state files (the related Deferred item).** That item is a
  demonstration gap for `/revise`'s *existing* current-vs-record discipline against
  `knowledge/`/`timeline.md`/`relationships.md`. This Sprint's Task 3 fixture may incidentally
  touch that ground for the `knowledge/` case, but closing that Deferred item fully is not this
  Sprint's goal and its checkbox is not touched here.
