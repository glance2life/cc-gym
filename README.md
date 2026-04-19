# cc-gym

在 Claude Code 忙着干活的时候，cc-gym 把你从"盯屏发呆"里拽出来，做一个 30 秒的小动作。

设计细节见 [DESIGN.md](./DESIGN.md)。

## 安装

在 Claude Code 里：

```
/plugin marketplace add glance2life/cc-gym
/plugin install cc-gym@cc-gym
```

（`marketplace add` 直接认 `owner/repo` 形式；也可以填完整的 `https://github.com/glance2life/cc-gym`。**不需要 fork**，这是只读拉取。）

装完按提示重启或 `/reload-plugins` 让钩子生效。

## 更新 / 卸载

```
/plugin marketplace update       # 拉 marketplace 最新
/plugin uninstall cc-gym         # 卸载
```

## 配置

所有配置都是环境变量，没有 GUI。默认值够用，想调再动：

| 环境变量 | 默认 | 作用 |
|---|---|---|
| `CC_GYM_LIGHT_SEC` | `20` | 多久后弹第一次（轻档）提醒 |
| `CC_GYM_HEAVY_SEC` | `180` | 多久后升级到重档提醒 |
| `CC_GYM_GLOBAL_COOLDOWN` | `900`（15 分钟） | 跨 session 两次弹窗的最短间隔，兜底节奏 |
| `CC_GYM_LIGHT_FILE` | 内置 | 自定义轻档动作清单文件 |
| `CC_GYM_HEAVY_FILE` | 内置 | 自定义重档动作清单文件 |

动作清单格式：每行 `category: 动作描述`，`category ∈ {eye, neck, leg, breath}`，`#` 开头为注释。
