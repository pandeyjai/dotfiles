#!/bin/bash
# fix-interlaced - universal: if any output on interlaced, switch to same res progressive at max rate
for out in $(xrandr --query 2>/dev/null | grep " connected" | awk '{print $1}'); do
  cur=$(xrandr --query 2>/dev/null | awk -v o="$out" '$1==o{getline; while($1!~/connected/ && NF){if($0 ~ /\*/){print; exit} getline}}' 2>/dev/null)
  if echo "$cur" | grep -q "i"; then
    res=$(echo "$cur" | grep -o "[0-9]\+x[0-9]\+i" | sed 's/i//')
    [ -z "$res" ] && res=$(echo "$cur" | awk '{print $1}' | sed 's/i//')
    # find best progressive rate for this res (max Hz, not interlaced)
    best=$(xrandr --query 2>/dev/null | awk -v o="$out" -v r="$res" '
      $1==o{found=1; next}
      found && /connected/{exit}
      found && $1==r{for(i=2;i<=NF;i++){if($i !~ /i/){gsub(/[*+]/,"",$i); print $i}}}
    ' | sort -nr | head -1)
    [ -z "$best" ] && best="60"
    xrandr --output "$out" --mode "$res" --rate "$best" 2>/dev/null || xrandr --output "$out" --mode "$res" 2>/dev/null || xrandr --output "$out" --preferred 2>/dev/null || true
  fi
done
