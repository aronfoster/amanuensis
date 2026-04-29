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

This file explains **what happens in order**.

### Numbered planning artifacts (`01-*.md` for Book 1, `02-*.md` for Book 2, etc.)
Book-specific working files used during iterative planning passes.

These are planning artifacts, not settled canon. They exist to preserve uncertainty, support reorganization, and make LLM/agent iteration easier before details are locked.

Common optional files include:
- `01-beats.md` — unordered or loosely ordered major beats and story fragments
- `01-cast.md` — book-specific cast working sheet, lighter than full character templates
- `01-outline.md` — current best sequential structure for the book
- `01-open-questions.md` — unresolved issues blocking stronger planning
- `01-continuity.md` — book-specific reveal timing and consistency risks

Naming convention note:
- The leading two digits identify the **book** (for example, all Book 1 planning files start with `01-`).
- Chapter-level files use `xx-yy-...` where `xx` is the book number and `yy` is the chapter number.

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
- numbered planning artifacts capture provisional scaffolding and unresolved alternatives
- chapter folders handle scene-level execution workflow
