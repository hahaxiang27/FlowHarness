#!/usr/bin/env bash
# Validate no high-level wrapper Codex skills remain in source.

set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
SKILLS_DIR="$ROOT_DIR/codex-skills"
failures=0

fail() {
    echo "ERROR: $*" >&2
    failures=$((failures + 1))
}

if [ -d "$SKILLS_DIR" ] && find "$SKILLS_DIR" -maxdepth 1 -type d -name 'sdd-*' | grep -q .; then
    fail "codex-skills/sdd-* wrapper skills must not remain."
fi

for command in speckit.specify speckit.plan speckit.tasks harness.exec harness.eval; do
    file="$ROOT_DIR/commands/$command.md"
    [ -f "$file" ] || fail "commands/$command.md is required for generated Codex skills."
    if [ -f "$file" ]; then
        grep -Eq '^description:[[:space:]]*.+' "$file" || fail "commands/$command.md must include frontmatter description."
    fi
done

if [ "$failures" -gt 0 ]; then
    echo "Codex skill validation failed with $failures issue(s)." >&2
    exit 1
fi

echo "Codex skill validation passed."
