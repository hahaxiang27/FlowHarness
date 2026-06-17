---
name: dashboard-state-updater
description: Update dashboard-state.json from current specs, tasks, Harness progress, metrics, reports, risks, evidence, and learning files.
---

# Dashboard State Updater

Update `specs/{REQUIREMENT_ID}/dashboard-state.json` beside `dashboard.html` so the dashboard shows delivery status and step-gate progress.

## Inputs

Read available artifacts in this order:

1. `specs/{REQUIREMENT_ID}/spec.md`, `plan.md`, `tasks.md`
2. `.harness/sprints/{REQUIREMENT_ID}/*progress.md`
3. `.harness/metrics/{REQUIREMENT_ID}/*.json`
4. `.harness/reports/*` or `.ai-dev/reports/*`
5. `.ai-dev/context/mistakes.md`, `team-rules.md`, `known-patterns.md`
6. `router/modes.yml` or `.ai-dev/router/modes.yml`

## Update Rules

1. Select the latest active requirement id and mode.
2. Write state to `specs/{REQUIREMENT_ID}/dashboard-state.json` beside `dashboard.html`.
3. Preserve `workflow_plan.steps` order. During execution, only the current command may be `active`. After a command finishes, mark it `done`, mark the following command `next`, and set `phase` to `awaiting_user`.
4. Set `workflow_plan.next_command` and `workflow_plan.next_command_label` to the upcoming `next` step.
5. Set `workflow_plan.phase` to `executing` only while a command is running; otherwise use `awaiting_user`, `planned`, or `completed`.
6. Summarize requirement clarity, open questions, and scope boundaries.
7. Summarize design state, impacted modules, and API contracts.
8. Summarize execution state, changed files, and remaining tasks.
9. Summarize verification state across build, tests, integration, security, and boundary review.
10. Summarize risk level, open risks, and human approval requirements.
11. Link evidence: diff, test results, review results, checkpoint, and metrics.
12. Capture learning added during the task.
13. Validate the output against `harness/templates/dashboard-state.schema.json`.

If `workflow_plan` is missing but `specs/{REQUIREMENT_ID}/dashboard.html` exists, rebuild `workflow_plan` from the active mode in router config before updating delivery fields.

## Output

Write `specs/{REQUIREMENT_ID}/dashboard-state.json` and report the path, requirement id, selected mode, open risks, verification status, and next action.
