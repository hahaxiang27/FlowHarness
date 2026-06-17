# 融合工作流纪律(Superpowers + SDD+Harness)

> 本片段由 speckit-harness-toolkit 的 `--with-superpowers` 铺设。在你的 `CLAUDE.md` 里加一行 `@CLAUDE.fusion.md` 即可让 Claude 自动遵循。
> 仅当本项目已启用 Superpowers 插件时有效。要回到纯基线,删除此引用即可。

本项目在 SDD+Harness 之上叠加 Superpowers 纪律。**执行循环归 Harness,唯一事实源是 `specs/` + `.harness/`;Superpowers 只按名提供纪律,不开自己的循环、不写计划文件。**

## 各阶段自动调起的 skill

- **起手挖需求**(specify 之前):调用 `superpowers:brainstorming`。产物仅作 specify 的草案,**严格收敛在需求与 constitution 范围内,不得发明需求外功能**。
- **每个任务实现**:在 `/harness.exec` 内引用 `superpowers:test-driven-development`,走 red-green-refactor,**不并行另起循环**。
- **实现后自检**:先用 `superpowers:requesting-code-review` 作 L0,再走 `/harness.eval`。
- **修 bug**:先用 `superpowers:systematic-debugging` 定位根因,再 `/harness.fix`。
- **声称完成前**:必须走 `superpowers:verification-before-completion`——没真跑过命令不算完成。

## 冲突纪律(三不)

1. **不调 `superpowers:writing-plans`**——plan 只用 `/speckit.plan`。
2. **TDD 在 `/harness.exec` 内引用,不并行跑两套循环。**
3. **进度只认 `.harness/sprints/*progress.md`**;Superpowers 的 TodoWrite/checkbox 不作为进度事实源。

> 何时该启用融合、以及增量未证的实验证据,见 `docs/Fusion-Superpowers-Integration.md`。

## 双轨输出·观测面板 (Dashboard)

全流程产出两条并行的内容线：**MD 给 AI 读（详尽）→ HTML 给人读（精炼但完整）**。

- **初始化**: `speckit.specify` 完成后，从 `harness/templates/dashboard.html` 复制模板到 `specs/{feature}/dashboard.html`，替换编号、名称、日期，重置所有节点为 pending。
- **逐步更新**: 每完成一个路由步骤，按 `harness/prompts/dashboard-updater.md` 规则同步更新 `dashboard.html`。
- **人不看 MD**: 面板直接展示完整精炼内容（表格/卡片/统计数字），每个阶段充分展现 AI 生成的所有关键信息，无需额外文件查看器。
