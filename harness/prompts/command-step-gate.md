# Command Step Gate (SDD Workflow)

Apply this protocol when a concrete SpecKit or Harness command finishes and `specs/{REQUIREMENT_ID}/dashboard-state.json` already exists.

## On Completion

1. Finish this command's delivery artifacts (spec, plan, code, reports, etc.).
2. Update `specs/{REQUIREMENT_ID}/dashboard-state.json` using `.harness/prompts/dashboard-state-updater.md`.
3. When this command produces dashboard panel content, update `specs/{REQUIREMENT_ID}/dashboard.html` using `.harness/prompts/dashboard-updater.md`.
4. In `workflow_plan.steps`:
   - mark the command that just finished as `done`
   - mark the following planned command as `next` (not `active`)
   - if no steps remain, set `workflow_plan.phase` to `completed`
   - otherwise set `workflow_plan.phase` to `awaiting_user`
5. Set `workflow_plan.next_command`, `workflow_plan.next_command_label`, and `workflow_plan.next_user_action`.
6. **Stop immediately.** Do not run the next internal command in the same assistant turn.
7. Hand off to the user with `.harness/prompts/step-gate-handoff.md`.

## Skip Step Gate Only When

- the user invoked this command standalone (for example `/speckit.plan`) **and** no `dashboard-state.json` exists for the requirement
- the user explicitly asked to run multiple remaining steps in one turn (for example "一口气跑完")
- this command's own batch sub-mode is active (for example `harness.exec batch`) **and** the user explicitly requested batch execution in that turn

## Path Note

Installed projects store Harness runtime under `.harness/`. Always read prompts and templates from `.harness/prompts/` and `.harness/templates/`, not `harness/`.
