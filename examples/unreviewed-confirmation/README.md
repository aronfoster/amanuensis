# Unreviewed-confirmation fixture — the *Ashfall Road* crossing

> **ILLUSTRATIVE EXAMPLE — NOT REAL PROJECT CANON OR STATE.**
> Per the Amanuensis Repository Boundary rule (`AGENTS.md:22-26`), prose, maintained
> state, storyboards, and canon live in this tooling repo *only* as clearly-marked
> examples. Senna Vail, Iyo Brakk, Torrin Kess, Dessa Rill, the caravan route (Last
> Well, the Ashfall Road, Drybone Market), the frost-ward mechanic, the verglass cargo,
> and the drafts (`draft-vNN.md`) here are all invented to demonstrate the M18
> unreviewed-generated-state confirmation lifecycle. Nothing in this folder is a real
> character, a real project's state, or anything to reconcile against — do not treat it
> as canon and do not copy it into a story repo as fixtures for a real project. (This
> crew is a **distinct** cast from the *Cormorant*'s in `examples/relational-review/`,
> the *Meridian*'s in `examples/continuity/`, and the untitled crew in
> `examples/review/` — none of these fixtures share a world.)

## What this folder shows

A worked demonstration of the **M18 confirmation lifecycle**: `agents/update-rules.md`'s
Confirmation subsection, `agents/revision.md`'s confirm-only and correct-and-confirm
`/revise` paths, and `agents/steps/compliance-report.md` / `compliance-fix.md`'s
`[premise: unreviewed]` tagging and escalation-override. It is a `short_story`-project
fixture slice (`agents/project-layouts.md`), the scale of `examples/relational-review/`
but the `short_story` layout's simpler paths — one scene, four storyboard blocks, one
draft, no book/chapter subdivision.

Three separate demonstrations, each proving a different piece of the mechanism:

| # | Destination | Detection path | `/revise` mode | Locator form |
| --- | --- | --- | --- | --- |
| 1 | `canon/generated/frost-wards.md` | Check 3's Canon-check escalation | confirm-only | `canon/generated/<file>#<scene-beat-attempt> "<quote>"` (no minted id) |
| 2 | `continuity/story.md` | Check 4's continuity resolution | correct-and-confirm | minted `co-NN` id |
| 3 | `characters/dessa/timeline.md` | none — direct invocation | confirm-only | inline tag, no compliance finding involved |

The maintained/generated state the fixture carries:

- `canon/generated/frost-wards.md` — two agent-invented world facts about the
  caravan's frost-ward, in the `agents/capture/capture-agent.md` Write-discipline
  shape: file-level `status: invented, unreviewed` frontmatter (untouched throughout)
  plus a per-entry inline tag on each of the two entries.
- `continuity/story.md` — one maintained chronology entry, `co-01`, in the
  `templates/continuity-book.md` shape (short_story: no `book_id`, story-position
  reduced to `<scene-id>`).
- `characters/dessa/timeline.md` — one character-timeline entry, `tl-01`, carrying the
  same per-entry inline tag shape as `canon/generated/`.

The prose and plans under review:

- `plot/storyboards/scene01-storyboard.md` — the four storyboard blocks. Block 002's
  `## Canon active` states the frost-ward rule only generically (no specific recast
  interval); block 003's `## Must Preserve` states the day-count constraint generically
  too — both deliberately insufficient, forcing each check to escalate to the named
  maintained-state file rather than resolve locally.
- `plot/drafts/attempt01/draft-v01.md` — the draft under review, carrying two
  deliberate contradictions (blocks 002 and 003) against the maintained/generated state.
- `plot/drafts/attempt01/reviewer-actions.md` — the compliance report, shown already
  carried through `compliance_fix`: two findings, two `Decision: FIX` calls, two
  `Escalated:` blocks. It validates `proceed` (exit 0) — see
  [Validating the report](#validating-the-report).
- `plot/drafts/attempt01/draft-v02.md` — `compliance_fix`'s output. Neither `FIX`
  decision reaches prose (both route upstream), so this is a byte-for-byte copy of
  `draft-v01.md` — but `compliance_fix` still mints it and repoints `Active-head:` to
  it, per its unconditional completion contract (`agents/steps/compliance-fix.md`).
  That leaves `reviewer-actions.md`'s `draft-v01.md` stamp **stale** against the new
  active head — see [Closing the loop](#closing-the-loop-a-regenerated-compliance_report-re-run).

## 1 — `canon/generated/`: Check 3's escalation path, and a confirm-only `/revise` pass

`canon/generated/frost-wards.md` carries two capture-agent-style entries, both
originally `invented, unreviewed`:

- **Entry A — Frost-ward duration** (load-bearing): *"A chalked frost-ward holds a
  sealed crate for three days before it must be recast; past that, the verglass begins
  to sweat and crack."* Tagged `(invented, unreviewed — scene01, beat01, attempt01)` in
  its pre-confirmation state.
- **Entry B — Ward-sigil chalk** (sibling, unrelated): *"The ward-sigil is chalked in
  blue ochre, not the caravan's usual white chalk, because the salt wind eats white
  chalk raw within a day."* Stays `invented, unreviewed` for the whole fixture — its
  job is to prove per-entry-only scope, not to be checked against anything.

Block 002's storyboard `## Canon active` states only *"frost-wards on sealed cargo
degrade over time and must be recast before they fail"* — no specific interval. The
draft's block 002 asserts a specific, checkable recast cadence: *"Every two days, same
as always."* `canon_active` doesn't cover that claim, so Check 3 escalates past it to
the named `canon/generated/frost-wards.md` file — and finds Entry A's three-day figure
instead.

### The finding

```markdown
<!-- review-id: compliance:scene01:block-002-v01 -->
- INCONSISTENT (canon): Frost-ward duration — "every two days, same as always" violates
  rule: "a chalked frost-ward holds a sealed crate for three days before it must be
  recast; past that, the verglass begins to sweat and crack" [premise: unreviewed] [ref:
  canon/generated/frost-wards.md#scene01-beat01-attempt01 "holds a sealed crate for
  three days before it must be recast"]
  - Decision: FIX
```

Note what is **absent**: no `[defect: …]` tag. Check 3's escalation path never carries
one (`agents/steps/compliance-report.md`: "never a `[defect:]` tag, which Check 3 never
carries"). Exactly one `[ref:]` tag, appended fresh at report time — Check 3 carries no
`[ref:]` tag on its ordinary path, so this is a new tag, not an enrichment (that's
Check 4's job, see §2). The `[ref:]` locator is self-contained — file path + the
entry's own scene/beat/attempt provenance + a short quote — because `canon/generated/`
mints no id and `compliance_fix` is forbidden from reading canon files to reconstruct
one later.

### The safety property: `FIX` still routes upstream

A human reviewer decided `Decision: FIX` on this unit — an entirely reasonable call, if
they didn't notice the tag. `compliance_fix` reads `[premise: unreviewed]` **before**
its defect-label rule, and it overrides: `FIX` (or `ESCALATE`) on a tagged unit routes
upstream via an `Escalated:` block, never a prose edit — regardless of the unit's
defect label or its absence. This is the core safety property the milestone exists to
guarantee: without it, this exact `FIX` would have silently baked an unconfirmed guess
("three days") into the accepted prose by rewriting "two days" to match it.

```markdown
#### Escalated: Frost-ward duration (review-id: compliance:scene01:block-002-v01)
- Reason: the violation line carries [premise: unreviewed] — the cited entry
  (canon/generated/frost-wards.md#scene01-beat01-attempt01) is itself unconfirmed, so a
  FIX cannot be applied to prose against an unconfirmed guess, regardless of the unit's
  (absent) defect label.
- Suggested upstream target: /revise against
  canon/generated/frost-wards.md#scene01-beat01-attempt01 — the self-contained locator,
  copied verbatim from the violation line's [ref:] tag.
```

The prose was never touched by a `FIX`: no unit's decision reached the prose-edit path,
so `compliance_fix` had nothing to apply. It still completes normally, though — a
successful run's completion contract is unconditional (`agents/steps/compliance-fix.md`:
"the step's final action is to repoint the manifest's `Active-head:` to the `<next-draft>`
it just wrote") — so it mints `draft-v02.md`, a byte-for-byte copy of `draft-v01.md`
("Everything not touched by a `FIX` decision is copied through verbatim"), and repoints
`Active-head:` to it. Block 002 still reads "every two days" in `draft-v02.md`, unchanged
text under a new version number. See [Closing the loop](#closing-the-loop-a-regenerated-compliance_report-re-run)
for what this means for the next `compliance_report` run.

### The confirm-only `/revise` pass

The human takes the `Escalated:` block's suggestion and runs `/revise` directly against
the named entry:

> **Human:** "Confirm the frost-ward duration entry in the generated canon — three days
> is right, I checked it against the recast log."
>
> **`/revise` (step 1, confirm-only invocation):** restates what is being confirmed:
> "Confirming `canon/generated/frost-wards.md`'s frost-ward duration entry — a chalked
> frost-ward holds a sealed crate for three days before it must be recast — as correct,
> no change." The human confirms.
>
> **`/revise` (step 4, Sweep):** read-only here — no downstream echo needs surfacing
> beyond the one draft block already reviewed.
>
> **`/revise` (step 6, Apply):** flips Entry A's per-entry inline tag `invented,
> unreviewed` → `invented, confirmed`. Confirm-only skips only step 3 (there is no
> content to fix); the marker flip **is** the entry's only edit, per
> `agents/revision.md` Procedure step 1's confirm-only carve-out.

The committed `canon/generated/frost-wards.md` in this folder **is** that
post-confirmation state. The diff against the pre-confirmation text quoted above is
visible in the file itself: Entry A's tag now reads `(invented, confirmed — scene01,
beat01, attempt01)` — text unchanged, tag flipped. Entry B's tag still reads
`(invented, unreviewed — scene01, beat01, attempt01)`, and the file-level frontmatter
still reads `status: invented, unreviewed` — both genuinely untouched, proving
per-entry-only scope, not just claimed in prose.

### This is not the end of the round trip

The marker flip fixes the *premise*, not the *prose* — `draft-v02.md`'s block 002 still
says "every two days." See [Closing the loop](#closing-the-loop-a-regenerated-compliance_report-re-run)
below (after §2's correction) for what re-running `compliance_report` actually produces —
it's not a simple append, because `compliance_fix`'s completion already moved the active
head out from under this report (see above).

**Check 4 covers the same ground, redundantly.** `compliance_report`'s Check 4 has its
own, separate Canon-consistency sub-check that reaches a named canon file on its own
escalation trigger (`canon_active` insufficient or not covering the asserted fact). It
reads the identical per-entry marker and applies the identical `[premise: unreviewed]`
tagging — the only difference is that Check 4 already carries a `[ref:]` tag on every
relational finding, so it **enriches that tag in place** with the entry's
scene/beat/attempt provenance rather than appending a second one (never two `[ref:]`
tags on one line). This fixture demonstrates Check 3's path only; the mechanism is
check-agnostic once a canon file is opened, so duplicating both paths here would add
fixture surface without adding a new mechanism to see.

## 2 — `continuity/`: Check 4, and a correct-and-confirm `/revise` pass

`continuity/story.md` originally carried:

```markdown
### Day count out of Last Well
- **id:** co-01
- **story-position:** scene01
- **committed-in:** draft-v01.md
- **evidence:** plot/drafts/attempt01/draft-v01.md#scene01
- **anchor:** The caravan stands six days out of Last Well at this point in the crossing.
- **review:** unreviewed
```

A different block of the same draft — block 003, not block 002 — has Senna reckon the
day-count: *"nine days out of Last Well."* Check 4 resolves `co-01`'s provenance,
reads its `unreviewed` marker, and finds a contradiction: six days maintained, nine
days claimed.

### The finding

```markdown
<!-- review-id: compliance:scene01:block-003-v01 -->
- INCONSISTENT (chronology): elapsed time — "nine days out of Last Well" contradicts
  the maintained day-count. co-01 fixes the caravan at Day 6 out of Last Well at this
  position. Prose: "nine days out of Last Well". [defect: prose] [ref:
  continuity/story.md#co-01] [premise: unreviewed]
  - Decision: FIX
```

Here the ordinary M16 `[defect: prose] [ref: continuity/story.md#co-01]` tag is present
— Check 4 always carries it — with `[premise: unreviewed]` appended **after** it, per
`agents/steps/compliance-report.md`'s ordering. `compliance_report`'s detection logic
is identical in shape across `canon/**` and `continuity/`/`knowledge/`; only the
locator differs — a self-contained quote+provenance triple for `canon/generated/`
(no minted id) versus a minted `co-NN`/`kn-NN` id here.

### Same safety property, same routing, different locator shape

```markdown
#### Escalated: elapsed time (review-id: compliance:scene01:block-003-v01)
- Reason: the violation line carries [premise: unreviewed] — the cited entry
  (continuity/story.md#co-01) is itself unconfirmed, so a FIX cannot be applied to
  prose against an unconfirmed guess, even though its defect label reads prose.
- Suggested upstream target: /revise against continuity/story.md#co-01 — the minted id,
  copied verbatim from the violation line's [ref:] tag.
```

Note the label reads `prose` — under ordinary M16 taxonomy this contradiction reads as
the prose being wrong, since `co-01` looks like settled, valid state. That is exactly
why the override matters here: a `prose`-or-absent-label unit decided `FIX` is
ordinarily applied straight to prose (`agents/steps/compliance-fix.md`). Only the
`[premise: unreviewed]` tag stops that — proving the override fires on a *labeled*
finding, not only on Check 3's unlabeled one (§1).

### The correct-and-confirm `/revise` pass

This time the human's investigation finds the *entry*, not the prose, was wrong:

> **Human:** "That day-count entry is wrong — I recount from the storm log, we were at
> Day 9 out of Last Well at that scene, not Day 6. Fix it and mark it reviewed."
>
> **`/revise` (step 1):** restates old truth → new truth: "`continuity/story.md#co-01`
> currently anchors Day 6 out of Last Well; correcting to Day 9."
>
> **`/revise` (step 3, fix the source of truth first):** corrects `co-01`'s `anchor`
> value in place, **keeping its `id`** — an authorial correction to a current-state
> entry, not a diegetic supersession, so no `## Superseded` transition is added
> (`agents/revision.md`'s current-state-vs-record distinction).
>
> **`/revise` (step 6, Apply):** flips `- **review:** unreviewed` → `- **review:**
> confirmed` **in the same edit** as the value correction.

The committed `continuity/story.md` **is** that post-correction, post-confirmation
state: `co-01`'s `anchor` now reads "nine days," `- **review:**` now reads `confirmed`
— both landed together, exactly as `/revise`'s Apply step (`agents/revision.md:39`)
requires.

### Contrast with §1: this time, no finding at all

Unlike §1, the corrected value happens to **already match** the prose — the entry, not
the draft, was the error. In a live run, `/revise`'s Sweep (step 4) + Apply (step 6)
would also check for a matching prose echo in `<latest-draft>` (now `draft-v02.md`, the
active head after `compliance_fix`'s run) per its Edit scope; here there is none to
correct, since block 003 already said "nine days." See
[Closing the loop](#closing-the-loop-a-regenerated-compliance_report-re-run) for what
this means once both §1's and §2's `/revise` passes are in.

## Closing the loop: a regenerated `compliance_report` re-run

Both `/revise` passes above (§1's confirm-only, §2's correct-and-confirm) are done. The
human now closes the loop the same way for both: re-run `compliance_report` — the
existing recipe step, not a new mechanism. But this re-run is not a simple append.

`compliance_fix`'s run (§1) already minted `draft-v02.md` and repointed `Active-head:`
to it, while `reviewer-actions.md`'s top-of-file stamp is still `Reviewed-draft:
draft-v01.md` — untouched, since `compliance_fix` "only appends"
(`agents/steps/compliance-fix.md`) and never rewrites the stamp. So `<latest-draft>` now
resolves to `draft-v02.md`, which does **not** equal the existing stamp. Per
`compliance_report`'s own freshness contract (`agents/steps/compliance-report.md`,
"Output file format"): *"If the file exists and its top-of-file stamp does not equal
`<latest-draft>` — the recovery path when the human is regenerating after a stale-report
blocker — the report is `regenerated`: overwrite the whole file with a fresh top-of-file
stamp, and the prior run's findings against the superseded draft are `discarded`."* This
is exactly the state the shared validator reports for the committed
`reviewer-actions.md` once the manifest is checked — see
[Validating the report](#validating-the-report).

So the re-run **overwrites** `reviewer-actions.md` with a fresh `Reviewed-draft:
draft-v02.md` stamp, discarding the prior findings (`Escalated:` blocks included) and
re-evaluating both blocks from scratch against `draft-v02.md`, whose text is identical
to `draft-v01.md`'s. Because it's a fresh file, there is no ordinal to continue — the new
findings legitimately start again at `v01`:

```markdown
Reviewed-draft: draft-v02.md

## Compliance Report — Scene scene01, 2026-08-12

### Block 001 — CLEAN

### Block 002
<!-- review-id: compliance:scene01:block-002-v01 -->
- INCONSISTENT (canon): Frost-ward duration — "every two days, same as always" violates
  rule: "a chalked frost-ward holds a sealed crate for three days before it must be
  recast; past that, the verglass begins to sweat and crack" [ref:
  canon/generated/frost-wards.md#scene01-beat01-attempt01 "holds a sealed crate for
  three days before it must be recast"]
  - Decision:

### Block 003 — CLEAN

### Block 004 — CLEAN
```

**Block 002** — the same contradiction, the same `[ref:]` locator (Check 3 still
escalates and still writes it, regardless of confirmation state) — but this time
**without** `[premise: unreviewed]`, since Entry A's marker now reads `confirmed`.
Without the tag, `compliance_fix`'s override never triggers: this is a local unit
carrying no `[defect: …]` tag (the pre-M16 shape), so a human `Decision: FIX` this time
reaches an ordinary `Applied:` prose edit through `compliance_fix` — actually correcting
"two days" to "three days," this time for real.

**Block 003** — clean. `co-01` is now confirmed **and** corrected to "nine days," which
is what the prose already said, so there is nothing left to find.

Put together, §1 and §2 are the two real outcomes of the same closing step, landing in
the **same** re-run: **either no finding (block 003), or a fresh, untagged finding
(block 002)** the human can `FIX` normally. Neither is "the tag silently disappears
while the underlying problem persists" — the round trip actually closes one way or the
other. This is illustrative, not a new committed artifact in this fixture — the actual
regenerated file isn't added here, since it would immediately supersede and orphan the
`reviewer-actions.md` this fixture's earlier sections walk through in detail.

## 3 — `characters/dessa/timeline.md`: `/revise`'s extended scope, no compliance finding involved

`characters/dessa/timeline.md` originally carried one capture-agent-style entry from an
earlier, unmodeled drafting pass (the drafting apparatus that produced it isn't built
here — only the resulting file is):

```markdown
### Apprenticed to a salt-diviner in Drybone Market
- **id:** tl-01
- **story-position:** pre-story
- **committed-in:** —
- **event:** Before joining Torrin's crew, Dessa spent a season apprenticed to a
  salt-diviner in Drybone Market, learning to read wind-scour patterns for weather
  sign. (invented, unreviewed — scene00, beat01, attempt01)
```

No compliance finding reaches this entry — `compliance_report` has no input reading
`timeline.md` or `profile.md` at all. This is a documented, tracked gap, not silently
dropped: ROADMAP.md's Deferred → Now-actionable list carries it by name —
`"compliance_report consultation of characters/<id>/timeline.md / profile.md for
unreviewed-premise detection"` — recorded because closing it needs
`compliance_report` to gain those as new relational inputs, a bigger change than this
Sprint's retrofit-of-existing-resolution scope.

### The direct `/revise` invocation

> **Human**, outside any compliance flow: "The Dessa apprenticeship entry in her
> timeline — that's right as written, mark it reviewed."
>
> **`/revise` (step 1, confirm-only invocation):** restates what is being confirmed:
> "`characters/dessa/timeline.md#tl-01` — Dessa's season apprenticed to a salt-diviner
> in Drybone Market — confirmed as written, no change." The human confirms.
>
> **`/revise` (step 6, Apply):** flips the inline tag `invented, unreviewed` →
> `invented, confirmed`. No other edit; character files are already in `/revise`'s
> "always edited in place" scope (`agents/revision.md:13`), so extending the
> confirm-or-correct mechanism to this destination cost nothing extra.

The committed `characters/dessa/timeline.md` **is** that post-confirmation state: the
tag now reads `(invented, confirmed — scene00, beat01, attempt01)`.

This proves `/revise`'s extended confirm-or-correct scope **independent of**
`compliance_report`'s detection gap for these two destinations: the marker vocabulary,
the confirm-only invocation shape, and the Apply-step flip are all real and reachable
today by a human asking directly, even though no automated check will ever surface this
particular entry's `unreviewed` state as a tagged finding this Sprint.

## Validating the report

The compliance report is a real `compliance:`-family review artifact. From the repo
root:

```sh
sh scripts/validate-review-artifact.sh \
  examples/unreviewed-confirmation/plot/drafts/attempt01/reviewer-actions.md \
  agents/review-grammars.yaml
```

Actual captured output:

```
validate-review-artifact.sh: examples/unreviewed-confirmation/plot/drafts/attempt01/reviewer-actions.md — family: compliance (adopted)
state: not checked (no manifest file given)
findings: none
ledger:
  total: 2
  pending: 0
  decided: 2
  inherited-by-bulk: 0
  skipped: 0
  escalated: 0
  invalid: 0
  stale: 0
verdict: proceed (exit 0)
```

Both units carry a legal, filled `Decision:` (`FIX`, `FIX`) and every violation line is
a well-formed, anchored review unit, so the ledger counts `decided: 2` and the verdict
is `proceed`, exit 0. Note `escalated: 0` in the ledger — that row counts units whose
`Decision:` token is literally `ESCALATE`; both units here are decided `FIX`. The
`Escalated:` blocks appended below `## Context consulted` are `compliance_fix`'s own
apply-log output, not a `Decision:` token, so they raise nothing in the validator's
count and do not turn a `FIX` into a different ledger bucket — the validator only cares
that the `Decision:` token itself is legal, exactly as expected: `FIX` stays legal
regardless of what the step body does with it afterward. The `[premise: unreviewed]`
and `[ref: …]` tags ride inside the existing violation line's free text, exactly as
M16's `[defect:][ref:]` tag does, so they raise no structural or grammar defect either.

Passing the attempt's manifest additionally exercises the freshness (state) layer — and
here it matters: `draft-manifest.md` shows `Active-head: draft-v02.md` (`compliance_fix`
minted it and repointed the head, per its completion contract — see
[Closing the loop](#closing-the-loop-a-regenerated-compliance_report-re-run)), while
this file is still stamped `Reviewed-draft: draft-v01.md`:

```sh
sh scripts/validate-review-artifact.sh \
  examples/unreviewed-confirmation/plot/drafts/attempt01/reviewer-actions.md \
  agents/review-grammars.yaml \
  examples/unreviewed-confirmation/plot/drafts/attempt01/draft-manifest.md
```

Actual captured output:

```
state: STALE — Reviewed-draft: draft-v01.md does not equal Active-head: draft-v02.md
ledger:
  total: 2
  pending: 0
  decided: 2
  inherited-by-bulk: 0
  skipped: 0
  escalated: 0
  invalid: 0
  stale: 1
verdict: stale (exit 5)
```

The ledger's per-unit counts are unchanged (`decided: 2`, both `FIX`), but the
file-level `state:` axis now reports `STALE` and the verdict flips to `stale` (exit 5) —
the validator's own confirmation of exactly the mechanism
[Closing the loop](#closing-the-loop-a-regenerated-compliance_report-re-run) narrates:
this committed `reviewer-actions.md` is a real, validator-confirmed stale artifact
against the post-`compliance_fix` manifest, which is why the next `compliance_report`
run regenerates it rather than appending to it.
