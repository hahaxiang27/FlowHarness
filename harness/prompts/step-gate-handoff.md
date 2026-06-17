# Step Gate Handoff

Use this prompt after **every** concrete SpecKit or Harness command completes, and after initial mode + dashboard plan publication.

## Rule

**One command per user turn.** Never chain multiple internal commands in the same assistant response unless the user explicitly asks to run multiple steps in one go (for example: "一口气跑完" or "run all remaining steps").

## When To Stop

Stop and hand control back to the user when:

1. Initial mode selection and dashboard initialization are complete.
2. Any concrete command finishes (`speckit.*`, `harness.*`, `context.scan`, etc.).
3. Missing information requires user input.
4. A high-risk or critical approval gate is reached.

Do **not** auto-continue because risk is low or medium.

## Update Dashboard Before Handoff

1. Write or update `specs/{REQUIREMENT_ID}/dashboard-state.json`.
2. Mark the command that just finished as `done`.
3. Mark the upcoming command as `next` (not `active`).
4. Set `workflow_plan.phase` to `awaiting_user`.
5. Set `workflow_plan.next_command` and `workflow_plan.next_command_label`.
6. Set `workflow_plan.next_user_action` to `下一步 / 继续 / next / continue`.

## Required User Message Format

```markdown
## 当前进度

- 需求 ID：`{REQUIREMENT_ID}`
- 刚完成：`{LAST_COMMAND}` — {one-line summary}
- 产物：{paths or key outputs}

## 可视化面板

打开：`specs/{REQUIREMENT_ID}/dashboard.html`
状态文件：`specs/{REQUIREMENT_ID}/dashboard-state.json`
面板每 3 秒自动拉取最新状态；也可手动刷新浏览器。

## 下一步

下一个内部命令：**`{NEXT_COMMAND}`** — {next command label}

{If approval required: 此步骤需要你先确认，因为 {reason}.}

请回复 **继续** / **下一步** / **next** / **continue** 后，我才会执行 `{NEXT_COMMAND}`。
```

If all planned steps are complete:

```markdown
## 当前进度

全部计划步骤已完成。

## 可视化面板

`specs/{REQUIREMENT_ID}/dashboard.html`

## 下一步

你可以本地验收、让我修复问题，或说 **继续** 进入收尾说明。
```

## Resume Rule

When the user says `继续`, `下一步`, `next`, or `continue`, read `workflow_plan.next_command` from `specs/{REQUIREMENT_ID}/dashboard-state.json`, execute **one** concrete command, then stop again with this handoff format.
