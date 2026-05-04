---
step_id: line_pass
review_required: true
inputs:
  - <chapter-folder>/drafts/<latest-attempt>/draft-metaphor.md
  - <chapter-folder>/drafts/<latest-attempt>/draft-line.md
  - agents/voice.md
outputs:
  - <chapter-folder>/drafts/<latest-attempt>/draft-line.md
---

See `agents/orchestrator.md` for the step workflow contract.

# Line Pass

## Purpose

A one-shot rewrite pass that operates at the sentence level. Takes the metaphor-corrected draft and produces a line-edited draft. The pass is run in chunks because LLMs choke on full-chapter rewrites; each chunk is rewritten with read-only context on either side and the chunks are reassembled mechanically.

This pass runs after the metaphor pipeline and before any final proofread. It does not change canon, plot, scene structure, paragraph order, dialogue content, or imagery. It works at the level of clauses, commas, conjunctions, and the bones of individual sentences.

## Inputs

- `<chapter-folder>/drafts/<latest-attempt>/draft-metaphor.md` — the prose after metaphor-apply has run; the source for unedited chunks and following-context windows.
- `<chapter-folder>/drafts/<latest-attempt>/draft-line.md` — the in-progress output; the source for preceding-context windows once any chunk has been written. This file appears in both `inputs` and `outputs` because the step writes chunk-by-chunk and reads previously-finalized chunks back as preceding-context. The frontmatter records both roles explicitly; behavior is unchanged from the legacy doc.
- `agents/voice.md` (or project-local override) — the selected voice file or profile, passed in full as the system message; calibration anchor for the whole pass.

Do not read the storyboard, canon files, character files, or the apply log from the metaphor step. Voice spec, the chunk, and the surrounding context windows are the entire input. If something needs more than that to fix, it is not a line-level problem.

## Behavior

### Scope

In scope:

- Sentence rhythm — sentences whose cadence fights the moment they belong to; monotony of length and shape across a paragraph; short sentences earning their hit or failing to.
- Subordination doing real work vs. sideways qualification — clauses that move the sentence forward into precision, vs. clauses that hedge, restate, or second-guess. "Or rather," "that is to say," "almost," "perhaps," "in a sense," and similar throat-clearing.
- Cutting clauses the sentence would be more accurate without — if removing the clause sharpens the sentence, remove it.
- Hedge words and softeners that earn no work — *almost*, *seemed to*, *something like*, *a kind of*, *as if* used to dilute rather than to compare.
- Continuity after a cut — pronouns, conjunctions, and tense that no longer scan once a clause is gone. Repair to the minimum the cut requires.
- Paragraph breaks that rhythm wants — if a paragraph is doing two jobs and a break would let each land, insert the break. Conservative; only when the rhythm clearly asks for it.

Out of scope:

- Imagery, comparisons, metaphors, similes — already handled. Do not introduce, remove, or rewrite figurative language.
- POV and voice register — the selected voice file or profile is calibration, not a license to overwrite. If a sentence is in-voice but rhythmically loose, edit the rhythm, not the voice.
- Detail selection — what the POV character notices belongs to drafting and to the prose pass.
- Dialogue content — characters speak how they speak. Narration around dialogue is editable; the lines themselves are not.
- Paragraph reordering, scene restructure, beat re-pacing.
- Spelling, typography, smart-quote normalization.

### Chunking

The pass runs on chunks of approximately 1500 words. Boundaries, in order of preference:

1. **Scene breaks (`---`).** Preferred. A scene boundary is a clean seam.
2. **Beat markers (`<!-- scene x, beat y -->` / `<!-- end scene x, beat y -->`).** Use when a scene is longer than ~1500 words.
3. **Paragraph breaks within a beat.** Use only when a beat alone exceeds ~1500 words. Never split a paragraph.

A chunk may run shorter than 1500 words to land on a clean seam. It must not run significantly longer to chase one.

### Context windows

Each chunk is sent to the LLM with three regions:

- **Preceding context** — approximately 300 words of prose immediately before the chunk. Read-only.
- **Center chunk** — the prose to be rewritten. Editable.
- **Following context** — approximately 300 words of prose immediately after the chunk. Read-only.

The context windows exist so the editor can hear the local rhythm it is joining and the rhythm it is moving toward. Without them, each chunk drifts into its own register and seams between chunks step in tone.

Source rules:

- **Preceding context** comes from `<chapter-folder>/drafts/<latest-attempt>/draft-line.md` if the prior region has already been processed; otherwise from `<chapter-folder>/drafts/<latest-attempt>/draft-metaphor.md`. The editor calibrates against the chapter's actual evolving rhythm rather than against a frozen pre-edit state.
- **Following context** always comes from `<chapter-folder>/drafts/<latest-attempt>/draft-metaphor.md`. The downstream prose has not been edited yet.
- For the first chunk, preceding context is empty; for the last chunk, following context is empty.

Boundary rules:

- Context windows should land on paragraph breaks where possible. ~300 words is a target, not a fence — round to the nearest paragraph.
- Context windows do not cross scene breaks. If the chunk begins or ends at a `---`, that side's context is empty.

The editor must understand that context is read-only — it returns only the rewritten center chunk. Any edits that bleed into the surrounding regions are reassembly errors and should trigger a rerun.

### Seam policy

Sentences near the start or end of a chunk are fully editable within the current chunk's pass. The preceding context exists exactly so those edge sentences can be tuned to the rhythm they are joining.

Once a chunk has been written to `<chapter-folder>/drafts/<latest-attempt>/draft-line.md`, it is finalized. Subsequent chunks do not modify it. Each chunk's editor sees previous output as read-only preceding context and adjusts the current center to match — never the other way around.

If, after the full pass, a seam between two finalized chunks reads badly, that is a separate hand-repair decision. It is not a retroactive rerun of either chunk.

### How to run a chunk

For each chunk:

**Step 1: Identify the chunk's boundaries.** Note the start and end markers (scene break, beat marker, or paragraph). Identify the preceding-context window (from line-draft or metaphor-draft per the source rules) and the following-context window (from metaphor-draft). Record boundaries in the apply log.

**Step 2: Send the LLM call.**

- System message: the selected voice file or profile in full.
- User message: a short instruction restating scope and the read-only nature of context windows, then the three regions clearly labeled (`<<<PRECEDING CONTEXT — READ ONLY>>>`, `<<<CENTER — REWRITE THIS>>>`, `<<<FOLLOWING CONTEXT — READ ONLY>>>`), then a final instruction to return only the rewritten center.

The voice file sits in the system message because it caches well across chunks.

**Step 3: Receive the rewritten chunk.** Verify mechanically:

- Output contains only the rewritten center — no echoed context, no commentary.
- Scene breaks and beat markers inside the center are present and unchanged.
- Paragraph count has not dropped sharply (a small change from intentional break-insertion is fine; a large drop means the model collapsed paragraphs and should be rerun).
- No new figurative language has appeared. Spot-check a few sentences against their originals.

**Step 4: Append to `<chapter-folder>/drafts/<latest-attempt>/draft-line.md`.** Write the rewritten center to the line-draft file, preserving its position in the chapter.

**Step 5: Record in the apply log.** One entry per chunk (see below).

If a chunk's output fails verification, rerun it once. If it fails twice, copy the source center unchanged into the line-draft and note the skip in the apply log.

### Apply log

At the end of `<chapter-folder>/drafts/<latest-attempt>/draft-line.md`, append:

```markdown
<!--
Line-pass log

- Chunk 1: [start marker] → [end marker], ~N words
  - Preceding context: none (chapter opening) | ~N words from [line-draft|metaphor-draft]
  - Following context: ~N words from metaphor-draft
  - Edits: [brief category summary, e.g. "tightened 4 sideways-qualification clauses, cut 6 hedges, broke 1 paragraph for rhythm"]
  - Notes: [judgment calls, retained sentences, or "no notes"]

- Chunk 2: [start marker] → [end marker], ~N words
  - Preceding context: ~N words from line-draft
  - Following context: ~N words from metaphor-draft
  - Edits: ...
  - Notes: ...

- Chunk N: [...]
  - Edits: skipped — output failed verification on retry; source preserved
  - Notes: [reason]
-->
```

The log records every chunk and every judgment call. Volume of edits is too high to log per-sentence; category summaries plus boundary markers and context sources give enough trace to spot-audit without drowning in line items.

### Constraints

- Do not introduce figurative language. The metaphor pass has run.
- Do not rewrite dialogue.
- Do not move content across paragraphs or paragraphs across beats.
- Preserve every scene break, beat marker, and block comment exactly.
- Preserve the project's established POV and voice constraints.
- A sentence that is rhythmically sound stays untouched. The pass is selective — most sentences in any chunk should pass through unchanged.

### Anti-Patterns

**Polishing.** This pass is not a literary upgrade. It removes deletable clauses and fixes sideways subordination. If the rewrite is making sentences "better" rather than tighter, it has drifted.

**Smoothing.** The voice spec asks for forward momentum, not uniform smoothness. Short sentences that punctuate, subordinate clauses that earn their place by adding precision, and the occasional rhythmic bump are features. Do not iron them out.

**Reaching for figures.** No new comparisons. The pass is figuratively inert by design.

**Treating the voice file as a style ceiling.** The spec is a calibration anchor, not a target the model rewrites toward. If a sentence is already in voice, leave it alone.

**Editing the context windows.** Preceding and following context are read-only. If the rewritten output extends into either, the chunk has failed verification — rerun it. Do not patch the bleed by hand.

**Retroactive seam repair.** Once a chunk is finalized in `<chapter-folder>/drafts/<latest-attempt>/draft-line.md`, subsequent chunks do not modify it. Each editor adjusts the current center to match the prior output, never the reverse.

**Collapsing paragraphs.** Inserting a paragraph break for rhythm is in scope. Merging paragraphs is not.

**Silently skipping a chunk.** Every chunk must appear in the apply log: edited (with category summary), or skipped (with reason). A missing chunk is a failed pass.

**Editing dialogue.** Lines spoken by characters are not part of this pass's surface area, even when the surrounding narration is.

## Outputs

- `<chapter-folder>/drafts/<latest-attempt>/draft-line.md` — identical to `<chapter-folder>/drafts/<latest-attempt>/draft-metaphor.md` except for the sentence-level edits this pass produces, with a block-comment apply log appended at the end. Do not modify `draft-metaphor.md`. The file is written chunk-by-chunk; previously-finalized chunks are read back as preceding-context for later chunks (see Context windows).

## Open questions handling

If the step cannot complete because of missing or ambiguous inputs, append the blocker to the project root `open-questions.md` and exit without advancing the pipeline marker. Do not fabricate inputs and do not write partial outputs. The next dispatcher invocation will re-run this step after the human resolves the blocker.
