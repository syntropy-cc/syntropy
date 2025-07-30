#!/bin/bash

#===============================================================================
# INFRASTRUCTURE MONITORING SERVICE
#===============================================================================

# Importa dependências
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" &> /dev/null && pwd)"
CORE_DIR="$(cd "$SCRIPT_DIR/../../core" &> /dev/null && pwd)"
ENV_FILE="$(cd "$SCRIPT_DIR/../../../../" &> /dev/null && pwd)/.env"

source "$ENV_FILE" 2>/dev/null || log_warning "Environment file not found"
source "$CORE_DIR/logger.sh" || exit 1
source "$CORE_DIR/utils.sh" || exit 1

# Carrega configuração
CONFIG_FILE="$SCRIPT_DIR/config.json"
MONITOR_INTERVAL=$(jq -r '.monitoring.interval_seconds' "$CONFIG_FILE" 2>/dev/null || echo "300")
MAX_CONSECUTIVE_FAILURES=$(jq -r '.monitoring.max_consecutive_failures' "$CONFIG_FILE" 2>/dev/null || echo "3")
SELF_HEALING_ENABLED=$(jq -r '.monitoring.self_healing_enabled' "$CONFIG_FILE" 2>/dev/null || echo "true")

# Variáveis de estado
FAILURE_COUNT=0
LAST_CHECK_TIME=0
PID_FILE="/tmp/monitor_infrastructure.pid"
LOG_FILE="/tmp/monitor_infrastructure.log"

#===============================================================================
# HEALTH CHECK FUNCTIONS
#===============================================================================

check_docker_daemon() {
    log_debug "Checking Docker daemon health"
    
    if ! execute_with_timeout 10 "docker info" "Docker daemon health check"; then
        log_error "Docker daemon health check failed"
        return 1
    fi
    
    log_debug "Docker daemon health check passed"
    return 0
}

check_container_count() {
    log_debug "Checking container count"
    
    local min_containers
    min_containers=$(jq -r '.thresholds.min_running_containers' "$CONFIG_FILE" 2>/dev/null || echo "6")
    
    local running_count
    running_count=$(docker ps -q | wc -l)
    
    if [[ $running_count -ge $min_containers ]]; then
        log_debug "Container count check passed: $running_count >= $min_containers"
        return 0
    else
        log_warning "Container count check failed: $running_count < $min_containers"
        return 1
    fi
}

check_system_resources() {
    log_debug "Checking system resources"
    
    local cpu_critical
    cpu_critical=$(jq -r '.thresholds.cpu_critical' "$CONFIG_FILE" 2>/dev/null || echo "90")
    
    local mem_critical
    mem_critical=$(jq -r '.thresholds.memory_critical' "$CONFIG_FILE" 2>/dev/null || echo "95")
    
    local disk_critical
    disk_critical=$(jq -r '.thresholds.disk_critical' "$CONFIG_FILE" 2>/dev/null || echo "95")
    
    # CPU Check
    local cpu_usage
    cpu_usage=$(top -bn1 | grep "Cpu(s)" | awk '{print $2}' | tr -d '%us,' 2>/dev/null || echo "0")
    
    if [[ "${cpu_usage%.*}" -ge $cpu_critical ]]; then
        log_warning "CPU usage critical: ${cpu_usage%.*}% >= $cpu_critical%"
        return 1
    fi
    
    # Memory Check
    local mem_usage
    mem_usage=$(get_memory_usage 2>/dev/null || echo "0")
    
    if [[ "${mem_usage%.*}" -ge $mem_critical ]]; then
        log_warning "Memory usage critical: ${mem_usage%.*}% >= $mem_critical%"
        return 1
    fi
    
    # Disk Check
    local disk_usage
    disk_usage=$(get_disk_usage "/" 2>/dev/null || echo "0")
    
    if [[ $disk_usage -ge $disk_critical ]]; then
        log_warning "Disk usage critical: $disk_usage% >= $disk_critical%"
        return 1
    fi
    
    log_debug "System resources check passed"
    return 0
}

check_critical_containers() {
    log_debug "Checking critical containers"
    
    local critical_containers=()
    critical_containers=($(jq -r '.containers[]' "$CONFIG_FILE" 2>/dev/null || echo ""))
    
    local failed_containers=()
    
    for container in "${critical_containers[@]}"; do
        if [[ -n "$container" ]]; then
            if ! docker ps -q -f name="$container" >/dev/null 2>&1; then
                failed_containers+=("$container")
            fi
        fi
    done
    
    if [[ ${#failed_containers[@]} -eq 0 ]]; then
        log_debug "All critical containers are running"
        return 0
    else
        log_warning "Critical containers not running: ${failed_containers[*]}"
        return 1
    fi
}

#===============================================================================
# SELF-HEALING FUNCTIONS
#===============================================================================

attempt_self_healing() {
    if [[ "$SELF_HEALING_ENABLED" != "true" ]]; then
        log_warning "Self-healing is disabled"
        return 1
    fi
    
    log_info "Attempting self-healing procedures"
    
    local healing_success=false
    
    # Limpa recursos não utilizados do Docker
    log_debug "Cleaning up unused Docker resources"
    if docker system prune -f >/dev/null 2>&1; then
        log_debug "Docker cleanup completed"
        healing_success=true
    fi
    
    # Reinicia containers unhealthy
    log_debug "Restarting unhealthy containers"
    local restarted_count=0
    for container in $(docker ps -a --filter "health=unhealthy" --format "{{.Names}}" 2>/dev/null); do
        if docker restart "$container" >/dev/null 2>&1; then
            log_info "Successfully restarted unhealthy container: $container"
            ((restarted_count++))
            healing_success=true
        else
            log_error "Failed to restart unhealthy container: $container"
        fi
    done
    
    # Inicia containers parados
    log_debug "Starting stopped containers"
    for container in $(docker ps -a --filter "status=exited" --format "{{.Names}}" 2>/dev/null); do
        if docker start "$container" >/dev/null 2>&1; then
            log_info "Successfully started stopped container: $container"
            ((restarted_count++))
            healing_success=true
        else
            log_error "Failed to start stopped container: $container"
        fi
    done
    
    # Limpa cache do sistema se necessário
    local mem_usage
    mem_usage=$(get_memory_usage 2>/dev/null || echo "0")
    
    if [[ "${mem_usage%.*}" -gt 80 ]]; then
        log_debug "Memory usage high, clearing system cache"
        if sync && echo 3 > /proc/sys/vm/drop_caches 2>/dev/null; then
            log_debug "System cache cleared"
            healing_success=true
        fi
    fi
    
    if $healing_success; then
        log_info "Self-healing procedures completed successfully ($restarted_count containers affected)"
        return 0
    else
        log_warning "Self-healing procedures completed with no effect"
        return 1
    fi
}

#===============================================================================
# MONITORING FUNCTIONS
#===============================================================================

run_health_check() {
    local current_time=$(date +%s)
    
    # Evita checks muito frequentes
    if (( current_time - LAST_CHECK_TIME < MONITOR_INTERVAL )); then
        return 0
    fi
    LAST_CHECK_TIME=$current_time
    
    log_debug "Running infrastructure health check"
    
    local check_failed=false
    
    # Executa checks principais
    if ! check_docker_daemon; then
        check_failed=true
    fi
    
    if ! check_container_count; then
        check_failed=true
    fi
    
    if ! check_system_resources; then
        check_failed=true
    fi
    
    if ! check_critical_containers; then
        check_failed=true
    fi
    
    if $check_failed; then
        return 1
    else
        return 0
    fi
}

monitor_infrastructure() {
    log_info "Starting infrastructure monitoring service"
    log_info "Monitoring interval: ${MONITOR_INTERVAL}s"
    log_info "Max consecutive failures: $MAX_CONSECUTIVE_FAILURES"
    log_info "Self-healing enabled: $SELF_HEALING_ENABLED"
    
    # Registra PID
    echo $$ > "$PID_FILE"
    
    # Loop principal de monitoramento
    while true; do
        if run_health_check; then
            FAILURE_COUNT=0
            log_debug "Infrastructure health: OK"
        else
            ((FAILURE_COUNT++))
            log_warning "Health check failed (Attempt $FAILURE_COUNT/$MAX_CONSECUTIVE_FAILURES)"
            
            if [[ $FAILURE_COUNT -ge $MAX_CONSECUTIVE_FAILURES ]]; then
                log_critical "Infrastructure critical failure detected after $FAILURE_COUNT consecutive failures"
                
                if attempt_self_healing; then
                    log_info "Self-healing successful, resetting failure count"
                    FAILURE_COUNT=0
                else
                    log_error "Self-healing failed, maintaining failure count"
                fi
            fi
        fi
        
        sleep "$MONITOR_INTERVAL"
    done
}

#===============================================================================
# SERVICE MANAGEMENT
#===============================================================================

get_monitoring_status() {
    if [[ -f "$PID_FILE" ]]; then
        local pid
        pid=$(cat "$PID_FILE" 2>/dev/null || echo "")
        
        if [[ -n "$pid" ]] && kill -0 "$pid" 2>/dev/null; then
            if run_health_check; then
                echo "HEALTHY"
                return 0
            else
                echo "UNHEALTHY"
                return 1
            fi
        else
            echo "STOPPED"
            return 1
        fi
    else
        echo "NOT_RUNNING"
        return 1
    fi
}

start_monitoring() {
    log_info "Starting infrastructure monitoring service"
    
    if [[ -f "$PID_FILE" ]]; then
        local pid
        pid=$(cat "$PID_FILE" 2>/dev/null || echo "")
        
        if [[ -n "$pid" ]] && kill -0 "$pid" 2>/dev/null; then
            log_warning "Monitoring service is already running (PID: $pid)"
            return 1
        else
            rm -f "$PID_FILE"
        fi
    fi
    
    # Inicia monitoramento em background
    monitor_infrastructure &
    local monitor_pid=$!
    
    # Aguarda um pouco para verificar se iniciou corretamente
    sleep 2
    
    if kill -0 "$monitor_pid" 2>/dev/null; then
        echo "$monitor_pid" > "$PID_FILE"
        log_info "Monitoring service started successfully (PID: $monitor_pid)"
        return 0
    else
        log_error "Failed to start monitoring service"
        return 1
    fi
}

stop_monitoring() {
    log_info "Stopping infrastructure monitoring service"
    
    if [[ -f "$PID_FILE" ]]; then
        local pid
        pid=$(cat "$PID_FILE" 2>/dev/null || echo "")
        
        if [[ -n "$pid" ]] && kill -0 "$pid" 2>/dev/null; then
            if kill "$pid" 2>/dev/null; then
                log_info "Monitoring service stopped (PID: $pid)"
                rm -f "$PID_FILE"
                return 0
            else
                log_error "Failed to stop monitoring service (PID: $pid)"
                return 1
            fi
        else
            log_warning "Monitoring service is not running"
            rm -f "$PID_FILE"
            return 0
        fi
    else
        log_warning "No PID file found"
        return 0
    fi
}

restart_monitoring() {
    log_info "Restarting infrastructure monitoring service"
    
    stop_monitoring
    sleep 2
    start_monitoring
}

#===============================================================================
# SIGNAL HANDLING
#===============================================================================

cleanup() {
    log_info "Shutting down infrastructure monitoring"
    rm -f "$PID_FILE"
    exit 0
}

# Gerencia sinais
trap cleanup SIGTERM SIGINT

#===============================================================================
# MAIN EXECUTION
#===============================================================================

# Processa comandos
case "${1:-status}" in
    "start")
        start_monitoring
        ;;
    "stop")
        stop_monitoring
        ;;
    "restart")
        restart_monitoring
        ;;
    "status")
        get_monitoring_status
        ;;
    "health")
        if run_health_check; then
            echo "HEALTHY"
            exit 0
        else
            echo "UNHEALTHY"
            exit 1
        fi
        ;;
    *)
        echo "Usage: $0 {start|stop|restart|status|health}"
        echo ""
        echo "Commands:"
        echo "  start   - Start the monitoring service"
        echo "  stop    - Stop the monitoring service"
        echo "  restart - Restart the monitoring service"
        echo "  status  - Show service status"
        echo "  health  - Run health check and exit"
        exit 1
        ;;
esac
