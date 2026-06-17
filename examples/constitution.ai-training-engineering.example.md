<!--
Sync Impact Report
- Version change: 1.3.0 → 1.4.0 (MINOR: enhanced VIII with deep-click verification)
- Principles (post-1.4.0):
  1. 前后端分离架构
  2. API契约驱动开发
  3. 测试纪律
  4. AI服务抽象层
  5. 可观测性优先
  6. 简单优先
  7. 安全与权限合规
  8. 前端可视化验证 (1.1.0: 交互断言; 1.2.0: +截图视觉审查; 1.4.0: +深度点击子页)
  9. 前端视觉质量标准 (NEW in 1.2.0)
  10. Corrector 修正回归纪律
- Rationale for 1.4.0:
  - VIII 增强: Sprint 27 收官走查 Playwright 96 passed + 11 admin 路由 goto 全绿，但用户
    点"最近课程"卡片进子页撞到"页面空白"（/courses/{id}/detail 后端 500 → 前端 catch +
    空渲染）。证明"顶层路由巡检 PASS ≠ 用户真实路径 PASS"——必须按 spec 故事深度点击子页，
    每次点击都验证 DOM 渲染 + Network 子 API 状态码。
  - 同次复盘发现根因是 JVM 启动时间早于代码 commit 12 小时（旧字节码），该问题落在
    evaluator.md L1 Step 4.0 Pre-flight（运行态校对）而非 Constitution 层，因为是流程约束
    不是代码约束。
- Templates requiring updates:
  - .harness/prompts/evaluator.md — L1 Step 4.0 Pre-flight + L1 Step 4e Deep-walk (已完成)
  - .harness/prompts/generator.md — 模板6 前端页面 追加"子页深度验证" (已完成)
  - .harness/tools/preflight-jvm.sh — L1 Step 4.0 自动化脚本 (已新增)
- Follow-up TODOs:
  - 既有 Playwright 基线补充"深度点击"场景（从父页真实点击进子页，而不是 goto 到末端 URL）
  - 新 feature 的 spec.md Acceptance Scenario 编写时明确"父页 → 子页"完整路径
-->

# AI原生工程师培训系统 Constitution

## Core Principles

### I. 前后端分离架构

前端与后端必须作为独立项目开发、构建和部署，通过API契约进行通信。

- 前端项目（`frontend/`）与后端项目（`backend/`）必须有独立的构建流程和依赖管理
- 前端与后端之间的所有通信必须通过RESTful API完成，禁止后端直接渲染前端页面
- 前端和后端必须可以独立启动、独立测试、独立部署
- 前端路由与后端路由必须完全解耦，前端采用客户端路由

### II. API契约驱动开发

所有前后端交互必须先定义API契约，再进行实现。

- 每个API端点必须在OpenAPI 3.0规范文件中定义，包含请求/响应结构、状态码和错误格式
- API契约变更必须先更新规范文件，再修改实现代码
- 前后端可基于契约并行开发：前端使用Mock数据，后端使用契约测试验证
- API版本管理采用URL路径方式（如 `/api/v1/`），重大变更必须保持旧版本兼容期

### III. 测试纪律

所有业务关键路径必须有自动化测试覆盖，确保功能正确性和回归安全。

- 后端：核心Service层必须有单元测试，API端点必须有集成测试
- 前端：核心业务组件必须有组件测试，关键用户流程必须有端到端测试
- 认证考试评分、徽章授予、认证等级变更等涉及数据完整性的逻辑必须有100%分支覆盖的测试
- 每个API契约必须有对应的契约测试，验证实现与规范一致
- 测试必须可以在CI环境中自动运行，不依赖外部服务（AI服务通过Mock/Stub替代）

### IV. AI服务抽象层

所有AI/LLM交互必须通过统一的抽象层进行，禁止业务代码直接调用LLM API。

- 后端采用Spring AI框架作为LLM集成层（1.0 GA已生产就绪，提供模型无关抽象、Prompt模板、对话记忆等能力）
- 必须定义统一的AI服务接口（如ChatService、ScoringService），业务代码仅依赖接口
- LLM提供商切换（如从OpenAI切换到其他模型）必须仅需修改配置，不改变业务代码
- AI对话的Prompt模板必须外置管理（不硬编码在业务逻辑中），支持独立迭代和版本管理
- AI响应必须有超时控制和降级策略：超时后返回友好提示，不阻塞用户操作

### V. 可观测性优先

系统运行状态必须可被监控、追踪和诊断。

- 所有API请求必须记录结构化日志（请求ID、用户ID、耗时、状态码）
- AI服务调用必须记录：模型名称、Prompt Token数、响应Token数、耗时、成功/失败状态
- 关键业务指标必须通过指标接口暴露：考试提交数、认证通过率、AI调用成功率、API响应时间
- 错误和异常必须有唯一追踪ID，支持从前端错误提示追溯到后端日志

### VI. 简单优先

优先选择简单、直接的实现方案，仅在需求明确要求时才引入复杂度。

- 不引入当前阶段不需要的框架或中间件（YAGNI原则）
- 数据库设计优先使用简单的关系模型，仅在性能需求明确时才引入缓存层或读写分离
- 前端状态管理优先使用Vue 3的组合式API（Composition API）和响应式系统，仅在全局状态复杂度确实需要时才引入状态管理库
- 微服务拆分必须有明确的业务边界和性能瓶颈依据，初始阶段采用单体后端应用
- 每次引入新依赖或架构组件必须说明理由，在plan.md的Complexity Tracking中记录

### VII. 安全与权限合规

系统必须在认证、授权和数据保护方面满足企业级安全标准。

- 用户认证必须通过企业SSO/LDAP集成，系统不存储用户密码
- 所有API必须进行身份验证和权限检查，基于RBAC模型（工程师、管理员、课程制作者、BU负责人）
- 考试和认证数据必须防篡改：答题记录、评分结果、认证状态变更必须有审计日志
- 数据看板必须执行数据隔离：BU负责人仅可查看本BU详细数据
- 所有数据传输必须使用HTTPS加密

### VIII. 前端可视化验证

前端页面任务的验证不能仅依赖 type-check（编译通过≠功能可用），必须通过 Playwright 自动化验证交互正确性，并经过截图视觉审查。

**交互验证（断言层）**:
- 含 UI 交互的前端任务，L1 验证必须包含 Playwright 截图和交互断言，不能仅靠 type-check 通过
- 最低验证要求：页面可渲染（截图无空白/报错）+ 关键交互路径可点击（按钮/表单/导航）
- 每个前端批次完成后的门禁（L1 Step 4）必须包含 Playwright 可视化回归检查
- Playwright 测试用例与被测页面同步维护：新增页面必须同步新增对应的基线测试
- 交互验证覆盖范围：表单输入、按钮点击响应、弹窗/对话框定位、组件嵌套的事件传播
- 同一可交互元素必须测试所有可点击区域（图标、文字 label、空白区域），不能只测单一入口——用户最自然的操作往往不是点组件本身而是点文字

**截图视觉审查（真相层）**:
- Playwright 测试必须在关键交互节点截图（页面初始态、操作后状态、弹窗/确认框、结果页）
- 截图必须被视觉审查确认（读取截图分析 或 人工审查），断言通过但截图异常视为 FAIL
- 断言验证的是代码逻辑，截图验证的是用户真实看到的效果 — 两者缺一不可
- 截图保存路径: `tests/e2e/screenshots/`，命名规则: `{测试编号}-{状态描述}.png`
- 截图分辨率必须 ≥ 1280x720（实际视口尺寸），禁止使用缩略图审查
- 审查必须覆盖页面四角和边缘控件（关闭按钮、滚动条、角标等容易被忽略的元素），不能只看中心内容区

**深度点击子页（路径层）**:
- "顶层 URL 巡检 PASS" ≠ "用户真实路径 PASS"——路由挂载正常但子页聚合 API 500、空数据态
  等盲区只能靠深度点击暴露
- 每个 User Story 的 Playwright 必须有至少一条路径是"从父页 `click` 进子页"，**禁止**用
  `page.goto(末端子页 URL)` 绕过父页交互——这样跳过了真实用户触发的聚合 API 调用链
- 到达子页后 3 件事必须验证：(a) DOM 主体内容区渲染（不止 TopBar/Sidebar 等 chrome）；
  (b) Network 面板该页触发的**所有** API 状态码，非 2xx 必须定位；(c) 至少点 1 个子交互
  （按钮/链接/对话框），确认不是死链
- 前端 `try/catch` 里用 `ElMessage.error(...)` 兜底的场景必须额外检测：Network 4xx/5xx
  还在，测试不应只看页面没报错就放过
- 本条由 `.harness/prompts/evaluator.md` L1 Step 4e (Deep-walk) 强制执行

**真 AI + 真 UI 实物验收层（收官硬约束 · Sprint 47 血教训沉淀 · 2026-04-24）**:

涉及真 AI 场景或最终用户可见 UI 的 feature · L4 Constitution Checkpoint 和批次 5 Polish 门禁**不能只看 progress 文件数字**（mvn test 数 · Playwright Mock 通过数 · grep 清洁数等）· 必须含**实物验收**证据链：

- **批次 5 Polish L1 Step 4 增补 4f 子步骤**（涉真 AI 时强制）:
  - 4f.1 启动完整栈（PG + Redis + backend + frontend · 4a-4c 的合集）
  - 4f.2 切 scene-toggle 到 REAL（若适用）
  - 4f.3 **至少 1 次真 AI 端到端走查 SUCCEEDED**（经本地 Key 可完成的 SC 不可 DEFERRED · 此为纪律）
  - 4f.4 浏览器肉眼打开关联 UI 页面 · 截图存证 ≥ 2 张（feature 关键路径）
  - 4f.5 API response 字段齐全度检查 · 与 UI 显示一致
- **L4 Checkpoint 审查员方法论**:
  - 审查员必须启动完整栈至少 1 次 · 不能纯看 progress.md
  - 如审查员无法做实物验收（环境不具备 / Key 缺失 / 独立子代理隔离）· **必须显式声明并对原则 VIII 至少扣 1 分 CONDITIONAL**（不默认 PASS）
  - Mock 模式 Playwright 通过 **≠** 原则 VIII PASS（只能证明前端主路径不崩 · 不能代替真 AI + 真 UI 端到端验收）
- **DEFERRED 不是 PASS 理由**:
  - 若 feature 核心 SC（如"连续 N 次真 AI 走查"）被 DEFERRED 到灰度 · 原则 VIII 至少扣 1 CONDITIONAL
  - 本地 Key 可加载却未跑的 DEFERRED · 视为流程违规 · 原则 X Corrector 纪律亦扣 1
- **过程中 · 人工验证节点识别**（防 autopilot 到收官才暴雷）:
  - Sprint 规划阶段（planner 模板）必须识别至少 **2 个人工验证节点**：典型是 US1 MVP 批次完成 + 批次 5 Polish 收官前
  - 批次门禁行在人工验证节点必须标注 `👁 人工签收 (预期 N min)` · 由用户肉眼验收代替 AI 自评
  - 未标注 / 未执行人工签收直接收官 · 视为 `原则 VIII -2` + `原则 X -1`
- **Scope 漏洞承认优于假收官**:
  - 收官时 Constitution 打分必须按实测证据诚实扣分 · 发现 scope 漏洞（如 "零 X 改动" 声明被打破）即承认扣 1
  - 100/100 满分应是罕见事件 · 不能成为默认凑分目标

**本条由 `.harness/prompts/evaluator.md` L1 Step 4f + L4 审查员指令、`.harness/prompts/planner.md` 人工验证节点识别、`.claude/commands/harness.checkpoint.md` 实物验收预启栈指令共同强制执行**。

### IX. 前端视觉质量标准

前端页面不仅要功能正确，还要满足专业级视觉质量。AI 生成的页面必须经过设计审查，不能只是"能用"。

**布局规范**:
- 页面内容区最大宽度约束（如 1200px），居中对齐，两侧留白
- 全屏对话框内容必须有明确的视觉层次：顶部信息栏 → 主内容区 → 底部操作栏，操作栏固定底部
- 响应式布局：关键页面必须在 1280px 和 768px 两个断点下视觉正常
- 组件间距遵循 8px 基线网格（8/12/16/24/32/40px），避免随意数值

**视觉层次与信息架构**:
- 每个页面必须有清晰的视觉焦点和阅读动线（标题 → 核心内容 → 操作区）
- 使用品牌色体系（主色 #1B3A5C, 辅色 #2E6B9E, 强调色 #E8913A, 成功色 #10B981）区分语义
- 状态反馈必须有视觉区分：成功(绿)/警告(橙)/错误(红)/信息(灰)，不能只靠文字
- 空状态、加载状态、错误状态必须有专门的视觉设计，不能留白或仅显示文字

**交互细节**:
- 可点击元素必须有 hover/active 视觉反馈（颜色变化、阴影、位移）
- 表单项必须有清晰的选中态/未选中态视觉区分，不能仅依赖浏览器默认样式
- 弹窗/对话框必须在视口居中，不得出现定位偏移（嵌套 overlay 场景需特别注意）
- 操作按钮的语义颜色必须一致：主操作(primary)、危险操作(danger)、取消(default)

**审查时机**:
- 每个前端页面任务的 Playwright 截图必须经过视觉质量审查
- 审查维度：布局合理性、间距一致性、颜色语义正确性、状态反馈完整性
- 视觉质量不达标视为 L2 验证 FAIL，需走 Corrector 修正

### X. Corrector 修正回归纪律

每轮 Corrector 修正不能只验证"原 bug 是否修好"，必须同时验证"修正是否引入新问题"。

- 每轮修正后，必须对修改涉及的组件做**完整交互路径回归**，不能只回归原失败项
- 修改第三方组件（Element Plus、Ant Design 等）的交互行为时，必须先理解该组件的 DOM 结构和事件传播机制，再选择修正方案——不能盲目套用 `@click.stop` / `preventDefault` 等通用方案
- 修正引入的新问题视为同一轮次的 FAIL，必须在当前轮次内一并解决，不消耗额外轮次

## 技术栈约束

### 前端技术栈

- **框架**: Vue 3（Composition API）
- **UI组件库**: Element Plus（Element UI的Vue 3版本）
- **构建工具**: Vite
- **语言**: TypeScript（严格模式）
- **样式**: Tailwind CSS + Element Plus主题定制
- **图表**: ECharts（数据看板可视化）
- **测试**: Vitest（单元/组件测试）+ Playwright（E2E测试）

### 后端技术栈

- **框架**: Spring Boot 3.x
- **语言**: Java 21+
- **AI集成**: Spring AI 1.0（LLM抽象层、Prompt模板、对话记忆）
- **数据库**: PostgreSQL（业务数据）+ Redis（会话缓存、考试自动保存）
- **API规范**: OpenAPI 3.0 + SpringDoc
- **测试**: JUnit 5 + Spring Boot Test + Testcontainers（集成测试）
- **文件存储**: 对象存储服务（视频、课件素材）

### Spring AI 评估结论

经评估，项目采用Spring AI 1.0作为AI集成层，理由如下：

1. **生产就绪**: Spring AI 1.0于2025年5月GA发布，已稳定可用
2. **模型无关抽象**: 提供统一的ChatModel接口，支持多LLM提供商切换（符合FR中多模型切换需求）
3. **内置能力匹配**: Prompt模板管理、对话记忆（ChatMemory）、流式输出等能力直接满足AI伴学、实践教练、闯关对话等场景
4. **生态一致**: 与Spring Boot无缝集成，自动配置、可观测性、安全性均遵循Spring编程模型
5. **风险控制**: 若未来需升级到Spring AI 2.0，迁移路径清晰；若需替换，抽象层（原则IV）限制了影响范围

## 开发工作流

### 代码规范

- 后端代码必须通过Checkstyle检查（Google Java Style基础上的项目定制规则）
- 前端代码必须通过ESLint + Prettier检查
- 提交前必须通过所有Lint检查和单元测试（通过Git hooks强制执行）

### 分支策略

- `main` 分支为保护分支，仅通过Pull Request合并
- 功能分支从 `main` 创建，命名格式：`feature/xxx` 或 speckit分支格式
- 每个PR必须通过CI流水线（Lint + Test + Build）才能合并

### 代码评审

- 所有代码变更必须经过至少一人评审后才能合并到 `main`
- 涉及AI服务抽象层、认证逻辑、权限控制的变更必须经过两人评审
- 评审重点：是否违反Constitution原则、是否有安全隐患、是否有充分测试

## Governance

本Constitution是项目的最高级技术治理文件，所有实现决策必须与其保持一致。

- 所有PR评审必须检查是否符合Constitution原则
- 引入新的复杂度（新依赖、新架构模式、新中间件）必须在plan.md中记录理由
- 修订Constitution必须提交PR并经过团队评审，附带修订说明和影响分析
- 版本管理采用语义化版本：MAJOR（原则删除/重定义）、MINOR（新增原则/章节）、PATCH（措辞澄清/修正）
- 每个迭代周期结束时进行一次Constitution合规回顾

**Version**: 1.4.0 | **Ratified**: 2026-04-07 | **Last Amended**: 2026-04-18
