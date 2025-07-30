#!/bin/bash

#===============================================================================
# SYSTEM RESOURCE MONITORING
#===============================================================================

# Importa funções de logging e utilitários
MODULE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" &> /dev/null && pwd)"
CORE_DIR="$(cd "$MODULE_DIR/../../core" &> /dev/null && pwd)"
source "$CORE_DIR/logger.sh" || exit 1
source "$CORE_DIR/utils.sh" || exit 1

# Carrega configurações
CONFIG_FILE="$MODULE_DIR/config.json"
CPU_WARNING=$(jq -r '.thresholds.cpu_warning' "$CONFIG_FILE" 2>/dev/null || echo "80")
CPU_CRITICAL=$(jq -r '.thresholds.cpu_critical' "$CONFIG_FILE" 2>/dev/null || echo "90")
MEM_WARNING=$(jq -r '.thresholds.memory_warning' "$CONFIG_FILE" 2>/dev/null || echo "85")
MEM_CRITICAL=$(jq -r '.thresholds.memory_critical' "$CONFIG_FILE" 2>/dev/null || echo "95")
DISK_WARNING=$(jq -r '.thresholds.disk_warning' "$CONFIG_FILE" 2>/dev/null || echo "90")
DISK_CRITICAL=$(jq -r '.thresholds.disk_critical' "$CONFIG_FILE" 2>/dev/null || echo "95")

#===============================================================================
# CPU MONITORING
#===============================================================================

get_cpu_metrics() {
    log_debug "Collecting CPU metrics"
    
    # Coleta uso de CPU
    local cpu_usage
    cpu_usage=$(top -bn1 | grep "Cpu(s)" | awk '{print $2}' | tr -d '%us,' 2>/dev/null || echo "0")
    
    # Coleta load average
    local load_1min
    load_1min=$(get_load_average 1)
    
    local load_5min
    load_5min=$(get_load_average 5)
    
    local load_15min
    load_15min=$(get_load_average 15)
    
    # Coleta número de cores
    local cpu_cores
    cpu_cores=$(get_cpu_count)
    
    # Calcula status baseado nos thresholds
    local status
    status=$(get_status "$cpu_usage" "$CPU_WARNING" "$CPU_CRITICAL")
    
    # Calcula load average por core
    local load_per_core
    load_per_core=$(echo "scale=2; $load_1min / $cpu_cores" | bc 2>/dev/null || echo "0")
    
    cat << EOF
{
    "usage": $cpu_usage,
    "load_average": {
        "1min": $load_1min,
        "5min": $load_5min,
        "15min": $load_15min,
        "per_core": $load_per_core
    },
    "cores": $cpu_cores,
    "status": "$status",
    "thresholds": {
        "warning": $CPU_WARNING,
        "critical": $CPU_CRITICAL
    }
}
EOF
}

#===============================================================================
# MEMORY MONITORING
#===============================================================================

get_memory_metrics() {
    log_debug "Collecting memory metrics"
    
    # Coleta informações de memória
    local total_mem
    total_mem=$(free -m | awk '/Mem:/ {print $2}' 2>/dev/null || echo "0")
    
    local used_mem
    used_mem=$(free -m | awk '/Mem:/ {print $3}' 2>/dev/null || echo "0")
    
    local free_mem
    free_mem=$(free -m | awk '/Mem:/ {print $4}' 2>/dev/null || echo "0")
    
    local cached_mem
    cached_mem=$(free -m | awk '/Mem:/ {print $6}' 2>/dev/null || echo "0")
    
    # Coleta informações de swap
    local total_swap
    total_swap=$(free -m | awk '/Swap:/ {print $2}' 2>/dev/null || echo "0")
    
    local used_swap
    used_swap=$(free -m | awk '/Swap:/ {print $3}' 2>/dev/null || echo "0")
    
    # Calcula percentuais
    local mem_usage
    mem_usage=$(awk "BEGIN {printf \"%.2f\", ($used_mem/$total_mem)*100}" 2>/dev/null || echo "0")
    
    local swap_usage
    if [[ "$total_swap" -gt 0 ]]; then
        swap_usage=$(awk "BEGIN {printf \"%.2f\", ($used_swap/$total_swap)*100}" 2>/dev/null || echo "0")
    else
        swap_usage="0"
    fi
    
    # Calcula status
    local status
    status=$(get_status "$mem_usage" "$MEM_WARNING" "$MEM_CRITICAL")
    
    cat << EOF
{
    "total_mb": $total_mem,
    "used_mb": $used_mem,
    "free_mb": $free_mem,
    "cached_mb": $cached_mem,
    "usage_percent": $mem_usage,
    "swap": {
        "total_mb": $total_swap,
        "used_mb": $used_swap,
        "usage_percent": $swap_usage
    },
    "status": "$status",
    "thresholds": {
        "warning": $MEM_WARNING,
        "critical": $MEM_CRITICAL
    }
}
EOF
}

#===============================================================================
# DISK MONITORING
#===============================================================================

get_disk_metrics() {
    log_debug "Collecting disk metrics"
    
    local disk_data=()
    
    # Coleta informações de todos os filesystems
    while IFS= read -r line; do
        local fs
        fs=$(echo "$line" | awk '{print $1}')
        
        local total
        total=$(echo "$line" | awk '{print $2}')
        
        local used
        used=$(echo "$line" | awk '{print $3}')
        
        local available
        available=$(echo "$line" | awk '{print $4}')
        
        local usage
        usage=$(echo "$line" | awk '{print $5}' | sed 's/%//')
        
        local mount
        mount=$(echo "$line" | awk '{print $6}')
        
        # Filtra apenas filesystems com uso > 0
        if [[ $usage -gt 0 ]]; then
            local status
            status=$(get_status "$usage" "$DISK_WARNING" "$DISK_CRITICAL")
            
            disk_data+=("{
                \"filesystem\": \"$fs\",
                \"mount_point\": \"$mount\",
                \"total_gb\": $total,
                \"used_gb\": $used,
                \"available_gb\": $available,
                \"usage_percent\": $usage,
                \"status\": \"$status\"
            }")
        fi
    done < <(df -h | grep -v '^Filesystem' | grep -v '^tmpfs' | grep -v '^devtmpfs')
    
    if [[ ${#disk_data[@]} -eq 0 ]]; then
        echo "[]"
    else
        echo "[$(IFS=,; echo "${disk_data[*]}")]"
    fi
}

#===============================================================================
# NETWORK MONITORING
#===============================================================================

get_network_metrics() {
    log_debug "Collecting network metrics"
    
    # Coleta estatísticas de rede
    local rx_bytes
    rx_bytes=$(cat /sys/class/net/[ew]*/statistics/rx_bytes 2>/dev/null | awk '{sum += $1} END {print sum+0}')
    
    local tx_bytes
    tx_bytes=$(cat /sys/class/net/[ew]*/statistics/tx_bytes 2>/dev/null | awk '{sum += $1} END {print sum+0}')
    
    local rx_errors
    rx_errors=$(cat /sys/class/net/[ew]*/statistics/rx_errors 2>/dev/null | awk '{sum += $1} END {print sum+0}')
    
    local tx_errors
    tx_errors=$(cat /sys/class/net/[ew]*/statistics/tx_errors 2>/dev/null | awk '{sum += $1} END {print sum+0}')
    
    # Coleta conexões ativas
    local active_connections
    active_connections=$(ss -s 2>/dev/null | awk '/TCP:/ {print $2}' || echo "0")
    
    # Coleta interfaces ativas
    local active_interfaces=()
    while IFS= read -r interface; do
        if [[ -n "$interface" ]]; then
            active_interfaces+=("\"$interface\"")
        fi
    done < <(ip link show | grep -E '^[0-9]+:' | awk -F: '{print $2}' | tr -d ' ')
    
    local interfaces_json
    if [[ ${#active_interfaces[@]} -eq 0 ]]; then
        interfaces_json="[]"
    else
        interfaces_json="[$(IFS=,; echo "${active_interfaces[*]}")]"
    fi
    
    cat << EOF
{
    "rx_bytes": $rx_bytes,
    "tx_bytes": $tx_bytes,
    "rx_errors": $rx_errors,
    "tx_errors": $tx_errors,
    "active_connections": $active_connections,
    "active_interfaces": $interfaces_json
}
EOF
}

#===============================================================================
# UTILITY FUNCTIONS
#===============================================================================

get_status() {
    local value="$1"
    local warning="$2"
    local critical="$3"
    
    # Converte para número para comparação
    value=$(echo "$value" | tr -d '%' 2>/dev/null || echo "0")
    
    if (( $(echo "$value >= $critical" | bc -l 2>/dev/null || echo "0") )); then
        echo "CRITICAL"
    elif (( $(echo "$value >= $warning" | bc -l 2>/dev/null || echo "0") )); then
        echo "WARNING"
    else
        echo "HEALTHY"
    fi
}

get_overall_status() {
    local cpu_status="$1"
    local mem_status="$2"
    local disk_status="$3"
    
    # Determina status geral baseado no pior status
    if [[ "$cpu_status" == "CRITICAL" ]] || [[ "$mem_status" == "CRITICAL" ]] || [[ "$disk_status" == "CRITICAL" ]]; then
        echo "CRITICAL"
    elif [[ "$cpu_status" == "WARNING" ]] || [[ "$mem_status" == "WARNING" ]] || [[ "$disk_status" == "WARNING" ]]; then
        echo "WARNING"
    else
        echo "HEALTHY"
    fi
}

#===============================================================================
# MAIN DIAGNOSTIC FUNCTION
#===============================================================================

run_resource_monitoring() {
    log_info "Starting resource monitoring diagnostic"
    
    # Coleta métricas de todos os recursos
    local cpu_metrics
    cpu_metrics=$(get_cpu_metrics)
    
    local memory_metrics
    memory_metrics=$(get_memory_metrics)
    
    local disk_metrics
    disk_metrics=$(get_disk_metrics)
    
    local network_metrics
    network_metrics=$(get_network_metrics)
    
    # Determina status geral
    local cpu_status
    cpu_status=$(echo "$cpu_metrics" | jq -r '.status' 2>/dev/null || echo "UNKNOWN")
    
    local mem_status
    mem_status=$(echo "$memory_metrics" | jq -r '.status' 2>/dev/null || echo "UNKNOWN")
    
    local disk_status
    disk_status=$(echo "$disk_metrics" | jq -r '[.[].status] | if contains(["CRITICAL"]) then "CRITICAL" elif contains(["WARNING"]) then "WARNING" else "HEALTHY" end' 2>/dev/null || echo "UNKNOWN")
    
    local overall_status
    overall_status=$(get_overall_status "$cpu_status" "$mem_status" "$disk_status")
    
    # Gera saída JSON estruturada
    cat << EOF
{
    "status": "$overall_status",
    "cpu": $cpu_metrics,
    "memory": $memory_metrics,
    "disk": $disk_metrics,
    "network": $network_metrics,
    "metadata": {
        "timestamp": "$(date -u +"%Y-%m-%dT%H:%M:%SZ")",
        "thresholds": {
            "cpu_warning": $CPU_WARNING,
            "cpu_critical": $CPU_CRITICAL,
            "memory_warning": $MEM_WARNING,
            "memory_critical": $MEM_CRITICAL,
            "disk_warning": $DISK_WARNING,
            "disk_critical": $DISK_CRITICAL
        }
    }
}
EOF
    
    # Retorna código de saída baseado no status geral
    if [[ "$overall_status" == "HEALTHY" ]]; then
        log_info "Resource monitoring completed successfully - all resources healthy"
        return 0
    elif [[ "$overall_status" == "WARNING" ]]; then
        log_warning "Resource monitoring completed with warnings"
        return 0
    else
        log_error "Resource monitoring completed with critical issues"
        return 1
    fi
}

#===============================================================================
# EXECUTION
#===============================================================================

# Se executado diretamente
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    run_resource_monitoring
fi
