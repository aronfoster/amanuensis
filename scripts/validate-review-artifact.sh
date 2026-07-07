#!/bin/sh
# validate-review-artifact.sh — validate a human-gated review artifact against
# agents/review-grammars.yaml (the single grammar source; token lists and bulk
# rules are read from it, never hardcoded here).
#
# Usage:
#   validate-review-artifact.sh <artifact-file> <grammar-yaml> [<manifest-file> [<effective-draft>]]
#
# Identifies the artifact's family by matching the artifact filename against
# the grammar file's per-family `path_pattern`, parses the artifact into
# review units (anchor lines, `- Decision:` / `- Decision-note:` fields,
# category `BULK:` headers, `BULK eligibility:` declarations), and validates
# four layers, reporting ALL of them — stale is reported alongside the other
# layers, never instead of them:
#
#   state       only when <manifest-file> and/or <effective-draft> is given.
#               The artifact's top-of-file `Reviewed-draft:` stamp must equal
#               the resolved `<latest-draft>` for this invocation: the
#               manifest's `Active-head:` pointer by default, or
#               <effective-draft> (a draft filename, e.g. draft-v01.md) when
#               given — the read-from case, where a dispatcher override
#               redefines `<latest-draft>` for one invocation and freshness
#               is derived against the draft that run reads. Pass `-` as the
#               manifest placeholder to give an effective draft without a
#               manifest.
#   structural  every unit anchored, review-ids unique within the file and
#               matching the family's id shape (`id_item_pattern`,
#               `id_min_locations`), each anchor immediately above its item
#               line (`item_line_pattern`; an orphaned anchor is invalid),
#               required fields present; where the family defines a
#               `container_pattern`, a non-exempt container heading with zero
#               anchored units is invalid (a positional/pre-migration report
#               is an invalid input, not a silently empty one).
#   grammar     filled decisions hold a token from the family's token list;
#               payload-bearing tokens carry non-empty payloads; bulk headers
#               only where the family has static bulk support AND the scene's
#               `BULK eligibility:` block declares the category permitted;
#               per-entry decisions override bulk defaults; prohibitions
#               enforced (e.g. no prose-pass bulk).
#   ledger      every unit classified pending / decided-explicit /
#               decided-inherited-by-bulk / skipped / escalated / invalid,
#               with printed counts: total / pending / decided /
#               inherited-by-bulk / skipped / escalated / invalid / stale.
#               When pending units remain, their review-ids are additionally
#               listed under a `pending-review-ids:` section so a consumer
#               (a fix/apply step's blocker, the review companion) names the
#               exact remaining units from this deterministic list rather
#               than re-enumerating blank `Decision:` fields by eye.
#
# Exit codes (verdict precedence when several conditions hold:
# invalid > pending > stale > proceed — invalid units must be fixed before
# the pending count is trustworthy, and both before staleness is worth
# adjudicating):
#   0  proceed          no invalid, no pending, not stale
#   3  invalid-present  at least one invalid unit or grammar defect
#   4  pending-remain   no invalid, but pending units remain
#   5  stale            no invalid, no pending, but the artifact is stale
#   1  input error      missing/unreadable file, unrecognized artifact,
#                       family not yet adopted, malformed grammar or manifest
#   2  usage error      wrong arguments
#
# A family whose adoption marker is `pending` in the grammar file is rejected
# (exit 1) with a not-yet-adopted error naming its migrating milestone: the
# family's current in-step grammar remains authoritative until then.
#
# Read-only; never modifies any file.

set -eu

prog=validate-review-artifact.sh

err() {
    printf '%s: error: %s\n' "$prog" "$1" >&2
}

usage() {
    cat >&2 <<EOF
Usage: $prog <artifact-file> <grammar-yaml> [<manifest-file> [<effective-draft>]]

  Validate a review artifact against the grammar file (normally
  agents/review-grammars.yaml; from a consuming project,
  amanuensis/agents/review-grammars.yaml). With a manifest file given,
  additionally compare the artifact's \`Reviewed-draft:\` stamp to the
  manifest's \`Active-head:\` pointer (state layer). With <effective-draft>
  given (a draft filename, e.g. draft-v01.md — the resolved <latest-draft>
  for this invocation, such as a dispatcher read-from draft), the stamp is
  compared against it instead; pass \`-\` as the manifest placeholder to
  give an effective draft without a manifest.

  Exit codes: 0 proceed, 3 invalid-present, 4 pending-remain, 5 stale,
  1 input error, 2 usage error. Precedence: invalid > pending > stale.
EOF
}

if [ $# -lt 2 ] || [ $# -gt 4 ]; then
    usage
    exit 2
fi

artifact_file=$1
grammar_file=$2
manifest_file=${3:-}
effective_draft=${4:-}
if [ "$manifest_file" = - ]; then
    manifest_file=
fi

if [ ! -f "$artifact_file" ]; then
    err "artifact file not found: $artifact_file"
    exit 1
fi
if [ ! -f "$grammar_file" ]; then
    err "grammar file not found: $grammar_file"
    exit 1
fi
if [ -n "$manifest_file" ] && [ ! -f "$manifest_file" ]; then
    err "manifest file not found: $manifest_file"
    exit 1
fi

# Read one machine-read key for one family out of the grammar file.
# Families are top-level `name:` lines; keys are two-space-indented
# `key: value` lines beneath them. Surrounding double quotes are stripped.
yaml_get() {
    awk -v fam="$1" -v key="$2" '
        /^[a-z_][a-z0-9_]*:[[:space:]]*$/ { in_fam = ($0 ~ "^" fam ":") }
        in_fam && $0 ~ "^  " key ":" {
            line = $0
            sub(/^[^:]*:[[:space:]]*/, "", line)
            sub(/[[:space:]]+$/, "", line)
            gsub(/^"|"$/, "", line)
            print line
            exit
        }
    ' "$grammar_file"
}

# Identify the family: match the artifact basename against each family's
# path_pattern.
artifact_base=${artifact_file##*/}
families=$(awk '/^[a-z_][a-z0-9_]*:[[:space:]]*$/ { sub(/:.*/, ""); print }' "$grammar_file")
if [ -z "$families" ]; then
    err "no family definitions found in grammar file: $grammar_file"
    exit 1
fi

family=
for fam in $families; do
    pattern=$(yaml_get "$fam" path_pattern)
    [ -n "$pattern" ] || continue
    # shellcheck disable=SC2254 # pattern matching is the point
    case $artifact_base in
        $pattern) family=$fam; break ;;
    esac
done

if [ -z "$family" ]; then
    err "artifact $artifact_file matches no family path_pattern in $grammar_file (known families: $(printf '%s ' $families))"
    exit 1
fi

# Adoption gate: pending families are rejected until their milestone.
adoption=$(yaml_get "$family" adoption)
migrates_in=$(yaml_get "$family" migrates_in)
case $adoption in
    adopted) ;;
    pending)
        err "family \`$family\` ($artifact_base) is not yet adopted: its current in-step grammar remains authoritative until $migrates_in flips the adoption marker in $grammar_file"
        exit 1
        ;;
    *)
        err "family \`$family\` has no valid adoption marker in $grammar_file (found: \`${adoption:-<none>}\`)"
        exit 1
        ;;
esac

# Grammar values the parser needs (never hardcoded here).
tokens=$(yaml_get "$family" tokens)
payload_optional=$(yaml_get "$family" payload_optional)
payload_required=$(yaml_get "$family" payload_required)
payload_forbidden=$(yaml_get "$family" payload_forbidden)
bulk_supported=$(yaml_get "$family" bulk_supported)
bulk_actions=$(yaml_get "$family" bulk_actions)
bulk_payload_optional=$(yaml_get "$family" bulk_payload_optional)
container_pattern=$(yaml_get "$family" container_pattern)
container_exempt_suffix=$(yaml_get "$family" container_exempt_suffix)
id_item_pattern=$(yaml_get "$family" id_item_pattern)
id_min_locations=$(yaml_get "$family" id_min_locations)
item_line_pattern=$(yaml_get "$family" item_line_pattern)

if [ -z "$tokens" ]; then
    err "family \`$family\` defines no token list in $grammar_file"
    exit 1
fi

# State layer (only when a manifest and/or an effective draft is given). The
# comparison target is the resolved <latest-draft> for this invocation: the
# effective draft when given (the read-from case), else the manifest's
# Active-head.
stale=0
active=
if [ -n "$manifest_file" ]; then
    active=$(awk '/^Active-head:/ { print $2; exit }' "$manifest_file")
    if [ -z "$active" ]; then
        err "manifest $manifest_file carries no \`Active-head:\` pointer"
        exit 1
    fi
fi
if [ -n "$effective_draft" ] || [ -n "$manifest_file" ]; then
    stamp=$(awk '/^Reviewed-draft:/ { print $2; exit }' "$artifact_file")
    if [ -n "$effective_draft" ]; then
        target=$effective_draft
        target_desc="effective draft $effective_draft"
    else
        target=$active
        target_desc="Active-head: $active"
    fi
    if [ -z "$stamp" ]; then
        stale=1
        state_line="STALE — artifact carries no \`Reviewed-draft:\` stamp ($target_desc)"
    elif [ "$stamp" != "$target" ]; then
        stale=1
        state_line="STALE — Reviewed-draft: $stamp does not equal $target_desc"
        if [ -n "$effective_draft" ] && [ -n "$active" ]; then
            state_line="$state_line (manifest Active-head: $active)"
        fi
    else
        state_line="fresh (Reviewed-draft: $stamp equals $target_desc)"
        if [ -n "$effective_draft" ] && [ -n "$active" ] && [ "$active" != "$effective_draft" ]; then
            state_line="fresh (Reviewed-draft: $stamp equals $target_desc; manifest Active-head: $active overridden by read-from)"
        fi
    fi
else
    state_line="not checked (no manifest file given)"
fi

# Structural + grammar + ledger layers: one line-oriented pass over the
# artifact. The awk program prints findings (one per line, prefixed
# "  line N:") followed by machine lines:
#   #COUNTS pending decided inherited skipped escalated invalid
#   #PENDING <review-id> <review-id> ...   (only when pending units remain)
report=$(awk \
    -v family="$family" \
    -v tokens="$tokens" \
    -v payload_optional="$payload_optional" \
    -v payload_required="$payload_required" \
    -v payload_forbidden="$payload_forbidden" \
    -v bulk_supported="$bulk_supported" \
    -v bulk_actions="$bulk_actions" \
    -v bulk_payload_optional="$bulk_payload_optional" \
    -v container_pattern="$container_pattern" \
    -v container_exempt="$container_exempt_suffix" \
    -v id_item_pattern="$id_item_pattern" \
    -v id_min_locations="${id_min_locations:-0}" \
    -v item_line_pattern="$item_line_pattern" \
'
function in_list(tok, list,    i, n, arr) {
    if (tok == "" || list == "") return 0
    n = split(list, arr, /[[:space:]]+/)
    for (i = 1; i <= n; i++) if (arr[i] == tok) return 1
    return 0
}
function finding(line, msg) {
    printf "  line %d: %s\n", line, msg
}
# Close the current review-unit container (structural layer). A non-exempt
# container holding zero anchored units is the positional/pre-migration
# format (or missing anchors) and is invalid.
function close_container() {
    if (container_line == 0) return
    if (container_units == 0) {
        finding(container_line, "unanchored violation block `" container_name "` — positional/pre-M10 format or missing anchors")
        defects++
    }
    container_line = 0; container_name = ""; container_units = 0
}
# Close the currently open review unit, classifying it into a ledger bucket.
function close_unit(    key) {
    if (cur_id == "") return
    if (invalid_reason != "") {
        invalid++
        finding(reason_line, invalid_reason)
    } else if (!have_decision) {
        invalid++
        finding(anchor_line, "unit `" cur_id "` has no `- Decision:` field (required)")
    } else if (dec_blank) {
        key = scene SUBSEP cur_cat
        if (bulk_ok[key]) inherited++
        else { pending++; pending_list = pending_list (pending_list == "" ? "" : " ") cur_id }
    } else if (dec_token == "SKIP") {
        skipped++
    } else if (dec_token == "ESCALATE") {
        escalated++
    } else {
        decided++
    }
    cur_id = ""; have_decision = 0; dec_blank = 0; dec_token = ""
    invalid_reason = ""; reason_line = 0
}
# Anchor adjacency (structural layer): the line immediately after an anchor
# must be the unit item line per the family item_line_pattern — not another
# anchor, not a Decision field, not a blank line. This rule runs before the
# anchor rule, so an anchor directly following an anchor orphans the first.
expect_item {
    expect_item = 0
    if (item_line_pattern != "" && invalid_reason == "" && \
        ($0 ~ /^[[:space:]]*-[[:space:]]+Decision(-note)?:/ || $0 !~ item_line_pattern)) {
        invalid_reason = "orphaned anchor `" cur_id "` — the line immediately after the anchor is not the unit item line"
        reason_line = anchor_line
    }
}
# Anchor line: opens a new review unit.
/^[[:space:]]*<!--[[:space:]]*review-id:/ {
    close_unit()
    id = $0
    sub(/^[[:space:]]*<!--[[:space:]]*review-id:[[:space:]]*/, "", id)
    sub(/[[:space:]]*-->[[:space:]]*$/, "", id)
    cur_id = id
    anchor_line = NR
    expect_item = 1
    if (container_line > 0) container_units++
    if (id in seen) {
        invalid_reason = "duplicate review-id `" id "`"
        reason_line = NR
    } else if (index(id, family ":") != 1) {
        invalid_reason = "review-id `" id "` does not begin with `" family ":`"
        reason_line = NR
    } else {
        # id shape: <family>:<location...>:<item-id> — the item segment must
        # match the family pattern, with at least id_min_locations location
        # segments between the family prefix and the item-id, none empty.
        nseg = split(id, seg, ":")
        if (nseg < 2 || seg[nseg] == "") {
            invalid_reason = "review-id `" id "` has no item-id segment"
            reason_line = NR
        } else if (id_item_pattern != "" && seg[nseg] !~ ("^(" id_item_pattern ")$")) {
            invalid_reason = "review-id `" id "` item segment `" seg[nseg] "` does not match the family shape `" id_item_pattern "`"
            reason_line = NR
        } else if (nseg - 2 < id_min_locations + 0) {
            invalid_reason = "review-id `" id "` has too few location segments (family requires at least " id_min_locations + 0 ")"
            reason_line = NR
        } else {
            for (i = 2; i < nseg; i++) {
                if (seg[i] == "") {
                    invalid_reason = "review-id `" id "` has an empty location segment"
                    reason_line = NR
                    break
                }
            }
        }
    }
    seen[id] = 1
    next
}
# BULK eligibility declaration block (the report'\''s dynamic layer).
/^BULK eligibility:[[:space:]]*$/ { in_elig = 1; next }
in_elig {
    if ($0 ~ /^-[[:space:]]/ && index($0, ": BULK ") > 0) {
        cat = $0
        sub(/^-[[:space:]]+/, "", cat)
        pos = index(cat, ": BULK ")
        perm = substr(cat, pos + 2)
        cat = substr(cat, 1, pos - 1)
        if (perm ~ /^BULK permitted/) elig[scene SUBSEP cat] = 1
        next
    }
    in_elig = 0
}
# Category BULK header (validated in both layers: static family support and
# the dynamic per-scene eligibility declaration).
/^BULK:/ {
    close_unit()
    rest = $0
    sub(/^BULK:[[:space:]]*/, "", rest)
    sub(/[[:space:]]+$/, "", rest)
    if (bulk_supported != "yes") {
        finding(NR, "bulk header illegal: family `" family "` has no bulk support")
        defects++
        next
    }
    if (cur_cat == "") {
        finding(NR, "bulk header outside any category subsection")
        defects++
        next
    }
    if (!((scene SUBSEP cur_cat) in elig)) {
        finding(NR, "bulk header on category `" cur_cat "` not declared `BULK permitted` in the BULK eligibility block of scene " scene)
        defects++
        next
    }
    if (match(rest, /^[A-Z]+$/)) {
        act = rest; act_payload = ""; has_payload = 0
    } else if (index(rest, ":") > 1) {
        act = substr(rest, 1, index(rest, ":") - 1)
        act_payload = substr(rest, index(rest, ":") + 1)
        gsub(/^[[:space:]]+/, "", act_payload)
        has_payload = 1
    } else {
        finding(NR, "malformed bulk header `BULK: " rest "`")
        defects++
        next
    }
    if (!in_list(act, bulk_actions)) {
        finding(NR, "illegal bulk action `" act "` (legal: " bulk_actions ")")
        defects++
        next
    }
    if (has_payload && !in_list(act, bulk_payload_optional)) {
        finding(NR, "bulk action `" act "` does not take an instruction payload")
        defects++
        next
    }
    if (has_payload && act_payload == "") {
        finding(NR, "bulk action `" act "` has a colon but an empty instruction payload")
        defects++
        next
    }
    bulk_ok[scene SUBSEP cur_cat] = 1
    next
}
# Headings close the open unit — unless the heading is the anchored item
# itself (anchor on the immediately preceding line, as in prose_pass and
# metaphor items whose unit begins at a heading).
/^#/ {
    if (cur_id != "" && NR != anchor_line + 1) close_unit()
    close_container()
    if (container_pattern != "" && index($0, container_pattern) == 1) {
        line = $0
        sub(/[[:space:]]+$/, "", line)
        if (container_exempt == "" || \
            substr(line, length(line) - length(container_exempt) + 1) != container_exempt) {
            container_line = NR
            container_name = line
        }
    }
    if ($0 ~ /^##[^#]/) {
        if (match($0, /Scene[[:space:]]+[^ ,]+/)) {
            scene = substr($0, RSTART + 6, RLENGTH - 6)
            sub(/^[[:space:]]+/, "", scene)
            sub(/[,[:space:]]+$/, "", scene)
        }
        cur_cat = ""
    } else if ($0 ~ /^###[^#]/) {
        cat = $0
        sub(/^###[[:space:]]*/, "", cat)
        sub(/[[:space:]]+$/, "", cat)
        cur_cat = cat
    }
    next
}
# Decision field.
/^[[:space:]]*-[[:space:]]+Decision:/ {
    if (cur_id == "") {
        finding(NR, "`- Decision:` field outside any anchored review unit")
        defects++
        next
    }
    if (have_decision) {
        finding(NR, "second `- Decision:` field under review-id `" cur_id "` — unanchored item?")
        defects++
        next
    }
    have_decision = 1
    rest = $0
    sub(/^[[:space:]]*-[[:space:]]+Decision:[[:space:]]*/, "", rest)
    sub(/[[:space:]]+$/, "", rest)
    if (rest == "") { dec_blank = 1; next }
    if (match(rest, /^[A-Z]+$/)) {
        tok = rest; payload = ""; has_payload = 0
    } else if (match(rest, /^[A-Z]+:/)) {
        tok = substr(rest, 1, index(rest, ":") - 1)
        payload = substr(rest, index(rest, ":") + 1)
        gsub(/^[[:space:]]+/, "", payload)
        has_payload = 1
    } else {
        invalid_reason = "malformed decision `" rest "` (expected a legal token, optionally `<TOKEN>: <payload>`)"
        reason_line = NR
        next
    }
    if (!in_list(tok, tokens)) {
        invalid_reason = "illegal token `" tok "` for family `" family "` (legal: " tokens ")"
        reason_line = NR
        next
    }
    if (has_payload && payload == "") {
        invalid_reason = "token `" tok "` has a colon but an empty payload"
        reason_line = NR
        next
    }
    if (has_payload && !in_list(tok, payload_optional) && !in_list(tok, payload_required)) {
        invalid_reason = "token `" tok "` does not take a payload"
        reason_line = NR
        next
    }
    if (!has_payload && in_list(tok, payload_required)) {
        invalid_reason = "token `" tok "` requires a non-empty payload (`" tok ": <payload>`)"
        reason_line = NR
        next
    }
    dec_token = tok
    next
}
END {
    if (expect_item && cur_id != "" && invalid_reason == "") {
        invalid_reason = "orphaned anchor `" cur_id "` — no item line follows the anchor"
        reason_line = anchor_line
    }
    close_unit()
    close_container()
    printf "#COUNTS %d %d %d %d %d %d\n", \
        pending, decided, inherited, skipped, escalated, invalid + defects
    if (pending_list != "") printf "#PENDING %s\n", pending_list
}
' "$artifact_file")

counts=$(printf '%s\n' "$report" | awk '/^#COUNTS/ { print; exit }')
pending_ids=$(printf '%s\n' "$report" | awk '/^#PENDING/ { sub(/^#PENDING /, ""); print; exit }')
findings=$(printf '%s\n' "$report" | grep -v '^#COUNTS' | grep -v '^#PENDING' || true)

# shellcheck disable=SC2086 # word splitting of the counts line is intended
set -- $counts
pending=$2 decided=$3 inherited=$4 skipped=$5 escalated=$6 invalid=$7
total=$((pending + decided + inherited + skipped + escalated + invalid))

# Verdict. Precedence: invalid > pending > stale > proceed.
if [ "$invalid" -gt 0 ]; then
    verdict=invalid-present; code=3
elif [ "$pending" -gt 0 ]; then
    verdict=pending-remain; code=4
elif [ "$stale" -eq 1 ]; then
    verdict=stale; code=5
else
    verdict=proceed; code=0
fi

printf '%s: %s — family: %s (%s)\n' "$prog" "$artifact_file" "$family" "$adoption"
printf 'state: %s\n' "$state_line"
if [ -n "$findings" ]; then
    printf 'findings:\n%s\n' "$findings"
else
    printf 'findings: none\n'
fi
printf 'ledger:\n'
printf '  total: %d\n' "$total"
printf '  pending: %d\n' "$pending"
printf '  decided: %d\n' "$decided"
printf '  inherited-by-bulk: %d\n' "$inherited"
printf '  skipped: %d\n' "$skipped"
printf '  escalated: %d\n' "$escalated"
printf '  invalid: %d\n' "$invalid"
printf '  stale: %d\n' "$stale"
if [ "$pending" -gt 0 ]; then
    printf 'pending-review-ids:\n'
    for id in $pending_ids; do
        printf '  %s\n' "$id"
    done
fi
printf 'verdict: %s (exit %d)\n' "$verdict" "$code"
exit "$code"
