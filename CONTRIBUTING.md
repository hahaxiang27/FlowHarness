# Contributing to FlowGate SDD

[中文贡献指南](CONTRIBUTING.zh-CN.md)

Thank you for your interest in FlowGate SDD. To protect contributors and
copyright holders, please read this document before opening issues or pull requests.

## Legal Terms

1. **License.** By contributing, you agree that your contributions are licensed
   under the [MIT License](LICENSE) and that you have the legal right to submit them.

2. **Copyright & NOTICE.** Do not remove or alter copyright notices, the
   [NOTICE](NOTICE) file, or managed-block markers in toolkit templates unless
   explicitly approved by maintainers.

3. **Trademarks.** Do not use "FlowGate SDD", "流门 SDD", or confusingly similar
   names in forked or derivative distributions without written permission from
   AsiaInfo, Inc.

4. **No CLA required for small fixes.** For substantial features or architectural
   changes, maintainers may ask for additional confirmation of licensing intent.

## What We Accept

- Bug fixes with reproducible steps
- Documentation improvements (Chinese or English)
- Test coverage for `tests/validate-*.sh`
- Router / Step Gate / Dashboard improvements aligned with project goals

## What Requires Discussion First

- Changing default Router modes or Step Gate policy
- Removing or bypassing copyright / NOTICE requirements
- Replacing MIT with another license
- Large refactors touching `install.sh`, `router/`, or `AGENTS.template.md`

Open an issue before starting work on these topics.

## Development Workflow

```bash
git clone <repo-url>
cd speckit-harness-flowgate
bash tests/validate-install.sh
bash tests/validate-agents-merge.sh
bash tests/validate-router-config.sh
```

Add or update validation scripts when behavior changes.

## Pull Request Checklist

- [ ] Describes **why** the change is needed
- [ ] Updates Chinese and/or English README if user-facing behavior changes
- [ ] Passes relevant `tests/validate-*.sh` scripts
- [ ] Does not commit secrets, `.claude/settings.local.json`, or `.tmp-*` artifacts
- [ ] Preserves NOTICE / LICENSE / copyright headers

## Code of Conduct

Be respectful and constructive. See [CODE_OF_CONDUCT.md](CODE_OF_CONDUCT.md).

## Security

Report vulnerabilities privately. See [SECURITY.md](SECURITY.md).

## Contact

For licensing or trademark questions, contact the repository maintainers
(AsiaInfo, Inc.) through the issue tracker with the `legal` label or via
your organization's internal channel.
