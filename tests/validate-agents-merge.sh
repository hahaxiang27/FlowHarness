#!/usr/bin/env bash
# Validate AGENTS.md merge behavior when a project already has custom content.

set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
target="$ROOT_DIR/.tmp-agents-merge-check"
custom_marker="CUSTOM-PROJECT-RULE-KEEP-ME-12345"

case "$target" in
    "$ROOT_DIR"/.tmp-agents-merge-check) rm -rf "$target" ;;
    *) echo "ERROR: unsafe temporary install target: $target" >&2; exit 2 ;;
esac
mkdir -p "$target"

cat > "$target/AGENTS.md" <<EOF
# My Existing Project Guide

This is project-specific guidance that must survive merge.

- $custom_marker
- Always run the legacy smoke test before release.
EOF

cd "$target"
bash "$ROOT_DIR/install.sh" --agent claude --with-router --with-agent-guide --no-constitution >/dev/null

grep -Fq "$custom_marker" "$target/AGENTS.md" || {
    echo "ERROR: merge must preserve custom AGENTS.md content" >&2
    exit 1
}

grep -Fq '<!-- speckit-harness-toolkit:managed -->' "$target/AGENTS.md" || {
    echo "ERROR: merge must inject toolkit managed markers" >&2
    exit 1
}

grep -Fq 'speckit-harness-toolkit:preserved-project-content' "$target/AGENTS.md" || {
    echo "ERROR: merge must add preserved project content marker" >&2
    exit 1
}

grep -Eq 'Step Gate Policy' "$target/AGENTS.md" || {
    echo "ERROR: merged AGENTS.md must include Step Gate Policy" >&2
    exit 1
}

grep -Eq 'Routing Gate' "$target/AGENTS.md" || {
    echo "ERROR: merged AGENTS.md must include Routing Gate" >&2
    exit 1
}

# Managed block should appear before preserved custom content.
managed_line="$(grep -nF '<!-- speckit-harness-toolkit:managed -->' "$target/AGENTS.md" | head -n1 | cut -d: -f1)"
custom_line="$(grep -n "$custom_marker" "$target/AGENTS.md" | head -n1 | cut -d: -f1)"
if [[ "$managed_line" -ge "$custom_line" ]]; then
    echo "ERROR: toolkit managed block must appear before preserved custom content" >&2
    exit 1
fi

# Re-run install should refresh managed block without duplicating custom content.
bash "$ROOT_DIR/install.sh" --agent claude --with-router --with-agent-guide --no-constitution >/dev/null

managed_count="$(grep -cF '<!-- speckit-harness-toolkit:managed -->' "$target/AGENTS.md" || true)"
if [[ "$managed_count" -ne 1 ]]; then
    echo "ERROR: refresh must keep exactly one managed block (found $managed_count)" >&2
    exit 1
fi

grep -Fq "$custom_marker" "$target/AGENTS.md" || {
    echo "ERROR: refresh must still preserve custom AGENTS.md content" >&2
    exit 1
}

# --force should overwrite custom content with toolkit template.
bash "$ROOT_DIR/install.sh" --agent claude --with-router --with-agent-guide --no-constitution --force >/dev/null

if grep -Fq "$custom_marker" "$target/AGENTS.md"; then
    echo "ERROR: --force must overwrite custom AGENTS.md content" >&2
    exit 1
fi

grep -Eq 'Step Gate Policy' "$target/AGENTS.md" || {
    echo "ERROR: forced AGENTS.md must still include Step Gate Policy" >&2
    exit 1
}

echo "AGENTS.md merge validation passed."
