#!/usr/bin/env bash
# Validate natural-language entry guidance without sdd.* wrapper commands.

set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
failures=0

fail() {
    echo "ERROR: $*" >&2
    failures=$((failures + 1))
}

if find "$ROOT_DIR/commands" -maxdepth 1 -type f -name 'sdd.*.md' | grep -q .; then
    fail "commands/sdd.*.md wrapper commands must not be distributed."
fi

if find "$ROOT_DIR/commands" -maxdepth 1 -type f -name 'dev.*.md' | grep -q .; then
    fail "legacy commands/dev.*.md files must not remain."
fi

if find "$ROOT_DIR/codex-skills" -maxdepth 1 -type d -name 'sdd-*' | grep -q .; then
    fail "codex-skills/sdd-* wrapper skills must not be distributed."
fi

if find "$ROOT_DIR/codex-skills" -maxdepth 1 -type d -name 'dev-*' | grep -q .; then
    fail "legacy codex-skills/dev-* directories must not remain."
fi

agent_template="$ROOT_DIR/templates/AGENTS.template.md"
[ -f "$agent_template" ] || fail "templates/AGENTS.template.md is required."
if [ -f "$agent_template" ]; then
    grep -Eq 'Users do not need to type slash commands' "$agent_template" || fail "AGENTS template must state users do not type slash commands."
    grep -Eq 'speckit\.constitution' "$agent_template" || fail "AGENTS template must require speckit.constitution before development."
    grep -Eq '下一步|next step' "$agent_template" || fail "AGENTS template must support 下一步/next step continuation."
    grep -Eq 'Step Gate Policy|One internal command per user turn' "$agent_template" || fail "AGENTS template must enforce step gate policy."
    grep -Eq 'speckit\.\*|harness\.\*' "$agent_template" || fail "AGENTS template must route directly through speckit.* and harness.* commands."
    if grep -Eq 'sdd\.' "$agent_template"; then
        fail "AGENTS template must not reference sdd.* wrapper commands."
    fi
fi

if [ "$failures" -gt 0 ]; then
    echo "SDD entrypoint validation failed with $failures issue(s)." >&2
    exit 1
fi

echo "SDD entrypoint validation passed."
