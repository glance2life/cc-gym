# cc-gym

[English](README.md) | [简体中文](README.zh.md) | [日本語](README.ja.md) | [Español](README.es.md) | Français | [Deutsch](README.de.md) | [Português](README.pt.md) | [Русский](README.ru.md) | [한국어](README.ko.md) | [العربية](README.ar.md)

Pendant que Claude Code travaille, cc-gym te sort du « regard fixe sur l'écran » et te pousse à faire un mini-exercice de 30 secondes.

Notes de conception : [DESIGN.md](./DESIGN.md) (en chinois).

## Installation

Dans Claude Code :

```
/plugin marketplace add glance2life/cc-gym
/plugin install cc-gym@cc-gym
```

(`marketplace add` accepte la forme `owner/repo` ; l'URL complète `https://github.com/glance2life/cc-gym` marche aussi. **Pas besoin de fork** — c'est une récupération en lecture seule.)

Après installation, redémarre ou lance `/reload-plugins` pour activer les hooks.

## Mise à jour / Désinstallation

Claude Code ne tire pas les nouvelles versions automatiquement. Deux étapes manuelles :

```
/plugin marketplace update cc-gym     # récupère le dernier commit du marketplace
/plugin update cc-gym@cc-gym          # met à jour le plugin
```

Puis redémarre ou lance `/reload-plugins`. Désinstaller :

```
/plugin uninstall cc-gym@cc-gym
```

## Configuration

Tout passe par des variables d'environnement, pas de GUI. Les valeurs par défaut sont raisonnables, ajuste seulement le nécessaire :

| Variable | Défaut | Rôle |
|---|---|---|
| `CC_GYM_LIGHT_SEC` | `20` | Secondes avant la première alerte (légère) |
| `CC_GYM_HEAVY_SEC` | `180` | Secondes avant de passer à l'alerte forte |
| `CC_GYM_GLOBAL_COOLDOWN` | `900` (15 min) | Intervalle minimal entre deux notifications, toutes sessions confondues |
| `CC_GYM_LANG` | auto depuis `$LANG` | Langue de l'interface. Supportées : `en`, `zh`, `es`, `ja`, `fr`, `de`, `pt`, `ru`, `ko`, `ar`. Valeurs inconnues retombent sur `en` |
| `CC_GYM_LIGHT_FILE` | intégré (par langue) | Liste d'exercices légers personnalisée |
| `CC_GYM_HEAVY_FILE` | intégré (par langue) | Liste d'exercices forts personnalisée |

Format de la liste : une ligne par entrée, `category: action`, `category ∈ {eye, neck, leg, breath}`, les lignes commençant par `#` sont des commentaires.
