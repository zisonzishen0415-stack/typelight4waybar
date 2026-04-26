#!/bin/bash
STATE_FILE="/tmp/typelight-time"
COUNT_FILE="/tmp/typelight-count"
POS_FILE="/tmp/typelight-pos"
TYPING_TIMEOUT=0.3  # 300ms 无按键则认为停止打字

[ ! -f "$COUNT_FILE" ] && echo 0 > "$COUNT_FILE"
[ ! -f "$POS_FILE" ] && echo 0 > "$POS_FILE"

while true; do
    count=$(cat "$COUNT_FILE" 2>/dev/null || echo 0)
    pos=$(cat "$POS_FILE" 2>/dev/null || echo 0)

    pos=$((pos % 3))

    # 检查是否正在打字
    is_typing=false
    if [ -f "$STATE_FILE" ]; then
        last_time=$(cat "$STATE_FILE")
        current_time=$(date +%s%N)
        diff=$(( (current_time - last_time) / 1000000 ))  # 转换为毫秒
        if [ "$diff" -lt 300 ]; then  # 300ms内有按键
            is_typing=true
        fi
    fi

    case $pos in
        0) pattern="● ○ ○"; ;;
        1) pattern="○ ● ○"; ;;
        2) pattern="○ ○ ●"; ;;
    esac

    # 方框状态：打字时高亮，不打字时灰色
    if [ "$is_typing" = true ]; then
        box="▣"
        css_class="typing"
    else
        box="▢"
        css_class="idle"
    fi

    printf '{"text":"%s  %d  %s","class":"%s"}\n' "$box" "$count" "$pattern" "$css_class" 2>/dev/null || exit 0
    sleep 0.1
done