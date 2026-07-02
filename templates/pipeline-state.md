---
project_type: short_story
last_updated: 2026-05-18T14:16:18-06:00
---

# Pipeline State

This file is the project's recipe and status record. The list below gives the recommended order of steps — the happy path, not the only legal path. Lines marked `[x]` have been completed at least once; lines marked `[ ]` have not yet been completed.

Any step can be invoked selectively with `run-step`, or the recipe can be followed in recommended order with `next-step`, which runs the first non-`[x]` step in the list.

## Steps

<!-- This file is the canonical default step sequence for an Amanuensis project. Its step set must match the files in `amanuensis/agents/steps/`. -->

- [ ] character_extraction
- [ ] scene_generation
- [ ] storyboarding
- [ ] storyboard_review
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
