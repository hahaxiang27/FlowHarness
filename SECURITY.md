# Security Policy

## Supported Versions

| Version | Supported |
|---------|-----------|
| main    | yes       |

## Reporting a Vulnerability

**Do not** open a public GitHub issue for security vulnerabilities.

Please report security issues privately to the repository maintainers
(AsiaInfo, Inc.) through your organization's security channel or by
opening a **private** security advisory on GitHub if enabled.

Include:

- Description of the vulnerability
- Steps to reproduce
- Impact assessment
- Suggested fix (if any)

We aim to acknowledge reports within 5 business days.

## Scope Notes

This toolkit installs agent commands, prompts, and configuration into
**target projects**. Review `install.sh` output paths before running in
production repositories.

Never commit:

- `.claude/settings.local.json`
- API keys, tokens, or credentials in templates or examples
