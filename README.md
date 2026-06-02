# OpenCode 配置备份与恢复

一键备份和恢复 OpenCode 配置，包括模型切换方案、自定义 Skills、插件等。

## 包含内容

- `opencode.json` - 主配置文件
- `oh-my-openagent*.jsonc` - 模型配置方案（mimo/volc/deepseek/opencode）
- `skills/` - 自定义 Skills（switch-model 等）
- `opencode-model-switch.md` - 模型切换说明
- `plugin/` - 插件配置
- `superpowers/` - Superpowers skills（如果存在）

## 使用方法

### 备份（在当前电脑执行）

```bash
cd /path/to/opencode-backup
./backup.sh
```

备份文件会保存到 `./backup/` 目录。

### 恢复（在新电脑执行）

```bash
cd /path/to/opencode-backup
./restore.sh
```

### 上传到 GitHub

```bash
git add .
git commit -m "backup: OpenCode 配置备份"
git push
```

### 从 GitHub 恢复

```bash
git clone https://github.com/your-repo/opencode-backup.git
cd opencode-backup
./restore.sh
```

## 目录结构

```
opencode-backup/
├── README.md
├── backup.sh          # 备份脚本
├── restore.sh         # 恢复脚本
└── backup/            # 备份文件目录（git 忽略）
    ├── opencode.json
    ├── oh-my-openagent*.jsonc
    ├── skills/
    ├── plugin/
    └── ...
```

## 注意事项

- `backup/` 目录包含敏感配置，已加入 `.gitignore`
- 只备份配置文件，不备份 API Keys
- 恢复前会检查目标目录是否存在
