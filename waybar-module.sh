#!/bin/bash
TIME_FILE="/tmp/typelight-time"
COUNT_FILE="/tmp/typelight-count"
POS_FILE="/tmp/typelight-pos"
COLOR_FILE="/tmp/typelight-color"

[ ! -f "$COUNT_FILE" ] && echo 0 > "$COUNT_FILE"
[ ! -f "$POS_FILE" ] && echo 0 > "$POS_FILE"
[ ! -f "$TIME_FILE" ] && echo 0 > "$TIME_FILE"
[ ! -f "$COLOR_FILE" ] && echo 0 > "$COLOR_FILE"

NUM_COLORS=64

while true; do
    count=$(cat "$COUNT_FILE" 2>/dev/null || echo 0)
    pos=$(cat "$POS_FILE" 2>/dev/null || echo 0)
    last=$(cat "$TIME_FILE" 2>/dev/null || echo 0)
    color_idx=$(cat "$COLOR_FILE" 2>/dev/null || echo 0)
    now=$(date +%s%N)

    pos=$((pos % 3))
    case $pos in 0) pattern="● ○ ○"; ;; 1) pattern="○ ● ○"; ;; 2) pattern="○ ○ ●"; ;; esac

    if [ "$last" != "0" ]; then
        diff=$(( (now - last) / 1000000 ))
        if [ "$diff" -lt 100 ]; then
            # 打字时：实心方框 + 彩色（只读取，不自增）
            color_idx=$((color_idx % NUM_COLORS))
            printf '{"text":"■  %d  %s","class":"c%d"}\n' "$count" "$pattern" "$color_idx"
        else
            # 不打字：空心方框 + 灰色
            printf '{"text":"□  %d  %s","class":"idle"}\n' "$count" "$pattern"
        fi
    else
        printf '{"text":"□  %d  %s","class":"idle"}\n' "$count" "$pattern"
    fi

    sleep 0.03
done