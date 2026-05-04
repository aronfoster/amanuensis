# Project layouts

Folder structure for a consuming project depends on its `project_type` (declared in `amanuensis-project.yaml`). This document is the canonical reference for resolving path placeholders used in step workflow frontmatter.

The three project types are `short_story`, `book`, and `series`.

## Conventions across all project types

- `open-questions.md` always lives at the project root, regardless of `project_type`. Steps that block write to this file.
- `pipeline-state.md` and `amanuensis-project.yaml` also live at the project root.
- **Folder paths replace filename prefixes.** Older convention used numeric prefixes like `01-01-summary.md` to encode book and chapter. The new convention uses folder structure: `<book-folder>/<chapter-folder>/summary.md`. This document declares the rule. The actual file renames happen in Milestone 4; until then existing projects retain their prefixed filenames.
- `<latest-attempt>` resolves to the highest-numbered `attemptNN` directory under the chapter's `drafts/`. If none exists and the step expects one, the step creates `attempt01`.

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
        draft.md
      attempt02/
        draft.md
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
            draft.md
        aftermath.md
      chapter02/
        summary.md
        scene-list.md
        storyboards/
        drafts/
          attempt01/
            draft.md
          attempt02/
            draft.md
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
            draft.md
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
            draft.md
          attempt02/
            draft.md
        aftermath.md
```

Resolution rules:

- Identical to `book`. The series wrapper is just `plot/` containing multiple book folders.
- `<book-folder>` resolves to `plot/<book-id>/`.
- `<chapter-folder>` resolves to `plot/<book-id>/<chapter-id>/`.
- `<latest-attempt>` for `book2/chapter01` in the example above resolves to `attempt02`.
