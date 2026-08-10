# Mira Knowledge State — Book 1

<!--
ILLUSTRATIVE EXAMPLE — NOT REAL PROJECT CANON OR STATE.

This file is a worked demonstration of the Temporal character-state model
(`agents/characters.md`, ## Temporal character-state model) and mirrors the
field shapes in `templates/knowledge-book.md`. The character, facts, drafts,
and story positions are invented for the example. See the folder README at
`examples/character-state/README.md` for the point-in-time reconstruction this
file supports.

Each entry is one discrete fact. The `### heading` is a short searchable label.
- `id:` — durable, file-scoped, minted once, never changed (kn-01, kn-02, …).
- `story-position:` — where the fact was acquired, canonical folder-style
  `book1/chapterNN/sceneNN` (zero-padded, so lexical order = chronological).
- `committed-in:` — the accepted draft that committed the fact (draft-vNN.md).
- `basis:` — how the character holds it: witnessed | told | inferred.
- `review:` — the `scene_knowledge_update` step's provenance stamp. Every entry
  it writes is stamped `unreviewed` until a human audits and clears it. The
  stamp is provenance only; it does not affect reconstruction.

The section a fact sits in carries its certainty. A correction never overwrites
a current-state entry — the superseded entry is moved to ## Lost or superseded
keeping its id, and the corrected state is recorded as a new stamped entry.
-->

---

## Knows

<!-- Facts the character holds with confidence. -->

### Captain is the thief; the steward was covering for him
- **id:** kn-03
- **story-position:** book1/chapter07/scene02
- **committed-in:** draft-v09.md
- **basis:** witnessed
- **fact:** The captain has been taking grain from the stores; the steward was covering for him, not stealing himself. Mira saw the captain at the stores with the falsified tally-book she had blamed the steward for keeping.
- **notes:** Supersedes kn-02 (see ## Lost or superseded). Corrects the earlier false belief that the steward was the thief.
- **review:** unreviewed

---

## Suspects

<!-- Facts the character holds as probable but unconfirmed. -->

<!-- No current entries. This section was the home of kn-01 — Mira's suspicion
     that the steward was skimming grain — from book1/chapter02/scene03 until
     book1/chapter04/scene01, when the suspicion hardened into the false belief
     kn-02. kn-01 now sits in ## Lost or superseded. -->

---

## Believes incorrectly

<!-- Facts the character holds confidently but which are wrong. -->

<!-- No current entries. This section was the home of kn-02 — Mira's false
     belief that the steward was the thief — from book1/chapter04/scene01 until
     book1/chapter07/scene02, when she witnessed the truth and it was corrected
     to kn-03. kn-02 now sits in ## Lost or superseded. -->

---

## Must not know yet

<!-- Hard guardrails authored by planning. These are the things reveal timing protects. -->

- The captain is not acting alone — he takes the grain on the baron's orders — must remain unknown until book1/chapter09/scene04.

---

## Lost or superseded

<!--
A correction never overwrites a current-state entry. Per the non-destruction
invariant (see agents/characters.md), the superseded entry is moved here —
keeping its own id — and the corrected state is recorded as a new stamped
entry, with a new id, in the section above. These entries are what make
point-in-time reconstruction survive later corrections.
-->

### Suspected the steward was skimming grain
- **id:** kn-01
- **formerly:** suspects
- **held:** book1/chapter02/scene03 to book1/chapter04/scene01
- **committed-in:** draft-v06.md
- **superseded-by:** kn-02
- **what changed:** The unconfirmed suspicion hardened into a confident (but wrong) belief. In book1/chapter04/scene01 a servant told Mira outright that the steward was the thief, and she accepted it as fact — the fact was promoted out of ## Suspects into ## Believes incorrectly as kn-02.

### Believed the steward was the thief
- **id:** kn-02
- **formerly:** believes incorrectly
- **held:** book1/chapter04/scene01 to book1/chapter07/scene02
- **committed-in:** draft-v09.md
- **superseded-by:** kn-03
- **what changed:** Mira witnessed the captain at the stores with the falsified tally-book and understood the steward had been covering for him, not stealing. The false belief was corrected to the confident, witnessed fact kn-03.
