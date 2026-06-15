#!/bin/sh
# check-pipeline-state.sh — verify a pipeline-state.md against a steps directory.
#
# Usage:
#   check-pipeline-state.sh <pipeline-state-file> <steps-dir>
#       Resolvable mode (default). Parse the `## Steps` block of
#       <pipeline-state-file>; for each step_id listed, assert that
#       <steps-dir>/<step-id-with-dashes>.md exists.
#
#   check-pipeline-state.sh --exhaustive <pipeline-state-file> <steps-dir>
#       Exhaustive mode. Everything resolvable mode does, plus assert that
#       every <steps-dir>/*.md basename (dashes -> snake_case) appears in
#       the parsed step list.
#
# Exits 0 on success (prints one confirmation line), non-zero on any failure
# with a clear, path-naming error. Read-only; never modifies any file.
#
# Step-line grammar inside the `## Steps` block: a list item whose marker is
# `[ ]`, `[>]`, or `[x]` followed by a single snake_case token, e.g.
#   - [>] character_extraction
# Lines outside the `## Steps` block (or before any heading) are ignored.

set -eu

prog=check-pipeline-state.sh

err() {
    printf '%s: error: %s\n' "$prog" "$1" >&2
}

usage() {
    cat >&2 <<EOF
Usage: $prog [--exhaustive] <pipeline-state-file> <steps-dir>

  Resolvable (default): every step_id in <pipeline-state-file> must resolve
  to <steps-dir>/<step-id-with-dashes>.md.

  --exhaustive: also require that every <steps-dir>/*.md basename
  (dashes -> snake_case) appears in the parsed step list.
EOF
}

# Parse arguments.
mode=resolvable
if [ $# -ge 1 ] && [ "$1" = "--exhaustive" ]; then
    mode=exhaustive
    shift
fi

if [ $# -ne 2 ]; then
    usage
    exit 2
fi

state_file=$1
steps_dir=$2

if [ ! -f "$state_file" ]; then
    err "pipeline-state file not found: $state_file"
    exit 1
fi

if [ ! -d "$steps_dir" ]; then
    err "steps directory not found or not a directory: $steps_dir"
    exit 1
fi

# Extract step_ids from the `## Steps` block. awk emits one step_id per line.
# - Enter the block on a line that is exactly `## Steps` (allowing trailing
#   whitespace).
# - Leave the block on the next heading (any line starting with `#`).
# - Within the block, accept list items of the form
#       - [ ] step_id
#       - [>] step_id
#       - [x] step_id
#   with arbitrary leading/trailing whitespace.
steps_list=$(awk '
    /^[[:space:]]*##[[:space:]]+Steps[[:space:]]*$/ {
        in_block = 1
        next
    }
    in_block && /^[[:space:]]*#/ {
        in_block = 0
    }
    in_block {
        # Match: optional ws, `-`, ws, `[`, marker char, `]`, ws, token, ws/eol.
        if (match($0, /^[[:space:]]*-[[:space:]]+\[[ x>]\][[:space:]]+[A-Za-z0-9_]+[[:space:]]*$/)) {
            line = $0
            # Strip trailing whitespace.
            sub(/[[:space:]]+$/, "", line)
            # The step_id is the final whitespace-separated field.
            n = split(line, parts, /[[:space:]]+/)
            print parts[n]
        }
    }
' "$state_file")

if [ -z "$steps_list" ]; then
    err "no step entries found in `## Steps` block of: $state_file"
    exit 1
fi

# Resolvable check: each listed step_id must resolve to a file.
# Iterate via a here-doc fed loop (POSIX, no process substitution).
fail=0
echo "$steps_list" | while IFS= read -r step_id; do
    [ -n "$step_id" ] || continue
    # Convert snake_case -> dashes.
    step_dashed=$(printf '%s\n' "$step_id" | tr '_' '-')
    expected=$steps_dir/$step_dashed.md
    if [ ! -f "$expected" ]; then
        err "step \`$step_id\` listed in $state_file does not resolve to a step file: expected $expected"
        exit 1
    fi
done
# The subshell exit status is propagated by `set -e` because the pipeline's
# last command is the while-loop subshell. If it exited non-zero, the script
# has already aborted; otherwise we continue.

# Exhaustive check: every step file basename must appear in the list.
if [ "$mode" = exhaustive ]; then
    # Collect step file basenames (dashes -> snake_case).
    # Use a glob; if no files match, the literal pattern remains and we error.
    found_any=0
    for f in "$steps_dir"/*.md; do
        if [ ! -f "$f" ]; then
            continue
        fi
        found_any=1
        base=${f##*/}
        base=${base%.md}
        snake=$(printf '%s\n' "$base" | tr '-' '_')
        # Look for an exact-match line in steps_list.
        if ! printf '%s\n' "$steps_list" | grep -q -x "$snake"; then
            err "step file $f (step_id \`$snake\`) is missing from the \`## Steps\` list in $state_file"
            fail=1
        fi
    done
    if [ "$found_any" -eq 0 ]; then
        err "no step files (*.md) found in steps directory: $steps_dir"
        exit 1
    fi
    if [ "$fail" -ne 0 ]; then
        exit 1
    fi
fi

if [ "$mode" = exhaustive ]; then
    printf 'OK [exhaustive]: %s\n' "$state_file"
else
    printf 'OK [resolvable]: %s\n' "$state_file"
fi
