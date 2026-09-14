---
step_id: storyboarding
review_required: true
inputs:
  - <chapter-folder>/scene-list.md
  - <chapter-folder>/summary.md
  - <chapter-folder>/storyboards-planning.md
  - <prior-scene-storyboards>
  - characters/<character-id>/knowledge/*.md
  - canon/**/*.md
outputs:
  - <chapter-folder>/storyboards/<scene-id>-<beat-id>-storyboard.md
preconditions:
  - path: <chapter-folder>/scene-list.md
    kind: source
    required: true
    review_sensitive: false
  - path: <chapter-folder>/summary.md
    kind: source
    required: true
    review_sensitive: false
  - path: <chapter-folder>/storyboards-planning.md
    kind: source
    required: false
    review_sensitive: false
  - path: <prior-scene-storyboards>
    kind: source
    required: false
    review_sensitive: false
  - path: characters/<character-id>/knowledge/*.md
    kind: source
    required: true
    review_sensitive: false
  - path: canon/**/*.md
    kind: source
    required: false
    review_sensitive: false
---

See `agents/orchestrator.md` for the step workflow contract.

# Storyboarding

## Purpose

Translates scene-level intent into ordered sets of beat-level plans that the drafting step can execute without opening any other project file. Each scene's ordered storyboard set is a self-contained unit of dramatic intent, prior-reader context, and structured guardrails — the bridge between scene-list planning and prose.

## Inputs

- `<chapter-folder>/scene-list.md` — scene list for the chapter.
- `<chapter-folder>/summary.md` — chapter summary.
- `<chapter-folder>/storyboards-planning.md` — storyboard planning notes (if present).
- `<prior-scene-storyboards>` — for the first planned scene of a continuing `book` or `series`, the immediately preceding scene's planned blocks, resolved by `agents/project-layouts.md`. `required: false` because it is undefined for a work opening and for `short_story`; when it exists, read only this targeted scene, never prior prose or the prior storyboard corpus.
- character knowledge files under `characters/<character-id>/knowledge/` — applicable information covering what each character knows in the scene.
- Any canon or character reference files linked from the scene list.

## Behavior

Process scenes in the canonical order declared by `<chapter-folder>/scene-list.md`; within each scene, process beats in their declared order. Produce one storyboard file per storyboard block at `<chapter-folder>/storyboards/<scene-id>-<beat-id>-storyboard.md`.

Scene-entry derivation is sequential even if the host later parallelizes file creation. Before resolving scene N+1, the coordinator must plan the reader-visible outcomes and exit state of scene N. Any parallel worker receives the two scene-entry fields already frozen by that canonical-order pass; it must not infer prior-reader context independently.

### What a Storyboard Block Is

A storyboard block is YAML frontmatter followed by markdown field sections, ending with the `Beat` production-notes paragraph.

The YAML frontmatter carries short structured values used for grouping, ordering, point of view, beat type, and pace. The markdown sections carry the planning information the LLM needs to make decisions about prior-reader context, character behavior, concealment, canon constraints, and dramatic intent. Neither part is sufficient alone.

For field definitions see `agents/storyboard-schema.md`.

Populate `reader_takeaway` for every block — what the reader must understand, feel, or infer by the beat's end. The field is defined in `agents/storyboard-schema.md`; like `concealment_from_reader`, it defaults to filled.

### Deriving scene-entry context

Before writing scene blocks, maintain a compact, planning-only reader-state ledger while walking the scene list in canonical order. This is working state for the storyboarding run, not a new output artifact and not a transcript of prior scenes.

For the opening scene of the entire work, put the schema's exact opening sentinels in the first block:

- `Reader state in`: `Opening scene — no prior reader state.`
- `Since previous scene`: `Opening scene — no previous scene.`

A chapter or planning-batch boundary is not an opening scene. For the first scene in a continuing work, seed the rolling state from `<prior-scene-storyboards>` — the immediately preceding planned scene's reader takeaways, reader-visible outcomes, final character states, and staging — together with the current summary, scene-list, and optional storyboard-planning boundary notes. Character knowledge and canon may constrain the current beats, but they do not prove what the reader already experienced and must not seed these fields unless the declared planned boundary sources establish the same reader-visible fact. If the declared boundary inputs do not establish enough prior-reader or transition context to make the scene independently draftable, record a blocker; do not use the opening sentinels, guess, scan earlier storyboards, or read prior prose.

For every later scene, derive the two first-block fields before writing that scene's beat-level details:

1. **Reader state in.** Select from the rolling ledger only the already-established reader knowledge or experience relevant to executing this scene. Include conditions whose continued existence should remain implicit rather than trigger a fresh establishing passage. Do not include information first revealed in the current or a future scene.
2. **Since previous scene.** Compare the previous scene's close with the current scene's planned opening. Use the previous scene's reader takeaways, reader-visible beat outcomes, final character states, and established staging together with the current scene-list entry. Record relevant changes and any material non-change whose omission would invite repetition or drift. Do not include developments that occur during the current scene.
3. Put both sections in the scene's first block (the lowest `beat_index`) and omit them from its later blocks. The fields describe the scene boundary once; they are available to the drafter alongside every other block in the scene.
4. After all blocks for the scene are complete, advance the rolling ledger with the scene's reader takeaways and other reader-visible outcomes. Exclude concealed information and character-only knowledge. Supersede changed conditions rather than carrying both old and new values forward, retain still-relevant unchanged conditions, and prune facts irrelevant to subsequent execution before deriving the next scene.

The two fields are context, not prose requirements. Their presence does not add an item to `must_preserve`, and storyboarding must not turn them into recap or transition sentences.

The beat description should read as a director's note — plain language, present tense, focused on dramatic intent. It must answer what happens, what is felt, and what the prose must accomplish that the YAML fields cannot capture.

### Independent Draftability

Every scene's ordered block set must be self-contained enough that drafting can run on it using only the selected voice file or profile and those blocks. The first block carries the scene-entry context; every block carries its own beat-level requirements.

This is a quality check on the storyboard set, not a constraint on the drafter. If the scene cannot be drafted without consulting the scene list, a prior scene, a character file, or a canon document, the set is incomplete. Cross-scene reader context belongs in `Reader state in` or `Since previous scene`; beat-local information belongs in `canon_active`, `character_state_in`, or the beat description. Do not duplicate the two scene-entry sections in later blocks merely to make each block independently draftable: the execution boundary is the complete scene.

---

### Anti-Patterns

**Writing finished prose during storyboarding.** Drafting is for writing the novel. Storyboarding is for setting up drafting for success. If storyboarding output contains subordinate clauses doing atmospheric work, sensory detail, or voice, it has drifted into drafting. Regenerate the block, not the prose.

**Vague beat descriptions.** "The characters talk" is not a beat description. The paragraph must answer what happens, what is felt, and what the prose must accomplish that the YAML fields cannot capture.

**Scene-blind parallel storyboarding.** Do not derive multiple scenes independently and ask each worker to reconstruct what came before. Resolve and freeze scene-entry context in canonical order before any parallel block elaboration.

**Copying the previous scene into Reader state in.** Carry forward only context relevant to the new scene. Do not paste every prior takeaway, beat outcome, or continuity fact.

**Treating canon or character knowledge as reader knowledge.** A fact belongs in `Reader state in` only if the reader already has it. Concealed truth and facts known only by a character remain excluded.

**Using the current scene to manufacture its own entry state.** Current-scene and future reveals belong in their beat fields and later reader takeaways, never in the scene's input state.

**Narrating the transition in Since previous scene.** Record the cross-scene delta as specification. Do not write a bridge passage or imply that the drafter must mention the transition.

**Empty concealment fields.** `concealment_from_reader` is the most commonly skipped field and the most consequential for series-long reveal integrity. An empty field is only correct after explicitly confirming the beat contains no active canon guardrails. Default to filling it.

**Empty reader_takeaway.** `reader_takeaway` is the positive counterpart to `concealment_from_reader` — the beat's comprehension target. An empty field is only correct after explicitly confirming the beat genuinely asks nothing of the reader's understanding. Default to filling it.

**Word targets instead of pace signals.** The `pace` field — `compressed`, `measured`, or `expansive` — is the correct way to signal how much room the beat earns. Pace is a tempo instruction, not a count. Do not write target word counts into the beat description.

## Outputs

- `<chapter-folder>/storyboards/<scene-id>-<beat-id>-storyboard.md` — one file per storyboard block. Each file is YAML frontmatter (per `agents/storyboard-schema.md`) followed by markdown field sections and a beat description paragraph. The first block of each scene includes `Reader state in` and `Since previous scene`; later blocks omit those two sections. The file name encodes the scene id and beat id; resolve `<chapter-folder>` per `agents/project-layouts.md`.

## Open questions handling

If the step cannot complete because of missing or ambiguous inputs — including a continuing work whose declared inputs do not establish enough prior-reader or transition context for its first planned scene — append the blocker to the project root `open-questions.md` and exit without recording completion in `pipeline-state.md`. Do not fabricate inputs, substitute the opening-scene sentinels at a chapter boundary, read undeclared prior prose, or write partial outputs. The next dispatcher invocation will re-run this step after the human resolves the blocker. On a successful run, the step's final action is to mark its own step line `[x]` in `pipeline-state.md` and update `last_updated`.
