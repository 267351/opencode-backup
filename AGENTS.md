# AGENTS.md

## What This Is

OpenCode configuration backup/restore utility. Shell scripts + version-controlled config snapshots.

**Purpose**: Backup and restore `~/.config/opencode` across machines

## Critical Facts

- `backup/` contains **desensitized** config (apiKey → `YOUR_API_KEY_HERE`)
- `skills/` contains the 3 project skills (backup-config, restore-config, switch-model) — tracked in git
- Plugin symlinks are stored as `.link` files (contain target path)
- Superpowers skills are only backed up if NOT a git repo (see backup.sh line ~85)
- `opencode.json` 备份时自动脱敏（apiKey 替换为占位符）
- 恢复时智能合并：保留目标机器的 apiKey，更新其他配置
- 恢复前自动备份现有配置到 `backup/before-restore-<timestamp>/`

## Commands

```bash
# Backup current OpenCode config → ./backup/ (auto-desensitize apiKey)
./backup.sh

# Restore from ./backup/ → ~/.config/opencode/ (smart merge, preserve apiKey)
./restore.sh

# Model switching (via skill — dynamic, auto-discovers available configs)
/switch-model volc       # Volcano Engine
/switch-model mimo       # Mimo
/switch-model opencode   # OpenCode official free
/switch-model deepseek   # DeepSeek V4

# Backup/Restore (via skill)
/backup-config             # 备份配置（自动脱敏 apiKey）
/restore-config            # 恢复配置（智能合并，保留 apiKey）
```

## Directory Structure

```
opencode-backup/
├── backup.sh              # Smart backup + desensitize apiKey
├── restore.sh             # Smart restore + merge + pre-backup safety
├── skills/                # [TRACKED] Project skills (available on clone)
│   ├── backup-config/     #   /backup-config command
│   ├── restore-config/    #   /restore-config command
│   └── switch-model/      #   /switch-model command
├── backup/                # Config snapshot (desensitized, in version control)
│   ├── opencode.json      #   Main config (providers, models, plugins)
│   ├── oh-my-openagent*.jsonc  # Agent configs
│   ├── opencode-model-switch.md
│   ├── skills/            #   User-custom skills (backed up from ~/.config)
│   └── plugin/            #   Plugin config (.link files for symlinks)
├── .gitignore
├── .gitattributes
├── AGENTS.md
└── README.md
```

## Model Switching System

The `/switch-model` skill now dynamically discovers available configurations by scanning `~/.config/opencode/` for `oh-my-openagent*.jsonc` files. No hardcoded model list.

## Config Details

**opencode.json**:
- Providers: deepseek, mimo, nvidia, ollama, taobaoai, vllm, volcengine-plan
- Compaction: enabled (trigger at 80%, target 50%)
- Plugins: superpowers, oh-my-openagent@latest

**oh-my-openagent.jsonc**:
- All agents use same model (mimo/mimo-v2.5-pro by default)
- Permission mode: `ask` for all operations (question, edit, bash)

## When Working Here

- Scripts use `$HOME/.config/opencode` and `$SCRIPT_DIR` — portable across machines
- Restore requires restart: `⚠️ 请重启 OpenCode 以使配置生效`
- Plugin symlinks use absolute paths (may break if home dir differs)
- Add new `oh-my-openagent-<name>.jsonc` files for new model profiles — switch-model auto-discovers them
