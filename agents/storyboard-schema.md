# Storyboard Block Schema

Examples in this document are illustrative. Some use names and constraints from the project that originally produced the workflow; replace them with project-local equivalents when applying the schema elsewhere.

Each storyboard file contains one or more blocks. Each block is independently
draftable — it should contain everything an LLM needs to write its prose without
access to any other file.

Structure: YAML frontmatter containing only short structured fields, followed by
markdown sections for all text content.

---

## The governing discipline: specification, not prose

Every field in this schema is specification. Storyboarding plans what the beat must contain and what it must do; drafting writes the sentences. If a field in a storyboard block could appear unedited in the novel, it is mis-filled.

The distinction is testable, not a matter of taste:

- **Specification:** names a phenomenon, constraint, or mechanic in the fewest words that make it actionable. Reads like a director's note, a props list, or a technical requirement.
- **Prose (do not use):** uses subordinate clauses to do sensory work, reaches for atmosphere, or lets sentence rhythm carry meaning. Reads like the novel.

Example, same content, both registers:

- **Specification:** "Louise's grip on the fork bends it. She hides the bent fork before the adults look back at her hands."
- **Prose (do not use):** "The silver bent between her fingers like something living, and she folded her palm closed around it before her mother's glance came back to her plate."

The specification tells the drafter what must occur and what must not be seen. The prose *writes the scene.* Storyboarding produces the first. Drafting produces the second.

Every field below is held to this discipline. A field that reads like prose — however good the prose — is rewritten.

---

## YAML frontmatter

```yaml
---
scene_ref: "path/to/scene-list.md#scene-N"
date: "Month YYYY"
location: "Short location"
beat_index: N
pov: CharacterName
beat_type: compression
pace: measured
---
```

**beat_type options:**
- `compression` — narration covers time, summarizes experience, skips clock
- `action` — something physical happens in real time
- `interiority` — primary content is a character's internal state or reasoning
- `transition` — movement between spaces or states; the journey itself matters
- `reveal` — information arrives (to reader, to character, or both)
- `communion` — contact with supernatural presence, collective, or vision

**pace options:**
- `compressed` — short, fast; moves the reader through quickly
- `measured` — standard scene tempo
- `expansive` — room to breathe; the moment earns its length

YAML values stay short. No colons, no special characters, no prose fragments. All narrative content belongs in the markdown sections below.

---

## Character state in

List each named character's state as the beat opens. One line per character, up to three. Each entry names: emotional state, knowledge state, current objective. Only characters whose state will shape on-page behavior. Background staff do not get entries.

Field content is a status readout, not a character sketch.

- **Specification:** "Louise: exhausted, containing hairpin-surge residue, performing unremarkable for Françoise. Objective: get through dressing without a tell."
- **Prose (do not use):** "Louise stood still as the hairpin slid home, her body taut against the wrongness folded inside her ribs, her face a careful mask Françoise could not read."

## Character state out

List each character's state at beat close. Each entry must differ meaningfully from its state-in counterpart. If they match, the beat is not doing work — revise the beat, not the field.

Same discipline as state-in: readout, not sketch.

- **Specification:** "Louise: now carrying pre-manifestation body-signal she has no framework for. Rule 'do not be noticed' confirmed as reflex, not principle. Objective unchanged."
- **Prose (do not use):** "Louise emerged from the dressing with a new weight beneath her ribs, something that had not been there when she woke, and the old rule settled deeper into her bones."

## Concealment from characters

List what one character is hiding from another, or what a character is being deliberately misled about. Name the lie or the misreading; name what the misreader thinks is true. Leave empty only if no information is being actively withheld in this beat.

Field content is a list of deceptions, not a dramatization of them.

- **Specification:** "Louise hides from Françoise: the hairpin-surge sensation, recent bad sleep. Françoise misreads Louise's pallor as ordinary morning tiredness."
- **Prose (do not use):** "Louise let Françoise believe in the simple story of a tired princess, her secret curling safely behind her eyes as the woman's practiced hands moved over her hair."

## Concealment from reader

List what the narrative must not name, explain, or clarify yet in this beat. This field guards reveal timing and series-long canon integrity. It is the most important field and the most commonly skipped. Default to filling it. If uncertain, re-read the scene list's canon guardrails.

Field content is a list of forbidden namings, not a discussion of why.

- **Specification:** "Do not name: the hairpin sensation as magical, pre-manifestation, or power-related. Do not name: Louise's full name, title, country."
- **Prose (do not use):** "The reader should feel, without understanding, that something vast and other has begun to stir in the body of a girl whose name the narrative has chosen to withhold."

## Canon active

List the specific canon mechanics operating in this beat. Extract the rule or constraint — not a file path, not a summary of a source document. Where the beat involves vision or supernatural content, include one compliant example and one non-compliant example.

Field content is a rules list, not a lecture on the rules.

- **Specification:** "Pre-manifestation attunement (per cohorts-and-creation.md): lived signs allowed before first transformation. Forms permitted in this beat: sensory sharpening, body-level sensations Louise cannot locate or name. Compliant: cramped-folded feeling during dressing. Non-compliant: any vision content, any sensation Louise can interpret."
- **Prose (do not use):** "The canon of this world permits the young magical girl to feel the stirrings of her power before she knows what it is, and Louise's body, faithful to this rule, begins to whisper its coming change."

## Craft signal

Optional. One or two lines noting register, sensory emphasis, or sentence rhythm that is not already implied by beat_type and pace. Omit if the beat description makes the register obvious.

This field is the most common site of prose-drift. Write it as a note to the drafter, not as a sample of what you want the drafter to produce.

- **Specification:** "Compress the dressing ritual. No sensory inventory of the room. Hairpin-surge gets its own sentence, short."
- **Prose (do not use):** "The prose should move with the hush of morning routine, letting the surge break through only briefly, a minor chord in the melody of an ordinary day."

## Knowledge Delta

Optional. List what each character knows at the end of the beat that they did not know at the start. One line per character.

Field content is a diff, not a narration of learning.

- **Specification:** "Louise learns: her body can produce sensations she cannot locate or explain."
- **Prose (do not use):** "By the end of the dressing, Louise understood for the first time that her body had begun to keep secrets from her."

## Must Preserve

List the specific canon-mandated content, imagery, phenomena, gestures, or reveals that must appear in the drafted prose. Written as specifications.

A specification names: what the element is, what distinguishes it from adjacent possibilities, what canon it enacts, and any hard constraints on how it manifests. It does not write the sentence.

This field exists to protect canon-load-bearing content from compression, merging, and rewriting. Items here survive verbatim in the sense that *the specification* is preserved — not its exact wording. The drafter enacts the specification in prose of the drafter's own making.

Texture details — how Françoise phrases a greeting, which specific staff member is dispatched, exact sensory flavor — do not belong here. Those go in the Beat description as direction. Must Preserve is for what cannot drift without breaking canon or the chapter's dramatic core.

- **Specification:** "Hairpin-surge phenomenon, form: internal cramped-folded sensation, something that needs to open with nothing to point at. Not pain. Not located. She holds still because the hairpin requires it. Sensation does not fully recede when Françoise moves on."
- **Prose (do not use):** "Something folded inside her wanted to open, a locked door against a closing hand, and she held still beneath Françoise's work as the wrongness thrummed on beneath her skin."

If an entry reads as prose, rewrite it as specification.

## Beat

One paragraph of production notes, maximum five sentences. Direct the drafter: what happens, what the prose must accomplish, what the drafter must not do. Present-tense, plain language, no subordinate clauses doing sensory work.

The test: if a sentence could appear unedited in the novel, it is prose and belongs in the chapter draft (`<latest-draft>`), not in a storyboard.

- **Specification:** "Open with Louise alone, registering the dream as present but unexamined. Françoise and Miss Aubert arrive; dressing proceeds as ordinary household routine. Mid-routine, during the hairpin placement, the surge lands per Must Preserve. Louise delivers 'I slept fine' as a prepared lie. Close with her moving into the day."
- **Prose (do not use):** "Louise wakes with the dream still curled beneath her eyelids, and as Françoise's hands begin their ordinary work, something stranger waits beneath them, until at the careful setting of a hairpin the wrongness cracks through — and Louise, trained in stillness, gives it nowhere to go."

---

## Anti-patterns

All anti-patterns below are specific instances of the governing discipline above: specification, not prose.

- **Prose in any field.** If a field reads as prose — atmosphere, sensory work, sentence rhythm carrying meaning — rewrite it as specification. This applies to every field, not just Beat.
- **Craft signal as prose sample.** Craft signal is a note to the drafter, not a demonstration of the register the drafter should use.
- **File paths in Canon active.** Extract the content. The drafter has no access to those files.
- **Empty Concealment from reader.** Re-read the scene list's canon guardrails before leaving this blank. Default to filling it.
- **Character state that names only an emotion.** Name emotion, knowledge, and objective.
- **Character state out identical to state in.** The beat is not earning its place.
- **Concealment fields that duplicate each other.** Characters hiding from each other and the narrative hiding from the reader are different axes. Keep them separate.
- **Texture in Must Preserve.** That field protects canon-mandated content only. Movable flavor belongs in Beat as direction.
- **Colons or special characters in YAML values.** Keep frontmatter values short and quoted. All narrative content belongs in the markdown sections.
