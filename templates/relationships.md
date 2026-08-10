---
character_id: <snake_case_id>
name: <Display Name>
edit_policy: editable | careful_edit | propose_only | locked
---

# [Character Name] Relationships

<!--
This is the character's relationship dynamics — character-relative truth, NOT a parallel
authority. It records how THIS character reads each relationship; objective facts about the
other party or the world are deferred to canon/continuity (the M15 boundary). It realizes the
temporal character-state model defined in `agents/characters.md` (## Temporal character-state
model). See it for the rules; this template shows the shapes.

Each entry carries:
- `id:` — durable, file-scoped, minted once, never changed (rel-01, rel-02, …).
- `story-position:` — where the dynamic is established or last shifted, canonical folder-style
  `<book-id>/<chapter-id>/<scene-id>` (short_story: `<scene-id>`).
- `committed-in:` — the accepted draft that committed the dynamic (draft-vNN.md).

Non-destruction (see agents/characters.md): a changed loyalty or dynamic never overwrites the
prior one. Move the superseded dynamic to `## Superseded dynamics`, keeping its id, and record
the new dynamic as its own stamped entry under `## Current dynamics`.
-->

## Current dynamics

### <Other character or faction>
- **id:** rel-01
- **story-position:** book1/chapter01/scene02
- **committed-in:** draft-v03.md
- **dynamic:** [The shape of the relationship as this character reads it.]
- **power balance:** [Who holds leverage, and over what.]
- **loyalty:** [Where this character's loyalty stands, and how firmly.]
- **misunderstanding:** [What this character doesn't see, or has wrong, about the other.]
- **notes:** [Optional.]

### <Other character or faction>
- **id:** rel-02
- **story-position:** book1/chapter02/scene05
- **committed-in:** draft-v04.md
- **dynamic:** [...]
- **power balance:** [...]
- **loyalty:** [...]
- **misunderstanding:** [...]
- **notes:** —

---

## Superseded dynamics

<!--
Non-destruction invariant. A fractured loyalty or reversed dynamic supersedes a prior one
non-destructively: move the prior entry here (keeping its id, citing held-from/to positions)
and record the new dynamic as its own entry under ## Current dynamics above.
-->

### <Other character or faction>
- **id:** rel-01
- **formerly:** [one-line summary of the prior dynamic or loyalty.]
- **held:** book1/chapter01/scene02 to book1/chapter07/scene01
- **committed-in:** draft-v13.md
- **superseded-by:** rel-08
- **what changed:** [How the loyalty fractured or the dynamic reversed.]
