#!/bin/bash
# OpenCode 配置备份脚本
# 用法: ./backup.sh

set -e

OPENCODE_DIR="$HOME/.config/opencode"
BACKUP_DIR="$(dirname "$0")/backup"

echo "🔄 开始备份 OpenCode 配置..."

# 创建备份目录
mkdir -p "$BACKUP_DIR"

# 备份主配置（脱敏版 - apiKey 替换为占位符）
if [ -f "$OPENCODE_DIR/opencode.json" ]; then
    python3 -c "
import json
import sys

with open('$OPENCODE_DIR/opencode.json', 'r') as f:
    config = json.load(f)

# 替换所有 apiKey 为占位符
if 'provider' in config:
    for provider_name, provider in config['provider'].items():
        if 'options' in provider and 'apiKey' in provider['options']:
            provider['options']['apiKey'] = 'YOUR_API_KEY_HERE'

with open('$BACKUP_DIR/opencode.json', 'w') as f:
    json.dump(config, f, indent=2)
"
    echo "✅ 备份 opencode.json（已脱敏）"
fi

# 备份模型配置方案
for config in "$OPENCODE_DIR"/oh-my-openagent*.jsonc; do
    if [ -f "$config" ]; then
        cp "$config" "$BACKUP_DIR/"
        echo "✅ 备份 $(basename "$config")"
    fi
done

# 备份自定义 Skills
if [ -d "$OPENCODE_DIR/skills" ]; then
    cp -r "$OPENCODE_DIR/skills" "$BACKUP_DIR/"
    echo "✅ 备份 skills/"
fi

# 备份插件配置（符号链接转为实际文件）
if [ -d "$OPENCODE_DIR/plugin" ]; then
    mkdir -p "$BACKUP_DIR/plugin"
    for plugin in "$OPENCODE_DIR/plugin"/*; do
        if [ -L "$plugin" ]; then
            # 符号链接：记录目标路径
            target=$(readlink "$plugin")
            echo "$target" > "$BACKUP_DIR/plugin/$(basename "$plugin").link"
            echo "✅ 备份插件链接: $(basename "$plugin") -> $target"
        elif [ -f "$plugin" ]; then
            cp "$plugin" "$BACKUP_DIR/plugin/"
            echo "✅ 备份插件文件: $(basename "$plugin")"
        fi
    done
fi

# 备份模型切换说明
if [ -f "$OPENCODE_DIR/opencode-model-switch.md" ]; then
    cp "$OPENCODE_DIR/opencode-model-switch.md" "$BACKUP_DIR/"
    echo "✅ 备份 opencode-model-switch.md"
fi

# 备份 Superpowers skills（如果存在且不是 git 仓库）
if [ -d "$OPENCODE_DIR/superpowers" ] && [ ! -d "$OPENCODE_DIR/superpowers/.git" ]; then
    cp -r "$OPENCODE_DIR/superpowers" "$BACKUP_DIR/"
    echo "✅ 备份 superpowers/"
fi

echo ""
echo "✅ 备份完成！文件保存在: $BACKUP_DIR"
echo ""
echo "📋 备份内容:"
ls -la "$BACKUP_DIR"
