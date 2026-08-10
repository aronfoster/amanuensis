# Sprint 20 — Milestone 15: Objective continuity state and evidence

This Sprint gives Amanuensis a **bounded, authoritative representation of objective story
continuity** — the facts that exist independently of any character's understanding
(chronology, event staging, location, possession, physical condition, roles, unresolved
causal threads) — and a running step that **maintains it from accepted prose, evidence-stamped
and non-destructively, surfacing conflicts rather than silently choosing a version.** It is the
objective-truth complement to M14's character-relative state: M14 records what a character
*believes*; M15 records what is *true* in the story world, and gives each maintained fact a
retrievable pointer to the accepted artifact that supports it.

The gap this closes is already documented. `agents/characters.md:67` states that objective
facts are "deferred to canon/continuity (the M15 boundary)," and the M14 templates
(`templates/timeline.md:11-12`, `templates/relationships.md:10-12`) each say objective facts
are "deferred to canon/continuity (the M15 boundary)" — but that home does not exist yet. The
only file today named for continuity is the optional, freeform, **book-level `continuity.md`**
(`agents/books.md:55`, `:59-66`), which holds human-authored *reveal-timing and consistency
risk notes* — planning, not maintained derived state. NOTES.md's "Continuity checking under
bounded context" section (`NOTES.md:17-126`) sketches exactly what is missing: "a compact,
authoritative continuity/canon-state artifact" — "timeline anchors … character knowledge-state,
rank/role assignments, established physical facts, and named events with their canonical
staging" — that a later check can *query* instead of re-deriving per pass (`NOTES.md:61-79`),
"cost O(facts + back-references), not O(corpus)" so it scales to a series. M15 builds that
artifact and its writer; the bounded *review* that consumes it is M16.

The milestone does four things. It **defines the boundary** (M15.1) — which class of fact each
home owns (objective continuity vs. character-relative belief vs. stable canon vs. storyboard
intent vs. raw prose) — and the **granularity policy** (M15.2) for which facts are load-bearing
enough to maintain. It **creates the `continuity/` artifact** (M15.3) at project root, reusing
M14's temporal/provenance idiom (durable `id`, canonical `story-position`, `committed-in` draft
stamp, non-destruction transitions, derived freshness) and adding one distinguishing field —
`evidence:`, a retrievable pointer to the accepted artifact that supports the fact. It defines
**how character belief refers to objective fact** (M15.4) without duplicating or overriding it —
the `truth:` field on an incorrect belief may carry a qualified `continuity/book-N.md#co-NN`
reference to the objective fact. And it **builds and wires a running `continuity_update` step**
(M15.5, M15.6) — the sole writer of `continuity/` — that reconciles the accepted draft into the
continuity state capture-style (provenance/evidence-stamped, non-destructive,
`review_required: false`) and **surfaces conflicts** — where the prose contradicts a
still-current maintained fact — to `open-questions.md` rather than overwriting. It closes with a
**multi-chapter demonstration** (M15.7) and a smoke recipe.

Two owner decisions from planning shape the Sprint (both starred in Conventions). (1) The
`continuity_update` step is **built and wired this Sprint** and is **capture-style with
conflict-surfacing** — not a report/fix pair on the review-grammar/validator machinery. So
"reviewable" (M15.5) means the writes are *legible, evidence-stamped, non-destructive, and
conflicts are surfaced not silently resolved* — a human **can** review them — **not** that they
are anchored `- Decision:` review units gated by `scripts/validate-review-artifact.sh`.
Agent-addressable, countable review of continuity, and the bounded relational continuity
*review* that reads prose against this state, are **M16**. (2) The maintained state lives in a
**new top-level `continuity/` folder**, parallel to `canon/` and `characters/`, keyed by
fact-class and book — leaving the freeform book-level `continuity.md` risk-notes file
(`agents/books.md:59-66`) untouched and distinct. This Sprint touches none of the four review
families, the validator, the review companion, or the dispatcher command/agent files.

## Background — what is and isn't wrong today

Established by inspection during planning, with file:line cites; tasks should not re-derive this.

- **The M15 boundary is already named in three shipped files, but points nowhere.**
  `agents/characters.md:67` ("Objective facts … are deferred to canon/continuity; a character
  file never claims objective authority. This is the M15 boundary"), `templates/timeline.md:11-12`,
  and `templates/relationships.md:10-12` all defer objective facts "to canon/continuity (the M15
  boundary)." No `continuity/` home exists, and `agents/canon.md` never mentions continuity. M15
  fills the referent: it creates the authority those files defer to, and closes the loop by
  pointing them at it.
- **The only "continuity" file today is freeform, book-level, human-authored risk notes.**
  `agents/books.md:55` lists `continuity.md` as an optional book planning artifact — "book-specific
  reveal timing and consistency risks" — and `:59-66` describes it as human notes on "fragile
  reveal timing," "dependencies across chapters," and "known consistency risks."
  `agents/workflows.md:10` ("Note major continuity risks in `continuity.md`") and `:56-60` (the
  "continuity review" workflow: "Record risks in the relevant continuity or open questions file")
  treat it as a planning/risk sink, not maintained derived state. It is `role: planning`, not
  `role: derived_state` (`agents/update-rules.md:81`). M15's maintained state is a **different
  artifact class** — derived, evidence-stamped, provenance-tracked — and must stay distinct from
  this risk-notes file (same name collision the owner decision resolves by using a folder, not the
  file).
- **NOTES.md already scoped this artifact — reuse its design, don't reinvent.** `NOTES.md:61-79`
  specifies "a compact, authoritative continuity/canon-state artifact" of "timeline anchors …
  character knowledge-state, rank/role assignments, established physical facts, and named events
  with their canonical staging," queried instead of re-derived, "cost O(facts + back-references),
  not O(corpus)," with structured, greppable state files "keyed by scene/chapter/entity"
  (`:124-126`). Its four milestone open questions (`:117-126`) map onto M15's tasks: *who maintains
  it and when* → the `continuity_update` step (M15.5); *how it is kept non-stale, same freshness
  class as `Reviewed-draft:`* → derived freshness (M15.6); *granularity, load-bearing vs. noise* →
  the maintain-vs-prose policy (M15.2); *filesystem-only retrieval* → the `evidence:` pointer +
  greppable per-book files (M15.3). The worked example there — a `compliance_report` that passed 40
  blocks scene-by-scene while a global pass found "8 real violations across 6 blocks" (elapsed-time
  vs. day-count, a moon-phase regression, a remembered scene's staging, a recap contradiction, an
  officer put at the helm against the roster, `:24-46`) — is the exact fact-class set M15 maintains
  and M15.7 demonstrates.
- **M14 already built the reusable temporal/provenance idiom this artifact should adopt.**
  `agents/characters.md:63-89` defines the Temporal character-state model: a durable visible `id`
  (`:73`), the canonical folder-style `story-position` (`:71`), the `committed-in: draft-vNN.md`
  provenance stamp (`:75`), the current/historical/prospective split realized by non-destruction
  transitions (`:79-87`), and freshness as a **derived predicate** over `committed-in` (`:89`),
  never stored or swept. The knowledge-book, timeline, and relationships templates realize it with
  `kn-`/`tl-`/`rel-` id prefixes. M15's continuity artifact is this same idiom applied to objective
  facts, with a `co-` id prefix and one added field (`evidence:`); it does **not** invent a parallel
  temporal model.
- **`continuity/book-N.md` aggregates facts across many chapters, so freshness must resolve per
  source chapter.** For `book`/`series`, one continuity file accumulates entries from every chapter
  of the book, but drafts and their `draft-manifest.md` are **per-chapter**
  (`agents/project-layouts.md`), and `draft-vNN.md` basenames repeat across chapters. So an entry's
  `committed-in: draft-vNN.md` (and its `evidence:` draft cite) is meaningful only **relative to its
  own chapter's manifest** — comparing every entry against the currently-invoked chapter's active
  lineage would falsely mark a prior-chapter entry stale/unsupported, or falsely fresh on a basename
  collision. The entry's `story-position` names its originating chapter; the freshness predicates
  (M15.6) resolve `committed-in`/`evidence` against **that** chapter's manifest and prose, still O(1)
  per entry. (M14's knowledge predicate, `agents/characters.md:89` and
  `agents/steps/scene-knowledge-update.md:71`, carries the same latent imprecision — it says "the
  attempt manifest" without disambiguating — masked because its demo is a single-chapter
  `short_story`; M15 states the resolved rule for `continuity/`, and the ROADMAP records the
  retroactive fix for M14's knowledge predicate.)
- **`scene_knowledge_update` is the near-exact structural precedent for the writer.**
  `agents/steps/scene-knowledge-update.md` is a `review_required: false`, sole-writer-of-a-folder
  step that reads accepted `<latest-draft>`, **confirms** a forecast against the drafted prose
  (`:50`, mirroring `compliance_report`'s confirm-against-prose), reconciles **non-destructively**
  (a changed fact becomes a `## Lost or superseded` transition plus a new stamped entry, never an
  overwrite — `:55`), is **idempotent on rerun** (matches by `id` / `(story-position + fact)`,
  `:65`), computes **derived-stale freshness** (`:69-75`), and routes blockers to
  `open-questions.md` (`:96-98`). `continuity_update` is this step's shape for objective facts —
  with one behavioral addition: it **surfaces conflicts** instead of only appending.
- **The confirm-against-prose and evidence inputs already exist in the pipeline.** Storyboard
  blocks carry `canon_active` (the rules operating in a beat, `agents/storyboard-schema.md:110-118`),
  `## Must Preserve` (canon-mandated staged content, `:137-148`), and `## Knowledge Delta`
  (`:128-135`); the accepted draft is the prose of record. These are the raw material NOTES.md says
  "is re-derived per check instead of consolidated" (`NOTES.md:66-68`). `continuity_update` reads
  the accepted draft (confirmed against these storyboard fields) and consolidates the load-bearing
  objective facts into `continuity/`; its `evidence:` field cites the draft position (and storyboard
  block / canon file where they apply) so a later step can retrieve the original (`NOTES.md:57-59`,
  the milestone note "Source references must allow later steps to retrieve the original evidence").
- **Canon owns stable world truth; continuity owns evolving objective fact.** `agents/canon.md:1-33`
  makes `canon/` the highest-priority, settled tier — "global setting facts that should remain
  consistent across books and chapters unless intentionally revised." That is **not** what changes
  as the story commits scenes (who holds the knife *now*, what day it is, who is captain *this*
  chapter). The boundary (M15.1): canon = intentionally-stable rules/history/institutions;
  continuity = objective facts the prose establishes and revises as it advances. A continuity fact
  never restates or overrides canon; where prose contradicts settled canon, that is a conflict to
  surface, not a continuity overwrite (`agents/canon.md:34-44`, "A settled or load-bearing world
  fact must never be silently invented").
- **Capture is barred from character `knowledge/`; `continuity/` needs the same protection.** The
  capture agent writes character `timeline.md`/`profile.md` and `canon/generated/` but is
  hard-barred from `knowledge/` (`agents/capture/capture-agent.md:44-49`, `:84`) because that folder
  has a single dedicated writer. `continuity/` is likewise derived, not invented: it has one writer
  (`continuity_update`), and capture must never write it. Capture's routing table (event → character
  `timeline.md`, identity → `profile.md`, world → `canon/generated/`) never targets `continuity/`
  already; M15 adds a one-line hard exclusion for symmetry and safety, mirroring the `knowledge/`
  line — it does **not** widen or re-route capture.
- **`revise` already models "correct current truth in place, never rewrite the record" — continuity
  slots into it.** The targeted-revision command (`agents/revision.md`) edits character files, canon,
  and storyboards **in place** because "they carry current truth; they are not versioned" (`:13`),
  and it **never edits** archived/superseded material because "Superseded and archived files record
  what was true when they were written. A revision changes the present, never the record" (`:22`).
  `continuity/` is the same shape: its current-state entries carry current truth (edit in place), and
  its `## Superseded` transitions are the record (leave untouched) — isomorphic to how `revise`
  already edits the active-head draft while leaving superseded drafts. But `revise` does not yet know
  about `continuity/`, so once it becomes the sole authority for objective facts, a human revision of
  such a fact would change the prose while leaving the continuity entry contradictory-but-current
  (harming every downstream check that trusts the state). M15 teaches `revise` the artifact.
- **`locations/` exists as a bare folder, not a structured authority.** `agents/project-layouts.md:118`,
  `:161`, `:218` show `locations/` in every project tree, and `templates/project-AGENTS.md:11`
  calls it "location references" — but there is no schema, no rules doc, and no maintained state
  there. Location-as-continuity-fact (where an entity is, per scene) is maintained in `continuity/`,
  not `locations/`; `locations/` stays a reference folder. M15 does not touch it.
- **Adding a step has the same three hard consistency surfaces M14 navigated.** (a)
  `scripts/check-pipeline-state.sh` runs in resolvable mode (every listed step resolves to a file)
  and `--exhaustive` mode (every step file appears in the list). (b) CI enforces **ordered-equality**
  of the step lists in `templates/pipeline-state.md` and `examples/smoke/pipeline-state.md` — the new
  line must sit at the **same position** in both (`.github/workflows/pipeline-state-check.yml`). (c)
  `AGENTS.md:63-78` catalogs every step file and needs a new catalog line; `AGENTS.md:80-93` catalogs
  support docs and needs an `agents/continuity.md` line. `install.sh` does **not** enumerate steps or
  support docs and stays unchanged; neither CI workflow yml lists step names.
- **Both current recipes end `… anti_ai_fix → scene_knowledge_update`.** `templates/pipeline-state.md`
  and `examples/smoke/pipeline-state.md` both list `scene_knowledge_update` last. `continuity_update`
  is inserted **before** `scene_knowledge_update` (objective facts precede the character-belief write
  that may reference them), so the tail becomes `… anti_ai_fix → continuity_update →
  scene_knowledge_update` in both files at the same position.
- **"Which chapter is current" for book/series is an open, deferred question — the demo works around
  it exactly as M14's did.** `agents/orchestrator.md:146-148` records chapter selection for
  book/series as a deferred TODO. M15.7's multi-chapter demonstration is a hand-authored fixture
  under `examples/continuity/` (like `examples/character-state/`), reconstructed by reading the
  stamped entries — it does not require the pipeline to resolve "current chapter."

## Definition of done

The Sprint is complete when:

1. ROADMAP.md tasks M15.1–M15.7 are checked; M16–M17 are untouched. The M15 section Notes carry
   the Sprint-20 planning addendum (the locked decisions below) and the two M14 follow-ups are on
   the Deferred list; nothing else outside M15 changes.
2. **The boundary and the objective-continuity model are defined and single-sourced in a new
   `agents/continuity.md`** (parallel to `agents/canon.md` and `agents/characters.md`), covering:
   the class-of-fact → authority boundary (M15.1); the maintain-vs-prose granularity policy (M15.2);
   the temporal/provenance/evidence model (M15.3), stated as M14's temporal model plus the
   `evidence:` field and referencing `agents/characters.md`'s model rather than restating it; the
   character-belief → objective-fact reference rule (M15.4); and the **diegetic-vs-authorial
   change distinction** (Conventions), stated once because it governs both `continuity_update`
   (diegetic → transition) and `revise` (authorial → in-place). It states once that `continuity/` is
   the sole authority for maintained objective story facts, that it never restates or overrides
   canon, and that character files never claim objective authority.
3. **The boundary loop is closed in the files that defer to it.** `agents/characters.md:67` and the
   `templates/timeline.md`/`templates/relationships.md` "the M15 boundary" notes point at
   `agents/continuity.md`; `agents/canon.md` gains a short cross-reference distinguishing stable
   canon from evolving continuity state. No temporal-model rule is restated — each cites its single
   source.
4. **The `continuity/` artifact and its template exist.** A new `templates/continuity-book.md` shows
   the entry shapes: each entry carries `id` (`co-NN`, file-scoped, minted once), `story-position`
   (canonical folder-style), `committed-in: draft-vNN.md`, `evidence:` (a retrievable pointer to the
   supporting accepted artifact — draft filename + scene-position, and storyboard block / canon file
   where they apply), the fact-class value fields, and the `- **review:** unreviewed` marker;
   fact-class sections cover the maintained set (Conventions); a `## Superseded` transition section
   applies the non-destruction invariant with held-from/to positions. A **cross-file** reference to
   an entry (e.g. a character `truth:` pointer) uses the qualified form `continuity/book-N.md#co-NN`,
   since file-scoped ids repeat across per-book files. The maintained target is
   `continuity/book-N.md` for `book`/`series` and `continuity/story.md` for `short_story`.
5. **The character-belief → objective reference is realized in the knowledge template and the
   knowledge step.** `templates/knowledge-book.md`'s `## Believes incorrectly` `truth:` field (`:59`)
   may carry a **qualified** `continuity/book-N.md#co-NN` reference to the objective fact (the
   continuity fact is the authority; the character file points, never restates or overrides).
   `scene_knowledge_update` gains a `required: false` continuity input and, when it writes an
   incorrect-belief entry, resolves the objective fact the belief contradicts and writes the
   qualified reference **advisorily** — non-fabricating (free-text `truth:` fallback when there is no
   confident match), never inventing a pointer. It remains the **sole writer of `knowledge/`** — it
   gains a continuity *read*, never a continuity *write* — and reveal timing is unaffected (`truth:`
   is continuity-tracking metadata, not character knowledge). The reference degrades gracefully: a
   diegetic supersession moves the target `co-NN` to `## Superseded` keeping its id and naming its
   successor (the pointer chases forward), and an authorial `revise` corrects the target in place (it
   still resolves).
6. **`continuity/` is added to the project layouts and the adapter.** `agents/project-layouts.md`
   shows `continuity/` in all three project trees (`short_story`: `continuity/story.md`;
   `book`/`series`: `continuity/book-N.md`) with resolution rules; `templates/project-AGENTS.md`
   lists `continuity/` in Project Paths and adds `agents/continuity.md` + the new step to Where To
   Look.
7. **A new step `agents/steps/continuity-update.md` exists and is wired.** It is the sole writer of
   `continuity/`. It reads the accepted `<latest-draft>` (resolved via the manifest active head), the
   scene storyboards, the existing `continuity/` files (created if absent), and — `required: false` —
   relevant canon for conflict context. It **confirms** the objective facts against the drafted prose,
   maintains only the load-bearing set (M15.2 policy), and reconciles into the project-type target:
   a new fact appends a stamped, evidence-bearing entry; a changed fact appends a `## Superseded`
   transition plus a new stamped entry (never an overwrite); a **conflict** — prose contradicting a
   still-current maintained fact in a way that is not an intended change — is **surfaced to
   `open-questions.md`** naming both sides (prior entry `id` + value + evidence, and the prose
   position + quote), with the prior entry left in place and the conflicting value **not** silently
   written. It writes `continuity/` only, respects each target's `edit_policy` (Rule 7,
   `agents/update-rules.md:62-108`), is `review_required: false`, and records its own completion in
   `pipeline-state.md`.
8. **The step is added to both recipes at the same position** — inserted **before**
   `scene_knowledge_update` (tail becomes `… anti_ai_fix → continuity_update →
   scene_knowledge_update`) in `templates/pipeline-state.md` and `examples/smoke/pipeline-state.md` —
   so both `check-pipeline-state.sh` modes pass and CI ordered-equality passes. `AGENTS.md`'s step
   catalog gains a `continuity-update.md` line and its support-doc catalog gains an
   `agents/continuity.md` line.
9. **Freshness, invalidation, and rebuilding are defined** (M15.6): a continuity entry is
   **derived-stale** iff its `committed-in` names a draft outside the active head's lineage (the M14
   predicate, `agents/characters.md:89`, `agents/orchestrator.md:150-181`), and **derived-unsupported**
   iff its `evidence:` pointer no longer resolves in the active prose — both evaluated against the
   manifest and prose of the **chapter named in the entry's `story-position`** (not the invoked
   chapter — per Background), both O(1), never stored, never swept. **Rebuild is the step's
   rerun-reconcile**: re-running `continuity_update` against the current active head appends
   corrections as transitions and re-surfaces conflicts, never silently rewriting. The rule lives in
   `agents/continuity.md` (and the step body computes it); the orchestrator's Artifact-state section
   is left byte-for-byte or gains at most a one-line cross-reference.
10. **The `continuity_update` behavior is added to `agents/workflows.md`.** The "scene knowledge
    update" workflow neighbor gains a "continuity update" workflow entry describing the automated
    step and its evidence-stamped, non-destructive, conflict-surfacing behavior; the freeform
    "continuity review" workflow (`:56-60`) is left as-is except a one-line note distinguishing it
    (human reveal-timing risk notes) from the maintained `continuity/` state, so the two are not
    conflated.
11. **Capture is barred from `continuity/`.** `agents/capture/capture-agent.md` (and its OpenCode
    mirror `opencode/agents/capture-agent.md`) gain a one-line hard exclusion mirroring the
    `knowledge/` line — capture never writes `continuity/`; its routing is otherwise unchanged.
12. **`revise` reconciles `continuity/`.** `agents/revision.md` is extended to name `continuity/`
    among the current-truth files it edits **in place** (the current-state entries, joining the
    `:13` "edited in place" category), while the `## Superseded` transition sections are treated as
    *the record* and left untouched (joining the `:22` "a revision changes the present, never the
    record" category) — the diegetic-vs-authorial distinction (item 2). The extension states the
    current-vs-record discipline **generally for non-destructive temporal-state files**, so it reads
    coherently for M14's character `knowledge/`/`timeline.md`/`relationships.md` as well, and notes
    that a continuity fact's `evidence:` pointers index the prose the sweep must check. Only
    `agents/revision.md` (the canonical contract, `:5`) changes; its thin `/revise` dispatcher
    adapters do not.
13. **A worked demonstration is committed** under `examples/continuity/` (clearly marked as an
    example per `AGENTS.md:22-26`): a `book`-project continuity fixture spanning **multiple chapters**
    that exercises **chronology** (a day/time anchor that advances), **event staging** (a named event
    with canonical staging later recalled), and **possession or role state** (a role assignment or an
    object's holder that **changes**, recorded as a non-destructive `## Superseded` transition), plus a
    character `knowledge/` entry whose `truth:` carries the qualified reference to the continuity fact
    the character is **wrong** about — and a README that (a) answers a material objective continuity
    question at two story positions from the `id`/`story-position`/transition data, (b) names the
    `evidence:` supporting each answer, and (c) shows the objective fact and the character's incorrect
    belief about it side by side, demonstrating the boundary.
14. **Smoke coverage exists** for the step in `examples/smoke/README.md`: at least one recipe that
    hand-authors a `continuity/story.md`, a scene storyboard, and an accepted draft, runs
    `continuity_update`, and confirms an evidence-stamped non-destructive append; a second run against
    a **changed** fact confirms a `## Superseded` transition is appended (not an overwrite); and a third
    run against a **conflicting** fact confirms the conflict is surfaced to `open-questions.md` with the
    prior entry left intact and the conflicting value not written. The recipe enumeration, layout/
    untracked notes, and reset procedure are updated; existing recipes (1–21) stay byte-for-byte
    untouched.
15. **Verification passes.** Both `check-pipeline-state.sh` modes succeed; the two step lists are
    ordered-equal; `git diff --stat` against the Sprint-start SHA (captured before the first commit)
    shows **no** changes to `scripts/validate-review-artifact.sh`, `agents/review-grammars.yaml`,
    `agents/review-validation.md`, any of the four review-family step files, the review companion skill,
    `install.sh`, either CI workflow yml, or the dispatcher command/agent files (the `/revise` adapters
    included — only `agents/revision.md` changes). `scene_knowledge_update`'s change is limited to the
    `required: false` continuity input and advisory `truth:` reference-writing (item 5); it gains no
    continuity write. Greps confirm the sweep: `git grep -ln "continuity_update\|continuity-update"`
    lists at least the step file, both pipeline-state files, `AGENTS.md`, `agents/continuity.md`,
    `agents/workflows.md`, and `templates/project-AGENTS.md`; `git grep -n "the M15 boundary"` shows
    the deferring files now resolve to `agents/continuity.md`.

## Conventions adopted by this Sprint

Locked at planning (the two starred items are owner decisions from this Sprint's planning session);
tasks don't rediscover them.

- **★ The `continuity_update` step is built and wired this Sprint, capture-style with
  conflict-surfacing — not a report/fix pair on the validator machinery.** The owner chose to build
  the running writer now (over a definitional-only sprint), and to model it on `scene_knowledge_update`
  (`review_required: false`, sole folder-writer, confirm-against-prose, non-destructive) **plus** a
  conflict-surfacing behavior, rather than as a `continuity_report`/`continuity_fix` pair adopting the
  `agents/review-grammars.yaml` / `scripts/validate-review-artifact.sh` contract. So "reviewable"
  (M15.5) means the writes are **legible, evidence-stamped, non-destructive, and conflicts are
  surfaced, not silently resolved** — a human *can* review and resolve them — **not** anchored
  `- Decision:` review units. Rationale: applying a confirmed objective fact is mechanical enough to
  trust ungated (the M14 rationale), and agent-addressable/countable review of continuity, plus the
  bounded relational continuity *review* that reads prose against this state, are explicitly **M16**
  (`ROADMAP.md` M16, and the "continuity review step" on the Deferred list). Rejected: a full
  agent-addressable review family — heaviest, overlaps M16's charter, too big for one sprint. Rejected:
  definitional-only, defer the step — leaves the artifact with no automated writer, the alternative M14
  explicitly rejected for `knowledge/`.
- **★ The maintained state lives in a new top-level `continuity/` folder, keyed by fact-class and
  book.** A project-root folder parallel to `canon/`, `characters/`, `locations/` — `continuity/story.md`
  for `short_story`, `continuity/book-N.md` for `book`/`series` — with fact-class sections and structured
  `co-NN` entries. This is NOTES.md's "greppable state files keyed by scene/chapter/entity"
  (`NOTES.md:124-126`), O(facts) not O(corpus), scaling to a series (per-book files, like `knowledge/`).
  It leaves the freeform book-level `continuity.md` risk-notes file (`agents/books.md:59-66`) **untouched
  and distinct** — that stays human `role: planning` reveal-timing notes; this is derived
  `role: derived_state`. Rejected: evolve `continuity.md` — conflates planning risk-notes with derived
  state and is book-level only (no `short_story` home). Rejected: per-chapter aftermath-style — fragments
  state so cross-chapter/series continuity must rescan, defeating the O(facts) goal that motivates the
  milestone.
- **The objective-continuity model reuses M14's temporal idiom; the only new field is `evidence:`.**
  `id` (`co-NN`, file-scoped, minted once, never changed — the `kn-`/`tl-`/`rel-` precedent),
  `story-position` (canonical folder-style `<book-id>/<chapter-id>/<scene-id>`, reduced to `<scene-id>`
  for `short_story`), `committed-in: draft-vNN.md`, the non-destruction transition discipline, and
  derived freshness are **defined once in `agents/characters.md`** (## Temporal character-state model)
  and referenced, not restated. `agents/continuity.md` adds the one field that distinguishes objective
  fact from character belief: `evidence:`, a **retrievable** pointer to the accepted artifact that
  supports the fact (draft filename + scene-position, plus storyboard block / canon file where they
  apply) — the objective-fact counterpart to knowledge's `basis:` (the character's grounds). Rationale:
  the milestone requires every maintained fact to "point to supporting evidence" and let a later step
  "retrieve the original evidence when a summary is insufficient or disputed."
- **The maintained fact-classes (M15.2 granularity policy).** Maintain a fact iff it is **relational**
  (its correctness depends on comparison across scenes) **and** capable of producing a **reader-visible
  contradiction**; a detail that lives only in one scene and is never referenced again stays in prose.
  The maintained classes, drawn from the ROADMAP M15 intro and the NOTES.md worked example
  (`NOTES.md:24-46`, `:61-64`): **chronology / time anchors** (day count, date, season, elapsed-time
  claims), **event staging** (canonical staging of named events, for recall/recap fidelity), **location**
  (where an entity or party is), **possession** (who holds what), **physical condition** (injuries,
  states of persons/objects), **role / assignment** (rank, title, post — "who is at the helm"), and
  **open causal threads** (unresolved threads capable of later contradiction). The policy and this set
  live in `agents/continuity.md`. The open-thread class is the natural join key for M15.4: a contested
  question ("who is the thief?") is one open thread that a character may answer wrongly while the prose
  later answers rightly.
- **The character-belief → objective-fact reference is a qualified, advisory citation, never a copy or
  an override (M15.4).** A `## Believes incorrectly` entry's `truth:` field (`templates/knowledge-book.md:59`)
  may carry a **qualified** `continuity/book-N.md#co-NN` reference — qualified because continuity ids are
  file-scoped, so a bare `co-01` is ambiguous across per-book files. The objective fact lives once, in
  `continuity/`; the character file points to it. `scene_knowledge_update` writes the reference
  **advisorily**: it reads the (distilled, cheap) continuity file — a `required: false` input — matches
  the belief to the objective fact it contradicts by subject, and writes the qualified reference when the
  match is confident, else leaves `truth:` free-text (M14 behavior) and **never fabricates a pointer**.
  The reference **degrades gracefully**: under a diegetic supersession the target `co-NN` moves to
  `## Superseded` keeping its id and naming its successor (the pointer chases forward); under an authorial
  `revise` the target is corrected in place (the pointer still resolves). `scene_knowledge_update` stays
  the **sole writer of `knowledge/`** — it gains a continuity *read*, never a *write* — and reveal timing
  is unaffected: `truth:` is continuity-tracking metadata, not character knowledge (it already held
  objective-truth text in M14). Rejected: a bare `co-NN` reference (ambiguous across per-book files);
  restating the fact in `truth:` (duplication that drifts from the authority).
- **`continuity_update` surfaces conflicts to `open-questions.md`; it never silently chooses.** When the
  accepted prose contradicts a **still-current** maintained fact in a way that is not an intended change
  (a day count that regresses; a role or possession that collides with an unretired entry; a fact that
  contradicts settled canon), the step records the conflict to `open-questions.md` naming both sides
  (prior entry `id` + value + `evidence`, and the prose position + quote), leaves the prior entry in
  place, and does **not** write the conflicting value as a fact. Conflict-surfacing is non-blocking
  (like capture): the step continues with the other facts and completes; the human resolves the conflict
  out-of-band. This is the concrete meaning of M15.5's "surfaces conflicts rather than silently choosing
  a version." An *intended* change (the prose deliberately advances the fact) is not a conflict — it is a
  non-destructive transition.
- **Two kinds of fact-change, kept distinct: diegetic (transition) vs. authorial (in-place).** A fact
  can change two ways, recorded differently. *Diegetic* change — the **story** advances and a fact
  changes in the fiction — is a non-destructive `## Superseded` transition, because at the earlier story
  position the earlier value really was the case; **`continuity_update` owns this**. *Authorial* change —
  a human **`revise`** decides to change what the fiction says — is an **in-place** correction of the
  current entry, because the earlier value was never true-in-the-fiction (it was a draft being fixed, and
  the archived drafts are its record); **`revise` owns this**, and a transition here would fabricate an
  in-story change that never happened. This mirrors how `revise` already edits the active-head draft in
  place while leaving superseded drafts as the record (`agents/revision.md:22`). The distinction is stated
  once in `agents/continuity.md` and governs both writers; it applies equally to M14's non-destructive
  temporal-state files (`knowledge/`, `timeline.md`, `relationships.md`).
- **Freshness is derived (stale + unsupported), never stored; resolved per source chapter; rebuild is
  rerun-reconcile.** A continuity entry is **derived-stale** iff its `committed-in` names a draft outside
  the active head's lineage, and **derived-unsupported** iff its `evidence:` no longer resolves in the
  active prose. Both are evaluated against the manifest and prose of the **chapter named in the entry's
  `story-position`** — not the currently-invoked chapter — because `continuity/book-N.md` aggregates
  entries across chapters whose per-chapter `draft-vNN.md` basenames repeat (Background), so a bare
  `committed-in` is meaningful only relative to its own chapter. Each is O(1) from facts on disk (the
  entry's stamp + its source-chapter manifest), never written as a field, never swept (the M14 predicate,
  `agents/orchestrator.md:150-181`). Rebuild is the step's rerun against the current active head.
  Dispatcher-level detection of continuity staleness is **out of scope** — a deferred follow-on, exactly
  as dispatcher-level artifact staleness (`agents/orchestrator.md:187`) and character-state staleness
  (`agents/steps/scene-knowledge-update.md:75`) are.
- **`continuity_update` runs before `scene_knowledge_update`, at the end of the recipe.** Both consume
  the accepted chapter prose and write post-chapter state. Objective facts are written first so
  `scene_knowledge_update` can resolve a `truth:` reference to an already-recorded `co-NN`. With
  `continuity_update` before it, the ordering is **load-bearing** for that reference — but **graceful**:
  the continuity input is `required: false`, so if `continuity/` is absent or the steps run out of order,
  `scene_knowledge_update` writes free-text `truth:` and does not block. End-of-recipe (after
  `anti_ai_fix`) matches the post-chapter-update ordering (`agents/workflows.md:85-93`) and reads one
  settled draft. Rejected: after `scene_knowledge_update` — would leave `truth:` → `co-NN` references
  unresolvable on a first pass.
- **`continuity/` is the sole province of `continuity_update`; capture stays out.** Just as `knowledge/`
  has one writer, `continuity/` has one writer. Capture's routing never targets `continuity/`; a one-line
  hard exclusion is added for symmetry, not a re-route. `continuity_update` writes `continuity/` and
  nothing else (never `canon/`, `characters/`, `knowledge/`, or drafts).

---

## Tasks

Wave order: **Task 1** settles the boundary, the model, and the artifact/templates/layouts — every
downstream file cites it — and lands first. **Task 2** builds and wires the step, teaches
`scene_knowledge_update` and `revise` the artifact, and defines the evidence/freshness/conflict
behavior against Task 1's model. **Task 3** demonstrates, smoke-tests, verifies, and closes out, last.
The tasks are largely sequential (Task 2 cites `agents/continuity.md`'s model and the template Task 1
creates; Task 3 depends on both), so run them in order rather than in parallel.

### Task 1 — The boundary, the objective-continuity model, and the artifact/templates/layouts

- [ ] Todo

**Goal.** Define the class-of-fact boundary, the granularity policy, the temporal/provenance/evidence
model, the character-belief → objective reference, and the diegetic-vs-authorial change distinction
once, authoritatively, in a new `agents/continuity.md`, and realize the artifact as human-readable
Markdown with no parallel temporal model. Closes **M15.1**, **M15.2**, **M15.3**, **M15.4**.

**Requirements.**

- Create `agents/continuity.md` (parallel to `agents/canon.md`, `agents/characters.md`), stating once:
  - **The boundary (M15.1).** Each class of fact → one authority: **objective, evolving story facts** →
    `continuity/` (this doc); **character-relative belief** → `characters/<id>/knowledge/` +
    `timeline.md` + `relationships.md` (M14); **stable world truth** → `canon/` (+ `canon/generated/`);
    **beat intent/specification** → storyboards; **source of record** → the accepted drafts + planning
    artifacts. State that `continuity/` is the **sole authority** for maintained objective facts, never
    restates or overrides `canon/` (canon outranks; a prose-vs-canon contradiction is surfaced, not
    absorbed), and that character files never claim objective authority (cross-reference
    `agents/characters.md:67`).
  - **The granularity policy (M15.2)** and the maintained fact-class set, per Conventions (maintain iff
    relational **and** reader-visible-contradiction-capable; the seven classes; single-scene throwaway
    detail stays in prose; the open-thread class as the M15.4 join key).
  - **The temporal/provenance/evidence model (M15.3):** reference `agents/characters.md`'s Temporal
    character-state model for `id`/`story-position`/`committed-in`/non-destruction/derived-freshness
    (do **not** restate them), and define the one added field, `evidence:` — a retrievable pointer to the
    supporting accepted artifact — as the objective counterpart to knowledge's `basis:`.
  - **The character-belief → objective reference (M15.4):** a `truth:` field may carry a **qualified**
    `continuity/book-N.md#co-NN` reference (qualified because ids are file-scoped); the objective fact
    lives once in `continuity/`; the character file points, never copies or overrides.
  - **The diegetic-vs-authorial change distinction** (Conventions): diegetic change → non-destructive
    transition (`continuity_update`); authorial change → in-place correction (`revise`). Stated here
    once because it governs both writers and applies equally to M14's temporal-state files.
- Close the boundary loop: update `agents/characters.md:67` and the `templates/timeline.md` /
  `templates/relationships.md` "the M15 boundary" notes to name `agents/continuity.md`; add a short
  cross-reference to `agents/canon.md` distinguishing stable canon from evolving continuity state. Restate
  no temporal-model rule — cite its single source.
- Create `templates/continuity-book.md` per Definition-of-done item 4: frontmatter (`edit_policy`,
  `role: derived_state`), a short "objective story facts, not a parallel authority; realizes the model in
  `agents/continuity.md` / `agents/characters.md`" note, fact-class sections (the seven classes), a
  structured entry shape carrying `id` (`co-NN`), `story-position`, `committed-in`, `evidence`, the
  fact-class value fields, and `- **review:** unreviewed`, and a `## Superseded` transition section with
  held-from/to positions and `superseded-by`. Model tone/structure on `templates/knowledge-book.md` and
  `templates/timeline.md`.
- Evolve `templates/knowledge-book.md`: document the `## Believes incorrectly` `truth:` field (`:59`) to
  carry an optional **qualified** `continuity/book-N.md#co-NN` reference to the objective fact (authority
  stays in `continuity/`; qualified because continuity ids are file-scoped). This is the **template
  change only**; the `scene_knowledge_update` behavior that *writes* the reference is Task 2. No other
  knowledge-template change.
- Add `continuity/` to `agents/project-layouts.md` (all three trees: `short_story` →
  `continuity/story.md`; `book`/`series` → `continuity/book-N.md`) with resolution rules, and to
  `templates/project-AGENTS.md` (Project Paths + Where To Look, adding `agents/continuity.md` and the
  step).
- Do not create the step file, edit `pipeline-state.md`, edit `agents/revision.md`, or touch the
  review-artifact system in this task.

**Done when.** `agents/continuity.md` defines the boundary, granularity policy, evidence model,
belief→truth reference, and diegetic-vs-authorial distinction in one place; `templates/continuity-book.md`
realizes the artifact as legible Markdown reusing the M14 idiom with `evidence:` added; the knowledge
template's `truth:` field carries an optional qualified reference; the three deferring files resolve "the
M15 boundary" to `agents/continuity.md`; `continuity/` appears in the layouts and the adapter; no parallel
temporal model is introduced and no rule is restated per file.

---

### Task 2 — The `continuity_update` step, the knowledge-step reference, and the revise contract

- [ ] Todo

**Goal.** Build the sole writer of `continuity/`, wire it before `scene_knowledge_update`, teach
`scene_knowledge_update` to write the qualified `truth:` reference and `revise` to reconcile
`continuity/`, and define the evidence, freshness/invalidation, and conflict-surfacing behavior against
Task 1's model. Closes **M15.5** and **M15.6**.

**Requirements.**

- Create `agents/steps/continuity-update.md` with standard step frontmatter (`step_id: continuity_update`,
  `review_required: false`, `inputs`/`outputs`, `preconditions`), modeling structure on
  `agents/steps/scene-knowledge-update.md` and following the step-workflow contract
  (`agents/orchestrator.md:35-79`). Inputs: the accepted `<latest-draft>` (`kind: prose_draft`, required),
  the scene storyboards (`kind: source`, required — for the confirm-against-prose fields
  `canon_active`/`## Must Preserve`/staging), the `continuity/` files it reconciles (`kind: source`,
  required: false — creates missing targets), and relevant canon (`kind: source`, required: false — for
  conflict context). Behavior: **confirm** each candidate objective fact against the drafted prose (mirror
  `compliance_report`'s and `scene_knowledge_update`'s confirm-against-prose); maintain only the
  load-bearing set (Task 1's M15.2 policy); **reconcile** into `continuity/book-N.md` (`book`/`series`) or
  `continuity/story.md` (`short_story`), creating the target if absent — a **new** fact appends a stamped,
  `evidence:`-bearing entry (`id`, `story-position`, `committed-in: <latest-draft>`, `evidence`,
  `- **review:** unreviewed`); a **changed** fact appends a `## Superseded` transition citing the prior
  `id` plus a new stamped entry (never an overwrite — the non-destruction invariant); a **conflict** (prose
  contradicts a still-current entry and is not an intended change) is **surfaced to `open-questions.md`**
  per Conventions (both sides named; prior entry untouched; conflicting value not written; non-blocking).
  It writes `continuity/` only, respects each target's `edit_policy` (Rule 7,
  `agents/update-rules.md:62-108`; a `locked`/`propose_only` target → open question, no write), and records
  its own completion in `pipeline-state.md` as its final action (mints no draft; does not touch the
  manifest `Active-head:`).
- Define freshness/invalidation/rebuild in the step body (and, where it generalizes, in
  `agents/continuity.md`): a continuity entry is **derived-stale** iff its `committed-in` names a draft
  outside the active head's lineage, and **derived-unsupported** iff its `evidence:` no longer resolves in
  the active prose — both resolved against the manifest and prose of the **chapter named in the entry's
  `story-position`**, not the invoked chapter (Background), both O(1) from facts on disk, never stored,
  never swept (mirror `agents/steps/scene-knowledge-update.md:69-75` and `agents/orchestrator.md:150-181`).
  An **idempotency/rerun** section: re-running against the current active head matches existing entries by
  `id` / `(story-position + fact)`, appends only genuinely new facts, corrections (as transitions), and
  newly-detected conflicts, and duplicates nothing — a rerun converges. Dispatcher-level staleness
  detection stays out of scope (deferred, per `agents/orchestrator.md:187`).
- Wire it: insert `- [ ] continuity_update` **before** `scene_knowledge_update` (same position) in **both**
  `templates/pipeline-state.md` and `examples/smoke/pipeline-state.md`. Add a `continuity-update.md` step
  catalog line and an `agents/continuity.md` support-doc catalog line to `AGENTS.md`. Run both
  `check-pipeline-state.sh` modes and confirm they pass.
- **Wire the character-belief → objective reference (#3, Definition-of-done item 5).** Give
  `agents/steps/scene-knowledge-update.md` a `required: false` project-type continuity input
  (`continuity/book-N.md` / `continuity/story.md`, `kind: source`), and specify: when the step writes a
  `## Believes incorrectly` entry, it resolves the objective fact the belief contradicts from that file
  and writes a **qualified** `truth: continuity/book-N.md#co-NN` reference — advisory, non-fabricating
  (free-text `truth:` fallback when there is no confident match), never a continuity *write*. This is the
  Sprint's only behavior change to that M14 step; it stays the **sole writer of `knowledge/`**. Note the
  graceful degradation (required:false → free-text fallback when continuity is absent or the steps run out
  of order) and that reveal timing is unaffected (`truth:` is continuity metadata, not character
  knowledge). Do **not** change the step's freshness/idempotency/reconcile behavior.
- **Extend `agents/revision.md` for `continuity/` (#4, Definition-of-done item 12).** Name `continuity/`
  among the current-truth files `revise` edits **in place** (join the `:13` "Always edited in place"
  category: current-state entries), and add its `## Superseded` transition sections to the *record* it
  **never edits** (join the `:22` category) — the diegetic-vs-authorial distinction (Task 1). State the
  current-vs-record discipline **generally for non-destructive temporal-state files** (so it covers M14's
  character `knowledge/`/`timeline.md`/`relationships.md` too), and note that a continuity fact's
  `evidence:` pointers index the prose locations the sweep (`:29`) must check. Only `agents/revision.md`
  (the canonical contract, `:5`) changes; the `/revise` dispatcher adapters stay untouched.
- Add a "continuity update" workflow entry to `agents/workflows.md` (neighboring the "scene knowledge
  update" entry) describing the automated step and its evidence-stamped, non-destructive,
  conflict-surfacing behavior; add a one-line note to the existing freeform "continuity review" workflow
  (`:56-60`) distinguishing it (human reveal-timing risk notes) from the maintained `continuity/` state.
  Add the one-line hard exclusion ("never `continuity/`") to `agents/capture/capture-agent.md` and its
  OpenCode mirror `opencode/agents/capture-agent.md`, mirroring the `knowledge/` line; capture routing is
  otherwise unchanged. Leave the orchestrator's Artifact-state section byte-for-byte, or add at most a
  one-line cross-reference.

**Done when.** The step exists, is the sole `continuity/` writer, confirms facts against prose, reconciles
non-destructively with evidence stamps and `review_required: false`, surfaces conflicts to
`open-questions.md` without silently choosing, targets the right file per project type, and defines its
per-source-chapter freshness/invalidation/rebuild behavior; both recipes carry the step at the same
position before `scene_knowledge_update`; both `check-pipeline-state.sh` modes and CI ordered-equality
pass; `scene_knowledge_update` writes the advisory qualified `truth:` reference (sole `knowledge/` writer,
no continuity write); `agents/revision.md` reconciles `continuity/` in place with transitions as the
record; the workflow entry and capture exclusion are in place; the untouched-surface diff (item 15) holds.

---

### Task 3 — Demonstration, smoke coverage, verification, and close-out

- [ ] Todo

**Goal.** Prove objective continuity across multiple chapters end-to-end (including a character wrong about
an objective fact), give the step a runnable smoke recipe, run the verification sweep, and close the
milestone. Closes **M15.7** and the residual of **M15**.

**Requirements.**

- Commit the worked demonstration under `examples/continuity/` (Definition-of-done item 13), clearly
  marked as an example per `AGENTS.md:22-26` (mirror the header of `examples/character-state/README.md`):
  a `book`-project fixture spanning **multiple chapters** exercising **chronology** (a day/time anchor that
  advances), **event staging** (a named event whose canonical staging is later recalled), and **possession
  or role state** (a holder/role that **changes**, recorded as a non-destructive `## Superseded`
  transition) — plus a character `knowledge/` entry whose `truth:` carries the qualified
  `continuity/book-N.md#co-NN` reference to the fact the character is **wrong** about. The README (a)
  answers a material objective continuity question at **two** story positions from the
  ids/positions/transitions, (b) names the `evidence:` behind each answer, and (c) puts the objective fact
  and the character's incorrect belief side by side to show the boundary.
- Add the smoke recipe(s) to `examples/smoke/README.md` (Definition-of-done item 14), modeled on the
  existing hand-authored-input recipes and the Recipe 21 pattern: hand-author a `continuity/story.md`, a
  scene storyboard, and an accepted draft; run `continuity_update` and confirm an evidence-stamped
  non-destructive append; a second run against a **changed** fact confirms a `## Superseded` transition is
  appended (not an overwrite); a third run against a **conflicting** fact confirms the conflict is surfaced
  to `open-questions.md` with the prior entry intact and the conflicting value unwritten. Update the recipe
  enumeration paragraph, the layout/untracked notes, and the reset procedure for the new recipe number(s)
  and any new untracked paths (`continuity/`, the hand-authored storyboard/draft); confirm the reset removes
  them. Existing recipes (1–21) stay byte-for-byte untouched.
- Run the full verification sweep (Definition-of-done items 8, 9, 15): both `check-pipeline-state.sh`
  modes; the two step lists ordered-equal; the untouched-surface `git diff --stat` against the captured
  Sprint-start SHA (no changes to the validator, review grammar/validation, the four review families, the
  review companion, `install.sh`, either CI workflow yml, or the dispatcher files — the `/revise` adapters
  included; `scene_knowledge_update` changed only per item 5); and the greps (item 15:
  `continuity_update`/`continuity-update` → the expected file set; `the M15 boundary` → resolves to
  `agents/continuity.md`).
- Cross-file consistency read: the step, `templates/continuity-book.md`, `agents/continuity.md`,
  `agents/characters.md`, `agents/canon.md`, `agents/revision.md`, `agents/workflows.md`, the layouts, and
  the adapter agree on the boundary, the `co-NN`/`story-position`/`committed-in`/`evidence` fields and the
  qualified cross-file reference form, the maintained fact-class set, the non-destruction invariant, the
  diegetic-vs-authorial distinction, the conflict-surfacing rule, and the per-source-chapter freshness
  predicates — no drift, no restated model; the demonstration and smoke fixtures match the template shapes.
- Update `ROADMAP.md`: check M15.1–M15.7 only after Tasks 1–2 pass verification; add the Sprint-20 planning
  addendum to the M15 Notes (the starred owner decisions and the locked conventions) and the two M14
  follow-ups to the Deferred list, so the roadmap stays the plan of record. Check this SPRINT.md's per-task
  boxes (Tasks 1–3) only after their acceptance conditions hold.

**Done when.** The demonstration answers an objective continuity question at two positions with evidence
and shows a character wrong about a maintained fact via a qualified `truth:` reference; the smoke recipe(s)
run and the reset covers them; all script runs, the ordered-equality check, the untouched-surface diff, and
the greps return the expected results; ROADMAP M15.1–M15.7, the Deferred follow-ups, and the SPRINT task
boxes reflect completed work.

---

## Out of scope for this Sprint

- **The review-grammar / validator machinery.** `agents/review-grammars.yaml`,
  `scripts/validate-review-artifact.sh`, `agents/review-validation.md`, the four review-family step files,
  and the `amanuensis-review` companion skill are byte-for-byte unchanged. Continuity changes are not
  modeled as `- Decision:` review units; agent-addressable, countable review of continuity is **M16**. The
  owner's capture-style / conflict-surfacing / no-validator decision is the reason.
- **Bounded relational continuity *review* (M16).** Reading prose against the maintained continuity state
  to catch cross-scene/-chapter/-book contradictions — the "continuity review step" on the Deferred list,
  and the precedence/conflict-resolution among storyboard, character state, continuity state, canon, and
  prose (M16.5) — is M16. This Sprint **builds and maintains** the state and surfaces update-time
  conflicts; it does not add the relational review that consumes it. NOTES.md's precedence rule
  (`:82-87`, storyboard > distilled state > raw source) governs that review, not this Sprint.
- **`scene_knowledge_update`'s writer role.** It remains the **sole writer** of `knowledge/`. This Sprint
  gives it one bounded change: a `required: false` continuity *read* and advisory qualified `truth:`
  reference-writing (Definition-of-done item 5). It gains no continuity *write*, no new required input, and
  no other behavior change; its freshness/idempotency/reconcile behavior is M14's.
- **An automated writer for `timeline.md` or `relationships.md`.** Still M14's deferral — they keep their
  human/post-chapter update path (`agents/workflows.md:85-93`). This Sprint adds no writer to them (the
  `revise` extension teaches the current-vs-record discipline generally but adds no pipeline writer).
- **Widening or re-routing capture.** Capture stays barred from `knowledge/` and now `continuity/`; its
  routing to `timeline.md`/`profile.md`/`canon/generated/` is unchanged. Only the one-line `continuity/`
  exclusion is added.
- **`canon/`, `canon/generated/`, `locations/`, and the freeform book-level `continuity.md`.** Canon rules
  are unchanged (a cross-reference is added to `agents/canon.md`, not a rule change); `canon/generated/`
  routing is capture's and unchanged; `locations/` stays a bare reference folder; the book-level
  `continuity.md` risk-notes file (`agents/books.md:59-66`) is left as-is and kept distinct from
  `continuity/`.
- **Dispatcher-level freshness/override for continuity state.** Detection stays in the step body as a
  derived predicate; lifting it into the dispatcher is a deferred follow-on, exactly as for artifact
  staleness (`agents/orchestrator.md:187`) and character-state staleness.
- **"Which chapter is current" for book/series.** The orchestrator TODO (`:146-148`) is unchanged; the
  multi-chapter demonstration is hand-authored, as `examples/character-state/` is.
- **The M14 retroactive follow-ups.** The knowledge-freshness per-source-chapter wording fix
  (`agents/characters.md:89`, `agents/steps/scene-knowledge-update.md:71`) and a demonstration of `revise`
  against M14's temporal-state files are **recorded on the ROADMAP Deferred list**, not executed here — M15
  states the resolved freshness rule for `continuity/` and teaches `revise` the current-vs-record discipline
  generally, but does not re-open the merged M14 step/model files beyond the item-5 knowledge-step change.
- **`install.sh`, the CI workflow ymls, and the dispatcher command/agent files.** Unchanged — adding a step
  and a support doc touches only the two `pipeline-state.md` lists, the step file, and the `AGENTS.md`
  catalogs; nothing enumerates step or doc names in those files. The `/revise` dispatcher adapters are
  unchanged too: `agents/revision.md` is the canonical contract they point at (`:5`), and only that doc is
  edited (Task 2).
