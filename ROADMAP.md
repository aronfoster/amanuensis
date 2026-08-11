# Amanuensis Roadmap

Remaining work, in rough dependency order. Tasks plus short notes on what's done.
Project overview, architecture, and current status live elsewhere.

Several milestones edit the canonical step list (`templates/pipeline-state.md`); they
are sequenced, not parallel, so it is never edited by two at once.

---

## M17 — Review companion: OpenCode parity + override capture

Bring the `amanuensis-review` companion to full host parity and give it the one
human-decision surface it still lacks. Two now-unblocked Deferred items promoted together
at triage (2026-08): **OpenCode parity for the companion** and **companion capture of
stale-`Override:` blocks**. Bundled so the OpenCode adapter is written once already
carrying the override surface, rather than porting Claude-first and re-opening the parity
gap.

Today `install.sh` installs asymmetrically: Claude Code gets three dispatcher commands
**and** the companion skill; OpenCode gets only the three dispatcher agents
(`install.sh:79-93`). So an OpenCode user runs the full pipeline and all four review
families but reviews them by hand — opening `reviewer-actions.md` / `metaphors.md`,
hand-writing `Decision:` / `Selected:` fields, running the validator manually — with none
of the guided queue, progress counts, fan-out, or two-round metaphor flow M10–M13 built.

Done when: an OpenCode user can review any of the four artifact families through a
companion at behavior/safety parity with the Claude Code skill; both hosts' companions can
capture a human-stated stale-override into the review artifact without a hand-edit;
`install.sh` installs the companion to both hosts; and the shared contracts
(`agents/review-grammars.yaml`, `agents/review-validation.md`,
`scripts/validate-review-artifact.sh`) are unchanged — both companions stay thin adapters
over them.

* [ ] M17.1 Port the companion to OpenCode as an explicitly-invoked agent
  (`templates/dispatcher/.opencode/agents/amanuensis-review.md`), mirroring the Claude Code
  skill's procedure, pacing controls, category/fan-out handling, two-round (metaphor)
  handling, and hard rules. Behavior and safety checks match; activation need not (the M7.8
  precedent) — Claude Code auto-activates the skill, OpenCode invokes the agent like
  `run-step`.
* [ ] M17.2 Wire `install.sh` to install the OpenCode companion alongside the existing
  `.opencode/agents/` dispatcher agents, parallel to the Claude Code skill block
  (`install.sh:82,114,130`).
* [ ] M17.3 Define the companion override carve-out and implement it in the Claude Code
  skill: capture a human-*stated* stale-override and write the `Override:` block into the
  review artifact (the file the companion already writes), per the block shape and
  recognition rules in `agents/steps/compliance-fix.md:118-138`. The companion originates
  no override and states no decision the human did not — it captures, exactly as it does
  `Decision:` fields. Update the companion hard rules to permit this one write; the current
  confinement forbids touching artifact state (`SKILL.md:193-202`).
* [ ] M17.4 Carry the override carve-out into the OpenCode companion (M17.1) so both hosts
  land at parity, covering all four families' override paths (the `Override:` mechanism is
  identical across the fix/apply steps).
* [ ] M17.5 Smoke coverage: an OpenCode review round-trip for one family (report →
  companion-captured decisions → fix consumes); and an override captured by the companion
  (stale report → human authorizes → companion writes the `Override:` block → fix step
  recognizes it and records it in its apply log).

Notes: Promoted from Deferred at triage (2026-08). Preconditions were met by M13 — the
companion contract is stable across all four families, including the two-round metaphor
selection layer. The port is bounded because the companion is an explicit thin adapter
(`SKILL.md:15`) over host-agnostic contracts that already exist; parity means the same
behavior and safety checks, not identical activation (M7.8). Override capture (former
Deferred item) is folded in here rather than shipped Claude-first, so both hosts reach
parity in one pass. Not in scope: any change to the grammar/validator contracts, and any
new review family. Recorded as a roadmap milestone; turn it into an active SPRINT.md via a
planning pass when it is scheduled.

---

## M18 — Unreviewed generated-state confirmation

Close the loop `agents/update-rules.md`'s Rule 1 promises but never wires up: permitted
invention "is recorded into the appropriate canonical files so it stops being a guess and
becomes reviewable truth" (`:23-27`) — but nothing ever reviews it. **Five** destinations
already write an `unreviewed` marker and stop: the M3 capture agent stamps `canon/generated/*`
entries `status: invented, unreviewed`, and stamps character `timeline.md` (fact-type `event`)
and `profile.md` (fact-type `identity`) entries the same way
(`agents/capture/capture-agent.md`'s routing table and Write discipline section); M15's
`continuity_update` stamps new `continuity/` entries `- **review:** unreviewed`
(`agents/steps/continuity-update.md:65`); M14's `scene_knowledge_update` stamps new
`knowledge/` entries the same way (`agents/steps/scene-knowledge-update.md:61`). None has a
confirmation workflow. An entry sits flagged indefinitely until something downstream trips
over it — and M16's retrofitted `compliance_report` (`agents/steps/compliance-report.md`
Checks 3–4) can cite a `canon/**`/`continuity/`/`knowledge/` entry it consults as if it were
settled truth, producing an overconfident finding instead of a hedged one. (`compliance_report`
does not read `timeline.md`/`profile.md` at all today — see the scope note below.)

This is not hypothetical: it is what happened on `the-course-he-kept`. Reviewer-actions.md's
`block-015-v02` (and, by the same mechanism, `block-011-v01`) reports "INCONSISTENT (canon)"
against a voyage-timeline figure — but that figure is not settled canon. It is the drafter's
own invention, sitting in `canon/generated/attempt02-voyage-log.md` under scene 8, tagged
`invented, unreviewed` with the drafter's own flag: *"storyboard says only 'for weeks' —
adjust if canon fixes the interval differently."* The checker contradicted the prose against
its own unconfirmed guess and reported it with the same confidence as a real violation. The
human reviewer has outside knowledge that could confirm or correct that entry — `/revise`
(`agents/revision.md`) already provides exactly the in-session, human-present mechanism to do
so (`:32`, `:34`: "runs with the human present: ask directly"; "fix the source of truth
first... `canon/` file") — but nothing points the reviewer at it from inside the finding, and
`/revise` itself never flips the entry's marker even when it corrects the value.

Done when: `/revise` can confirm-or-correct an unreviewed entry across **all five**
destinations (`canon/generated/*`, `characters/<id>/timeline.md`, `characters/<id>/profile.md`,
`continuity/`, `knowledge/`), flipping its provenance marker either way via a write it actually
performs (a confirm-only request still runs `/revise`'s Apply step, with the marker flip as its
only edit — skipping it would report success while writing nothing), without disturbing the
non-destructive current-vs-record discipline `agents/revision.md` already states; a
`compliance_report` finding whose check actually resolved a `canon/**` file (via Check 3's own
Canon-check escalation path, **or** Check 4's separate Canon-consistency sub-check, which
escalates to a named canon file the same way) or a `continuity/`/`knowledge/` entry is flagged
distinctly when that resolved source's per-entry marker carries `unreviewed` — bare
`canon_active` comparisons are out of reach by design (see scope note below) and
`timeline.md`/`profile.md` citations are out of reach because `compliance_report` does not
consult them at all (tracked, not silently dropped — see Deferred); and `compliance_fix` treats
`[premise: unreviewed]` as an override on the ordinary defect-label routing — **any** decision on
a tagged unit, `FIX` included regardless of defect label or its absence, is routed upstream and
never applied to prose until the entry is confirmed, naming `/revise` against the specific
unreviewed entry as the suggested upstream target and reading the locator straight off the
violation line's tag (this step cannot read canon or state files) — `continuity/`/`knowledge/`'s
minted `co-NN`/`kn-NN` id, or `canon/generated/`'s self-contained scene/beat/attempt-plus-quote
locator that whichever check resolved it already wrote into the tag, since no minted id exists
there.

* [ ] M18.1 Design note: define the confirmation lifecycle once — `unreviewed` →
  `confirmed` (or corrected-and-confirmed) — in uniform terms across all five destinations'
  differing surface forms (`status: invented, unreviewed` vs. `- **review:** unreviewed`), and
  the citation rule `compliance_report` follows to detect one *where it already resolves a
  marker-bearing source* (see scope note). Single-source it by extending
  `agents/update-rules.md` (Rule 1) rather than restating per-file.
* [ ] M18.2 Extend `agents/revision.md`: a confirm-only invocation (human reviews an entry,
  agrees, no content change) alongside the existing correct-and-change flow, covering all five
  destinations — `canon/generated/*`, `timeline.md`, `profile.md`, `continuity/`, `knowledge/`
  (all already in `/revise`'s edit scope, `:13`). The confirm-only path skips only step 3
  (nothing to fix); it still runs step 6 (Apply) — `/revise`'s sole write operation — with the
  marker flip as its only edit, so the request actually writes something rather than reporting
  success with no change. Preserve the current-state-vs-record distinction already stated there
  (`:24`) — a confirmation is an in-place update to a current-state entry, never a fabricated
  transition.
* [ ] M18.3 Retrofit `compliance_report` Checks 3 (Canon) and 4 (Relational): when a check
  actually resolves a named `canon/**` file — Check 3's own Canon-check escalation path, **or**
  Check 4's separate Canon-consistency sub-check, which escalates the same way (both fire only
  when `canon_active` is insufficient) — or a `continuity/`/`knowledge/` entry via Check 4's
  targeted retrieval, and that resolved entry's **per-entry** marker (never a `canon/generated/`
  file's own file-level frontmatter `status:`, which this milestone never reads or writes for
  any entry) is unreviewed, tag the finding distinctly from a settled-truth citation. For a
  `canon/generated/` referent specifically (no minted id, reached by either check's canon-file
  escalation), also write a self-contained `[ref: canon/generated/<file>#<scene-beat-attempt>
  "<quote>"]` tag onto the violation line at report time — `compliance_fix` cannot read canon
  files to reconstruct this later (`agents/steps/compliance-fix.md:51`) and the report's `##
  Context consulted` section records only the file path, not the entry (`:178-186`). Bare
  `canon_active` comparisons (either check's common, non-escalated path) are explicitly out of
  scope: `agents/storyboard-schema.md:110-112` requires `canon_active` to hold an extracted
  rule, "not a file path, not a summary of a source document," so there is no source to check a
  marker against until the check escalates — forcing provenance back into `canon_active` would
  fight that schema decision, not fix a bug in it. `timeline.md`/`profile.md` are out of scope
  for this task (`compliance_report` has no input reading them — see Deferred).
* [ ] M18.4 Retrofit `compliance_fix`'s routing so `[premise: unreviewed]` overrides the
  ordinary defect-label rule for `FIX`, not only for units already routed upstream. Today, `FIX`
  goes straight to a prose edit whenever the defect label is `prose` or absent
  (`agents/steps/compliance-fix.md:59`) — exactly the common shape of a tagged finding (a Check
  3 escalation-path finding carries no defect tag; a Check 4 finding whose prose contradicts
  what reads as "settled, valid" canon is labeled `prose`, since the taxonomy doesn't yet know
  that canon is itself unconfirmed). Left unchanged, a human deciding `FIX` on exactly the
  finding this milestone exists to catch would still get a silent prose edit encoding the
  unconfirmed guess as accepted truth. So: check for `[premise: unreviewed]` *before* the
  defect-label rule; if present, route the unit upstream regardless of decision token or defect
  label, exactly as a non-prose-defect unit already is. When routing such a unit, name `/revise`
  against the specific entry as the suggested target, reading the locator straight off the
  violation line's `[ref: <referent>]` tag rather than re-deriving it (this step cannot read
  canon or state files, `:51`) — `continuity/`/`knowledge/`'s minted `co-NN`/`kn-NN` id, or
  `canon/generated/`'s self-contained file+provenance+quote locator that M18.3 now writes into
  the tag — not just "the canon file" in the abstract.
* [ ] M18.5 Smoke/demo coverage: a synthetic fixture exercising an unreviewed-premise finding
  flagged distinctly (via a resolved `canon/**`/`continuity/`/`knowledge/` source, not bare
  `canon_active`), `ESCALATE` routing naming `/revise` with each system's actual locator shape,
  and `/revise`'s confirm and correct-and-confirm paths each flipping the marker — including at
  least one `timeline.md` or `profile.md` entry to prove the extended `/revise` scope.

Notes: Sprint 22 plans M18 (see SPRINT.md). Locked at planning (2026-08-11, prompted by a
live `amanuensis-review` companion session on `the-course-he-kept`): (1) **scope is
unified across all unreviewed-marker systems**, not `canon/generated/` alone —
rejected: ship `canon/generated/` first and extend to the others in later
sprints (the M10→M11–M13 precedent), because these systems share identical marker shape
and `compliance_report`'s relational checks already read several of them, so a narrow fix would
leave the same failure mode live on the rest. (2) **`/revise` is
extended to own the write**, confirm and correct alike — rejected: teach `compliance_fix`
to write the confirmation itself (keeps the write inside the review-decision flow, but widens
`compliance_fix`'s write surface beyond the draft + `reviewer-actions.md` it touches today,
and duplicates a write path `/revise` already owns for exactly this class of file). (3) **This
sprint is definitional only** — no live application against `the-course-he-kept`'s actual
`canon/generated/attempt02-voyage-log.md` entries or regeneration of its `reviewer-actions.md`;
that stays a follow-up the human runs afterward, once `/revise`'s confirm path and the
sharpened routing exist to run it through. The parked `reviewer-actions.md` review session
predating this milestone resumes separately. Related Deferred item: "revise coverage of M14
temporal-state files" (below) is a demonstration gap for `/revise`'s *existing* discipline;
M18.2 adds new behavior and is tracked here, not there. (4) **Scope corrections from PR review
(Codex PR-57 round 1):** the original planning pass undercounted the marker destinations (missed
`timeline.md`/`profile.md`, capture-agent-routed alongside `canon/generated/`) and overstated
`compliance_report`'s reach (implied `canon_active` itself could be marker-checked, and implied
a uniform "file + entry id" locator when `canon/generated/` mints no entry id). `/revise`'s
confirm-or-correct scope is widened to all five destinations (M18.2, M18.5); `compliance_report`
detection (M18.3) stays scoped to sources it actually resolves — `timeline.md`/`profile.md`
detection is not built this milestone (added to Deferred below, not silently dropped), and
`canon_active`'s own schema constraint is documented as a deliberate boundary, not a defect.
(5) **Further corrections from PR review (Codex PR-57 round 2):** two more confirmed gaps.
First, `compliance_fix` is forbidden from reading canon files (`agents/steps/compliance-fix.md:51`)
and the report's `## Context consulted` section names only a file path, never a specific entry's
provenance or text — so a `canon/generated/` locator has nowhere to come from at fix time unless
`compliance_report` writes the complete locator (file + scene/beat/attempt + quote) into the
violation line's `[ref: <referent>]` tag itself, at report time, while it still has the entry in
hand; M18.3/M18.4 now specify this explicitly rather than leaving the locator's origin
unspecified. Second, `canon/generated/*` files carry the marker at **two levels** — a file-level
frontmatter `status:` written once at file creation, and a per-entry inline tag on every captured
fact (`agents/capture/capture-agent.md:62-76`,`:93-96`) — and the real multi-entry
`attempt02-voyage-log.md` fixture has both, with many independently-confirmable entries under one
file status. Flipping the file-level status on one entry's confirmation would misrepresent every
sibling entry as confirmed; this milestone therefore scopes detection and confirmation to the
per-entry inline tag exclusively, for every `canon/generated/` entry — the file-level `status:`
is never read or written by this mechanism, for any entry, confirmed or not (an aggregate rule
was considered and rejected as unneeded complexity for a field no consumer reads).
(6) **Further corrections from PR review (Codex PR-57 round 3):** two more confirmed gaps.
First, Check 4 has its **own** canon-file escalation — its Canon-consistency sub-check
(`agents/steps/compliance-report.md:153`) opens a named `canon/**` file exactly like Check 3's
Canon check does, when `canon_active` is insufficient — which the plan had scoped the
marker/locator handling away from, leaving the relational path able to reproduce the milestone's
motivating failure. M18.3/M18.4 now cover both escalation points identically. Second, the
`/revise` confirm-only procedure as planned skipped step 6 (Apply) — `/revise`'s sole write
operation (`agents/revision.md:37`) — alongside step 3, which would perform no write at all and
could report success while leaving the entry unreviewed. M18.2 now skips only step 3; step 6
still runs, with the marker flip as its only edit.
(7) **Further correction from PR review (Codex PR-57 round 4) — the most safety-critical one:**
`compliance_fix`'s existing defect-label rule sends `FIX` straight to a prose edit whenever the
label is `prose` or absent (`agents/steps/compliance-fix.md:59`) — exactly the common shape of a
`[premise: unreviewed]`-tagged finding (a Check 3 escalation-path finding carries no defect tag;
a Check 4 finding whose prose contradicts what reads as "settled, valid" canon is labeled
`prose`, since the taxonomy doesn't independently know that canon is unconfirmed). As originally
scoped, `[premise: unreviewed]` was purely informational — a human deciding `FIX` on the exact
finding this milestone exists to catch would still get a silent prose edit encoding the
unconfirmed guess as accepted truth, defeating the milestone's purpose. M18.4 now makes
`[premise: unreviewed]` an override, checked before the defect-label rule: **any** decision on a
tagged unit is routed upstream, `FIX` included, regardless of defect label or its absence, until
the entry is confirmed.

---

## Completed

### M1 — Pipeline step-list consistency

Make every step list agree with `agents/steps/` and single-source it.

Done when: all step lists match the step files; `orchestrator.md` references the
canonical list instead of duplicating it; the smoke fixture is checked against it.

- [x] M1.1 Propagate the `anti_ai_report`/`anti_ai_fix` split into
  `examples/smoke/pipeline-state.md`, the `orchestrator.md` state example, and any
  README references still showing monolithic `anti_ai`.
- [x] M1.2 Make `templates/pipeline-state.md` canonical; point `orchestrator.md` at it
  rather than re-listing; add a check that the smoke fixture's step set matches.
- [x] M1.3 Replace any other hard-coded step lists (README, `workflows.md`, adapter
  template) with references.

Notes: Also shipped a consumer-side validator — `scripts/check-pipeline-state.sh` plus
a CI workflow template (`templates/dispatcher/.github/workflows/pipeline-state-check.yml`)
installed by `install.sh` — so consuming projects' `pipeline-state.md` files are
checked against their installed Amanuensis step set on push and pull request.

---

### M2 — Drafting artifact cleanup

Delete per-scene fragments after assembly; align the step body with the OpenCode
coordinator.

Done when: a drafting run leaves `draft.md` and `notes.md` only; `sceneNN.md` /
`sceneNN-notes.md` removed; `drafting.md` frontmatter no longer lists them as durable
outputs.

- [x] M2.1 Add post-assembly deletion of `sceneNN.md` / `sceneNN-notes.md` to
  `drafting.md`, mirroring `opencode/agents/chapter-coordinator.md`.
- [x] M2.2 Reconcile `drafting.md` frontmatter: drop the per-scene fragments from
  durable outputs or mark them transient.
- [x] M2.3 Document the audit-record vs transient-fragment distinction (persist
  `reviewer-actions.md`, `metaphors.md`, `anti-ai.md`, `notes.md`; delete scene fragments).

Notes: The OpenCode coordinator (`chapter-coordinator.md`) was also pointed at the
shared persist-vs-delete rule in `chapters.md` for host parity.

---

### M3 — Bounded canon invention + capture

Replace the blanket "do not invent canon" with one bounded rule; resolve the
`orchestrator.md` TODO; add a coordinator-managed **capture agent** that records the
continuity-relevant inventions the rule permits into the right canonical files.

Done when: a single statement of the rule exists and is referenced from the step
bodies; the contradictory TODO is gone; the drafting coordinator dispatches a capture
agent that writes permitted inventions to `timeline.md` / `profile.md` / an
agent-generated `canon/` subfolder (never `knowledge/`), with annotated, edit-policy-
respecting, non-blocking writes, at parity on both hosts.

#### The rule

- [x] M3.1 Write the rule (in `canon.md` or `update-rules.md`): invent only when canon
  and plan are silent, it cannot contradict existing canon, it fits genre/register/period,
  and it is not load-bearing for reveal timing or character knowledge; otherwise record an
  open question.
- [x] M3.2 Reference it from `drafting.md`, `scene-generation.md`,
  `character-extraction.md`, `storyboarding.md`, `update-rules.md`; keep the hard
  prohibition for reveal- and knowledge-load-bearing facts.
- [x] M3.3 Resolve the `orchestrator.md` invention TODO.

#### The capture agent

A new subagent role dispatched by the drafting coordinator (and the OpenCode
`chapter-coordinator`), **not** a new pipeline step. The sandboxed scene-drafters stay
sandboxed — they only emit *recommendations*; the capture agent is the one role permitted
to write character and canon files.

- [x] M3.4 Recommendation hand-off. Define the schema a scene-drafter emits in its
  `sceneNN-notes.md` for each continuity-relevant invention: the invented fact, the target
  (`character_id`(s) or world-scope), the fact-type (`event` / `identity` / `world`), and the
  source scene+beat. Add a line to the `drafting.md` subagent prompt contract instructing
  subagents to record these (they still write nothing outside their notes/prose).
- [x] M3.5 Coordinator collection + dispatch. The coordinator gathers recommendations while
  assembling `notes.md` (drafting step 8) and dispatches the capture agent **before** the
  step-9 fragment deletion, so nothing is lost when `sceneNN-notes.md` is removed. Capture
  is gated like deletion: it runs only on a completed assembly, never on a failure/abandon
  path.
- [x] M3.6 Capture agent definition + routing. Write the agent (a host doc under `agents/`
  plus an `opencode/agents/` counterpart). Routing:
  character `event` → `characters/<id>/timeline.md`; invented stable identity color →
  `characters/<id>/profile.md`; **never `knowledge/`** (reserved for the deferred
  scene-knowledge-update step and reveal-sensitive — `characters.md:61`); non-character /
  `world` facts → a new agent-generated subfolder under `canon/` (kept distinct from
  human-authored canon); a walk-on with no folder → create a `status: stub` folder per
  `characters.md` then write. Capture only records inventions the M3.1 rule permits;
  reveal-/knowledge-load-bearing facts are still recorded as open questions, never captured.
- [x] M3.7 Write discipline. Each write is annotated with source scene+beat, draft-version
  provenance (the M4.3 stamp — "which draft did this come from"), and an
  `invented, unreviewed` marker; respects the target file's `edit_policy` (no silent write
  to a locked / propose-only file — emit a proposal / log instead); and is non-blocking —
  a capture failure never blocks draft completion, it is logged in `notes.md`. Captured
  writes ride drafting's existing `review_required: true` gate.
- [x] M3.8 Host parity. Mirror the coordinator dispatch and the capture agent across the
  `.claude` drafting coordinator (`agents/steps/drafting.md`) and
  `opencode/agents/chapter-coordinator.md`.

Notes: knowledge/ is deliberately out of bounds for capture — it stays the sole province of
the scene-knowledge-update step, which protects reveal timing. M3.7's provenance
annotation depends on M4.3's per-draft-version stamp. The agent-generated canon subfolder was
named `canon/generated/` (Sprint 8 Open decision 1); capture annotates source scene + beat +
attempt now and folds in the M4.3 draft-version stamp when M4 lands.

---

### M4 — Versioned draft naming

Decouple prose-bearing draft filenames from the producing step so prose-chain reordering
is a `pipeline-state.md`-only edit. Prerequisite for M5 and M7.

Done when: prose-advancing steps read `<latest-draft>` and write the next version; report
steps read `<latest-draft>` and do not increment; provenance is recorded; side-artifacts
keep their step names; the report→fix adjacency invariant is documented.

- [x] M4.1 Define `<latest-draft>` resolution (highest-numbered `draft-vNN.md` in the
  attempt), parallel to `<latest-attempt>`. Drafting produces `draft-v01.md`.
- [x] M4.2 Convert prose-advancing steps (`drafting`, `compliance_fix`,
  `metaphor_apply`, `line_pass`, `anti_ai_fix`) to write `<next-draft>`; convert prose-reading
  steps (`compliance_report`, `prose_pass`, `metaphor_identify`, `metaphor_fix`,
  `anti_ai_report`) to read `<latest-draft>`.
- [x] M4.3 Add provenance to each draft version (frontmatter stamp `produced_by` / `reads`,
  or an attempt-level manifest). This is also the "which draft did this come from" stamp that
  M3.7's capture annotations reference — define it so a captured invention can name its source
  draft version.
- [x] M4.4 Document the report→fix adjacency invariant: no draft increment between a report
  and its paired fix.
- [x] M4.5 Sweep the rename through docs that hard-code `draft.md` (`chapters.md`,
  `project-layouts.md`, schema examples) and the canonical state list.

Notes: side-artifacts (`reviewer-actions.md`, `metaphors.md`, `anti-ai.md`,
`prose-pass.md`) stay step-named; only prose-bearing files are versioned. Sprint 9 landed
provenance as an attempt-level `draft-manifest.md` (not per-draft frontmatter) because
drafting's prose-only invariant precludes in-file YAML in the draft files themselves; each
prose-advancing step appends a per-version entry to the manifest. `prose_fix` remains deferred
to M5; M4 only makes the versioned naming model ready for it.

---

### M5 — Prose fix apply step

Close the prose-apply orphan: `prose_pass` recommendations get applied into the versioned
draft the metaphor stage reads. Depends on M4.

Done when: `prose_fix` reads annotated `prose-pass.md` + `<latest-draft>` and writes the
next draft version; `prose_pass` output carries an annotation grammar; the metaphor stage
consumes the prose-applied draft.

- [x] M5.1 Add `FIX` / `FIX: <instruction>` / `SKIP` / `ESCALATE` per-entry annotation
  grammar to `prose-pass.md`, keyed off the existing KEEP/TIGHTEN/FLATTEN/REWRITE labels;
  `KEEP` needs no annotation and is treated as `SKIP`. No bulk headers (Sprint 10 locked
  decision — `prose_pass` is deliberately selective at 5-10 findings, so bulk-annotation
  surface would go unused).
- [x] M5.2 Record the apply strategy in `agents/steps/prose-fix.md`: surgical per-entry
  (Sprint 10 locked decision). Locate quote → apply local edit → copy rest verbatim,
  matching `compliance_fix` / `anti_ai_fix` / `metaphor_apply`. Bare `FIX` on `REWRITE` is
  generative — the fixer produces a new sentence/paragraph in-voice using `voice.md` as
  system message and the target paragraph plus one paragraph either side as read-only
  context. Chunked-like-`line_pass` was considered and rejected: `prose_pass` is
  deliberately selective, so a whole-chapter chunk pass would reprocess mostly untouched
  prose.
- [x] M5.3 Write `agents/steps/prose-fix.md` (inputs: annotated `prose-pass.md`,
  `<latest-draft>`, `voice.md`; outputs: `<next-draft>` + appended `prose-pass.md` apply
  log + appended `draft-manifest.md` entry). `review_required: false`. Follows the
  report→fix adjacency invariant via the `Reviewed-draft:` stamp `prose_pass` already
  writes.
- [x] M5.4 Insert `prose_fix` after `prose_pass` in the canonical step list
  (`templates/pipeline-state.md` and `examples/smoke/pipeline-state.md`); the pipeline
  check (`scripts/check-pipeline-state.sh`) must pass.

Notes: with M4 done, the metaphor steps already read `<latest-draft>`, so no input
rewiring is needed. Sprint 10 retires the "Manual prose-edit handoff" procedure in
`agents/chapters.md` and the "advisory only until M5" language in `prose-pass.md` /
`AGENTS.md`; `prose_pass → prose_fix` joins the report→fix invariant list in
`agents/orchestrator.md`. Storyboards and canon are deliberately *not* read by `prose_fix`
(matches `metaphor_apply` / `anti_ai_fix`) — `prose_pass` already reviewed the prose
against the storyboard and voice, and `prose_fix` applies the reviewed judgments without
re-evaluating them.

---

### M6 — Storyboard reader-reveal coverage

Storyboards declare what the reader must understand, not only what is concealed; an
advisory review pass flags under-communication. Order-independent of M4/M5.

Done when: the schema has a reader-takeaway field; `storyboarding` populates it;
`storyboard_review` flags beats whose takeaway is unsupported or whose reveals lack prior
setup; it sits between storyboarding and drafting.

- [x] M6.1 Add a reader-takeaway field to `storyboard-schema.md` (distinct from
  `concealment_from_reader` and `must_preserve`), held to the spec-not-prose discipline.
- [x] M6.2 Update `storyboarding.md` to populate it; make an empty field a default-to-fill
  anti-pattern.
- [x] M6.3 Write `agents/steps/storyboard-review.md` (advisory, report-only): check each
  beat's takeaway is carried and that dependent beats have prior setup.
- [x] M6.4 Insert `storyboard_review` between `storyboarding` and `drafting` in the
  canonical list.

Notes: a `storyboard_review_fix` apply step and the cross-chapter reveals ledger are
deferred. Sprint 11 plans M6 (see SPRINT.md). Locked there: the new field is
`reader_takeaway`, a default-to-fill markdown section (not frontmatter) that states what
the *reader* must understand by a beat's end — distinct from `concealment_from_reader` (its
inverse) and `knowledge_delta` (character knowledge). `storyboard_review` is advisory-only —
a report with no annotation grammar and no paired fix step (the deferred `storyboard_review_fix`
would add the grammar later, mirroring how `prose_pass`'s grammar landed with `prose_fix`); it
runs before drafting so it carries no `Reviewed-draft:` stamp and sits outside the report→fix
invariant. It runs three checks: takeaway-supported, reveal-has-prior-setup (within-chapter
only), and a takeaway/concealment contradiction guard. Reveal dependencies are inferred from
`beat_type`/`reader_takeaway`/`concealment_from_reader` plus `scene-list.md` ordering — no new
dependency field is added.

---

### M7 — Selective step execution

Replace the linear `next-step` cursor model with explicit, selective step invocation.
The default pipeline remains a recommended recipe, but correctness is governed by
artifact preconditions, not by strict sequence position.

Done when: a human can invoke a specific step by `step_id`; the dispatcher validates
that the step's declared inputs exist and are usable; locally ordered pairs such as
`compliance_report -> compliance_fix` are enforced by artifact freshness rules rather
than by global pipeline position; `pipeline-state.md` no longer requires a single
`[>]` cursor to define what may run next; both hosts expose the same model.

- [x] M7.1 Design note: define the selective execution model. Terms to settle:
  `runnable`, `blocked`, `stale`, `superseded`, `active`, `recommended next`,
  and `explicit override`.

- [x] M7.2 Reframe `pipeline-state.md` from cursor state into recipe/status state.
  Remove the requirement that exactly one `[>]` marker controls execution. Preserve
  the default step order as the recommended happy path, not as the only legal path.

- [x] M7.3 Expand the step workflow contract so each step declares machine-readable
  preconditions in addition to descriptive `inputs` / `outputs`. At minimum, distinguish:
  required files, optional files, prose-draft inputs, side-artifact inputs, and
  human-review-sensitive inputs.

- [x] M7.4 Implement explicit step invocation in the dispatcher:
  `run_step <step_id>` or host-equivalent. The dispatcher resolves the requested
  workflow file, checks preconditions, then follows that step body in the same session.

- [x] M7.5 Keep a convenience command for the recommended path:
  `next_recommended_step` or host-equivalent. This reads the recipe/status file and
  chooses the next incomplete recommended step, but it is layered on top of selective
  execution rather than being the core control model.

- [x] M7.6 Generalize local ordering constraints. Report/fix and identify/apply pairs
  must be enforced by artifact stamps such as `Reviewed-draft:`, not by global adjacency
  in the step list. A fix/apply step may run only when its paired report artifact was
  produced against the current usable draft, unless the human explicitly overrides.

- [x] M7.7 Update `orchestrator.md` to remove forward/back/redo language. The
  orchestrator should describe Amanuensis as running selected transformations against
  explicit artifacts, with judgment living in the human and the step bodies.

- [x] M7.8 Host parity: expose the same selective invocation model in Claude Code and
  OpenCode. The names do not have to be identical, but the behavior and safety checks
  must match.

- [x] M7.9 Smoke coverage: verify that the default recipe still runs in order; verify
  that a human can rerun a completed report step; verify that a fix step blocks on a
  stale report; verify that a non-dependent step can run out of recipe order when its
  inputs are valid.

Notes: This milestone deliberately does not change draft version lineage. For now,
`<latest-draft>` may remain the highest-numbered `draft-vNN.md` as defined by M4.
Non-destructive reruns, active draft heads, and superseded draft branches are deferred
to M8. The purpose of M7 is to decouple dispatcher control from strict linear cursor
movement without rewriting the draft manifest model in the same sprint.

Sprint 12 plans M7 (see SPRINT.md). Locked there: the state grammar becomes `[x]`/`[ ]`
only, with `[>]` retired but tolerated as a legacy synonym of `[ ]` (no migration, no
`check-pipeline-state.sh` change); recommended next = first non-`[x]` step. The command
surface adds `run-step` on both hosts and keeps `next-step` as a convenience layer over
the same procedure. The M7.1 design note lands inside `agents/orchestrator.md` as an
Execution model section (single-sourcing; a separate design doc was rejected).
Preconditions are an additive frontmatter block (`path`/`kind: source|prose_draft|side_artifact`/
`required`/`review_sensitive`); the dispatcher checks required-file existence only —
freshness and review checks stay in step bodies until M9.6. The adjacency invariant is
renamed the report→fix freshness invariant with mechanics unchanged.

---

### M8 — Active draft lineage

Replace highest-numbered draft resolution with an explicit active draft head in
`draft-manifest.md`, so arbitrary reruns can create new draft versions without deleting
or archiving prior work.

Done when: `<latest-draft>` resolves to the manifest's active head rather than the
highest-numbered `draft-vNN.md`; rerunning a prose-advancing step can read an earlier
draft and produce a new active draft; superseded downstream drafts remain on disk but
are no longer considered active; stale side artifacts can identify which draft lineage
they belong to.

- [x] M8.1 Design note: define active draft lineage. Terms to settle:
  `active_head`, `reads`, `produced_by`, `supersedes`, `superseded_by`,
  `lineage`, and `abandoned`.

- [x] M8.2 Update `draft-manifest.md` schema so each prose-bearing draft version records:
  producing step, input draft(s), side artifacts consumed, timestamp, review gate if any,
  and whether it is the active head.

- [x] M8.3 Change `<latest-draft>` resolution from highest-numbered draft to active
  manifest head. Keep draft filenames monotonic: reruns create the next `draft-vNN.md`
  rather than overwriting or reusing old numbers.

- [x] M8.4 Define non-destructive rerun semantics. If a human reruns a prose-advancing
  step from an earlier draft, the new output becomes the active head and any previously
  active downstream drafts are marked superseded in the manifest, not deleted.

- [x] M8.5 Update all prose-advancing steps to append manifest entries that preserve
  lineage. Steps must not infer active state from filenames alone.

- [x] M8.6 Update all prose-reading/report steps to resolve the active head through the
  manifest before reading `<latest-draft>`.

- [x] M8.7 Smoke coverage: create a linear draft chain, rerun a prose-advancing step from
  an earlier draft, verify the new draft becomes active, verify old downstream drafts
  remain on disk but are superseded, and verify report steps read the new active head.

Notes: This milestone replaces the archive-on-redo idea from the old M7. Amanuensis
does not move backward. It creates a new version from selected inputs and records which
draft lineage is now active.

Sprint 13 plans M8 (see SPRINT.md). Locked there: the active head is a top-of-manifest
`Active-head: draft-vNN.md` pointer (parallel to the `Reviewed-draft:` stamp), and
`<latest-draft>` resolves to it — falling back to the highest-numbered draft when no
pointer exists, so existing projects need no migration. `<latest-draft>` (the read
pointer) and `<next-draft>` (highest existing draft number + 1, kept monotonic) decouple.
Branch selection is an owner decision: a read-from argument on `run-step`
(`run-step <step_id> from <draft-vNN>`) that overrides which draft `<latest-draft>`
resolves to for that one invocation; `next-step` never branches. On a branch (read-from ≠
active head) the prose-advancing step writes `<next-draft>`, repoints `Active-head`, and
stamps each displaced active-lineage draft `superseded_by: <next-draft>`; abandonment is
derived from that stamp, not a separate field, and a linear advance supersedes nothing.
The M8.1 design note and the lineage/supersession algorithm land in
`agents/project-layouts.md` (the doc that owns the manifest); `orchestrator.md`'s
Execution-model terms are updated to match and cross-reference it. The report→fix
freshness invariant keeps its filename-comparison mechanics unchanged — with active-head
resolution, a report stamped against an abandoned draft is correctly stale, and stamp
filename plus the manifest's `read_from` chain identifies which lineage a stale artifact
belongs to.

---

### M14 — Temporal character state

Evolve the existing character knowledge, relationship, and timeline system so Amanuensis can determine a character's state at any point in a story, rather than only describing the character's latest known state.

The existing Markdown character folders remain the authoritative home for character-relative state. This milestone must preserve the distinction between stable profile information and evolving story state while adding enough temporal structure to support chapter-, book-, and series-scale review.

Done when: Amanuensis can determine what a character knew, suspected, believed incorrectly, remembered, and was prohibited from knowing at a specified story position; can trace changes back to the scenes that caused them; and does not erase prior state when later events revise it.

* [x] M14.1 Define the temporal character-state model across `knowledge/`, `timeline.md`, and `relationships.md`, including how state changes are ordered and attributed to story positions.
* [x] M14.2 Define durable identity and provenance rules for character-state entries so later review steps can refer to the same fact, belief, relationship, or transition consistently.
* [x] M14.3 Distinguish current character state, historical transitions, and prospective reveal constraints. A later update must not destroy the ability to reconstruct an earlier state.
* [x] M14.4 Update character templates and guidance so the temporal model remains human-readable Markdown and does not introduce a parallel authoritative character-state system.
* [x] M14.5 Update the scene knowledge workflow so accepted prose produces reviewable character-state changes rather than silently rewriting accumulated knowledge.
* [x] M14.6 Define freshness and correction behavior when an accepted draft is superseded or earlier prose changes the basis of downstream character state.
* [x] M14.7 Demonstrate point-in-time reconstruction for a character whose knowledge changes more than once, including suspicion, incorrect belief, correction, and an active reveal constraint.

Notes: Character files describe character-relative truth: what a character knows, believes, suspects, remembers, and feels about others. They are not the authoritative source for objective facts about what actually happened. Existing character folders should be evolved rather than replaced by generic state files.

Sprint 19 plans M14 (see SPRINT.md). Two owner decisions locked at planning: (1) the scene-knowledge-update **step is built and wired this Sprint**, not deferred — a new `scene_knowledge_update` step becomes the pipeline's first (and sole) writer of `knowledge/`, closing the gap where `character_extraction`'s empty `knowledge/book-N.md` scaffolds were never filled (rejected: model-and-templates only, step left deferred); (2) the step is **capture-style but not human-gated** (`review_required: false`) — it writes knowledge directly the way the capture subsystem writes provenance-stamped inventions, because applying a confirmed scene delta is mechanical enough to trust without a human double-check. "Reviewable" therefore means *legible, provenance-stamped, and non-destructive* (an earlier state is always reconstructable), **not** human-gated; it is safe re: reveal timing because the step records what committed prose already established, never a premature reveal. Further conventions locked: the reviewable-change format stays **off** the review-grammar/validator machinery — agent-addressable review of character-state changes is M16, and the objective continuity-update workflow is M15.5, so M14 touches none of the four review families, the validator, or the companion; the canonical story-position reference is folder-style `<book-id>/<chapter-id>/<scene-id>` (book-id omitted for `short_story`), adopting the knowledge-delta's existing form and retiring the deprecated `xx-yy` in `templates/knowledge-book.md`; durable identity is a **visible `id` field**, not an HTML-comment anchor (the entry is a structured unit and M14.4 demands human-readable Markdown); non-destruction is a hard invariant realized by transitions (corrections move superseded state into `## Lost or superseded`, never overwrite), the same append-don't-destroy discipline as draft lineage; freshness is a **derived predicate** over each entry's `committed-in: draft-vNN.md` stamp vs. the active head's lineage, mirroring the `Reviewed-draft:` contract (O(1), never stored/swept), with dispatcher-level detection deferred; the step writes `knowledge/` only (`timeline.md`/`relationships.md` get the model and templates but no automated writer this Sprint), targets `knowledge/story.md` for `short_story`, and runs at the end of the recipe (after `anti_ai_fix`). Shipped in Sprint 19 as planned. Execution found two `deferred scene-knowledge-update` references the plan's enumerated file list did not name — the OpenCode capture-agent mirror (`opencode/agents/capture-agent.md`) and this roadmap's own M3 completed-note — and retired both so the sweep grep returns clean; line-shifted `agents/characters.md` cites in the capture docs were converted to stable section references at the same time.

---

### M15 — Objective continuity state and evidence

Establish a bounded, authoritative representation of objective story continuity that complements the character-state system.

The continuity model must cover facts that exist independently of any character's understanding, including chronology, event staging, location, possession, physical condition, roles, unresolved causal threads, and other persistent facts capable of producing reader-visible contradictions. It must remain traceable to accepted planning or prose artifacts and usable without rereading the full corpus.

Done when: Amanuensis can answer a material objective continuity question at a specified story position, identify the accepted evidence supporting the answer, distinguish objective truth from character belief, and detect when the maintained continuity state is stale or unsupported.

* [x] M15.1 Define the boundary between objective continuity, character-relative state, canon, storyboards, and prose evidence so each class of fact has one clear authority.
* [x] M15.2 Define which continuity facts are load-bearing enough to maintain and which details should remain only in prose.
* [x] M15.3 Define temporal and provenance requirements for objective continuity so earlier story state remains reconstructable and every maintained fact points to supporting evidence.
* [x] M15.4 Define how characters' knowledge and beliefs refer to objective facts and events without duplicating or silently overriding them.
* [x] M15.5 Add a reviewable continuity-update workflow that reconciles accepted chapter prose with prior continuity state and surfaces conflicts rather than silently choosing a version.
* [x] M15.6 Define freshness, invalidation, and rebuilding behavior when an accepted draft, storyboard, canon source, or earlier continuity entry changes.
* [x] M15.7 Demonstrate objective continuity across multiple chapters, including chronology, event staging, possession or role state, and a character who holds an incorrect belief about one of those facts.

Notes: The maintained continuity representation is a bounded aid for reasoning, not a substitute for source prose. Source references must allow later steps to retrieve the original evidence when a summary is insufficient or disputed. The milestone should preserve Amanuensis's filesystem-only, host-agnostic design and human-readable artifacts.

Sprint 20 plans M15 (see SPRINT.md). Two owner decisions locked at planning: (1) the continuity-update **step is built and wired this Sprint** — a new `continuity_update` step becomes the sole writer of a new `continuity/` artifact, modeled on `scene_knowledge_update` (`review_required: false`, sole folder-writer, confirm-against-prose, non-destructive) **plus a conflict-surfacing behavior**; it is **not** a `continuity_report`/`continuity_fix` pair on the review-grammar/validator machinery (rejected: full agent-addressable review family — overlaps M16's charter, too big for one sprint; rejected: definitional-only, defer the step — leaves the artifact with no automated writer, the alternative M14 rejected for `knowledge/`). So "reviewable" (M15.5) means *legible, evidence-stamped, non-destructive, and conflicts surfaced not silently resolved* — a human **can** review them — **not** anchored `- Decision:` review units; agent-addressable/countable continuity review, and the bounded relational continuity *review* that reads prose against this state, are **M16** (the "continuity review step" on the Deferred list). (2) The maintained state lives in a **new top-level `continuity/` folder**, parallel to `canon/`/`characters/`/`locations/`, keyed by fact-class and book (`continuity/story.md` for `short_story`, `continuity/book-N.md` for `book`/`series`) — NOTES.md's greppable, O(facts)-not-O(corpus) sketch (`NOTES.md:61-79`, `:124-126`) — leaving the freeform book-level `continuity.md` reveal-timing risk-notes file (`agents/books.md:59-66`) **untouched and distinct** (rejected: evolve `continuity.md` — conflates human `role: planning` risk-notes with `role: derived_state` and is book-level only; rejected: per-chapter aftermath-style — fragments state so cross-chapter/series continuity must rescan). Further conventions locked: the objective-continuity model **reuses M14's temporal idiom** (`id` `co-NN`, canonical `story-position`, `committed-in`, non-destruction transitions, derived freshness — defined once in `agents/characters.md`, referenced not restated) and adds **one field**, `evidence:` — a retrievable pointer to the accepted artifact supporting the fact, the objective counterpart to knowledge's `basis:`; the **granularity policy** (M15.2) maintains a fact iff it is *relational* and *reader-visible-contradiction-capable* across the seven classes (chronology/time-anchor, event-staging, location, possession, physical-condition, role/assignment, open-thread), single-scene throwaway detail staying in prose; the **belief→truth reference** (M15.4) is the knowledge `truth:` field optionally carrying a **qualified** `continuity/book-N.md#co-NN` reference (qualified because continuity ids are file-scoped, so a bare `co-NN` is ambiguous across per-book files), written **advisorily** by `scene_knowledge_update` — which gains a `required: false` continuity read, falls back to free-text on no confident match, never fabricates a pointer, and stays the sole `knowledge/` writer with no continuity write; the objective fact lives once in `continuity/`, the character file points, never copies or overrides, and the pointer degrades gracefully under both a diegetic supersession (target moves to `## Superseded` keeping its id, naming its successor) and an authorial `revise` (target corrected in place); **conflicts** (prose contradicting a still-current maintained fact, not an intended change) are surfaced non-blockingly to `open-questions.md` naming both sides, the prior entry untouched and the conflicting value unwritten; **freshness** is a derived **prose-axis** predicate (stale over `committed-in` lineage + unsupported over `evidence` resolution), resolved by the entry's **full attempt-qualified evidence path** (`<chapter-folder>/drafts/<attemptNN>/draft-vNN.md`) so it is unambiguous across chapters *and* attempts — a bare `draft-vNN.md` basename would false-fresh on a collision; a change to a **non-prose evidence source (storyboard/canon) or an earlier continuity entry** is handled by rerun-reconcile + surfaced conflicts and M16 review, **not** a stored dependency graph (M15.6 is scoped to the prose axis; proactive/cross-source invalidation deferred); never stored, rebuild = rerun-reconcile, dispatcher-level detection deferred; the step **runs before `scene_knowledge_update`** at end-of-recipe (objective facts first, so `truth:`→`co-NN` references resolve — load-bearing but graceful: the continuity read is `required: false`, so out-of-order/absent continuity falls back to free-text `truth:` and never blocks); the boundary (M15.1) gets a new support doc `agents/continuity.md` (single source), closing the "the M15 boundary" loop in `agents/characters.md:67` and the M14 timeline/relationships templates; capture gains a one-line "never `continuity/`" hard exclusion (routing otherwise unchanged); the **diegetic-vs-authorial** change distinction is stated once in `agents/continuity.md` (diegetic story-change → non-destructive `## Superseded` transition by `continuity_update`; authorial change → in-place correction by `revise`), and `agents/revision.md` is extended to reconcile `continuity/` — editing current-state entries in place, treating `## Superseded` transitions as the record it never touches (the same current-vs-record discipline it already applies to drafts, `agents/revision.md:13`/`:22`), stated generally for non-destructive temporal-state files so it also covers M14's `knowledge/`/`timeline.md`/`relationships.md`, with `evidence:` pointers indexing the sweep; and this Sprint touches none of the four review families, the validator, the review companion, the `/revise` dispatcher adapters (only the `agents/revision.md` contract they point at), the other dispatcher files, or `install.sh`. Two retroactive M14 follow-ups surfaced in PR review are recorded on the Deferred list rather than executed here.

---

### M16 — Bounded relational review

Make continuity, reveal-timing, character-knowledge, recap-fidelity, and other relational reviews operate correctly when the full prose corpus cannot fit in one model context.

Review scope must be determined by the defect being checked. Local prose-quality checks may remain block- or scene-local; chapter-wide checks may read the current chapter; cross-chapter and cross-book checks must use maintained temporal state plus targeted retrieval of relevant source evidence. Merely widening declared inputs or splitting relational checks into scene-blind parallel runs is not sufficient.

Done when: a review of a bounded prose unit can detect contradictions whose evidence lies elsewhere in the chapter, an earlier chapter, or an earlier book; each finding identifies the conflicting evidence and the context consulted; and the process does not require loading the complete series.

* [x] M16.1 Classify existing review responsibilities as local, bounded-window, or relational, and define the minimum valid context strategy for each class.
* [x] M16.2 Audit pipeline steps whose responsibilities include continuity, canon, reveal timing, character knowledge, chronology, recollection, quotation, summary, or recap fidelity.
* [x] M16.3 Remove instructions and evaluation partitioning that make relational defects structurally invisible, including block-isolated or scene-blind review where broader comparison is required.
* [x] M16.4 Define how a review identifies relevant characters, events, facts, constraints, and back-references, then obtains only the maintained state and source evidence needed to evaluate them.
* [x] M16.5 Establish precedence and conflict handling among the current storyboard, maintained character state, objective continuity state, canon, and raw prose. Broader context must supplement local intent without silently overriding it.
* [x] M16.6 Require relational findings to identify both the reviewed prose location and the conflicting or supporting referent, and require reports to declare the material context actually consulted.
* [x] M16.7 Distinguish prose defects from storyboard, state, canon, and missing-context defects so remediation is directed at the authoritative artifact.
* [x] M16.8 Define graceful behavior for project scale and project type: short stories may use whole-work context where practical, books may use whole-chapter context plus prior state, and series must not depend on full-corpus rereads.
* [x] M16.9 Demonstrate the model against representative failures involving cross-scene chronology, character knowledge, reveal timing, recalled event staging, and recap fidelity.

Notes: Findings remain attached to stable per-block review units where the existing review grammar requires it. Their relational nature is represented by cited referents and declared context, not by abandoning the existing review-unit scheme. Parallel execution is acceptable only where it preserves the relationships needed by the check.

Sprint 21 plans M16 (see SPRINT.md). Two owner decisions locked at planning: (1) M16 is realized by **retrofitting the existing `compliance_report` step into the bounded relational review** — it consults the maintained `continuity/` (M15) and `characters/<id>/knowledge/` (M14) state plus targeted retrieval of named source evidence, applies precedence, cites the conflicting/supporting referent, declares the context consulted, and labels defect type — **not** by building a new `continuity_report`/`continuity_fix` review family (rejected: a fifth validator family is the heaviest option, adds a parallel review artifact the M16 Notes above say to avoid, and overlaps M17 timing), and **not** definitional-only (rejected: leaves the relational review defined-but-not-working, the exact gap M14 and M15 were built to let M16 close). Relational findings stay on the **existing per-block review-unit scheme** — the anchor is the reviewed prose location, the referent is cited in the finding text, and a report-level `## Context consulted` section declares what was read — so `agents/review-grammars.yaml` and `scripts/validate-review-artifact.sh` change **additively at most** (verified against the updated `examples/review/reviewer-actions.md` fixture; M16 is permitted to touch them, unlike M15). This realizes the Deferred "continuity review step" *inside* `compliance_report`, not as a separate step. (2) Reveal-timing is carried the **broad** way: **also retrofit `storyboard_review`** to reason across chapters against a new **story-level reveals ledger**, realizing the Deferred "story-level reveals ledger with buildup" item. Further conventions locked: the reveals ledger is a **human-authored, story-level planning artifact** (project-root `reveals.md`, `role: planning`, **no pipeline writer**) — reveals are forward authorial intent and `storyboard_review` is pre-draft, so there is no committed prose to derive from and a derived writer would be near-circular (it would review storyboards against a ledger derived from those same storyboards); it is the structured, greppable evolution of the reveal-timing dimension of the freeform **book-level** `continuity.md` risk-notes (`agents/books.md:59-66`), kept **distinct** from it (book-level freeform risk notes vs. story-level structured ledger), and reuses the M14/M15 idiom (`id` `rv-NN`, canonical `story-position`, buildup as an ordered `setup:` list of setup positions, a `concealed-until:` position) — O(reveals) not O(corpus), so a series `storyboard_review` checks a chapter's reveals against the ledger by targeted lookup, never a full-corpus storyboard rescan. The model single-sources in a new `agents/review-context.md` (the classification — **local / bounded-window / relational** — the minimum-valid-context strategy per class, the referent-identification and targeted-retrieval rule (M16.4), the precedence rule (M16.5), the prose-vs-storyboard-vs-state-vs-canon-vs-missing-context defect taxonomy (M16.7), and the project-scale/type gradation (M16.8)) and a new `agents/reveals.md` (the ledger schema). The **audit (M16.2)** records `anti_ai_report` as **local** ("context-free by design," `agents/steps/anti-ai-report.md:29`) and `metaphor_identify` as **local** (no change), `prose_pass` as **bounded-window** (no change), and `compliance_report` + `storyboard_review`'s reveal-setup check as **relational** (retrofit) — the two whose block-local / within-chapter framing (`agents/steps/compliance-report.md:33`,`:93`,`:115`,`:153`; `agents/steps/storyboard-review.md:78`,`:115`) makes relational defects structurally invisible (`NOTES.md:38-50`). **Precedence (M16.5):** the storyboard block's deliberate intent > the distilled continuity/knowledge state > raw canon/prose — broader context *supplements, never overrides* the block, so reaching into raw source without a tiebreaker cannot manufacture a false positive where a storyboard deliberately diverged (`NOTES.md:82-87`); this review tiebreak sits atop the authoring-authority order (canon > continuity, `agents/continuity.md`) and does not change it. **Findings (M16.6)** are per-block review units citing the conflicting/supporting referent (`continuity/…#co-NN` / `knowledge/…#kn-NN` / `reveals.md#rv-NN` / a canon file + quote) and the report declares `## Context consulted` — the specific state entries / chapters / files actually read — so a bounded check is auditable at series scale. **Defect-type labels (M16.7)** (prose / storyboard / state / canon / missing-context) route remediation: `compliance_fix` directs a non-prose-defect finding to its authoritative artifact (strengthening its existing `ESCALATE` "Suggested upstream target," `agents/steps/compliance-fix.md:71-80`) rather than editing prose. **Scale gradation (M16.8):** short_story may use whole-work context; book uses whole-chapter + prior maintained state; series uses maintained state + targeted retrieval and never a full-corpus reread — the new inputs are `required: false` and project-type-aware (prior-chapter material and `continuity/`/`reveals.md` exist meaningfully only for book/series; a short_story must not block on their absence, `NOTES.md:103-107`). **No new pipeline step and no recipe change** — both retrofit targets are already in the recipe, so `templates/pipeline-state.md` / `examples/smoke/pipeline-state.md` and both `check-pipeline-state.sh` modes are untouched; the sprint adds two support docs (`agents/review-context.md`, `agents/reveals.md`) and one template (`templates/reveals.md`) to the `AGENTS.md` catalogs. Realized here: the Deferred "story-level reveals ledger with buildup" (built), "continuity review step" (realized inside `compliance_report`), and the "M14 knowledge-freshness per source chapter and attempt" repair (folded in — M16 is the first step to make `knowledge/` authoritative input for cross-chapter findings, so `scene_knowledge_update` is made to **stamp** the full attempt-qualified draft path (not a bare basename) and the freshness predicate + M14 templates resolve against it, mirroring M15's `continuity_update` `evidence:` write; the predicate is additionally **latest-attempt-qualified** (an entry stamped in a superseded, non-latest attempt is stale even though it still resolves against that attempt's own frozen manifest — the same one-line precision applied to `agents/continuity.md`'s predicate wording, `continuity_update` behavior unchanged); a `knowledge/` entry whose currency is still ambiguous — e.g. a legacy entry — is treated as **missing-context**, never silently trusted — Codex PR-54 review). The reveal-setup check gains a **premature-disclosure guard**: a `concealed-until:` is an active constraint applied to **every** reviewed block in its range (positions **block/beat-qualified** — `<…scene-id>:block-NNN` — so the guard can order blocks within a scene), not only reveal-tagged blocks, so an ordinary beat that leaks a ledger secret early is caught. The defect taxonomy's **state** type spans all three maintained-state artifacts (`continuity/` / `knowledge/` / `reveals.md`), and `compliance_fix` routes on the defect label for **every** decision (`FIX` included, not only `ESCALATE`), so a mislabeled `FIX` can't edit prose for a non-prose defect (Codex PR-54 review). Left deferred: a *derived* reveals-ledger writer, cross-book `truth:` resolution (M16's read path is its consumer, but the knowledge-step write stays deferred), and `storyboard_review_fix`.

---

## M9 — Stale artifacts and review gates

Make arbitrary step execution safe by tracking whether side artifacts are fresh,
stale, reviewed, pending review, superseded, or explicitly overridden.

Done when: side artifacts generated from prose identify the draft they reviewed;
fix/apply steps refuse stale artifacts by default; review-required artifacts carry
an explicit review status or equivalent human-acknowledgment marker; the dispatcher
and step bodies consistently block, warn, or proceed according to declared rules.

* [x] M9.1 Design note: define side-artifact state. Terms to settle:
  `fresh`, `stale`, `review_pending`, `reviewed`, `override`, `discarded`,
  and `regenerated`.

* [x] M9.2 Standardize freshness stamps for prose-derived side artifacts. Existing
  `Reviewed-draft:` behavior becomes the common pattern for reports, annotations,
  metaphor findings, anti-AI findings, and similar artifacts.

* [x] M9.3 Standardize review markers for artifacts produced by `review_required: true`
  steps. Decide whether review state lives in the artifact itself, in a manifest, or
  in the recipe/status file.

* [x] M9.4 Update fix/apply steps to check both freshness and review state before
  consuming side artifacts. On mismatch, append a clear blocker to `open-questions.md`
  and exit without modifying prose.

* [x] M9.5 Define explicit override behavior. Overrides must be human-visible,
  source-specific, and recorded in the relevant artifact or manifest. No stale apply
  should happen silently.

* [x] M9.6 Update the dispatcher to surface stale/review blockers before loading the
  requested step body when the precondition is machine-checkable. **Resolved as a
  deliberate non-goal (triage, 2026-08):** enforcement stays in the step bodies and the
  dispatcher stays thin by design (`agents/orchestrator.md:192`). The step bodies already
  block on stale / review-pending inputs correctly and completely (`compliance-fix.md:126`;
  the report→fix freshness invariant), so M9's enforcement goal is met; the dispatcher lift
  would only surface the blocker earlier and would duplicate freshness logic into a second
  place, against the thin-dispatcher principle. Declined, not deferred — so M9 is complete.
  (If the dispatcher is ever grown past mechanical, this belongs with M16's deferred
  scope/precedence lift as one "dispatcher enforcement" milestone, not on its own.)

* [x] M9.7 Smoke coverage: verify stale report detection, reviewed-artifact detection,
  pending-review blocking or warning behavior, regeneration of a stale report against
  the active draft, and explicit override recording.

Notes: M9 generalizes the report→fix adjacency invariant into an artifact-freshness
model. The old adjacency rule remains valid as a special case, but the framework no
longer depends on global step order to protect fix/apply steps.

Sprint 14 plans M9 (see SPRINT.md). Locked there: staleness is a **derived predicate**
(`Reviewed-draft:` stamp = manifest `Active-head:` → fresh, else stale), computed by the
consuming step at step start and never stored or swept — no update walks every artifact
(the owner decision; it applies M8's derived-`abandoned` precedent to the whole model).
Review is **surfaced, not enforced**: `review_sensitive`/`review_gate` remain the
declaration, annotation is the review evidence for the four reports, consumption emits a
non-blocking notice, and the only hard review block is the pre-existing unannotated-report
path. The design note lands in `agents/orchestrator.md` (which owns the freshness invariant
and execution-model vocabulary), generalizing the report→fix invariant into a single
**Artifact state** section that keeps the invariant verbatim as its named special case and
adds the terms `fresh`/`review_pending`/`reviewed`/`override`/`discarded`/`regenerated`.
No new frontmatter or manifest field: override is recorded in the consuming step's apply
log; `discarded`/`regenerated` name behavior that already ships. The one new step-body
behavior is an explicit recorded-override branch in the four fix/apply steps. M9.6
(dispatcher lift) is deferred so the model proves out in step bodies first; Sprint 14
delivers M9.1–M9.5 and M9.7. **Triage (2026-08): M9.6 is resolved as a deliberate
non-goal** — the step-body state model proved out across M9–M16, and the lift was
declined to keep the dispatcher thin, so M9 is complete (see the M9.6 line above).

---

## M10 — Agent-addressable review: shared contract + compliance slice

### Goal

First of four milestones (M10–M13) delivering **agent-addressable human review**: the four human-gated review artifact families are retargeted from human-only markdown to structured markdown an agent can address, count, and validate, and an agent-assisted **review companion** makes working through them fast, auditable, resumable, and visibly finite.

The companion is **not** a checker, fixer, or decider. It is the human-decision capture layer and progress ledger over structured review artifacts. Most review decisions are irreducibly human; the problem is that the work is not ergonomic or visibly finite. The value is not that the agent decides more — it is that the human decides faster, safer, and with visible progress toward done:

```text
identify/report → human decision capture + progress ledger → fix/apply
```

M10 lands the shared contract — grammar file, validator script, fixtures, companion skill — and migrates the crispest artifact family (compliance) end-to-end. M11 (anti-AI), M12 (prose pass), and M13 (metaphors) migrate the remaining families against that proven contract, one milestone per sprint. Each slice is a big-bang migration for its family: once a family is migrated, its old human-only annotation format is an invalid input and no compatibility path is kept.

Done when: `agents/review-grammars.yaml`, `scripts/validate-review-artifact.sh`, and `agents/review-validation.md` exist as the single-source contract covering all four families; the compliance family round-trips — `compliance_report` emits structured review items, the human (companion-assisted) records decisions into explicit fields by `review-id`, and `compliance_fix` consumes those decisions via the shared validator; progress counts are accurate; and a human can stop mid-review and later resume from accurate remaining counts.

### Shared design (governs M10–M13)

1. **Human decisions remain human.** The companion may recommend actions, explain tradeoffs, and batch presentation. It must not silently make editorial decisions except where the artifact grammar explicitly permits mechanical bulk handling.
2. **The report/identify step surfaces findings; the companion captures decisions; the fix/apply step changes prose.** The companion never becomes the checker or the fixer.
3. **A field is a promise; a position is only a hope.** Every review item carries an embedded HTML-comment anchor (`<!-- review-id: ... -->`) plus explicit `- Decision:` / `- Decision-note:` fields. No positional annotation conventions ("insert below the flag line"). *(Extended in Sprint 16 planning: M13 adds a second evidence field, `Selected:`, for the metaphor family's variant-selection round — the same field-not-position rule applied to the family's second human-decision round.)*
4. **Progress must be countable.** Blank decision fields mean pending; filled decision fields mean adjudicated. Accepted and unreviewed items must never look identical at the review-unit level.
5. **Category-level decisions are capture behavior, not artifact grammar.** *(Revised in Sprint 16 planning; formerly header bulk, anti-AI only.)* Where the grammar declares a category fan-out-eligible, the human may state one decision for the whole category and the companion writes it into every pending unit's `Decision:` field, each marked with an audit note. The artifact carries no bulk grammar: blank means pending in every family with no exceptions, and a `BULK:` header is invalid input.
6. **Grammars are artifact-specific and single-sourced** in `agents/review-grammars.yaml`. The parser, validator, companion, and fix/apply steps consume the same contract; step docs reference it rather than restating token sets in prose.
7. **Fan-out eligibility is static and single-sourced in the grammar file.** *(Revised in Sprint 16 planning; formerly a static-grammar/dynamic-report-declaration split.)* The per-report `BULK eligibility:` declaration was retired with the header grammar: the report emitted the same fixed list every run, restating static knowledge the grammar file owns. No family currently defines per-report review permissions.
8. **Structured markdown remains the primary artifact** — readable, hand-editable, Git-diff-friendly. No JSON sidecars as source of truth.
9. **IDs are stable within a reviewed-draft epoch, not across regenerations.** A `review-id` only needs to be stable for the report generated against its `Reviewed-draft:` stamp; regeneration discards prior findings (existing contract) and may regenerate IDs.

Target grammar per artifact — the full machine-readable definition lives in `agents/review-grammars.yaml` once M10.1 lands; this table is the summary:

| Artifact              | Producer            | Consumer                         | Review Unit                                                          | Legal Decisions                                                                                                                          | Blank Means                                         | Bulk Legal?                                                                                     | Notes                                                                                                                                        |
| --------------------- | ------------------- | -------------------------------- | -------------------------------------------------------------------- | ---------------------------------------------------------------------------------------------------------------------------------------- | --------------------------------------------------- | ----------------------------------------------------------------------------------------------- | -------------------------------------------------------------------------------------------------------------------------------------------- |
| `reviewer-actions.md` | `compliance_report` | `compliance_fix`                 | Per violation                                                        | `FIX`, `FIX: <instruction>`, `SKIP`, `ESCALATE`                                                                                          | Pending / review evidence missing                   | No generic bulk                                                                                 | Crispest grammar; migrated first (M10). `CLEAN` blocks require no action and are not review units.                                           |
| `prose-pass.md`       | `prose_pass`        | `prose_fix`                      | Per finding (`KEEP` included)                                        | `FIX`, `FIX: <instruction>`, `SKIP`, `ESCALATE`                                                                                          | Pending — every finding is a unit                   | No                                                                                              | Every finding, `KEEP` included, is an anchored review unit the human decides (a `KEEP` finding's typical decision is `SKIP`). `Action:` (`KEEP/TIGHTEN/FLATTEN/REWRITE`) is the producer's severity recommendation, distinct from the human's `Decision:`. Migrated in M12. |
| `anti-ai.md`          | `anti_ai_report`    | `anti_ai_fix`                    | Per flagged instance                                                  | `FIX`, `FIX: <instruction>`, `SKIP`, `ESCALATE`                                                                                          | Pending                                             | No — category fan-out is companion capture, not artifact grammar (revised Sprint 16)            | Fan-out-eligible categories and recommended defaults are declared in the grammar file; a `BULK:` header is invalid input. Migrated in M11.   |
| `metaphors.md`        | `metaphor_identify` | `metaphor_fix`, `metaphor_apply` | Per metaphor entry                                                   | `KEEP`, `REJECT`, `FLATTEN`, `REPLACE: <image>`, `WORKSHOP`                                                                              | Pending                                             | No                                                                                              | Replaces delete-as-rejection with `Decision: REJECT` so the file remains an audit record and progress is countable. Migrated in M13.         |

Freshness, review, and override stay governed by `agents/orchestrator.md`'s Artifact-state contract; M10–M13 change none of its mechanics. For a migrated family, the structured decision fields *are* the review evidence: a blank `Decision:` is `review_pending`, and override remains stale-axis-only and anchor-gated.

### Tasks

- [x] M10.1 `agents/review-grammars.yaml`: machine-readable grammar definitions for all four families — per artifact: producer/consumer steps, artifact path pattern, review item shape, anchor pattern, legal decision tokens, payload requirements, blank-means semantics, bulk rules (static support + dynamic declaration requirement + header grammar), progress-counting rules, what constitutes review evidence, and what state lets the consumer proceed — with a per-family adoption marker (compliance `adopted` in M10; the other three defined here but `pending` until their milestone). Locks the bare-`REPLACE` policy: `REPLACE` requires a non-empty image payload; bare `REPLACE` is invalid and `WORKSHOP` is the ask-for-candidates path.
- [x] M10.2 `scripts/validate-review-artifact.sh` + `agents/review-validation.md`: a read-only validator script (parse review units; validate state, structure, and grammar with token lists read from `review-grammars.yaml`, never hardcoded; print the progress ledger — total / pending / decided / inherited-by-bulk / skipped / escalated / invalid / stale; exit with a distinct proceed / pending / invalid / stale code) plus the thin interpretation contract the companion and fix/apply steps of migrated families follow — when to run the script, how to act on its output, and what remains agentic judgment.
- [x] M10.3 Fixture examples of all four target formats under `examples/review/`, exercising each grammar's distinctive cases (compliance CLEAN vs violation; anti-AI bulk and non-bulk categories; prose-pass KEEP handling; metaphor decision tokens).
- [x] M10.4 Retarget `compliance_report` to emit structured review items: a `review-id` anchor plus `Decision:` / `Decision-note:` fields per violation; `CLEAN` blocks are not review units and carry no anchor or fields.
- [x] M10.5 Retarget `compliance_fix` to consume explicit `Decision:` fields via the shared validator (blank decision = `review_pending`; positional annotations are no longer valid input; stale/override behavior unchanged).
- [x] M10.6 `amanuensis-review` Claude Code skill, installed by `install.sh` into consuming projects: identify artifact, load grammar, validate, show progress counts, present pending units as a queue, explain legal decisions, capture and write decisions by `review-id`, support pacing controls. Compliance support in this milestone.
- [x] M10.7 Smoke coverage: compliance round-trip (structured report → decisions → fix consumes), blank-decision `review_pending` block, progress counts, resume mid-review; existing compliance-format recipes updated to the structured format.

Notes: Sprint 15 plans M10 (see SPRINT.md). Locked there: the validator is a **deterministic script** (`scripts/validate-review-artifact.sh`) with a thin agentic interpretation contract (`agents/review-validation.md`) — an agentic prose procedure was chosen first and flipped after discussion (owner decision: the ledger counts and the proceed/block verdict are the two things that must never be wrong, and LLM counting is the design's weakest point; strictness is a feature since `invalid` is a reported state and the companion writes canonical format; the grammar YAML stays the single source — the script reads its token lists from it; the agentic fallback is on the Deferred list if the script proves too rigid). The companion ships as a **Claude Code skill**, not a host command pair (owner decision: conversational activation wins over host parity; OpenCode parity is on the Deferred list). The roadmap was restructured to one milestone per sprint (owner decision), splitting the former monolithic M10 into M10–M13 and renumbering reverse ingestion to M14. Shipped in Sprint 15 as planned, with one addition found in verification: the validator detects a pre-M10 positional report (violation blocks with no anchors) as structurally invalid via per-family container-pattern keys in `review-grammars.yaml`, so an old-format report can never pass as zero-units/proceed.

---

## M11 — Agent-addressable review: anti-AI slice

Second of the four agent-addressable-review milestones (M10–M13). The shared design
and target grammar table governing all four live in the completed M10 section above;
the machine-readable contract is `agents/review-grammars.yaml`.

Retarget `anti-ai.md` to the structured contract, and simplify it under the review model's shift from human-edits-markdown to **AI-plus-human review** (owner direction, Sprint 16): conventions that existed to make hand-annotating markdown cheap — the per-category `BULK:` header, its per-scene `BULK eligibility:` declaration block, and bulk inheritance — are retired rather than migrated. Category-level review survives as **companion fan-out**: where the grammar declares a category fan-out-eligible, the human states one decision for the category and the companion writes it into every pending unit's `Decision:` field, each marked with an audit note. The artifact itself carries pure per-unit decisions: blank means pending in every family, with no exceptions.

Done when: anti-AI flagged instances carry `review-id` anchors and decision fields; blank `Decision:` means pending with no inheritance exception; a `BULK:` header, the old positional annotation format, and an anchorless pre-M11 report are all invalid inputs to `anti_ai_fix` (never silently empty, never silently tolerated); `anti_ai_fix` consumes structured per-entry decisions via the shared validator; fan-out eligibility and recommended defaults are single-sourced in `agents/review-grammars.yaml`; the companion offers category-level capture only for declared categories and writes only human-stated decisions, fanned per-unit with audit notes.

- [x] M11.1 Retarget `anti_ai_report` output: `review-id` anchor plus blank decision fields per flagged instance; drop the `BULK eligibility:` block and the per-scene `### Summary` tally (the validator's ledger is the authoritative count); a clean scene records a single `No flags.` line; grammar referenced from `agents/review-grammars.yaml`, not restated.
- [x] M11.2 Update `anti_ai_fix` to consume `Decision:` fields via the shared validator (per-unit pending gate; positional annotations and `BULK:` headers are invalid input; category fix rules and stale/override mechanics unchanged).
- [x] M11.3 Flip anti-AI to `adopted` in `review-grammars.yaml` with `container_pattern` settled and artifact bulk support withdrawn (`bulk_supported: no`); add the fan-out declaration (eligible categories plus recommended defaults). The grammar flip itself needed no validator change — verified at planning (a later PR-review follow-up separately extended the validator; see Notes).
- [x] M11.4 Companion support: category queues; fan-out capture per the grammar's declaration (one stated decision written into every pending unit of the category, each with an audit note); payload prompting on categories whose bare `FIX` has no fix rule.
- [x] M11.5 Smoke coverage: fan-out round-trip with a per-entry exception and mixed pending counts, a stray `BULK:` header rejected as invalid; the existing anti-AI-format recipes updated to the structured format.

Notes: Sprint 16 plans M11 (see SPRINT.md). The milestone was reshaped at planning under an owner directive: the review process is now AI-plus-human — the companion captures and writes, the human decides — so conventions that existed to make human hand-editing of markdown cheap are retired when retiring them makes agent review simpler or more reliable. Header bulk was the largest: it was the design's only blank-means-decided exception and its only two-layer validation case, and the `BULK eligibility:` block was fake-dynamic (the report emitted the same fixed list every run, restating static knowledge the grammar file owns). Shared-design principles 5 and 7 in the M10 section were revised accordingly. Locked at planning (owner decisions): the bare-`FIX` fallback on categories with no bare-FIX rule stays fixer-level treat-as-`ESCALATE` — the validator stays category-agnostic, and the companion instead prompts for the needed instruction at capture time (rejected: per-category payload keys in the grammar YAML and validator); the companion writes only what the human states — a category fan-out is one human decision mechanically applied, marked per unit in `Decision-note:` (this supersedes the same session's earlier plan, where the companion would write `BULK:` headers); the progress ledger is unchanged — `inherited-by-bulk` now stays 0, since no adopted family grants artifact-level bulk. Verified at planning with the stock validator against a scratch grammar copy: the fan-out-shaped artifact yields the correct ledger; a pre-M11 positional report — including its `### Summary` heading — fails the plain `container_pattern` check as invalid, so the old format can never pass as zero-units/proceed; and a stray `BULK:` header is rejected through the existing no-bulk-support path. `scripts/validate-review-artifact.sh` therefore shipped byte-for-byte unchanged for the milestone's grammar/adoption work. Post-sprint follow-up (M11 PR review): the validator was then extended to emit a `pending-review-ids:` section when pending units remain, so fix/apply blockers and the review companion name the exact remaining units from a deterministic list rather than re-scanning blank `Decision:` fields by eye — the one deliberate departure from the byte-for-byte-unchanged plan, applying M10's own "don't make the LLM enumerate what the script already knows" rationale to the pending set. Exit codes and all ledger counts are unchanged; the section is additive and appears only when `pending` > 0.

---

## M12 — Agent-addressable review: prose-pass slice

Retarget `prose-pass.md` findings to the structured contract, under the AI-plus-human review directive recorded in Sprint 16 planning (see the M11 Notes): the companion captures and writes, the human decides, and hand-edit-era affordances are retired where that makes agent review simpler or more reliable. Prose-pass declares no `fanout_categories`: the pass is deliberately selective (5–10 findings), so per-entry decisions are the point — the locked M5 no-bulk convention, restated in the post-Sprint-16 vocabulary. The one hand-edit affordance retired here is anchorless `KEEP`: under the directive **every finding — `KEEP` included — becomes an anchored review unit the human decides**, so the reviewer's agreement with a `KEEP` is explicit review evidence rather than a silent accepted-vs-unreviewed gap (shared-design principle 4). This dissolves the all-`KEEP` container problem with the stock validator (see Notes).

Done when: **every finding — `KEEP`, `TIGHTEN`, `FLATTEN`, `REWRITE` — carries a `review-id` anchor and blank `Decision:` / `Decision-note:` fields** (the `Annotation:` line, including its bracketed token-set placeholder that restated the grammar inline, is retired); any finding with a blank `Decision:` blocks `prose_fix` as `review_pending`, per unit; the container shape is settled with `container_pattern: "#### Findings"` so a report with anchored findings validates while an unanchored pre-M12 report is invalid input, and a report with no findings uses a `#### Findings — none` exempt heading; `prose_fix` consumes structured decisions via the shared validator, which ships byte-for-byte unchanged.

- [x] M12.1 Retarget `prose_pass` findings format: anchor plus blank `Decision:` / `Decision-note:` fields on **every** finding (`KEEP` included); the zero-findings marker (`#### Findings — none` heading plus a `No findings.` line) per grammar; the annotation-grammar section (with its bracketed placeholder) moves to a `review-grammars.yaml` reference. The reviewer's `KEEP/TIGHTEN/FLATTEN/REWRITE` rubric is unchanged — only the finding template gains the anchor and fields.
- [x] M12.2 Update `prose_fix` to consume `Decision:` fields via the shared validator (per-unit pending gate; positional annotations are invalid input); delete the effective-annotation resolution, including the `KEEP`→`SKIP` shortcut — every finding now carries an explicit decision; add the `KEEP` severity case (a bare `FIX` on a `KEEP` finding has no fix strategy, so it falls back to `ESCALATE`; `FIX: <instruction>` applies the instruction sentence-locally).
- [x] M12.3 Flip prose-pass to `adopted` in `review-grammars.yaml` with the container shape settled (`container_pattern: "#### Findings"`, `container_exempt_suffix: "— none"`); no `fanout_categories` declared; `item_shape` / `counting` / `blank_means` / `review_id_item` rewritten so every finding is a unit; restate the family's `bulk_rules` in the post-Sprint-16 vocabulary (artifact bulk is retired everywhere; per-entry is this family's point).
- [x] M12.4 Companion support for prose-pass's flat (non-category) finding queue: the skill's generic adopted-family path already covers it (compliance is the precedent); no category queues and no fan-out offers anywhere in this family.
- [x] M12.5 Smoke coverage: non-`KEEP` finding pending/decided flow; an all-`KEEP` report (every finding anchored, decided `SKIP`) validating clean; an unanchored pre-M12 report rejected as invalid.

Notes — planning inputs recorded ahead (Sprint 16 AI-first review), plus decisions locked at Sprint 17 planning:

- **★ The all-`KEEP` container problem is settled by making `KEEP` a review unit (owner decision, Sprint 17 planning).** The problem was that anchorless `KEEP` findings made an all-`KEEP` `#### Findings` section indistinguishable, to a plain container check, from a pre-M12 unanchored report. Rather than exempt the section with a body sentinel plus a validator change, the owner directed that `KEEP` items be annotated like every other finding: with every finding anchored, an all-`KEEP` report has anchored units (valid), a zero-findings report uses the `#### Findings — none` exempt heading (the compliance `— CLEAN` mechanism), and a pre-M12 report's unanchored `#### Findings` fails the stock container check (invalid). Verified at planning with the stock validator and a scratch grammar (prose_pass flipped to `adopted`, the two container keys added): mixed report exit 4, all-`KEEP`-decided exit 0, zero-findings exit 0, pre-M12 exit 3 — no validator change. This supersedes the ROADMAP's original framing, where `KEEP` findings were non-units.
- **Producer analysis survives the directive.** `#### Top priorities` and the `### Chapter-level diagnosis` subsections carry non-derivable producer analysis (failure modes, revision strategy, lines worth preserving) — unlike the retired anti-AI tallies they are not machine-redundant, and they stay. `container_pattern: "#### Findings"` matches only the literal Findings heading, so those sibling headings legitimately hold no anchored units without tripping the container check — unlike anti_ai, where every `### ` is a category, prose_pass's container is one specific heading (ROADMAP M10's "container settlement must accommodate headings that legitimately hold no anchored units").
- **No tally to retire** — prose-pass has no summary-count block; its diagnosis sections are analysis, not counts.
- Sprint 17 plans M12 (see SPRINT.md).

---

## M13 — Agent-addressable review: metaphor slice

Retarget `metaphors.md` to the structured contract, under the AI-plus-human review directive recorded in Sprint 16 planning (see the M11 Notes). This is the deepest slice: the metaphor family has **two human-decision rounds** — disposition (which figures to act on) and variant selection (which rewrite to apply) — and both are hand-edit conventions today. Rejection is deletion; selection is "delete the variants you don't want" with `metaphor_apply` instructed to best-guess ambiguity (`agents/steps/metaphor-fix.md:60`, `agents/steps/metaphor-apply.md:51`). Both rounds become structured, addressable, and countable; deletion stops being a decision signal anywhere in the family; every figurative decision — including rejected variants — stays in the audit record; and no step guesses a human decision.

This slice extends the shared contract itself: the grammar file gains its first two-evidence-layer family (`Decision:` gates `metaphor_fix`; `Selected:` gates `metaphor_apply`), and the validator must parse and ledger the selection layer — unlike M11, which shipped the validator byte-for-byte unchanged, M13 includes contract and validator work. Scoped at Sprint 18 planning (see the locked decisions in the Notes): the validator gains an explicit `--round decision | --round selection` selector so one artifact can gate two consumers, and folds in the heading-item orphan check the M12 PR review surfaced.

Done when: each metaphor entry carries a `review-id` anchor and decision fields with tokens `KEEP` / `REJECT` / `FLATTEN` / `REPLACE: <image>` / `WORKSHOP`, replacing the free-text `Human Assessment:` line and delete-as-rejection; bare `REPLACE` is invalid per the policy locked in M10.1; `metaphor_fix` consumes decisions via the shared validator (`--round decision`), generates variants only for `FLATTEN` / `REPLACE` / `WORKSHOP`, treats an all-`KEEP`/`REJECT` file as a clean no-op rather than a nothing-to-do blocker, and appends its variants with stable variant ids plus a blank `Selected:` / `Selection-note:` pair per actionable entry; `metaphor_apply` consumes the `Selected:` field via the shared validator (`--round selection`) — a blank `Selected:` on an actionable entry is selection-pending and blocks, an ambiguous or malformed selection is invalid and never best-guessed, and an all-`KEEP`/`REJECT` file is valid pass-through; pending entries block downstream at both rounds; the count-only `### Summary` block is retired (the validator's ledger is the count) and the variant sections are demoted to `#### ` so they never read as an item line or container; and the container shape settles as the heading-item orphan check with **no** `container_pattern` (an unanchored `### ` figure is an invalid orphaned item; a no-figures scene records `No figures.`).

- [x] M13.1 Retarget `metaphor_identify` entry format: anchor plus decision fields; drop the `Human Assessment:` line and the count-only `### Summary` block; a clean scene records a single `No figures.` line; grammar referenced from `review-grammars.yaml`, not restated.
- [x] M13.2 Extend the shared contract for two evidence layers: rewrite the metaphor entry in `review-grammars.yaml` (it predates this reshape and models only the disposition round) to define `Decision:` (gates `metaphor_fix`) and `Selected:` (gates `metaphor_apply`) with per-consumer proceed states; validator support for parsing and ledgering the selection layer, with selection-pending reported distinctly from decision-pending; container shape settled; flip metaphors to `adopted`; extend the `examples/review/metaphors.md` fixture (currently round-one only) with variant sections and selection states.
- [x] M13.3 Update `metaphor_fix`: consume `Decision:` tokens via the shared validator (bare `REPLACE` invalid — the treat-as-`WORKSHOP` convenience is removed; `KEEP` / `REJECT` entries stay in the file untouched; all-`KEEP`/`REJECT` is a clean no-op); append variants with ids and a blank `Selected:` field; deletion is no longer a decision signal.
- [x] M13.4 Update `metaphor_apply`: consume `Selected:` variants via the shared validator; blank `Selected:` blocks as selection-pending; ambiguous or missing selections are invalid, never best-guessed (removes the "use your best understanding" instruction); all-`KEEP`/`REJECT` pass-through.
- [x] M13.5 Companion support: disposition and selection queues with progress counts across both rounds; flag-based queue prioritization (e.g. `BROKEN` first); payload capture (`REPLACE` images; a selection with the human's inline edits); no auto-disposition from `CLEAN` / `REVIEW` / `BROKEN` flags.
- [x] M13.6 Smoke coverage: non-destructive rejection, all-`KEEP`/`REJECT` pass-through at both consumers, decision-pending and selection-pending blocks, bare-`REPLACE` rejection, an ambiguous selection rejected as invalid.

Notes — planning inputs recorded ahead (Sprint 16 AI-first review), plus decisions locked at Sprint 18 planning (the starred items are owner decisions from that session). Sprint 18 plans M13 (see SPRINT.md).

- **★ The validator gains an explicit `--round decision | --round selection` selector (owner decision).** One `metaphors.md` gates two consumers with different proceed conditions; the consumer states which layer it gates — `metaphor_fix` passes `--round decision`, `metaphor_apply` passes `--round selection`, default `decision`, so the other three families and every existing invocation are unchanged. Rejected: auto-detecting the round from artifact content (ambiguous on a `metaphor_fix` rerun, which itself writes the blank `Selected:` fields, and on a skipped-`metaphor_fix` artifact); ledgering both layers under one precedence (cannot separate "an actionable entry with no `Selected:` yet" — normal for `metaphor_fix`, a block for `metaphor_apply`).
- **★ The inline-edit carrier is a `Selection-note:` field; `Selected:` holds only the variant id (owner decision).** Settles the "payload on `Selected:` vs. note" fork: `Selected:` stays a machine-clean single variant id (validated structurally), and a human's inline edit to the chosen variant goes in a sibling `Selection-note:` the validator never parses and `metaphor_apply` reads — mirroring the `Decision:` / `Decision-note:` split and giving a symmetric pair (`Decision-note:` for round-one corrections, `Selection-note:` for round-two edits). Rejected: a payload on `Selected:` (mixes a machine id with free text on one line); reusing `Decision-note:` (overloads one field across both rounds).
- **Structured selection replaces delete-and-guess.** Variants get stable ids (the existing per-variant letters `A`/`B`/`C`, workshop `A`–`H`, now named as the ids the human records in `Selected:`); rejected variants stay in the file as the audit record. `metaphor_apply`'s best-guess instruction exists only because deletion is a noisy signal; with a structured field, ambiguity is invalid and blocks. The validator checks `Selected:` **structurally** (blank = pending; one well-formed id = selected; malformed/misplaced = invalid); it does not verify the id resolves to an appended variant (the unit closes at the `#### ` variant heading, so cross-checking would require reopening units) — `metaphor_apply` resolves the id to prose under its existing anchor-gate and blocks/skips, never guesses, if it cannot.
- **Two evidence layers is a contract extension.** The M10 grammar models one review round per artifact (one `Decision:` field is the review evidence; one proceed state per consumer); `metaphor_apply`'s evidence is currently defined outside that model ("a surviving variant per entry"). M13.2 brings it inside via a new machine-read `selection_tokens` key (the `Decision:` tokens that make an entry actionable) plus selection-round ledger rows (`selection-pending`, `selected`) and a `selection-pending-review-ids:` section, printed only in the selection round so every other family's output is unchanged.
- **Inline round-one corrections move to `Decision-note:`** (settled — the "likely" from the pre-recorded note is confirmed). The three fix subagents read the human's identify-field corrections from the entry's `Decision-note:`, not from the undocumented "below the action word" side channel.
- **Container settles as the heading-item orphan check, with no `container_pattern` (settled).** The variant sections `metaphor_fix` appends demote from `### ` to `#### ` so they never read as a figure item line or container; the count-only `### Summary` block is retired. Pre-migration rejection is then per-figure via the orphan-item check (next bullet), and a no-figures scene records `No figures.` (zero `### ` headings, no orphan, valid) — so metaphor needs no `container_pattern`. Rejected: a scene-level `container_pattern: "## Metaphor Report"`, which would flag the legitimate no-figures scene as an empty container unless the scene heading carried a `— none`-style exempt suffix (uglier than the `No figures.` marker the orphan check already permits).
- **Heading-item families need an orphan-anchor check (surfaced in M12 PR review; folded into M13).** For families whose `item_line_pattern` is a heading (`metaphor`'s `^### `, and `prose_pass`'s `^##### ` migrated in M12), the validator's `container_pattern` check catches a *fully* unanchored section (zero anchored units → invalid) and an orphaned `- Decision:` field, but it does **not** flag an item-line heading that carries neither an anchor nor a decision field — so a partially hand-migrated report with a leftover legacy finding (an unanchored heading with an old annotation line and no `Decision:`) can slip through uncounted. Demonstrated at Sprint 18 planning with the stock validator (one anchored `KEEP` figure plus one unanchored legacy `### ` figure → `total 1, proceed, exit 0`, the orphan silently dropped). M13 folds in the fix: inside the `/^#/` rule, a line matching `item_line_pattern` with no anchor immediately above (`anchor_line != NR - 1`) is an orphaned item — auto-scoped to heading-item families because a bullet family's `^- ` never matches a `#` line (`compliance`/`anti_ai` therefore never misfire). Additive; fires on no existing fixture; the three adopted fixtures are re-verified as a regression guard.
- **`CLEAN` / `REVIEW` / `BROKEN` flags stay producer recommendations** — never auto-disposed (locked in M10) — and gain value under AI-first as companion queue-prioritization signal (`BROKEN` first); the companion also never auto-selects a variant.
- **M13 confirms no adopted family uses artifact-level bulk**, which unblocks the deferred strip of the inert bulk machinery and the always-0 `inherited-by-bulk` ledger row — but the strip stays out of Sprint 18 (a separate cleanup; the bulk machinery still doubles as the stray-`BULK:`-header rejection path that must survive it).

---

## Deferred

### Now-actionable

- strip the validator's inert artifact-bulk machinery and the always-0
  `inherited-by-bulk` ledger row — unblocked now that M13 confirmed no adopted family
  defines artifact-level bulk. The machinery still doubles as the stray-`BULK:`-header
  rejection path, which must survive the cleanup. Small; fold into a later slice.
- `compliance_report` consultation of `characters/<id>/timeline.md` / `profile.md` for
  unreviewed-premise detection (surfaced in M18 planning / Codex PR-57 review) —
  `compliance_report` has no input reading either file today, so M18's `[premise: unreviewed]`
  tagging (M18.3) cannot reach the two capture-agent-routed destinations `/revise` can already
  confirm (M18.2). Not a functional bug in M18 as scoped — `timeline.md`/`profile.md` facts
  aren't consulted by any check yet, so there is nothing to falsely over-trust — but closing it
  fully needs `compliance_report` to gain those as new relational inputs, which M18 deliberately
  left out to stay a retrofit of existing resolution rather than a new-input expansion. Revisit
  once there's a concrete relational check that would consult them.

### Parked

- reverse ingestion (existing prose into Amanuensis) — ingest a finished work into
  Amanuensis artifacts (characters, scene-list, storyboards, overview, temporal character
  state, objective continuity state), chunked to fit context. Design-gated: blocked on a
  design note that splits it into smaller milestones (prose chunking + source maps,
  character/entity extraction, scene and storyboard reconstruction, overview synthesis,
  canon reconciliation, temporal-state and continuity reconstruction, reverse-to-forward
  bridge). The temporal-state and bounded-review systems it depends on (M14–M16) are now in
  place, so the tabling reason is largely met; parked pending prioritization.
- storyboard_review_fix apply step — makes `storyboard_review` more than advisory,
  mirroring how `prose_pass` gained `prose_fix` (after M6 proved out). Affirmed at triage as
  a real future increment.
- derived reveals-ledger writer (`reveals_update`) — M16/Sprint 21 shipped the
  human-authored, story-level `reveals.md` ledger and its read path (`storyboard_review`'s
  setup-sufficiency + premature-disclosure checks); a *derived* writer that reconciles the
  ledger from accepted storyboards/prose stays deferred, because a reveal is forward
  authorial intent and `storyboard_review` is pre-draft — a writer feeding a ledger derived
  from the same storyboards it then reviews would be near-circular. Revisit once a
  non-circular basis exists.
- agentic fallback for review-artifact validation — front the strict validator with an
  agent-followed procedure only if it proves too rigid against hand-edited artifacts. The
  Sprint-16 AI-plus-human directive makes this less likely to be needed — the companion
  writes canonical format, so hand-edit noise shrinks on the write path.
- compliance hand-edit-era residue — the blank `Decision-note:` slot emission and the
  `### Summary` block's ledger-redundant `Review units emitted:` line (the clean-block count
  and the pattern-level observation are *not* ledger-derivable and stay). Cosmetic; fold
  into a later slice rather than churning the shipped M10 surface on its own.
- revise coverage of M14 temporal-state files (surfaced in Sprint 20 / M15 PR review) — add
  a demonstration or smoke recipe exercising a `revise` against an M14
  `knowledge/`/`timeline.md` entry (correcting a current entry in place while leaving a
  `## Lost or superseded` transition untouched), proving the discipline `agents/revision.md`
  already states generally holds for the M14 artifacts, not only continuity. A test/demo
  gap, not a functional one.
- pre-writing pipeline (vague idea -> plan) — a front stage before the current pipeline.
  Parked (not elevated to a stated ambition at triage).
- per-attempt comparison tooling — revisit after M7/M8's archive model sees real use; no
  demand signal yet.
- multi-work concurrency — the orchestrator deliberately does not coordinate concurrent work
  across chapters or works (`agents/orchestrator.md:189`); parked with no plan to change it.

### Book/series

Book/series is not a near-term target (triage): only `short_story` is verified end-to-end.
These three are the book/series gap and move together when it is prioritized.

- chapter selection for book/series ("which chapter is current?") — the load-bearing one.
  No step resolves the current chapter for `book`/`series`, so those project types are not
  verified end-to-end (`agents/steps/scene-generation.md:76`,
  `agents/orchestrator.md:146-148`). The orchestrator TODO parks it as "see it in practice
  first"; revisit once more book/series material exists to design against.
- post-chapter update step — partially subsumed: M14/M15 automated `knowledge/` and
  `continuity/` at end-of-recipe, but `aftermath.md`, `timeline.md`, and `relationships.md`
  still have no automated writer. The remainder is chapter-boundary work that overlaps the
  "Chapter-boundary continuity" workflow backlog (`agents/workflows.md:116-121`), so it
  couples to chapter selection.
- cross-book `truth:` reference resolution (surfaced in Sprint 20 / M15 PR review) —
  `scene_knowledge_update` reads only the current project-type `continuity/` file, so in a
  series an incorrect belief about a fact established in an earlier book falls back to
  free-text `truth:` instead of resolving the qualified `continuity/book-N.md#co-NN` pointer.
  Advisory with a correct fallback, so a series-only completeness refinement, not a bug:
  declare prior `continuity/book-*.md` as optional inputs and search them before falling
  back. Couples to M16's cross-book read path.

### Non-goals

- multi-host beyond Claude Code / OpenCode — support for agents other than these two is out
  of scope by owner direction.
