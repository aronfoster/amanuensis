---
step_id: storyboard_review
review_required: true
inputs:
  - <chapter-folder>/storyboards/*-storyboard.md
  - <chapter-folder>/scene-list.md
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
  - path: reveals.md
    kind: source
    required: false
    review_sensitive: false
---

See `agents/orchestrator.md` for the step workflow contract.

# Storyboard Review

## Purpose

Flag where a chapter's storyboard blocks under-serve the reader: takeaways the storyboard does not support, reveals with no prior setup, blocks that disclose a reveal before its concealment window, and takeaways that contradict their own concealment. The reveal checks reason **across chapters** against the story-level `reveals.md` ledger (`agents/reveals.md`). This step is read-only, report-only, and advisory: it produces a per-block report for a human to read. It runs after `storyboarding` and before `drafting`. It is purely diagnostic — it proposes no fixes and there is no paired fix step (a `storyboard_review_fix` is a future milestone); the human reads the report and revises the storyboards by hand.

## Inputs

- `<chapter-folder>/storyboards/*-storyboard.md` — all storyboard blocks for the chapter. The block fields drive the three checks below: `reader_takeaway` for all three; the `beat` description, `must_preserve`, `canon_active`, and character-state fields for takeaway support; `concealment_from_reader` for setup and consistency.
- `<chapter-folder>/scene-list.md` — read only for canonical scene/beat ordering and scene-level reveal intent. It anchors the reveal checks' ordering of blocks.
- `reveals.md` — the project-root, human-authored, story-level reveals ledger (`agents/reveals.md`): the `id`-bearing index of forward reveals with their `lands:` / `setup:` / `concealed-until:` block-qualified positions. Consumed **read-only** by the two reveal checks (Check 2) via targeted lookup of named entries and positions, per `agents/review-context.md` — not a corpus scan. `required: false` and project-type-aware: a story-level ledger exists meaningfully only where reveals span the work, so a project without one does not block.

Beyond these, do not read a draft — none exists at this stage — and do not consult source canon files: the current chapter's storyboard fields, the ledger, and — by targeted retrieval of exactly the positions a ledger `setup:` entry names (Check 2(i)) — the storyboard block at each such prior position are what this step evaluates against. A field that is missing or unparseable is a storyboard defect to note, not a reason to reach for source files.

## Behavior

Read all storyboard blocks for the chapter in order — by `scene-list.md` scene order, then `beat_index`. For each block, run the three checks below. Record one entry per block in `storyboard-review.md`.

### Output file format

Begin each run's section with a dated header:

```markdown
## Storyboard Review — [chapter/scene id], [date]
```

If a block is fully clean across all three checks, record a single line:

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
```

Use only the finding types that apply. Do not record passing checks alongside findings. Do not include a draft-version stamp of any kind (there is no draft to stamp) and do not add any FIX/SKIP/ESCALATE annotation grammar or `<!-- review-id: ... -->` anchors — this report is advisory-only and no consumer for annotations exists.

A reveal finding (Check 2) carries the greppable trailing tag ` [defect: <type>] [ref: reveals.md#rv-NN]` on its finding line (the canonical surface form of `agents/review-context.md`): a leaking or ill-ordered *storyboard* is `[defect: storyboard]` (it violates the higher-precedence reveal plan — never a "ledger is wrong" defect), and only the *plan itself* being wrong — a ledger entry internally inconsistent or contradicting canon — is `[defect: state]` (the `reveals.md` member of the maintained-state type), routed to the human who maintains the ledger. The takeaway checks (1 and 3) do not carry the tag.

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

### At the end of the report

After all blocks, append a summary:

```markdown
### Summary

- Unsupported takeaways: N
- Reveals without setup: N
- Premature disclosures: N
- Takeaway/concealment contradictions: N
- Blocks fully clean: N of N

[Any pattern-level observation — e.g. "unsetup reveals cluster in scene 03" — goes here. One or two lines only. Do not propose fixes.]
```

Do not propose fixes. The summary observation is a diagnostic, not a recommendation. This step never rewrites a storyboard block: it is read-only over the storyboards it reviews.

After the summary, append a report-level section — headed exactly `## Context consulted` — naming the specific ledger entries (and the positions) this run consulted for the reveal checks, the canonical audit surface of `agents/review-context.md`:

```markdown
## Context consulted

- reveals.md#rv-02 (setup positions scene01:block-003, scene02:block-005; concealed-until scene04:block-002)
```

If no ledger was present or consulted, record a single `## Context consulted` heading with a `- none` line.

## Outputs

- `<chapter-folder>/storyboards/storyboard-review.md` — the advisory report. One `## Storyboard Review — [chapter/scene id], [date]` header per run, one `### Block NNN` entry per storyboard block (either a single `CLEAN` line or a list of findings; reveal findings carry the ` [defect: <type>] [ref: reveals.md#rv-NN]` tag and reason cross-chapter against the ledger), a `### Summary` block per run tallying findings by check and noting any pattern-level observation, and a report-level `## Context consulted` section naming the `reveals.md` entries the reveal checks consulted. It is written beside the storyboards it reviews because no `drafts/<latest-attempt>/` folder exists yet — the other report steps write into a draft attempt folder because they review a draft; this step runs before any draft attempt exists. The file is the human review artifact: the human reads it and revises the storyboards by hand before `drafting`.

## Anti-Patterns

**Proposing fixes or rewriting storyboards.** This step is advisory and read-only. If the review pass rewrites a block or recommends a specific revision, it has failed. There is no paired fix step; revision is the human's job.

**Recording passing checks.** Clean checks are not recorded. A block entry is either one line (`CLEAN`) or a list of findings only. Passing items alongside findings inflate the file and defeat the purpose of the format.

**Consulting files not listed as inputs.** If a block's fields are too thin to evaluate a check, that is a storyboard defect. Note it; do not reach for canon source files or a draft (none exists). The reveal checks consult `reveals.md` and — by **targeted retrieval of exactly the position a ledger `setup:` entry names** — the storyboard block at that named prior position (Check 2(i)); no other source file, and never an untargeted scan of the prior storyboard corpus.

**Rescanning the prior storyboard corpus.** The reveal checks reason across chapters, but by **targeted lookup** against `reveals.md` — a reveal's named `setup:` positions, a secret's `concealed-until:` range — never a full re-read of every prior block. Setup sufficiency reads exactly the storyboard block each named `setup:` position points at (a bounded, targeted retrieval, not a scan); the premature-disclosure guard walks only the active secrets against the blocks in their range (O(active secrets × blocks)).

**Adding a draft-version stamp or annotation grammar.** Neither applies to a pre-draft advisory report: there is no draft to stamp against, and no fix step exists to consume annotations.

## Open questions handling

If the step cannot complete because of missing or ambiguous inputs (e.g., no storyboard blocks, a storyboard block whose fields cannot be parsed, or no `scene-list.md`), append the blocker to the project root `open-questions.md` and exit without recording completion in `pipeline-state.md`. Do not fabricate inputs and do not write a partial report. The next dispatcher invocation will re-run this step after the human resolves the blocker. On a successful run, the step's final action is to mark its own step line `[x]` in `pipeline-state.md` and update `last_updated`.
