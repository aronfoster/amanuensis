# Metaphor Subsystem

Pipeline for identifying, reviewing, and fixing figurative language in drafted prose.

---

## Files

- `metaphor-identify.md` — extracts all live metaphors and similes from the draft; produces `xx-yy-metaphors.md`
- `metaphor-flatten.md` — generates literal rewrites for FLATTEN-marked entries
- `metaphor-replace.md` — integrates a human-supplied image for REPLACE-marked entries
- `metaphor-workshop.md` — generates constrained candidates for WORKSHOP-marked entries; one entry per session

---

## Pipeline

### Step 1 — Identify (LLM)
Run `metaphor-identify.md`. Output: `xx-yy-metaphors.md` with full entries for every live figure in the draft.

### Step 2 — Human review
Go through `xx-yy-metaphors.md`. For each entry:

- **Delete the entry** if the metaphor is sound and no action is needed.
- **Add `FLATTEN`** below the flag line if the figure should be removed.
- **Add `REPLACE: [target image]`** below the flag line if you already know the replacement.
- **Add `WORKSHOP`** below the flag line if you want candidates generated.

If any of the identify fields are wrong — tenor, implication, register fit — correct them inline or add a note below the action word. The fix passes will read your corrections and use them in place of the original assessment. You do not need to use a special format; plain language is sufficient.

Examples:

```
FLATTEN
tenor: the lie passes without scrutiny but doesn't disappear — it persists
```

```
REPLACE: [image]
register fit: this beat is colder than assessed — procedural, not intimate
```

```
WORKSHOP
implication: the model has this backwards — the sensation is expansive, not contracting
```

What remains in the file after this pass is the action queue.

### Step 3 — Flatten (LLM)
Run `metaphor-flatten.md` on all FLATTEN-marked entries. Variants are appended to each entry in `xx-yy-metaphors.md`.

### Step 4 — Replace (LLM)
Run `metaphor-replace.md` on all REPLACE-marked entries. Integration versions are appended to each entry.

### Step 5 — Workshop (LLM, one entry per session)
Run `metaphor-workshop.md` for each WORKSHOP-marked entry. Candidates are appended to the entry. Human selects or rejects. Integration versions follow.

### Step 6 — Human selection
For each entry with multiple variants, delete the variants you are not using. Leave exactly one variant per entry — the one to be written into the draft.

### Step 7 — Apply (human or future workflow)
Apply the surviving variants to the draft after human selection. A dedicated apply workflow is planned but not yet included.

---

## Working document

`xx-yy-metaphors.md` is the working document for the entire pipeline. It begins as the identify output and accumulates fix options through steps 3–5. After human selection in step 6 it becomes the apply input. Do not discard it after the pipeline completes — it is the audit record of every figurative decision made in the chapter.
