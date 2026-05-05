---
character_id: <snake_case_id>
name: <Display Name>
status: stub | canonical
edit_policy: editable | careful_edit | propose_only | locked
story_role: <one phrase: protagonist | major supporting | supporting | minor | etc.>
first_appearance: <book_n/ch_xx, or TBD>
pov_eligible: true | false
tags: [<tag>, <tag>]
review_on_change:
  - <relative path to file that should be reviewed if this profile changes>
change_affects:
  - <concrete downstream consequence>
---

# <Character Name>

<!--
This template is for character profiles. Fill in what is known. Use:
- `TBD` for fields where the answer exists or will exist but hasn't been decided yet.
- `open question (ref: <id>)` for unresolved fields significant enough to track in the project's open-questions.md.
- `n/a` for fields that genuinely do not apply to this character.

Sections are marked **mandatory** or **optional**. Optional sections may be omitted entirely for minor characters; the empty header doesn't need to remain.

Mandatory: One-line summary, Narrative function, Core identity, Essence, Voice and presence, Continuity constraints, Open questions.

Optional: Background, Capabilities, Motivations by timescale, Internal conflicts, External conflicts, Relationships (or How they relate to other characters), Secrets, Arc, Plot utility, What a writing LLM needs to know.

Major and POV-eligible characters should generally have all optional sections filled. Supporting characters fill optional sections selectively. Minor or single-appearance characters may omit most optional sections entirely.
-->

## One-line summary

**Mandatory.** A single sentence capturing this character's essential function in the story. Not a description of their personality or background — a statement of what they do for the narrative.

## Narrative function

**Mandatory.** Why this character exists in the story. Cover:

- Primary role in the story.
- What pressure they uniquely bring into scenes.
- What breaks if this character is removed.

For major characters, also cover why the story specifically needs this character — what thematic or structural work only they can do.

## Core identity

**Mandatory.** Surface facts. Cover:

- Age (and apparent age if different).
- Species / type (human, magical girl, other).
- Occupation / social role.
- Home / base of operations.
- Affiliations.
- Status in the public world / status in any hidden world the story tracks.

## Essence

**Mandatory.** The character's interior architecture. Use these specific labels — they map to a deliberate theory of character and are referenced consistently across the project:

- **Central desire.** What they actively want. Not what they should want.
- **Central fear.** What they are organized to avoid.
- **Misbelief.** A false thing they believe about themselves or the world. Often the engine of their arc.
- **Wound / formative damage.** What happened to them that produced the misbelief.
- **Greatest strength.** Often a virtue earned through the wound.
- **Greatest flaw.** Often the same trait as the strength, viewed from the cost side.
- **Default coping strategy.** What they do when stressed or uncertain.
- **Moral line they will not cross.**
- **Moral line they might cross under pressure.**

For minor characters, several of these may be `TBD` or `n/a`. The labels stay even when the content doesn't yet exist.

## Voice and presence

**Mandatory.** How the character occurs in the world. Cover:

- **Surface personality.** How they read to people who don't know them.
- **Private personality.** Who they are when not performing.
- **Social mask.** What strategy of self-presentation they use.
- **Sense of humor.** Distinctive enough to be a character signature, or absent.
- **Speech patterns.** Concrete observations about how they talk — sentence length, vocabulary, hedging, register, distinctive constructions.
- **Physical presence.** How they take up space.
- **Tells, habits, mannerisms.** Specific small behaviors a careful reader would notice.

If the character changes register significantly across the story (e.g., before/after a major shift), split the relevant fields into phases.

## Background

**Optional.** Useful for characters whose history shapes their on-page behavior. Cover:

- Family.
- Upbringing.
- Key past events.
- Education / training.
- Prior contact with the supernatural (if relevant to the project).
- Important losses.
- Important loyalties.

## Capabilities

**Optional. Mandatory for any character with supernatural abilities or specialized skills.** Cover:

- Core competencies.
- Special skills.
- Supernatural abilities — primary power, weapon, combat style, synergies with other characters.
- Limits and costs of those abilities.
- Vulnerabilities.
- Resources they can access.

## Motivations by timescale

**Optional. Recommended for protagonists and major supporting characters.**

- Immediate.
- Mid-range.
- Long-range.

## Internal conflicts

**Optional. Recommended for protagonists and major supporting characters.** Tensions inside the character: want vs. need, loyalty vs. truth, identity vs. role, etc. Each as a brief paired tension.

## External conflicts

**Optional. Recommended for protagonists and major supporting characters.** Cover:

- Main antagonistic force.
- Social obstacles.
- Institutional obstacles.
- Supernatural obstacles.
- Self-created obstacles.

## Relationships

**Optional. Mandatory for any character with significant cross-character dynamics.** Use the structured per-relationship format:

### <Other character's name>

- **Dynamic.** The shape of the relationship.
- **What this character wants from the other.**
- **What this character fears from the other.**
- **Hidden truth in the relationship.** What one or both parties don't fully see.
- **Arc direction.** How the relationship changes across the story.

Repeat for each significant relationship.

For groups or factions rather than individuals, the same structure applies but at the group level.

## Secrets

**Optional. Recommended for protagonists and any character with hidden information that drives plot.**

- What this character is hiding.
- What is being hidden from this character.
- What they suspect.
- What they believe incorrectly.
- What would destroy them if revealed.

## Arc

**Optional. Mandatory for protagonists. Recommended for any character whose state changes meaningfully across the book or series.**

- Starting state.
- Ending state.
- What changes.
- What does not change.
- Key turning points.
- Failure mode (the version of the arc that doesn't work).
- Success mode (the version of the arc that lands).

## Plot utility

**Optional. Recommended for protagonists and major supporting characters.**

- Best scene types for this character.
- Worst scene types for this character.
- What kinds of decisions only they can make.
- What information they are well positioned to reveal.
- What information they should never conveniently know.

## What a writing LLM needs to know

**Optional. Strongly recommended for any POV-eligible character.** Prose-level craft notes about how to write the character. Distinct from what's true about them — this is guidance for the drafter on register, tone, common mistakes, and what to preserve. Things the surrounding sections imply but don't state outright.

## Continuity constraints

**Mandatory.** The single most important section for downstream LLM use. Storyboarding and drafting workflows reference this section to avoid drift. Use this three-part structure:

- **Immutable facts.** Things that must remain true across the story. Bullet list. Can grow over time as the story commits to more.
- **Forbidden contradictions.** Specific things that must never happen to this character or be written about them. Bullet list.
- **Timing constraints.** When in the story specific things must or must not happen. Bullet list.

This section is deliberately invitational — add to it whenever a scene commits to something the character must carry forward.

## Open questions

**Mandatory.** Bullet list of unresolved questions about this character. Each question that is significant enough to track formally should also have an entry in the project's `open-questions.md` and be referenced from this section as `open question (ref: <id>)`. Less significant unresolved details can stay here as plain text, marked `TBD` if they appear inline in earlier sections.

This section is the character extraction workflow's primary output destination — when a story plan implies a character without specifying details, the missing details land here for the human to resolve.
