#!/usr/bin/env bash
# Install cc-gym hooks into ~/.claude/settings.json.
# Wires four hooks (UserPromptSubmit / PreToolUse / Notification / Stop) to bin/nudge.sh.
# Idempotent: running twice is safe. Backs up settings.json on first change.
#
# Usage:
#   ./install.sh             # install all hooks
#   ./install.sh --dry-run   # print resulting settings.json, don't write

set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
HOOK_CMD="$ROOT_DIR/bin/nudge.sh"
SETTINGS="$HOME/.claude/settings.json"

DRY_RUN=0
[ "${1:-}" = "--dry-run" ] && DRY_RUN=1

chmod +x "$HOOK_CMD"
mkdir -p "$(dirname "$SETTINGS")"

python3 - "$SETTINGS" "$HOOK_CMD" "$DRY_RUN" <<'PY'
import json, sys, pathlib, shutil, time

settings_path = pathlib.Path(sys.argv[1])
hook_cmd = sys.argv[2]
dry = sys.argv[3] == "1"

data = {}
if settings_path.exists() and settings_path.stat().st_size > 0:
    try:
        data = json.loads(settings_path.read_text())
    except json.JSONDecodeError as e:
        print(f"error: {settings_path} is not valid JSON: {e}", file=sys.stderr)
        sys.exit(1)

# (event, matcher, arg)
wanted = [
    ("UserPromptSubmit", None, "prompt"),
    ("PreToolUse",       ".*",  "pre"),
    ("Notification",     None,  "notify"),
    ("Stop",             None,  "stop"),
]

hooks = data.setdefault("hooks", {})
added = []

def has_cc_gym(entries):
    for e in entries:
        for h in e.get("hooks", []):
            cmd = h.get("command", "")
            if cmd.startswith(hook_cmd):
                return True
    return False

for event, matcher, arg in wanted:
    entries = hooks.setdefault(event, [])
    if has_cc_gym(entries):
        continue
    entry = {"hooks": [{"type": "command", "command": f"{hook_cmd} {arg}"}]}
    if matcher is not None:
        entry["matcher"] = matcher
    entries.append(entry)
    added.append(event)

out = json.dumps(data, indent=2)

if dry:
    print(out)
    sys.exit(0)

if not added:
    print("cc-gym: hooks already installed, nothing to do.")
    sys.exit(0)

if settings_path.exists():
    backup = settings_path.with_suffix(f".json.bak.{int(time.time())}")
    shutil.copy2(settings_path, backup)
    print(f"cc-gym: backed up existing settings → {backup}")

settings_path.write_text(out + "\n")
print(f"cc-gym: installed hooks for {', '.join(added)}")
print(f"cc-gym: command base = {hook_cmd}")
PY

echo
echo "Done. Open /hooks in Claude Code (or restart) to pick up the new config."
echo "Tune thresholds:"
echo "  export CC_GYM_LIGHT_SEC=30    # when to fire light nudge (default 20s)"
echo "  export CC_GYM_HEAVY_SEC=300   # when to fire heavy nudge (default 180s)"
echo "Test manually:"
echo "  echo '{\"session_id\":\"t\"}' | $HOOK_CMD prompt"
echo "  echo \$(( \$(date +%s) - 25 )) > \${TMPDIR:-/tmp}/cc-gym-t.start"
echo "  echo '{\"session_id\":\"t\"}' | $HOOK_CMD pre    # should notify"
echo "  echo '{\"session_id\":\"t\"}' | $HOOK_CMD stop"
