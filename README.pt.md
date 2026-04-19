# cc-gym

[English](README.md) | [简体中文](README.zh.md) | [日本語](README.ja.md) | [Español](README.es.md) | [Français](README.fr.md) | [Deutsch](README.de.md) | Português | [Русский](README.ru.md) | [한국어](README.ko.md) | [العربية](README.ar.md)

Enquanto o Claude Code está trabalhando, o cc-gym te tira do "olhar parado para a tela" e te empurra para um mini-exercício de 30 segundos.

Notas de design: [DESIGN.md](./DESIGN.md) (em chinês).

## Instalação

Dentro do Claude Code:

```
/plugin marketplace add glance2life/cc-gym
/plugin install cc-gym@cc-gym
```

(`marketplace add` aceita o formato `owner/repo`; a URL completa `https://github.com/glance2life/cc-gym` também funciona. **Sem necessidade de fork** — é leitura apenas.)

Após instalar, reinicie ou rode `/reload-plugins` para os hooks valerem.

## Atualizar / Desinstalar

O Claude Code não puxa novas versões automaticamente. Dois passos manuais:

```
/plugin marketplace update cc-gym     # puxa o commit mais recente do marketplace
/plugin update cc-gym@cc-gym          # atualiza o plugin
```

Depois reinicie ou rode `/reload-plugins`. Desinstalar:

```
/plugin uninstall cc-gym@cc-gym
```

## Configuração

Tudo é configurado por variáveis de ambiente; não há GUI. Os padrões são razoáveis, ajuste apenas o necessário:

| Variável | Padrão | Função |
|---|---|---|
| `CC_GYM_LIGHT_SEC` | `20` | Segundos até o primeiro aviso (leve) |
| `CC_GYM_HEAVY_SEC` | `180` | Segundos até subir para o aviso pesado |
| `CC_GYM_GLOBAL_COOLDOWN` | `900` (15 min) | Intervalo mínimo entre dois avisos somando todas as sessões |
| `CC_GYM_LANG` | automático a partir de `$LANG` | Idioma da interface. Suportados: `en`, `zh`, `es`, `ja`, `fr`, `de`, `pt`, `ru`, `ko`, `ar`. Valores desconhecidos voltam para `en` |
| `CC_GYM_LIGHT_FILE` | embutido (por idioma) | Lista personalizada de exercícios leves |
| `CC_GYM_HEAVY_FILE` | embutido (por idioma) | Lista personalizada de exercícios pesados |

Formato da lista: uma linha por item, `category: ação`, `category ∈ {eye, neck, leg, breath}`, linhas começando com `#` são comentários.
