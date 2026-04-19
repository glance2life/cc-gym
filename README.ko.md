# cc-gym

[English](README.md) | [简体中文](README.zh.md) | [日本語](README.ja.md) | [Español](README.es.md) | [Français](README.fr.md) | [Deutsch](README.de.md) | [Português](README.pt.md) | [Русский](README.ru.md) | 한국어 | [العربية](README.ar.md)

Claude Code가 작업 중일 때, cc-gym이 "화면 멍하니 보기"에서 당신을 끄집어내 30초짜리 미니 운동을 시킵니다.

설계 메모: [DESIGN.md](./DESIGN.md) (중국어).

## 설치

Claude Code 안에서:

```
/plugin marketplace add glance2life/cc-gym
/plugin install cc-gym@cc-gym
```

(`marketplace add`는 `owner/repo` 단축형을 받아들입니다. 전체 URL `https://github.com/glance2life/cc-gym`도 됩니다. **포크 불필요** — 읽기 전용 가져오기입니다.)

설치 후 재시작하거나 `/reload-plugins`를 실행해 훅을 적용하세요.

## 업데이트 / 제거

Claude Code는 새 버전을 자동으로 가져오지 않습니다. 수동 두 단계:

```
/plugin marketplace update cc-gym     # 마켓플레이스 최신 커밋 가져오기
/plugin update cc-gym@cc-gym          # 플러그인 본체 업데이트
```

이후 재시작 또는 `/reload-plugins`. 제거:

```
/plugin uninstall cc-gym@cc-gym
```

## 설정

모든 설정은 환경 변수입니다. GUI는 없습니다. 기본값으로 충분하며, 필요할 때만 조정하세요:

| 환경 변수 | 기본값 | 역할 |
|---|---|---|
| `CC_GYM_LIGHT_SEC` | `20` | 첫 (가벼운) 알림까지의 초 |
| `CC_GYM_HEAVY_SEC` | `180` | 강한 알림으로 올라가기까지의 초 |
| `CC_GYM_GLOBAL_COOLDOWN` | `900` (15분) | 모든 세션을 통틀어 두 알림 사이 최소 간격 |
| `CC_GYM_LANG` | `$LANG`에서 자동 | UI 언어. 지원: `en`, `zh`, `es`, `ja`, `fr`, `de`, `pt`, `ru`, `ko`, `ar`. 알 수 없는 값은 `en`으로 회귀 |
| `CC_GYM_LIGHT_FILE` | 내장 (언어별) | 가벼운 동작 목록 사용자화 |
| `CC_GYM_HEAVY_FILE` | 내장 (언어별) | 강한 동작 목록 사용자화 |

목록 형식: 한 줄에 하나, `category: 동작`, `category ∈ {eye, neck, leg, breath}`, `#`로 시작하면 주석.
