#!/usr/bin/env bash
# Validate AI Dev Router configuration files.

set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
ROUTER_DIR="$ROOT_DIR/router"
failures=0

fail() {
    echo "ERROR: $*" >&2
    failures=$((failures + 1))
}

require_file() {
    local file="$1"

    if [ ! -f "$ROUTER_DIR/$file" ]; then
        fail "router/$file is required."
        return 1
    fi
    return 0
}

require_file "modes.yml" || true
require_file "routing-rules.yml" || true
require_file "tool-manifest.yml" || true
require_file "risk-rules.yml" || true
require_file "bypass-rules.yml" || true

if [ -f "$ROUTER_DIR/modes.yml" ]; then
    for mode in direct doc fast speclite full debug; do
        if ! grep -Eq "^[[:space:]]{2}${mode}:" "$ROUTER_DIR/modes.yml"; then
            fail "router/modes.yml must define mode: $mode."
            continue
        fi

        mode_block="$(awk -v mode="$mode" '
            $0 ~ "^  " mode ":" { in_mode = 1; print; next }
            in_mode && /^  [a-zA-Z0-9_-]+:/ { exit }
            in_mode { print }
        ' "$ROUTER_DIR/modes.yml")"

        printf '%s\n' "$mode_block" | grep -Eq '^[[:space:]]{4}name:' || fail "mode $mode must include name."
        printf '%s\n' "$mode_block" | grep -Eq '^[[:space:]]{4}goal:' || fail "mode $mode must include goal."
        printf '%s\n' "$mode_block" | grep -Eq '^[[:space:]]{4}steps:' || fail "mode $mode must include steps."
    done
fi

if [ -f "$ROUTER_DIR/bypass-rules.yml" ]; then
    grep -Eq '^eligibility:' "$ROUTER_DIR/bypass-rules.yml" || fail "router/bypass-rules.yml must define eligibility."
    grep -Eq '^blockers:' "$ROUTER_DIR/bypass-rules.yml" || fail "router/bypass-rules.yml must define blockers."
fi

if [ -f "$ROUTER_DIR/routing-rules.yml" ]; then
    grep -Eq '^scoring:' "$ROUTER_DIR/routing-rules.yml" || fail "router/routing-rules.yml must define scoring."
    grep -Eq '^rules:' "$ROUTER_DIR/routing-rules.yml" || fail "router/routing-rules.yml must define rules."
    grep -Eq 'mode: direct' "$ROUTER_DIR/routing-rules.yml" || fail "router/routing-rules.yml must route direct mode."
fi

if [ -f "$ROUTER_DIR/tool-manifest.yml" ]; then
    grep -Eq '^tools:' "$ROUTER_DIR/tool-manifest.yml" || fail "router/tool-manifest.yml must define tools."
fi

if [ -f "$ROUTER_DIR/risk-rules.yml" ]; then
    grep -Eq '^risk_levels:' "$ROUTER_DIR/risk-rules.yml" || fail "router/risk-rules.yml must define risk_levels."
    grep -Eq '^approval_required_for:' "$ROUTER_DIR/risk-rules.yml" || fail "router/risk-rules.yml must define approval_required_for."
fi

if [ "$failures" -gt 0 ]; then
    echo "Router config validation failed with $failures issue(s)." >&2
    exit 1
fi

echo "Router config validation passed."
