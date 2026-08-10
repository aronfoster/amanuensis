---
character_id: <snake_case_id>
name: <Display Name>
edit_policy: editable | careful_edit | propose_only | locked
---

# [Character Name] Timeline

<!--
This is the character's chronological event record — character-relative truth, NOT a parallel
authority. It records events as this character experienced or understands them; objective facts
(what actually happened, world continuity) are deferred to canon/continuity (the M15 boundary).
It realizes the temporal character-state model defined in `agents/characters.md`
(## Temporal character-state model). See it for the rules; this template shows the shapes.

Entries are ordered chronologically. Each carries:
- `id:` — durable, file-scoped, minted once, never changed (tl-01, tl-02, …).
- `story-position:` — where the event is fixed in the story, canonical folder-style
  `<book-id>/<chapter-id>/<scene-id>` (short_story: `<scene-id>`). Pre-story events that
  predate any scene use `pre-story` and sort before the first scene.
- `committed-in:` — the accepted draft that committed the event (draft-vNN.md), where one applies.

Non-destruction (see agents/characters.md): a corrected event is never silently overwritten.
Move the superseded event to `## Corrected or superseded`, keeping its id, and record the
corrected event as its own new stamped entry under `## Events`.
-->

## Events

### [Short label, e.g. "Sent to the boarding house"]
- **id:** tl-01
- **story-position:** pre-story
- **committed-in:** —
- **event:** [One or two sentences, as this character experienced or understands it.]
- **notes:** [Optional. Cross-references, caveats, downstream implications.]

### [Short label]
- **id:** tl-02
- **story-position:** book1/chapter01/scene03
- **committed-in:** draft-v03.md
- **event:** [What happened, character-relative.]
- **notes:** —

---

## Corrected or superseded

<!--
Non-destruction invariant. When a later scene reveals an earlier recorded event was
misunderstood or wrong, move the superseded entry here (keeping its id) and add the
corrected event as a new entry under ## Events above.
-->

### [Short label]
- **id:** tl-02
- **held:** book1/chapter01/scene03 to book1/chapter04/scene02
- **committed-in:** draft-v09.md
- **superseded-by:** tl-06
- **what changed:** [Brief explanation of the correction.]
