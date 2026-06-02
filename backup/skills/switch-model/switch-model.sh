#!/bin/bash

# OpenCode Model Switcher
# Switch between preconfigured model sets

CONFIG_DIR="/root/.config/opencode"
TARGET_CONFIG="$CONFIG_DIR/oh-my-openagent.jsonc"
VOLC_CONFIG="$CONFIG_DIR/oh-my-openagent-volc.jsonc"
MIMO_CONFIG="$CONFIG_DIR/oh-my-openagent-mimo.jsonc"
OPENCODE_FREE_CONFIG="$CONFIG_DIR/oh-my-openagent-opencode.jsonc"
DEEPSEEK_CONFIG="$CONFIG_DIR/oh-my-openagent-deepseek.jsonc"
OPENCODE_CONFIG="$CONFIG_DIR/opencode.json"

show_usage() {
    echo "Usage: /switch-model <volc|mimo|opencode|deepseek>"
    echo ""
    echo "  volc:     Switch to Volcano Engine full configuration"
    echo "  mimo:     Switch to Mimo full configuration"
    echo "  opencode: Switch to OpenCode official free model"
    echo "  deepseek: Switch to DeepSeek V4 configuration"
    echo ""
    echo "Example: /switch-model volc"
}

switch_to_volc() {
    echo "Switching to VOLCANO ENGINE configuration..."
    cp "$VOLC_CONFIG" "$TARGET_CONFIG"
    sed -i '3s/"model": ".*"/"model": "volcengine-plan\/ark-code-latest"/' "$OPENCODE_CONFIG"
    echo "✅ Done! Please restart OpenCode for changes to take effect."
    echo "   Configuration: $VOLC_CONFIG → $TARGET_CONFIG"
    echo "   Default model changed to: volcengine-plan/ark-code-latest"
}

switch_to_mimo() {
    echo "Switching to MIMO configuration..."
    cp "$MIMO_CONFIG" "$TARGET_CONFIG"
    sed -i '3s/"model": ".*"/"model": "mimo\/mimo-v2.5-pro"/' "$OPENCODE_CONFIG"
    echo "✅ Done! Please restart OpenCode for changes to take effect."
    echo "   Configuration: $MIMO_CONFIG → $TARGET_CONFIG"
    echo "   Default model changed to: mimo/mimo-v2.5-pro"
}

switch_to_opencode() {
    echo "Switching to OPENCODE OFFICIAL FREE MODEL configuration..."
    cp "$OPENCODE_FREE_CONFIG" "$TARGET_CONFIG"
    sed -i '3s/"model": ".*"/"model": "opencode\/gpt-5.1-codex"/' "$OPENCODE_CONFIG"
    echo "✅ Done! Please restart OpenCode for changes to take effect."
    echo "   Configuration: $OPENCODE_FREE_CONFIG → $TARGET_CONFIG"
    echo "   Default model changed to: opencode/gpt-5.1-codex"
    echo "   Note: OpenCode official free model requires that you have authenticated with OpenCode and have available quota"
}

switch_to_deepseek() {
    echo "Switching to DEEPSEEK V4 configuration..."
    cp "$DEEPSEEK_CONFIG" "$TARGET_CONFIG"
    sed -i '3s/"model": ".*"/"model": "deepseek\/deepseek-v4-pro"/' "$OPENCODE_CONFIG"
    echo "✅ Done! Please restart OpenCode for changes to take effect."
    echo "   Configuration: $DEEPSEEK_CONFIG → $TARGET_CONFIG"
    echo "   Default model changed to: deepseek/deepseek-v4-pro"
}

case "$1" in
    "volc")
        switch_to_volc
        ;;
    "mimo")
        switch_to_mimo
        ;;
    "opencode")
        switch_to_opencode
        ;;
    "deepseek")
        switch_to_deepseek
        ;;
    *)
        show_usage
        exit 1
        ;;
esac
