# Project layouts

Folder structure for a consuming project depends on its `project_type` (declared in `amanuensis-project.yaml`). This document is the canonical reference for resolving path placeholders used in step workflow frontmatter.

The three project types are `short_story`, `book`, and `series`.

## Conventions across all project types

- `open-questions.md` always lives at the project root, regardless of `project_type`. Steps that block write to this file.
- `pipeline-state.md` and `amanuensis-project.yaml` also live at the project root.
- **Folder paths replace filename prefixes.** Older convention used numeric prefixes like `01-01-summary.md` to encode book and chapter. The new convention uses folder structure: `<book-folder>/<chapter-folder>/summary.md`. Files inside a chapter folder use unprefixed canonical names; book and chapter identity come from the folder path, not the filename.
- `<latest-attempt>` resolves to the highest-numbered `attemptNN` directory under the chapter's `drafts/`. If none exists and the step expects one, the step creates `attempt01`.
- `<latest-draft>` resolves to the draft named by the attempt manifest's `Active-head: draft-vNN.md` pointer (see "Attempt-level provenance" below), read at step start. When the manifest has no `Active-head:` line — or no manifest exists — `<latest-draft>` falls back to the highest-numbered `draft-vNN.md` file in the current `<latest-attempt>` directory. The fallback is the no-migration path for pre-M8 attempts: existing projects resolve exactly as before, and no manifest edit is required to keep them working. A read-from override passed to the dispatcher (`run-step <step_id> from <draft-vNN>`) substitutes the named draft for `<latest-draft>` for that one invocation only.
- `<next-draft>` resolves to one greater than the **highest existing** `draft-vNN.md` number in the current `<latest-attempt>` directory — not one greater than `<latest-draft>` — zero-padded to two digits (e.g., if the highest existing draft is `draft-v03.md` then `<next-draft>` is `draft-v04.md`, even when the step is reading `draft-v01.md`). This keeps draft filenames monotonic: a branch output never collides with or renumbers an existing file. When a step creates a brand-new attempt with no existing drafts (the drafting step), `<next-draft>` is `draft-v01.md`.
- `<story-plan>` resolves to the project's top-level planning file for the work in flight. Defaults by `project_type`:
  - `short_story`: `plot/summary.md`
  - `book`: `plot/<book-folder>/overview.md`
  - `series`: `plot/<book-folder>/overview.md` (per book in flight)
  Consuming projects may override this resolution in their local `AGENTS.md` if the project keeps its planning file elsewhere.

### Attempt-level provenance: `draft-manifest.md`

Each attempt directory carries a `draft-manifest.md` alongside its versioned draft files at `<chapter-folder>/drafts/<latest-attempt>/draft-manifest.md`. The manifest is the provenance source for the attempt, not in-file frontmatter: draft files remain manuscript-only prose (see `agents/steps/drafting.md:131`).

The manifest opens with a single top-of-file pointer, written above the per-version entries (the same top-of-file shape as a report's `Reviewed-draft:` stamp):

- `Active-head: draft-vNN.md` — the single source of "which draft is active" in the attempt, and the thing `<latest-draft>` resolves to. The drafting step initializes it to `draft-v01.md` when it creates the manifest; each prose-advancing step repoints it to the draft it just wrote. There is exactly one pointer per attempt manifest; no per-entry `active` flag exists.

The manifest records, per draft version, at minimum:

- the draft file (`draft-v01.md`, `draft-v02.md`, etc.)
- `produced_by` — the step that wrote this version
- `read_from` — the draft version(s) the producing step read as input
- `timestamp` — when the version was written, as an ISO 8601 datetime with timezone offset (the same convention as `pipeline-state.md`'s `last_updated`)
- `review_gate` — the producing step's `review_required` value, copied at write time (feeds M9's review-state work)
- `superseded_by: draft-vNN.md` — present only on a displaced draft: names the draft whose creation displaced this one from the active lineage (see the algorithm below)
- side artifacts consulted or updated during the step (e.g., `reviewer-actions.md`, `metaphors.md`, `anti-ai.md`)
- a short note or pointer to the producing step's apply log, when one exists

Only prose-bearing draft files are versioned. Side artifacts (`reviewer-actions.md`, `metaphors.md`, `anti-ai.md`, `prose-pass.md`, `notes.md`) keep their semantic names and are not versioned. M3 capture annotations (the "invented, unreviewed" writes) may cite a draft version recorded here when they need a draft-version stamp.

A worked specimen. This attempt advanced linearly `v01 → v02 → v03`, then the human reran a fix step from `draft-v01` (`run-step compliance_fix from draft-v01`); the rerun wrote `draft-v04.md` (highest existing number + 1), repointed the head, and stamped the displaced `v02`/`v03` branch superseded:

```markdown
Active-head: draft-v04.md

## draft-v01.md
- produced_by: drafting
- read_from: []
- timestamp: 2026-05-18T09:04:11-06:00
- review_gate: true

## draft-v02.md
- produced_by: compliance_fix
- read_from: [draft-v01.md]
- timestamp: 2026-05-18T11:32:47-06:00
- review_gate: false
- superseded_by: draft-v04.md
- side_artifacts: [reviewer-actions.md]
- apply_log: apply log appended to `reviewer-actions.md`

## draft-v03.md
- produced_by: prose_fix
- read_from: [draft-v02.md]
- timestamp: 2026-05-18T14:16:18-06:00
- review_gate: false
- superseded_by: draft-v04.md
- side_artifacts: [prose-pass.md]

## draft-v04.md
- produced_by: compliance_fix
- read_from: [draft-v01.md]
- timestamp: 2026-05-19T10:02:33-06:00
- review_gate: false
- side_artifacts: [reviewer-actions.md]
- apply_log: apply log appended to `reviewer-actions.md`
```

`draft-v02.md` and `draft-v03.md` remain on disk, unrenamed and unmodified as prose; only their manifest entries carry the `superseded_by` stamp. `draft-v01.md` carries no stamp — it is an ancestor of the active head, not a displaced draft.

#### Lineage vocabulary

- `active_head` — the draft named by the manifest's `Active-head:` pointer; what `<latest-draft>` resolves to.
- `read_from` — the draft version(s) a draft was produced from; the "reads" edge, recorded as a per-entry field.
- `produced_by` — the step that wrote a draft version, recorded as a per-entry field.
- `supersedes` / `superseded_by` — the displacement edge: a new branch head supersedes the drafts it displaces from the active lineage; each displaced draft is stamped `superseded_by: draft-vNN.md` naming the new head.
- `lineage` — the `read_from` chain from a draft back to `draft-v01.md`; the **active lineage** is the active head's chain.
- `abandoned` — a draft that carries a `superseded_by` stamp and is not the active head. A derived predicate, not a recorded field: `superseded_by` is the recorded edge, abandonment is read off it.

#### Lineage and supersession algorithm

This is the canonical statement of the procedure; the prose-advancing step bodies reference it rather than restating it. When a prose-advancing step completes a draft write, let `R` be the draft it read (the active head, or the read-from override), `H` the active head at step start, and `N` the `<next-draft>` it just wrote. Then:

1. Set `Active-head: N`.
2. If `R ≠ H` — a branch — walk the `read_from` chain backward from `H` to `R` and stamp every draft strictly after `R`, up to and including `H`, with `superseded_by: N`. `R` itself and its ancestors are never stamped.
3. If `R = H` — a linear advance, the common case — supersede nothing.

Steps that read a draft without minting one (report and pass steps) never move the pointer and never stamp; only a step that writes `<next-draft>` runs this procedure. Branching is within-attempt: the walk never leaves the current attempt's manifest.

## short_story

The project root is the chapter equivalent. There is no book and no chapter subdivision.

```text
story-project/
  AGENTS.md
  amanuensis-project.yaml
  pipeline-state.md
  open-questions.md
  canon/
    core/
    world/
  characters/
    character_id/
      profile.md
      timeline.md
      relationships.md
  locations/
  plot/
    summary.md
    scene-list.md
    storyboards/
    drafts/
      attempt01/
        draft-v01.md
        draft-manifest.md
      attempt02/
        draft-v01.md
        draft-v02.md
        draft-manifest.md
    aftermath.md
```

Resolution rules:

- `<chapter-folder>` resolves to `plot/`.
- `<book-folder>` is undefined. Steps that reference book-level files must either handle the absence gracefully or be inapplicable to short stories.
- `<latest-attempt>` in the example above resolves to `attempt02`.

## book

A single book containing multiple chapters.

```text
book-project/
  AGENTS.md
  amanuensis-project.yaml
  pipeline-state.md
  open-questions.md
  canon/
    core/
    world/
  characters/
    character_id/
      profile.md
      timeline.md
      relationships.md
      knowledge/
        baseline.md
        book-1.md
  locations/
  plot/
    book1/
      overview.md
      outline.md
      chapter01/
        summary.md
        scene-list.md
        storyboards/
        drafts/
          attempt01/
            draft-v01.md
            draft-manifest.md
        aftermath.md
      chapter02/
        summary.md
        scene-list.md
        storyboards/
        drafts/
          attempt01/
            draft-v01.md
            draft-manifest.md
          attempt02/
            draft-v01.md
            draft-v02.md
            draft-manifest.md
        aftermath.md
```

Resolution rules:

- `<book-folder>` resolves to `plot/<book-id>/` (e.g., `plot/book1/`).
- `<chapter-folder>` resolves to `plot/<book-id>/<chapter-id>/` (e.g., `plot/book1/chapter02/`).
- `<latest-attempt>` for `chapter02` in the example above resolves to `attempt02`.

## series

Multiple books under a shared canon. The layout is the `book` layout with additional book folders alongside `book1/`.

```text
series-project/
  AGENTS.md
  amanuensis-project.yaml
  pipeline-state.md
  open-questions.md
  canon/
    core/
    world/
  characters/
    character_id/
      profile.md
      timeline.md
      relationships.md
      knowledge/
        baseline.md
        book-1.md
        book-2.md
  locations/
  plot/
    book1/
      overview.md
      outline.md
      chapter01/
        summary.md
        scene-list.md
        storyboards/
        drafts/
          attempt01/
            draft-v01.md
            draft-manifest.md
        aftermath.md
    book2/
      overview.md
      outline.md
      chapter01/
        summary.md
        scene-list.md
        storyboards/
        drafts/
          attempt01/
            draft-v01.md
            draft-manifest.md
          attempt02/
            draft-v01.md
            draft-v02.md
            draft-manifest.md
        aftermath.md
```

Resolution rules:

- Identical to `book`. The series wrapper is just `plot/` containing multiple book folders.
- `<book-folder>` resolves to `plot/<book-id>/`.
- `<chapter-folder>` resolves to `plot/<book-id>/<chapter-id>/`.
- `<latest-attempt>` for `book2/chapter01` in the example above resolves to `attempt02`.
