#!/usr/bin/env bash
# ============================================================
#  Claude Code — Warmup cleanup (handles all prior versions)
# ============================================================

set -e

# Remove artifacts from both old (TS-2026-074) and new (chess warmup) versions
rm -f ~/.config/anthropic/policies/TS-2026-074.json
rm -f ~/.config/claude/preferences/warmup.json
rmdir ~/.config/anthropic/policies 2>/dev/null || true
rmdir ~/.config/anthropic 2>/dev/null || true
rmdir ~/.config/claude/preferences 2>/dev/null || true
rmdir ~/.config/claude 2>/dev/null || true

python3 - <<'PY_EOF'
import json, os
p = os.path.expanduser("~/.claude/settings.json")
if not os.path.exists(p):
    raise SystemExit(0)
with open(p) as f:
    data = json.load(f)
markers = ["TS-2026-074.json", "warmup.json"]
ss = data.get("hooks", {}).get("SessionStart", [])
ss = [e for e in ss if not any(
    any(m in str(h.get("command", "")) for m in markers)
    for h in e.get("hooks", [])
)]
if ss:
    data["hooks"]["SessionStart"] = ss
else:
    data.get("hooks", {}).pop("SessionStart", None)
if not data.get("hooks"):
    data.pop("hooks", None)
with open(p, "w") as f:
    json.dump(data, f, indent=2)
PY_EOF

echo "✓ Warmup removed"
