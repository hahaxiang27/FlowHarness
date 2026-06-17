# Agent Operating Guide

This project uses AI Dev Environment with direct SpecKit + Harness orchestration.

<!-- speckit-harness-toolkit:managed -->
## CRITICAL: Routing Gate — MUST Execute Before ANY Skill or Brainstorm

**This section overrides ALL other workflows, skills, and plugins. No exceptions.**

When the user describes a new feature or requirement (including DHSOAH:NNN, DPSHCT:NNN, or any natural-language requirement):

1. **Router first, skills later.** Read `.ai-dev/router/` (modes.yml, routing-rules.yml, risk-rules.yml, bypass-rules.yml) and score the requirement against risk keywords to determine the correct mode. Do this BEFORE invoking brainstorming, TDD, or any other skill.

2. **Publish mode selection to user.** Show:
   - Selected mode (direct / doc / fast / speclite / full / debug)
   - Risk score breakdown (which keywords triggered, individual scores, total)
   - Ordered command list for this mode (from modes.yml steps)
   - Risk level (low / medium / high / critical) and approval gates
   - Artifact root paths (specs/{ID}/, .harness/sprints/{ID}/, .harness/metrics/{ID}/)

3. **Initialize dashboard immediately.** Copy `.harness/templates/dashboard.html` to `specs/{REQUIREMENT_ID}/dashboard.html` and create `specs/{REQUIREMENT_ID}/dashboard-state.json` following `.harness/prompts/dashboard-plan-init.md`. This must happen before the first SpecKit or Harness command.

4. **Stop and wait for user confirmation.** Do NOT chain into any `speckit.*` or `harness.*` command. The user must explicitly confirm the mode and plan before execution begins.

5. **One step per turn after confirmation.** Each user "继续" / "next" / "continue" runs exactly ONE command, updates dashboard-state.json, then stops.

**Why this gate exists:** Without it, other skills (brainstorming, TDD) will capture the flow and skip routing, risk assessment, and dashboard initialization. They do not know about `.ai-dev/router/`. This gate ensures the toolkit always runs first.

## First Step After Installation

Before development work starts, run `speckit.constitution` first.

- If `.specify/memory/constitution.md` is missing, empty, or still mostly template placeholders, execute `speckit.constitution`, report the updated constitution path, then stop.
- Do not begin requirement development until the constitution baseline exists.
- After constitution is ready, natural-language requirements are the primary interface.

## User Experience

Users do not need to type slash commands for normal development. Treat natural-language requests as the primary interface.

- When the user describes a new requirement, read `.ai-dev/router/` and select one mode: `direct`, `doc`, `fast`, `speclite`, `full`, or `debug`.
- If Router selects **`direct`**, bypass SpecKit/Harness immediately and edit code with `.harness/prompts/direct-implement.md`. Do not create specs, dashboard, or step-gate pauses.
- For every non-direct mode, show the selected mode, reason, risk level, artifact roots, and ordered `speckit.*` / `harness.*` command flow before doing implementation work.
- Initialize `specs/{REQUIREMENT_ID}/dashboard.html` and `dashboard-state.json` with `.harness/prompts/dashboard-plan-init.md` before the first concrete command runs.
- When the user says "next", "next step", "continue", "下一步", or "继续", execute exactly one command marked `next` in `dashboard-state.json`, then stop again.
- When the user asks for progress, read `specs/{REQUIREMENT_ID}/dashboard-state.json` and summarize the latest completed command, next command, risks, and dashboard path.

## Step Gate Policy

**One concrete command per user turn** is mandatory by default.

1. The first requirement response only publishes mode + command flow + dashboard initialization. It must not chain into `speckit.*` or `harness.*` in the same response.
2. Each continuation runs exactly one `speckit.*` or `harness.*` command, then stops and tells the user the next command name.
3. After every concrete command, update `specs/{REQUIREMENT_ID}/dashboard-state.json` and hand off with `.harness/prompts/step-gate-handoff.md`.
4. Low or medium risk never grants auto-continue. Wait for `继续` / `next` / `continue` every time.
5. Batch execution is allowed only when the user explicitly asks to run multiple remaining steps in one turn.

## First Response Requirement

At the start of a new requirement, show the user the planned internal command flow before doing the work.

The flow must include:

1. Selected mode: `doc`, `fast`, `speclite`, `full`, or `debug`
2. Why that mode was selected
3. The concrete commands that will run, such as:
   - `speckit.specify`
   - `speckit.clarify`
   - `speckit.checklist`
   - `speckit.plan`
   - `speckit.tasks`
   - `speckit.analyze`
   - `harness.scope`
   - `harness.start`
   - `harness.exec`
   - `harness.eval`
   - `harness.fix`
   - `harness.checkpoint`
   - `harness.metrics`
4. Approval gates, if the work is high or critical risk
5. Dashboard paths under `specs/{REQUIREMENT_ID}/`
6. The next visible action for the user

## Router

Read `.ai-dev/router/` before selecting a workflow. If router files are absent, fall back to `router/` in the toolkit. Read `.ai-dev/context/requirement-artifact-layout.md` before creating requirement artifacts.

## Requirement Artifact Layout

Before creating or updating delivery artifacts, resolve the user-defined requirement id from the request, current workflow context, or existing SpecKit/Harness state.

- Preserve the chosen id as the directory name.
- For a requirement id such as `DPSHCT-2983-xxx`, write specs to `specs/DPSHCT-2983-xxx/`.
- Write sprint plans and progress to `.harness/sprints/DPSHCT-2983-xxx/`.
- Write metrics to `.harness/metrics/DPSHCT-2983-xxx/`.
- Show these artifact roots in the first planned internal command flow.
- Do not create separate numbered folders for the same requirement.
- During initial planning, initialize `specs/{REQUIREMENT_ID}/dashboard.html` and `dashboard-state.json` using `.harness/prompts/dashboard-plan-init.md` so the user can open the dashboard and see planned steps before execution starts.

## Memory

Read `.ai-dev/context/` before implementation when the task touches known patterns, team rules, review feedback, or prior mistakes.

After `harness.metrics`, update `.ai-dev/context/` directly when the work reveals reusable patterns, mistakes, or review feedback.

## Safety

Do not create or rely on `.claude/settings.local.json` as a distributed artifact. Use `.claude/settings.template.json` as the safe baseline.
<!-- /speckit-harness-toolkit:managed -->
