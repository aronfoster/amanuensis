---
step_id: compliance_report
review_required: true
inputs:
  - <chapter-folder>/storyboards/*-storyboard.md
  - <chapter-folder>/drafts/<latest-attempt>/<latest-draft>
  - continuity/
  - characters/<character-id>/knowledge/*.md
  - canon/**
outputs:
  - <chapter-folder>/drafts/<latest-attempt>/reviewer-actions.md
preconditions:
  - path: <chapter-folder>/storyboards/*-storyboard.md
    kind: source
    required: true
    review_sensitive: false
  - path: <chapter-folder>/drafts/<latest-attempt>/<latest-draft>
    kind: prose_draft
    required: true
    review_sensitive: false
  - path: continuity/
    kind: source
    required: false
    review_sensitive: false
  - path: characters/<character-id>/knowledge/*.md
    kind: source
    required: false
    review_sensitive: false
  - path: canon/**
    kind: source
    required: false
    review_sensitive: false
---

See `agents/orchestrator.md` for the step workflow contract.

# Compliance Report

## Purpose

Report compliance violations between a chapter's storyboard blocks and its drafted prose. This step is the **bounded relational review** (`agents/review-context.md`, `compliance_report` row of its audit): it is read-only, and it produces a per-block report of Must-Contain, Must-Not-Contain, and Canon-consistency violations (the local checks) **plus relational violations** — continuity, character-knowledge, reveal-timing, chronology, recollection, and recap fidelity, the drafted prose read against the maintained `continuity/` + `characters/<id>/knowledge/` state and named canon via targeted retrieval — for a human to triage. Fixing happens in the separate `compliance_fix` step. The report is the human review artifact that gates the fix step.

## Inputs

- `<chapter-folder>/storyboards/*-storyboard.md` — all storyboard blocks for the chapter. The block fields drive the three checks below: `must_preserve` and `character_state_out` for Must-Contain; `concealment_from_reader` and `concealment_from_characters` for Must-Not-Contain; `canon_active` for Canon.
- `<chapter-folder>/drafts/<latest-attempt>/<latest-draft>` — the drafted prose to evaluate against the storyboard blocks. Resolved at step start via the manifest's active head — or via the read-from override the dispatcher passed — per `agents/project-layouts.md`, not by highest-numbered draft; this step does not mint a new draft version.
- `continuity/` (`continuity/book-N.md` for `book`/`series`, `continuity/story.md` for `short_story`) — the maintained derived-continuity state, read for the relational continuity checks (chronology, event-staging, location, possession, physical-condition, role, open-thread — including recalled-event-staging and recap fidelity). `required: false` because it may not have been produced yet (the M15 `continuity_update` writer may not have run) — **not** because a `short_story` lacks it: a `short_story` maintains `continuity/story.md` just as a `book`/`series` maintains `continuity/book-N.md`. Read whichever this project has whenever it is present; only block-nothing on its absence.
- `characters/<character-id>/knowledge/*.md` (`knowledge/book-N.md` for `book`/`series`, `knowledge/story.md` for `short_story`) — the maintained character-knowledge state, read for the `concealment_from_characters` / reveal-timing relational check. `required: false` for the same reason — a `short_story` maintains `knowledge/story.md`; read it when present, block on nothing when it is absent (the M14 writer may not have run yet).
- `canon/**` — named canon files, consulted only when a block's `canon_active` is insufficient or the prose asserts a checkable fact `canon_active` does not cover. `required: false`.

Retrieve context by the `agents/review-context.md` strategy — name the specific referents the prose invokes and fetch only those — not by corpus scan. For a canon check, consult the block's `canon_active` first and escalate to *named* `canon/**` files only when `canon_active` is insufficient or the prose asserts a checkable fact `canon_active` does not cover. For the relational checks, consult the maintained state — `continuity/` and `characters/<id>/knowledge/` — plus targeted retrieval of exactly the named referents (a specific prior scene, a named canon file), never a full re-read. The three relational inputs are `required: false` because they may not be present yet — the M15/M14 writers may not have run, and a project may carry no canon file for a given asserted fact — **not** because a `short_story` lacks maintained state: a `short_story` has `continuity/story.md` and `knowledge/story.md` and this review reads them whenever they are present, blocking on nothing when they are absent.

## Behavior

Read all storyboard blocks for the scene in order. For each block, run the three **local** checks (1–3) against the corresponding prose range, and run the **relational** check (4) over the chapter as a whole against the maintained state + targeted retrieval. Record one entry per block in `reviewer-actions.md`.

### Output file format

The file begins with a single top-of-file `Reviewed-draft:` line naming the resolved `<latest-draft>` filename (e.g. `draft-v03.md`) — the draft this run actually read, so when a read-from override is in effect the stamp names that draft; the stamp lets `compliance_fix` detect stale annotations when a newer draft has been minted since this report was written. If the file does not exist, create it with the stamp. If the file exists and its top-of-file stamp equals `<latest-draft>`, append this run's per-scene sections beneath the existing content. If the file exists and its top-of-file stamp does not equal `<latest-draft>` — the recovery path when the human is regenerating after a stale-report blocker — the report is `regenerated`: **overwrite the whole file** with a fresh top-of-file stamp, and the prior run's findings against the superseded draft are `discarded`. See the general freshness contract in `agents/orchestrator.md`'s Artifact-state section (the report→fix freshness invariant is its canonical worked instance). On the append path, new items' review-ids must not collide with any already in the file — same epoch, same uniqueness scope: when a block already has anchored violations from an earlier run against this draft, continue that block's `v<KK>` ordinals rather than restarting at `v01` where a collision would result.

Below the top-of-file stamp, begin each scene's section with a dated header:

```markdown
Reviewed-draft: draft-vNN.md

## Compliance Report — Scene [scene-id], [date]
```

If a block is fully clean across all three checks, record a single line:

```markdown
### Block NNN — CLEAN
```

CLEAN blocks are not review units: exactly one line, no anchor, no decision fields. They never appear in the review-unit count.

If a block has any violation, record only the violations — not the passing items. Each violation line is one review unit: it gets a `<!-- review-id: ... -->` anchor on its own line immediately above it, and blank `- Decision:` / `- Decision-note:` fields nested one level below it:

```markdown
### Block NNN
<!-- review-id: compliance:[scene-id]:block-NNN-v01 -->
- DEGRADED (must_preserve): [Item label] — [one sentence: what was required, what is wrong with what was written]. Prose: "[quote]"
  - Decision:
  - Decision-note:
<!-- review-id: compliance:[scene-id]:block-NNN-v02 -->
- MISSING (must_preserve): [Item label] — not found in prose range
  - Decision:
  - Decision-note:
<!-- review-id: compliance:[scene-id]:block-NNN-v03 -->
- NOT ENACTED (character_state_out): [CharacterName] — closing state "[spec]" not reached
  - Decision:
  - Decision-note:
<!-- review-id: compliance:[scene-id]:block-NNN-v04 -->
- VIOLATED (concealment_from_reader): "[quote]" names or implies [what it reveals]
  - Decision:
  - Decision-note:
<!-- review-id: compliance:[scene-id]:block-NNN-v05 -->
- VIOLATED (concealment_from_characters): [Character A]'s [X] accessible to [Character B] — "[quote]"
  - Decision:
  - Decision-note:
<!-- review-id: compliance:[scene-id]:block-NNN-v06 -->
- INCONSISTENT (canon): [Mechanic label] — "[quote]" violates rule: "[rule as stated in block]"
  - Decision:
  - Decision-note:
<!-- review-id: compliance:[scene-id]:block-NNN-v07 -->
- INCONSISTENT (chronology): [subject] — "[quote]" contradicts the maintained fact [what the referent fixes]. [defect: <type>] [ref: <referent>]
  - Decision:
  - Decision-note:
```

Use only the violation types that apply. Do not record passing items alongside violations.

A **relational** finding (Check 4) uses the same review-unit shape but its violation line carries the greppable trailing tag ` [defect: <type>] [ref: <referent>]` — `<type>` ∈ {prose, storyboard, state, canon, missing-context} and `<referent>` one of `continuity/book-N.md#co-NN`, `characters/<id>/knowledge/book-N.md#kn-NN`, `reveals.md#rv-NN`, or `canon/<file>` + a quote — the canonical surface form defined in `agents/review-context.md`. The **local** findings (Checks 1–3) do not carry the tag. The anchor / `review-id` / `Decision:` scheme is identical for both (`agents/review-grammars.yaml` `compliance:` family).

The review-id follows the `compliance:` family segment grammar in `agents/review-grammars.yaml`: short_story form `compliance:<scene-id>:block-<NNN>-v<KK>`, book form `compliance:<book-id>:<chapter-id>:<scene-id>:block-<NNN>-v<KK>`. `<NNN>` is the storyboard block number and `<KK>` the violation's ordinal within that block's entry — both already in the report; the location segments are derivable from the artifact's resolved path. Emit `Decision:` and `Decision-note:` blank — they belong to the human, and a blank `Decision:` means the unit is pending review. The fixture `examples/review/reviewer-actions.md` shows the exact target shape.

Work block by block for the **local** checks (Must-Contain, Must-Not-Contain, Canon-as-stated): evaluate each block against its own prose range and do not collapse those findings across blocks. The **relational** check (Check 4) is different: it evaluates the **chapter as a whole** against maintained state + targeted retrieval, because the contradictions it catches are cross-scene by construction. **Scene-blind sharding is forbidden for relational checks** — splitting one chapter's continuity / recap / timeline into scene-blind shards makes every cross-scene contradiction structurally invisible (`NOTES.md:42-46`). A relational finding is still emitted as a per-block review unit anchored to the block whose prose carries it; "chapter-whole" describes the evaluation, not the anchoring.

#### Check 1: Must-Contain

Source fields: `must_preserve`, `character_state_out`.

For each item in `must_preserve`: locate the prose that enacts it. If absent or degraded, record a violation. If present, do not record it.

For each character in `character_state_out`: confirm the prose has moved that character to the stated closing state. If the closing state is not enacted, record a violation. If enacted, do not record it.

#### Check 2: Must-Not-Contain

Source fields: `concealment_from_reader`, `concealment_from_characters`.

For each item in `concealment_from_reader`: scan the prose for any naming, explaining, or clarifying of the forbidden fact. If found, record the violating quote and identify what it reveals. If clean, do not record it.

For each item in `concealment_from_characters`: scan for any moment where Character A's hidden information becomes accessible to Character B through dialogue, action, or narratorial slip. If found, record it. If clean, do not record it.

#### Check 3: Canon

Source field: `canon_active`.

For each canon mechanic listed: confirm the prose is consistent with the rule as stated in the block. Consult the block's `canon_active` first; escalate to the *named* `canon/**` file only when `canon_active` is insufficient or the prose asserts a checkable fact `canon_active` does not cover — the retrieval strategy of `agents/review-context.md`, not a corpus scan. (Deep canon consistency against the maintained state is Check 4's job; here the concern is the prose against the mechanic as the block states it.)

If the prose enacts a mechanic in a way that the block's compliant/non-compliant examples would classify as non-compliant, record a violation. If consistent, do not record it.

#### Check 4: Relational consistency

Checks 1–3 are **local** — each block against its own prose range. This check is **relational**: it reads the chapter's prose against facts established **elsewhere** — the maintained state (`continuity/`, `characters/<id>/knowledge/`) plus targeted retrieval of the named referents the prose invokes. The classification, referent-identification, targeted-retrieval, precedence, and defect-taxonomy strategy is single-sourced in `agents/review-context.md` and is **not** restated here — this step consults it. Evaluate the chapter as a whole (see the partitioning rule above); never in scene-blind shards.

Apply the precedence rule by reference to `agents/review-context.md` (review tiebreak: **storyboard intent > distilled derived state > raw source**; reveal-timing carve-out: **canon > `reveals.md` > storyboard > prose**; authoring authority: **canon > continuity**). Assign each finding a defect type — prose / storyboard / state / canon / missing-context — by **which artifact is wrong under precedence**, per the taxonomy there (state spans `continuity/` + `knowledge/` + `reveals.md`).

Resolve each `knowledge/` *and* `continuity/` entry by unambiguous, latest-attempt-qualified provenance — its `story-position` for point-in-time reconstruction and its full attempt-qualified draft path for freshness. Treat any entry whose currency cannot be unambiguously resolved as **missing-context**, and any entry stamped in a **superseded (non-latest) attempt** as a **state** defect — surfaced, never silently trusted, so a false-fresh entry can never silently produce a relational finding. (The freshness model lives in `agents/characters.md` / `agents/continuity.md`; reference, don't restate.)

Run the relational sub-checks against the named referents:

- **Canon consistency.** Where the prose asserts a checkable world-fact, confirm it against `canon_active` first, escalating to the *named* `canon/**` file only when `canon_active` is insufficient or does not cover it. When the prose contradicts settled, **valid** canon, the prose is the wrong one (canon outranks) — label it **`prose`** so `compliance_fix` corrects the prose to conform. Reserve **`canon`** for when the canon artifact *itself* is at fault (internally contradictory, or a settled rule the prose exposes as needing revision), which `compliance_fix` routes to the canon file and never edits in prose; a block's `canon_active` merely under-stating a rule is a **`storyboard`** defect. (Per the taxonomy in `agents/review-context.md`.)
- **Character-knowledge / reveal-timing.** Check each block's `concealment_from_characters` against the maintained character-knowledge state in `characters/<id>/knowledge/`: prose that acts on knowledge a character was concealed from at that story position is a finding, cited to the `knowledge/…#kn-NN` entry.
- **Continuity fact-classes.** Check the prose against the maintained `continuity/` entries for the seven fact-classes — chronology, event-staging, location, possession, physical-condition, role, open-thread — **covering recalled-event-staging** (a remembered scene whose staging contradicts the maintained fact) **and recap fidelity** (a summary or quotation that contradicts the scenes that produced it). Cite the conflicting/supporting `continuity/…#co-NN` entry.

Emit each relational finding as a per-block review unit on the existing `compliance:` grammar (the `- INCONSISTENT …` shape above), its violation line carrying the ` [defect: <type>] [ref: <referent>]` tag. If the fact needed to judge is absent from every consulted source, label it `missing-context` and surface it as an open question rather than fabricating a verdict.

### At the end of the report

After all blocks, append a summary:

```markdown
### Summary

- Must-Contain violations: N
- Must-Not-Contain violations: N
- Canon violations: N
- Relational violations: N
- Blocks fully clean: N of N
- Review units emitted: N

[Any pattern-level observation — e.g. "violations cluster in blocks 011 and 050" — goes here. One or two lines only. Do not propose fixes.]
```

Do not propose fixes. The summary observation is a diagnostic, not a recommendation.

After the summary, append a report-level section — headed exactly `## Context consulted` — naming the specific maintained-state entries, chapters, and files this run actually read for its relational checks. It is a report-level `##` section (neither a `### Block ` container nor a `- ` review unit), the canonical audit surface defined in `agents/review-context.md`: at series scale the consulted set is a small named subset, and naming it is what makes the bounded relational check reproducible and auditable.

```markdown
## Context consulted

- continuity/book-1.md#co-03 (chronology — day-count anchor)
- characters/mara/knowledge/book-1.md#kn-07 (concealment — what Mara knew at scene start)
- canon/resonance.md (Resonance lag rule)
```

If the relational check consulted nothing (e.g. a `short_story` with no maintained state present), record a single `## Context consulted` heading with a `- none` line.

## Outputs

- `<chapter-folder>/drafts/<latest-attempt>/reviewer-actions.md` — the compliance report. Begins with a single top-of-file `Reviewed-draft: draft-vNN.md` line naming the `<latest-draft>` this report covers — the draft this run actually read; subsequent runs against the same draft append below, runs against a newer draft (recovery path) overwrite the file with a fresh stamp (the report is `regenerated`, the prior findings `discarded`). Then one `## Compliance Report — Scene [scene-id], [date]` header per scene-run, one `### Block NNN` entry per storyboard block (either a single `CLEAN` line — no anchor, no fields, not a review unit — or a list of violations, each carrying its `<!-- review-id: ... -->` anchor immediately above the violation line and blank `- Decision:` / `- Decision-note:` fields nested below it; relational violations carry the ` [defect: <type>] [ref: <referent>]` tag on their violation line), a `### Summary` block per run tallying violations by check type (local and relational), reporting the review units emitted this run, and noting any pattern-level observation, and a report-level `## Context consulted` section naming the maintained-state entries / chapters / files the relational checks read. The `Reviewed-draft` stamp is required so `compliance_fix` can detect stale annotations against a newer draft. The file is the human review artifact: the human records decisions in each unit's `Decision:` field per the `compliance:` family grammar in `agents/review-grammars.yaml` before `compliance_fix` runs.

## Anti-Patterns

**Fixing during reporting.** This step is read-only. If the reporting pass rewrites anything, it has failed. Prose changes are the `compliance_fix` step's job.

**Recording passing items.** Clean checks are not recorded. A block entry is either one line (`CLEAN`) or a list of anchored violations only. Passing items alongside violations inflate the file and defeat the purpose of the format.

**Filling decision fields.** `Decision:` and `Decision-note:` are emitted blank. They belong to the human; a report that pre-fills a decision — however obvious — has decided instead of reported, and a blank `Decision:` is the only honest signal that a unit is still pending.

**Anchoring CLEAN blocks.** A CLEAN block is one line, no anchor, no fields. An anchor turns it into a countable review unit and inflates the ledger with items that need no decision.

**Collapsing local findings across blocks.** The **local** checks (Must-Contain, Must-Not-Contain, Canon-as-stated) are reported block by block; pattern-level observations belong only in the summary. The **relational** check evaluates the chapter as a whole, but each relational finding is still emitted as its own per-block review unit anchored to the block whose prose carries it — chapter-whole evaluation, per-block anchoring.

**Scanning the corpus instead of targeted retrieval.** A relational check names the specific referents the prose invokes and fetches only those (the maintained-state entry, the named canon file, the specific prior scene) — never a full re-read (`agents/review-context.md`). For a canon check, `canon_active` comes first; reach for a named `canon/**` file only when `canon_active` is insufficient or does not cover the asserted fact. If a block's `canon_active` is genuinely insufficient *and* no named canon file resolves the question, that is itself a finding to note (`missing-context`, or a `storyboard` defect where the block under-specifies), not a reason to scan.

## Open questions handling

If the step cannot complete because of missing or ambiguous inputs (e.g., no storyboard files, no draft, or a storyboard block whose fields cannot be parsed), append the blocker to the project root `open-questions.md` and exit without recording completion in `pipeline-state.md`. Do not fabricate inputs and do not write a partial report. The next dispatcher invocation will re-run this step after the human resolves the blocker. On a successful run, the step's final action is to mark its own step line `[x]` in `pipeline-state.md` and update `last_updated`.
