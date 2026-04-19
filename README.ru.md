# cc-gym

[English](README.md) | [简体中文](README.zh.md) | [日本語](README.ja.md) | [Español](README.es.md) | [Français](README.fr.md) | [Deutsch](README.de.md) | [Português](README.pt.md) | Русский | [한국어](README.ko.md) | [العربية](README.ar.md)

Пока Claude Code занят работой, cc-gym вытаскивает тебя из «тупого пялинья в экран» и подсовывает 30-секундную мини-разминку.

Заметки по дизайну: [DESIGN.md](./DESIGN.md) (на китайском).

## Установка

В Claude Code:

```
/plugin marketplace add glance2life/cc-gym
/plugin install cc-gym@cc-gym
```

(`marketplace add` понимает короткую форму `owner/repo`; полный URL `https://github.com/glance2life/cc-gym` тоже работает. **Форк не нужен** — это read-only клон.)

После установки перезапусти или выполни `/reload-plugins`, чтобы хуки заработали.

## Обновление / Удаление

Claude Code не подтягивает новые версии автоматически. Два ручных шага:

```
/plugin marketplace update cc-gym     # тянем свежий коммит marketplace
/plugin update cc-gym@cc-gym          # обновляем сам плагин
```

Затем перезапуск или `/reload-plugins`. Удаление:

```
/plugin uninstall cc-gym@cc-gym
```

## Конфигурация

Всё настраивается переменными окружения, GUI нет. Дефолты разумные, трогай только то, что нужно:

| Переменная | По умолчанию | Что делает |
|---|---|---|
| `CC_GYM_LIGHT_SEC` | `20` | Через сколько секунд первое (лёгкое) напоминание |
| `CC_GYM_HEAVY_SEC` | `180` | Через сколько секунд эскалация до тяжёлого напоминания |
| `CC_GYM_GLOBAL_COOLDOWN` | `900` (15 мин) | Минимальный интервал между уведомлениями по всем сессиям |
| `CC_GYM_LANG` | авто из `$LANG` | Язык интерфейса. Поддерживаются: `en`, `zh`, `es`, `ja`, `fr`, `de`, `pt`, `ru`, `ko`, `ar`. Неизвестные значения откатываются на `en` |
| `CC_GYM_LIGHT_FILE` | встроенный (по языку) | Свой список лёгких упражнений |
| `CC_GYM_HEAVY_FILE` | встроенный (по языку) | Свой список тяжёлых упражнений |

Формат списка: одна строка — один пункт, `category: действие`, `category ∈ {eye, neck, leg, breath}`, строки с `#` — комментарии.
