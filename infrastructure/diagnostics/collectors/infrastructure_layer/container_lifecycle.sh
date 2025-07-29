#!/bin/bash

# Importa funções de logging e utilitários
source "$(dirname "$0")/../../core/logger.sh"
source "$(dirname "$0")/../../core/utils.sh"

# Carrega configurações
CONFIG_FILE="$(dirname "$0")/config.json"
CONTAINERS=($(jq -r '.containers[]' "$CONFIG_FILE"))
HEALTH_CHECK_TIMEOUT=$(jq -r '.timeouts.health_check' "$CONFIG_FILE")

check_container_health() {
    local container="$1"
    local health_cmd="docker exec $container curl -f http://localhost/health"
    timeout $HEALTH_CHECK_TIMEOUT $health_cmd >/dev/null 2>&1
    return $?
}

check_restart_policy() {
    local container="$1"
    local policy=$(docker inspect --format='{{.HostConfig.RestartPolicy.Name}}' "$container")
    local max_attempts=$(docker inspect --format='{{.HostConfig.RestartPolicy.MaximumRetryCount}}' "$container")
    
    echo "{
        \"policy\": \"$policy\",
        \"max_attempts\": $max_attempts,
        \"valid\": $([ "$policy" == "always" ] || [ "$policy" == "unless-stopped" ] && echo "true" || echo "false")
    }"
}

check_resource_limits() {
    local container="$1"
    local cpu_limit=$(docker inspect --format='{{.HostConfig.NanoCpus}}' "$container")
    local memory_limit=$(docker inspect --format='{{.HostConfig.Memory}}' "$container")
    
    echo "{
        \"cpu_limit\": \"${cpu_limit:-unlimited}\",
        \"memory_limit\": \"${memory_limit:-unlimited}\",
        \"has_limits\": $([ "$cpu_limit" != "0" ] || [ "$memory_limit" != "0" ] && echo "true" || echo "false")
    }"
}

detect_container_drift() {
    local container="$1"
    local current_image=$(docker inspect --format='{{.Config.Image}}' "$container")
    local running_digest=$(docker inspect --format='{{.Image}}' "$container")
    local latest_digest=$(docker image inspect "${current_image}" --format='{{.Id}}')
    
    echo "{
        \"current_image\": \"$current_image\",
        \"is_latest\": $([ "$running_digest" == "$latest_digest" ] && echo "true" || echo "false")
    }"
}

attempt_container_recovery() {
    local container="$1"
    local status="$2"
    
    log_info "Attempting recovery for container: $container (Status: $status)"
    
    case "$status" in
        "unhealthy")
            log_debug "Restarting unhealthy container: $container"
            docker restart "$container"
            ;;
        "exited")
            log_debug "Starting stopped container: $container"
            docker start "$container"
            ;;
        *)
            log_warning "No recovery action defined for status: $status"
            return 1
            ;;
    esac
    
    # Aguarda e verifica se a recuperação foi bem sucedida
    sleep 5
    if docker ps -q -f name="$container" >/dev/null 2>&1; then
        log_info "Recovery successful for: $container"
        return 0
    else
        log_error "Recovery failed for: $container"
        return 1
    fi
}

run_container_lifecycle() {
    local results=()
    
    for container in "${CONTAINERS[@]}"; do
        log_info "Checking lifecycle for container: $container"
        
        local health_status="UNKNOWN"
        local recovery_needed=false
        local recovery_success=false
        
        # Coleta informações do container
        local restart_policy=$(check_restart_policy "$container")
        local resource_limits=$(check_resource_limits "$container")
        local drift_status=$(detect_container_drift "$container")
        
        # Verifica saúde do container
        if check_container_health "$container"; then
            health_status="HEALTHY"
        else
            health_status="UNHEALTHY"
            recovery_needed=true
        fi
        
        # Tenta recuperação se necessário
        if $recovery_needed; then
            if attempt_container_recovery "$container" "$health_status"; then
                recovery_success=true
            fi
        fi
        
        # Adiciona resultado do container
        results+=("{
            \"container\": \"$container\",
            \"health_status\": \"$health_status\",
            \"restart_policy\": $restart_policy,
            \"resource_limits\": $resource_limits,
            \"drift_status\": $drift_status,
            \"recovery\": {
                \"needed\": $recovery_needed,
                \"success\": $recovery_success
            }
        }")
    done
    
    # Gera saída JSON
    echo "{
        \"lifecycle_checks\": [
            $(IFS=,; echo "${results[*]}")
        ],
        \"timestamp\": \"$(date -u +"%Y-%m-%dT%H:%M:%SZ")\"
    }"
}

# Se executado diretamente
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    run_container_lifecycle
fi
