# Storyboarding

Translates scene-level intent into beat-level plans that [drafting](drafting.md) can execute without opening any other file.

## Inputs

- `xx-yy-scene-list.md` — scene list for the chapter
- `xx-yy-summary.md` — chapter summary
- `xx-yy-storyboards-planning.md` — storyboard planning notes
- `characters/*/knowledge` — applicable information covering what each character knows in the scene
- Any canon or character reference files linked from the scene list

## Output

One storyboard file per storyboard block: `xx-yy-zzz-storyboard.md`.

## What a Storyboard Block Is

A storyboard block is YAML frontmatter followed by a beat description paragraph.

The YAML frontmatter carries all structured information the LLM needs to make decisions about character behavior, concealment, pacing, and canon constraints. The beat description paragraph captures dramatic intent that the structured fields cannot hold. Neither is sufficient alone.

For field definitions see `agents/storyboard-schema.md`.

The beat description should read as a director's note — plain language, present tense, focused on dramatic intent. It must answer what happens, what is felt, and what the prose must accomplish that the YAML fields cannot capture.

## Independent Draftability

Every block produced must be self-contained enough that drafting can run on it using only `agents/voice.md` and the block itself.

This is a quality check on the storyboard, not a constraint on the drafter. If a block cannot be drafted without consulting the scene list, a character file, or a canon document, the block is incomplete. The missing information belongs in `canon_active`, `character_state_in`, or the beat description.

---

## Anti-Patterns

**Writing finished prose during storyboarding.** Drafting is for writing the novel. Storyboarding is for setting up drafting for success. If storyboarding output contains subordinate clauses doing atmospheric work, sensory detail, or voice, it has drifted into drafting. Regenerate the block, not the prose.

**Vague beat descriptions.** "Louise and Françoise talk" is not a beat description. The paragraph must answer what happens, what is felt, and what the prose must accomplish that the YAML fields cannot capture.

**Empty concealment fields.** `concealment_from_reader` is the most commonly skipped field and the most consequential for series-long reveal integrity. An empty field is only correct after explicitly confirming the beat contains no active canon guardrails. Default to filling it.

**Word targets instead of pace signals.** The `pace` field — `compressed`, `measured`, or `expansive` — is the correct way to signal how much room the beat earns. Pace is a tempo instruction, not a count. Do not write target word counts into the beat description.
