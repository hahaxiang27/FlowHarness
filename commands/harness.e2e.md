---
name: harness-e2e
description: ä¸ºå½åç¨æ·æäºæ Sprint ç¼åå¹¶è¿è¡?`[E2E_TOOL]` E2E æµè¯ã?triggers:
  - harness e2e
  - e2e visual
  - end to end test
  - E2E æµè¯
  - äº¤äºéªè¯
  - ç¨æ·æäºéªæ¶
---

# Harness `[E2E_TOOL]` E2E æµè¯

**ä¸ä¸æç®¡ç?*: ð æ¸ç©ºä¸ä¸æ?â?ä½¿ç¨å­ä»£çæ§è¡ï¼ç¡®ä¿å¹²åç¯å¢

## æä»¤

ä¸ºå½åå®æçç¨æ·æäºç¼åå¹¶è¿è¡?`[E2E_TOOL]` E2E æµè¯ã?
### è¾å¥åæ°

$ARGUMENTS â?ç¨æ·æäºç¼å·ï¼å¦ "US1"ï¼æ "sprint" è¡¨ç¤ºå½å Sprint çææ?E2E

### æ§è¡æ­¥éª¤

ä½¿ç¨ Agent å·¥å·å¯å¨å­ä»£çï¼ä¼ å¥ä»¥ä¸ä»»å¡ï¼?
```
ä½ æ¯ Harness E2E æµè¯æ§è¡å¨ã?
1. è¯»å `specs/[FEATURE_ID]/spec.md`ï¼æ¾å?{USç¼å·} çå¨é¨éªæ¶åºæ?2. è¯»å `.harness/prompts/evaluator.md` ç?Level 3 æ¨¡æ¿ï¼äºè§?E2E ç¼åè§å
3. è¯»å `.harness/prompts/generator.md` ç?E2E æ¨¡æ¿ï¼äºè§?`[E2E_TOOL]` æµè¯çæè§è

æ§è¡ï¼?a. ä¸ºæ¯ä¸ªéªæ¶åºæ¯ç Given/When/Then ç¼åä¸ä¸?test case
b. ä½¿ç¨ Page Object æ¨¡å¼ç»ç»é¡µé¢äº¤äº
c. åå¥ `[TEST_ROOT]/e2e/{story-name}[TEST_FILE_SUFFIX]`
d. è¿è¡ `[E2E_COMMAND]`
e. å¦æå¤±è´¥ï¼ä¿®æ­£æµè¯ä»£ç åéè·
f. ç¡®è®¤éè¿åéè·?æ¬¡éªè¯ç¨³å®æ?g. å³é®æ­¥éª¤æªå¾ä¿å­å?`[E2E_SCREENSHOT_DIR]`

æ¥åï¼?- æµè¯ç¨ä¾æ»æ°ãéè¿æ°ãå¤±è´¥æ°
- å¤±è´¥ç¨ä¾çè¯¦æåæªå¾è·¯å¾
- ç¨³å®æ§ç»æï¼3æ¬¡éè·æ¯å¦å¨é¨éè¿ï¼?- æ´æ° sprint-*-progress.md ä¸­ç E2E éªè¯ç¶æ?```

### æ³¨æ
- E2E æµè¯éè¦ç¸å³åºç¨ãç¨æ·çé¢åä¾èµæå¡é½å¨è¿è¡
- å¦æåºç¨æç¨æ·çé¢æªå¯å¨ï¼åæç¤ºç¨æ·æ§è¡ `[APP_START_COMMAND]` / `[UI_START_COMMAND]`
- é¦æ¬¡è¿è¡å¯è½éè¦å®è£æåå§å?`[E2E_TOOL]` çè¿è¡æ¶èµæº

## SDD Step Gate

When specs/{REQUIREMENT_ID}/dashboard-state.json exists (SDD workflow active), after this command completes follow .harness/prompts/command-step-gate.md:

1. Update dashboard-state.json and dashboard.html when applicable.
2. Mark this command done, next step next, workflow_plan.phase = awaiting_user.
3. **Stop immediately** - do not chain the next internal command in the same turn.
4. Hand off with .harness/prompts/step-gate-handoff.md.

Skip only for standalone invocation without dashboard state, or when the user explicitly asks to batch remaining steps.
