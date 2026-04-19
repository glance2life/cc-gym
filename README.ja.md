# cc-gym

[English](README.md) | [简体中文](README.zh.md) | 日本語 | [Español](README.es.md) | [Français](README.fr.md) | [Deutsch](README.de.md) | [Português](README.pt.md) | [Русский](README.ru.md) | [한국어](README.ko.md) | [العربية](README.ar.md)

Claude Code が作業中に、cc-gym があなたを「画面を呆然と眺める」状態から引っ張り出して、30 秒のミニ運動に誘います。

設計メモ：[DESIGN.md](./DESIGN.md)（中国語）。

## インストール

Claude Code 内で：

```
/plugin marketplace add glance2life/cc-gym
/plugin install cc-gym@cc-gym
```

（`marketplace add` は `owner/repo` 形式を受け付けます。`https://github.com/glance2life/cc-gym` のフル URL でも可。**fork 不要**、読み取り専用の取得です。）

インストール後、再起動するか `/reload-plugins` でフックを有効化してください。

## アップデート / アンインストール

Claude Code は自動で新バージョンを取りに行きません。手動で 2 ステップ：

```
/plugin marketplace update cc-gym     # marketplace の最新コミットを取得
/plugin update cc-gym@cc-gym          # プラグイン本体を更新
```

その後、再起動か `/reload-plugins`。アンインストール：

```
/plugin uninstall cc-gym@cc-gym
```

## 設定

設定はすべて環境変数で、GUI はありません。既定値でだいたい十分、必要なら調整：

| 環境変数 | 既定値 | 意味 |
|---|---|---|
| `CC_GYM_LIGHT_SEC` | `20` | 何秒後に最初の（軽め）通知を出すか |
| `CC_GYM_HEAVY_SEC` | `180` | 何秒後に重め通知に切り替えるか |
| `CC_GYM_GLOBAL_COOLDOWN` | `900`（15 分） | セッション横断での通知間隔の下限。荒れすぎ防止 |
| `CC_GYM_LANG` | 既定で `$LANG` から推測 | UI 言語。対応：`en`、`zh`、`es`、`ja`、`fr`、`de`、`pt`、`ru`、`ko`、`ar`。未知なら `en` に戻る |
| `CC_GYM_LIGHT_FILE` | 内蔵（言語ごと） | 軽めの動作リストを差し替え |
| `CC_GYM_HEAVY_FILE` | 内蔵（言語ごと） | 重めの動作リストを差し替え |

動作リストの形式：1 行 1 項目、`category: 動作`、`category ∈ {eye, neck, leg, breath}`、`#` から始まる行はコメント。
