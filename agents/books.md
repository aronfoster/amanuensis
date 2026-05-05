# Book Folder Rules

Book folders are named `book1`, `book2`, `book3`, and so on.

Each book folder is the working area for one book in the series.

## Purpose of a book folder

A book folder contains the planning and drafting materials specific to that book.

A book folder should answer:
- why this book exists in the series
- what happens in this book
- how this book changes characters and plot
- what must remain unrevealed for later books

## Expected book-level files

### `overview.md`
Strategic view of the book.

Use this file for:
- the purpose of the book in the larger series
- major arcs
- major revelations
- beginning state
- ending state
- themes
- what is intentionally saved for later books

This file explains **why the book exists**.

### `outline.md`
Sequential plan for the book.

Use this file for:
- chapter-by-chapter progression
- major events in order
- reveal timing
- escalation
- major turning points

This file explains **what happens in order**. Under the current convention there is a single `outline.md` per book — the sequential plan above; projects that want a separate scratch file for early planning may keep one under any name they like, and the support doc no longer prescribes one.

### Planning artifacts
Book-specific working files used during iterative planning passes.

These are planning artifacts, not settled canon. They exist to preserve uncertainty, support reorganization, and make LLM/agent iteration easier before details are locked.

Common optional files include:
- `beats.md` — unordered or loosely ordered major beats and story fragments
- `cast.md` — book-specific cast working sheet, lighter than full character templates
- `outline.md` — current best sequential structure for the book (the same `outline.md` documented above; one per book)
- `open-questions.md` — unresolved issues blocking stronger planning (book-scoped; distinct from project-root and chapter-scoped open-questions)
- `continuity.md` — book-specific reveal timing and consistency risks

Book and chapter identity come from folder structure rather than filename prefixes; see `agents/project-layouts.md` for how book and chapter folders resolve per project type.

### `continuity.md` if present
Book-level continuity notes.

Use this file for:
- fragile reveal timing
- dependencies across chapters
- known consistency risks
- unresolved book-level continuity issues

## Book folder expectations

A book folder should contain chapter folders such as:
- `chapter01`
- `chapter02`
- `chapter03`

Do not treat book folders as generic storage.
They are structured workspaces for one book.

Keep the distinction clear:
- strategic files (`overview.md`, `outline.md`) capture the current stable plan
- planning artifacts capture provisional scaffolding and unresolved alternatives
- chapter folders handle scene-level execution workflow
