<!--
Harness-Enhanced Constitution Template

这份模板是基于 SpecKit 官方 5 原则骨架，融合 Harness 驱动开发框架
在团队实践中沉淀的若干增量原则（用户界面可视化验证、视觉质量、Corrector 回归纪律、模块边界纪律 等）。

使用方式：
1. 复制本文件到 `.specify/memory/constitution.md`
2. 用 `/speckit.constitution` 命令交互式填充（推荐）
3. 或手动替换所有 [PLACEHOLDER]，按项目删减原则数量

版本记号：保留 MAJOR.MINOR.PATCH 语义化版本。
- MAJOR: 原则删除/重定义
- MINOR: 新增原则/章节
- PATCH: 措辞澄清/修正
-->

# [PROJECT_NAME] Constitution

## Core Principles

### I. [ARCHITECTURE_PRINCIPLE]
<!-- 填写项目架构原则，例如 [ARCHITECTURE_STYLE] -->
[DESCRIPTION]

### II. [CONTRACT_PRINCIPLE]
<!-- 填写项目契约原则，例如 [CONTRACT_STANDARD] -->
[DESCRIPTION]

### III. 测试纪律 (Test Discipline)
<!-- 几乎所有项目都需要的硬性原则，保留不删 -->
所有业务关键路径必须有自动化测试覆盖。
- 核心业务逻辑必须有单元测试；接口 / 边界必须有集成测试或契约测试
- 涉及数据完整性、计费、权限、审计的逻辑必须有 **100% 分支覆盖**
- 测试必须可在 CI 环境中独立运行，不依赖外部服务（通过 Mock / Stub）
- [PROJECT_SPECIFIC_ADDITIONS]

### IV. [EXTERNAL_SERVICE_PRINCIPLE]
<!-- 填写外部服务治理原则，例如 [EXTERNAL_SERVICE_NAME] 适配层 -->
所有外部依赖必须通过统一抽象层访问。
- [DESCRIPTION]

### V. 可观测性优先 (Observability First)
- 所有接口请求必须有结构化日志（请求 ID、用户 ID、耗时、状态码）
- 关键业务指标必须通过项目指标系统暴露
- 错误必须有唯一追踪 ID，支持从用户界面错误追溯到服务或核心日志

### VI. 简单优先 (Simplicity / YAGNI)
- 不引入当前阶段不需要的框架 / 运行时组件
- 每次引入新依赖必须在 `plan.md` 的 Complexity Tracking 中记录理由
- 优先选择简单、直接的实现，除非测量出瓶颈

### VII. [SECURITY_PRINCIPLE]
<!-- 填写项目安全原则，例如 [SECURITY_MODEL] / [DATA_PROTECTION_RULES] -->
[DESCRIPTION]

---

**以下 3 条为 Harness 框架增强原则，是在团队迭代中沉淀出的。**
**如果你的团队使用 Harness `.harness/prompts/evaluator.md` 和 `corrector.md` 流程，强烈建议保留。**

### VIII. 用户界面可视化验证 (User Interface Visual Verification)
用户界面任务的验证不能仅依赖静态检查或编译结果（编译通过 ≠ 功能可用），必须通过 `[E2E_TOOL]` 自动化验证交互正确性，并经过截图视觉审查。

**交互断言层**:
- 含用户界面交互的任务，L1 验证必须包含 `[E2E_TOOL]` 截图 + 交互断言
- 每个用户界面批次完成后的门禁必须包含 `[E2E_TOOL]` 可视化回归检查
- 同一可交互元素必须测试**所有可点击区域**（图标 / 文字 label / 空白区域）

**截图视觉审查层**:
- `[E2E_TOOL]` 必须在关键节点截图（初始态、操作后、弹窗、结果页）
- 截图必须被视觉审查确认（自动化读图分析 或 人工审查），断言通过但截图异常视为 FAIL
- 审查必须覆盖页面四角和边缘控件（关闭按钮、滚动条、角标）

**深度点击子页层**:
- "顶层 URL 巡检 PASS" ≠ "用户真实路径 PASS"
- 每个 User Story 的 `[E2E_TOOL]` 必须有至少一条路径是"从父页用户动作进子页"，**禁止**直接打开子页绕过真实路径
- 到达子页后必须验证：(a) 主体内容区渲染 (b) 所有接口调用状态 (c) 至少点 1 个子交互

**涉真实外部服务（[EXTERNAL_SERVICE_NAME] / 第三方服务）时的实物验收**:
- L4 Checkpoint 审查员必须启动完整栈至少 1 次 · 不能纯看 progress.md 数字
- 至少 1 次真实外部调用端到端走查 SUCCEEDED（本地凭证可完成的场景不可 DEFERRED）
- 浏览器肉眼打开用户界面页面 · 截图存证 ≥ 2 张
- Mock / fixture 模式 `[E2E_TOOL]` 通过 ≠ 真实用户界面验收 PASS

### IX. [VISUAL_QUALITY_PRINCIPLE]（用户界面视觉质量标准）
<!-- 若项目无用户界面，本原则可删除；若有用户界面，保留并按品牌定制 -->
用户界面页面不仅要功能正确，还要满足专业级视觉质量。
- **布局**: 内容区最大宽度约束 + 8px 基线网格
- **视觉层次**: 清晰的焦点和阅读动线（标题 → 核心内容 → 操作区）
- **品牌色**: [PRIMARY_COLOR] / [SECONDARY_COLOR] / [ACCENT_COLOR] / [SUCCESS_COLOR] 区分语义
- **状态设计**: 空状态、加载态、错误态必须有专门的视觉设计，不能留白
- **交互反馈**: hover / active 必须有视觉反馈（颜色、阴影、位移）
- 自动化生成的页面必须经过设计审查，不能只是"能用"

### X. Corrector 修正回归纪律 (Corrector Regression Discipline)
每轮 Corrector 修正不能只验证"原 bug 是否修好"，必须同时验证"修正是否引入新问题"。
- 每轮修正后，必须对修改涉及的组件做**完整交互路径回归**
- 修改第三方用户界面组件行为时，必须先理解该组件的结构和事件传播机制
- 修正引入的新问题视为同一轮次的 FAIL，必须在当前轮次内一并解决
- 最多 3 轮修正，超过则人工介入

### XI. 模块边界纪律 (Module Boundary Discipline)
"焦点 / 出范围"必须是结构化数据驱动的硬约束，不是 prose 文档。Spec 之间的实体消费必须显式申报，反向依赖必须自动验证。

**结构化 scope（强制）**:
- 每个 Sprint 必须有一份 `.harness/scope/sprint-<N>.yaml`，按 `harness/scope-template.yaml` 的 schema 声明 `in_scope` / `out_of_scope` / `dependency_rules`
- CLAUDE.md 里的"焦点 / 出范围"叙述必须与该 yaml 一致 · 叙述不是约束源 · yaml 才是
- yaml 修订必须 PR + 评审，与 Constitution 修订同等级别

**反向依赖禁令**:
- in_scope 模块**不得依赖 / 引用** out_of_scope 模块（默认 severity=error）
- out_of_scope 模块本 Sprint 内**不得新增**对 in_scope 的依赖 / 引用（severity=warning · 检测到说明出范围模块在被悄悄改）
- 历史遗留违规登记到 yaml 的 `known_violations` · 列出后允许冻结，但**禁止扩大**：同一 (from, to) 的文件清单只能减少不能增加
- 横切关注点（`*ExceptionHandler` / `*Aspect` / `*EventListener` / `*Configuration` 等）天然跨模块引用是合理设计 · scope.yaml `cross_cutting_exempt` 列出豁免规则。豁免不是"忽略" —— sensor 仍报 INFO 让其可见，不阻断 L2 但记入 Checkpoint 长期趋势

**跨 spec 实体消费的显式申报**:
- spec 模板的 "External Dependencies" 段必须列出本 feature 消费的其他 spec 的实体 / 服务 / 事件（producer-consumer 关系）
- data-model.md 的每个数据模型对象必须填 "Consumed By" · 如果 consumer ≠ owning feature · 模块归属在 plan 阶段就要重新讨论 · 不是事后审计

**自动化 sensor**:
- L2 验证（evaluator.md §2.4）必须运行 boundary-reviewer · 对照 scope.yaml 输出违规清单
- 任一 error 级违规 → L2 FAIL → 触发 Corrector 或升级 scope
- warning 级违规 → 不阻断但记入 Checkpoint · 连续 2 个 Sprint 出现同一 warning 必须升级处理

**与既有 plan-template "Scope 边界验证清单" 的关系**:
- 那张表是 **contract-level** 边界（"零 X 改动"承诺 vs 下游 schema drift）· 由人工填写
- 本原则是 **module-level** 边界（模块依赖图 vs scope.yaml 申报）· 由 sensor 自动验证
- 两层互补不替代：contract-level 防"我说零用户界面改动结果改了 schema"，module-level 防"我说出范围结果还在新增依赖"

### XII. Spec 颗粒度纪律 (Spec Sizing Discipline)

一个 spec 太大会沿流程链放大：spec 大 → plan 重 → tasks 膨胀 → 单 sprint 装不下 → 质量妥协。Sprint 颗粒度问题的根因在 spec 阶段，必须在最上游卡住。

**硬阈值（默认）**:

- 一个 spec 包含 **≤ 3 个 user story**（紧密耦合的小 story 可视为 1 个）
- 由 spec 派生的 sprint **≤ 30 个 task**
- 超阈值必须**在 specify 阶段拆分**，不允许"先这样写完再说"

**强制点**:

- `/harness.plan` Step 0：读 spec.md 数 user story；读 tasks.md（如存在）数 task。任一超阈值 → **阻断 sprint plan 生成** · 提示走拆分流程
- `/harness.spec-check <spec-id>`：独立审计命令，可以在 spec 完成后任意时刻跑

**超阈值的 3 选 1 处理**（不允许"再加几个 task 就好"绕过）:

1. **拆 spec**（推荐）· 按 user story 边界切成 N 个独立 spec，依次走 specify → plan → tasks
2. **合并 user story**（仅当几个 story 真正紧密耦合，独立交付不构成完整价值）
3. **升级 justification**（仅当确实有不可拆分的根本理由 · 必须在 spec 末尾显式声明，并对应增大 sprint 容量预估）

**与 SDD 上游 speckit 的关系**:

- 不修改 speckit 上游命令（specify / plan / tasks）—— 保留上游同步能力
- 强制点全部加在 harness 命名空间（`/harness.plan` / `/harness.spec-check`）

**血泪溯源**:

Sprint 49 单 sprint 51 task 膨胀是这条规则缺失的直接后果——5 个 user story 塞一个 spec，下游必然爆炸。本原则把"≤ 30 task"从经验值升格为可机器验证的硬约束。

---

## 项目技术约束

### [TECH_STACK_SECTION]
<!--
填写项目实际运行时、依赖、构建、测试、数据存储和交互验证工具。
请使用项目事实或槽位，不在模板中列出默认技术栈候选。

示例结构：
- 服务 / 核心运行时: [BACKEND_RUNTIME]
- 用户界面运行时: [FRONTEND_RUNTIME]
- 数据存储: [DATA_STORE]
- 测试命令: [TEST_COMMAND]
- 构建命令: [BUILD_COMMAND]
- 交互验证工具: [E2E_TOOL]
-->

## 开发工作流

### 代码规范
- [PROJECT_LINT_RULES]

### 分支策略
- 主分支保护，通过 PR 合并
- 功能分支命名遵循 speckit 格式：`NNN-feature-short-name`（由 `/speckit.specify` 自动创建）

### 代码评审
- 所有变更必须经过至少一人评审
- 涉及安全 / 权限 / 外部服务抽象层的变更必须两人评审
- 评审重点：是否违反 Constitution 原则、是否有安全隐患、是否有充分测试

## Governance

本 Constitution 是项目的最高级技术治理文件，所有实现决策必须与其保持一致。

- 所有 PR 评审必须检查是否符合 Constitution 原则
- 引入新的复杂度（新依赖、新架构模式、新运行时组件）必须在 `plan.md` 中记录理由
- 修订 Constitution 必须提交 PR 并经过团队评审，附带修订说明和影响分析
- 版本管理采用语义化版本：MAJOR（原则删除/重定义）、MINOR（新增原则/章节）、PATCH（措辞澄清/修正）
- 每个迭代周期结束时进行一次 Constitution 合规回顾（Harness Checkpoint）

**Version**: 1.0.0 | **Ratified**: [YYYY-MM-DD] | **Last Amended**: [YYYY-MM-DD]
