<div align="center">

# ⚡ FlowHarness SDD

### SpecKit + Harness · AI Dev Environment

**Speak Requirements · Route Modes · Watch Dashboard · Ship Step by Step**

*Natural Language In · Governed Flow Out*

<br/>

One sentence in — **Router** picks the flow · **Step Gate** enforces discipline · **Dashboard** shows live progress

[中文 README](README.md) · [Usage Guide](docs/ProMax-Innovation-vs-Base.md) · [Contributing](CONTRIBUTING.md) · [Security](SECURITY.md)

<br/>

[![License: MIT](https://img.shields.io/badge/License-MIT-blue.svg)](LICENSE)
[![NOTICE](https://img.shields.io/badge/Copyright-FlowHarness-orange.svg)](NOTICE)
[![Router](https://img.shields.io/badge/Router-6_Modes-purple.svg)](#overview)
[![Step Gate](https://img.shields.io/badge/Step_Gate-One_Cmd_Per_Turn-red.svg)](#overview)
[![Dashboard](https://img.shields.io/badge/Dashboard-Live_Panel-green.svg)](#dashboard-memory-and-safety)

</div>

---

## Overview

FlowHarness SDD integrates [SpecKit](https://github.com/github/spec-kit) Specification-Driven Development with a **Harness** quality loop into a deployable **AI Dev Environment**:

```
Natural-language requirement → Router (6 modes) → Dashboard
→ spec → plan → tasks → Harness execution → verification → metrics
```

| Innovation | Description |
|------------|-------------|
| **Router** | Auto-select `direct` / `doc` / `fast` / `speclite` / `full` / `debug` by risk |
| **Step Gate** | One command per turn; user says "continue" to proceed |
| **Dashboard** | `dashboard.html` + `dashboard-state.json` with auto-refresh |
| **AGENTS.md merge** | Non-destructive coexistence with existing agent guides |
| **Multi-agent** | Claude Code · Cursor · Codex · OpenCode |

---

## Quick Start

### 1. Install

```bash
git clone https://github.com/hahaxiang27/FlowHarness.git
cd FlowHarness
# install into your project
cd /path/to/your/project
bash /path/to/FlowHarness/install.sh --agent cursor
```

### 2. Constitution → new session → describe requirement

Use **natural-language** requirements — no slash commands required. Typical flow: describe → confirm plan → reply `continue` for each **next step**.

```text
Step 1  Run install.sh in your project
Step 2  First session: run speckit.constitution
Step 3  Open a new AI session after constitution is ready
Step 4  Describe requirement in natural language → confirm plan → reply "continue" step by step
```

See [Usage Guide](docs/ProMax-Innovation-vs-Base.md) for full workflow and artifact layout (Chinese).

### 3. Common install flags

| Flag | Purpose |
|------|---------|
| `--agent cursor` / `claude` / `codex` / `all` | Target AI platform |
| `--force` | Overwrite existing installed files |
| `--no-constitution` | Skip constitution template |
| `--no-agent-guide` | Skip AGENTS.md and `.ai-dev/context/` |

---

## Repository Layout

```text
FlowHarness/
├── install.sh
├── router/
├── commands/
├── harness/
├── templates/
├── scripts/
├── tests/
└── docs/
```

---

## Command Cheat Sheet

### SpecKit

| Command | Purpose |
|---------|---------|
| `speckit.constitution` | Project constitution |
| `speckit.specify` | Feature specification |
| `speckit.clarify` | Clarify ambiguities |
| `speckit.checklist` | Quality checklist |
| `speckit.plan` | Implementation plan |
| `speckit.tasks` | Task breakdown |
| `speckit.analyze` | Consistency audit (after plan & tasks) |

### Harness

| Command | Purpose |
|---------|---------|
| `harness.scope` | Module boundaries |
| `harness.start` | Start sprint |
| `harness.exec` | Execute tasks |
| `harness.eval` | Multi-level verification |
| `harness.fix` | Targeted correction |
| `harness.checkpoint` | Constitution review |
| `harness.metrics` | Five-dimension metrics |

See `harness/README.original.md` for methodology depth.

---

## Validation

```bash
bash tests/validate-install.sh
bash tests/validate-router-config.sh
bash tests/validate-agents-merge.sh
```

---

## Copyright & Contributing

- **License:** [MIT License](LICENSE)
- **Copyright & trademarks:** [NOTICE](NOTICE)
- **Contributing:** [CONTRIBUTING.md](CONTRIBUTING.md) / [CONTRIBUTING.zh-CN.md](CONTRIBUTING.zh-CN.md)
- **Code of conduct:** [CODE_OF_CONDUCT.md](CODE_OF_CONDUCT.md)

You may not use the name "FlowHarness SDD" to endorse derivative products without written permission from the project maintainers.

---

## Dashboard, Memory, And Safety

- **Dashboard**: non-direct requirements initialize `specs/{REQUIREMENT_ID}/dashboard.html` and `dashboard-state.json` before the first command; the browser panel auto-refreshes.
- **Memory**: reusable patterns and team rules live under `.ai-dev/context/` and may be updated after `harness.metrics`.
- **Safety**: do not distribute `.claude/settings.local.json`; use `.claude/settings.template.json` as the safe baseline.

---

## Links

- [SpecKit](https://github.com/github/spec-kit)
- [FlowHarness SDD Usage Guide](docs/ProMax-Innovation-vs-Base.md)
- [Claude Code docs](https://docs.claude.com/en/docs/claude-code/)
