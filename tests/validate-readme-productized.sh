#!/usr/bin/env bash
# Validate README positions the toolkit as AI Dev Environment with high-level entrypoints.

set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
README="$ROOT_DIR/README.md"
failures=0

fail() {
    echo "ERROR: $*" >&2
    failures=$((failures + 1))
}

[ -f "$README" ] || fail "README.md is required."

if [ -f "$README" ]; then
    grep -Eq 'AI Dev Environment' "$README" || fail "README must use AI Dev Environment as the primary title."
    grep -Eq 'speckit\.constitution|/speckit\.constitution' "$README" || fail "README must require speckit.constitution first."
    grep -Eq 'speckit\.\*|harness\.\*' "$README" || fail "README must foreground concrete speckit/harness commands."
    grep -Eq '下一步|next step|natural-language|natural language|plain requirement' "$README" || fail "README must explain no-command natural-language operation."
    grep -Eq 'Dashboard, Memory, And Safety' "$README" || fail "README must document Dashboard, Memory, and Safety."
    grep -Eq 'Doc|Fast|SpecLite|Full|Debug|doc|fast|speclite|full|debug' "$README" || fail "README must explain router modes."
    grep -Eq 'settings\.local\.json' "$README" || fail "README must mention local settings safety."
fi

if [ "$failures" -gt 0 ]; then
    echo "README productization validation failed with $failures issue(s)." >&2
    exit 1
fi

echo "README productization validation passed."
