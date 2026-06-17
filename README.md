<div align="center">

# ⚡ FlowHarness SDD

### Harness 驱动的 AI 规范开发引擎

**说需求 · 选模式 · 看面板 · 一步步交付**

*Natural Language In · Governed Flow Out*

<br/>

一句话启动 **AI Dev Environment** — Router 六模式路由 · Step Gate 逐步门禁 · Dashboard 实况面板

[English README](README.en.md) · [使用指南](docs/ProMax-Innovation-vs-Base.md) · [贡献指南](CONTRIBUTING.zh-CN.md) · [安全策略](SECURITY.md)

<br/>

[![License: MIT](https://img.shields.io/badge/License-MIT-blue.svg)](LICENSE)
[![NOTICE](https://img.shields.io/badge/Copyright-FlowHarness-orange.svg)](NOTICE)
[![Router](https://img.shields.io/badge/Router-6_Modes-purple.svg)](#这是什么)
[![Step Gate](https://img.shields.io/badge/Step_Gate-One_Cmd_Per_Turn-red.svg)](#这是什么)
[![Dashboard](https://img.shields.io/badge/Dashboard-Live_Panel-green.svg)](#dashboard-memory-and-safety)

</div>

---

## 这是什么

将 [SpecKit](https://github.com/github/spec-kit) 规范驱动开发（SDD）与 **Harness** 质量闭环整合为**可落地的 AI Dev Environment**：

```
自然语言需求 → Router 六模式 → Dashboard 可视化 → spec → plan → tasks
→ Harness 批次执行 → 四级验证 → 定向修正 → 度量报告
```

| 创新点 | 说明 |
|--------|------|
| **Router** | `direct` / `doc` / `fast` / `speclite` / `full` / `debug` 按风险自动选流 |
| **Step Gate** | 每轮只执行一个命令，用户说「继续」才往下走 |
| **Dashboard** | `dashboard.html` + `dashboard-state.json` 浏览器实时刷新 |
| **AGENTS.md 合并** | 与企业已有 Agent 规范非破坏性共存 |
| **多 Agent** | Claude Code · Cursor · Codex · OpenCode |

---

## 快速开始

### 1. 安装

```bash
git clone https://github.com/hahaxiang27/FlowHarness.git
cd FlowHarness
# 安装到目标项目
cd /path/to/your/project
bash /path/to/FlowHarness/install.sh --agent cursor
```

### 2. 初始化宪法 → 新开会话 → 描述需求

用 **natural-language** 描述需求即可，无需记忆 slash 命令。日常操作：说明需求 → 确认计划 → 回复「继续」进入 **next step**。

```text
Step 1  install.sh 安装到项目
Step 2  第一个会话：执行 speckit.constitution
Step 3  宪法完成后新开 AI 会话
Step 4  自然语言描述需求 → 确认模式与命令流 → 回复「继续」逐步执行
```

详细步骤与 full 模式产物结构见 [使用指南](docs/ProMax-Innovation-vs-Base.md)。

### 3. 常用安装参数

| 参数 | 作用 |
|------|------|
| `--agent cursor` / `claude` / `codex` / `all` | 选择目标 AI 平台 |
| `--force` | 覆盖已存在文件 |
| `--no-constitution` | 跳过宪法模板铺设 |
| `--no-agent-guide` | 跳过 AGENTS.md 与 context |

---

## 仓库结构

```text
FlowHarness/
├── install.sh              # 一键安装
├── router/                 # AI Dev Router 配置
├── commands/               # speckit.* / harness.* 命令定义
├── harness/                # prompts · dashboard 模板
├── templates/              # AGENTS.md · Cursor rules · Constitution
├── scripts/                # merge-agents-guide.sh 等
├── tests/                  # validate-*.sh 产品化校验
└── docs/                   # 创新点对比 · 使用说明
```

---

## 命令速查

### SpecKit

| 命令 | 作用 |
|------|------|
| `speckit.constitution` | 项目宪法 |
| `speckit.specify` | 需求规格 |
| `speckit.clarify` | 澄清歧义 |
| `speckit.checklist` | 质量检查清单 |
| `speckit.plan` | 技术方案 |
| `speckit.tasks` | 任务拆解 |
| `speckit.analyze` | spec/plan/tasks 一致性审计 |

### Harness

| 命令 | 作用 |
|------|------|
| `harness.scope` | 模块边界 |
| `harness.start` | 启动 Sprint |
| `harness.exec` | 执行任务 |
| `harness.eval` | 四级验证 |
| `harness.fix` | 定向修正 |
| `harness.checkpoint` | 宪法审查 |
| `harness.metrics` | 五维度量 |

完整说明见 `harness/README.original.md`。

---

## 验证

```bash
bash tests/validate-install.sh
bash tests/validate-router-config.sh
bash tests/validate-agents-merge.sh
```

---

## 著作权与贡献

- **许可证**：[MIT License](LICENSE)
- **著作权申明**：[NOTICE](NOTICE) — 保留商标与署名要求
- **贡献规则**：[CONTRIBUTING.zh-CN.md](CONTRIBUTING.zh-CN.md) / [CONTRIBUTING.md](CONTRIBUTING.md)
- **行为准则**：[CODE_OF_CONDUCT.md](CODE_OF_CONDUCT.md)

未经书面许可，不得将「FlowHarness SDD」用于衍生产品的宣传背书。

---

## Dashboard, Memory, And Safety

- **Dashboard**：非 direct 需求在首个命令前初始化 `specs/{REQUIREMENT_ID}/dashboard.html` 与 `dashboard-state.json`，浏览器自动刷新进度。
- **Memory**：可复用经验沉淀于 `.ai-dev/context/`（mistakes、patterns、team-rules），`harness.metrics` 后可回写。
- **Safety**：禁止分发 `.claude/settings.local.json`；请使用 `.claude/settings.template.json` 作为安全基线。

---

## 相关链接

- [SpecKit 官方仓库](https://github.com/github/spec-kit)
- [FlowHarness SDD 使用指南](docs/ProMax-Innovation-vs-Base.md)
- [Claude Code 文档](https://docs.claude.com/en/docs/claude-code/)
