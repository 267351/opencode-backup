#!/bin/bash
# OpenCode 配置恢复脚本
# 用法: ./restore.sh

set -e

OPENCODE_DIR="$HOME/.config/opencode"
BACKUP_DIR="$(dirname "$0")/backup"

if [ ! -d "$BACKUP_DIR" ]; then
    echo "❌ 备份目录不存在: $BACKUP_DIR"
    echo "请先运行 ./backup.sh 或从 GitHub 克隆备份"
    exit 1
fi

echo "🔄 开始恢复 OpenCode 配置..."

mkdir -p "$OPENCODE_DIR"

if [ -f "$BACKUP_DIR/opencode.json" ]; then
    cp "$BACKUP_DIR/opencode.json" "$OPENCODE_DIR/"
    echo "✅ 恢复 opencode.json"
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
