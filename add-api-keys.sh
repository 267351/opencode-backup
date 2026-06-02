#!/bin/bash
# OpenCode API Key 填入助手
# 用法: ./add-api-keys.sh
# 交互式提示填入每个 provider 的 apiKey，安全写入 ~/.config/opencode/opencode.json

set -euo pipefail

OPENCODE_DIR="$HOME/.config/opencode"
CONFIG="$OPENCODE_DIR/opencode.json"

if [ ! -f "$CONFIG" ]; then
    echo "❌ 找不到 $CONFIG"
    exit 1
fi

if ! command -v python3 &>/dev/null; then
    echo "❌ 需要 python3"
    exit 1
fi

echo "🔑 OpenCode API Key 填入助手"
echo ""
echo "当前状态："
python3 -c "
import json
with open('$CONFIG') as f: cfg = json.load(f)
for name, p in cfg.get('provider', {}).items():
    opts = p.get('options', {})
    key = opts.get('apiKey', '<未配置>')
    base = opts.get('baseURL', '')
    status = '✓ 已配置' if key and key != 'YOUR_API_KEY_HERE' else '✗ 待填入'
    print(f'  [{status}] {name:18s} {base}')
"
echo ""

read -p "是否开始填入? [y/N] " CONFIRM
if [ "$CONFIRM" != "y" ] && [ "$CONFIRM" != "Y" ]; then
    echo "已取消"
    exit 0
fi

BACKUP="$CONFIG.bak-$(date +%Y%m%d_%H%M%S)"
cp "$CONFIG" "$BACKUP"
echo "📦 已备份到: $BACKUP"
echo ""

python3 -c "
import json, getpass, sys

with open('$CONFIG') as f: cfg = json.load(f)
providers = cfg.get('provider', {})

for name in providers:
    opts = providers[name].setdefault('options', {})
    current = opts.get('apiKey', '')
    if current and current != 'YOUR_API_KEY_HERE':
        print(f'  {name:18s}: 已配置（跳过）', file=sys.stderr)
        continue
    if 'apiKey' not in opts:
        print(f'  {name:18s}: 配置中无 apiKey 字段（跳过）', file=sys.stderr)
        continue
    key = getpass.getpass(f'  {name:18s} apiKey: ')
    if key:
        opts['apiKey'] = key
        print(f'  {name:18s}: ✓ 已填入', file=sys.stderr)

with open('$CONFIG', 'w') as f:
    json.dump(cfg, f, indent=2, ensure_ascii=False)
"

echo ""
echo "✅ 完成！建议重启 OpenCode 使配置生效"
echo "   然后运行: ./backup.sh 重新生成脱敏备份"
