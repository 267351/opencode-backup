#!/bin/bash
# OpenCode 配置备份 Skill
# 用法: /backup-config

set -e

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"

if [ ! -f "$REPO_ROOT/backup.sh" ]; then
    echo "❌ 错误：必须在 opencode-backup 项目目录下执行"
    echo "请先切换到项目根目录"
    exit 1
fi

OPENCODE_DIR="$HOME/.config/opencode"
BACKUP_DIR="$REPO_ROOT/backup"

echo "🔄 开始备份 OpenCode 配置..."

mkdir -p "$BACKUP_DIR"

if [ -f "$OPENCODE_DIR/opencode.json" ]; then
    python3 -c "
import json

with open('$OPENCODE_DIR/opencode.json', 'r') as f:
    config = json.load(f)

if 'provider' in config:
    for provider_name, provider in config['provider'].items():
        if 'options' in provider and 'apiKey' in provider['options']:
            provider['options']['apiKey'] = 'YOUR_API_KEY_HERE'

with open('$BACKUP_DIR/opencode.json', 'w') as f:
    json.dump(config, f, indent=2)
"
    echo "✅ 备份 opencode.json（已脱敏）"
fi

for config in "$OPENCODE_DIR"/oh-my-openagent*.jsonc; do
    if [ -f "$config" ]; then
        cp "$config" "$BACKUP_DIR/"
        echo "✅ 备份 $(basename "$config")"
    fi
done

if [ -d "$OPENCODE_DIR/skills" ]; then
    cp -r "$OPENCODE_DIR/skills" "$BACKUP_DIR/"
    echo "✅ 备份 skills/"
fi

if [ -d "$OPENCODE_DIR/plugin" ]; then
    mkdir -p "$BACKUP_DIR/plugin"
    for plugin in "$OPENCODE_DIR/plugin"/*; do
        if [ -L "$plugin" ]; then
            target=$(readlink "$plugin")
            echo "$target" > "$BACKUP_DIR/plugin/$(basename "$plugin").link"
            echo "✅ 备份插件链接: $(basename "$plugin") -> $target"
        elif [ -f "$plugin" ]; then
            cp "$plugin" "$BACKUP_DIR/plugin/"
            echo "✅ 备份插件文件: $(basename "$plugin")"
        fi
    done
fi

if [ -f "$OPENCODE_DIR/opencode-model-switch.md" ]; then
    cp "$OPENCODE_DIR/opencode-model-switch.md" "$BACKUP_DIR/"
    echo "✅ 备份 opencode-model-switch.md"
fi

if [ -d "$OPENCODE_DIR/superpowers" ] && [ ! -d "$OPENCODE_DIR/superpowers/.git" ]; then
    cp -r "$OPENCODE_DIR/superpowers" "$BACKUP_DIR/"
    echo "✅ 备份 superpowers/"
fi

echo ""
echo "✅ 备份完成！文件保存在: $BACKUP_DIR"
echo ""
echo "📋 备份内容:"
ls -la "$BACKUP_DIR"