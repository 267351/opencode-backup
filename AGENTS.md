# AGENTS.md

## What This Is

OpenCode configuration backup/restore utility. Not a code project—shell scripts + config snapshots.

**Repository**: `/home/hys/projects/opencode-backup`  
**Purpose**: Backup and restore `~/.config/opencode` across machines

## Critical Facts

- `backup/` is **gitignored** — contains sensitive API keys and user config
- Only `backup.sh`, `restore.sh`, `README.md` are version-controlled
- Plugin symlinks are stored as `.link` files (contain target path)
- Superpowers skills are only backed up if NOT a git repo (see backup.sh line 58)
- `opencode.json` 备份时自动脱敏（apiKey 替换为占位符）
- 恢复时智能合并：保留目标机器的 apiKey，更新其他配置

## Commands

```bash
# Backup current OpenCode config → ~/.config/opencode/backup/
./backup.sh

# Restore from ~/.config/opencode/backup/ → ~/.config/opencode/
./restore.sh

# Model switching (via skill)
/switch-model volc       # Volcano Engine (ark-code-latest)
/switch-model mimo       # Mimo (mimo-v2.5-pro)
/switch-model opencode   # OpenCode official free (gpt-5.1-codex)
/switch-model deepseek   # DeepSeek V4 (deepseek-v4-pro)

# Backup/Restore (via skill - 推荐)
/backup-config             # 备份配置（自动脱敏 apiKey）
/restore-config            # 恢复配置（智能合并，保留 apiKey）
```

## Directory Structure

```
opencode-backup/
├── backup.sh              # Copies ~/.config/opencode → ./backup/
├── restore.sh             # Copies ./backup/ → ~/.config/opencode/
├── README.md              # Chinese documentation
└── backup/                # [GITIGNORED] Config snapshot
    ├── opencode.json                    # Main config (providers, models, plugins)
    ├── oh-my-openagent.jsonc            # Active agent config
    ├── oh-my-openagent-{volc,mimo,opencode,deepseek}.jsonc  # Presets
    ├── opencode-model-switch.md         # Model switching guide
    ├── skills/
    │   ├── switch-model/                # Model switching skill
    │   ├── backup-config/               # Backup skill (/backup-config)
    │   ├── restore-config/              # Restore skill (/restore-config)
    │   └── superpowers/                 # Superpowers skills (15 total)
    └── plugin/
        └── superpowers.js.link          # Symlink → superpowers plugin
```

## Model Switching System

Two files must change together:
1. `oh-my-openagent.jsonc` — agent model assignments (prometheus, oracle, metis, etc.)
2. `opencode.json` line 3 — default model

**Gotcha**: If you only change `opencode.json`, sub-agents (brainstorming, planning) will fail silently because they still reference the old model.

## Config Details

**opencode.json**:
- Providers: deepseek, mimo, nvidia, ollama, taobaoai, vllm, volcengine-plan
- Compaction: enabled (trigger at 80%, target 50%)
- Plugins: superpowers, oh-my-openagent@latest

**oh-my-openagent.jsonc**:
- All agents use same model (mimo/mimo-v2.5-pro by default)
- Permission mode: `ask` for all operations (question, edit, bash)
- Categories: visual-engineering, ultrabrain, deep, artistry, quick, unspecified-low/high, writing

## When Working Here

- Never commit `backup/` contents (API keys exposed)
- Scripts assume `~/.config/opencode` as target (hardcoded in both .sh files)
- Restore requires restart: `⚠️ 请重启 OpenCode 以使配置生效`
- Plugin symlinks use absolute paths (will break if home dir differs)
