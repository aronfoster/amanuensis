#!/bin/bash
set -euo pipefail

# The Claude Code web sandbox has no ssh binary, so cloning submodules
# declared with an SSH URL fails. Rewrite SSH GitHub URLs to HTTPS for
# this invocation so private submodules clone via the sandbox's HTTPS
# GitHub proxy. Safe to run on every startup: already-initialized
# submodules are a no-op for `submodule update`.
if [ "${CLAUDE_CODE_REMOTE:-}" != "true" ]; then
  exit 0
fi

repo_root="${CLAUDE_PROJECT_DIR:-$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)}"
cd "$repo_root"
git -c url."https://github.com/".insteadOf="git@github.com:" \
  submodule update --init --recursive
