#!/bin/bash

# Importa funções de logging e utilitários
source "$(dirname "$0")/../../core/logger.sh"
source "$(dirname "$0")/../../core/utils.sh"

# Carrega configurações
CONFIG_FILE="$(dirname "$0")/config.json"
CONTAINERS=($(jq -r '.containers[]' "$CONFIG_FILE" 2>/dev/null || echo ""))
HEALTH_CHECK_TIMEOUT=$(jq -r '.timeouts.health_check // 5' "$CONFIG_FILE" 2>/dev/null)

check_container_health() {
    local container="$1"
    
    # Verifica se o container está rodando primeiro
    if ! docker ps -q -f name="$container" >/dev/null 2>&1; then
        return 1
    fi
    
    # Tenta diferentes métodos de health check
    
    # Método 1: Docker health check nativo
    local health_status=$(docker inspect --format='{{.State.Health.Status}}' "$container" 2>/dev/null)
    if [[ "$health_status" == "healthy" ]]; then
        return 0
    elif [[ "$health_status" == "unhealthy" ]]; then
        return 1
    fi
    
    # Método 2: Verifica se o processo principal está rodando
    local main_pid=$(docker inspect --format='{{.State.Pid}}' "$container" 2>/dev/null)
    if [[ -n "$main_pid" ]] && [[ "$main_pid" != "0" ]] && kill -0 "$main_pid" 2>/dev/null; then
        return 0
    fi
    
    # Método 3: Verifica logs para erros recentes
    local recent_logs=$(docker logs "$container" --since=30s 2>&1 | grep -i "error\|fatal\|exception" | wc -l)
    if [[ "$recent_logs" -gt 5 ]]; then
        return 1
    fi
    
    # Se chegou aqui, considera saudável por padrão
    return 0
}

check_restart_policy() {
    local container="$1"
    
    if ! docker ps -a -q -f name="$container" >/dev/null 2>&1; then
        echo '{"policy": "unknown", "max_attempts": 0, "valid": false}'
        return
    fi
    
    local policy=$(docker inspect --format='{{.HostConfig.RestartPolicy.Name}}' "$container" 2>/dev/null || echo "no")
    local max_attempts=$(docker inspect --format='{{.HostConfig.RestartPolicy.MaximumRetryCount}}' "$container" 2>/dev/null || echo "0")
    
    local is_valid="false"
    if [[ "$policy" == "always" ]] || [[ "$policy" == "unless-stopped" ]] || [[ "$policy" == "on-failure" ]]; then
        is_valid="true"
    fi
    
    echo "{
        \"policy\": \"$policy\",
        \"max_attempts\": $max_attempts,
        \"valid\": $is_valid
    }"
}

check_resource_limits() {
    local container="$1"
    
    if ! docker ps -a -q -f name="$container" >/dev/null 2>&1; then
        echo '{"cpu_limit": "unlimited", "memory_limit": "unlimited", "has_limits": false}'
        return
    fi
    
    local cpu_limit=$(docker inspect --format='{{.HostConfig.NanoCpus}}' "$container" 2>/dev/null || echo "0")
    local memory_limit=$(docker inspect --format='{{.HostConfig.Memory}}' "$container" 2>/dev/null || echo "0")
    
    # Converte para formato legível
    local cpu_readable="unlimited"
    local memory_readable="unlimited"
    local has_limits="false"
    
    if [[ "$cpu_limit" != "0" ]] && [[ -n "$cpu_limit" ]]; then
        cpu_readable="${cpu_limit}"
        has_limits="true"
    fi
    
    if [[ "$memory_limit" != "0" ]] && [[ -n "$memory_limit" ]]; then
        memory_readable="${memory_limit}"
        has_limits="true"
    fi
    
    echo "{
        \"cpu_limit\": \"$cpu_readable\",
        \"memory_limit\": \"$memory_readable\",
        \"has_limits\": $has_limits
    }"
}

detect_container_drift() {
    local container="$1"
    
    if ! docker ps -a -q -f name="$container" >/dev/null 2>&1; then
        echo '{"current_image": "unknown", "is_latest": false}'
        return
    fi
    
    local current_image=$(docker inspect --format='{{.Config.Image}}' "$container" 2>/dev/null || echo "unknown")
    local running_digest=$(docker inspect --format='{{.Image}}' "$container" 2>/dev/null || echo "")
    
    # Tenta obter o digest da imagem mais recente
    local latest_digest=""
    if [[ "$current_image" != "unknown" ]]; then
        latest_digest=$(docker image inspect "$current_image" --format='{{.Id}}' 2>/dev/null || echo "")
    fi
    
    local is_latest="false"
    if [[ -n "$running_digest" ]] && [[ -n "$latest_digest" ]] && [[ "$running_digest" == "$latest_digest" ]]; then
        is_latest="true"
    fi
    
    echo "{
        \"current_image\": \"$current_image\",
        \"is_latest\": $is_latest
    }"
}

attempt_container_recovery() {
    local container="$1"
    local status="$2"
    
    log_info "Attempting recovery for container: $container (Status: $status)"
    
    # Verifica se auto-healing está habilitado
    local self_healing=$(jq -r '.monitoring.self_healing_enabled // false' "$CONFIG_FILE" 2>/dev/null)
    if [[ "$self_healing" != "true" ]]; then
        log_info "Self-healing is disabled, skipping recovery"
        return 1
    fi
    
    case "$status" in
        "unhealthy"|"UNHEALTHY")
            log_debug "Restarting unhealthy container: $container"
            if docker restart "$container" >/dev/null 2>&1; then
                sleep 10  # Aguarda mais tempo para estabilizar
                return 0
            fi
            ;;
        "exited"|"stopped")
            log_debug "Starting stopped container: $container"
            if docker start "$container" >/dev/null 2>&1; then
                sleep 5
                return 0
            fi
            ;;
        *)
            log_warning "No recovery action defined for status: $status"
            return 1
            ;;
    esac
    
    return 1
}

run_container_lifecycle() {
    local results=()
    
    # Verifica se há containers para verificar
    if [[ ${#CONTAINERS[@]} -eq 0 ]]; then
        log_warning "No containers configured for lifecycle checks"
        echo '{
            "lifecycle_checks": [],
            "timestamp": "'$(date -u +"%Y-%m-%dT%H:%M:%SZ")'",
            "error": "No containers configured"
        }'
        return 0
    fi
    
    for container in "${CONTAINERS[@]}"; do
        # Pula containers vazios
        [[ -z "$container" ]] && continue
        
        log_info "Checking lifecycle for container: $container"
        
        local health_status="UNKNOWN"
        local recovery_needed=false
        local recovery_success=false
        
        # Verifica se o container existe
        if ! docker ps -a -q -f name="$container" >/dev/null 2>&1; then
            log_warning "Container not found: $container"
            health_status="NOT_FOUND"
        else
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
            if [[ "$recovery_needed" == true ]]; then
                if attempt_container_recovery "$container" "$health_status"; then
                    recovery_success=true
                    health_status="RECOVERED"
                fi
            fi
        fi
        
        # Adiciona resultado do container (usando JSON seguro)
        local container_result="{
            \"container\": \"$container\",
            \"health_status\": \"$health_status\",
            \"restart_policy\": $restart_policy,
            \"resource_limits\": $resource_limits,
            \"drift_status\": $drift_status,
            \"recovery\": {
                \"needed\": $recovery_needed,
                \"success\": $recovery_success
            }
        }"
        
        results+=("$container_result")
    done
    
    # Gera saída JSON final
    local final_json="{
        \"lifecycle_checks\": ["
    
    # Adiciona resultados separados por vírgula
    for i in "${!results[@]}"; do
        [[ $i -gt 0 ]] && final_json+=","
        final_json+="${results[$i]}"
    done
    
    final_json+="],
        \"timestamp\": \"$(date -u +"%Y-%m-%dT%H:%M:%SZ")\"
    }"
    
    # Valida JSON antes de retornar
    if echo "$final_json" | jq '.' >/dev/null 2>&1; then
        echo "$final_json"
    else
        log_error "Generated invalid JSON in container lifecycle"
        echo '{
            "lifecycle_checks": [],
            "timestamp": "'$(date -u +"%Y-%m-%dT%H:%M:%SZ")'",
            "error": "Failed to generate valid JSON"
        }'
    fi
}

# Se executado diretamente
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    run_container_lifecycle
fi