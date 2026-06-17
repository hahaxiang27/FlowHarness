# Dashboard Updater — 全流程观测面板同步更新

## 设计目标

SDD + Harness 全流程中，AI 在完成每个步骤后，**同步更新** `specs/{feature}/dashboard.html`。该文件是给人看的流程观测面板：

- **左侧**：步骤流程导航（点哪个看哪个）
- **右侧**：当前步骤的**完整精炼内容**（表格/卡片/统计数字），充分展现 AI 生成的所有关键信息

核心原则：**MD 给 AI 读（详尽），HTML 给人读（精炼但完整）。两份产物，同一来源，同步生长。**

---

## 初始化：Feature 开始时

当 `speckit.specify` 完成，spec 目录确定后（如 `specs/002-login-security/`），从 `harness/templates/dashboard.html` 复制作为模板，执行以下替换：

1. `<title>` 中的 spec 编号和名称
2. `.topbar` 中的标题、spec-tag、日期
3. 清空所有 `.step-panel` 的内容（保留结构框架）
4. 左侧所有 `.step` 的 `s-dot` 和 `s-badge` 重置为 `pending`
5. 保留 CSS 和 JS 框架不变

**模板位置**: `harness/templates/dashboard.html`（通用模板，所有节点 pending，待 AI 逐步骤填充）

---

## 步骤更新规则

每完成一个流程步骤，按以下规则更新 dashboard.html：

### 通用规则

1. **左侧节点**：将当前步骤的 `.step` 中 `.s-dot` 从 `pending` 改为 `done`（或 `warn` 如有待办），`.s-badge` 改为 `ok`（或 `warn` 如有待办）
2. **右侧面板**：填充当前步骤 `#panel-{step}` 的完整精炼内容，充分展现 AI 生成的关键信息
3. **顶部日期**：更新 `.topbar .right` 中的统计数字

### 各步骤具体内容

#### Step 1: brainstorming
- **面板**：8 项关键决策表（决策点/选项/选择/理由四列）+ 架构图（ASCII 树形）
- **侧边栏 data-step**: `brainstorm`

#### Step 2: speckit.specify
- **面板**：US 总览表（所有 US/优先级/内容/FR数/SC数）+ 脱敏/业务规则定义表 + Edge Cases 完整列表 + 安全审查要点
- **侧边栏 data-step**: `specify`

#### Step 3: speckit.plan
- **面板**：技术研究决策表（#/主题/决策）+ Constitution 合规检查表（原则/状态）+ 数据模型概要 + API 契约清单
- **侧边栏 data-step**: `plan`

#### Step 4: speckit.tasks
- **面板**：所有 Task 明细表（ID/Phase/任务内容/依赖/可并行/产出文件）+ Phase 分解统计 + Constitution XII 合规检查
- **侧边栏 data-step**: `tasks`

#### Step 5: speckit.analyze
- **面板**：问题统计数字（CRITICAL/HIGH/MEDIUM/LOW 四色数字）+ 全部问题明细表（ID/严重度/文件/行号/描述/建议修复）
- **侧边栏 data-step**: `analyze`

#### Step 6: harness.plan
- **面板**：Sprint 配置表（批次/类型/任务范围/工时/门禁）+ 全部批次任务分配
- **侧边栏 data-step**: `hplan`

#### Step 7: harness.scope
- **面板**：In-Scope / Out-of-Scope 双栏卡片（逐项列出所有模块/文件）
- **侧边栏 data-step**: `scope`

#### Step 8: harness.start
- **面板**：环境检查清单表（检查项/状态两列）
- **侧边栏 data-step**: `start`

#### Step 9-14: harness.exec（每个批次）
- **面板**：本批次全部任务完成清单表（含每项任务状态/文件变更/验证结果）+ 如有人工待办则加黄色提示卡 + 如有修正则加修正记录表
- **侧边栏 data-step**: `b{批次号}`（如 `b11`, `b12`, `b13`...）
- **状态**：编译+测试通过 → `done`；有人工待办 → `warn`

#### Step 15: harness.eval
- **面板**：四级验证结果表（L1/L2/L3/L4 状态+详情+输出摘要）
- **侧边栏 data-step**: `eval`

#### Step 16: harness.checkpoint
- **面板**：Constitution 逐条审查表（原则/检查项/结果/扣分依据）+ 总得分 + 评级
- **侧边栏 data-step**: `checkpoint`

#### Step 17: harness.metrics
- **面板**：五维健康度色块 + 统计数字卡片（3x2）+ 全部阻塞项列表 + Top 3 改进建议 + Sprint 评级
- **侧边栏 data-step**: `metrics`

---

## 更新操作指南

### 更新侧边栏节点

```html
<!-- 从 -->
<div class="step" data-step="specify">
  <div class="s-dot pending">📋</div>
  <div class="s-info"><div class="s-name pending">speckit.specify</div>...</div>
  <span class="s-badge">待执行</span>
</div>

<!-- 改为 -->
<div class="step" data-step="specify">
  <div class="s-dot done">📋</div>
  <div class="s-info"><div class="s-name done">speckit.specify</div>...</div>
  <span class="s-badge ok">完成</span>
</div>
```

状态对应：
- `done` + `ok` = 顺利完成
- `warn` + `warn` = 完成但有人工待办
- `fail` + `fail` = 失败需修正

### 填充面板内容（通用模板）

```html
<div class="step-panel" id="panel-{step}">
  <div class="panel-header">
    <h2>{图标} {步骤名称}</h2>
    <div class="ph-meta">{日期} · {简述} · 产出 <code>{文件列表}</code></div>
  </div>
  
  <!-- 核心精炼内容区域 — 充分展现 AI 生成的所有关键信息 -->
  <div class="card-grid">
    <div class="card">
      <h3>{卡片标题}</h3>
      <table class="tbl">...</table>
    </div>
  </div>
</div>
```

### 更新顶部统计数字

```html
<!-- 在 .topbar .right 中更新 -->
<span>2026-06-10 → 2026-06-14</span>
<span>28 任务 · 12 完成 · 16 待执行</span>
<span class="grade">--</span>  <!-- Sprint 完成后更新评级 -->
```

---

## 内容精炼原则

面板内容是给人看的，兼顾完整性和可读性：

1. **完整呈现**：每个阶段的面板应充分展现 AI 生成的所有关键信息，如 tasks 阶段列出全部 task，analyze 阶段列出全部问题，不遗漏。
2. **表格优先**：能用表格就不用段落。表格每行一个关键信息，一眼扫完。
3. **数字说话**：用统计数字代替"大量""多个"等模糊描述。
4. **颜色编码**：绿色=通过/完成，黄色=待办/警告，红色=失败/阻塞，蓝色=信息。
5. **不复制 MD 原文**：面板是格式化的提炼展示，不是原始 MD 的复制粘贴。
6. **每面板独立**：人点哪个步骤就看哪个，不需要上下翻找上下文。
7. **信息密度优先**：面板行数不设硬性上限，以信息完整为第一优先。内容特别多的可用折叠卡片分组。

---


## Requirement Artifact Path Convention

For a requirement id `{REQUIREMENT_ID}`, keep all delivery artifacts bucketed by that id:

- Specs and dashboards: `specs/{REQUIREMENT_ID}/`
- Harness sprint plans/progress: `.harness/sprints/{REQUIREMENT_ID}/`
- Harness metrics and reports: `.harness/metrics/{REQUIREMENT_ID}/`

Do not create a second numbered feature folder for the same requirement.
