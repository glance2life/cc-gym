# cc-gym

English | [简体中文](README.zh.md) | [日本語](README.ja.md) | [Español](README.es.md) | [Français](README.fr.md) | [Deutsch](README.de.md) | [Português](README.pt.md) | [Русский](README.ru.md) | [한국어](README.ko.md) | [العربية](README.ar.md)

While Claude Code is busy working, cc-gym pulls you out of "staring blankly at the screen" and into a 30-second mini-workout.

Design notes: [DESIGN.md](./DESIGN.md) (in Chinese).

## Install

Inside Claude Code:

```
/plugin marketplace add glance2life/cc-gym
/plugin install cc-gym@cc-gym
```

(`marketplace add` accepts the `owner/repo` shorthand; the full `https://github.com/glance2life/cc-gym` URL also works. **No fork needed** — this is a read-only pull.)

After install, restart or run `/reload-plugins` so the hooks take effect.

## Update / Uninstall

Claude Code does not auto-pull new versions. Two manual steps:

```
/plugin marketplace update cc-gym     # pull the latest marketplace commit
/plugin update cc-gym@cc-gym          # update the plugin itself
```

Then restart or run `/reload-plugins`. Uninstall:

```
/plugin uninstall cc-gym@cc-gym
```

## Configuration

Everything is environment variables — no GUI. Defaults are sensible; tweak only what you need:

| Env var | Default | Purpose |
|---|---|---|
| `CC_GYM_LIGHT_SEC` | `20` | Seconds before the first (light) nudge |
| `CC_GYM_HEAVY_SEC` | `180` | Seconds before escalating to a heavy nudge |
| `CC_GYM_GLOBAL_COOLDOWN` | `900` (15 min) | Minimum seconds between two notifications across sessions — keeps the cadence sane |
| `CC_GYM_LANG` | auto from `$LANG` | UI language. Supported: `en`, `zh`, `es`, `ja`, `fr`, `de`, `pt`, `ru`, `ko`, `ar`. Unknown values fall back to `en` |
| `CC_GYM_LIGHT_FILE` | built-in (per language) | Custom light-tier exercise list |
| `CC_GYM_HEAVY_FILE` | built-in (per language) | Custom heavy-tier exercise list |

Exercise list format: one line per item, `category: action`, `category ∈ {eye, neck, leg, breath}`, lines starting with `#` are comments.
