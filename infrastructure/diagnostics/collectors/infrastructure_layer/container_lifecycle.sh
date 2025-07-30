#!/bin/bash

#===============================================================================
# CONTAINER LIFECYCLE DIAGNOSTIC
#===============================================================================

# Importa funções de logging e utilitários
MODULE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" &> /dev/null && pwd)"
CORE_DIR="$(cd "$MODULE_DIR/../../core" &> /dev/null && pwd)"
source "$CORE_DIR/logger.sh" || exit 1
source "$CORE_DIR/utils.sh" || exit 1

# Carrega configurações
CONFIG_FILE="$MODULE_DIR/config.json"
CONTAINERS=($(jq -r '.containers[]' "$CONFIG_FILE" 2>/dev/null || echo ""))
HEALTH_CHECK_TIMEOUT=$(jq -r '.timeouts.health_check' "$CONFIG_FILE" 2>/dev/null || echo "5")

#===============================================================================
# CONTAINER HEALTH CHECKS
#===============================================================================

check_container_health() {
    local container="$1"
    log_debug "Checking health for container: $container"
    
    # Verifica se o container está rodando
    if ! docker ps -q -f name="$container" >/dev/null 2>&1; then
        log_warning "Container is not running: $container"
        return 1
    fi
    
    # Tenta executar health check interno se disponível
    local health_cmd="docker exec $container curl -f http://localhost/health"
    
    if execute_with_timeout "$HEALTH_CHECK_TIMEOUT" "$health_cmd" "Health check for $container" >/dev/null 2>&1; then
        log_debug "Health check passed for: $container"
        return 0
    else
        log_warning "Health check failed for: $container"
        return 1
    fi
}

#===============================================================================
# CONTAINER CONFIGURATION CHECKS
#===============================================================================

check_restart_policy() {
    local container="$1"
    log_debug "Checking restart policy for container: $container"
    
    local policy
    policy=$(docker inspect --format='{{.HostConfig.RestartPolicy.Name}}' "$container" 2>/dev/null || echo "no")
    
    local max_attempts
    max_attempts=$(docker inspect --format='{{.HostConfig.RestartPolicy.MaximumRetryCount}}' "$container" 2>/dev/null || echo "0")
    
    # Valida se a política é adequada
    local valid=false
    case "$policy" in
        "always"|"unless-stopped") valid=true ;;
        *) valid=false ;;
    esac
    
    cat << EOF
{
    "policy": "$policy",
    "max_attempts": $max_attempts,
    "valid": $valid,
    "recommended": $([ "$policy" == "always" ] && echo "true" || echo "false")
}
EOF
}

check_resource_limits() {
    local container="$1"
    log_debug "Checking resource limits for container: $container"
    
    local cpu_limit
    cpu_limit=$(docker inspect --format='{{.HostConfig.NanoCpus}}' "$container" 2>/dev/null || echo "0")
    
    local memory_limit
    memory_limit=$(docker inspect --format='{{.HostConfig.Memory}}' "$container" 2>/dev/null || echo "0")
    
    local memory_swap_limit
    memory_swap_limit=$(docker inspect --format='{{.HostConfig.MemorySwap}}' "$container" 2>/dev/null || echo "0")
    
    # Converte para formato legível
    local cpu_limit_readable
    if [[ "$cpu_limit" -gt 0 ]]; then
        cpu_limit_readable=$(echo "scale=2; $cpu_limit / 1000000000" | bc 2>/dev/null || echo "unlimited")
    else
        cpu_limit_readable="unlimited"
    fi
    
    local memory_limit_readable
    if [[ "$memory_limit" -gt 0 ]]; then
        memory_limit_readable=$(echo "scale=2; $memory_limit / 1024 / 1024" | bc 2>/dev/null || echo "unlimited")
    else
        memory_limit_readable="unlimited"
    fi
    
    local memory_swap_readable
    if [[ "$memory_swap_limit" -gt 0 ]]; then
        memory_swap_readable=$(echo "scale=2; $memory_swap_limit / 1024 / 1024" | bc 2>/dev/null || echo "unlimited")
    else
        memory_swap_readable="unlimited"
    fi
    
    # Verifica se há limites configurados
    local has_limits=false
    if [[ "$cpu_limit" -gt 0 ]] || [[ "$memory_limit" -gt 0 ]]; then
        has_limits=true
    fi
    
    cat << EOF
{
    "cpu_limit": "$cpu_limit_readable",
    "memory_limit": "$memory_limit_readable",
    "memory_swap_limit": "$memory_swap_readable",
    "has_limits": $has_limits,
    "recommended": $has_limits
}
EOF
}

#===============================================================================
# CONTAINER DRIFT DETECTION
#===============================================================================

detect_container_drift() {
    local container="$1"
    log_debug "Detecting drift for container: $container"
    
    local current_image
    current_image=$(docker inspect --format='{{.Config.Image}}' "$container" 2>/dev/null || echo "")
    
    local running_digest
    running_digest=$(docker inspect --format='{{.Image}}' "$container" 2>/dev/null || echo "")
    
    local latest_digest
    latest_digest=$(docker image inspect "${current_image}" --format='{{.Id}}' 2>/dev/null || echo "")
    
    local is_latest=false
    if [[ "$running_digest" == "$latest_digest" ]] && [[ -n "$running_digest" ]]; then
        is_latest=true
    fi
    
    # Coleta informações de criação da imagem
    local image_created
    image_created=$(docker image inspect "${current_image}" --format='{{.Created}}' 2>/dev/null || echo "")
    
    local image_size
    image_size=$(docker image inspect "${current_image}" --format='{{.Size}}' 2>/dev/null || echo "0")
    
    cat << EOF
{
    "current_image": "$current_image",
    "is_latest": $is_latest,
    "image_created": "$image_created",
    "image_size_bytes": $image_size,
    "recommended": $is_latest
}
EOF
}

#===============================================================================
# CONTAINER RECOVERY
#===============================================================================

attempt_container_recovery() {
    local container="$1"
    local status="$2"
    
    log_info "Attempting recovery for container: $container (Status: $status)"
    
    case "$status" in
        "unhealthy")
            log_debug "Restarting unhealthy container: $container"
            if docker restart "$container" >/dev/null 2>&1; then
                log_info "Successfully restarted container: $container"
                return 0
            else
                log_error "Failed to restart container: $container"
                return 1
            fi
            ;;
        "exited")
            log_debug "Starting stopped container: $container"
            if docker start "$container" >/dev/null 2>&1; then
                log_info "Successfully started container: $container"
                return 0
            else
                log_error "Failed to start container: $container"
                return 1
            fi
            ;;
        *)
            log_warning "No recovery action defined for status: $status"
            return 1
            ;;
    esac
}

#===============================================================================
# CONTAINER UPTIME ANALYSIS
#===============================================================================

analyze_container_uptime() {
    local container="$1"
    
    local start_time
    start_time=$(docker inspect --format='{{.State.StartedAt}}' "$container" 2>/dev/null || echo "")
    
    local restarts
    restarts=$(docker inspect --format='{{.RestartCount}}' "$container" 2>/dev/null || echo "0")
    
    # Calcula uptime se possível
    local uptime_seconds="0"
    if [[ -n "$start_time" ]]; then
        local start_timestamp
        start_timestamp=$(date -d "$start_time" +%s 2>/dev/null || echo "0")
        local current_timestamp
        current_timestamp=$(date +%s)
        uptime_seconds=$((current_timestamp - start_timestamp))
    fi
    
    # Converte para formato legível
    local uptime_readable
    if [[ $uptime_seconds -gt 0 ]]; then
        local days=$((uptime_seconds / 86400))
        local hours=$(((uptime_seconds % 86400) / 3600))
        local minutes=$(((uptime_seconds % 3600) / 60))
        uptime_readable="${days}d ${hours}h ${minutes}m"
    else
        uptime_readable="0d 0h 0m"
    fi
    
    # Analisa estabilidade
    local stability="STABLE"
    if [[ $restarts -gt 5 ]]; then
        stability="UNSTABLE"
    elif [[ $restarts -gt 2 ]]; then
        stability="WARNING"
    fi
    
    cat << EOF
{
    "start_time": "$start_time",
    "uptime_seconds": $uptime_seconds,
    "uptime_readable": "$uptime_readable",
    "restarts": $restarts,
    "stability": "$stability"
}
EOF
}

#===============================================================================
# MAIN DIAGNOSTIC FUNCTION
#===============================================================================

run_container_lifecycle() {
    log_info "Starting container lifecycle diagnostic"
    
    # Verifica se há containers configurados
    if [[ ${#CONTAINERS[@]} -eq 0 ]] || [[ -z "${CONTAINERS[0]}" ]]; then
        log_error "No containers configured in config.json"
        echo "{\"error\":\"No containers configured\",\"lifecycle_checks\":[],\"metadata\":{\"timestamp\":\"$(date -u +"%Y-%m-%dT%H:%M:%SZ")\"}}"
        return 1
    fi
    
    local results=()
    local total_containers=${#CONTAINERS[@]}
    local healthy_containers=0
    local recovery_attempts=0
    local recovery_successes=0
    
    log_debug "Checking lifecycle for $total_containers containers"

    for container in "${CONTAINERS[@]}"; do
        log_info "Checking lifecycle for container: $container"
        
        local health_status="UNKNOWN"
        local recovery_needed=false
        local recovery_success=false
        local container_status="unknown"
        
        # Verifica se o container existe
        if docker ps -a -q -f name="$container" >/dev/null 2>&1; then
            container_status=$(docker inspect --format='{{.State.Status}}' "$container" 2>/dev/null || echo "unknown")
        else
            log_warning "Container does not exist: $container"
            container_status="not_found"
        fi
        
        # Coleta informações de configuração
        local restart_policy="{}"
        local resource_limits="{}"
        local drift_status="{}"
        local uptime_info="{}"
        
        if [[ "$container_status" != "not_found" ]]; then
            restart_policy=$(check_restart_policy "$container")
            resource_limits=$(check_resource_limits "$container")
            drift_status=$(detect_container_drift "$container")
            uptime_info=$(analyze_container_uptime "$container")
        fi
        
        # Verifica saúde do container
        if [[ "$container_status" == "running" ]]; then
            if check_container_health "$container"; then
                health_status="HEALTHY"
                ((healthy_containers++))
            else
                health_status="UNHEALTHY"
                recovery_needed=true
            fi
        elif [[ "$container_status" == "exited" ]]; then
            health_status="STOPPED"
            recovery_needed=true
        else
            health_status="UNKNOWN"
        fi
        
        # Tenta recuperação se necessário
        if $recovery_needed; then
            ((recovery_attempts++))
            if attempt_container_recovery "$container" "$health_status"; then
                recovery_success=true
                ((recovery_successes++))
                
                # Aguarda e verifica se a recuperação foi bem sucedida
                sleep 3
                if check_container_health "$container" 2>/dev/null; then
                    health_status="HEALTHY"
                    ((healthy_containers++))
                fi
            fi
        fi
        
        # Adiciona resultado do container
        results+=("{
            \"container\": \"$container\",
            \"status\": \"$container_status\",
            \"health_status\": \"$health_status\",
            \"restart_policy\": $restart_policy,
            \"resource_limits\": $resource_limits,
            \"drift_status\": $drift_status,
            \"uptime\": $uptime_info,
            \"recovery\": {
                \"needed\": $recovery_needed,
                \"attempted\": $recovery_needed,
                \"success\": $recovery_success
            }
        }")
    done
    
    # Determina status geral
    local overall_status="HEALTHY"
    if [[ $healthy_containers -eq 0 ]]; then
        overall_status="CRITICAL"
    elif [[ $healthy_containers -lt $total_containers ]]; then
        overall_status="WARNING"
    fi
    
    # Gera saída JSON
    cat << EOF
{
    "status": "$overall_status",
    "lifecycle_checks": [
        $(IFS=,; echo "${results[*]}")
    ],
    "summary": {
        "total_containers": $total_containers,
        "healthy_containers": $healthy_containers,
        "recovery_attempts": $recovery_attempts,
        "recovery_successes": $recovery_successes
    },
    "metadata": {
        "timestamp": "$(date -u +"%Y-%m-%dT%H:%M:%SZ")",
        "timeout_seconds": $HEALTH_CHECK_TIMEOUT,
        "containers_checked": $total_containers
    }
}
EOF
    
    # Retorna código de saída baseado no status geral
    if [[ "$overall_status" == "HEALTHY" ]]; then
        log_info "Container lifecycle diagnostic completed successfully - all containers healthy"
        return 0
    elif [[ "$overall_status" == "WARNING" ]]; then
        log_warning "Container lifecycle diagnostic completed with warnings - $healthy_containers/$total_containers healthy"
        return 0
    else
        log_error "Container lifecycle diagnostic completed with critical issues - $healthy_containers/$total_containers healthy"
        return 1
    fi
}

#===============================================================================
# EXECUTION
#===============================================================================

# Se executado diretamente
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    run_container_lifecycle
fi
