#!/usr/bin/env bash
# Validate install.sh installs router, agent guide, safe settings, dashboard state, memory, and concrete command skills.

set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
target="$ROOT_DIR/.tmp-install-check"
log="$target/install.log"

case "$target" in
    "$ROOT_DIR"/.tmp-install-check) rm -rf "$target" ;;
    *) echo "ERROR: unsafe temporary install target: $target" >&2; exit 2 ;;
esac
mkdir -p "$target"

cd "$target"
mkdir -p .claude/commands .opencode/command .codex/skills/sdd-run
printf '%s\n' stale > .claude/commands/sdd.run.md
printf '%s\n' stale > .opencode/command/sdd.run.md
printf '%s\n' stale > .codex/skills/sdd-run/SKILL.md
bash "$ROOT_DIR/install.sh" --agent all --with-router --with-agent-guide --safe-settings --force >"$log"

help_output="$(bash "$ROOT_DIR/install.sh" --help)"
for option in --with-router --with-agent-guide --safe-settings; do
    if ! printf '%s\n' "$help_output" | grep -q -- "$option"; then
        echo "ERROR: install --help must mention $option" >&2
        exit 1
    fi
done

required=(
    "AGENTS.md"
    ".ai-dev/router/modes.yml"
    ".ai-dev/router/routing-rules.yml"
    ".ai-dev/router/tool-manifest.yml"
    ".ai-dev/router/risk-rules.yml"
    ".ai-dev/context/mistakes.md"
    ".ai-dev/context/team-rules.md"
    ".ai-dev/context/requirement-artifact-layout.md"
    ".claude/settings.template.json"
    ".harness/templates/dashboard-state.schema.json"
    ".harness/templates/dashboard-state.example.json"
    ".harness/templates/dashboard.html"
    ".harness/prompts/dashboard-state-updater.md"
    ".harness/prompts/dashboard-plan-init.md"
    ".harness/prompts/step-gate-handoff.md"
    ".harness/prompts/command-step-gate.md"
    ".harness/prompts/direct-implement.md"
    ".cursor/rules/speckit-harness-orchestration.mdc"
    ".codex/skills/speckit-specify/SKILL.md"
    ".codex/skills/harness-exec/SKILL.md"
    ".specify/templates/spec-template.md"
    ".harness/prompts/generator.md"
)

failures=0
for path in "${required[@]}"; do
    if [ ! -e "$path" ]; then
        echo "ERROR: missing installed artifact: $path" >&2
        failures=$((failures + 1))
    fi
done

if [ -e ".claude/settings.local.json" ]; then
    echo "ERROR: install must not create .claude/settings.local.json" >&2
    failures=$((failures + 1))
fi

if [ -e ".claude/commands/dev.run.md" ] || [ -e ".codex/skills/dev-run/SKILL.md" ] || \
   [ -e ".claude/commands/sdd.run.md" ] || [ -e ".codex/skills/sdd-run/SKILL.md" ]; then
    echo "ERROR: install must not create dev.* or sdd.* high-level wrapper entries" >&2
    failures=$((failures + 1))
fi

if [ "$failures" -gt 0 ]; then
    echo "Install validation failed with $failures issue(s)." >&2
    exit 1
fi

grep -Eq 'Step Gate Policy' "$target/AGENTS.md" || {
    echo "ERROR: installed AGENTS.md must include Step Gate Policy" >&2
    exit 1
}

grep -Eq 'speckit\.constitution' "$target/AGENTS.md" || {
    echo "ERROR: installed AGENTS.md must require speckit.constitution first" >&2
    exit 1
}

grep -Eq '## SDD Step Gate' "$target/.claude/commands/speckit.plan.md" || {
    echo "ERROR: installed speckit.plan.md must include SDD Step Gate section" >&2
    exit 1
}

grep -Eq 'setInterval' "$target/.harness/templates/dashboard.html" || {
    echo "ERROR: dashboard.html must auto-refresh dashboard state" >&2
    exit 1
}

echo "Install validation passed."
