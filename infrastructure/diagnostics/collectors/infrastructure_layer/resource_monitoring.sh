#!/bin/bash

# Importa funções de logging e utilitários
source "$(dirname "$0")/../../core/logger.sh"
source "$(dirname "$0")/../../core/utils.sh"

# Carrega configurações
CONFIG_FILE="$(dirname "$0")/config.json"
CPU_WARNING=$(jq -r '.thresholds.cpu_warning' "$CONFIG_FILE")
CPU_CRITICAL=$(jq -r '.thresholds.cpu_critical' "$CONFIG_FILE")
MEM_WARNING=$(jq -r '.thresholds.memory_warning' "$CONFIG_FILE")
MEM_CRITICAL=$(jq -r '.thresholds.memory_critical' "$CONFIG_FILE")
DISK_WARNING=$(jq -r '.thresholds.disk_warning' "$CONFIG_FILE")
DISK_CRITICAL=$(jq -r '.thresholds.disk_critical' "$CONFIG_FILE")

get_cpu_metrics() {
    local cpu_usage=$(top -bn1 | grep "Cpu(s)" | awk '{print $2}')
    local load_1min=$(uptime | awk -F'load average: ' '{print $2}' | cut -d, -f1)
    local cpu_cores=$(nproc)
    
    echo "{
        \"usage\": $cpu_usage,
        \"load_average\": $load_1min,
        \"cores\": $cpu_cores,
        \"status\": \"$(get_status $cpu_usage $CPU_WARNING $CPU_CRITICAL)\"
    }"
}

get_memory_metrics() {
    local total_mem=$(free -m | awk '/Mem:/ {print $2}')
    local used_mem=$(free -m | awk '/Mem:/ {print $3}')
    local mem_usage=$(awk "BEGIN {printf \"%.2f\", ($used_mem/$total_mem)*100}")
    
    echo "{
        \"total_mb\": $total_mem,
        \"used_mb\": $used_mem,
        \"usage_percent\": $mem_usage,
        \"status\": \"$(get_status $mem_usage $MEM_WARNING $MEM_CRITICAL)\"
    }"
}

get_disk_metrics() {
    local disk_data=()
    while IFS= read -r line; do
        local fs=$(echo "$line" | awk '{print $1}')
        local usage=$(echo "$line" | awk '{print $5}' | sed 's/%//')
        local mount=$(echo "$line" | awk '{print $6}')
        
        if [[ $usage -gt 0 ]]; then
            disk_data+=("{
                \"filesystem\": \"$fs\",
                \"mount_point\": \"$mount\",
                \"usage_percent\": $usage,
                \"status\": \"$(get_status $usage $DISK_WARNING $DISK_CRITICAL)\"
            }")
        fi
    done < <(df -h | grep -v '^Filesystem' | grep -v '^tmpfs')
    
    echo "[$(IFS=,; echo "${disk_data[*]}")]"
}

get_network_metrics() {
    local rx_bytes=$(cat /sys/class/net/[ew]*/statistics/rx_bytes 2>/dev/null | awk '{sum += $1} END {print sum}')
    local tx_bytes=$(cat /sys/class/net/[ew]*/statistics/tx_bytes 2>/dev/null | awk '{sum += $1} END {print sum}')
    
    echo "{
        \"rx_bytes\": $rx_bytes,
        \"tx_bytes\": $tx_bytes,
        \"active_connections\": $(ss -s | awk '/TCP:/ {print $2}')
    }"
}

get_status() {
    local value=$1
    local warning=$2
    local critical=$3
    
    if (( $(echo "$value >= $critical" | bc -l) )); then
        echo "CRITICAL"
    elif (( $(echo "$value >= $warning" | bc -l) )); then
        echo "WARNING"
    else
        echo "HEALTHY"
    fi
}

run_resource_monitoring() {
    local cpu_metrics=$(get_cpu_metrics)
    local memory_metrics=$(get_memory_metrics)
    local disk_metrics=$(get_disk_metrics)
    local network_metrics=$(get_network_metrics)
    
    # Determina status geral
    local cpu_status=$(echo "$cpu_metrics" | jq -r '.status')
    local mem_status=$(echo "$memory_metrics" | jq -r '.status')
    local disk_status=$(echo "$disk_metrics" | jq -r '[.[].status] | if contains(["CRITICAL"]) then "CRITICAL" elif contains(["WARNING"]) then "WARNING" else "HEALTHY" end')
    
    # Gera saída JSON
    echo "{
        \"status\": \"$(get_overall_status "$cpu_status" "$mem_status" "$disk_status")\",
        \"cpu\": $cpu_metrics,
        \"memory\": $memory_metrics,
        \"disk\": $disk_metrics,
        \"network\": $network_metrics,
        \"timestamp\": \"$(date -u +"%Y-%m-%dT%H:%M:%SZ")\"
    }"
}

get_overall_status() {
    if [[ "$1" == "CRITICAL" ]] || [[ "$2" == "CRITICAL" ]] || [[ "$3" == "CRITICAL" ]]; then
        echo "CRITICAL"
    elif [[ "$1" == "WARNING" ]] || [[ "$2" == "WARNING" ]] || [[ "$3" == "WARNING" ]]; then
        echo "WARNING"
    else
        echo "HEALTHY"
    fi
}

# Se executado diretamente
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    run_resource_monitoring
fi
