# cc-gym

在 Claude Code 忙着干活的时候，cc-gym 把你从"盯屏发呆"里拽出来，做一个 30 秒的小动作。

等 CC 跑工具的那段时间往往是真正的空档——20 秒后来一次轻提醒（转脖子/深呼吸），超过 3 分钟再来一次重提醒（起身走动）。短任务（<20s）不触发；同一轮回合每档最多弹一次；多 session 并行也只会有一个弹出，不会三连弹。

设计细节见 [DESIGN.md](./DESIGN.md)。

## 安装

在 Claude Code 里：

```
/plugin marketplace add https://github.com/<your-fork>/cc-gym
/plugin install cc-gym@cc-gym
```

本地开发或试用也可以指到本地路径：

```
/plugin marketplace add /path/to/cc-gym
/plugin install cc-gym@cc-gym
```

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
| `CC_GYM_GLOBAL_COOLDOWN` | = 轻档阈值 | 多 session 并行时两次弹窗的最短间隔 |
| `CC_GYM_LIGHT_FILE` | 内置 | 自定义轻档动作清单文件 |
| `CC_GYM_HEAVY_FILE` | 内置 | 自定义重档动作清单文件 |

动作清单格式：每行 `category: 动作描述`，`category ∈ {eye, neck, leg, breath}`，`#` 开头为注释。

## 手动测试

插件装好后可以直接调 `nudge.sh` 验证：

```bash
PLUGIN=~/.claude/plugins/cache/cc-gym        # 或你本地 clone 的 plugins/cc-gym
CLAUDE_PLUGIN_ROOT=$PLUGIN \
  bash -c '
    SID=$(printf "{\"session_id\":\"t\"}")
    echo "$SID" | "$PLUGIN/bin/nudge.sh" prompt
    echo $(( $(date +%s) - 25 )) > "${TMPDIR:-/tmp}/cc-gym-t.start"
    echo "$SID" | "$PLUGIN/bin/nudge.sh" pre     # 应该弹轻档通知
    echo "$SID" | "$PLUGIN/bin/nudge.sh" stop
  '
```
