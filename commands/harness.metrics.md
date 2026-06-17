---
name: harness-metrics
description: 生成 Sprint 五维度量报告，统计约束、上下文、验证、修正和效率指标。
triggers:
  - harness metrics
  - sprint metrics
  - delivery metrics
  - Sprint 度量
  - 五维度量
  - 度量报告
---

# Harness Sprint 度量报告

**上下文管理**: 🔄 清空上下文 — 使用子代理执行，纯粹基于进度文件生成数据

## 指令

生成当前 Sprint 的五维度量报告。

### 输入参数

$ARGUMENTS — 可选：
- Sprint 编号（如 "1"）
- "trend" — 生成跨 Sprint 趋势分析

### 执行步骤

使用 Agent 工具启动子代理，传入以下任务：

```
你是 Harness 度量分析师。基于进度数据生成度量报告。

1. 读取 `.harness/sprints/sprint-{N}-progress.md`
2. 读取 `.harness/prompts/metrics.md` 了解度量指标定义和计算公式
3. 基于进度文件中的数据，计算五维度量：
   - 约束层: 硬/软约束违反次数、约束遵守率
   - 信息层: 契约覆盖率、模型覆盖率、模板使用率
   - 验证层: 首次通过率、验证分数、E2E通过率
   - 修正层: 修正收敛率、平均轮次、人工介入次数
   - 执行质量: Sprint完成率、平均任务耗时、有效代码率
4. 生成健康度仪表盘（🟢/🟡/🔴）
5. 提出 Top 3 改进建议

输出：
a. 终端显示度量摘要
b. 写入完整报告到 `.harness/metrics/sprint-{N}.json`

如果参数为 "trend":
a. 读取 .harness/metrics/ 下所有 sprint-*.json
b. 生成跨 Sprint 趋势对比表
c. 识别改善和恶化的指标
d. 输出预测和建议
```

## Dashboard 观测面板更新

metrics 完成后，按 `.harness/prompts/dashboard-updater.md` 中 Step 17 规则更新 `specs/{feature}/dashboard.html`：
- 填充 `#panel-metrics` 面板：五维健康度色块 + 统计数字卡片（3x2）+ 全部阻塞项列表 + Top 3 改进建议 + Sprint 评级
- metrics 节点侧边栏状态改为 `done` + `ok`，同时更新 `.topbar` 中的评级

## Memory 更新

如果本次 Sprint 暴露出可复用模式、踩坑、评审反馈或团队规则变化，直接更新 `.ai-dev/context/` 下的对应文件：

- `.ai-dev/context/mistakes.md`
- `.ai-dev/context/known-patterns.md`
- `.ai-dev/context/review-feedback.md`
- `.ai-dev/context/reusable-patterns.md`
- `.ai-dev/context/team-rules.md`

## SDD Step Gate

When specs/{REQUIREMENT_ID}/dashboard-state.json exists (SDD workflow active), after this command completes follow .harness/prompts/command-step-gate.md:

1. Update dashboard-state.json and dashboard.html when applicable.
2. Mark this command done, next step next, workflow_plan.phase = awaiting_user.
3. **Stop immediately** - do not chain the next internal command in the same turn.
4. Hand off with .harness/prompts/step-gate-handoff.md.

Skip only for standalone invocation without dashboard state, or when the user explicitly asks to batch remaining steps.


## Requirement Artifact Path Convention

For a requirement id `{REQUIREMENT_ID}`, keep all delivery artifacts bucketed by that id:

- Specs and dashboards: `specs/{REQUIREMENT_ID}/`
- Harness sprint plans/progress: `.harness/sprints/{REQUIREMENT_ID}/`
- Harness metrics and reports: `.harness/metrics/{REQUIREMENT_ID}/`

Do not create a second numbered feature folder for the same requirement.
