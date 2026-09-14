---
step_id: storyboard_review
review_required: true
inputs:
  - <chapter-folder>/storyboards/*-storyboard.md
  - <chapter-folder>/scene-list.md
  - <chapter-folder>/summary.md
  - <chapter-folder>/storyboards-planning.md
  - <prior-scene-storyboards>
  - reveals.md
outputs:
  - <chapter-folder>/storyboards/storyboard-review.md
preconditions:
  - path: <chapter-folder>/storyboards/*-storyboard.md
    kind: source
    required: true
    review_sensitive: false
  - path: <chapter-folder>/scene-list.md
    kind: source
    required: true
    review_sensitive: false
  - path: <chapter-folder>/summary.md
    kind: source
    required: true
    review_sensitive: false
  - path: <chapter-folder>/storyboards-planning.md
    kind: source
    required: false
    review_sensitive: false
  - path: <prior-scene-storyboards>
    kind: source
    required: false
    review_sensitive: false
  - path: reveals.md
    kind: source
    required: false
    review_sensitive: false
---

See `agents/orchestrator.md` for the step workflow contract.

# Storyboard Review

## Purpose

Flag where a chapter's storyboard blocks under-serve the reader: takeaways the storyboard does not support, reveals with no prior setup, blocks that disclose a reveal before its concealment window, takeaways that contradict their own concealment, and scene-entry context that is missing, misplaced, inconsistent with the preceding plan, future-leaking, or too broad to guide an isolated drafter. The reveal checks reason **across chapters** against the story-level `reveals.md` ledger (`agents/reveals.md`). This step is read-only, report-only, and advisory: it produces a per-block report for a human to read. It runs after `storyboarding` and before `drafting`. It is purely diagnostic — it proposes no fixes and there is no paired fix step (a `storyboard_review_fix` is a future milestone); the human reads the report and revises the storyboards by hand.

## Inputs

- `<chapter-folder>/storyboards/*-storyboard.md` — all storyboard blocks for the chapter. The block fields drive the four checks below: `reader_takeaway`, the `beat` description, `must_preserve`, `canon_active`, character-state fields, and `concealment_from_reader` drive Checks 1–3; the first block's `Reader state in` and `Since previous scene`, together with the preceding scene's blocks, drive Check 4.
- `<chapter-folder>/scene-list.md` — read for canonical scene/beat ordering, scene-level reveal intent, and scene-boundary intent.
- `<chapter-folder>/summary.md` — the declared chapter-level planning source used to assess the first planned scene's entry context when the work began earlier.
- `<chapter-folder>/storyboards-planning.md` — optional planning notes used for the same first-scene boundary check when present.
- `<prior-scene-storyboards>` — for the first planned scene of a continuing `book` or `series`, the same immediately preceding planned scene that `storyboarding` used to seed entry context, resolved by `agents/project-layouts.md`. `required: false` for work openings and `short_story`; retrieval is limited to that one scene.
- `reveals.md` — the project-root, human-authored, story-level reveals ledger (`agents/reveals.md`): the `id`-bearing index of forward reveals with their `lands:` / `setup:` / `concealed-until:` block-qualified positions. Consumed **read-only** by the two reveal checks (Check 2) via targeted lookup of named entries and positions, per `agents/review-context.md` — not a corpus scan. `required: false` and project-type-aware: a story-level ledger exists meaningfully only where reveals span the work, so a project without one does not block.

Beyond these, do not read a draft — none exists at this stage — and do not consult source canon files. Checks 1–3 use the current chapter's storyboard fields, the ledger, and targeted retrieval of exactly the positions a ledger `setup:` entry names. Check 4 uses the same boundary inputs as `storyboarding`: the current chapter's ordered storyboard set, summary, scene list, optional storyboard-planning notes, and the targeted `<prior-scene-storyboards>` when the chapter continues an existing work. A field that is missing, unparseable, or unverifiable from those declared inputs is a storyboard defect to note, not a reason to reach for prior prose, other prior scenes, or source files.

## Behavior

Read all storyboard blocks for the chapter in order — by `scene-list.md` scene order, then `beat_index`. For each block, run the four checks below. Record one entry per block in `storyboard-review.md`.

### Output file format

Begin each run's section with a dated header:

```markdown
## Storyboard Review — [chapter/scene id], [date]
```

If a block is fully clean across all four checks, record a single line:

```markdown
### Block NNN — CLEAN
```

If a block has any finding, record only the findings — not the passing checks:

```markdown
### Block NNN
- UNSUPPORTED (reader_takeaway): [beat] — [takeaway] has no on-page support in the beat's content
- UNSETUP (reveal): [beat] — reveal rv-NN's `setup:` position [pos] is not established. [defect: storyboard] [ref: reveals.md#rv-NN]
- PREMATURE (reveal): [beat] — block discloses reveal rv-NN before its `concealed-until:` [pos]. [defect: storyboard] [ref: reveals.md#rv-NN]
- CONTRADICTION (reader_takeaway vs concealment_from_reader): [beat] — takeaway "[…]" requires naming what concealment forbids "[…]"
- MISSING (reader_state_in): [scene] — first block has no `Reader state in` section
- MISSING (since_previous_scene): [scene] — first block has no `Since previous scene` section
- MISPLACED (scene_entry): [scene] — scene-entry section appears outside the first block
- INCONSISTENT (reader_state_in): [scene] — entry claim "[…]" conflicts with the preceding scene's reader-visible close at [scene/block]
- PREMATURE (reader_state_in): [scene] — entry claim "[…]" is first established in the current or a future block
- UNVERIFIABLE (reader_state_in): [scene] — declared inputs do not establish claimed prior context "[…]"
- INCOMPLETE (since_previous_scene): [scene] — relevant change or material non-change […] is omitted
- OVERLOADED (scene_entry): [scene] — section copies irrelevant prior content or dictates recap prose rather than supplying compact context
```

Use only the finding types that apply. Do not record passing checks alongside findings. Do not include a draft-version stamp of any kind (there is no draft to stamp) and do not add any FIX/SKIP/ESCALATE annotation grammar or `<!-- review-id: ... -->` anchors — this report is advisory-only and no consumer for annotations exists.

A reveal finding (Check 2) carries the greppable trailing tag ` [defect: <type>] [ref: reveals.md#rv-NN]` on its finding line (the canonical surface form of `agents/review-context.md`): a leaking or ill-ordered *storyboard* is `[defect: storyboard]` (it violates the higher-precedence reveal plan — never a "ledger is wrong" defect), and only the *plan itself* being wrong — a ledger entry internally inconsistent or contradicting canon — is `[defect: state]` (the `reveals.md` member of the maintained-state type), routed to the human who maintains the ledger. The takeaway checks (1 and 3) and scene-entry check (4) do not carry the tag. Scene-entry findings are necessarily about the storyboard contract being reviewed and have no annotation consumer; they cite the preceding scene/block or boundary input directly in the finding text and `## Context consulted` section.

Work block by block. Do not collapse findings across blocks.

#### Check 1: Takeaway supported

Source fields: `reader_takeaway`, checked against the `beat` description, `must_preserve`, `canon_active`, and character-state fields.

For each block, confirm the beat's own content gives the drafter the material to land the block's `reader_takeaway`. If the takeaway asserts an understanding the beat provides no on-page support for, record an `UNSUPPORTED` finding. If supported, do not record it.

#### Check 2: Reveal setup and premature disclosure

Source: the storyboard blocks (`reader_takeaway`, `beat_type`, `concealment_from_reader`) and `reveals.md` (each entry's `lands:` / `setup:` / `concealed-until:` block-qualified positions), ordered by `scene-list.md` scene order then `beat_index`. The strategy and precedence are single-sourced in `agents/review-context.md` (reveal-timing carve-out: **canon > `reveals.md` > storyboard > prose**) and the ledger schema in `agents/reveals.md`; neither is restated here. This check reasons **across chapters** against the story-level ledger — it is no longer chapter-scoped. Two complementary sub-checks run, so the review is blind to neither direction of a reveal failure:

**(i) Setup sufficiency (targeted).** For each block that is a `beat_type: reveal` (or whose `reader_takeaway` depends on prior understanding), look up its ledger entry and confirm the entry's `setup:` positions are established — by **targeted lookup of exactly those positions**, never a full prior-storyboard rescan. A `setup:` position in the **current** chapter resolves against the blocks already in hand; a `setup:` position that names a **prior** chapter is confirmed by **targeted retrieval of the storyboard block at exactly that named position** (the `agents/review-context.md` strategy — read only what the ledger names, never a corpus scan). If a `setup:` position is not established (the named block does not do the setup), record an `UNSETUP (reveal)` finding citing the ledger entry (`reveals.md#rv-NN`).

**No-ledger fallback (within-chapter).** `reveals.md` is `required: false`, so a project may carry none, or a reveal-bearing block may have no covering ledger entry. Where there is no ledger entry to check a reveal against, fall back to the pre-M16 **within-chapter** setup check: for each block whose `reader_takeaway` depends on prior understanding — including every `beat_type: reveal` — confirm that an **earlier block in the current chapter** establishes that understanding (via its `reader_takeaway` or content) and that the depended-on fact is not still under `concealment_from_reader` at that earlier point. If no prior setup exists, record an `UNSETUP (reveal)` finding. This retains the original coverage so a ledger-less project is never left with an unchecked reveal; the ledger path above supersedes it wherever a ledger entry covers the reveal.

**(ii) Premature-disclosure guard (whole-range, every block).** A `concealed-until:` is an **active constraint over a block-qualified position range**, and it applies to **every** reviewed block whose block-qualified position precedes it — **not only reveal-tagged blocks**, and **not** by trusting the block's local `concealment_from_reader` to redundantly carry the secret. For each ledger secret still active at the current block (the block's position precedes the secret's `concealed-until:`), check whether the block discloses it; if an ordinary beat leaks a ledger secret early, record a `PREMATURE (reveal)` finding — even though the block is not itself a reveal. Because positions are block-qualified (`<…scene-id>:block-NNN`), "precedes" is well-defined **within** a scene as well as across scenes — block 003 precedes a `concealed-until: …:block-004`. The guard is bounded: O(active secrets × blocks), not a corpus rescan.

Both sub-checks label a leaking or ill-ordered *storyboard* `[defect: storyboard]` (the storyboard violates the higher-precedence reveal plan; the guard must not be talked out of the finding by relaxing the plan). Only the *plan itself* being wrong — a ledger entry internally inconsistent or contradicting canon — is `[defect: state]` against `reveals.md`, routed to the human who maintains the ledger.

#### Check 3: Takeaway/concealment consistency guard

Source fields: `reader_takeaway`, `concealment_from_reader`.

For each block, confirm its `reader_takeaway` does not require the reader to grasp something the same block's `concealment_from_reader` forbids naming or clarifying. If they conflict, record a `CONTRADICTION` finding. If consistent, do not record it.

#### Check 4: Scene-entry context

Source fields: `Reader state in` and `Since previous scene` in each scene's first block; the ordered storyboard blocks for the preceding scene; `scene-list.md`; and, for the first planned scene when the work began earlier, the same declared boundary set used by `storyboarding`: `<prior-scene-storyboards>`, chapter summary, scene list, and optional storyboard-planning notes.

Review scene-entry context by scene, while emitting any finding on the specific block that carries or should carry the field:

1. **Placement and cardinality.** The lowest-`beat_index` block must contain exactly one of each scene-entry section, and neither may appear in a later block. Identify a section by its normalized Markdown heading text, regardless of heading depth; the canonical producer emits `##`, while legacy fixtures may use `#`. Record `MISSING (reader_state_in)`, `MISSING (since_previous_scene)`, or `MISPLACED` as applicable. The exact opening sentinels are valid only for the opening scene of the entire work; using them at a chapter or planning-batch boundary is `INCONSISTENT`.
2. **Reader-state correctness.** For each later scene, compare `Reader state in` with the preceding scene's `reader_takeaway` fields and reader-visible beat outcomes. The field may select only relevant already-established context. Record `INCONSISTENT` for a contradiction, `PREMATURE` for information first established in the current or a future block, and `UNVERIFIABLE` when the claimed prior state cannot be supported from the declared inputs. Do not treat objective canon or character-only knowledge as reader knowledge.
3. **Cross-scene delta.** Compare `Since previous scene` with the preceding scene's close and the current scene's planned opening: final character states, elapsed time, location, environment or staging, roles, relationships, dangers, objectives, and emotional carryover where relevant. Record `INCONSISTENT` for a wrong delta and `INCOMPLETE` when omission of a relevant change or material non-change would invite a fresh establishing treatment or continuity drift. Do not admit developments that occur during the current scene.
4. **Context discipline.** Both fields must be compact specifications, not prior-scene summaries, prose samples, or instructions to repeat the listed content. Record `OVERLOADED` when a field copies irrelevant prior material or converts context into recap requirements.

For the first planned scene of a continuing work, assess the fields against `<prior-scene-storyboards>` plus the boundary information in the declared summary, scene list, and optional storyboard-planning notes — exactly the producer's declared boundary set. If those sources do not establish the claimed reader state or prior-scene delta, record `UNVERIFIABLE`; do not scan other prior scenes or prose. For the work's true opening scene, validate the exact sentinels and perform only the placement/cardinality and context-discipline checks.

Do not flag every carried-forward fact or unchanged condition. The defect is an incorrect, missing, future-leaking, or unusably broad entry briefing — not the mere existence of cross-scene context.

### At the end of the report

After all blocks, append a summary:

```markdown
### Summary

- Unsupported takeaways: N
- Reveals without setup: N
- Premature disclosures: N
- Takeaway/concealment contradictions: N
- Scene-entry structure violations: N
- Reader-state inconsistencies / premature claims / unverifiable claims: N
- Cross-scene delta inconsistencies / omissions: N
- Overloaded scene-entry fields: N
- Blocks fully clean: N of N

[Any pattern-level observation — e.g. "unsetup reveals cluster in scene 03" — goes here. One or two lines only. Do not propose fixes.]
```

Do not propose fixes. The summary observation is a diagnostic, not a recommendation. This step never rewrites a storyboard block: it is read-only over the storyboards it reviews.

After the summary, append a report-level section — headed exactly `## Context consulted` — naming the specific ledger entries and prior storyboard positions consulted for the reveal checks, plus the preceding-scene positions or first-scene boundary planning inputs consulted for the scene-entry check. This is the canonical audit surface of `agents/review-context.md`:

```markdown
## Context consulted

- reveals.md#rv-02 (setup positions scene01:block-003, scene02:block-005; concealed-until scene04:block-002)
- plot/storyboards/scene01-beat04-storyboard.md (scene01 reader-visible close used for scene02 entry check)
- plot/summary.md (boundary source used for the first planned scene)
```

If no ledger, preceding scene, or boundary planning source was consulted — possible for a one-scene work opening — record a single `## Context consulted` heading with a `- none` line.

## Outputs

- `<chapter-folder>/storyboards/storyboard-review.md` — the advisory report. One `## Storyboard Review — [chapter/scene id], [date]` header per run, one `### Block NNN` entry per storyboard block (either a single `CLEAN` line or a list of findings; reveal findings carry the ` [defect: <type>] [ref: reveals.md#rv-NN]` tag and reason cross-chapter against the ledger; scene-entry findings validate placement, prior-reader correctness, cross-scene delta, and context discipline), a `### Summary` block per run tallying findings by check and noting any pattern-level observation, and a report-level `## Context consulted` section naming the `reveals.md` entries, preceding-scene storyboard positions, and first-scene boundary inputs the checks consulted. It is written beside the storyboards it reviews because no `drafts/<latest-attempt>/` folder exists yet — the other report steps write into a draft attempt folder because they review a draft; this step runs before any draft attempt exists. The file is the human review artifact: the human reads it and revises the storyboards by hand before `drafting`.

## Anti-Patterns

**Proposing fixes or rewriting storyboards.** This step is advisory and read-only. If the review pass rewrites a block or recommends a specific revision, it has failed. There is no paired fix step; revision is the human's job.

**Recording passing checks.** Clean checks are not recorded. A block entry is either one line (`CLEAN`) or a list of findings only. Passing items alongside findings inflate the file and defeat the purpose of the format.

**Consulting files not listed as inputs.** If a block's fields are too thin to evaluate a check, that is a storyboard defect. Note it; do not reach for canon source files or a draft (none exists). The reveal checks consult `reveals.md` and — by **targeted retrieval of exactly the position a ledger `setup:` entry names** — the storyboard block at that named prior position (Check 2(i)); no other source file, and never an untargeted scan of the prior storyboard corpus.

**Rescanning the prior storyboard corpus.** The reveal checks reason across chapters, but by **targeted lookup** against `reveals.md` — a reveal's named `setup:` positions, a secret's `concealed-until:` range — never a full re-read of every prior block. Setup sufficiency reads exactly the storyboard block each named `setup:` position points at (a bounded, targeted retrieval, not a scan); the premature-disclosure guard walks only the active secrets against the blocks in their range (O(active secrets × blocks)).

**Treating all carry-forward as a defect.** `Reader state in` is supposed to carry relevant context across scenes, and `Since previous scene` may explicitly record material non-change. Flag incorrect, omitted, future-leaking, or bloated context — not concise context that does its job.

**Scanning prior prose to verify scene entry.** For later scenes in the current chapter, use the preceding scene's planned blocks already in hand. For the first planned scene in a continuing work, use only `<prior-scene-storyboards>` and the declared current-chapter boundary sources. If they are insufficient, record `UNVERIFIABLE`; do not expand the input boundary.

**Adding a draft-version stamp or annotation grammar.** Neither applies to a pre-draft advisory report: there is no draft to stamp against, and no fix step exists to consume annotations.

## Open questions handling

If the step cannot complete because of missing or ambiguous inputs (e.g., no storyboard blocks, a storyboard block whose fields cannot be parsed, or no `scene-list.md`), append the blocker to the project root `open-questions.md` and exit without recording completion in `pipeline-state.md`. Do not fabricate inputs and do not write a partial report. The next dispatcher invocation will re-run this step after the human resolves the blocker. On a successful run, the step's final action is to mark its own step line `[x]` in `pipeline-state.md` and update `last_updated`.
