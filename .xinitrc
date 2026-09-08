if command -v xinput >/dev/null 2>&1; then
  xinput list --id-only 2>/dev/null | while read -r id; do
    xinput list-props "$id" 2>/dev/null | grep -q "libinput Tapping Enabled (" && xinput set-prop "$id" "libinput Tapping Enabled" 1 2>/dev/null || true
  done
fi
exec i3
