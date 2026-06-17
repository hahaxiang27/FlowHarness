---
name: harness-review
description: å³è peer-reviewer sub-agent ç¬ç«è·?peer reviewï¼äº§å?review æ¥åï¼ä¸è¿?evaluator æµç¨ã?triggers:
  - harness review
  - peer review
  - peer reviewer
  - åè¡è¯å®¡
  - ä»£ç è¯å®¡
  - review æ¥å
---

# Harness Peer Review

**å³è peer-reviewer sub-agent Â· åè§ä¼è®¾è®¡ï¼å·¥ç¨å¸å»ºå¿æºæ¨¡å + ç³»ç»æ?bugï¼ã?*

**ä¸ä¸æç®¡ç?*: ä¿æå½åä¸ä¸æï¼éè¦è¯» diff + CLAUDE.md + specï¼?
## æä»¤

ç¬ç« ad-hoc è·?peer reviewï¼ä¸è¿?evaluator æµç¨ã`/harness.exec` é»è®¤å?L2.5 åç½®åæ ·ç?reviewï¼æ¬å½ä»¤æ¯æå·¥è§¦åçï¼å¦ï¼è¡¥ review æ?task / review å«äººåçä»£ç  / review è·¨å¤ task çæ´æ®µæ¹å¨ï¼ã?
è¯»åä»¥ä¸æä»¶ï¼?1. `.harness/prompts/peer-reviewer.md` â?sub-agent prompt
2. é¡¹ç®æ ?`CLAUDE.md` â?é¡¹ç®å³é
3. `specs/<feature>/spec.md` â?å½å feature specï¼èªå¨ä» task ID æ¨æ­æç¨æ·ä¼ åï¼
4. git diffï¼é»è®?`HEAD~1..HEAD`ï¼å¯åæ°æå® baseï¼?
### è¾å¥åæ°

- Task IDï¼`$ARGUMENTS`ï¼å¿ä¼?Â· ä¾å¦ `T042` æ?`chapter-quiz-gen`ï¼?- Base commitï¼å¯éï¼ï¼`--base <SHA>`ï¼é»è®?`HEAD~1`

### æ§è¡æ­¥éª¤

#### Step 1 Â· è§£æåæ°

- ä»?task ID åæ¥ specï¼æ« `specs/*/tasks.md`ï¼æ¾å°åå«è¯¥ task ID ç?spec
- æ¾ä¸å?spec â?è­¦åä½ä¸é»æ­ï¼review ä»å¯è·ï¼åªæ¯å°äº spec ä¸ä¸æï¼
- è§£æ baseï¼é»è®?`git rev-parse HEAD~1`ï¼å¯è¢?`--base` è¦ç

#### Step 2 Â· æ¶é diff

```bash
git diff <base>..HEAD --name-only
git diff <base>..HEAD
```

å¦æ diff ä¸ºç©º â?æ¥éå¹¶éåºï¼æ²¡æ¹å¨æ²¡ review å¿è¦ï¼ã?
#### Step 3 Â· è°ç¨ peer-reviewer sub-agent

ç?Task å·¥å· spawn sub-agentï¼?- system promptï¼`.harness/prompts/peer-reviewer.md` å¨æ
- åæ°ï¼`task_id` + `base_commit` + diff åå®¹

Sub-agent æå¶ Step 0-5 èµ°å®ï¼åç?`.harness/reviews/<task-id>.md`ï¼è¾å?`PEER_REVIEWER_RESULT`ã?
#### Step 4 Â· ææ¥åè·¯å¾åé¦ç¨æ?
è¾åºæ ¼å¼ï¼?
```
â?Peer Review å®æ Â· Task <ID>

æ¥å: .harness/reviews/<task-id>.md
verdict: PASS | WARN | FAIL
score: X/10
must-fix: N Â· should-fix: M Â· suggestion: K Â· sensor-gap: G

è¦ç¹ï¼?ç»äººç?æ®µæè¦ï¼:
- æ¹äºä»ä¹ï¼[Step 1.1 æè¦]
- ææ¥æå¼ï¼[Step 1.4 å¤?2 æ¡]

å®æ´æ¥åæå¼ .harness/reviews/<task-id>.md
```

### æ³¨æ

- **åªè¯»å½ä»¤**ï¼ä¸ä¿®æ¹ä»»ä½ä»£ç ãä¸ä¿®æ¹ specãä¸ä¿®æ¹ task ç¶æãä»äº§åº review æ¥åã?- **æ¥åå­æ¡£**ï¼`.harness/reviews/<task-id>.md` æä¹åä¿å­ãè¿ä¸æä»¶æ¯å·¥ç¨å¸æªæ¥ææ¥é®é¢çå¥å£ââå°¤å¶é£æ®?ææ¥æå¼"æ?AI åå®ä»£ç  N ä¸ªæåçå¯¼èªå°å¾ã?- ä¸?`/harness.exec` åç½® review çåºå«ï¼
  - `/harness.exec` å?L2.5 èªå¨è·?Â· æ åæµç¨ Â· evaluator æ¶è´¹ verdict
  - `/harness.review` æå·¥è§¦å Â· ad-hoc Â· ä¸å½±å?evaluator
  - ä¸¤èé½è°åä¸ä¸?peer-reviewer.mdï¼è¾åºæ ¼å¼ä¸è?- å³èææ¡£ï¼?  - peer-reviewerï¼`.harness/prompts/peer-reviewer.md`
  - L2.5 éæï¼`.harness/prompts/evaluator.md` Â§ 2.5

## SDD Step Gate

When specs/{REQUIREMENT_ID}/dashboard-state.json exists (SDD workflow active), after this command completes follow .harness/prompts/command-step-gate.md:

1. Update dashboard-state.json and dashboard.html when applicable.
2. Mark this command done, next step next, workflow_plan.phase = awaiting_user.
3. **Stop immediately** - do not chain the next internal command in the same turn.
4. Hand off with .harness/prompts/step-gate-handoff.md.

Skip only for standalone invocation without dashboard state, or when the user explicitly asks to batch remaining steps.

