# FlowHarness SDD

**SpecKit + Harness AI 开发环境** — 自然语言驱动规范开发，Router 选模式，Step Gate 逐步执行，Dashboard 实时可视。

[English README](README.en.md) · [创新点对比](docs/ProMax-Innovation-vs-Base.md) · [贡献指南](CONTRIBUTING.zh-CN.md) · [安全策略](SECURITY.md)

[![License: MIT](https://img.shields.io/badge/License-MIT-blue.svg)](LICENSE)
[![NOTICE](https://img.shields.io/badge/Copyright-FlowHarness-orange.svg)](NOTICE)

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
git clone https://github.com/hahaxiang27/speckit-harness-flowgate.git ~/flowharness-sdd
cd /path/to/your/project
bash ~/flowharness-sdd/install.sh --agent cursor
```

### 2. 初始化宪法 → 新开会话 → 描述需求

```text
Step 1  install.sh 安装到项目
Step 2  第一个会话：执行 speckit.constitution
Step 3  宪法完成后新开 AI 会话
Step 4  自然语言描述需求 → 确认模式与命令流 → 回复「继续」逐步执行
```

详细步骤与 full 模式产物结构见 [docs/ProMax-Innovation-vs-Base.md](docs/ProMax-Innovation-vs-Base.md)。

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
flowharness-sdd/
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

## 相关链接

- [SpecKit 官方仓库](https://github.com/github/spec-kit)
- [ProMax 创新点与基线版对比](docs/ProMax-Innovation-vs-Base.md)
- [Claude Code 文档](https://docs.claude.com/en/docs/claude-code/)
