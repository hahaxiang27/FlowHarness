# FlowHarness SDD 贡献指南

[English](CONTRIBUTING.md)

感谢关注 **FlowHarness SDD**。为保护开发者与著作权人权益，请在提 Issue 或 PR 前阅读本文。

## 法律与著作权

1. **许可协议。** 提交贡献即表示你同意将贡献内容按 [MIT License](LICENSE) 授权，且你有权提交该内容。

2. **著作权与 NOTICE。** 不得擅自删除或修改版权申明、[NOTICE](NOTICE) 文件，以及模板中的托管标记（如 `AGENTS.md` 里的 `speckit-harness-toolkit:managed` 区块），除非维护者明确批准。

3. **商标。** 未经项目维护者书面许可，不得在 Fork 或衍生发行版中使用「FlowHarness SDD」或易混淆名称进行宣传或背书。

4. **大型变更。** 小修复无需 CLA；涉及架构或核心编排逻辑的重大变更，维护者可能要求额外确认授权意图。

## 欢迎的贡献

- 可复现的 Bug 修复
- 中英文文档改进
- `tests/validate-*.sh` 测试补充
- 与 Router / Step Gate / Dashboard 目标一致的增强

## 需先讨论再动手

- 修改默认 Router 模式或 Step Gate 策略
- 绕过或删除版权 / NOTICE 要求
- 更换开源许可证
- 大规模重构 `install.sh`、`router/`、`AGENTS.template.md`

请先开 Issue 说明方案。

## 本地验证

```bash
git clone https://github.com/hahaxiang27/FlowHarness.git
cd FlowHarness
bash tests/validate-install.sh
bash tests/validate-agents-merge.sh
bash tests/validate-router-config.sh
```

行为变更时请同步更新或新增验证脚本。

## PR 检查清单

- [ ] 说明变更原因（why）
- [ ] 用户可见行为变更时更新 README（中/英）
- [ ] 通过相关 `tests/validate-*.sh`
- [ ] 不提交密钥、`.claude/settings.local.json`、`.tmp-*` 临时目录
- [ ] 保留 NOTICE / LICENSE / 版权头

## 行为准则

见 [CODE_OF_CONDUCT.md](CODE_OF_CONDUCT.md)。

## 安全报告

见 [SECURITY.md](SECURITY.md)，请勿在公开 Issue 中披露可利用漏洞细节。

## 联系

许可或商标问题请通过 Issue（标签 `legal`）联系项目维护者。
