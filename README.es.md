# cc-gym

[English](README.md) | [简体中文](README.zh.md) | [日本語](README.ja.md) | Español | [Français](README.fr.md) | [Deutsch](README.de.md) | [Português](README.pt.md) | [Русский](README.ru.md) | [한국어](README.ko.md) | [العربية](README.ar.md)

Mientras Claude Code está trabajando, cc-gym te saca de la "mirada perdida en la pantalla" y te empuja a hacer un mini-ejercicio de 30 segundos.

Notas de diseño: [DESIGN.md](./DESIGN.md) (en chino).

## Instalación

Dentro de Claude Code:

```
/plugin marketplace add glance2life/cc-gym
/plugin install cc-gym@cc-gym
```

(`marketplace add` acepta el formato `owner/repo`; también vale la URL completa `https://github.com/glance2life/cc-gym`. **No hace falta fork**: es una descarga de solo lectura.)

Tras instalar, reinicia o ejecuta `/reload-plugins` para que los hooks tomen efecto.

## Actualizar / Desinstalar

Claude Code no descarga nuevas versiones automáticamente. Dos pasos manuales:

```
/plugin marketplace update cc-gym     # trae el commit más reciente del marketplace
/plugin update cc-gym@cc-gym          # actualiza el plugin
```

Luego reinicia o ejecuta `/reload-plugins`. Desinstalar:

```
/plugin uninstall cc-gym@cc-gym
```

## Configuración

Todo se configura por variables de entorno; no hay GUI. Los valores por defecto son razonables, ajusta solo lo necesario:

| Variable | Por defecto | Función |
|---|---|---|
| `CC_GYM_LIGHT_SEC` | `20` | Segundos antes del primer aviso (ligero) |
| `CC_GYM_HEAVY_SEC` | `180` | Segundos antes de subir al aviso fuerte |
| `CC_GYM_GLOBAL_COOLDOWN` | `900` (15 min) | Intervalo mínimo entre dos avisos en todas las sesiones |
| `CC_GYM_LANG` | auto desde `$LANG` | Idioma de la interfaz. Soportados: `en`, `zh`, `es`, `ja`, `fr`, `de`, `pt`, `ru`, `ko`, `ar`. Valores desconocidos vuelven a `en` |
| `CC_GYM_LIGHT_FILE` | integrado (por idioma) | Lista personalizada de ejercicios ligeros |
| `CC_GYM_HEAVY_FILE` | integrado (por idioma) | Lista personalizada de ejercicios fuertes |

Formato de la lista: una línea por ítem, `category: acción`, `category ∈ {eye, neck, leg, breath}`, las líneas que empiezan por `#` son comentarios.
