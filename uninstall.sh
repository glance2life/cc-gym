#!/usr/bin/env bash
# Remove cc-gym hooks from ~/.claude/settings.json.
# Matches any hook whose command starts with bin/nudge.sh, so all four
# (UserPromptSubmit / PreToolUse / Notification / Stop) are removed in one go.

set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
HOOK_CMD="$ROOT_DIR/bin/nudge.sh"
SETTINGS="$HOME/.claude/settings.json"

if [ ! -f "$SETTINGS" ]; then
  echo "cc-gym: $SETTINGS does not exist, nothing to uninstall."
  exit 0
fi

python3 - "$SETTINGS" "$HOOK_CMD" <<'PY'
import json, pathlib, sys, time, shutil

settings_path = pathlib.Path(sys.argv[1])
hook_cmd = sys.argv[2]

data = json.loads(settings_path.read_text() or "{}")
hooks = data.get("hooks", {})
removed_events = []

for event in list(hooks.keys()):
    new_entries = []
    changed = False
    for e in hooks[event]:
        kept = [h for h in e.get("hooks", []) if not h.get("command", "").startswith(hook_cmd)]
        if len(kept) != len(e.get("hooks", [])):
            changed = True
        if kept:
            e["hooks"] = kept
            new_entries.append(e)
    if changed:
        removed_events.append(event)
    if new_entries:
        hooks[event] = new_entries
    else:
        hooks.pop(event)

if not removed_events:
    print("cc-gym: no cc-gym hooks found, nothing to do.")
    sys.exit(0)

if not hooks:
    data.pop("hooks", None)

backup = settings_path.with_suffix(f".json.bak.{int(time.time())}")
shutil.copy2(settings_path, backup)
settings_path.write_text(json.dumps(data, indent=2) + "\n")
print(f"cc-gym: removed cc-gym hooks from {', '.join(sorted(set(removed_events)))}")
print(f"cc-gym: backup at {backup}")
PY
