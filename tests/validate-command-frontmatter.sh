#!/usr/bin/env bash
# Validate Front Matter metadata for command source files.

set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
COMMANDS_DIR="$ROOT_DIR/commands"
failures=0

usage() {
    cat <<'EOF'
Usage: tests/validate-command-frontmatter.sh [--commands-dir DIR]

Validates commands/*.md Front Matter:
- file must start with YAML Front Matter
- Front Matter must be closed
- description is required and non-empty
- name is optional, but must be non-empty when present
EOF
}

while [ "$#" -gt 0 ]; do
    case "$1" in
        --commands-dir)
            if [ "$#" -lt 2 ] || [ -z "$2" ]; then
                echo "ERROR: --commands-dir requires a directory path" >&2
                exit 2
            fi
            COMMANDS_DIR="$2"
            shift 2
            ;;
        --help|-h)
            usage
            exit 0
            ;;
        *)
            echo "ERROR: unknown option: $1" >&2
            usage >&2
            exit 2
            ;;
    esac
done

fail() {
    echo "ERROR: $*" >&2
    failures=$((failures + 1))
}

field_value_state() {
    local file="$1"
    local key="$2"
    local end_line="$3"

    awk -v key="$key" -v end="$end_line" '
        function trim(value) {
            sub(/^[[:space:]]+/, "", value)
            sub(/[[:space:]]+$/, "", value)
            return value
        }
        NR > 1 && NR < end {
            pattern = "^[[:space:]]*" key ":[[:space:]]*"
            if ($0 ~ pattern) {
                found = 1
                value = $0
                sub(pattern, "", value)
                value = trim(value)
                if (value != "" && value != "\"\"" && value != "''") {
                    nonempty = 1
                }
            }
        }
        END {
            if (!found) print "missing"
            else if (!nonempty) print "empty"
            else print "nonempty"
        }
    ' "$file"
}

frontmatter_end_line() {
    local file="$1"

    awk '{ line = $0; sub(/\r$/, "", line); if (NR > 1 && line == "---") { print NR; exit } }' "$file"
}

relative_path() {
    local file="$1"

    case "$file" in
        "$ROOT_DIR"/*) printf '%s\n' "${file#$ROOT_DIR/}" ;;
        *) printf '%s\n' "$file" ;;
    esac
}

validate_file() {
    local file="$1"
    local rel
    local first_line
    local end_line
    local description_state
    local name_state

    rel="$(relative_path "$file")"
    first_line="$(sed -n '1p' "$file")"
    first_line="${first_line#$'\xef\xbb\xbf'}"
    first_line="${first_line%$'\r'}"

    if [ "$first_line" != "---" ]; then
        fail "$rel must start with YAML Front Matter ('---')."
        return
    fi

    end_line="$(frontmatter_end_line "$file")"
    if [ -z "$end_line" ]; then
        fail "$rel must close YAML Front Matter with a second '---' line."
        return
    fi

    description_state="$(field_value_state "$file" "description" "$end_line")"
    case "$description_state" in
        missing) fail "$rel Front Matter must include description." ;;
        empty) fail "$rel Front Matter description must be non-empty." ;;
    esac

    name_state="$(field_value_state "$file" "name" "$end_line")"
    if [ "$name_state" = "empty" ]; then
        fail "$rel Front Matter name must be non-empty when defined."
    fi
}

if [ ! -d "$COMMANDS_DIR" ]; then
    fail "commands directory does not exist: $COMMANDS_DIR"
else
    command_count=0
    while IFS= read -r file; do
        command_count=$((command_count + 1))
        validate_file "$file"
    done < <(find "$COMMANDS_DIR" -maxdepth 1 -type f -name '*.md' | sort)

    if [ "$command_count" -eq 0 ]; then
        fail "commands directory has no markdown command files: $COMMANDS_DIR"
    fi
fi

if [ "$failures" -gt 0 ]; then
    echo "Command Front Matter validation failed with $failures issue(s)." >&2
    exit 1
fi

echo "Command Front Matter validation passed."
