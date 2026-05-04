# Amanuensis Agent Guide

Use the guidance in `agents/` for reusable long-form writing workflows.

## Where to look

- `agents/update-rules.md` — start here for safety rules around canon integrity, reveal timing, and downstream updates.
- `agents/workflows.md` — workflow order for book setup, chapter planning, drafting, continuity review, and post-chapter updates.
- `agents/canon.md` — rules for world-level truth files.
- `agents/books.md` — rules for book-level planning folders.
- `agents/chapters.md` — rules for chapter workflow files.
- `agents/characters.md` — rules for character profiles, knowledge state, timelines, and relationships.
- `agents/storyboarding.md` and `agents/storyboard-schema.md` — storyboard workflow and schema.
- `agents/drafting.md` and `agents/agentic-drafting.md` — drafting workflows.
- `agents/compliance.md`, `agents/prose-pass.md`, `agents/anti-ai.md`, and `agents/metaphor/` — review and revision passes.

## Repository Boundary

Amanuensis is tooling, not story canon. Do not add project-specific canon, character state, plot files, or prose drafts here except as clearly marked examples.

Consuming story repositories should keep a small local `AGENTS.md` adapter that points back to these reusable workflows and defines project-local paths.

## Next Task Queueing

After completing a task, provide the next step text to the user so he can copy-paste it. When starting a new Sprint, use **PM New Sprint**. When uncompleted tasks remain in SPRINT.md, use **Developer Step for Sprint Task**. When all tasks are complete in SPRINT.md, use **PM Sprint Closeout**. After the closeout, provide **PM New Sprint**.

### PM New Sprint
You are an expert PM. See AGENTS.md, ROADMAP.md, and BUGS.md. We're going to work together to turn [next milestone number and title from ROADMAP.md] into a series of Tasks within SPRINT.md. We will focus on requirements, not implementation. However, we will provide specifics, even code, if it will answer necessary design decisions for the developer. The goal is that our developers can grab a task and complete it in the way they want, with minimal intervention, and they'll produce a result that meets the customer's needs. This is the stage to ask questions.

### Developer Step for Sprint Task
See AGENTS.md and SPRINT.md. Complete Sprint [Sprint number from SPRINT.md header] Task [First incomplete task in SPRINT.md].

### PM Sprint Closeout
Complete Sprint [Sprint number from SPRINT.md header] from SPRINT.md. See AGENTS.md for additional guidance. Close out the Sprint, ensuring that all markdown files are up to date (including architecture, readme, roadmap, and runbook; but please search and assess all markdown files in the project) and all objectives have been met. Do not erase or overwrite SPRINT.md, just mark items completed.
