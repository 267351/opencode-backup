#!/bin/bash
# OpenCode 配置恢复脚本
# 用法: ./restore.sh
# 智能合并：保留目标机器 apiKey，更新其他配置

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
OPENCODE_DIR="$HOME/.config/opencode"
BACKUP_DIR="$SCRIPT_DIR/backup"
REPO_SKILLS_DIR="$SCRIPT_DIR/skills"

echo "🔄 OpenCode 配置恢复"
echo ""

# 检查备份目录
if [ ! -d "$BACKUP_DIR" ]; then
    echo "❌ 备份目录不存在: $BACKUP_DIR"
    echo "   请先运行 ./backup.sh 或从 GitHub 克隆备份"
    exit 1
fi

# 检查 python3（智能合并需要）
if ! command -v python3 &>/dev/null; then
    echo "⚠️  python3 未安装，将采用直接覆盖方式（apiKey 可能被覆盖）"
    SMART_MERGE=false
else
    SMART_MERGE=true
fi

# 恢复前自动备份现有配置（安全兜底）
if [ -d "$OPENCODE_DIR" ] && [ -n "$(ls -A "$OPENCODE_DIR" 2>/dev/null)" ]; then
    TIMESTAMP=$(date +%Y%m%d_%H%M%S)
    PRE_BACKUP="$BACKUP_DIR/before-restore-$TIMESTAMP"
    mkdir -p "$PRE_BACKUP"
    cp -r "$OPENCODE_DIR"/* "$PRE_BACKUP/" 2>/dev/null || true
    echo "📦 已备份现有配置到: $PRE_BACKUP"
    echo ""
fi

mkdir -p "$OPENCODE_DIR"

# --- 1. opencode.json（智能合并，保留 apiKey）---
if [ -f "$BACKUP_DIR/opencode.json" ]; then
    if [ "$SMART_MERGE" = true ] && [ -f "$OPENCODE_DIR/opencode.json" ]; then
        MERGE_RESULT=$(python3 -c "
import json, sys

with open('$OPENCODE_DIR/opencode.json', 'r') as f:
    existing = json.load(f)
with open('$BACKUP_DIR/opencode.json', 'r') as f:
    backup = json.load(f)

existing_providers = existing.get('provider', {})
backup_providers = backup.get('provider', {})

PLACEHOLDER = 'YOUR_API_KEY_HERE'
preserved, lost, already_real = [], [], []

for name in backup_providers:
    old_key = existing_providers.get(name, {}).get('options', {}).get('apiKey', '')
    new_key = backup_providers.get(name, {}).get('options', {}).get('apiKey', '')
    if old_key and old_key != PLACEHOLDER:
        if new_key == PLACEHOLDER:
            backup_providers[name]['options']['apiKey'] = old_key
            preserved.append(name)
        else:
            already_real.append(name)
    else:
        if new_key != PLACEHOLDER:
            already_real.append(name)
        else:
            lost.append(name)

with open('$OPENCODE_DIR/opencode.json', 'w') as f:
    json.dump(backup, f, indent=2, ensure_ascii=False)

print('PRESERVED=' + ','.join(preserved))
print('ALREADY_REAL=' + ','.join(already_real))
print('LOST=' + ','.join(lost))
")
        eval "$MERGE_RESULT"

        if [ -n "${PRESERVED:-}" ]; then
            echo "🔑 已保留 apiKey: $PRESERVED"
        fi
        if [ -n "${ALREADY_REAL:-}" ]; then
            echo "ℹ️  备份中已是真实 key: $ALREADY_REAL"
        fi
        if [ -n "${LOST:-}" ]; then
            echo "⚠️  以下 provider 无 apiKey 可保留: $LOST"
            echo "    (目标机器和备份都未配置，请手动填入)"
        fi
        echo "✅ 智能合并 opencode.json 完成"
    elif [ -f "$OPENCODE_DIR/opencode.json" ]; then
        # 有现有配置但没 python3：拒绝覆盖
        echo "❌ 缺少 python3，无法安全合并。已中止以保护 apiKey。"
        echo "   安装 python3 后重试，或手动备份现有 opencode.json 后用 --force 覆盖"
        exit 1
    else
        # 没有现有配置，正常创建
        cp "$BACKUP_DIR/opencode.json" "$OPENCODE_DIR/"
        echo "⚠️  已创建 opencode.json，请手动填入 apiKey"
    fi
fi

# --- 2. Agent 配置文件 ---
shopt -s nullglob
configs=("$BACKUP_DIR"/oh-my-openagent*.jsonc)
if [ ${#configs[@]} -gt 0 ]; then
    for config in "${configs[@]}"; do
        cp "$config" "$OPENCODE_DIR/"
        echo "✅ 恢复 $(basename "$config")"
    done
fi
shopt -u nullglob

# --- 3. Skills（从 repo 安装项目技能 + 从 backup 恢复用户技能）---
mkdir -p "$OPENCODE_DIR/skills"

# 安装仓库自带技能（优先，始终可用）
if [ -d "$REPO_SKILLS_DIR" ]; then
    for skill_dir in "$REPO_SKILLS_DIR"/*; do
        if [ -d "$skill_dir" ]; then
            skill_name=$(basename "$skill_dir")
            cp -r "$skill_dir" "$OPENCODE_DIR/skills/"
            echo "✅ 安装技能: $skill_name"
        fi
    done
fi

# 恢复用户自定义技能（backup/skills/ 中的额外内容）
if [ -d "$BACKUP_DIR/skills" ]; then
    for skill_dir in "$BACKUP_DIR/skills"/*; do
        if [ -d "$skill_dir" ]; then
            skill_name=$(basename "$skill_dir")
            if [ ! -d "$OPENCODE_DIR/skills/$skill_name" ]; then
                cp -r "$skill_dir" "$OPENCODE_DIR/skills/"
                echo "✅ 恢复用户技能: $skill_name"
            fi
        fi
    done
fi

# --- 4. 插件配置 ---
if [ -d "$BACKUP_DIR/plugin" ]; then
    mkdir -p "$OPENCODE_DIR/plugin"
    for item in "$BACKUP_DIR/plugin"/*; do
        if [ -f "$item" ] && [[ "$item" == *.link ]]; then
            plugin_name=$(basename "$item" .link)
            target=$(cat "$item")
            ln -sf "$target" "$OPENCODE_DIR/plugin/$plugin_name"
            echo "✅ 恢复插件链接: $plugin_name -> $target"
        elif [ -f "$item" ]; then
            cp "$item" "$OPENCODE_DIR/plugin/"
            echo "✅ 恢复插件文件: $(basename "$item")"
        fi
    done
fi

# --- 5. 模型切换说明 ---
if [ -f "$BACKUP_DIR/opencode-model-switch.md" ]; then
    cp "$BACKUP_DIR/opencode-model-switch.md" "$OPENCODE_DIR/"
    echo "✅ 恢复 opencode-model-switch.md"
fi

# --- 6. Superpowers ---
if [ -d "$BACKUP_DIR/superpowers" ]; then
    mkdir -p "$OPENCODE_DIR/superpowers"
    cp -r "$BACKUP_DIR/superpowers"/* "$OPENCODE_DIR/superpowers/"
    echo "✅ 恢复 superpowers/"
fi

echo ""
echo "✅ 恢复完成！"
echo ""
echo "⚠️  请重启 OpenCode 以使配置生效"
