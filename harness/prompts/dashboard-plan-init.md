# Dashboard Plan Initialization (Phase 2)

Initialize the visual dashboard **immediately after** the agent selects a router mode and publishes the opening execution plan. Do this **before** the first SpecKit or Harness command runs.

## Goal

The user should be able to open `specs/{REQUIREMENT_ID}/dashboard.html` at Phase 2 and see the original-style dashboard:

- left sidebar for step navigation
- right `panel-workflow` for the planned internal command list
- dark top bar for requirement title and progress stats

## Files To Create Or Update

1. `specs/{REQUIREMENT_ID}/dashboard.html`
   - Copy from `.harness/templates/dashboard.html` when missing.
   - Do not hand-edit HTML unless the template changed upstream.

2. `specs/{REQUIREMENT_ID}/dashboard-state.json`
   - Validate against `.harness/templates/dashboard-state.schema.json`.
   - Must include `workflow_plan`.

3. `.specify/feature.json`
   - Set `feature_directory` to `specs/{REQUIREMENT_ID}`.

## Build `workflow_plan`

1. Read selected mode from `router/modes.yml` or `.ai-dev/router/modes.yml`.
2. Build ordered steps:
   - Steps 1..N: mode `steps` from `modes.yml` — status `pending`
   - Mark the first concrete command as `next` (not `active`)
3. Set `current_step_index` to the `order` of the first `next` step.
4. Set `phase` to `awaiting_user` after Phase 2 publication.
5. Set `next_command` and `next_command_label` to that first mode step.
6. Fill metadata:
   - `mode_reason`: why the router chose this mode
   - `artifact_roots`: `specs/{REQUIREMENT_ID}/`, `.harness/sprints/{REQUIREMENT_ID}/`, `.harness/metrics/{REQUIREMENT_ID}/`
   - `approval_gates`: human approval gates from `risk-rules.yml`
   - `next_user_action`: `下一步 / 继续 / next / continue`
7. For each step, add human-readable `label` and expected `outputs` when known from `modes.yml` `default_output`.

## Initial Delivery State

Also populate the top-level dashboard state fields:

- `current_requirement.requirement_id`, `title`, `summary`, `feature_path`
- `mode`
- `requirement_status.clarity`: `plan published`
- `execution.task_progress`: `0/N planned steps`
- `execution.remaining_tasks`: command names still `pending`
- `risk.level`, `risk.approval_required`, `risk.open_risks` from router scoring

Leave build/test/evidence fields as `-` or empty arrays until real execution evidence exists.

## User Message

After writing the files, tell the user:

```text
Dashboard ready: specs/{REQUIREMENT_ID}/dashboard.html
Open it in a browser to see the planned workflow on the right.
Say 下一步 / 继续 / next / continue when you want execution to start.
```

## Later Updates

After each completed internal command:

1. Mark that command `done` in `workflow_plan.steps`.
2. Mark the following command as `next` (not `active`).
3. Set `workflow_plan.phase` to `awaiting_user`.
4. Update delivery fields through `.harness/prompts/dashboard-state-updater.md`.
5. Hand off with `.harness/prompts/step-gate-handoff.md`.
6. Keep `dashboard-state.json` colocated with `dashboard.html` under `specs/{REQUIREMENT_ID}/`.

If `speckit.specify` runs and the dashboard already exists, **do not recreate** the HTML template. Update `dashboard-state.json` only.
