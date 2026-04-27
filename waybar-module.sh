#!/bin/bash
TIME_FILE="/tmp/typelight-time"
COUNT_FILE="$HOME/.cache/typelight-count"
POS_FILE="/tmp/typelight-pos"
COLOR_FILE="/tmp/typelight-color"

[ ! -f "$COUNT_FILE" ] && echo 0 > "$COUNT_FILE"
[ ! -f "$POS_FILE" ] && echo 0 > "$POS_FILE"
[ ! -f "$TIME_FILE" ] && echo 0 > "$TIME_FILE"
[ ! -f "$COLOR_FILE" ] && echo 0 > "$COLOR_FILE"

NUM_COLORS=64

while true; do
    # Use bash read builtin - no process spawn
    read -r count < "$COUNT_FILE" 2>/dev/null || count=0
    read -r pos < "$POS_FILE" 2>/dev/null || pos=0
    read -r last < "$TIME_FILE" 2>/dev/null || last=0
    read -r color_idx < "$COLOR_FILE" 2>/dev/null || color_idx=0

    # Use date for nanoseconds (matches main daemon format)
    now=$(date +%s%N)

    pos=$((pos % 3))
    case $pos in 0) pattern="● ○ ○"; ;; 1) pattern="○ ● ○"; ;; 2) pattern="○ ○ ●"; ;; esac

    color_idx=$((color_idx % NUM_COLORS))

    if [ "$last" != "0" ]; then
        diff=$(( (now - last) / 1000000 ))
        if [ "$diff" -lt 100 ]; then
            output=$(printf '{"text":"■  %d  %s","class":"t%d"}' "$count" "$pattern" "$color_idx")
        else
            output=$(printf '{"text":"□  %d  %s","class":"i%d"}' "$count" "$pattern" "$color_idx")
        fi
    else
        output=$(printf '{"text":"□  %d  %s","class":"i%d"}' "$count" "$pattern" "$color_idx")
    fi

    # Always output (Waybar handles updates)
    printf '%s\n' "$output"

    sleep 0.1
done