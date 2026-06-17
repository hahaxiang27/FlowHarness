#!/usr/bin/env bash
# Validate requirement-id bucketed artifact layout across SpecKit, Harness, and dashboard state.

set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
failures=0

fail() {
    echo "ERROR: $*" >&2
    failures=$((failures + 1))
}

require_file() {
    local path="$1"
    [ -f "$ROOT_DIR/$path" ] || fail "missing required file: $path"
}

require_grep() {
    local pattern="$1"
    local path="$2"
    local message="$3"
    if [ -f "$ROOT_DIR/$path" ]; then
        grep -Eq "$pattern" "$ROOT_DIR/$path" || fail "$message"
    fi
}

layout="templates/ai-dev-context/requirement-artifact-layout.md"
require_file "$layout"
require_grep 'REQUIREMENT_ID|requirement id' "$layout" "layout context must describe requirement id."
require_grep 'specs/DPSHCT-2983-xxx/' "$layout" "layout context must show bucketed specs example."
require_grep '\.harness/sprints/DPSHCT-2983-xxx/' "$layout" "layout context must show bucketed sprint example."
require_grep '\.harness/metrics/DPSHCT-2983-xxx/' "$layout" "layout context must show bucketed metrics example."
require_grep 'must not force a single id pattern' "$layout" "layout context must not force DPSHCT-only ids."

require_grep 'requirement-artifact-layout\.md' "templates/AGENTS.template.md" "AGENTS template must read requirement artifact layout context."
require_grep 'specs/\{REQUIREMENT_ID\}/' "templates/AGENTS.template.md" "AGENTS template must expose requirement-id specs root."
require_grep '\.harness/sprints/' "templates/AGENTS.template.md" "AGENTS template must expose requirement-id sprint root."
require_grep '\.harness/metrics/' "templates/AGENTS.template.md" "AGENTS template must expose requirement-id metrics root."

require_grep 'specs/<REQUIREMENT_ID>' "commands/speckit.specify.md" "speckit.specify must prefer specs/<REQUIREMENT_ID>."
require_grep '\.harness/sprints/<REQUIREMENT_ID>/' "commands/speckit.specify.md" "speckit.specify must document matching Harness sprint root."
require_grep '\.harness/metrics/<REQUIREMENT_ID>/' "commands/speckit.specify.md" "speckit.specify must document matching Harness metrics root."

for path in \
    commands/harness.plan.md \
    commands/harness.start.md \
    commands/harness.exec.md \
    commands/harness.metrics.md \
    commands/harness.checkpoint.md \
    commands/harness.eval.md \
    commands/harness.fix.md \
    commands/harness.scope.md \
    harness/prompts/planner.md \
    harness/prompts/executor.md \
    harness/prompts/metrics.md \
    harness/prompts/dashboard-updater.md
do
    require_file "$path"
    require_grep 'Requirement Artifact Path Convention' "$path" "$path must include the requirement artifact convention."
    require_grep 'specs/\{REQUIREMENT_ID\}/' "$path" "$path must use requirement-id specs path."
    require_grep '\.harness/sprints/\{REQUIREMENT_ID\}/' "$path" "$path must use requirement-id sprint path."
    require_grep '\.harness/metrics/\{REQUIREMENT_ID\}/' "$path" "$path must use requirement-id metrics path."
done

require_grep '"requirement_id"' "harness/templates/dashboard-state.schema.json" "dashboard schema must include requirement_id."
require_grep 'specs/DPSHCT-2983-xxx' "harness/templates/dashboard-state.example.json" "dashboard example must use requirement-id specs path."
require_grep '\.harness/sprints/DPSHCT-2983-xxx/' "harness/templates/dashboard-state.example.json" "dashboard example must use requirement-id sprint path."
require_grep 'REQUIREMENT_ID' "harness/prompts/dashboard-state-updater.md" "dashboard updater must read artifacts by requirement id."
require_grep 'dashboard-state\.json' "templates/AGENTS.template.md" "AGENTS template must initialize dashboard-state.json before the first command."
require_grep 'direct-implement\.md' "templates/AGENTS.template.md" "AGENTS template must reference direct-implement prompt."
require_grep 'dashboard-plan-init\.md' "templates/AGENTS.template.md" "AGENTS template must reference dashboard plan init prompt."
require_grep 'dashboard\.html' "templates/ai-dev-context/requirement-artifact-layout.md" "layout context must document dashboard.html."
require_grep 'dashboard-state\.json' "templates/ai-dev-context/requirement-artifact-layout.md" "layout context must document dashboard-state.json."
require_grep 'requirement-artifact-layout\.md' "tests/validate-install.sh" "install validation must require installed requirement artifact layout context."

if [ "$failures" -gt 0 ]; then
    echo "Requirement artifact layout validation failed with $failures issue(s)." >&2
    exit 1
fi

echo "Requirement artifact layout validation passed."
