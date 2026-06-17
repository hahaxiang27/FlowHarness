#!/usr/bin/env bash
# SpecKit + Harness Toolkit 一键安装脚本
#
# 用法:
#   cd /path/to/your/project
#   bash /path/to/speckit-harness-toolkit/install.sh [选项]
#
# 选项:
#   --agent <type>  指定目标 AI 智能体: claude (默认)、opencode、codex、cursor、all
#   --force         覆盖目标项目中已存在的同名文件（AGENTS.md 亦整文件覆盖；默认: 跳过或合并）
#   --no-constitution  不铺设 .specify/memory/constitution.md（你自己准备）
#   --help          显示帮助

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TARGET_DIR="$(pwd)"

FORCE=false
SKIP_CONSTITUTION=false
AGENT="claude"
WITH_SUPERPOWERS=false
WITH_ROUTER=true
WITH_DEV_ENTRY=true
SAFE_SETTINGS=true

while [[ $# -gt 0 ]]; do
    case "$1" in
        --agent)
            if [[ -z "$2" || "$2" == --* ]]; then
                echo "ERROR: --agent requires a value: claude, opencode, codex, cursor, or all" >&2
                exit 1
            fi
            case "$2" in
                claude|opencode|codex|cursor|all)
                    AGENT="$2"
                    ;;
                *)
                    echo "ERROR: Unknown agent type '$2'. Valid values: claude, opencode, codex, cursor, all" >&2
                    exit 1
                    ;;
            esac
            shift 2
            ;;
        --force)
            FORCE=true
            shift
            ;;
        --no-constitution)
            SKIP_CONSTITUTION=true
            shift
            ;;
        --with-superpowers)
            WITH_SUPERPOWERS=true
            shift
            ;;
        --with-router)
            WITH_ROUTER=true
            shift
            ;;
        --no-router)
            WITH_ROUTER=false
            shift
            ;;
        --with-agent-guide)
            WITH_DEV_ENTRY=true
            shift
            ;;
        --no-agent-guide)
            WITH_DEV_ENTRY=false
            shift
            ;;
        --safe-settings)
            SAFE_SETTINGS=true
            shift
            ;;
        --no-safe-settings)
            SAFE_SETTINGS=false
            shift
            ;;
        --help|-h)
            cat <<'EOF'
SpecKit + Harness Toolkit 一键安装脚本

用法:
  cd /path/to/your/project
  bash /path/to/speckit-harness-toolkit/install.sh [选项]

选项:
  --agent <type>    目标 AI 智能体: claude (默认)、opencode、codex、cursor、all
  --force           覆盖目标项目中已存在的同名文件（AGENTS.md 亦整文件覆盖；默认: 跳过或合并）
  --no-constitution 不铺设 .specify/memory/constitution.md
  --with-superpowers 铺设可选融合层(Superpowers 集成 · 仅 claude/all · 实验性)
  --with-router     铺设 .ai-dev/router/（默认开启）
  --no-router       跳过 router 配置
  --with-agent-guide 铺设 AGENTS.md 与 AI Dev context（默认开启）
  --no-agent-guide   跳过 AGENTS.md 与 AI Dev context
  --safe-settings   铺设 .claude/settings.template.json（默认开启）
  --no-safe-settings 跳过安全设置模板
  --help, -h        显示本帮助

示例:
  bash install.sh                             # 安装到 claude
  bash install.sh --agent opencode            # 安装到 opencode
  bash install.sh --agent codex               # 安装到 Codex skills
  bash install.sh --agent codex --force       # 强制覆盖 Codex skills
  bash install.sh --agent cursor               # 安装 Cursor rules + AGENTS.md
  bash install.sh --agent all                 # 同时安装到 claude、opencode、Codex skills 和 Cursor
  bash install.sh --agent opencode --force    # 强制覆盖 opencode 已存在文件
EOF
            exit 0
            ;;
        *)
            echo "Unknown option: $1" >&2
            exit 1
            ;;
    esac
done

# Determine agent command directories
declare -a COMMAND_TARGETS=()
case "$AGENT" in
    claude)
        COMMAND_TARGETS=("$TARGET_DIR/.claude/commands")
        ;;
    opencode)
        COMMAND_TARGETS=("$TARGET_DIR/.opencode/command")
        ;;
    codex)
        COMMAND_TARGETS=()
        ;;
    cursor)
        COMMAND_TARGETS=()
        ;;
    all)
        COMMAND_TARGETS=("$TARGET_DIR/.claude/commands" "$TARGET_DIR/.opencode/command")
        ;;
esac

# Agent display names
agent_display() {
    case "$AGENT" in
        claude)   echo "Claude Code" ;;
        opencode) echo "opencode" ;;
        codex)    echo "Codex skills" ;;
        cursor)   echo "Cursor rules" ;;
        all)      echo "Claude Code + opencode + Codex skills + Cursor" ;;
    esac
}

# Agent-specific run command hint
agent_run_hint() {
    case "$AGENT" in
        claude)   echo "先运行 /speckit.constitution，然后用自然语言描述需求" ;;
        opencode) echo "先运行 /speckit.constitution，然后用自然语言描述需求" ;;
        codex)    echo "重启 Codex 后先使用 speckit-constitution skill，然后用自然语言描述需求" ;;
        cursor)   echo "在 Cursor 中用自然语言描述需求，或引用 AGENTS.md / .cursor/rules" ;;
        all)      echo "先运行 speckit.constitution，然后用自然语言描述需求" ;;
    esac
}

echo "=========================================="
echo "SpecKit + Harness Toolkit 安装"
echo "=========================================="
echo "源: $SCRIPT_DIR"
echo "目标: $TARGET_DIR"
echo ""

# copy_with_check <src> <dst>
copy_with_check() {
    local src="$1"
    local dst="$2"
    if [ -e "$dst" ] && [ "$FORCE" != "true" ]; then
        echo "  [跳过] $dst (已存在，--force 可覆盖)"
        return 0
    fi
    mkdir -p "$(dirname "$dst")"
    cp -r "$src" "$dst"
    echo "  [铺设] $dst"
}

# install_agents_guide
# Fresh install -> copy template.
# Existing AGENTS.md -> merge toolkit managed block, preserve project content.
# --force -> full overwrite with template.
install_agents_guide() {
    local template="$SCRIPT_DIR/templates/AGENTS.template.md"
    local dst="$TARGET_DIR/AGENTS.md"
    local merge_script="$SCRIPT_DIR/scripts/merge-agents-guide.sh"
    local action

    if [ ! -f "$merge_script" ]; then
        echo "ERROR: missing merge script: $merge_script" >&2
        exit 1
    fi

    if [ "$FORCE" = "true" ]; then
        action="$(bash "$merge_script" --force "$template" "$dst")"
        echo "  [覆盖] $dst"
        return 0
    fi

    action="$(bash "$merge_script" "$template" "$dst")"
    case "$action" in
        install)
            echo "  [铺设] $dst"
            ;;
        merge)
            echo "  [合并] $dst (保留项目自定义内容，注入 toolkit 编排段落)"
            ;;
        refresh)
            echo "  [更新] $dst (刷新 toolkit 编排段落，保留项目自定义内容)"
            ;;
        *)
            echo "ERROR: unexpected merge action: $action" >&2
            exit 1
            ;;
    esac
}

command_to_skill_name() {
    local fname="$1"
    local base="${fname%.md}"
    echo "${base//./-}"
}

write_skill_file() {
    local src="$1"
    local skill_name="$2"
    local dst="$3"
    local title

    if [ "$(sed -n '1p' "$src")" = "---" ]; then
        if awk '
            /^---$/ { count++; if (count == 2) exit }
            count == 1 && /^name:[[:space:]]*/ { found = 1 }
            END { exit found ? 0 : 1 }
        ' "$src"; then
            cp "$src" "$dst"
        else
            awk -v skill_name="$skill_name" '
                NR == 1 && $0 == "---" {
                    print
                    print "name: " skill_name
                    next
                }
                { print }
            ' "$src" > "$dst"
        fi
    else
        title="$(sed -n '1s/^# *//p' "$src")"
        {
            echo "---"
            echo "name: $skill_name"
            echo "description: $title"
            echo "---"
            echo ""
            cat "$src"
        } > "$dst"
    fi
}

copy_skill_with_check() {
    local src="$1"
    local skill_dir="$2"
    local dst="$skill_dir/SKILL.md"
    local skill_name
    skill_name="$(basename "$skill_dir")"
    if [ -e "$skill_dir" ] && [ "$FORCE" != "true" ]; then
        echo "  [跳过] $skill_dir (已存在，--force 可覆盖)"
        return 0
    fi
    if [ -e "$skill_dir" ] && [ "$FORCE" = "true" ]; then
        rm -rf "$skill_dir"
    fi
    mkdir -p "$skill_dir"
    write_skill_file "$src" "$skill_name" "$dst"
    echo "  [铺设] $dst"
}

cleanup_legacy_wrappers() {
    echo "▶ 清理旧版高层 wrapper 命令"
    if [ "$AGENT" = "claude" ] || [ "$AGENT" = "all" ]; then
        rm -f "$TARGET_DIR"/.claude/commands/sdd.*.md "$TARGET_DIR"/.claude/commands/dev.*.md 2>/dev/null || true
    fi
    if [ "$AGENT" = "opencode" ] || [ "$AGENT" = "all" ]; then
        rm -f "$TARGET_DIR"/.opencode/command/sdd.*.md "$TARGET_DIR"/.opencode/command/dev.*.md 2>/dev/null || true
    fi
    if [ "$AGENT" = "codex" ] || [ "$AGENT" = "all" ]; then
        rm -rf "$TARGET_DIR"/.codex/skills/sdd-* "$TARGET_DIR"/.codex/skills/dev-* 2>/dev/null || true
    fi
    echo ""
}

cleanup_legacy_wrappers

# 1. Slash commands → agent-specific dir
COMMAND_COUNT=0
for f in "$SCRIPT_DIR"/commands/*.md; do
    fname="$(basename "$f")"
    if [[ "$fname" == sdd.* ]]; then
        continue
    fi
    COMMAND_COUNT=$((COMMAND_COUNT + 1))
done

if [ "${#COMMAND_TARGETS[@]}" -gt 0 ]; then
    echo "▶ 铺设 slash commands ($COMMAND_COUNT 个) → $(agent_display)"
    for target_dir in "${COMMAND_TARGETS[@]}"; do
        mkdir -p "$target_dir"
        for f in "$SCRIPT_DIR"/commands/*.md; do
            fname="$(basename "$f")"
            if [[ "$fname" == sdd.* ]]; then
                continue
            fi
            copy_with_check "$f" "$target_dir/$fname"
        done
    done
    echo ""
fi

# 1b. Codex skills → project .codex/skills/
if [ "$AGENT" = "codex" ] || [ "$AGENT" = "all" ]; then
    CODEX_SKILLS_DIR="$TARGET_DIR/.codex/skills"
    CODEX_SKILL_COUNT=0
    if [ -d "$SCRIPT_DIR/codex-skills" ]; then
        for skill_dir in "$SCRIPT_DIR"/codex-skills/*/; do
            [ -f "$skill_dir/SKILL.md" ] || continue
            CODEX_SKILL_COUNT=$((CODEX_SKILL_COUNT + 1))
        done
    fi
    for f in "$SCRIPT_DIR"/commands/*.md; do
        fname="$(basename "$f")"
        if [[ "$fname" == sdd.* ]]; then
            continue
        fi
        CODEX_SKILL_COUNT=$((CODEX_SKILL_COUNT + 1))
    done
    echo "▶ 铺设 Codex skills ($CODEX_SKILL_COUNT 个) → $CODEX_SKILLS_DIR"
    if [ -d "$SCRIPT_DIR/codex-skills" ]; then
        for skill_dir in "$SCRIPT_DIR"/codex-skills/*/; do
            [ -f "$skill_dir/SKILL.md" ] || continue
            skill_name="$(basename "$skill_dir")"
            copy_skill_with_check "$skill_dir/SKILL.md" "$CODEX_SKILLS_DIR/$skill_name"
        done
    fi
    for f in "$SCRIPT_DIR"/commands/*.md; do
        fname="$(basename "$f")"
        if [[ "$fname" == sdd.* ]]; then
            continue
        fi
        skill_name="$(command_to_skill_name "$fname")"
        copy_skill_with_check "$f" "$CODEX_SKILLS_DIR/$skill_name"
    done
    echo ""
fi

# 1c. AI Dev router + context + entry guide
if [ "$WITH_ROUTER" = "true" ]; then
    echo "▶ 铺设 AI Dev router → .ai-dev/router/"
    mkdir -p "$TARGET_DIR/.ai-dev/router"
    for f in "$SCRIPT_DIR"/router/*.yml; do
        fname="$(basename "$f")"
        copy_with_check "$f" "$TARGET_DIR/.ai-dev/router/$fname"
    done
    echo ""
fi

if [ "$WITH_DEV_ENTRY" = "true" ]; then
    echo "▶ 铺设 AI Dev context → .ai-dev/context/"
    mkdir -p "$TARGET_DIR/.ai-dev/context"
    for f in "$SCRIPT_DIR"/templates/ai-dev-context/*.md; do
        fname="$(basename "$f")"
        copy_with_check "$f" "$TARGET_DIR/.ai-dev/context/$fname"
    done
    echo ""
    echo "Installing agent operating guide -> AGENTS.md"
    install_agents_guide
    echo ""
fi

# 1d. Cursor rules (cursor agent, or all)
if [ "$AGENT" = "cursor" ] || [ "$AGENT" = "all" ]; then
    echo "▶ 铺设 Cursor orchestration rules → .cursor/rules/"
    mkdir -p "$TARGET_DIR/.cursor/rules"
    for f in "$SCRIPT_DIR"/templates/cursor-rules/*.mdc; do
        fname="$(basename "$f")"
        copy_with_check "$f" "$TARGET_DIR/.cursor/rules/$fname"
    done
    if [ "$WITH_DEV_ENTRY" != "true" ] && { [ "$AGENT" = "cursor" ]; }; then
        echo "Installing agent operating guide -> AGENTS.md"
        install_agents_guide
    fi
    echo ""
fi

if [ "$SAFE_SETTINGS" = "true" ] && { [ "$AGENT" = "claude" ] || [ "$AGENT" = "all" ]; }; then
    echo "▶ 铺设 safe settings template → .claude/settings.template.json"
    mkdir -p "$TARGET_DIR/.claude"
    copy_with_check "$SCRIPT_DIR/templates/settings.safe.template.json" "$TARGET_DIR/.claude/settings.template.json"
    echo ""
fi

# 2. SpecKit 运行时 → .specify/
echo "▶ 铺设 SpecKit 运行时 → .specify/"
mkdir -p "$TARGET_DIR/.specify/scripts/bash"
mkdir -p "$TARGET_DIR/.specify/templates"
mkdir -p "$TARGET_DIR/.specify/memory"

for f in "$SCRIPT_DIR"/specify/scripts/bash/*.sh; do
    fname="$(basename "$f")"
    copy_with_check "$f" "$TARGET_DIR/.specify/scripts/bash/$fname"
    chmod +x "$TARGET_DIR/.specify/scripts/bash/$fname" 2>/dev/null || true
done

for f in "$SCRIPT_DIR"/specify/templates/*.md; do
    fname="$(basename "$f")"
    copy_with_check "$f" "$TARGET_DIR/.specify/templates/$fname"
done

# Set init-options.json with correct AI agent
if [ ! -f "$TARGET_DIR/.specify/init-options.json" ] || [ "$FORCE" = "true" ]; then
    AI_AGENT="$AGENT"
    AI_SKILLS=false
    if [ "$AGENT" = "all" ]; then
        AI_AGENT="claude"  # default for all is claude
    fi
    if [ "$AGENT" = "codex" ] || [ "$AGENT" = "all" ]; then
        AI_SKILLS=true
    fi
    # Create init-options.json with the correct AI agent
    cat > "$TARGET_DIR/.specify/init-options.json" <<JSONEOF
{
  "ai": "$AI_AGENT",
  "ai_commands_dir": null,
  "ai_skills": $AI_SKILLS,
  "branch_numbering": "sequential",
  "here": true,
  "offline": true,
  "preset": null,
  "script": "sh",
  "speckit_version": "0.4.3"
}
JSONEOF
    echo "  [铺设] $TARGET_DIR/.specify/init-options.json (agent: $AI_AGENT)"
else
    echo "  [跳过] $TARGET_DIR/.specify/init-options.json (已存在)"
fi

# Constitution: 默认放一份 Harness 增强版核心原则骨架做起点
if [ "$SKIP_CONSTITUTION" != "true" ]; then
    if [ ! -f "$TARGET_DIR/.specify/memory/constitution.md" ] || [ "$FORCE" = "true" ]; then
        cp "$SCRIPT_DIR/templates/constitution.harness-enhanced.template.md" \
           "$TARGET_DIR/.specify/memory/constitution.md"
        echo "  [铺设] $TARGET_DIR/.specify/memory/constitution.md (Harness 增强版核心原则骨架)"
        echo "         → 后续用 /speckit.constitution 命令填充，或参考 examples/"
    else
        echo "  [跳过] $TARGET_DIR/.specify/memory/constitution.md (已存在)"
    fi
fi
echo ""

# 3. Harness 运行时 → .harness/
echo "▶ 铺设 Harness 运行时 → .harness/"
mkdir -p "$TARGET_DIR/.harness/prompts"

for f in "$SCRIPT_DIR"/harness/prompts/*.md; do
    fname="$(basename "$f")"
    copy_with_check "$f" "$TARGET_DIR/.harness/prompts/$fname"
done

mkdir -p "$TARGET_DIR/.harness/templates"
for f in "$SCRIPT_DIR"/harness/templates/*; do
    [ -e "$f" ] || continue
    fname="$(basename "$f")"
    copy_with_check "$f" "$TARGET_DIR/.harness/templates/$fname"
done

if [ ! -f "$TARGET_DIR/.harness/README.md" ] || [ "$FORCE" = "true" ]; then
    cp "$SCRIPT_DIR/harness/README.original.md" "$TARGET_DIR/.harness/README.md"
    echo "  [铺设] $TARGET_DIR/.harness/README.md (Harness 框架深度说明)"
else
    echo "  [跳过] $TARGET_DIR/.harness/README.md (已存在)"
fi
echo ""

# 4. 建 sprints/ 、 metrics/ 、 scope/ 占位目录（供 Harness 运行时写入）
mkdir -p "$TARGET_DIR/.harness/sprints"
mkdir -p "$TARGET_DIR/.harness/metrics"
mkdir -p "$TARGET_DIR/.harness/scope"
mkdir -p "$TARGET_DIR/specs"

# 5. scope.yaml 模板 → .harness/scope/_template.yaml（关联 Constitution 原则 XI · 模块边界纪律）
copy_with_check "$SCRIPT_DIR/harness/scope-template.yaml" "$TARGET_DIR/.harness/scope/_template.yaml"
echo "         → 每 Sprint 复制一份为 sprint-<N>.yaml · 由 boundary-reviewer 消费"
echo ""

# 6. (可选) 融合层:Superpowers 集成(仅 Claude · 实验性 · 增量未证)
if [ "$WITH_SUPERPOWERS" = "true" ]; then
    echo "▶ 融合层:Superpowers 集成(实验性 · 仅 Claude)"
    if [ "$AGENT" != "claude" ] && [ "$AGENT" != "all" ]; then
        echo "  [跳过] --with-superpowers 仅支持 --agent claude 或 all（Superpowers 是 Claude Code 插件，opencode/codex 不支持）" >&2
    else
        # 6a. 铺融合纪律片段 → 项目根（供 CLAUDE.md 用 @CLAUDE.fusion.md 引用）
        copy_with_check "$SCRIPT_DIR/templates/CLAUDE.fusion.md" "$TARGET_DIR/CLAUDE.fusion.md"
        # 6b. 启用插件开关（不覆盖已存在的 settings.json）
        SETTINGS="$TARGET_DIR/.claude/settings.json"
        if [ ! -f "$SETTINGS" ]; then
            mkdir -p "$TARGET_DIR/.claude"
            cat > "$SETTINGS" <<'JSONEOF'
{
  "enabledPlugins": {
    "superpowers@claude-plugins-official": true
  }
}
JSONEOF
            echo "  [铺设] $SETTINGS (enabledPlugins: superpowers)"
        else
            echo "  [跳过] $SETTINGS 已存在 —— 请手动加入 enabledPlugins:"
            echo '           "superpowers@claude-plugins-official": true'
        fi
        echo ""
        echo "  ⚠ 融合层为实验性，增量未证 —— 详见 docs/Fusion-Superpowers-Integration.md"
        echo "  下一步(融合):"
        echo "    1. 通过 Claude Code 插件市场安装 superpowers 插件（key 以 'claude plugin list' 为准）"
        echo "    2. 在你的 CLAUDE.md 里加一行:  @CLAUDE.fusion.md"
        echo "    3. 在本项目目录【新开】Claude 会话（SessionStart 钩子才装载），/ 里能看到 superpowers:* 即激活"
    fi
    echo ""
fi

echo "=========================================="
echo "✅ 安装完成"
echo "=========================================="
echo ""
echo "目标 AI 智能体: $(agent_display)"
echo ""
echo "下一步："
echo "  1. 先运行 /speckit.constitution，完成项目宪法初始化并停下确认"
echo "  2. 在 $(agent_display) 中运行: $(agent_run_hint)"
echo "  3. 说明需求后，AI 必须先展示模式、命令流和 dashboard 路径，再逐个执行 speckit/harness 命令"
echo ""
echo "文档: README.md"
echo "示例 Constitution: examples/constitution.ai-training-engineering.example.md"
