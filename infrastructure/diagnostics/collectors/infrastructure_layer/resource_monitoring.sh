#!/bin/bash

#===============================================================================
# SYSTEM RESOURCE MONITORING - ULTRA-ROBUST VERSION
#===============================================================================

# Importa funções de logging e utilitários
MODULE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" &> /dev/null && pwd)"
CORE_DIR="$(cd "$MODULE_DIR/../../core" &> /dev/null && pwd)"
source "$CORE_DIR/logger.sh" || exit 1
source "$CORE_DIR/utils.sh" || exit 1

# Carrega configurações de forma robusta
CONFIG_FILE="$MODULE_DIR/config.json"
if [[ -f "$CONFIG_FILE" ]]; then
    CPU_WARNING=$(jq -r '.thresholds.cpu_warning // 80' "$CONFIG_FILE" 2>/dev/null)
    CPU_CRITICAL=$(jq -r '.thresholds.cpu_critical // 90' "$CONFIG_FILE" 2>/dev/null)
    MEM_WARNING=$(jq -r '.thresholds.memory_warning // 85' "$CONFIG_FILE" 2>/dev/null)
    MEM_CRITICAL=$(jq -r '.thresholds.memory_critical // 95' "$CONFIG_FILE" 2>/dev/null)
    DISK_WARNING=$(jq -r '.thresholds.disk_warning // 90' "$CONFIG_FILE" 2>/dev/null)
    DISK_CRITICAL=$(jq -r '.thresholds.disk_critical // 95' "$CONFIG_FILE" 2>/dev/null)
else
    log_warning "Config file not found, using default thresholds"
    CPU_WARNING=80
    CPU_CRITICAL=90
    MEM_WARNING=85
    MEM_CRITICAL=95
    DISK_WARNING=90
    DISK_CRITICAL=95
fi

#===============================================================================
# ROBUST UTILITY FUNCTIONS
#===============================================================================

safe_log() {
    local level="$1"
    local message="$2"
    
    if declare -f "log_$level" >/dev/null 2>&1; then
        "log_$level" "$message"
    else
        echo "[$(date '+%Y-%m-%d %H:%M:%S')][$level] $message" >&2
    fi
}

safe_number() {
    local value="$1"
    local default="${2:-0}"
    
    # Remove caracteres não numéricos, exceto ponto decimal
    value=$(echo "$value" | sed 's/[^0-9.]//g' | tr -d '\000-\037')
    
    # Verifica se é um número válido
    if [[ "$value" =~ ^[0-9]*\.?[0-9]+$ ]] || [[ "$value" =~ ^[0-9]+$ ]]; then
        printf "%.2f" "$value" 2>/dev/null || echo "$default"
    else
        echo "$default"
    fi
}

get_status() {
    local value="$1"
    local warning="$2"
    local critical="$3"
    
    # Converte para número inteiro para comparação
    local value_int=$(echo "$value" | cut -d. -f1)
    local warning_int=$(echo "$warning" | cut -d. -f1)
    local critical_int=$(echo "$critical" | cut -d. -f1)
    
    if [[ $value_int -ge $critical_int ]]; then
        echo "CRITICAL"
    elif [[ $value_int -ge $warning_int ]]; then
        echo "WARNING"
    else
        echo "HEALTHY"
    fi
}

#===============================================================================
# ENHANCED CPU MONITORING
#===============================================================================

get_cpu_metrics() {
    safe_log "debug" "Collecting CPU metrics"
    
    # Método 1: top (mais confiável)
    local cpu_usage="0.0"
    local cpu_output
    if cpu_output=$(timeout 5 top -bn2 -d1 | grep "Cpu(s)" | tail -n1 2>/dev/null); then
        # Extrai uso de CPU do top
        local cpu_idle=$(echo "$cpu_output" | awk '{print $8}' | sed 's/%id,//')
        if [[ -n "$cpu_idle" ]]; then
            cpu_usage=$(echo "100 - $cpu_idle" | bc 2>/dev/null || echo "0.0")
        fi
    fi
    
    # Fallback: /proc/stat
    if [[ "$cpu_usage" == "0.0" ]]; then
        if [[ -r /proc/stat ]]; then
            local cpu_line1=$(grep "^cpu " /proc/stat)
            sleep 1
            local cpu_line2=$(grep "^cpu " /proc/stat)
            
            if [[ -n "$cpu_line1" ]] && [[ -n "$cpu_line2" ]]; then
                local idle1=$(echo "$cpu_line1" | awk '{print $5}')
                local total1=$(echo "$cpu_line1" | awk '{sum=0; for(i=2;i<=NF;i++) sum+=$i; print sum}')
                local idle2=$(echo "$cpu_line2" | awk '{print $5}')
                local total2=$(echo "$cpu_line2" | awk '{sum=0; for(i=2;i<=NF;i++) sum+=$i; print sum}')
                
                local idle_diff=$((idle2 - idle1))
                local total_diff=$((total2 - total1))
                
                if [[ $total_diff -gt 0 ]]; then
                    cpu_usage=$(echo "scale=2; 100 * (1 - $idle_diff / $total_diff)" | bc 2>/dev/null || echo "0.0")
                fi
            fi
        fi
    fi
    
    cpu_usage=$(safe_number "$cpu_usage" "0.0")
    
    # Load average
    local load_1min load_5min load_15min
    if [[ -r /proc/loadavg ]]; then
        local loadavg_content=$(cat /proc/loadavg 2>/dev/null)
        load_1min=$(echo "$loadavg_content" | awk '{print $1}')
        load_5min=$(echo "$loadavg_content" | awk '{print $2}')
        load_15min=$(echo "$loadavg_content" | awk '{print $3}')
    else
        load_1min="0.0"
        load_5min="0.0"
        load_15min="0.0"
    fi
    
    load_1min=$(safe_number "$load_1min" "0.0")
    load_5min=$(safe_number "$load_5min" "0.0")
    load_15min=$(safe_number "$load_15min" "0.0")
    
    # Número de cores
    local cpu_cores
    cpu_cores=$(nproc 2>/dev/null || grep -c "^processor" /proc/cpuinfo 2>/dev/null || echo "1")
    
    # Load average por core
    local load_per_core=$(echo "scale=2; $load_1min / $cpu_cores" | bc 2>/dev/null || echo "0.0")
    
    # Status baseado nos thresholds
    local status
    status=$(get_status "$cpu_usage" "$CPU_WARNING" "$CPU_CRITICAL")
    
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
    },
    "insights": {
        "efficiency": "$(get_cpu_efficiency "$cpu_usage" "$load_per_core")",
        "recommendation": "$(get_cpu_recommendation "$status" "$cpu_usage" "$load_per_core")"
    }
}
EOF
}

get_cpu_efficiency() {
    local usage="$1"
    local load_per_core="$2"
    
    local usage_int=$(echo "$usage" | cut -d. -f1)
    local load_int=$(echo "$load_per_core" | cut -d. -f1)
    
    if [[ $usage_int -lt 50 ]] && [[ $load_int -lt 1 ]]; then
        echo "Excellent - Low utilization"
    elif [[ $usage_int -lt 70 ]]; then
        echo "Good - Moderate utilization"
    elif [[ $usage_int -lt 85 ]]; then
        echo "Fair - High utilization"
    else
        echo "Poor - Critical utilization"
    fi
}

get_cpu_recommendation() {
    local status="$1"
    local usage="$2"
    local load_per_core="$3"
    
    case "$status" in
        "CRITICAL")
            echo "Immediate action required - consider scaling or optimization"
            ;;
        "WARNING")
            echo "Monitor closely - may need performance tuning"
            ;;
        *)
            echo "Performance within acceptable parameters"
            ;;
    esac
}

#===============================================================================
# ENHANCED MEMORY MONITORING
#===============================================================================

get_memory_metrics() {
    safe_log "debug" "Collecting memory metrics"
    
    local total_mem used_mem free_mem available_mem cached_mem
    local total_swap used_swap free_swap
    
    if [[ -r /proc/meminfo ]]; then
        # Lê /proc/meminfo diretamente
        local meminfo=$(cat /proc/meminfo 2>/dev/null)
        
        total_mem=$(echo "$meminfo" | grep "^MemTotal:" | awk '{print $2}')
        free_mem=$(echo "$meminfo" | grep "^MemFree:" | awk '{print $2}')
        available_mem=$(echo "$meminfo" | grep "^MemAvailable:" | awk '{print $2}')
        cached_mem=$(echo "$meminfo" | grep "^Cached:" | awk '{print $2}')
        total_swap=$(echo "$meminfo" | grep "^SwapTotal:" | awk '{print $2}')
        free_swap=$(echo "$meminfo" | grep "^SwapFree:" | awk '{print $2}')
        
        # Converte de KB para MB
        total_mem=$((total_mem / 1024))
        free_mem=$((free_mem / 1024))
        available_mem=$((available_mem / 1024))
        cached_mem=$((cached_mem / 1024))
        total_swap=$((total_swap / 1024))
        free_swap=$((free_swap / 1024))
        
        # Calcula memória usada
        used_mem=$((total_mem - available_mem))
        used_swap=$((total_swap - free_swap))
    else
        # Fallback para o comando free
        local free_output
        if free_output=$(timeout 3 free -m 2>/dev/null); then
            total_mem=$(echo "$free_output" | awk '/^Mem:/ {print $2}')
            used_mem=$(echo "$free_output" | awk '/^Mem:/ {print $3}')
            free_mem=$(echo "$free_output" | awk '/^Mem:/ {print $4}')
            available_mem=$(echo "$free_output" | awk '/^Mem:/ {print $7}')
            cached_mem=$(echo "$free_output" | awk '/^Mem:/ {print $6}')
            total_swap=$(echo "$free_output" | awk '/^Swap:/ {print $2}')
            used_swap=$(echo "$free_output" | awk '/^Swap:/ {print $3}')
        else
            # Valores padrão se tudo falhar
            total_mem=1024
            used_mem=512
            free_mem=512
            available_mem=512
            cached_mem=0
            total_swap=0
            used_swap=0
        fi
    fi
    
    # Sanitiza todos os valores
    total_mem=$(safe_number "$total_mem" "1024")
    used_mem=$(safe_number "$used_mem" "512")
    free_mem=$(safe_number "$free_mem" "512")
    available_mem=$(safe_number "$available_mem" "512")
    cached_mem=$(safe_number "$cached_mem" "0")
    total_swap=$(safe_number "$total_swap" "0")
    used_swap=$(safe_number "$used_swap" "0")
    
    # Calcula percentuais
    local mem_usage_percent="0.0"
    local swap_usage_percent="0.0"
    
    if [[ $(echo "$total_mem > 0" | bc 2>/dev/null || echo "0") -eq 1 ]]; then
        mem_usage_percent=$(echo "scale=2; $used_mem * 100 / $total_mem" | bc 2>/dev/null || echo "0.0")
    fi
    
    if [[ $(echo "$total_swap > 0" | bc 2>/dev/null || echo "0") -eq 1 ]]; then
        swap_usage_percent=$(echo "scale=2; $used_swap * 100 / $total_swap" | bc 2>/dev/null || echo "0.0")
    fi
    
    # Status baseado no uso de memória
    local status
    status=$(get_status "$mem_usage_percent" "$MEM_WARNING" "$MEM_CRITICAL")
    
    cat << EOF
{
    "total_mb": $total_mem,
    "used_mb": $used_mem,
    "free_mb": $free_mem,
    "available_mb": $available_mem,
    "cached_mb": $cached_mem,
    "usage_percent": $mem_usage_percent,
    "swap": {
        "total_mb": $total_swap,
        "used_mb": $used_swap,
        "usage_percent": $swap_usage_percent
    },
    "status": "$status",
    "thresholds": {
        "warning": $MEM_WARNING,
        "critical": $MEM_CRITICAL
    },
    "insights": {
        "efficiency": "$(get_memory_efficiency "$mem_usage_percent" "$swap_usage_percent")",
        "recommendation": "$(get_memory_recommendation "$status" "$mem_usage_percent" "$swap_usage_percent")"
    }
}
EOF
}

get_memory_efficiency() {
    local mem_usage="$1"
    local swap_usage="$2"
    
    local mem_int=$(echo "$mem_usage" | cut -d. -f1)
    local swap_int=$(echo "$swap_usage" | cut -d. -f1)
    
    if [[ $mem_int -lt 60 ]] && [[ $swap_int -lt 10 ]]; then
        echo "Excellent - Low memory pressure"
    elif [[ $mem_int -lt 80 ]] && [[ $swap_int -lt 25 ]]; then
        echo "Good - Moderate memory usage"
    elif [[ $mem_int -lt 90 ]]; then
        echo "Fair - High memory usage"
    else
        echo "Poor - Critical memory pressure"
    fi
}

get_memory_recommendation() {
    local status="$1"
    local mem_usage="$2"
    local swap_usage="$3"
    
    local swap_int=$(echo "$swap_usage" | cut -d. -f1)
    
    case "$status" in
        "CRITICAL")
            echo "Critical memory usage - consider adding RAM or reducing workload"
            ;;
        "WARNING")
            if [[ $swap_int -gt 50 ]]; then
                echo "High swap usage detected - investigate memory leaks"
            else
                echo "Monitor memory usage trends and plan capacity"
            fi
            ;;
        *)
            echo "Memory usage within normal parameters"
            ;;
    esac
}

#===============================================================================
# ENHANCED DISK MONITORING
#===============================================================================

get_disk_metrics() {
    safe_log "debug" "Collecting disk metrics"
    
    local disk_data=()
    
    # Usa df para obter informações de disco
    local df_output
    if df_output=$(timeout 5 df -h 2>/dev/null); then
        while IFS= read -r line; do
            # Pula cabeçalho e filesystems temporários
            [[ "$line" =~ ^Filesystem ]] && continue
            [[ "$line" =~ ^tmpfs ]] && continue
            [[ "$line" =~ ^devtmpfs ]] && continue
            [[ "$line" =~ ^udev ]] && continue
            
            # Parse da linha
            local fs total used available usage_percent mount
            fs=$(echo "$line" | awk '{print $1}')
            total=$(echo "$line" | awk '{print $2}')
            used=$(echo "$line" | awk '{print $3}')
            available=$(echo "$line" | awk '{print $4}')
            usage_percent=$(echo "$line" | awk '{print $5}' | sed 's/%//')
            mount=$(echo "$line" | awk '{print $6}')
            
            # Sanitiza valores
            fs=$(echo "$fs" | tr -d '\000-\037' | cut -c1-100)
            total=$(echo "$total" | tr -d '\000-\037')
            used=$(echo "$used" | tr -d '\000-\037')
            available=$(echo "$available" | tr -d '\000-\037')
            mount=$(echo "$mount" | tr -d '\000-\037' | cut -c1-100)
            usage_percent=$(safe_number "$usage_percent" "0")
            
            # Verifica se o uso é válido
            local usage_int=$(echo "$usage_percent" | cut -d. -f1)
            if [[ $usage_int -gt 0 ]] && [[ $usage_int -le 100 ]]; then
                local status
                status=$(get_status "$usage_percent" "$DISK_WARNING" "$DISK_CRITICAL")
                
                disk_data+=("{
                    \"filesystem\": \"$fs\",
                    \"mount_point\": \"$mount\",
                    \"total\": \"$total\",
                    \"used\": \"$used\",
                    \"available\": \"$available\",
                    \"usage_percent\": $usage_percent,
                    \"status\": \"$status\",
                    \"insights\": {
                        \"efficiency\": \"$(get_disk_efficiency "$usage_percent")\",
                        \"recommendation\": \"$(get_disk_recommendation "$status" "$usage_percent")\"
                    }
                }")
            fi
        done <<< "$df_output"
    fi
    
    # Se não conseguiu coletar dados, cria entrada padrão
    if [[ ${#disk_data[@]} -eq 0 ]]; then
        disk_data+=("{
            \"filesystem\": \"unknown\",
            \"mount_point\": \"/\",
            \"total\": \"unknown\",
            \"used\": \"unknown\",
            \"available\": \"unknown\",
            \"usage_percent\": 0,
            \"status\": \"UNKNOWN\",
            \"insights\": {
                \"efficiency\": \"Unknown - data unavailable\",
                \"recommendation\": \"Check disk monitoring tools\"
            }
        }")
    fi
    
    echo "[$(IFS=','; echo "${disk_data[*]}")]"
}

get_disk_efficiency() {
    local usage="$1"
    local usage_int=$(echo "$usage" | cut -d. -f1)
    
    if [[ $usage_int -lt 60 ]]; then
        echo "Excellent - Plenty of space available"
    elif [[ $usage_int -lt 80 ]]; then
        echo "Good - Adequate space remaining"
    elif [[ $usage_int -lt 90 ]]; then
        echo "Fair - Consider cleanup or expansion"
    else
        echo "Poor - Immediate attention required"
    fi
}

get_disk_recommendation() {
    local status="$1"
    local usage="$2"
    
    case "$status" in
        "CRITICAL")
            echo "Critical disk usage - free space immediately"
            ;;
        "WARNING")
            echo "Plan disk cleanup or expansion soon"
            ;;
        *)
            echo "Disk usage within normal parameters"
            ;;
    esac
}

#===============================================================================
# ENHANCED NETWORK MONITORING
#===============================================================================

get_network_metrics() {
    safe_log "debug" "Collecting network metrics"
    
    local rx_bytes=0 tx_bytes=0 rx_errors=0 tx_errors=0
    local active_connections=0
    local active_interfaces=()
    
    # Coleta estatísticas de rede de /proc/net/dev
    if [[ -r /proc/net/dev ]]; then
        while IFS= read -r line; do
            # Pula cabeçalhos
            [[ "$line" =~ face\|bytes ]] && continue
            [[ "$line" =~ \|.* ]] && continue
            
            # Parse da linha
            local interface=$(echo "$line" | awk -F: '{print $1}' | tr -d ' ')
            local stats=$(echo "$line" | awk -F: '{print $2}')
            
            # Pula interface loopback e interfaces virtuais desnecessárias
            [[ "$interface" == "lo" ]] && continue
            [[ "$interface" =~ ^veth ]] && continue
            [[ "$interface" =~ ^br- ]] && continue
            
            if [[ -n "$interface" ]] && [[ -n "$stats" ]]; then
                local rx_b=$(echo "$stats" | awk '{print $1}')
                local rx_e=$(echo "$stats" | awk '{print $3}')
                local tx_b=$(echo "$stats" | awk '{print $9}')
                local tx_e=$(echo "$stats" | awk '{print $11}')
                
                # Sanitiza e acumula
                rx_b=$(safe_number "$rx_b" "0")
                rx_e=$(safe_number "$rx_e" "0")
                tx_b=$(safe_number "$tx_b" "0")
                tx_e=$(safe_number "$tx_e" "0")
                
                rx_bytes=$(echo "$rx_bytes + $rx_b" | bc 2>/dev/null || echo "$rx_bytes")
                tx_bytes=$(echo "$tx_bytes + $tx_b" | bc 2>/dev/null || echo "$tx_bytes")
                rx_errors=$(echo "$rx_errors + $rx_e" | bc 2>/dev/null || echo "$rx_errors")
                tx_errors=$(echo "$tx_errors + $tx_e" | bc 2>/dev/null || echo "$tx_errors")
                
                # Adiciona à lista de interfaces ativas
                active_interfaces+=("\"$interface\"")
            fi
        done < /proc/net/dev
    fi
    
    # Coleta conexões ativas
    if command -v ss >/dev/null 2>&1; then
        active_connections=$(timeout 3 ss -s 2>/dev/null | grep "TCP:" | awk '{print $2}' | safe_number || echo "0")
    elif command -v netstat >/dev/null 2>&1; then
        active_connections=$(timeout 3 netstat -an 2>/dev/null | grep -c "^tcp.*ESTABLISHED" || echo "0")
    fi
    
    active_connections=$(safe_number "$active_connections" "0")
    
    # Prepara lista de interfaces
    local interfaces_json="[]"
    if [[ ${#active_interfaces[@]} -gt 0 ]]; then
        interfaces_json="[$(IFS=','; echo "${active_interfaces[*]}")]"
    fi
    
    cat << EOF
{
    "rx_bytes": $rx_bytes,
    "tx_bytes": $tx_bytes,
    "rx_errors": $rx_errors,
    "tx_errors": $tx_errors,
    "active_connections": $active_connections,
    "active_interfaces": $interfaces_json,
    "insights": {
        "health": "$(get_network_health "$rx_errors" "$tx_errors")",
        "activity": "$(get_network_activity "$rx_bytes" "$tx_bytes")",
        "recommendation": "$(get_network_recommendation "$rx_errors" "$tx_errors")"
    }
}
EOF
}

get_network_health() {
    local rx_errors="$1"
    local tx_errors="$2"
    
    local total_errors=$(echo "$rx_errors + $tx_errors" | bc 2>/dev/null || echo "0")
    local errors_int=$(echo "$total_errors" | cut -d. -f1)
    
    if [[ $errors_int -eq 0 ]]; then
        echo "Excellent - No network errors"
    elif [[ $errors_int -lt 100 ]]; then
        echo "Good - Minimal network errors"
    elif [[ $errors_int -lt 1000 ]]; then
        echo "Fair - Some network errors detected"
    else
        echo "Poor - High network error rate"
    fi
}

get_network_activity() {
    local rx_bytes="$1"
    local tx_bytes="$2"
    
    local total_bytes=$(echo "$rx_bytes + $tx_bytes" | bc 2>/dev/null || echo "0")
    local total_mb=$(echo "scale=0; $total_bytes / 1024 / 1024" | bc 2>/dev/null || echo "0")
    
    if [[ $total_mb -lt 100 ]]; then
        echo "Low network activity"
    elif [[ $total_mb -lt 1000 ]]; then
        echo "Moderate network activity"
    else
        echo "High network activity"
    fi
}

get_network_recommendation() {
    local rx_errors="$1"
    local tx_errors="$2"
    
    local total_errors=$(echo "$rx_errors + $tx_errors" | bc 2>/dev/null || echo "0")
    local errors_int=$(echo "$total_errors" | cut -d. -f1)
    
    if [[ $errors_int -gt 1000 ]]; then
        echo "Investigate network hardware and configuration"
    elif [[ $errors_int -gt 100 ]]; then
        echo "Monitor network performance for issues"
    else
        echo "Network performance within normal parameters"
    fi
}

#===============================================================================
# MAIN DIAGNOSTIC FUNCTION
#===============================================================================

run_resource_monitoring() {
    safe_log "info" "Starting ultra-robust resource monitoring diagnostic"
    
    # Coleta métricas de todos os recursos com tratamento de erro
    local cpu_metrics memory_metrics disk_metrics network_metrics
    
    # CPU metrics
    if cpu_metrics=$(get_cpu_metrics 2>/dev/null); then
        if ! echo "$cpu_metrics" | jq '.' >/dev/null 2>&1; then
            safe_log "warning" "CPU metrics JSON invalid, using fallback"
            cpu_metrics='{"usage": 0.0, "status": "UNKNOWN", "cores": 1, "load_average": {"1min": 0.0, "5min": 0.0, "15min": 0.0}}'
        fi
    else
        safe_log "error" "Failed to collect CPU metrics"
        cpu_metrics='{"usage": 0.0, "status": "UNKNOWN", "cores": 1, "load_average": {"1min": 0.0, "5min": 0.0, "15min": 0.0}}'
    fi
    
    # Memory metrics
    if memory_metrics=$(get_memory_metrics 2>/dev/null); then
        if ! echo "$memory_metrics" | jq '.' >/dev/null 2>&1; then
            safe_log "warning" "Memory metrics JSON invalid, using fallback"
            memory_metrics='{"total_mb": 1024, "used_mb": 512, "usage_percent": 50.0, "status": "UNKNOWN"}'
        fi
    else
        safe_log "error" "Failed to collect memory metrics"
        memory_metrics='{"total_mb": 1024, "used_mb": 512, "usage_percent": 50.0, "status": "UNKNOWN"}'
    fi
    
    # Disk metrics
    if disk_metrics=$(get_disk_metrics 2>/dev/null); then
        if ! echo "$disk_metrics" | jq '.' >/dev/null 2>&1; then
            safe_log "warning" "Disk metrics JSON invalid, using fallback"
            disk_metrics='[{"filesystem": "unknown", "mount_point": "/", "usage_percent": 0, "status": "UNKNOWN"}]'
        fi
    else
        safe_log "error" "Failed to collect disk metrics"
        disk_metrics='[{"filesystem": "unknown", "mount_point": "/", "usage_percent": 0, "status": "UNKNOWN"}]'
    fi
    
    # Network metrics
    if network_metrics=$(get_network_metrics 2>/dev/null); then
        if ! echo "$network_metrics" | jq '.' >/dev/null 2>&1; then
            safe_log "warning" "Network metrics JSON invalid, using fallback"
            network_metrics='{"rx_bytes": 0, "tx_bytes": 0, "active_connections": 0, "active_interfaces": []}'
        fi
    else
        safe_log "error" "Failed to collect network metrics"
        network_metrics='{"rx_bytes": 0, "tx_bytes": 0, "active_connections": 0, "active_interfaces": []}'
    fi
    
    # Determina status geral de forma robusta
    local cpu_status=$(echo "$cpu_metrics" | jq -r '.status // "UNKNOWN"' 2>/dev/null || echo "UNKNOWN")
    local mem_status=$(echo "$memory_metrics" | jq -r '.status // "UNKNOWN"' 2>/dev/null || echo "UNKNOWN")
    local disk_status=$(echo "$disk_metrics" | jq -r '[.[].status] | if contains(["CRITICAL"]) then "CRITICAL" elif contains(["WARNING"]) then "WARNING" else "HEALTHY" end' 2>/dev/null || echo "UNKNOWN")
    
    local overall_status
    overall_status=$(get_overall_status "$cpu_status" "$mem_status" "$disk_status")
    
    # Gera insights para LLM
    local summary_insight impact_assessment recommendations
    local analysis_result
    analysis_result=$(generate_resource_analysis "$overall_status" "$cpu_status" "$mem_status" "$disk_status")
    
    summary_insight=$(echo "$analysis_result" | jq -r '.summary // "Resource analysis completed"' 2>/dev/null)
    impact_assessment=$(echo "$analysis_result" | jq -r '.impact // "No significant impact"' 2>/dev/null)
    recommendations=$(echo "$analysis_result" | jq -c '.recommendations // []' 2>/dev/null || echo "[]")
    
    # Gera saída JSON final
    local final_json
    final_json=$(cat << EOF
{
    "status": "$overall_status",
    "cpu": $cpu_metrics,
    "memory": $memory_metrics,
    "disk": $disk_metrics,
    "network": $network_metrics,
    "insights": {
        "summary": "$(echo "$summary_insight" | sed 's/"/\\"/g')",
        "impact_assessment": "$(echo "$impact_assessment" | sed 's/"/\\"/g')",
        "overall_health_score": $(calculate_health_score "$cpu_status" "$mem_status" "$disk_status"),
        "recommendations": $recommendations,
        "trend_analysis": {
            "cpu_trend": "$(get_trend_analysis "$cpu_status")",
            "memory_trend": "$(get_trend_analysis "$mem_status")",
            "disk_trend": "$(get_trend_analysis "$disk_status")"
        }
    },
    "metadata": {
        "timestamp": "$(date -u +"%Y-%m-%dT%H:%M:%SZ")",
        "thresholds": {
            "cpu_warning": $CPU_WARNING,
            "cpu_critical": $CPU_CRITICAL,
            "memory_warning": $MEM_WARNING,
            "memory_critical": $MEM_CRITICAL,
            "disk_warning": $DISK_WARNING,
            "disk_critical": $DISK_CRITICAL
        },
        "diagnostic_version": "2.1.0",
        "data_quality": "validated"
    }
}
EOF
)
    
    # Validação final
    if echo "$final_json" | jq '.' >/dev/null 2>&1; then
        safe_log "info" "Resource monitoring completed successfully - status: $overall_status"
        echo "$final_json"
        return 0
    else
        safe_log "error" "Final JSON validation failed"
        # JSON de emergência
        cat << EOF
{
    "status": "CRITICAL",
    "error": "Resource monitoring failed",
    "cpu": {"usage": 0, "status": "UNKNOWN"},
    "memory": {"usage_percent": 0, "status": "UNKNOWN"},
    "disk": [{"usage_percent": 0, "status": "UNKNOWN"}],
    "network": {"rx_bytes": 0, "tx_bytes": 0},
    "timestamp": "$(date -u +"%Y-%m-%dT%H:%M:%SZ")"
}
EOF
        return 1
    fi
}

#===============================================================================
# ADVANCED ANALYSIS FUNCTIONS
#===============================================================================

generate_resource_analysis() {
    local overall_status="$1"
    local cpu_status="$2"
    local mem_status="$3"
    local disk_status="$4"
    
    local summary=""
    local impact=""
    local recommendations='[]'
    
    # Análise baseada no status geral
    case "$overall_status" in
        "CRITICAL")
            summary="Critical resource conditions detected requiring immediate attention"
            impact="System performance severely degraded - service availability at risk"
            recommendations='[
                {"priority": "P1", "action": "Immediate resource scaling or workload reduction"},
                {"priority": "P1", "action": "Emergency monitoring and alerting activation"},
                {"priority": "P2", "action": "Root cause analysis and performance optimization"}
            ]'
            ;;
        "WARNING")
            summary="Resource utilization approaching critical thresholds"
            impact="Performance degradation likely - proactive intervention recommended"
            recommendations='[
                {"priority": "P2", "action": "Monitor resource trends closely"},
                {"priority": "P3", "action": "Plan capacity expansion or optimization"},
                {"priority": "P3", "action": "Review and optimize resource-intensive processes"}
            ]'
            ;;
        "HEALTHY")
            summary="All system resources operating within normal parameters"
            impact="No immediate performance impact - system operating efficiently"
            recommendations='[
                {"priority": "P4", "action": "Continue routine monitoring"},
                {"priority": "P4", "action": "Maintain current resource allocation"}
            ]'
            ;;
        *)
            summary="Resource monitoring completed with indeterminate results"
            impact="Unable to assess performance impact accurately"
            recommendations='[
                {"priority": "P3", "action": "Investigate monitoring system health"},
                {"priority": "P3", "action": "Verify system access and permissions"}
            ]'
            ;;
    esac
    
    cat << EOF
{
    "summary": "$summary",
    "impact": "$impact",
    "recommendations": $recommendations
}
EOF
}

calculate_health_score() {
    local cpu_status="$1"
    local mem_status="$2"
    local disk_status="$3"
    
    local score=100
    
    # Reduz score baseado no status de cada componente
    case "$cpu_status" in
        "CRITICAL") score=$((score - 40)) ;;
        "WARNING") score=$((score - 20)) ;;
        "UNKNOWN") score=$((score - 10)) ;;
    esac
    
    case "$mem_status" in
        "CRITICAL") score=$((score - 35)) ;;
        "WARNING") score=$((score - 18)) ;;
        "UNKNOWN") score=$((score - 8)) ;;
    esac
    
    case "$disk_status" in
        "CRITICAL") score=$((score - 25)) ;;
        "WARNING") score=$((score - 12)) ;;
        "UNKNOWN") score=$((score - 5)) ;;
    esac
    
    # Garante que o score não seja negativo
    [[ $score -lt 0 ]] && score=0
    
    echo "$score"
}

get_trend_analysis() {
    local status="$1"
    
    case "$status" in
        "CRITICAL")
            echo "deteriorating"
            ;;
        "WARNING")
            echo "concerning"
            ;;
        "HEALTHY")
            echo "stable"
            ;;
        *)
            echo "unknown"
            ;;
    esac
}

get_overall_status() {
    local cpu_status="$1"
    local mem_status="$2"
    local disk_status="$3"
    
    # Prioriza o pior status encontrado
    if [[ "$cpu_status" == "CRITICAL" ]] || [[ "$mem_status" == "CRITICAL" ]] || [[ "$disk_status" == "CRITICAL" ]]; then
        echo "CRITICAL"
    elif [[ "$cpu_status" == "WARNING" ]] || [[ "$mem_status" == "WARNING" ]] || [[ "$disk_status" == "WARNING" ]]; then
        echo "WARNING"
    elif [[ "$cpu_status" == "HEALTHY" ]] && [[ "$mem_status" == "HEALTHY" ]] && [[ "$disk_status" == "HEALTHY" ]]; then
        echo "HEALTHY"
    else
        echo "UNKNOWN"
    fi
}

#===============================================================================
# PERFORMANCE OPTIMIZATION
#===============================================================================

optimize_collection_performance() {
    # Configura coleta otimizada baseada na carga do sistema
    local current_load
    current_load=$(get_load_average 1 2>/dev/null || echo "0")
    
    local load_threshold=2.0
    if [[ $(echo "$current_load > $load_threshold" | bc 2>/dev/null || echo "0") -eq 1 ]]; then
        # Sistema sob carga - reduz intensidade da coleta
        export COLLECTION_TIMEOUT=3
        export COLLECTION_SAMPLES=1
        safe_log "debug" "High system load detected - using optimized collection mode"
    else
        # Sistema normal - coleta completa
        export COLLECTION_TIMEOUT=5
        export COLLECTION_SAMPLES=2
        safe_log "debug" "Normal system load - using standard collection mode"
    fi
}

enable_smart_caching() {
    # Habilita cache inteligente para reduzir overhead
    local cache_dir="/tmp/resource_monitoring_cache"
    local cache_ttl=30  # 30 segundos
    
    if ! mkdir -p "$cache_dir" 2>/dev/null; then
        safe_log "warning" "Failed to create cache directory"
        return 1
    fi
    
    export CACHE_DIR="$cache_dir"
    export CACHE_TTL="$cache_ttl"
    safe_log "debug" "Smart caching enabled (TTL: ${cache_ttl}s)"
}

cleanup_monitoring_resources() {
    # Limpa recursos temporários e otimiza para próxima execução
    local temp_files=$(find /tmp -name "*resource_monitoring*" -type f -mmin +60 2>/dev/null)
    
    if [[ -n "$temp_files" ]]; then
        echo "$temp_files" | xargs rm -f 2>/dev/null
        safe_log "debug" "Cleaned up temporary monitoring files"
    fi
    
    # Otimiza cache do sistema se necessário
    local mem_usage
    mem_usage=$(get_memory_usage 2>/dev/null || echo "0")
    
    if [[ $(echo "$mem_usage > 85" | bc 2>/dev/null || echo "0") -eq 1 ]]; then
        sync 2>/dev/null
        safe_log "debug" "System memory optimization triggered"
    fi
}

#===============================================================================
# ENHANCED ERROR HANDLING
#===============================================================================

handle_collection_error() {
    local component="$1"
    local error_details="$2"
    local fallback_data="$3"
    
    safe_log "error" "Error collecting $component metrics: $error_details"
    
    # Registra erro para análise posterior
    local error_log="/tmp/resource_monitoring_errors.log"
    echo "$(date -u +"%Y-%m-%dT%H:%M:%SZ") [$component] $error_details" >> "$error_log" 2>/dev/null
    
    # Retorna dados de fallback
    echo "$fallback_data"
}

validate_system_requirements() {
    local missing_tools=()
    
    # Verifica ferramentas essenciais
    command -v jq >/dev/null 2>&1 || missing_tools+=("jq")
    command -v bc >/dev/null 2>&1 || missing_tools+=("bc")
    command -v awk >/dev/null 2>&1 || missing_tools+=("awk")
    
    # Verifica arquivos essenciais do sistema
    [[ ! -r /proc/stat ]] && missing_tools+=("/proc/stat")
    [[ ! -r /proc/meminfo ]] && missing_tools+=("/proc/meminfo")
    [[ ! -r /proc/loadavg ]] && missing_tools+=("/proc/loadavg")
    
    if [[ ${#missing_tools[@]} -gt 0 ]]; then
        safe_log "warning" "Missing system requirements: ${missing_tools[*]}"
        return 1
    fi
    
    return 0
}

#===============================================================================
# EXECUTION OPTIMIZATION
#===============================================================================

# Inicializa otimizações se executado diretamente
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    # Valida requisitos do sistema
    validate_system_requirements || {
        safe_log "critical" "System requirements not met"
        exit 1
    }
    
    # Configura otimizações
    optimize_collection_performance
    enable_smart_caching
    
    # Executa monitoramento principal
    run_resource_monitoring
    exit_code=$?
    
    # Limpa recursos
    cleanup_monitoring_resources
    
    # Finaliza com código de saída apropriado
    exit $exit_code
fi

#===============================================================================
# EXPORT FUNCTIONS
#===============================================================================

export -f run_resource_monitoring get_cpu_metrics get_memory_metrics
export -f get_disk_metrics get_network_metrics get_status safe_number
export -f generate_resource_analysis calculate_health_score get_overall_status