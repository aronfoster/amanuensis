<!-- ILLUSTRATIVE EXAMPLE — NOT REAL PROJECT CANON OR STATE. See
     examples/unreviewed-confirmation/README.md.

     draft-v01.md is drafting's output. compliance_fix's run over reviewer-actions.md
     routes both units upstream via Escalated: blocks (neither carries a prose-defect
     FIX — see the README) — no FIX decision reaches prose, so draft-v02.md is a
     byte-for-byte copy of draft-v01.md. compliance_fix still mints it and repoints
     Active-head: to it, per its completion contract (agents/steps/compliance-fix.md:
     "the step's final action is to repoint the manifest's `Active-head:` to the
     `<next-draft>` it just wrote", unconditional on a successful run). This leaves
     reviewer-actions.md's `Reviewed-draft: draft-v01.md` stamp STALE against the new
     active head (draft-v02.md) — see the README's "Closing the loop" section for the
     regenerated compliance_report re-run that follows from this. -->

Active-head: draft-v02.md

## draft-v01.md
- produced_by: drafting
- read_from: []
- timestamp: 2026-08-10T09:00:00-06:00
- review_gate: true

## draft-v02.md
- produced_by: compliance_fix
- read_from: [draft-v01.md]
- timestamp: 2026-08-10T14:20:00-06:00
- review_gate: false
- side_artifacts: [reviewer-actions.md]
- apply_log: apply log appended to `reviewer-actions.md`
