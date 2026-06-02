# Backup Config Skill

一键备份 OpenCode 配置到本地备份目录。

## Usage

在 OpenCode 聊天中使用（仅在 opencode-backup 项目下有效）：

```
/backup-config
```

## Prerequisites

必须在 `opencode-backup` 项目目录下执行：
```bash
cd /home/hys/projects/opencode-backup
```

如果当前不在该项目目录，提示用户先切换目录。

## Description

自动完成：
1. 备份 opencode.json（脱敏版 - apiKey 替换为占位符）
2. 备份 oh-my-openagent*.jsonc 模型配置方案
3. 备份自定义 Skills
4. 备份插件配置（符号链接转为实际文件）
5. 备份模型切换说明

## Security

- opencode.json 中的 apiKey 会被替换为 `YOUR_API_KEY_HERE`
- 备份文件保存在仓库根目录的 `backup/` 目录
- 该目录已加入 `.gitignore`，不会上传到 GitHub

## Output

备份完成后显示：
- 备份内容列表
- 备份文件路径

## Author

Created by Sisyphus
