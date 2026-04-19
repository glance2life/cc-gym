# cc-gym

[English](README.md) | [简体中文](README.zh.md) | [日本語](README.ja.md) | [Español](README.es.md) | [Français](README.fr.md) | Deutsch | [Português](README.pt.md) | [Русский](README.ru.md) | [한국어](README.ko.md) | [العربية](README.ar.md)

Während Claude Code arbeitet, holt dich cc-gym aus dem „Auf-den-Bildschirm-Starren" raus und schiebt dir eine 30-Sekunden-Mini-Übung unter.

Designnotizen: [DESIGN.md](./DESIGN.md) (auf Chinesisch).

## Installation

In Claude Code:

```
/plugin marketplace add glance2life/cc-gym
/plugin install cc-gym@cc-gym
```

(`marketplace add` akzeptiert die `owner/repo`-Kurzform; die volle URL `https://github.com/glance2life/cc-gym` geht auch. **Kein Fork nötig** — das ist nur ein Lesezugriff.)

Nach der Installation neu starten oder `/reload-plugins` ausführen, damit die Hooks greifen.

## Aktualisieren / Deinstallieren

Claude Code zieht neue Versionen nicht automatisch. Zwei manuelle Schritte:

```
/plugin marketplace update cc-gym     # neuesten Marketplace-Commit holen
/plugin update cc-gym@cc-gym          # das Plugin selbst aktualisieren
```

Danach neu starten oder `/reload-plugins`. Deinstallieren:

```
/plugin uninstall cc-gym@cc-gym
```

## Konfiguration

Alles läuft über Umgebungsvariablen, keine GUI. Die Defaults sind brauchbar, nur ändern, wenn nötig:

| Variable | Default | Funktion |
|---|---|---|
| `CC_GYM_LIGHT_SEC` | `20` | Sekunden bis zur ersten (leichten) Erinnerung |
| `CC_GYM_HEAVY_SEC` | `180` | Sekunden bis zur Eskalation auf die schwere Erinnerung |
| `CC_GYM_GLOBAL_COOLDOWN` | `900` (15 min) | Mindestabstand zwischen zwei Hinweisen über alle Sessions hinweg |
| `CC_GYM_LANG` | automatisch aus `$LANG` | UI-Sprache. Unterstützt: `en`, `zh`, `es`, `ja`, `fr`, `de`, `pt`, `ru`, `ko`, `ar`. Unbekannte Werte fallen auf `en` zurück |
| `CC_GYM_LIGHT_FILE` | eingebaut (pro Sprache) | Eigene Liste leichter Übungen |
| `CC_GYM_HEAVY_FILE` | eingebaut (pro Sprache) | Eigene Liste schwerer Übungen |

Listenformat: ein Eintrag pro Zeile, `category: Übung`, `category ∈ {eye, neck, leg, breath}`, Zeilen mit `#` sind Kommentare.
