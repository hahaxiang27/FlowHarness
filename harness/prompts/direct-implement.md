# Direct Implement

Use this prompt when Router selects `direct` mode.

## Rule

**Do not run SDD / SpecKit / Harness for this request.**

Skip all of the following unless the user explicitly asks to switch back to the full toolkit:

- `specs/{REQUIREMENT_ID}/`
- `.harness/sprints/` / `.harness/metrics/`
- `dashboard.html` / `dashboard-state.json`
- `speckit.specify` / `speckit.plan` / `speckit.tasks`
- `harness.plan` / `harness.exec` / `harness.eval` / step-gate handoffs

## Workflow

1. Restate the tiny scope in one sentence.
2. Locate the target page/component in the existing codebase.
3. Implement the change directly with the smallest correct diff.
4. Reuse existing Modal/Button/components when the project already has them.
5. Run the project's normal validation if available (lint, typecheck, unit test, dev build).
6. Tell the user what files changed and how to verify in browser.

## Example: login help button + modal

Typical touch points:

- login page component
- existing modal/dialog component or a tiny new presentational component
- local styles only if needed

Do not change authentication, routing guards, API calls, or backend code.

## User Message

```markdown
## 判定结果：Direct Mode

这是一个极简前端改动，**不进入 SDD/Harness 工具链**，我将直接修改代码。

### 将要做的事
- {one-line scope}

### 不会做的事
- 不创建 specs / dashboard / tasks
- 不跑 speckit / harness 内部命令

### 验证
- {lint/test/build commands or manual browser check}
```

## Escalation

Switch to `fast` or `speclite` only if you discover during implementation:

- more than 2 files/modules are truly required
- API/backend/auth/data changes are necessary
- the user explicitly asks for spec/plan/tasks or dashboard tracking

When escalating, stop coding, explain why direct mode is no longer sufficient, and rerun routing.
