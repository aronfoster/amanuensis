---
step_id: storyboarding
review_required: true
inputs:
  - <chapter-folder>/scene-list.md
  - <chapter-folder>/summary.md
  - <chapter-folder>/storyboards-planning.md
  - characters/<character-id>/knowledge/*.md
  - canon/**/*.md
outputs:
  - <chapter-folder>/storyboards/<scene-id>-<beat-id>-storyboard.md
---

See `agents/orchestrator.md` for the step workflow contract.

# Storyboarding

## Purpose

Translates scene-level intent into beat-level plans that the drafting step can execute without opening any other file. Each storyboard block is a self-contained unit of dramatic intent and structured guardrails — the bridge between scene-list planning and prose.

## Inputs

- `<chapter-folder>/scene-list.md` — scene list for the chapter.
- `<chapter-folder>/summary.md` — chapter summary.
- `<chapter-folder>/storyboards-planning.md` — storyboard planning notes (if present).
- character knowledge files under `characters/<character-id>/knowledge/` — applicable information covering what each character knows in the scene.
- Any canon or character reference files linked from the scene list.

## Behavior

Produce one storyboard file per storyboard block at `<chapter-folder>/storyboards/<scene-id>-<beat-id>-storyboard.md`.

### What a Storyboard Block Is

A storyboard block is YAML frontmatter followed by a beat description paragraph.

The YAML frontmatter carries all structured information the LLM needs to make decisions about character behavior, concealment, pacing, and canon constraints. The beat description paragraph captures dramatic intent that the structured fields cannot hold. Neither is sufficient alone.

For field definitions see `agents/storyboard-schema.md`.

Populate `reader_takeaway` for every block — what the reader must understand, feel, or infer by the beat's end. The field is defined in `agents/storyboard-schema.md`; like `concealment_from_reader`, it defaults to filled.

The beat description should read as a director's note — plain language, present tense, focused on dramatic intent. It must answer what happens, what is felt, and what the prose must accomplish that the YAML fields cannot capture.

### Independent Draftability

Every block produced must be self-contained enough that drafting can run on it using only the selected voice file or profile and the block itself.

This is a quality check on the storyboard, not a constraint on the drafter. If a block cannot be drafted without consulting the scene list, a character file, or a canon document, the block is incomplete. The missing information belongs in `canon_active`, `character_state_in`, or the beat description.

---

### Anti-Patterns

**Writing finished prose during storyboarding.** Drafting is for writing the novel. Storyboarding is for setting up drafting for success. If storyboarding output contains subordinate clauses doing atmospheric work, sensory detail, or voice, it has drifted into drafting. Regenerate the block, not the prose.

**Vague beat descriptions.** "The characters talk" is not a beat description. The paragraph must answer what happens, what is felt, and what the prose must accomplish that the YAML fields cannot capture.

**Empty concealment fields.** `concealment_from_reader` is the most commonly skipped field and the most consequential for series-long reveal integrity. An empty field is only correct after explicitly confirming the beat contains no active canon guardrails. Default to filling it.

**Empty reader_takeaway.** `reader_takeaway` is the positive counterpart to `concealment_from_reader` — the beat's comprehension target. An empty field is only correct after explicitly confirming the beat genuinely asks nothing of the reader's understanding. Default to filling it.

**Word targets instead of pace signals.** The `pace` field — `compressed`, `measured`, or `expansive` — is the correct way to signal how much room the beat earns. Pace is a tempo instruction, not a count. Do not write target word counts into the beat description.

## Outputs

- `<chapter-folder>/storyboards/<scene-id>-<beat-id>-storyboard.md` — one file per storyboard block. Each file is YAML frontmatter (per `agents/storyboard-schema.md`) followed by a beat description paragraph. The file name encodes the scene id and beat id; resolve `<chapter-folder>` per `agents/project-layouts.md`.

## Open questions handling

If the step cannot complete because of missing or ambiguous inputs, append the blocker to the project root `open-questions.md` and exit without advancing the pipeline marker. Do not fabricate inputs and do not write partial outputs. The next dispatcher invocation will re-run this step after the human resolves the blocker.
