# Story Repository Layout Example

Recommended layout for a project that consumes Amanuensis:

```text
story-project/
  AGENTS.md
  README.md
  amanuensis/
  .opencode/
    agents/
    package.json
    package-lock.json
    .amanuensis-sync.json
  canon/
    core/
    world/
    open_questions/
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
        01-01-summary.md
        01-01-scene-list.md
        storyboards/
        drafts/
        aftermath.md
```

This layout is a convention, not a hard requirement. If a project uses different paths, document them in the project-local `AGENTS.md` adapter.
