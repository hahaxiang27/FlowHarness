# 融合层 · Superpowers 集成指南(实验性 · 可选)

> **定位**:这是 SDD+Harness 之上的**可选第三层**,只在 Claude Code 上可用(Superpowers 是 Claude Code 插件,opencode/codex 不支持)。
>
> **诚实声明**:本融合层的**最终质量增量尚未被证实**。在一次"小而明确"的对照实验(coupon-fusion-exp,2026-05-29)中,叠加 Superpowers 与纯 SDD+Harness 基线**功能正确性打平(8/8 vs 8/8 统一裁判 curl)**,基线在测试密度、金额取整、错误面整洁度上反而更扎实。Superpowers 的价值体现在**过程纪律**(TDD red-green、code-review、verification),未转化为交付物优势。
>
> **因此**:默认不开。**推荐仅用于"大、模糊、易踩坑"的任务**——brainstorming / systematic-debugging 在那种场景才发力。小而需求锁定的任务别开,只会增加交互闸、拖长流程。

---

## 1. 这是什么 / 为什么

Superpowers 提供一组"工程纪律" skill(brainstorming、test-driven-development、systematic-debugging、requesting-code-review、verification-before-completion 等)。本融合层**不 vendor、不 fork** Superpowers,只规定**它的 skill 接在 SDD+Harness 流程的哪一步、以及怎么接才不打架**。

核心分工原则:

> **执行循环归 Harness,唯一事实源仍是 `specs/`(SpecKit)+ `.harness/`。Superpowers 只按名提供纪律,不开自己的循环、不写计划文件。**

## 2. 前置:安装并启用 Superpowers 插件

1. 在 Claude Code 里通过插件市场安装 Superpowers(`/plugin` 菜单,或 `claude plugin` CLI)。
2. 启用后,项目 `.claude/settings.json` 里会出现形如下面的开关(**以你本地 `claude plugin list` 显示的实际 key 为准**):
   ```json
   { "enabledPlugins": { "superpowers@claude-plugins-official": true } }
   ```
3. **必须在目标项目目录里新开 Claude Code 会话**——Superpowers 的 SessionStart 钩子只在会话启动时装载。在别处 `cd` 过去不算激活。
4. 验证:新会话里输入 `/`,看到 `superpowers:brainstorming` 等条目 = 激活成功。

> 用 `install.sh --with-superpowers` 可自动铺设上述开关与项目指令片段(见 README「可选第三层」)。

## 3. 阶段映射表(skill 接在哪一步)

| 阶段 | 命令 / skill | 说明 |
|---|---|---|
| 起手挖需求 | `superpowers:brainstorming` | 产物是喂给 specify 的**草案**,不是事实源;**严格收敛在需求与宪法范围内**,不得发明需求外功能 |
| 写 spec | `/speckit.specify` → `/speckit.clarify` | 与基线一致 |
| 写 plan | `/speckit.plan` → `/speckit.tasks` → `/speckit.analyze` | 与基线一致 |
| 执行准备 | `/harness.plan` → `/harness.scope` → `/harness.start` | 与基线一致 |
| 每个任务实现 | `/harness.exec` 内**引用** `superpowers:test-driven-development` | red-green-refactor,**不并行跑两套循环** |
| 实现后自检 | `superpowers:requesting-code-review` 作 L0,再 `/harness.eval` | L0 在 Harness 四级验证之前 |
| 修 bug | `superpowers:systematic-debugging` 先定位根因,再 `/harness.fix` | 先根因后修,符合原则 X 回归纪律 |
| 声称完成前 | `superpowers:verification-before-completion` | 没跑过命令不算过,强制 fresh 证据 |

## 4. 冲突纪律(三不)

三套体系叠加最大的风险是"两个计划循环 / 两套进度源打架"。守住三条:

1. **不调 `superpowers:writing-plans`** —— plan 只用 `/speckit.plan`,否则两份计划文件互相覆盖。
2. **TDD 是在 `/harness.exec` 内引用 skill,不并行跑两套** —— Harness 的 Generator 已是 TDD 骨架,Superpowers 的 TDD 作为纪律叠加,而非另起循环。
3. **进度只认 `.harness/sprints/*progress.md`** —— Superpowers 的 TodoWrite / checkbox 不作为进度事实源,跨会话恢复只读 Harness 进度文件。

## 5. 何时开融合(决策树)

```
任务需求是否被逐字锁定、规模小(单 sprint 可完成)?
  ├─ 是 → 不开融合。纯 SDD+Harness 已足够,融合只增开销。
  └─ 否 → 任务是否模糊 / 跨模块边界 / 有状态变更 / 易踩坑?
            ├─ 是 → 开融合。brainstorming 挖歧义、debugging 防踩坑在此发力。
            └─ 否 → 倾向不开,按需单点引用某个 skill 即可。
```

## 6. 实验证据(coupon-fusion-exp · 2026-05-29)

| | arm-A 纯基线 | arm-B 融合 |
|---|---|---|
| 8 条统一裁判 curl | 8/8 | 8/8 |
| pytest | 50 passed | 26 passed |
| 折扣取整 | Decimal+ROUND_HALF_UP | 整数 `//100` 截断 |
| 负数错误面 | 归一 400 | 默认 422(泄 schema 细节) |
| 终态质量增量 | — | **未观测到** |

结论:小任务上融合无净收益;价值在过程纪律。**待用更大、更模糊的任务复测,本指南会据新证据更新。**

## 7. 关闭 / 卸载

- **临时关闭**:把 `.claude/settings.json` 里 `enabledPlugins` 对应 key 改成 `false`,重开会话。
- **彻底卸载**:`claude plugin uninstall <你的-superpowers-key>`(以 `claude plugin list` 为准)。
- 移除项目里 `CLAUDE.fusion.md` 及 `CLAUDE.md` 中对它的 `@CLAUDE.fusion.md` 引用即可恢复纯基线行为。
