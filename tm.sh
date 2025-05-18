#!/bin/bash

LOG="/var/log/monitoring.log"
URL="https://test.com/monitoring/test/api"
PROCESS="test"
PID="/tmp/tm_pid"

if [ ! -f "$LOG" ]; then
    touch "$LOG"
    chmod 644 "$LOG"
fi

log_message() {
    echo "$(date '+%Y-%m-%d %H:%M:%S') - $1" >> "$LOG"
}

check_process() {
    pgrep -x "$PROCESS" > /dev/null
    return $?
}

get_process_pid() {
    pgrep -x "$PROCESS"
}


if [ -f "$PID" ]; then
    PREV_PID=$(cat "$PID")
else
    PREV_PID=0
fi

if check_process; then
    CURRENT_PID=$(get_process_pid)
    
    if [ -n "$PREV_PID" ] && [ "$PREV_PID" -ne 0 ] && [ "$PREV_PID" -ne "$CURRENT_PID" ]; then
        log_message "Процесс $PROCESS был перезапущен. Новый PID: $CURRENT_PID, Предыдущий PID: $PREV_PID"
    fi
    
    echo "$CURRENT_PID" > "$PID"
    
    HTTP_RESPONSE=$(curl -s -o /dev/null -w "%{http_code}" "$URL" --connect-timeout 5 --max-time 10)
    
    if [ "$HTTP_RESPONSE" != "200" ]; then
        log_message "Ошибка при обращении к серверу мониторинга. Код ответа: $HTTP_RESPONSE"
    fi
else
    echo "0" > "$PID"
fi

exit 0
