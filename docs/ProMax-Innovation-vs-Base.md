# ProMax 版说明（相对基线版 `speckit-harness-toolkit`）

> **基线版**：`D:\AAA-IPD\speckit-harness-toolkit`  
> **ProMax 版**：本仓库 `speckit-harness-toolkit-dashbosrd-promax`

---

## 一、原工具弊端 & 反馈问题合集

基线版命令和模板齐全，但在实际推广中暴露出这些问题：

| # | 问题 | 典型反馈 |
|---|------|----------|
| 1 | **门槛高** | 「必须记住 `/speckit.specify` → `/harness.exec` 整条命令链，新人不会用」 |
| 2 | **流程不可控** | 「AI 一次回复连跑好几个命令，我不知道做到哪了，也不好中途叫停」 |
| 3 | **被其他 Skill 抢跑** | 「brainstorming、TDD 等插件一进来就跳过规范流程，直接写代码」 |
| 4 | **大小需求一刀切** | 「改个按钮文案也要走 specify，太重；支付/权限类改动又没有自动加重审批」 |
| 5 | **进度不可见** | 「spec、plan、执行散落在文件夹里，没有一眼能看懂的进度面板」 |
| 6 | **Dashboard 装不上** | 「文档里有 dashboard，但 `install.sh` 不把模板复制到项目，实际用不了」 |
| 7 | **产物路径不统一** | 「工单号是 DPSHCT-2983，目录却是 `specs/003-xxx`，对不上」 |
| 8 | **Cursor 支持弱** | 「没有 Cursor 安装选项，也没有编排规则，换 IDE 就乱套」 |
| 9 | **已有 AGENTS.md 冲突** | 「项目里本来就有 Agent 规范，安装工具后要么跳过要么整文件覆盖」 |
| 10 | **经验无法沉淀** | 「同样错误反复犯，mistake、review 意见没有固定存放位置」 |

---

## 二、本工具主要针对哪些点优化

ProMax 版在**保留基线版 SpecKit + Harness 内核**的前提下，重点优化这 5 件事：

1. **降低使用门槛** — 用自然语言说需求，不用背命令
2. **管住执行节奏** — 一步一停，用户说「继续」才往下走
3. **按风险选流程** — 小改动快办，大改动/full 模式自动加重
4. **让人看得见进度** — 浏览器 Dashboard 实时展示当前步骤
5. **方便团队落地** — 支持 Cursor、AGENTS.md 合并、跨需求记忆沉淀

---

## 三、优化方案（分点）

| # | 针对问题 | 优化方案 | 关键实现 |
|---|----------|----------|----------|
| 1 | 门槛高 | **自然语言入口** | 去掉 `sdd.*` / `dev.*` wrapper；用户描述需求即可启动 |
| 2 | 流程不可控 | **Step Gate 逐步门禁** | 每轮只执行 1 个 `speckit.*` / `harness.*` 命令，完成后停下 |
| 3 | Skill 抢跑 | **Routing Gate 编排优先** | `AGENTS.md` + Cursor Rules 规定：先 Router，再执行，其他 Skill 不得插队 |
| 4 | 大小需求一刀切 | **Router 六模式** | `direct` / `doc` / `fast` / `speclite` / `full` / `debug`，按意图 + 风险评分自动选择 |
| 5 | 进度不可见 | **Dashboard ProMax** | `dashboard.html` + `dashboard-state.json`，浏览器自动刷新 |
| 6 | Dashboard 装不上 | **安装时完整铺设** | `install.sh` 复制 `harness/templates/` 到项目 |
| 7 | 产物路径乱 | **需求 ID 中心化** | `specs/{工单号}/`、`.harness/sprints/{工单号}/` 统一命名 |
| 8 | Cursor 支持弱 | **Cursor 一等支持** | `--agent cursor`，铺设 `speckit-harness-orchestration.mdc` |
| 9 | AGENTS.md 冲突 | **智能合并** | 保留你原有内容，顶部注入/更新 toolkit 编排段落 |
| 10 | 经验无法沉淀 | **AI Dev Memory** | `.ai-dev/context/` 存放 mistakes、patterns、team-rules 等 |

---

## 四、怎么用（用户视角）

### Step 1：安装到项目

```bash
cd 你的项目目录
bash /path/to/speckit-harness-toolkit-dashbosrd-promax/install.sh --agent cursor
```

- 用 Cursor 选 `--agent cursor`；用 Claude Code / Codex 等选 `--agent all` 或对应选项
- 项目里**已有 `AGENTS.md`** 也没关系，默认会**智能合并**，不会删掉你的自定义内容

---

### Step 2：执行项目宪法（安装后的第一个会话）

安装完成后，在**当前项目里打开 AI 会话**。  
按 `AGENTS.md` 约定，AI 会**主动提示你先执行宪法**，或你直接说：

> 先帮我初始化项目宪法

AI 会执行 `speckit.constitution`，交互式填写 `.specify/memory/constitution.md`，完成后**停下等你确认**。  
**宪法没建好之前，不要开始正式需求开发。**

---

### Step 3：宪法完成后，新开一个会话

宪法确认无误后，**新开一个 AI 会话**，再描述需求。

这样 `AGENTS.md`、`.cursor/rules/` 会在「宪法已就绪」的前提下重新加载，后续 Router、Step Gate、Dashboard 流程更稳定。  
若继续用 Step 2 的同一会话，可在描述需求时 `@AGENTS.md` 作为兜底，但**仍建议新开会话**。

#### 各模式对应的命令列表

Router 会根据你的需求描述自动选模式，选中后按下列命令**逐步执行**（`direct` 除外）。

**标准 SpecKit spec 阶段顺序**（宪法 `speckit.constitution` 在需求前单独完成）：

```
speckit.specify → speckit.clarify → speckit.checklist → speckit.plan → speckit.tasks → speckit.analyze
```

各模式在此基础上裁剪或扩展：

| 模式 | 适用场景 | 命令流 |
|------|----------|--------|
| **direct** | 极小 UI/文案改动，≤2 文件 | 无命令链，直接改代码（跳过 spec、dashboard、Step Gate） |
| **doc** | 写 PRD、需求文档、验收标准，暂不写代码 | `speckit.specify`<br>`speckit.clarify`<br>`speckit.checklist` |
| **fast** | 小 bug、低风险、单文件改动 | `context.scan`<br>`harness.exec`<br>`harness.eval` |
| **speclite** | 中等功能（单页、若干 API、业务逻辑） | `speckit.specify`<br>`speckit.clarify`<br>`speckit.plan`<br>`speckit.tasks`<br>`harness.exec`<br>`harness.eval`<br>`harness.fix` |
| **full** | 高风险、跨模块（支付、权限、数据迁移等） | `speckit.specify`<br>`speckit.clarify`<br>`speckit.checklist`<br>`speckit.plan`<br>`speckit.tasks`<br>`speckit.analyze`<br>`harness.scope`<br>`harness.start`<br>`harness.exec`<br>`harness.eval`<br>`harness.fix`<br>`harness.checkpoint`<br>`harness.metrics` |
| **debug** | 构建失败、测试失败、生产问题排查 | `context.scan`<br>`harness.review`<br>`harness.fix`<br>`harness.eval`<br>`harness.checkpoint` |

> - **full** 覆盖完整 spec 阶段（含 checklist、analyze），`analyze` 在 plan/tasks 之后执行一致性审计  
> - **speclite** 省略 checklist 和 analyze，加快中等需求交付  
> - **doc** 只跑 spec 前半段，不进入 plan/tasks/实现  
> - 配置来源：`.ai-dev/router/modes.yml`

#### full 模式最终文档结构

假设需求标识为 **`DPCMNM-123: xxx`**，目录名通常取路径安全形式 **`DPCMNM-123-xxx`**（`dashboard-state.json` 中保留完整标题）。full 模式跑完后，项目里大致会生成如下结构：

```text
your-project/
│
├── specs/                                    # 需求规格根目录
│   └── DPCMNM-123-xxx/                       # 本需求专属目录
│       ├── spec.md                           # speckit.specify / clarify
│       ├── plan.md                           # speckit.plan
│       ├── research.md                       # speckit.plan
│       ├── data-model.md                     # speckit.plan
│       ├── quickstart.md                     # speckit.plan
│       ├── tasks.md                          # speckit.tasks
│       ├── dashboard.html                    # 全流程可视化面板
│       ├── dashboard-state.json              # 步骤状态机
│       ├── checklists/                       # 质量检查清单
│       │   ├── requirements.md               # speckit.specify
│       │   └── security.md                   # speckit.checklist（示例）
│       └── contracts/                        # 接口契约
│           └── payment-callback.yaml         # speckit.plan（示例）
│
├── .harness/                                 # Harness 运行时产物
│   ├── scope/                                # 模块边界
│   │   └── sprint-1.yaml                     # harness.scope
│   ├── sprints/                              # Sprint 计划与进度
│   │   └── DPCMNM-123-xxx/
│   │       ├── sprint-1.md                   # Sprint 计划
│   │       ├── sprint-1-progress.md          # harness.exec
│   │       └── sprint-1-checkpoint.md      # harness.checkpoint
│   └── metrics/                              # 度量报告
│       └── DPCMNM-123-xxx/
│           └── sprint-1.json                 # harness.metrics
│
├── src/                                      # harness.exec 代码变更
│   └── ...
├── tests/                                    # harness.exec / eval 测试
│   └── ...
└── .ai-dev/                                  # 跨需求记忆（可选回写）
    └── context/
        ├── mistakes.md
        ├── known-patterns.md
        └── team-rules.md
```

**按命令对照（full 模式）**

| 命令 | 主要产出 |
|------|----------|
| `speckit.specify` | `spec.md`、`checklists/requirements.md` |
| `speckit.clarify` | 回写 `spec.md` |
| `speckit.checklist` | `checklists/{领域}.md` |
| `speckit.plan` | `plan.md`、`research.md`、`data-model.md`、`quickstart.md`、`contracts/` |
| `speckit.tasks` | `tasks.md` |
| `speckit.analyze` | 一致性审计报告（**默认在对话中输出**，不落盘） |
| `harness.scope` | `.harness/scope/sprint-1.yaml` |
| `harness.start` | 汇报 Sprint 状态，更新 `dashboard.html` |
| `harness.exec` | 源代码变更 + `sprint-1-progress.md` |
| `harness.eval` | 验证报告（对话 + dashboard 面板） |
| `harness.fix` | 修正记录（对话 + dashboard 面板） |
| `harness.checkpoint` | `sprint-1-checkpoint.md` |
| `harness.metrics` | `sprint-1.json`，可选回写 `.ai-dev/context/` |

> 计划阶段还会初始化 `dashboard.html` 和 `dashboard-state.json`（在第一个 spec/harness 命令执行之前）。

---

### Step 4：用自然语言描述需求

在新会话里直接说你的需求，可带上工单号，例如：

> DPSHCT-2983：增加一个登录设备 MAC 地址监控列表页面

**不用记 slash 命令。** AI 会自动读 Router、选模式、列出后续要跑的命令。

---

### Step 5：看计划，确认后再继续

AI 第一次回复会告诉你：

- 选中的模式（如 `speclite` / `full` / `direct`）
- 计划执行的命令流
- 产物目录（`specs/{需求ID}/`）
- Dashboard 路径

确认没问题后，回复 **「继续」**。  
每回复一次「继续」，AI **只执行一步**，做完再停下告诉你下一步。

---

### Step 6：用浏览器看进度（非 direct 模式）

AI 初始化计划后，用浏览器打开：

```
specs/你的需求ID/dashboard.html
```

页面会自动刷新，显示当前步骤和下一步。  
想查进度也可以直接问：「DPSHCT-2983 做到哪了？」

---

### Step 7：重复「继续」，直到完成

```
你说需求 → AI 出计划 → 你说「继续」→ AI 执行一步 → 停下
                ↑                                    |
                └──────────── 重复 ──────────────────┘
```

- **小改动**（如改按钮文案）可能走 `direct` 模式，直接改代码，不需要反复「继续」
- **高风险需求**（如支付、权限）会走 `full` 模式，步骤更多，但仍是每步暂停
- 想手动跑某个 `/speckit.*` 或 `/harness.*` 命令也可以，默认同样遵守逐步暂停

---

> 📸 截图占位：`docs/screenshots/01-install-complete.png`（Step 1）  
> 📸 截图占位：`docs/screenshots/02-constitution-init.png`（Step 2）  
> 📸 截图占位：`docs/screenshots/03-router-mode-selection.png`（Step 5）  
> 📸 截图占位：`docs/screenshots/04-dashboard-plan-init.png`（Step 6）

---

## 五、实际使用示例

### 示例 1：中等功能需求（speclite 模式）

**你说：**

> DPSHCT-2983：增加一个登录设备 MAC 地址监控列表页面，支持按 MAC 搜索和导出

**AI 第一次回复（示意）：**

```
模式：speclite（中等功能，涉及列表页 + 查询，非 trivial UI）
风险：低

计划命令流：
  speckit.specify → speckit.clarify → speckit.plan → speckit.tasks
  → harness.exec → harness.eval → harness.fix

产物目录：
  specs/DPSHCT-2983/
  .harness/sprints/DPSHCT-2983/

Dashboard：
  specs/DPSHCT-2983/dashboard.html  ← 浏览器打开可看进度

请确认后回复「继续」，我将执行第一步 speckit.specify
```

**你说：** `继续`

**AI：** 执行 `speckit.specify`，生成 `spec.md`，更新 dashboard，停下，告诉你下一步是 `speckit.plan`。

**你说：** `继续` → 执行 `speckit.plan` → 停下 → … 依此类推。

> 📸 截图占位：`docs/screenshots/03-router-mode-selection.png`  
> 📸 截图占位：`docs/screenshots/05-step-gate-handoff.png`

---

### 示例 2：改个按钮文案（direct 模式）

**你说：**

> 把登录页「提交」按钮改成「立即登录」，只改文案，不动逻辑

**AI 回复（示意）：**

```
模式：direct（纯 UI 文案，≤2 文件，低风险）
跳过 spec / dashboard / Step Gate，直接改代码
```

**AI：** 直接修改对应文件，给出 diff，结束。不需要你反复说「继续」。

> 📸 截图占位：`docs/screenshots/10-direct-mode-bypass.png`

---

### 示例 3：支付相关高风险需求（full 模式）

**你说：**

> 新增微信支付回调接口，涉及订单状态变更和退款

**AI 回复（示意）：**

```
模式：full（命中 risk：payment、cross_module）
风险：高 — 需你确认后再执行

计划命令流：
  speckit.specify → speckit.clarify → speckit.checklist → speckit.plan
  → speckit.tasks → speckit.analyze → harness.scope → harness.start → harness.exec
  → harness.eval → harness.checkpoint → harness.metrics

请确认是否按 full 模式执行
```

**你说：** `确认，继续`

之后仍是每步暂停，但流程更完整，含 scope 边界审查和 checkpoint。

> 📸 截图占位：`docs/screenshots/06-dashboard-live-refresh.png`

---

### 示例 4：只看文档、不写代码（doc 模式）

**你说：**

> 帮我写一份用户登录模块的 PRD 和验收标准，先不写代码

**AI：** 选 `doc` 模式，跑 `speckit.specify` → `speckit.clarify` → `speckit.checklist`，产出 spec 和 checklist，不启动 Harness 执行。

---

### 示例 5：查进度

**你说：**

> 现在 DPSHCT-2983 做到哪了？

**AI：** 读 `specs/DPSHCT-2983/dashboard-state.json`，告诉你上一步完成的命令、下一步命令、风险项和 dashboard 路径。

---

## 截图占位（按需补充）

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

**基线版给你一套好命令；ProMax 版让你用说话的方式把这些命令跑起来，并且看得见、控得住、落得进团队。**
