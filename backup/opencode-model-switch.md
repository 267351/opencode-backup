# OpenCode 模型切换指南

## 三套配置方案

目前配置了三套完整的 OhMyOpenAgent 方案：

| 方案 | 配置文件 | 默认模型 | 说明 |
|------|----------|----------|------|
| 火山引擎方案 | `oh-my-openagent-volc.jsonc` | `volcengine-plan/ark-code-latest` | 火山引擎官方模型 |
| Mimo 方案 | `oh-my-openagent-mimo.jsonc` | `mimo/mimo-v2.5-pro` | Mimo 第三方模型 |
| OpenCode 免费方案 | `oh-my-openagent-opencode.jsonc` | `opencode/gpt-5.1-codex` | OpenCode 官方自带免费额度 |

## 使用自定义 skill 一键切换（推荐）

已经创建了 `switch-model` 自定义 skill，直接在 OpenCode 聊天中使用：

```
/switch-model volc
```
一键切换到火山引擎全套方案。

```
/switch-model mimo
```
一键切换到 Mimo 全套方案。

```
/switch-model opencode
```
一键切换到 OpenCode 官方免费模型。

切换完成后，重启 OpenCode 即可生效。

---

## 手动切换命令

如果你不想用 skill，可以手动执行：

### 切换到 Mimo 方案

```bash
# 切换 oh-my-openagent 配置
cp /root/.config/opencode/oh-my-openagent-mimo.jsonc /root/.config/opencode/oh-my-openagent.jsonc

# 修改 opencode.json 默认模型为 mimo
sed -i '3s/"model": ".*"/"model": "mimo\/mimo-v2.5-pro"/' /root/.config/opencode/opencode.json
```

### 切换到火山引擎方案

```bash
# 切换 oh-my-openagent 配置
cp /root/.config/opencode/oh-my-openagent-volc.jsonc /root/.config/opencode/oh-my-openagent.jsonc

# 修改 opencode.json 默认模型为火山
sed -i '3s/"model": ".*"/"model": "volcengine-plan\/ark-code-latest"/' /root/.config/opencode/opencode.json
```

## 使用自定义 skill 一键切换

安装了 `switch-model` skill 后，可以直接使用：

```
/switch-model volc
/switch-model mimo
```

## 问题排查

### 为什么切换模型后，头脑风暴/计划不启动？

这是因为：
1. 你只改了 `opencode.json` 里的默认模型
2. 但是 `oh-my-openagent.jsonc` 里各个专门智能体（prometheus计划、metis分析等）还是用原来的模型
3. 如果原模型认证失败，子智能体启动不了，就会跳过流程直接干活

**解决方法**：必须同时切换两套配置，本方案已经处理好了这个问题。

### Token超限报错 `Total tokens of image and text exceed max message tokens`

这是因为：
1. 自动压缩功能被禁用了
2. 长时间对话累积超过模型上下文上限

**解决方法**：
- 确保 `opencode.json` 中 `compaction.disabled = false`
- 本配置默认已开启自动压缩：80% 触发，压缩到 50%

