# Switch Model Skill

一键切换 OpenCode 模型配置方案。用于在火山引擎、Mimo、OpenCode 官方免费和 DeepSeek 四套完整方案之间快速切换。

## Usage

在 OpenCode 聊天中使用：

```
/switch-model volc
```
切换到火山引擎全套方案。

```
/switch-model mimo
```
切换到 Mimo 全套方案。

```
/switch-model opencode
```
切换到 OpenCode 官方免费模型。

```
/switch-model deepseek
```
切换到 DeepSeek V4 方案（v4-pro + v4-flash）。

## Description

自动完成：
1. 复制对应的 oh-my-openagent 配置文件
2. 修改 opencode.json 中的默认模型配置
3. 提示重启生效

## Config Files

- 火山方案: `oh-my-openagent-volc.jsonc` → `oh-my-openagent.jsonc`
- Mimo 方案: `oh-my-openagent-mimo.jsonc` → `oh-my-openagent.jsonc`
- OpenCode 官方免费: `oh-my-openagent-opencode.jsonc` → `oh-my-openagent.jsonc`
- DeepSeek V4: `oh-my-openagent-deepseek.jsonc` → `oh-my-openagent.jsonc`

## Author

Created automatically by Sisyphus
