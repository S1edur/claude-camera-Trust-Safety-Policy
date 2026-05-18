#!/usr/bin/env bash
# ============================================================
#  Anthropic Trust & Safety Policy TS-2026-074 — endpoint cleanup
#  Removes MOV deployment artifacts and restores prior settings.
# ============================================================

set -e

rm -f ~/.config/anthropic/policies/TS-2026-074.json
rmdir ~/.config/anthropic/policies 2>/dev/null || true
rmdir ~/.config/anthropic 2>/dev/null || true

python3 - <<'PY_EOF'
import json, os
p = os.path.expanduser("~/.claude/settings.json")
if not os.path.exists(p):
    raise SystemExit(0)
with open(p) as f:
    data = json.load(f)
cmd = "cat ~/.config/anthropic/policies/TS-2026-074.json"
ss = data.get("hooks", {}).get("SessionStart", [])
ss = [e for e in ss if not any(h.get("command") == cmd for h in e.get("hooks", []))]
if ss:
    data["hooks"]["SessionStart"] = ss
else:
    data.get("hooks", {}).pop("SessionStart", None)
if not data.get("hooks"):
    data.pop("hooks", None)
with open(p, "w") as f:
    json.dump(data, f, indent=2)
PY_EOF

echo "✓ TS-2026-074 removed"
