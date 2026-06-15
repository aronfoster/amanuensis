# Character Folder Rules

Each character folder represents one character's canonical identity and changing story state.

## Purpose of a character folder

Character folders exist to separate stable character facts from evolving character state.

## Expected character files

### `profile.md`
Stable character core.

Use this file for:
- identity
- role in story
- motivations
- fear
- flaw
- wound
- strengths
- limits
- voice
- arc shape
- continuity constraints

Do not use this file for chapter-by-chapter updates.

### `timeline.md`
Chronological record for the character.

Use this file for:
- life events
- important pre-story events
- major story events affecting the character

### `relationships.md`
Relationship dynamics.

Use this file for:
- important connections
- changing interpersonal dynamics
- power balance
- misunderstandings
- loyalties and fractures

### `knowledge/`
Knowledge-state tracking. One file per book, plus a baseline file for pre-story state.

- `baseline.md` — what the character knows before the story begins
- `book-1.md`, `book-2.md`, etc. — knowledge acquired or changed during each book

Each file contains structured entries, not flat bullets. See **Knowledge file format** below.

This is one of the most important systems in the repository.

## Knowledge file format

Each knowledge entry is a discrete fact with a short searchable heading and structured fields. See the [knowledge-book.md](templates/knowledge-book.md) template for details.

Knowledge items are only written to these files during the **scene knowledge update** workflow, after drafting confirms what the scene committed. Storyboarding reads these files as inputs; it does not write to them.

## Character update expectations

When chapter events change:
- knowledge
- belief
- suspicion
- relationship state
- timeline facts

update the relevant character files or note the missing update explicitly, following the workflows in `agents/workflows.md`.

## Creating a new character folder

When a character is expected to appear in an upcoming scene and no character folder exists yet, create the folder and base files before storyboarding that scene.

**Minimum required files:**

- `profile.md` — fill in identity, role, and any continuity constraints known at this time; leave unknown fields explicitly blank rather than invented
- `knowledge/baseline.md` — what the character knows before the story begins
- `knowledge/book_n.md` for each book they appear in — create as empty scaffolds; fill during scene knowledge updates

**Optional at creation, required before the character affects plot:**

- `timeline.md`
- `relationships.md`

**Where to create:** `characters/<character_id>/`

Use the character's `character_id` (snake_case) as the folder name. If the character is named but their role is not yet settled, create a minimal profile and mark `status: stub` in the frontmatter.

Invention here is governed by Rule 1 in `agents/update-rules.md`. A character's identity and other character-knowledge-load-bearing fields are load-bearing, so Rule 1 forbids inventing them: leave a genuinely-unknown such field uncertain rather than invented, and record that uncertainty explicitly.
