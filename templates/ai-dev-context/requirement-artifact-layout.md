# Requirement Artifact Layout

All generated delivery artifacts MUST be grouped by the user-defined requirement id.

## Requirement Id

- Resolve the id from the user request, current workflow context, or existing SpecKit/Harness state.
- Preserve the chosen id as the directory name.
- `DPSHCT-2983-xxx` is a valid example, but the toolkit must not force a single id pattern.
- Do not create separate numbered feature folders for the same requirement.

## Required Paths

For requirement id `DPSHCT-2983-xxx`, write artifacts under:

```text
specs/DPSHCT-2983-xxx/
.harness/sprints/DPSHCT-2983-xxx/
.harness/metrics/DPSHCT-2983-xxx/
```

Expected files:

```text
specs/DPSHCT-2983-xxx/spec.md
specs/DPSHCT-2983-xxx/plan.md
specs/DPSHCT-2983-xxx/tasks.md
specs/DPSHCT-2983-xxx/dashboard.html
specs/DPSHCT-2983-xxx/dashboard-state.json
.harness/sprints/DPSHCT-2983-xxx/sprint-1.md
.harness/sprints/DPSHCT-2983-xxx/sprint-1-progress.md
.harness/metrics/DPSHCT-2983-xxx/sprint-1.json
```

Dashboard initialization happens during initial requirement planning, before the first SpecKit or Harness command. The right-side **Planned Workflow** panel comes from `dashboard-state.json` → `workflow_plan.steps`.
