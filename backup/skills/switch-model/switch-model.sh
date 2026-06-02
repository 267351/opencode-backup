#!/bin/bash
set -euo pipefail

CONFIG_DIR="$HOME/.config/opencode"
TARGET_CONFIG="$CONFIG_DIR/oh-my-openagent.jsonc"

declare -A MODEL_MAP
shopt -s nullglob
for config in "$CONFIG_DIR"/oh-my-openagent*.jsonc; do
    base=$(basename "$config" .jsonc)
    if [ "$base" = "oh-my-openagent" ]; then
        continue
    fi
    name=${base#oh-my-openagent-}
    name=${name#oh-my-openagent.}
    if [ -n "$name" ] && [ "$name" != "$base" ]; then
        MODEL_MAP["$name"]="$config"
    fi
done
shopt -u nullglob

show_usage() {
    echo "Usage: /switch-model <name>"
    echo ""
    echo "Available models:"
    for name in $(printf '%s\n' "${!MODEL_MAP[@]}" | sort); do
        echo "  $name"
    done
    echo ""
    echo "Example: /switch-model volc"
}

case "${1:-}" in
    ""|help|-h|--help)
        show_usage
        ;;
    *)
        if [ -n "${MODEL_MAP[$1]:-}" ]; then
            cp "${MODEL_MAP[$1]}" "$TARGET_CONFIG"
            echo "✅ 已切换到 $1 ($(basename "${MODEL_MAP[$1]}"))"
            echo ""
            echo "⚠️  请重启 OpenCode 以使配置生效"
        else
            echo "❌ 未知模型: $1"
            echo ""
            show_usage
            exit 1
        fi
        ;;
esac
