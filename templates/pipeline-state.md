---
project_type: short_story
last_updated: 2026-05-18T14:16:18-06:00
---

# Pipeline State

This file tracks the orchestrator's progress through the project. The line marked `[>]` is the next step the orchestrator will run. Lines marked `[x]` are complete. Lines marked `[ ]` are pending.

To redo a step, move the `[>]` marker up to that step and change downstream `[x]` markers back to `[ ]`. The orchestrator will re-run from the new position on its next invocation.

## Steps

<!-- This file is the canonical default step sequence for an Amanuensis project. Its step set must match the files in `amanuensis/agents/steps/`. -->

- [>] character_extraction
- [ ] scene_generation
- [ ] storyboarding
- [ ] drafting
- [ ] compliance_report
- [ ] compliance_fix
- [ ] prose_pass
- [ ] prose_fix
- [ ] metaphor_identify
- [ ] metaphor_fix
- [ ] metaphor_apply
- [ ] line_pass
- [ ] anti_ai_report
- [ ] anti_ai_fix
