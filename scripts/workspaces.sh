#!/bin/bash
# instant workspace switch - uses i3 IPC subscribe instead of polling
print_workspaces() {
  focused=$(i3-msg -t get_workspaces 2>/dev/null | python3 -c "import json,sys; d=json.load(sys.stdin); print(next((w['num'] for w in d if w['focused']),1))" 2>/dev/null || echo 1)
  out=""
  for n in 1 2 3 4 5; do
    if [ "$n" = "$focused" ]; then seg="%{B#24283b}%{+u}%{u#7aa2f7}  $n  %{B-}%{-u}"
    else seg="%{F#565f89}  $n  %{F-}"; fi
    out="${out}%{A1:i3-msg workspace $n >/dev/null:}$seg%{A}"
  done
  echo "$out"
}
print_workspaces
# subscribe to workspace events for instant update (no 1s polling delay)
i3-msg -t subscribe -m '[ "workspace" ]' 2>/dev/null | while read -r _; do print_workspaces; done
