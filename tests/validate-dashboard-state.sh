#!/usr/bin/env bash
# Validate dashboard state schema, example, and updater prompt.

set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
failures=0

fail() {
    echo "ERROR: $*" >&2
    failures=$((failures + 1))
}

schema="$ROOT_DIR/harness/templates/dashboard-state.schema.json"
example="$ROOT_DIR/harness/templates/dashboard-state.example.json"
updater="$ROOT_DIR/harness/prompts/dashboard-state-updater.md"
dashboard="$ROOT_DIR/harness/templates/dashboard.html"

[ -f "$schema" ] || fail "harness/templates/dashboard-state.schema.json is required."
[ -f "$example" ] || fail "harness/templates/dashboard-state.example.json is required."
[ -f "$updater" ] || fail "harness/prompts/dashboard-state-updater.md is required."
[ -f "$dashboard" ] || fail "harness/templates/dashboard.html is required."

if [ -f "$schema" ]; then
    grep -Eq '"current_requirement"' "$schema" || fail "dashboard schema must include current_requirement."
    grep -Eq '"requirement_id"' "$schema" || fail "dashboard schema must include current_requirement.requirement_id."
    grep -Eq '"mode"' "$schema" || fail "dashboard schema must include mode."
    grep -Eq '"verification"' "$schema" || fail "dashboard schema must include verification."
    grep -Eq '"evidence"' "$schema" || fail "dashboard schema must include evidence."
    grep -Eq '"learning"' "$schema" || fail "dashboard schema must include learning."
    grep -Eq 'workflow_plan' "$schema" || fail "dashboard schema must include workflow_plan."
    grep -Eq '"steps"' "$schema" || fail "dashboard schema must include workflow_plan.steps."
fi

if [ -f "$example" ]; then
    grep -Eq '"mode"[[:space:]]*:[[:space:]]*"(direct|doc|fast|speclite|full|debug)"' "$example" || fail "dashboard example must set a valid mode."
    grep -Eq '"requirement_id"[[:space:]]*:' "$example" || fail "dashboard example must set requirement_id."
    grep -Eq 'specs/DPSHCT-2983-xxx' "$example" || fail "dashboard example must use requirement-id spec path."
    grep -Eq '\.harness/sprints/DPSHCT-2983-xxx/' "$example" || fail "dashboard example must use requirement-id sprint path."
    grep -Eq '"workflow_plan"' "$example" || fail "dashboard example must include workflow_plan."
fi

if [ -f "$updater" ]; then
    grep -Eq 'dashboard-state\.json' "$updater" || fail "dashboard updater must write dashboard-state.json."
    grep -Eq 'specs/\{REQUIREMENT_ID\}/dashboard-state\.json' "$updater" || fail "dashboard updater must write colocated dashboard-state.json."
    grep -Eq 'workflow_plan' "$updater" || fail "dashboard updater must preserve workflow_plan."
    grep -Eq 'spec|tasks|progress|metrics|reports' "$updater" || fail "dashboard updater must read delivery artifacts."
    grep -Eq 'REQUIREMENT_ID' "$updater" || fail "dashboard updater must read artifacts by requirement id."
fi

if [ -f "$dashboard" ]; then
    grep -Eq 'dashboard-state\.json' "$dashboard" || fail "dashboard.html must load dashboard-state.json."
    grep -Eq 'fetch\(' "$dashboard" || fail "dashboard.html must fetch dashboard state."
    grep -Eq 'sidebar|step-panel|topbar' "$dashboard" || fail "dashboard.html must use original sidebar + panel layout."
    grep -Eq 'panel-workflow|workflow_plan|执行计划' "$dashboard" || fail "dashboard.html must render workflow plan panel."
fi

plan_init="$ROOT_DIR/harness/prompts/dashboard-plan-init.md"
handoff="$ROOT_DIR/harness/prompts/step-gate-handoff.md"
gate="$ROOT_DIR/harness/prompts/command-step-gate.md"
[ -f "$plan_init" ] || fail "harness/prompts/dashboard-plan-init.md is required."
[ -f "$handoff" ] || fail "harness/prompts/step-gate-handoff.md is required."
[ -f "$gate" ] || fail "harness/prompts/command-step-gate.md is required."
grep -Eq 'Phase 2|workflow_plan\.steps' "$plan_init" || fail "dashboard plan init must describe Phase 2 workflow_plan initialization."
grep -Eq 'One command per user turn|awaiting_user' "$handoff" || fail "step gate handoff must enforce one command per user turn."
grep -Eq 'setInterval|refreshDashboard' "$dashboard" || fail "dashboard.html must auto-refresh dashboard state."

if [ "$failures" -gt 0 ]; then
    echo "Dashboard state validation failed with $failures issue(s)." >&2
    exit 1
fi

echo "Dashboard state validation passed."
