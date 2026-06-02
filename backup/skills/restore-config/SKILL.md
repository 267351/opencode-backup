# Restore Config Skill

从本地备份恢复 OpenCode 配置。

## Usage

在 OpenCode 聊天中使用（仅在 opencode-backup 项目下有效）：

```
/restore-config
```

## Prerequisites

必须在 `opencode-backup` 项目目录下执行：
```bash
cd /home/hys/projects/opencode-backup
```

如果当前不在该项目目录，提示用户先切换目录。

## Description

智能恢复：
1. opencode.json：保留目标机器的 apiKey，更新其他配置
2. oh-my-openagent*.jsonc：直接覆盖
3. 自定义 Skills：直接覆盖
4. 插件配置：恢复符号链接
5. 模型切换说明：直接覆盖

## Smart Merge

opencode.json 恢复逻辑：
- 如果目标机器已有 opencode.json：保留原有 apiKey，更新其他配置
- 如果目标机器没有 opencode.json：创建模板，提示用户手动填入 apiKey

## Backup Location

备份文件位于仓库根目录的 `backup/` 目录（已 gitignore）。

## Security

- 不会覆盖目标机器的 apiKey
- 只更新模型配置、插件、compaction 等非敏感信息

## Output

恢复完成后显示：
- 恢复内容列表
- 提示重启 OpenCode

## Author

Created by Sisyphus
