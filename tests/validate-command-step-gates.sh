#!/usr/bin/env bash
# Validate every distributed speckit.* and harness.* command stops at the SDD step gate.

set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
failures=0

fail() {
    echo "ERROR: $*" >&2
    failures=$((failures + 1))
}

while IFS= read -r file; do
    rel="${file#$ROOT_DIR/}"
    grep -Eq '## SDD Step Gate|Dashboard Observation Panel Sync' "$file" || fail "$rel must include an SDD Step Gate section."
    grep -Eq '\.harness/prompts/command-step-gate\.md|\.harness/prompts/step-gate-handoff\.md' "$file" || fail "$rel must reference the step-gate prompt."
    grep -Eq 'Stop immediately|stop immediately|Do not chain|do not chain' "$file" || fail "$rel must explicitly stop after completion."
done < <(find "$ROOT_DIR/commands" -maxdepth 1 -type f \( -name 'speckit.*.md' -o -name 'harness.*.md' \) | sort)

if [ "$failures" -gt 0 ]; then
    echo "Command step-gate validation failed with $failures issue(s)." >&2
    exit 1
fi

echo "Command step-gate validation passed."
