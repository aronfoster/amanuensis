#!/bin/sh
# install.sh — install Amanuensis into a consuming project.
#
# Usage:
#   ./install.sh                 # install into current working directory
#   ./install.sh <target-dir>    # install into <target-dir>
#
# Always overwrites (framework dispatcher files):
#   templates/dispatcher/.claude/commands/next-step.md
#       -> <target>/.claude/commands/next-step.md
#   templates/dispatcher/.opencode/agents/next-step.md
#       -> <target>/.opencode/agents/next-step.md
#   templates/dispatcher/.claude/hooks/session-start.sh
#       -> <target>/.claude/hooks/session-start.sh
#
# Created only if missing (project scaffold; preserves user edits and
# pipeline state on re-run):
#   templates/amanuensis-project.yaml -> <target>/amanuensis-project.yaml
#   templates/pipeline-state.md       -> <target>/pipeline-state.md
#   templates/project-AGENTS.md       -> <target>/AGENTS.md
#   templates/voice.md                -> <target>/voice.md
#   templates/dispatcher/.claude/settings.json
#       -> <target>/.claude/settings.json
#   (empty file)                      -> <target>/open-questions.md

set -eu

err() {
    printf 'install.sh: error: %s\n' "$1" >&2
}

# Resolve the script's own directory in a POSIX-portable way.
script_path=$0
case $script_path in
    /*) ;;
    *) script_path=$PWD/$script_path ;;
esac
script_dir=$(dirname "$script_path")
script_dir=$(cd "$script_dir" && pwd)

# Determine target directory.
if [ $# -gt 1 ]; then
    err "too many arguments; usage: $0 [<target-dir>]"
    exit 2
fi

if [ $# -eq 1 ]; then
    target=$1
else
    target=$PWD
fi

if [ ! -d "$target" ]; then
    err "target directory does not exist: $target"
    exit 1
fi

if [ ! -w "$target" ]; then
    err "target directory is not writable: $target"
    exit 1
fi

# Source files.
src_claude=$script_dir/templates/dispatcher/.claude/commands/next-step.md
src_opencode=$script_dir/templates/dispatcher/.opencode/agents/next-step.md
src_session_hook=$script_dir/templates/dispatcher/.claude/hooks/session-start.sh
src_settings=$script_dir/templates/dispatcher/.claude/settings.json
src_project_yaml=$script_dir/templates/amanuensis-project.yaml
src_pipeline_state=$script_dir/templates/pipeline-state.md
src_agents=$script_dir/templates/project-AGENTS.md
src_voice=$script_dir/templates/voice.md

for src in "$src_claude" "$src_opencode" "$src_session_hook" \
           "$src_settings" "$src_project_yaml" \
           "$src_pipeline_state" "$src_agents" "$src_voice"; do
    if [ ! -f "$src" ]; then
        err "missing source file: $src"
        exit 1
    fi
done

# Dispatcher destinations (always overwrite).
dst_claude_dir=$target/.claude/commands
dst_opencode_dir=$target/.opencode/agents
dst_hooks_dir=$target/.claude/hooks
dst_claude=$dst_claude_dir/next-step.md
dst_opencode=$dst_opencode_dir/next-step.md
dst_session_hook=$dst_hooks_dir/session-start.sh

mkdir -p "$dst_claude_dir"
mkdir -p "$dst_opencode_dir"
mkdir -p "$dst_hooks_dir"

cp "$src_claude" "$dst_claude"
cp "$src_opencode" "$dst_opencode"
cp "$src_session_hook" "$dst_session_hook"
chmod +x "$dst_session_hook"

printf '  %s -> %s\n' "$src_claude" "$dst_claude"
printf '  %s -> %s\n' "$src_opencode" "$dst_opencode"
printf '  %s -> %s\n' "$src_session_hook" "$dst_session_hook"

# Scaffold destinations (create only if missing).
dst_project_yaml=$target/amanuensis-project.yaml
dst_pipeline_state=$target/pipeline-state.md
dst_agents=$target/AGENTS.md
dst_settings=$target/.claude/settings.json
dst_voice=$target/voice.md
dst_open_questions=$target/open-questions.md

install_if_missing() {
    _src=$1
    _dst=$2
    if [ -e "$_dst" ]; then
        printf '  skipped (exists): %s\n' "$_dst"
    else
        cp "$_src" "$_dst"
        printf '  %s -> %s\n' "$_src" "$_dst"
    fi
}

install_if_missing "$src_project_yaml" "$dst_project_yaml"
install_if_missing "$src_pipeline_state" "$dst_pipeline_state"
install_if_missing "$src_agents" "$dst_agents"
install_if_missing "$src_settings" "$dst_settings"
install_if_missing "$src_voice" "$dst_voice"

if [ -e "$dst_open_questions" ]; then
    printf '  skipped (exists): %s\n' "$dst_open_questions"
else
    : > "$dst_open_questions"
    printf '  created empty: %s\n' "$dst_open_questions"
fi

printf 'Installed Amanuensis into %s.\n' "$target"
