# FlowHarness SDD 使用指南

> 本文介绍 **FlowHarness SDD** 从安装到交付的完整使用流程。  
> 仓库地址：https://github.com/hahaxiang27/FlowHarness

---

## 使用流程总览

```text
安装 → 执行宪法 → 新开会话 → 描述需求 → 确认计划 → 逐步「继续」 → 完成
```

---

## Step 1：安装到项目

```bash
git clone https://github.com/hahaxiang27/FlowHarness.git
cd FlowHarness
cd /path/to/your/project
bash /path/to/FlowHarness/install.sh --agent cursor
```

- Cursor 用户选 `--agent cursor`；Claude Code / Codex 等选 `--agent all` 或对应选项
- 项目里**已有 `AGENTS.md`** 时，默认**智能合并**，不会删除你的自定义内容

---

## Step 2：执行项目宪法（安装后的第一个会话）

安装完成后，在**当前项目里打开 AI 会话**。  
AI 会**主动提示先执行宪法**，或你直接说：

> 先帮我初始化项目宪法

AI 执行 `speckit.constitution`，交互式填写 `.specify/memory/constitution.md`，完成后**停下等你确认**。  
**宪法没建好之前，不要开始正式需求开发。**

---

## Step 3：宪法完成后，新开一个会话

宪法确认无误后，**新开一个 AI 会话**，再描述需求。

这样 `AGENTS.md`、`.cursor/rules/` 会在「宪法已就绪」的前提下重新加载，Router、Step Gate、Dashboard 流程更稳定。  
若必须用同一会话，可在描述需求时 `@AGENTS.md` 作为兜底，但**仍建议新开会话**。

### 各模式对应的命令列表

Router 会根据需求描述自动选模式，选中后按下列命令**逐步执行**（`direct` 除外）。

**标准 SpecKit spec 阶段顺序**（`speckit.constitution` 在需求前单独完成）：

```
speckit.specify → speckit.clarify → speckit.checklist → speckit.plan → speckit.tasks → speckit.analyze
```

| 模式 | 适用场景 | 命令流 |
|------|----------|--------|
| **direct** | 极小 UI/文案改动，≤2 文件 | 无命令链，直接改代码（跳过 spec、dashboard、Step Gate） |
| **doc** | 写 PRD、需求文档、验收标准，暂不写代码 | `speckit.specify`<br>`speckit.clarify`<br>`speckit.checklist` |
| **fast** | 小 bug、低风险、单文件改动 | `context.scan`<br>`harness.exec`<br>`harness.eval` |
| **speclite** | 中等功能（单页、若干 API、业务逻辑） | `speckit.specify`<br>`speckit.clarify`<br>`speckit.plan`<br>`speckit.tasks`<br>`harness.exec`<br>`harness.eval`<br>`harness.fix` |
| **full** | 高风险、跨模块（支付、权限、数据迁移等） | `speckit.specify`<br>`speckit.clarify`<br>`speckit.checklist`<br>`speckit.plan`<br>`speckit.tasks`<br>`speckit.analyze`<br>`harness.scope`<br>`harness.start`<br>`harness.exec`<br>`harness.eval`<br>`harness.fix`<br>`harness.checkpoint`<br>`harness.metrics` |
| **debug** | 构建失败、测试失败、生产问题排查 | `context.scan`<br>`harness.review`<br>`harness.fix`<br>`harness.eval`<br>`harness.checkpoint` |

> 配置来源：`.ai-dev/router/modes.yml`

### full 模式最终文档结构

假设需求标识为 **`DPCMNM-123: xxx`**，目录名通常取路径安全形式 **`DPCMNM-123-xxx`**。

```text
your-project/
│
├── specs/
│   └── DPCMNM-123-xxx/
│       ├── spec.md
│       ├── plan.md
│       ├── research.md
│       ├── data-model.md
│       ├── quickstart.md
│       ├── tasks.md
│       ├── dashboard.html
│       ├── dashboard-state.json
│       ├── checklists/
│       │   ├── requirements.md
│       │   └── security.md
│       └── contracts/
│           └── payment-callback.yaml
│
├── .harness/
│   ├── scope/
│   │   └── sprint-1.yaml
│   ├── sprints/
│   │   └── DPCMNM-123-xxx/
│   │       ├── sprint-1.md
│   │       ├── sprint-1-progress.md
│   │       └── sprint-1-checkpoint.md
│   └── metrics/
│       └── DPCMNM-123-xxx/
│           └── sprint-1.json
│
├── src/
│   └── ...
├── tests/
│   └── ...
└── .ai-dev/
    └── context/
        ├── mistakes.md
        ├── known-patterns.md
        └── team-rules.md
```

| 命令 | 主要产出 |
|------|----------|
| `speckit.specify` | `spec.md`、`checklists/requirements.md` |
| `speckit.clarify` | 回写 `spec.md` |
| `speckit.checklist` | `checklists/{领域}.md` |
| `speckit.plan` | `plan.md`、`research.md`、`data-model.md`、`quickstart.md`、`contracts/` |
| `speckit.tasks` | `tasks.md` |
| `speckit.analyze` | 一致性审计报告（默认在对话中输出） |
| `harness.scope` | `.harness/scope/sprint-1.yaml` |
| `harness.start` | Sprint 状态汇报，更新 `dashboard.html` |
| `harness.exec` | 源代码变更 + `sprint-1-progress.md` |
| `harness.eval` | 验证报告 |
| `harness.fix` | 修正记录 |
| `harness.checkpoint` | `sprint-1-checkpoint.md` |
| `harness.metrics` | `sprint-1.json`，可选回写 `.ai-dev/context/` |

> 计划阶段会初始化 `dashboard.html` 和 `dashboard-state.json`（在第一个 spec/harness 命令之前）。

---

## Step 4：用自然语言描述需求

在新会话里直接说需求，可带工单号，例如：

> DPCMNM-123：增加一个登录设备 MAC 地址监控列表页面

**不用记 slash 命令。** AI 自动读 Router、选模式、列出后续命令流。

---

## Step 5：看计划，确认后再继续

AI 第一次回复会告诉你：

- 选中的模式（`speclite` / `full` / `direct` 等）
- 计划执行的命令流
- 产物目录（`specs/{需求ID}/`）
- Dashboard 路径

确认后回复 **「继续」**。每回复一次，AI **只执行一步**，做完再停下。

---

## Step 6：用浏览器看进度（非 direct 模式）

```
specs/你的需求ID/dashboard.html
```

页面自动刷新，显示当前步骤和下一步。也可直接问：「DPCMNM-123 做到哪了？」

---

## Step 7：重复「继续」，直到完成

```text
你说需求 → AI 出计划 → 你说「继续」→ AI 执行一步 → 停下
                ↑                                    |
                └──────────── 重复 ──────────────────┘
```

- **direct** 模式：直接改代码，无需反复「继续」
- **full** 模式：步骤更完整，仍每步暂停
- 可手动调用 `/speckit.*` 或 `/harness.*`，默认同样遵守 Step Gate

---

## 使用示例

### 示例 1：中等功能（speclite）

**你说：**

> DPCMNM-123：增加 MAC 地址监控列表页，支持搜索和导出

**AI 示意：**

```text
模式：speclite · 风险：低
命令流：speckit.specify → speckit.clarify → speckit.plan → speckit.tasks
        → harness.exec → harness.eval → harness.fix
Dashboard：specs/DPCMNM-123/dashboard.html
请确认后回复「继续」
```

**你说：** `继续` → 执行 `speckit.specify` → 停下 → 继续下一步…

---

### 示例 2：改按钮文案（direct）

**你说：**

> 把「提交」改成「立即登录」，只改文案

**AI：** 选 `direct`，直接改代码给 diff，结束。

---

### 示例 3：支付接口（full）

**你说：**

> 新增微信支付回调，涉及订单状态变更和退款

**AI：** 选 `full`，展示完整命令流，等你确认后逐步「继续」。

---

### 示例 4：只写文档（doc）

**你说：**

> 写登录模块 PRD 和验收标准，先不写代码

**AI：** 选 `doc`，执行 specify → clarify → checklist。

---

### 示例 5：查进度

**你说：**

> DPCMNM-123 做到哪了？

**AI：** 读 `dashboard-state.json`，汇报已完成步骤与下一步。

---

## 截图占位

| 文件 | 建议内容 |
|------|----------|
| `docs/screenshots/01-install-complete.png` | 安装完成 |
| `docs/screenshots/02-constitution-init.png` | 宪法初始化 |
| `docs/screenshots/03-router-mode-selection.png` | 模式选择与命令流 |
| `docs/screenshots/04-dashboard-plan-init.png` | Dashboard 初始化 |
| `docs/screenshots/05-step-gate-handoff.png` | 单步执行与 handoff |
| `docs/screenshots/06-dashboard-live-refresh.png` | Dashboard 执行中 |
| `docs/screenshots/09-cursor-natural-language-flow.png` | Cursor 完整对话 |

---

## 一句话总结

**安装一次，说清需求，看面板进度，每一步你来掌控。**
