#!/usr/bin/env bash
# Validate that distributable toolkit files do not contain local-only paths or settings.

set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
failures=0

fail() {
    echo "ERROR: $*" >&2
    failures=$((failures + 1))
}

relative_path() {
    local file="$1"

    case "$file" in
        "$ROOT_DIR"/*) printf '%s\n' "${file#$ROOT_DIR/}" ;;
        *) printf '%s\n' "$file" ;;
    esac
}

while IFS= read -r file; do
    rel="$(relative_path "$file")"
    base="$(basename "$file")"

    if [ "$rel" = ".claude/settings.local.json" ]; then
        fail ".claude/settings.local.json must not be distributed; use templates/settings.local.example.json instead."
    fi

    if [[ "$base" == ".env" || "$base" == .env.* ]]; then
        fail "$rel must not be distributed."
    fi
done < <(
    find "$ROOT_DIR" \
        -path "$ROOT_DIR/.git" -prune -o \
        -path "$ROOT_DIR/.tmp-install-check" -prune -o \
        -type f -print | sort
)

while IFS= read -r match; do
    file="${match%%:*}"
    rel="$(relative_path "$file")"
    fail "$rel contains a local-only absolute path or private key marker."
done < <(
    grep -RIlE \
        --exclude-dir='.git' \
        --exclude-dir='.tmp-install-check' \
        --exclude='validate-no-local-paths.sh' \
        'C:\\Users\\|/Users/|//private/|BEGIN [A-Z ]*PRIVATE KEY' \
        "$ROOT_DIR" | sort
)

if [ "$failures" -gt 0 ]; then
    echo "Local path validation failed with $failures issue(s)." >&2
    exit 1
fi

echo "Local path validation passed."
