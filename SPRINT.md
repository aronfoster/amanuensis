# Sprint 22 — Milestone 18: Unreviewed generated-state confirmation

This Sprint closes a loop Amanuensis has promised since Rule 1 but never wired up: permitted
invention "is recorded into the appropriate canonical files so it stops being a guess and
becomes reviewable truth" (`agents/update-rules.md:23-27`) — but nothing ever reviews it.
**Five** destinations each write an `unreviewed` marker and stop there: the M3 capture agent
stamps `canon/generated/*` entries `status: invented, unreviewed`, and by the same routing
table stamps character `timeline.md` (fact-type `event`) and `profile.md` (fact-type
`identity`) entries the same way (`agents/capture/capture-agent.md`); M15's `continuity_update`
stamps new `continuity/` entries `- **review:** unreviewed`; M14's `scene_knowledge_update`
stamps new `knowledge/` entries the same way. No step or workflow ever flips one to confirmed.
An entry sits flagged indefinitely until something downstream trips over it — and M16's
retrofitted `compliance_report` can cite a `canon/**`/`continuity/`/`knowledge/` entry it
actually reads as if it were settled truth, producing an overconfident finding instead of a
hedged one. (`compliance_report` has no input reading `timeline.md`/`profile.md` at all today
— those two are in `/revise`'s confirmation scope this Sprint but out of `compliance_report`'s
detection scope; see Background and Out of scope.)

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
correction this class of problem needs — it edits `canon/`, character files, and `continuity/`
current-state entries in place (so all five destinations, `timeline.md`/`profile.md` included,
are already in its reach) and is designed to ask the human directly when something is
ambiguous. What's missing is three small, well-precedented pieces: `compliance_report` flagging
when a finding's premise is itself unconfirmed (where it already resolves a source to check —
see Background for where that is and isn't true); `compliance_fix`'s already-defect-type-aware
escalation routing naming `/revise` as the concrete next action, with the right locator for
each destination; and `/revise` gaining the ability to flip an entry's marker to confirmed,
whether it corrects the value or the human simply confirms it as already right.

## Background — what is and isn't wrong today

Established by inspection during planning, with file:line cites; tasks should not re-derive
this.

- **Rule 1 promises review that no step delivers.** `agents/update-rules.md:23-27`: permitted
  invention "must be *captured, not hidden*: it is recorded into the appropriate canonical
  files so it stops being a guess and becomes reviewable truth." Nothing in the pipeline ever
  performs that review — `canon/generated/*` entries are written once (M3) and never revisited
  by any step.
- **Five destinations share the same marker shape, and none has a confirmation workflow.**
  `canon/generated/attempt02-voyage-log.md` carries file-level `status: invented, unreviewed`
  frontmatter plus a per-entry inline tag, e.g. *"The Cape lies about six weeks astern at this
  dinner. (invented, unreviewed — scene 8, beat 2, attempt02; drafter flagged: storyboard says
  only 'for weeks' — adjust if canon fixes the interval differently.)"* The same capture agent
  routes fact-type `event` to `characters/<id>/timeline.md` and fact-type `identity` to
  `characters/<id>/profile.md`, each entry annotated the same way — "a provenance annotation:
  the source scene + beat + attempt" plus "an `invented, unreviewed` marker" — per the routing
  table and Write discipline section of `agents/capture/capture-agent.md`. `continuity_update`
  stamps each new fact `- **review:** unreviewed` (`agents/steps/continuity-update.md:65`).
  `scene_knowledge_update` stamps each new fact the same way
  (`agents/steps/scene-knowledge-update.md:61`). Every writer's own docs say a human *can*
  audit an unreviewed entry (`agents/steps/continuity-update.md:42`,
  `agents/steps/scene-knowledge-update.md:40`) — none says how that audit gets recorded, or
  what changes when it happens. An entry that is actually correct has no way to ever stop being
  flagged `unreviewed`.
- **`compliance_report`'s M16 relational/canon checks resolve `canon/**`/`continuity/`/
  `knowledge/` referents for citation on some paths, but not `canon_active` itself, and never
  `timeline.md`/`profile.md`.** Check 4 (Relational) resolves `continuity/` and `knowledge/`
  entries "by unambiguous, latest-attempt-qualified provenance" before citing them
  (`agents/steps/compliance-report.md:149`,`:203-207`) — that resolution step already reads the
  field this Sprint needs. Check 4 also has its **own** canon-file path, distinct from Check 3:
  its "Canon consistency" sub-check confirms a checkable world-fact against `canon_active`
  first, "escalating to the *named* `canon/**` file only when `canon_active` is insufficient or
  does not cover it" (`:153`) — the same escalation shape Check 3 has, on a different check. So
  **two** checks can open a named canon file: Check 3's Canon check (`:135-141`) and Check 4's
  Canon-consistency sub-check (`:153`); both must be covered by this Sprint's detection, not
  Check 3 alone. Check 3 (Canon) is otherwise different from Check 4: it reads `canon_active`
  *first*, and the block's `canon_active` field is required by
  `agents/storyboard-schema.md:110-112` to hold an "extracted rule or constraint — not a file
  path, not a summary of a source document," so there is nothing there to check a marker on
  until it escalates. So Check 3's *typical* finding (prose vs. the block's own paraphrased
  rule) has no source to resolve at all; only its escalation path, Check 4's own canon-file
  escalation, and Check 4's `continuity/`/`knowledge/` resolution, ever touch a file this Sprint
  can read a marker from. `compliance_report` also has no input reading `timeline.md` or
  `profile.md` — neither is in its `Inputs` section (`agents/steps/compliance-report.md:43-51`)
  — so those two destinations are unreachable by any check regardless. A finding's violation
  line already carries a `[defect: <type>] [ref: <referent>]` tag when relational (`:106`,
  `:113`); this Sprint adds one more optional tag to that same line where a check actually
  resolved a marker-bearing source — it does not invent a new line shape, and it does not add
  new inputs to reach `timeline.md`/`profile.md` (see Out of scope, and the "Now-actionable"
  Deferred item this surfaced).
- **`canon/generated/*` entries carry no minted, addressable id — unlike `continuity/`/
  `knowledge/`'s `co-NN`/`kn-NN`.** `agents/capture/capture-agent.md:55-76` (Write discipline)
  specifies only a provenance annotation (scene + beat + attempt) and the inline `invented,
  unreviewed` marker for every capture destination — no per-entry `id` field of any kind. A
  `continuity/`/`knowledge/` entry can be routed by its minted id; a `canon/generated/` entry
  cannot, so routing there needs a different locator (see Conventions).
- **`canon/generated/*` files carry the marker at two levels — file frontmatter and per-entry —
  and only the per-entry level is the one that matters for detection or confirmation.**
  `agents/capture/capture-agent.md:62-76` defines a file-level `status: invented, unreviewed`
  frontmatter block, written once when the file is created; its Output contract (`:93-96`)
  separately requires *every* captured entry to carry its own provenance annotation and
  `invented, unreviewed` tag. The real `canon/generated/attempt02-voyage-log.md` fixture that
  motivated this Sprint has both forms and many independently-invented entries under one file
  status. A file-level flip on one entry's confirmation would misrepresent every other entry in
  the file as confirmed; a per-entry-only flip leaves the file-level status permanently
  `unreviewed` even once every entry is confirmed, which no consumer reads anyway. Detection and
  confirmation must operate on the per-entry inline tag only (see Conventions) — the file-level
  `status:` is written once at file creation and is not part of this Sprint's confirmation
  lifecycle at all.
- **`compliance_fix` is forbidden from reading canon files, and the report's own `## Context
  consulted` section only records a file path — so a canon/generated locator must be built at
  report time, inside the violation line itself, or `compliance_fix` cannot construct it.**
  `agents/steps/compliance-fix.md:51` states plainly: "Do not read canon files during this
  step" — confirmed again at `:57`, which says the step "reads no canon or state file to route."
  Its `Escalated:` block is built solely from the violation line's tags. `compliance_report`'s
  `## Context consulted` section (`agents/steps/compliance-report.md:178-186`) records only the
  consulted file's path and a one-line gloss (e.g. `canon/resonance.md (Resonance lag rule)`) —
  never a specific entry's scene/beat/attempt or its text. So the scene/beat/attempt-plus-quote
  locator this Sprint's routing needs for `canon/generated/` (no minted id — see above) has
  nowhere to come from at fix time unless `compliance_report` puts the complete, self-contained
  locator on the violation line itself, at the moment it already has the entry's text in hand
  (see Conventions and Task 2).
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
- **`agents/revision.md` is the canonical contract, but a real `/revise` invocation loads a host
  adapter first — and both adapters currently frame every request as a correction.**
  `agents/revision.md` itself says "a host command (the `/revise` slash command in Claude Code;
  the `revise` agent in OpenCode) whose thin adapters point here." Those adapters —
  `templates/dispatcher/.claude/commands/revise.md` and
  `templates/dispatcher/.opencode/agents/revise.md` — summarize the change description as "what
  is wrong and what should be true instead" and their procedure summary opens "Restate the
  change as old truth → new truth," with no acknowledgment that a confirm-only request (no
  change, just marking an entry reviewed) is a distinct, legal shape. Extending only the
  canonical contract would leave the mechanism real but practically unreachable through the
  actual installed command — see Conventions and Task 2.
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
   five destinations' differing surface forms, and ROADMAP M18.1–M18.5 are checked.
2. `agents/revision.md` supports a confirm-only invocation (no content change, entry marked
   confirmed) alongside its existing correct-and-change flow, covering all five destinations —
   `canon/generated/*`, `characters/<id>/timeline.md`, `characters/<id>/profile.md`,
   `continuity/`, `knowledge/` — and both paths flip the cited entry's provenance marker on
   write, without disturbing the current-state-vs-record distinction already stated there. Both
   installed `/revise` host adapters (`templates/dispatcher/.claude/commands/revise.md`,
   `templates/dispatcher/.opencode/agents/revise.md`) acknowledge the confirm-only shape exists,
   so a real invocation actually reaches it rather than being steered toward the correction
   procedure by the adapter's own framing.
3. `agents/steps/compliance-report.md` Checks 3 and 4 tag a finding distinctly when the check
   actually resolved a named `canon/**` file (Check 3's own escalation path, **or** Check 4's
   Canon-consistency sub-check, which escalates to a named canon file the same way) or a
   `continuity/`/`knowledge/` entry (Check 4) whose **per-entry** marker (not any file-level
   status) is unreviewed — an unconfirmed premise reads differently from a settled-truth
   citation. Bare `canon_active` comparisons (the non-escalated common path, in either check) are
   explicitly not tagged, since `canon_active` holds no resolvable source per
   `agents/storyboard-schema.md:110-112`; `timeline.md`/`profile.md` citations are not tagged
   either, since `compliance_report` has no input reading them. For a `canon/generated/`
   referent (no minted id) resolved by **either** check's canon-file escalation, the violation
   line's `[ref: <referent>]` tag itself carries the complete locator — file path + the entry's
   scene/beat/attempt provenance + a short quote of the entry's own text — captured at the
   moment `compliance_report` already has the entry in hand, since `compliance_fix` cannot read
   canon files to reconstruct it later (`agents/steps/compliance-fix.md:51`).
4. `agents/steps/compliance-fix.md`'s routing treats `[premise: unreviewed]` as an override on
   `FIX` and `ESCALATE` — regardless of defect label or its absence, both are routed upstream,
   never applied to prose, until the underlying entry is confirmed. `SKIP` is untouched: it
   already leaves prose as-is and appends no block (`agents/steps/compliance-fix.md:87`), so a
   tagged unit's `SKIP` stays a fully resolved, terminal human disposition — the override does
   not force it into an unwanted escalation. (Without the `FIX`/`ESCALATE` override, a `FIX` on
   exactly the finding this milestone exists to catch — a Check 3 escalation-path finding with
   no defect tag, or a Check 4 finding the taxonomy labels `prose` because it doesn't yet know
   the canon it checked against is itself unconfirmed — would still silently edit the draft to
   match an unconfirmed guess, the failure M18 is for.) When routing such a unit, the
   `Escalated:` block names `/revise` against the
   specific unreviewed entry rather than the artifact class alone — using each system's actual
   locator: `continuity/`/`knowledge/`'s minted `co-NN`/`kn-NN` id, or `canon/generated/`'s
   self-contained `[ref: <referent>]` locator from item 3 above, copied verbatim into the
   `Escalated:` block without re-deriving it (the step never reads canon files itself).
5. A synthetic fixture demonstrates the full round trip: an unreviewed-premise finding tagged
   distinctly (via a resolved `canon/**` or `continuity/`/`knowledge/` source), `ESCALATE`
   routing naming `/revise` with the correct locator shape for that system, `/revise`'s confirm
   and correct-and-confirm paths flipping the marker — including at least one `timeline.md` or
   `profile.md` example, confirmed directly (not via a compliance finding, since none reaches
   them) to prove `/revise`'s extended scope — **and the closing step this mechanism hands off
   to**: a `compliance_report` re-run against the confirmed state, showing either no finding
   (the confirmed premise matched the prose) or a fresh, untagged finding the human can `FIX`
   normally. The marker flip routes and unblocks the decision; it is not itself the prose fix.
6. Verification passes: `agents/review-grammars.yaml` and `scripts/validate-review-artifact.sh`
   are byte-for-byte unchanged; the four families' fixtures under `examples/review/` are
   byte-for-byte unchanged; no pipeline step is added or removed and `pipeline-state.md` /
   `examples/smoke/pipeline-state.md` are untouched; no change lands outside the six touched
   docs (`agents/update-rules.md`, `agents/revision.md`,
   `agents/steps/compliance-report.md`, `agents/steps/compliance-fix.md`,
   `templates/dispatcher/.claude/commands/revise.md`,
   `templates/dispatcher/.opencode/agents/revise.md`) plus the new fixture and
   `ROADMAP.md`/`SPRINT.md`.
7. `the-course-he-kept`'s actual `canon/generated/attempt02-voyage-log.md` and
   `reviewer-actions.md` are untouched by this Sprint (locked scope decision 3) — confirmed by
   `git diff --stat` against the project repo showing no changes there.

## Conventions adopted by this Sprint

Locked at planning (2026-08-11, prompted by the live companion session); tasks don't
rediscover them.

- **★ Scope is unified across all five unreviewed-marker destinations, not `canon/generated/`
  alone (owner decision; widened from three to five at PR review — see the corrections note
  below).** Rejected: ship `canon/generated/` first and extend to the rest in later sprints,
  mirroring the M10→M11–M13 one-family-per-sprint precedent. The owner chose unified scope
  because these systems already share identical marker shape — a narrow fix would leave the
  same failure mode live on the rest, for no real savings (the lifecycle definition and the
  `/revise` extension are the same shape across all five; only the marker's surface syntax
  differs). Unified scope applies fully to `/revise`'s confirm-or-correct mechanism (Task 2);
  it does **not** mean `compliance_report` gains new checks or inputs to detect all five — that
  stays bounded to what it already resolves (see the Finding-tag convention below and Out of
  scope).
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
  resolved a marker-bearing source — and for `canon/generated/`, paired with a self-contained
  `[ref: <referent>]` tag, since nothing downstream can re-derive one.** Rides the same
  violation line as the existing `[defect: <type>] [ref: <referent>]` tag from M16, appended
  after it, on any finding whose resolved source's **per-entry** marker (never a file-level
  status — see Background) is unreviewed: a Check 4 finding (via its `continuity/`/`knowledge/`
  resolution, or its own Canon-consistency sub-check's canon-file escalation), or a Check 3
  finding that took the Canon check's escalation path. **Two distinct escalation points** open a
  named canon file — Check 3's Canon check and Check 4's Canon-consistency sub-check — and both
  get this treatment identically. Check 4 findings already carry `[ref: <referent>]` per M16,
  naming the `continuity/`/`knowledge/` entry's minted id when that's the resolved source.
  Neither check's canon-file path carries a `[ref:]` tag today, and `canon/generated/` mints no
  id to put in one — so this Sprint adds one: whenever either check's canon escalation resolves
  an unreviewed `canon/generated/` entry, the violation line gets `[ref:
  canon/generated/<file>#<scene-beat-attempt> "<short quote>"]`, self-contained because
  `compliance_fix` cannot read canon files to reconstruct it later
  (`agents/steps/compliance-fix.md:51`) and the report's `## Context consulted` section records
  only the file path, not the entry (`agents/steps/compliance-report.md:178-186`). **Never** on
  a finding decided from bare `canon_active` (in either check) — that field has no resolvable
  source per `agents/storyboard-schema.md:110-112`, so there is nothing to tag; this is a
  deliberate scope boundary, not a gap to close by adding provenance to `canon_active` (rejected
  — see below). Local checks (1–2) never carry it either — they don't cite maintained state or
  named canon files. This is additive text inside the grammar's existing `^- ` item line, so no
  grammar or validator change is needed (see Background).
- **`[premise: unreviewed]` overrides ordinary defect-label routing for `FIX` — surfaced at PR
  review (Codex PR-57), this is the property the milestone actually exists to guarantee.**
  `compliance_fix`'s existing rule sends `FIX` straight to a prose edit whenever the unit's
  defect label is `prose` or absent (`agents/steps/compliance-fix.md:59`) — and that is exactly
  the common shape of a tagged finding: a Check 3 escalation-path finding carries no defect tag
  at all, and a Check 4 finding whose prose contradicts what the taxonomy reads as "settled,
  valid" canon is explicitly labeled `prose` (`agents/steps/compliance-report.md:153`), because
  the taxonomy doesn't independently know that canon is itself unconfirmed. Without an override,
  a human deciding `FIX` on the exact finding this milestone exists to catch would still get a
  silent prose edit encoding the unconfirmed guess as accepted truth. So `[premise: unreviewed]`
  is checked **before** the defect-label rule and, when the decision is `FIX` or `ESCALATE`,
  routes the unit upstream regardless of defect label — the same "never applied to prose"
  treatment a non-prose-defect unit already gets. **`SKIP` is deliberately excluded from the
  override** (surfaced at PR review, Codex PR-57 round 5): `SKIP` already leaves prose untouched
  and appends no block — "the human has accepted the violation"
  (`agents/steps/compliance-fix.md:87`) — a fully resolved, terminal disposition the human
  explicitly chose; forcing it into the upstream-routing branch would override that choice and
  emit an escalation the human never asked for, not fix a safety gap. A `FIX` only reaches prose
  once the underlying entry is confirmed (via `/revise`) and a regenerated report no longer
  carries the tag. Rejected: leave `[premise: unreviewed]` as a passive, informational tag only
  (the original scoping) — it would faithfully warn the human but not stop a `FIX` from silently
  encoding the unconfirmed guess, which defeats the point of tagging it in the first place.
  Rejected: override every decision including `SKIP` (the round-4 fix's first, too-broad
  phrasing) — `SKIP` carries no risk of silently trusting the premise, since it writes nothing.
- **Detection is a read of a field already being resolved, not a new lookup pass — and it stays
  bounded to what's already resolved.** M16 already requires `compliance_report` to resolve each
  cited `continuity/`/`knowledge/` entry and each escalated-to canon file for the citation itself
  (`agents/steps/compliance-report.md:149`,`:203-207`,`:135-141`); this Sprint's detection reads
  that same resolved entry's marker field, immediately available at the point the citation is
  already being formed. No separate scan of `canon/generated/`, `continuity/`, or `knowledge/` is
  added, and — the correction from PR review — no new resolution is added either: `canon_active`
  is not retrofitted to carry provenance (that fights `agents/storyboard-schema.md`'s explicit
  "not a file path" design), and `compliance_report` does not gain `timeline.md`/`profile.md` as
  new inputs this Sprint (tracked as a Deferred follow-on instead — see Out of scope).
- **`canon/generated/` routing uses provenance + a quoted snippet, built once at report time,
  not a minted entry id.** `continuity/`/`knowledge/` entries route by their existing
  `co-NN`/`kn-NN` id. `canon/generated/` entries have no equivalent id
  (`agents/capture/capture-agent.md:55-76` mints none), so `compliance_report` (which already
  has the entry's text in hand at the point it resolves the citation) writes the locator — file
  path + scene/beat/attempt provenance + a short quote — directly into the violation line's
  `[ref: <referent>]` tag (see Finding-tag convention above); `compliance_fix` then copies that
  tag verbatim into its `Escalated:` block rather than re-deriving anything, consistent with it
  never reading canon files (`agents/steps/compliance-fix.md:51`). Precise enough to disambiguate
  within a chronologically-ordered generated-canon file without inventing new write-side
  machinery. Rejected: mint a durable id for every `canon/generated/` entry
  (`agents/capture/capture-agent.md`'s own alternative) — a real option, but it changes the
  capture agent's write shape and entry format, which is a larger, separate change this Sprint's
  "reuse existing mechanism" framing deliberately avoids; revisit if the quote+provenance locator
  proves too ambiguous in practice.
- **Detection and confirmation for `canon/generated/` are per-entry only; the file-level
  frontmatter `status:` is never read or written by this mechanism.** A `canon/generated/` file
  carries a marker at two levels (see Background): file-level frontmatter, written once at file
  creation, and a per-entry inline tag on every captured fact. Checking or flipping the
  file-level status would either falsely mark unconfirmed sibling entries as confirmed (if one
  entry's confirmation flipped it) or leave a fully-confirmed file permanently `unreviewed` at
  the file level (if it only ever flips per-entry) — an ambiguity with no consumer that needs
  resolving, since nothing reads the file-level status once per-entry detection exists. So this
  Sprint scopes both `compliance_report`'s detection (M18.3) and `/revise`'s confirm-or-correct
  flip (M18.2) to the per-entry inline tag exclusively, for `canon/generated/`; the file-level
  `status:` field is untouched and out of scope entirely. Rejected: an aggregate rule (e.g. flip
  the file-level status once every entry is confirmed) — adds a sweep-and-check step no consumer
  needs, for a field nothing reads.
- **Timeline.md/profile.md are in `/revise`'s confirmation scope but not `compliance_report`'s
  detection scope this Sprint — tracked, not silently dropped.** `/revise` already edits
  character files in place (`agents/revision.md:13`), so extending its confirm-or-correct
  mechanism to `timeline.md`/`profile.md` entries costs nothing extra (Task 2). But
  `compliance_report` has no check that reads either file today, so there is no finding for the
  new tag to ride on — closing that fully means giving `compliance_report` new relational inputs,
  which is a bigger change than this Sprint's retrofit-of-existing-resolution scope. Recorded on
  ROADMAP's Deferred list (Now-actionable) rather than folded in here.

---

## Tasks

Wave order: **Task 1** defines the lifecycle and vocabulary — Task 2 depends on it. **Task 2**
extends `/revise` and retrofits the two compliance steps against Task 1's definitions. **Task
3** demonstrates, verifies, and closes out, last. Run in order. Capture the Sprint-start SHA
(`git rev-parse HEAD`) before the first commit; the untouched-surface diff anchors there.

### Task 1 — Define the confirmation lifecycle

- [ ] Todo

**Goal.** State once, authoritatively, how an `unreviewed` entry becomes `confirmed` across all
five destinations (`canon/generated/*`, `characters/<id>/timeline.md`, `characters/<id>/
profile.md`, `continuity/`, `knowledge/`) — the marker vocabulary, the citation/detection rule
`compliance_report` follows (and its explicit boundary), and the confirm-vs-correct distinction
`/revise` follows. Closes **M18.1**.

**Requirements.**

- Extend `agents/update-rules.md` Rule 1 (immediately after the existing `:23-27` "captured,
  not hidden" paragraph) with a short **Confirmation** subsection stating: the marker
  vocabulary locked in Conventions above (`unreviewed` → `confirmed`, surface form per
  destination, including `timeline.md`/`profile.md`'s inline tag shape per
  `agents/capture/capture-agent.md`); that for `canon/generated/*` specifically, detection and
  confirmation act on each entry's own inline tag only — never the file-level frontmatter
  `status:`, which this lifecycle does not read or write, for any entry, confirmed or not; that
  confirmation happens via `/revise` (either path — confirm-only or correct-and-confirm) for all
  five destinations; and that a `compliance_report` finding is tagged `[premise: unreviewed]`
  per the Conventions above **only** when the check actually resolved a marker-bearing
  `canon/**` file or `continuity/`/`knowledge/` entry — stating explicitly that bare
  `canon_active` citations and `timeline.md`/`profile.md` citations are out of that detection's
  reach this Sprint, so a later reader doesn't assume the tag is comprehensive.
- Do not restate the per-system marker mechanics (`canon/generated/*`'s frontmatter status,
  `timeline.md`/`profile.md`'s inline tag, `continuity/`/`knowledge/`'s `- **review:**` field) —
  those stay defined where M3/M14/M15 already define them; this task adds only the confirmation
  half and cross-references the existing write-side definitions.
- Do not edit `agents/revision.md`, either compliance step, or any fixture in this task — those
  are Task 2.

**Done when.** `agents/update-rules.md` states the lifecycle, vocabulary, and citation rule in
one place; nothing downstream needs to re-derive them.

---

### Task 2 — Extend `/revise`; retrofit `compliance_report` and `compliance_fix`

- [ ] Todo

**Goal.** Give `/revise` a confirm-only path and a marker-flipping side effect on both paths,
reachable through both installed host adapters; teach `compliance_report` to tag a finding when
its resolved referent is unreviewed; teach `compliance_fix`'s escalation routing to name
`/revise` against the specific entry. Closes **M18.2**, **M18.3**, **M18.4**.

**Requirements.**

- **Extend `agents/revision.md`:**
  - Add a confirm-only invocation to `## Invocation` (`:7-9`): parsed the same tolerant,
    prose-not-CLI way as the existing change-description invocation — a request that names an
    entry and states it should be confirmed as correct, with no proposed change. Applies to any
    of the five destinations (`canon/generated/*`, `timeline.md`, `profile.md`, `continuity/`,
    `knowledge/`) — all already in `/revise`'s edit scope (`:13`; character files are already
    "always edited in place" there). If the request is ambiguous about whether it's a
    confirmation or a correction, ask (per the existing ambiguity-resolution rule at `:32`).
  - In `## Procedure` step 1 (`:32`), add: on a confirm-only request, restate what is being
    confirmed and proceed once the human confirms, skipping only step 3 (there is no source
    content to fix) but still running step 4 (Sweep, read-only, if useful context) and **step 6
    (Apply)** — step 6 is `/revise`'s sole write operation (`:37`), and for confirm-only its only
    edit is the marker flip itself; skipping step 6 would perform no write at all and could
    report success while leaving the entry unreviewed. Close with step 8's report as usual.
  - Both the correct-and-change flow (existing) and the new confirm-only flow flip the target
    entry's marker to `confirmed` (per Task 1's vocabulary) as part of the same edit (or, for
    confirm-only, as the sole edit) — stated as a new sentence in `## Edit scope` or `##
    Procedure` step 6, wherever it reads most naturally alongside the existing in-place-edit
    language at `:13`,`:24`. Covers each destination's per-entry surface form — `timeline.md`/
    `profile.md`/`canon/generated/`'s inline tag, `continuity/`/`knowledge/`'s `- **review:**`
    field. For `canon/generated/` specifically, flip only the confirmed entry's own inline tag;
    never touch the file-level frontmatter `status:` (per the Conventions above — it is outside
    this Sprint's confirmation lifecycle entirely, for any entry, confirmed or not).
  - Do not touch the transition-structure prohibitions at `:22` — a confirmation is a
    current-state-entry update, never a fabricated `## Superseded` / `## Lost or superseded`
    transition.
  - **Reconcile with `## Consequences the command accepts` (`:43`)** (surfaced at PR review,
    Codex PR-57 round 7): that section states "a revision never touches freshness or review
    state" — meaning the `Reviewed-draft:`/review-gate concept from `agents/orchestrator.md`'s
    Artifact-state contract (an artifact's pending-vs-decided review status), which `/revise`
    still never touches. That is a different thing from the per-entry `unreviewed`/`confirmed`
    marker this Sprint adds — which, for `continuity/`/`knowledge/`, is literally named `-
    **review:**`, an unfortunate naming collision with the sentence that forbids touching
    "review state." Left unreconciled, the completed contract would simultaneously require and
    appear to forbid the same write. Add one clarifying sentence at `:43` distinguishing the two
    — artifact review-gate state (never touched) vs. per-entry generated-state confirmation
    markers (the write this Sprint's confirm-or-correct mechanism performs by design).
- **Update both installed `/revise` host adapters so the confirm-only invocation is actually
  reachable, not just defined in the contract they point at** (surfaced at PR review, Codex
  PR-57 round 6). `templates/dispatcher/.claude/commands/revise.md` and
  `templates/dispatcher/.opencode/agents/revise.md` are what a real `/revise` invocation
  actually loads first; both currently frame every request as a correction — "the change
  description in prose: what is wrong and what should be true instead," and a procedure summary
  opening "Restate the change as old truth → new truth" — with no mention that a confirm-only
  request is a distinct, legal shape. Left as originally scoped (touching only
  `agents/revision.md`), a human confirming a generated-canon entry as correct would hit an
  adapter prompt that expects a replacement value, and might follow the correction procedure
  instead of the marker-only Apply flow M18.2 defines, even though the canonical contract itself
  is correct. Add one sentence to each adapter's request-framing line and procedure-step-1
  summary acknowledging the confirm-only shape and pointing at `agents/revision.md`'s
  `## Invocation` section for it — minimal, since "this prompt is a thin adapter... the contract
  governs" is already each adapter's own stated relationship to `agents/revision.md`, and the
  fix only needs to stop the summary itself from omitting a legal request shape, not restate the
  full contract.
- **Retrofit `agents/steps/compliance-report.md`:**
  - In Check 3 (Canon, `:135-141`), only on its **escalation path** — when `canon_active` is
    insufficient and the check opens a named `canon/**` file — read that file's **per-entry**
    marker for the specific entry the prose is checked against (never the file-level frontmatter
    `status:` — see Background/Conventions). Do **not** add any lookup on the common,
    non-escalated path (bare `canon_active` comparison): per
    `agents/storyboard-schema.md:110-112`, `canon_active` holds an extracted rule, never a file
    path, so there is nothing there to resolve a marker from.
  - In Check 4 (Relational, `:143-157`): (a) when the check resolves a cited `continuity/`/
    `knowledge/` entry per the provenance resolution already required at `:149`, read that
    entry's marker; **and** (b) when the check's own Canon-consistency sub-check (`:153`)
    escalates to a named `canon/**` file — the same "`canon_active` insufficient" trigger as
    Check 3's Canon check, just reached from Check 4 — read that file's per-entry marker too.
    Check 4 therefore has **two** independent canon/continuity/knowledge resolution points that
    both need this treatment, not one.
  - In every case above, if the resolved entry's marker is `unreviewed`, append `[premise:
    unreviewed]` to the violation line, after the existing `[defect: <type>] [ref: <referent>]`
    tag where present (Check 4) or standing alone (Check 3's escalation path, which carries no
    defect tag today).
  - **Whenever either check's canon-file escalation resolves a `canon/generated/` entry**
    (Check 3's Canon check, or Check 4's Canon-consistency sub-check), also append a `[ref:
    <referent>]` tag naming the self-contained locator — `canon/generated/<file>#<scene-beat-
    attempt> "<short quote of the entry's own text>"` — built now, while the entry is in hand,
    because `compliance_fix` cannot read canon files to build this later
    (`agents/steps/compliance-fix.md:51`) and the `## Context consulted` section records only
    the file path, not the entry (`agents/steps/compliance-report.md:178-186`). Check 4's
    resolution of a `continuity/`/`knowledge/` entry already carries `[ref:]` naming its minted
    id per M16 — no change needed there.
  - No change to Checks 1–2 (Must-Contain, Must-Not-Contain) — they don't cite maintained state
    or named canon files. No new inputs are added to read `timeline.md` or `profile.md` — those
    stay outside this task (see Conventions and Out of scope).
  - No change to the `### Summary` or `## Context consulted` sections beyond what already names
    the consulted entries — the tag lives on the violation line only.
- **Retrofit `agents/steps/compliance-fix.md`'s routing (`:57-85`) so `[premise: unreviewed]`
  overrides the ordinary defect-label routing for `FIX`, not just for units already routed
  upstream.** As written today, the defect-label rule (`:59`) sends `FIX` straight to a prose
  edit whenever the label is `prose` **or absent** — and that is exactly the common case for a
  unit carrying `[premise: unreviewed]`: a Check 3 escalation-path finding carries no defect tag
  at all, and a Check 4 finding whose prose contradicts what looks like "settled, valid" canon
  is explicitly labeled `prose` by the taxonomy (`:153` of `compliance-report.md`) — the
  taxonomy's own labeling logic doesn't yet know the canon it just checked against is itself
  unconfirmed. Left as originally scoped, a human who decides `FIX` on exactly the finding this
  milestone exists to catch would still get a silent prose edit that encodes the unconfirmed
  guess as accepted truth — the precise failure mode M18 is for. So: **before** applying the
  defect-label rule, check for `[premise: unreviewed]` on the violation line; if the decision is
  `FIX` or `ESCALATE`, the unit is routed upstream — regardless of the defect label or its
  absence — exactly as a non-prose-defect unit already is. `SKIP` is untouched by this override:
  it already leaves prose as-is and appends no block (`:87`, "the human has accepted the
  violation"), a fully resolved disposition that needs no escalation. Only once the underlying
  entry is confirmed (via `/revise`, which clears the tag on regeneration) can a `FIX` on that
  unit reach a prose edit. When a unit routed upstream this
  way (`ESCALATE`, a non-prose-defect `FIX`, or now a `[premise: unreviewed]`-tagged `FIX`)
  carries the tag, the `Escalated:` block's "Suggested upstream target" names `/revise` against
  the specific entry, reading the locator straight from the violation line's `[ref: <referent>]`
  tag — never re-deriving it, since this step cannot read canon or state files (`:51`): for a
  `continuity/`/`knowledge/` referent, the minted `co-NN`/`kn-NN` id; for a `canon/generated/`
  referent (from either check's canon-file escalation — Check 3's Canon check or Check 4's
  Canon-consistency sub-check), the self-contained file + scene/beat/attempt + quote locator now
  written into the tag by whichever check resolved it (Task 2's `compliance-report.md` bullet
  above) — never claim a "file + entry id" for `canon/generated/`,
  which mints no id.
- **Verify the grammar/validator are untouched:** run
  `sh scripts/validate-review-artifact.sh examples/review/reviewer-actions.md
  agents/review-grammars.yaml` (and the other three fixtures) after the retrofit and confirm
  identical ledgers/exit codes to before this task — the new tags are additive prose inside
  existing violation lines, per the Conventions above.

**Done when.** `/revise` accepts a confirm-only request and flips the target entry's marker on
either path, reachably from both installed host adapters (not just the canonical contract);
`compliance_report` tags a finding whose resolved referent is unreviewed; `compliance_fix`
routes a `[premise: unreviewed]`-tagged unit upstream on `FIX` or `ESCALATE` regardless of
defect label, and names `/revise` against the specific entry when doing so — a `FIX` on such a
unit never reaches a prose edit, and `SKIP` is unaffected, keeping its existing no-write
behavior; all four `examples/review/` fixtures validate identically to before this task.

---

### Task 3 — Demonstration, verification, and close-out

- [ ] Todo

**Goal.** Prove the round trip end-to-end against a synthetic fixture, run the verification
sweep, and close the milestone. Closes **M18.5** and the residual of **M18**.

**Requirements.**

- Add a synthetic fixture (a small hand-authored chapter-folder slice, not a full project —
  mirror the scale of `examples/relational-review/` from Sprint 21) covering the two paths that
  actually get built:
  - A `canon/generated/` file with **at least two entries** (mirroring the real multi-entry
    `attempt02-voyage-log.md`), one stamped `unreviewed` and cited by a Check 3 finding that
    took the Canon check's escalation path (not a bare `canon_active` finding — those never
    tag). Note in the README that Check 4's Canon-consistency sub-check reaches the identical
    marker/locator handling via its own, separate canon-file escalation — the fixture need not
    duplicate both, since the mechanism is check-agnostic once a canon file is opened. Show: the
    violation line's `[premise: unreviewed]` tag and its self-contained `[ref:
    canon/generated/<file>#<scene-beat-attempt> "<quote>"]` tag — with **no** `[defect: …]` tag,
    since Check 3's escalation path carries none; a human `Decision: FIX` on that unit still
    produces an `Escalated:` block, **not** a prose edit — the core safety property this Sprint
    exists to demonstrate, since the unit's absent defect label would otherwise route `FIX`
    straight to prose; the `Escalated:` block copying the locator verbatim (no re-derivation, no
    canon-file read); and — after a `/revise` confirm-only pass on that one entry — that its
    per-entry inline tag flips to confirmed while
    both the file-level frontmatter `status:` and the sibling (still-unreviewed) entry's inline
    tag are visibly unchanged, proving per-entry-only scope. **State explicitly in the README**
    (surfaced at PR review, Codex PR-57 round 7) **that the marker flip is not the end of the
    round trip for a `FIX`-decided unit**: the escalation's job was to route the decision to the
    right place and stop an unconfirmed guess from reaching prose, not to apply the eventual
    prose correction itself. Once the entry is confirmed or corrected, the human re-runs
    `compliance_report` — the existing recipe step, not a new mechanism — which either finds no
    violation (the confirmed premise already matched the prose) or emits a fresh, untagged
    finding the human can `FIX` normally through `compliance_fix`. Show this as the fixture's
    closing step, not just the marker flip.
  - A `continuity/` **or** `knowledge/` entry stamped `- **review:** unreviewed`, cited by a
    Check 4 finding, showing the same tag and an `Escalated:` block routing to `/revise` by its
    minted `co-NN`/`kn-NN` id. Note in the README that `compliance_report`'s detection logic is
    identical in shape across `canon/**` and `continuity/`/`knowledge/`; only the locator differs.
  - A worked `/revise` correct-and-confirm pass against the `continuity/`/`knowledge/` entry
    (distinct from the `canon/generated/` confirm-only pass above), showing both the value
    correction and the marker flip together.
  - A worked `/revise` confirm-only pass against a `timeline.md` **or** `profile.md` entry,
    invoked directly (not via a compliance finding, since `compliance_report` never reaches
    these) — proving `/revise`'s extended scope independent of the detection gap the README
    should name explicitly, cross-referencing the Deferred follow-on.
  Place it under `examples/` with a README, clearly marked as an example per `AGENTS.md:22-26`.
- Run the verification sweep: `git diff --stat` against the captured Sprint-start SHA shows
  changes confined to `agents/update-rules.md`, `agents/revision.md`,
  `agents/steps/compliance-report.md`, `agents/steps/compliance-fix.md`,
  `templates/dispatcher/.claude/commands/revise.md`,
  `templates/dispatcher/.opencode/agents/revise.md`, the new fixture directory, `ROADMAP.md`,
  and `SPRINT.md` — nothing else; `agents/review-grammars.yaml` and
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
the marker → a `compliance_report` re-run showing the loop actually closes, not just the marker
flip); the verification sweep and both `check-pipeline-state.sh` modes pass; ROADMAP
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
- **Giving `compliance_report` new inputs to consult `timeline.md`/`profile.md`.** Both are in
  `/revise`'s confirmation scope (Task 2) but stay outside `compliance_report`'s detection scope
  — it has no check reading either file today, and adding one is a new-input expansion, not a
  retrofit of existing resolution. Recorded on ROADMAP's Deferred list (Now-actionable),
  surfaced at PR review (Codex PR-57) rather than silently left uncovered.
- **Retrofitting `canon_active` to carry structured source provenance.** Rejected as a way to
  let Check 3's common path resolve a marker: `agents/storyboard-schema.md:110-112` explicitly
  requires `canon_active` to hold an extracted rule, "not a file path, not a summary of a source
  document." Changing that is a cross-cutting schema change unrelated to this Sprint's narrow
  aim, not a small fix.
- **Minting a durable entry id for `canon/generated/*` entries.** A real alternative to the
  provenance+quote locator (Conventions), but it changes `agents/capture/capture-agent.md`'s
  write shape — larger and separate from this Sprint's reuse-existing-mechanism scope. Revisit
  if the quote+provenance locator proves too ambiguous in practice.
- **An aggregate or file-level confirmation status for `canon/generated/*` files.** Surfaced at
  PR review (Codex PR-57): a multi-entry generated-canon file carries a marker at both the
  file-frontmatter and per-entry level (Background), and this Sprint deliberately does not try
  to keep them in sync — detection and confirmation are per-entry only, and the file-level
  `status:` is untouched permanently, by any entry's confirmation (Conventions). Rejected:
  derive the file-level status from its entries' state (e.g. "confirmed" once all are
  confirmed) — adds a sweep no consumer needs, for a field nothing reads.
- **OpenCode parity for the `amanuensis-review` companion skill.** That is a separate,
  unrelated feature (compliance-review UX, not `/revise`), tracked under M17. **Narrowed at PR
  review (Codex PR-57 round 7)** from an earlier, broader "OpenCode parity for `/revise` or the
  compliance steps" phrasing that directly contradicted Task 2, which *does* touch
  `templates/dispatcher/.opencode/agents/revise.md` (round 6's fix) to keep `/revise`'s
  confirm-only invocation reachable on both hosts — that adapter edit is in scope and is not
  excluded by this bullet.
- **Dispatcher-level detection of unreviewed entries.** Matches the standing dispatcher-stays-
  thin non-goal already recorded in `agents/orchestrator.md` for staleness and overrides;
  detection here stays in the step bodies (`compliance_report`) exactly as those do.
- **Revise coverage of M14 temporal-state files (the related Deferred item).** That item is a
  demonstration gap for `/revise`'s *existing* current-vs-record discipline against
  `knowledge/`/`timeline.md`/`relationships.md`. This Sprint's Task 3 fixture may incidentally
  touch that ground for the `knowledge/` case, but closing that Deferred item fully is not this
  Sprint's goal and its checkbox is not touched here.
