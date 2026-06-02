#!/bin/bash
# OpenCode 配置恢复 Skill
# 用法: /restore-config

set -e

CURRENT_DIR="$(pwd)"
EXPECTED_DIR="/home/hys/projects/opencode-backup"

if [ "$CURRENT_DIR" != "$EXPECTED_DIR" ]; then
    echo "❌ 错误：必须在 opencode-backup 项目目录下执行"
    echo "请先运行: cd $EXPECTED_DIR"
    exit 1
fi

OPENCODE_DIR="$HOME/.config/opencode"
BACKUP_DIR="$CURRENT_DIR/backup"

if [ ! -d "$BACKUP_DIR" ]; then
    echo "❌ 备份目录不存在: $BACKUP_DIR"
    echo "请先运行 /backup-config 创建备份"
    exit 1
fi

echo "🔄 开始恢复 OpenCode 配置..."

mkdir -p "$OPENCODE_DIR"

if [ -f "$BACKUP_DIR/opencode.json" ]; then
    if [ -f "$OPENCODE_DIR/opencode.json" ]; then
        python3 -c "
import json

with open('$OPENCODE_DIR/opencode.json', 'r') as f:
    existing = json.load(f)
with open('$BACKUP_DIR/opencode.json', 'r') as f:
    backup = json.load(f)

if 'provider' in backup and 'provider' in existing:
    for name in backup['provider']:
        if name in existing:
            old_key = existing[name].get('options', {}).get('apiKey', '')
            if old_key and old_key != 'YOUR_API_KEY_HERE':
                backup[name]['options']['apiKey'] = old_key

with open('$OPENCODE_DIR/opencode.json', 'w') as f:
    json.dump(backup, f, indent=2)
"
        echo "✅ 智能合并 opencode.json（保留原有 apiKey）"
    else
        cp "$BACKUP_DIR/opencode.json" "$OPENCODE_DIR/"
        echo "⚠️  已创建 opencode.json，请手动填入 apiKey"
    fi
fi

for config in "$BACKUP_DIR"/oh-my-openagent*.jsonc; do
    if [ -f "$config" ]; then
        cp "$config" "$OPENCODE_DIR/"
        echo "✅ 恢复 $(basename "$config")"
    fi
done

if [ -d "$BACKUP_DIR/skills" ]; then
    mkdir -p "$OPENCODE_DIR/skills"
    cp -r "$BACKUP_DIR/skills"/* "$OPENCODE_DIR/skills/"
    echo "✅ 恢复 skills/"
fi

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

if [ -f "$BACKUP_DIR/opencode-model-switch.md" ]; then
    cp "$BACKUP_DIR/opencode-model-switch.md" "$OPENCODE_DIR/"
    echo "✅ 恢复 opencode-model-switch.md"
fi

if [ -d "$BACKUP_DIR/superpowers" ]; then
    mkdir -p "$OPENCODE_DIR/superpowers"
    cp -r "$BACKUP_DIR/superpowers"/* "$OPENCODE_DIR/superpowers/"
    echo "✅ 恢复 superpowers/"
fi

echo ""
echo "✅ 恢复完成！"
echo ""
echo "⚠️  请重启 OpenCode 以使配置生效"