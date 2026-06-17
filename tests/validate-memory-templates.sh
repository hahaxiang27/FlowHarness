#!/usr/bin/env bash
# Validate Memory templates and metrics capture.

set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
failures=0

fail() {
    echo "ERROR: $*" >&2
    failures=$((failures + 1))
}

for file in mistakes.md team-rules.md known-patterns.md review-feedback.md reusable-patterns.md; do
    path="$ROOT_DIR/templates/ai-dev-context/$file"
    [ -f "$path" ] || fail "templates/ai-dev-context/$file is required."
done

metrics="$ROOT_DIR/commands/harness.metrics.md"

if [ ! -f "$metrics" ]; then
    fail "commands/harness.metrics.md is required."
else
    grep -Eq '\.ai-dev/context' "$metrics" || fail "harness.metrics must direct agents to update Memory after metrics."
fi

if [ "$failures" -gt 0 ]; then
    echo "Memory template validation failed with $failures issue(s)." >&2
    exit 1
fi

echo "Memory template validation passed."
