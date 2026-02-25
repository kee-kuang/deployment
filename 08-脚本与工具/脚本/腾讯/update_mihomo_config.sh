#!/usr/bin/env bash
set -euo pipefail

URL="https://dler.cloud/api/v3/download.getFile/30623758-ed2b-4dbc-9eaf-c63063c96a13?clash=smart&lv=2.wav"
CFG="/etc/mihomo/config.yaml"
BAK_DIR="/etc/mihomo/bak"
TS=$(date +%F_%H%M)
SERVICE="mihomo"

/bin/mkdir -p "$BAK_DIR"

if [ -f "$CFG" ]; then
  cp "$CFG" "$BAK_DIR/config.yaml.$TS.bak"
fi

/usr/bin/curl -fsSL "$URL" -o "$CFG.tmp"
/bin/mv "$CFG.tmp" "$CFG"
sed -i 's/^[[:space:]]*allow-lan:[[:space:]]*false/allow-lan: true/' "$CFG"

/bin/systemctl restart "$SERVICE"