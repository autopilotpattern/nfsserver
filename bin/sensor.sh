#!/bin/bash
set -e

help() {
    echo 'Uses cli tools free and top to determine current CPU and memory usage'
    echo 'for the telemetry service.'
}

# disk usage in percent
sys_disk() {
    (>&2 echo "sys disk check fired")
    local diskpercent=$(df -h -P /exports | awk 'NR==2 {print $5/1}')
    echo ${diskpercent}
}

cmd=$1
if [ ! -z "$cmd" ]; then
    shift 1
    $cmd "$@"
    exit
fi

help
