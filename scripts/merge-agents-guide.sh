#!/usr/bin/env bash
# Merge SpecKit + Harness toolkit orchestration sections into an existing AGENTS.md.
#
# Usage:
#   merge-agents-guide.sh <template> <target>
#   merge-agents-guide.sh --force <template> <target>
#
# Default behavior:
#   - Missing target: copy full template
#   - Target without toolkit markers: prepend managed block, preserve original content
#   - Target with toolkit markers: refresh managed block only, preserve project content
#   - --force: overwrite target with full template

set -euo pipefail

MARKER_START='<!-- speckit-harness-toolkit:managed -->'
MARKER_END='<!-- /speckit-harness-toolkit:managed -->'
PRESERVED_MARKER='<!-- speckit-harness-toolkit:preserved-project-content -->'

FORCE=false

while [[ $# -gt 0 ]]; do
    case "$1" in
        --force)
            FORCE=true
            shift
            ;;
        -h|--help)
            cat <<'EOF'
Usage: merge-agents-guide.sh [--force] <template> <target>

Merge toolkit-managed orchestration sections into AGENTS.md while preserving
project-specific content below the preserved marker.
EOF
            exit 0
            ;;
        *)
            break
            ;;
    esac
done

if [[ $# -ne 2 ]]; then
    echo "ERROR: expected <template> <target>" >&2
    exit 1
fi

TEMPLATE="$1"
TARGET="$2"

if [[ ! -f "$TEMPLATE" ]]; then
    echo "ERROR: template not found: $TEMPLATE" >&2
    exit 1
fi

if ! grep -Fq "$MARKER_START" "$TEMPLATE" || ! grep -Fq "$MARKER_END" "$TEMPLATE"; then
    echo "ERROR: template missing toolkit managed markers" >&2
    exit 1
fi

if [[ "$FORCE" == "true" ]]; then
    cp "$TEMPLATE" "$TARGET"
    echo "overwrite"
    exit 0
fi

if [[ ! -f "$TARGET" ]]; then
    cp "$TEMPLATE" "$TARGET"
    echo "install"
    exit 0
fi

TMP_DIR="$(mktemp -d)"
trap 'rm -rf "$TMP_DIR"' EXIT

MANAGED_BLOCK="$TMP_DIR/managed.md"
PRESERVED_BLOCK="$TMP_DIR/preserved.md"
OUTPUT="$TMP_DIR/output.md"

awk -v start="$MARKER_START" -v end="$MARKER_END" '
    $0 == start { capture = 1 }
    capture { print }
    $0 == end { capture = 0 }
' "$TEMPLATE" > "$MANAGED_BLOCK"

if [[ ! -s "$MANAGED_BLOCK" ]]; then
    echo "ERROR: failed to extract managed block from template" >&2
    exit 1
fi

if grep -Fq "$MARKER_START" "$TARGET"; then
    if grep -Fq "$PRESERVED_MARKER" "$TARGET"; then
        awk -v marker="$PRESERVED_MARKER" '
            $0 == marker { capture = 1; next }
            capture { print }
        ' "$TARGET" > "$PRESERVED_BLOCK"
    else
        awk -v end="$MARKER_END" '
            found_end && !done {
                if ($0 != "") {
                    print
                }
                next
            }
            $0 == end {
                found_end = 1
                next
            }
            found_end { print }
        ' "$TARGET" > "$PRESERVED_BLOCK"
    fi
    action="refresh"
else
    cp "$TARGET" "$PRESERVED_BLOCK"
    action="merge"
fi

{
    cat "$MANAGED_BLOCK"
    if [[ -s "$PRESERVED_BLOCK" ]]; then
        echo ""
        echo "$PRESERVED_MARKER"
        echo ""
        cat "$PRESERVED_BLOCK"
    fi
} > "$OUTPUT"

mv "$OUTPUT" "$TARGET"
echo "$action"
