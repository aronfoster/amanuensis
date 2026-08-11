# [Character Name] Knowledge State — Book [N]

<!--
These fields realize the temporal character-state model defined in `agents/characters.md`
(## Temporal character-state model). See it for the rules; this template shows the shapes.

Each entry is one discrete fact. The `### heading` is a short searchable label.
- `id:` — durable, file-scoped, minted once, never changed (kn-01, kn-02, …).
- `story-position:` — where the fact was acquired, canonical folder-style
  `<book-id>/<chapter-id>/<scene-id>` (short_story: `<scene-id>`).
- `committed-in:` — the accepted draft that committed the fact, as its full
  attempt-qualified path `<chapter-folder>/drafts/<attemptNN>/draft-vNN.md`
  (never a bare `draft-vNN.md` basename — basenames repeat across chapters and
  attempts and would false-fresh on a collision; the same shape
  `templates/continuity-book.md` uses for `evidence:`).
- `basis:` — how the character holds it: witnessed | told | inferred. A remembered
  fact is one witnessed at its source scene and still held.

The section a fact sits in carries its certainty; a fact acquired across multiple scenes
is broken into parts, each its own entry.

A `## Believes incorrectly` entry's `truth:` field may optionally carry a qualified
`continuity/book-N.md#co-NN` reference to the objective fact the belief contradicts — the objective
fact is the authority in `continuity/`; the character file points, never restates or overrides it
(see `agents/continuity.md`). This is continuity-tracking metadata, not character knowledge, and
does not affect reveal timing.
-->

---

## Knows

<!-- Facts the character holds with confidence. -->

### [Short label, e.g. "Duchess Mathilde attended ch1 luncheon"]
- **id:** kn-01
- **story-position:** book1/chapter01/scene02
- **committed-in:** plot/book1/chapter01/drafts/attempt01/draft-v03.md
- **basis:** witnessed
- **fact:** [One or two sentences stating the fact precisely.]
- **notes:** [Optional. Cross-references, caveats, or downstream implications.]

---

## Suspects

<!-- Facts the character holds as probable but unconfirmed. -->

### [Short label]
- **id:** kn-02
- **story-position:** book1/chapter02/scene01
- **committed-in:** plot/book1/chapter02/drafts/attempt01/draft-v03.md
- **basis:** inferred
- **suspicion:** [What they think is true, and why.]
- **notes:** —

---

## Believes incorrectly

<!-- Facts the character holds confidently but which are wrong. -->

### [Short label]
- **id:** kn-03
- **story-position:** book1/chapter02/scene04
- **committed-in:** plot/book1/chapter02/drafts/attempt01/draft-v03.md
- **basis:** told
- **belief:** [What they believe.]
- **truth:** [What is actually true, for continuity tracking. May optionally carry a QUALIFIED
  reference to the objective fact in `continuity/` — `continuity/book-N.md#co-NN` (qualified because
  continuity ids are file-scoped) — the authority for the true state. Free text is the fallback when
  there is no confident match. See `agents/continuity.md`.]
- **notes:** —

---

## Must not know yet

<!-- Hard guardrails authored by planning. These are the things reveal timing protects. -->

- [Fact] — must remain unknown until [story point, canonical format, e.g. book1/chapter05/scene02]

---

## Lost or superseded

<!--
A correction never overwrites a current-state entry. Per the non-destruction invariant
(see agents/characters.md), the superseded entry is moved here — keeping its own id — and
the corrected state is recorded as a new stamped entry, with a new id, in the section above.
-->

### [Short label]
- **id:** kn-03
- **formerly:** believes incorrectly
- **held:** book1/chapter02/scene04 to book1/chapter06/scene03
- **committed-in:** plot/book1/chapter02/drafts/attempt01/draft-v11.md
- **superseded-by:** kn-07
- **what changed:** [Brief explanation of the correction.]
