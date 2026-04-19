#!/usr/bin/env bash
# cc-gym nudge hook — two-tier busy-time notifier.
# Called by Claude Code hooks with one of these event args:
#   prompt  (UserPromptSubmit) — mark busy_start, clear flags
#   pre     (PreToolUse)       — check elapsed, maybe notify
#   notify  (Notification)     — CC waiting on user (permission/idle); pause timer
#   stop    (Stop)             — clear all state
#
# State is per-session, scoped by session_id read from stdin JSON.
# Must exit 0 quickly. Notifications fire in background.

set -u

event="${1:-}"

if [ -n "${CLAUDE_PLUGIN_ROOT:-}" ]; then
  ROOT_DIR="$CLAUDE_PLUGIN_ROOT"
else
  SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
  ROOT_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"
fi

# Resolve UI language: CC_GYM_LANG > $LC_ALL > $LANG > 'en'.
# Strips encoding/region (fr_FR.UTF-8 -> fr, zh-CN -> zh, C/POSIX -> en).
resolve_lang() {
  local raw code
  raw="${CC_GYM_LANG:-${LC_ALL:-${LANG:-}}}"
  code="${raw%%[._@]*}"
  code="${code%%-*}"
  code="$(printf '%s' "$code" | tr '[:upper:]' '[:lower:]')"
  case "$code" in
    en|zh|es|ja|fr|de|pt|ru|ko|ar) printf '%s' "$code" ;;
    *)                             printf 'en' ;;
  esac
}
CC_GYM_LANG_RESOLVED="$(resolve_lang)"

# Hardcoded notification-fallback strings, keyed by lang:slot.
i18n_text() {
  case "${CC_GYM_LANG_RESOLVED}:$1" in
    en:light_title) printf 'cc-gym 🧘 Stretch';;
    en:light_body)  printf 'Roll your neck, take 5 deep breaths';;
    en:heavy_title) printf 'cc-gym 💪 Move';;
    en:heavy_body)  printf 'Stand up, walk for 1-2 minutes, step away from the screen';;
    zh:light_title) printf 'cc-gym 🧘 小动一下';;
    zh:light_body)  printf '转转脖子，深呼吸 5 次';;
    zh:heavy_title) printf 'cc-gym 💪 起来动动';;
    zh:heavy_body)  printf '起身走动 1-2 分钟，离开屏幕';;
    es:light_title) printf 'cc-gym 🧘 Estírate';;
    es:light_body)  printf 'Gira el cuello y haz 5 respiraciones profundas';;
    es:heavy_title) printf 'cc-gym 💪 Muévete';;
    es:heavy_body)  printf 'Levántate, camina 1-2 minutos, aléjate de la pantalla';;
    ja:light_title) printf 'cc-gym 🧘 ひと伸び';;
    ja:light_body)  printf '首を回して、深呼吸を5回';;
    ja:heavy_title) printf 'cc-gym 💪 動こう';;
    ja:heavy_body)  printf '1〜2分席を立って歩こう。画面から離れて';;
    fr:light_title) printf 'cc-gym 🧘 Étire-toi';;
    fr:light_body)  printf 'Fais tourner ton cou et 5 respirations profondes';;
    fr:heavy_title) printf 'cc-gym 💪 Bouge';;
    fr:heavy_body)  printf "Lève-toi, marche 1-2 minutes, éloigne-toi de l'écran";;
    de:light_title) printf 'cc-gym 🧘 Strecken';;
    de:light_body)  printf 'Nacken kreisen, 5-mal tief durchatmen';;
    de:heavy_title) printf 'cc-gym 💪 Beweg dich';;
    de:heavy_body)  printf 'Aufstehen, 1-2 Minuten gehen, weg vom Bildschirm';;
    pt:light_title) printf 'cc-gym 🧘 Alongue-se';;
    pt:light_body)  printf 'Gire o pescoço e faça 5 respirações profundas';;
    pt:heavy_title) printf 'cc-gym 💪 Mexa-se';;
    pt:heavy_body)  printf 'Levante-se, caminhe 1-2 minutos, saia da tela';;
    ru:light_title) printf 'cc-gym 🧘 Разомнись';;
    ru:light_body)  printf 'Покрути шеей и сделай 5 глубоких вдохов';;
    ru:heavy_title) printf 'cc-gym 💪 Подвигайся';;
    ru:heavy_body)  printf 'Встань и походи 1-2 минуты, отойди от экрана';;
    ko:light_title) printf 'cc-gym 🧘 가볍게 풀기';;
    ko:light_body)  printf '목을 돌리고 심호흡 5회';;
    ko:heavy_title) printf 'cc-gym 💪 일어나서 움직이기';;
    ko:heavy_body)  printf '1~2분 자리에서 일어나 걷고 화면에서 벗어나세요';;
    ar:light_title) printf 'cc-gym 🧘 تمدّد';;
    ar:light_body)  printf 'حرّك رقبتك وخذ 5 أنفاس عميقة';;
    ar:heavy_title) printf 'cc-gym 💪 تحرّك';;
    ar:heavy_body)  printf 'قف وامشِ دقيقة إلى دقيقتين، وابتعد عن الشاشة';;
  esac
}

# Pick the lang-specific exercise file, falling back to English if missing.
default_exercise_file() {
  local tier="$1"
  local path="$ROOT_DIR/lib/exercises.${tier}.${CC_GYM_LANG_RESOLVED}.txt"
  if [ -f "$path" ]; then printf '%s' "$path"
  else printf '%s' "$ROOT_DIR/lib/exercises.${tier}.en.txt"; fi
}

LIGHT_SEC="${CC_GYM_LIGHT_SEC:-20}"
HEAVY_SEC="${CC_GYM_HEAVY_SEC:-180}"
LIGHT_FILE="${CC_GYM_LIGHT_FILE:-$(default_exercise_file light)}"
HEAVY_FILE="${CC_GYM_HEAVY_FILE:-$(default_exercise_file heavy)}"
STATE_DIR="${CC_GYM_STATE_DIR:-${TMPDIR:-/tmp}}"
# Minimum seconds between any two notifications across ALL parallel sessions.
# Default 15 min: anti-sedentary cadence that stays out of the way when many
# sessions run in parallel. Lower it if you want more frequent nudges.
GLOBAL_COOLDOWN="${CC_GYM_GLOBAL_COOLDOWN:-900}"

payload="$(cat 2>/dev/null || true)"
sid="$(printf '%s' "$payload" | jq -r '.session_id // "default"' 2>/dev/null || echo default)"
[ -z "$sid" ] && sid="default"

base="$STATE_DIR/cc-gym-${sid}"
start_file="${base}.start"
light_flag="${base}.light"
heavy_flag="${base}.heavy"
pause_file="${base}.pause"
lastcat_file="${base}.lastcat"

# Global (cross-session) coordination files.
global_last_file="$STATE_DIR/cc-gym-global.last"
global_lock_dir="$STATE_DIR/cc-gym-global.lock"

# Try to claim the global fire slot. Returns 0 on success (records timestamp),
# 1 if another session fired recently or holds the lock.
try_global_fire() {
  local mtime age last now
  if ! mkdir "$global_lock_dir" 2>/dev/null; then
    # Lock held. If stale (>5s), force-release and retry once.
    mtime=$(stat -f %m "$global_lock_dir" 2>/dev/null \
            || stat -c %Y "$global_lock_dir" 2>/dev/null || echo 0)
    age=$(( $(date +%s) - mtime ))
    if [ "$age" -gt 5 ]; then
      rmdir "$global_lock_dir" 2>/dev/null
      mkdir "$global_lock_dir" 2>/dev/null || return 1
    else
      return 1
    fi
  fi
  last=$(cat "$global_last_file" 2>/dev/null || echo 0)
  now=$(date +%s)
  if [ $((now - last)) -lt "$GLOBAL_COOLDOWN" ]; then
    rmdir "$global_lock_dir" 2>/dev/null
    return 1
  fi
  echo "$now" > "$global_last_file"
  rmdir "$global_lock_dir" 2>/dev/null
  return 0
}

# If a pause is in progress, shift busy_start forward by the paused duration
# so elapsed excludes the wait. Safe to call when no pause is active.
resume_from_pause() {
  [ -f "$pause_file" ] || return 0
  local pstart now delta start
  pstart=$(cat "$pause_file" 2>/dev/null || echo 0)
  rm -f "$pause_file"
  [ "$pstart" -gt 0 ] 2>/dev/null || return 0
  now=$(date +%s)
  delta=$(( now - pstart ))
  [ "$delta" -gt 0 ] || return 0
  [ -f "$start_file" ] || return 0
  start=$(cat "$start_file" 2>/dev/null || echo 0)
  [ "$start" -gt 0 ] 2>/dev/null || return 0
  echo $(( start + delta )) > "$start_file"
}

pick_from() {
  local file="$1" last_cat="${2:-}"
  [ -f "$file" ] || return 1
  awk -v last="$last_cat" -v seed="$RANDOM$$" '
    BEGIN { srand(seed) }
    NF && !/^#/ {
      i = index($0, ":")
      if (i > 0) {
        cat = substr($0, 1, i-1)
        gsub(/^[ \t]+|[ \t]+$/, "", cat)
        text = substr($0, i+1)
        sub(/^[ \t]+/, "", text)
      } else {
        cat = "_"
        text = $0
      }
      n[cat]++
      items[cat SUBSEP n[cat]] = text
      if (!(cat in seen)) { seen[cat] = 1; cats[++nc] = cat }
    }
    END {
      if (nc == 0) exit 1
      # Build avail = cats minus last (unless it is the only category)
      na = 0
      for (j = 1; j <= nc; j++) if (cats[j] != last) avail[++na] = cats[j]
      if (na == 0) { for (j = 1; j <= nc; j++) avail[++na] = cats[j] }
      pick = avail[int(rand()*na) + 1]
      k = int(rand() * n[pick]) + 1
      printf "%s\t%s\n", pick, items[pick SUBSEP k]
    }
  ' "$file"
}

nudge_with() {
  local file="$1" title="$2" fallback="$3"
  # Coordinate across parallel sessions: only one notification within the
  # cooldown window. If suppressed, leave per-session lastcat untouched so the
  # rotation advances based on what the user actually saw.
  try_global_fire || return 0
  local last picked cat msg
  last=$(cat "$lastcat_file" 2>/dev/null || true)
  picked=$(pick_from "$file" "$last" 2>/dev/null || true)
  if [ -n "$picked" ]; then
    cat=${picked%%$'\t'*}
    msg=${picked#*$'\t'}
    printf '%s' "$cat" > "$lastcat_file"
  else
    msg="$fallback"
  fi
  notify "$title" "$msg"
}

notify() {
  local title="$1" msg="$2"
  (
    if command -v osascript >/dev/null 2>&1; then
      local safe=${msg//\"/\\\"}
      osascript -e "display notification \"$safe\" with title \"$title\" sound name \"Glass\"" >/dev/null 2>&1
    elif command -v notify-send >/dev/null 2>&1; then
      notify-send "$title" "$msg"
    else
      printf '\n[cc-gym] %s — %s\n' "$title" "$msg" >&2
    fi
  ) &
}

case "$event" in
  prompt)
    mkdir -p "$STATE_DIR"
    date +%s > "$start_file"
    rm -f "$light_flag" "$heavy_flag" "$pause_file"
    ;;
  stop)
    rm -f "$start_file" "$light_flag" "$heavy_flag" "$pause_file" "$lastcat_file"
    ;;
  notify)
    # CC is waiting on the user (permission prompt / idle). Mark pause start,
    # keeping the earliest timestamp if notifications repeat.
    [ -f "$start_file" ] || exit 0
    [ -f "$pause_file" ] || date +%s > "$pause_file"
    ;;
  pre)
    [ -f "$start_file" ] || exit 0
    resume_from_pause
    start=$(cat "$start_file" 2>/dev/null || echo 0)
    [ "$start" -gt 0 ] 2>/dev/null || exit 0
    now=$(date +%s)
    elapsed=$(( now - start ))

    if [ "$elapsed" -ge "$HEAVY_SEC" ] && [ ! -f "$heavy_flag" ]; then
      touch "$heavy_flag"
      nudge_with "$HEAVY_FILE" "$(i18n_text heavy_title)" "$(i18n_text heavy_body)"
    elif [ "$elapsed" -ge "$LIGHT_SEC" ] && [ ! -f "$light_flag" ]; then
      touch "$light_flag"
      nudge_with "$LIGHT_FILE" "$(i18n_text light_title)" "$(i18n_text light_body)"
    fi
    ;;
  *)
    # Unknown event; be silent, exit clean.
    ;;
esac

exit 0
