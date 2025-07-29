#!/bin/bash

# Importa dependências
source "$(dirname "$0")/../../../../.env" 2>/dev/null
source "$(dirname "$0")/../../core/logger.sh"
source "$(dirname "$0")/../../core/utils.sh"

# Carrega configuração
CONFIG_FILE="$(dirname "$0")/config.json"
MONITOR_INTERVAL=$(jq -r '.monitoring.interval_seconds' "$CONFIG_FILE")
MAX_CONSECUTIVE_FAILURES=$(jq -r '.monitoring.max_consecutive_failures' "$CONFIG_FILE")
SELF_HEALING_ENABLED=$(jq -r '.monitoring.self_healing_enabled' "$CONFIG_FILE")

FAILURE_COUNT=0
LAST_CHECK_TIME=0

check_docker_daemon() {
    timeout 5 docker info >/dev/null 2>&1
    return $?
}

check_container_count() {
    local min_containers=$(jq -r '.thresholds.min_running_containers' "$CONFIG_FILE")
    local running_count=$(docker ps -q | wc -l)
    [[ $running_count -ge $min_containers ]]
    return $?
}

check_system_resources() {
    local cpu_critical=$(jq -r '.thresholds.cpu_critical' "$CONFIG_FILE")
    local mem_critical=$(jq -r '.thresholds.memory_critical' "$CONFIG_FILE")
    local disk_critical=$(jq -r '.thresholds.disk_critical' "$CONFIG_FILE")
    
    # CPU Check
    local cpu_usage=$(top -bn1 | grep "Cpu(s)" | awk '{print $2}' | tr -d '%us,')
    [[ "${cpu_usage%.*}" -lt $cpu_critical ]] || return 1
    
    # Memory Check
    local mem_usage=$(free | grep Mem | awk '{print ($3/$2 * 100)}')
    [[ "${mem_usage%.*}" -lt $mem_critical ]] || return 1
    
    # Disk Check
    local disk_usage=$(df / | tail -1 | awk '{print $5}' | tr -d '%')
    [[ $disk_usage -lt $disk_critical ]] || return 1
    
    return 0
}

attempt_self_healing() {
    if [[ "$SELF_HEALING_ENABLED" != "true" ]]; then
        log_warning "Self-healing is disabled"
        return 1
    fi
    
    log_info "Attempting self-healing procedures"
    
    # Limpa recursos não utilizados
    docker system prune -f >/dev/null 2>&1
    
    # Reinicia containers unhealthy
    for container in $(docker ps -a --filter "health=unhealthy" --format "{{.Names}}"); do
        log_info "Restarting unhealthy container: $container"
        docker restart "$container" >/dev/null 2>&1
    done
    
    # Limpa cache do sistema
    sync && echo 3 > /proc/sys/vm/drop_caches
    
    log_info "Self-healing procedures completed"
}

run_health_check() {
    local current_time=$(date +%s)
    
    # Evita checks muito frequentes
    if (( current_time - LAST_CHECK_TIME < MONITOR_INTERVAL )); then
        return 0
    fi
    LAST_CHECK_TIME=$current_time
    
    # Executa checks principais
    check_docker_daemon || {
        log_error "Docker daemon check failed"
        return 1
    }
    
    check_container_count || {
        log_error "Container count check failed"
        return 1
    }
    
    check_system_resources || {
        log_error "System resources check failed"
        return 1
    }
    
    return 0
}

monitor_infrastructure() {
    log_info "Starting infrastructure monitoring"
    
    while true; do
        if run_health_check; then
            FAILURE_COUNT=0
            log_debug "Infrastructure health: OK"
        else
            ((FAILURE_COUNT++))
            log_warning "Health check failed (Attempt $FAILURE_COUNT/$MAX_CONSECUTIVE_FAILURES)"
            
            if [[ $FAILURE_COUNT -ge $MAX_CONSECUTIVE_FAILURES ]]; then
                log_critical "Infrastructure critical failure detected"
                attempt_self_healing
                FAILURE_COUNT=0
            fi
        fi
        
        sleep "$MONITOR_INTERVAL"
    done
}

get_monitoring_status() {
    if run_health_check; then
        echo "HEALTHY"
        return 0
    else
        echo "UNHEALTHY"
        return 1
    fi
}

# Gerencia sinais
trap 'log_info "Stopping infrastructure monitoring"; exit 0' SIGTERM SIGINT

# Processa comandos
case "${1:-status}" in
    "start")
        monitor_infrastructure &
        echo $! > /tmp/monitor_infrastructure.pid
        ;;
    "stop")
        if [[ -f /tmp/monitor_infrastructure.pid ]]; then
            kill $(cat /tmp/monitor_infrastructure.pid)
            rm /tmp/monitor_infrastructure.pid
        fi
        pkill -f "monitor_infrastructure"
        ;;
    "status")
        get_monitoring_status
        ;;
    *)
        echo "Usage: $0 {start|stop|status}"
        exit 1
        ;;
esac
