#!/bin/bash

#===============================================================================
# CONTAINER STATUS DIAGNOSTIC
#===============================================================================

# Importa funções de logging e utilitários
MODULE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" &> /dev/null && pwd)"
CORE_DIR="$(cd "$MODULE_DIR/../../core" &> /dev/null && pwd)"
source "$CORE_DIR/logger.sh" || exit 1
source "$CORE_DIR/utils.sh" || exit 1

# Carrega configurações
CONFIG_FILE="$MODULE_DIR/config.json"
CONTAINERS=($(jq -r '.containers[]' "$CONFIG_FILE" 2>/dev/null || echo ""))
CHECK_TIMEOUT=$(jq -r '.timeouts.container_check' "$CONFIG_FILE" 2>/dev/null || echo "10")

#===============================================================================
# CONTAINER STATUS CHECKS
#===============================================================================

check_container_status() {
    local container="$1"
    log_debug "Checking container status: $container"

    # Verifica se o container existe e está rodando
    if ! docker ps -q -f name="$container" >/dev/null 2>&1; then
        log_warning "Container is not running: $container"
        echo "{\"running\":false,\"health\":\"CRITICAL\",\"uptime\":\"0\",\"restarts\":\"0\",\"cpu_usage\":0,\"memory_usage\":0,\"status\":\"stopped\"}"
        return 1
    fi

    # Coleta informações detalhadas do container
    local health
    health=$(docker inspect --format='{{.State.Health.Status}}' "$container" 2>/dev/null | tr -d '\n' || echo "none")
    
    local uptime
    uptime=$(docker inspect --format='{{.State.StartedAt}}' "$container" 2>/dev/null | tr -d '\n' || echo "")
    
    local restarts
    restarts=$(docker inspect --format='{{.RestartCount}}' "$container" 2>/dev/null | tr -d '\n' || echo "0")
    
    local status
    status=$(docker inspect --format='{{.State.Status}}' "$container" 2>/dev/null | tr -d '\n' || echo "unknown")

    # Verifica recursos (com timeout para evitar travamento)
    local cpu_usage="0"
    local mem_usage="0"
    
    if execute_with_timeout 5 "docker stats --no-stream --format '{{.CPUPerc}}' '$container'" "CPU stats for $container" >/dev/null 2>&1; then
        cpu_usage=$(docker stats --no-stream --format "{{.CPUPerc}}" "$container" 2>/dev/null | sed 's/%//' | tr -d '\n' || echo "0")
    fi
    
    if execute_with_timeout 5 "docker stats --no-stream --format '{{.MemPerc}}' '$container'" "Memory stats for $container" >/dev/null 2>&1; then
        mem_usage=$(docker stats --no-stream --format "{{.MemPerc}}" "$container" 2>/dev/null | sed 's/%//' | tr -d '\n' || echo "0")
    fi
    
    # Converte valores vazios para zero
    [[ -z "$cpu_usage" ]] && cpu_usage="0"
    [[ -z "$mem_usage" ]] && mem_usage="0"
    
    # Determina status de saúde
    local health_status="UNKNOWN"
    case "$health" in
        "healthy") health_status="HEALTHY" ;;
        "unhealthy") health_status="UNHEALTHY" ;;
        "starting") health_status="STARTING" ;;
        "none") health_status="NO_HEALTH_CHECK" ;;
        *) health_status="UNKNOWN" ;;
    esac
    
    echo "{\"running\":true,\"health\":\"$health_status\",\"uptime\":\"$uptime\",\"restarts\":\"$restarts\",\"cpu_usage\":$cpu_usage,\"memory_usage\":$mem_usage,\"status\":\"$status\"}"
    return 0
}

#===============================================================================
# CONTAINER HEALTH ANALYSIS
#===============================================================================

analyze_container_health() {
    local container="$1"
    local status_json="$2"
    
    local health_status
    health_status=$(echo "$status_json" | jq -r '.health' 2>/dev/null || echo "UNKNOWN")
    
    local restarts
    restarts=$(echo "$status_json" | jq -r '.restarts' 2>/dev/null || echo "0")
    
    local cpu_usage
    cpu_usage=$(echo "$status_json" | jq -r '.cpu_usage' 2>/dev/null || echo "0")
    
    local mem_usage
    mem_usage=$(echo "$status_json" | jq -r '.memory_usage' 2>/dev/null || echo "0")
    
    # Análise de saúde baseada em múltiplos critérios
    local health_score="HEALTHY"
    
    if [[ "$health_status" == "UNHEALTHY" ]]; then
        health_score="CRITICAL"
    elif [[ "$health_status" == "STARTING" ]]; then
        health_score="WARNING"
    elif [[ "$restarts" -gt 5 ]]; then
        health_score="WARNING"
    elif [[ "$cpu_usage" -gt 90 ]]; then
        health_score="WARNING"
    elif [[ "$mem_usage" -gt 90 ]]; then
        health_score="WARNING"
    fi
    
    echo "$health_score"
}

#===============================================================================
# CONTAINER RESOURCE MONITORING
#===============================================================================

get_container_resources() {
    local container="$1"
    
    # Coleta informações de recursos do container
    local cpu_limit
    cpu_limit=$(docker inspect --format='{{.HostConfig.NanoCpus}}' "$container" 2>/dev/null || echo "0")
    
    local memory_limit
    memory_limit=$(docker inspect --format='{{.HostConfig.Memory}}' "$container" 2>/dev/null || echo "0")
    
    local network_mode
    network_mode=$(docker inspect --format='{{.HostConfig.NetworkMode}}' "$container" 2>/dev/null || echo "default")
    
    # Converte limites para formato legível
    if [[ "$cpu_limit" -gt 0 ]]; then
        cpu_limit=$(echo "scale=2; $cpu_limit / 1000000000" | bc 2>/dev/null || echo "unlimited")
    else
        cpu_limit="unlimited"
    fi
    
    if [[ "$memory_limit" -gt 0 ]]; then
        memory_limit=$(echo "scale=2; $memory_limit / 1024 / 1024" | bc 2>/dev/null || echo "unlimited")
    else
        memory_limit="unlimited"
    fi
    
    echo "{\"cpu_limit\":\"$cpu_limit\",\"memory_limit\":\"$memory_limit\",\"network_mode\":\"$network_mode\"}"
}

#===============================================================================
# MAIN DIAGNOSTIC FUNCTION
#===============================================================================

run_container_diagnostic() {
    log_info "Starting container status diagnostic"
    
    # Verifica se há containers configurados
    if [[ ${#CONTAINERS[@]} -eq 0 ]] || [[ -z "${CONTAINERS[0]}" ]]; then
        log_error "No containers configured in config.json"
        echo "{\"status\":\"CRITICAL\",\"error\":\"No containers configured\",\"running_count\":0,\"total_count\":0,\"containers\":{},\"unhealthy_containers\":[]}"
        return 1
    fi
    
    local total_containers=${#CONTAINERS[@]}
    local running_containers=0
    local healthy_containers=0
    local unhealthy_containers=()
    local container_statuses="{"
    local overall_status="HEALTHY"

    log_debug "Checking $total_containers configured containers"

    for container in "${CONTAINERS[@]}"; do
        log_info "Checking container: $container"
        
        # Adiciona separador JSON se necessário
        if [[ "$container_statuses" != "{" ]]; then
            container_statuses="$container_statuses,"
        fi
        
        # Obtém status do container como JSON
        local status_json
        status_json=$(check_container_status "$container")
        
        # Adiciona ao objeto de containers
        container_statuses="$container_statuses\"$container\": $status_json"
        
        # Atualiza contadores
        if [[ $(echo "$status_json" | jq -r '.running' 2>/dev/null) == "true" ]]; then
            ((running_containers++))
            
            # Analisa saúde do container
            local health_score
            health_score=$(analyze_container_health "$container" "$status_json")
            
            if [[ "$health_score" == "HEALTHY" ]]; then
                ((healthy_containers++))
            else
                unhealthy_containers+=("$container")
            fi
        else
            unhealthy_containers+=("$container")
        fi
    done

    # Fecha o objeto de status dos containers
    container_statuses="$container_statuses}"

    # Determina status geral
    if [[ $running_containers -eq 0 ]]; then
        overall_status="CRITICAL"
    elif [[ $running_containers -lt $total_containers ]]; then
        overall_status="WARNING"
    elif [[ ${#unhealthy_containers[@]} -gt 0 ]]; then
        overall_status="WARNING"
    else
        overall_status="HEALTHY"
    fi

    # Prepara lista de containers não saudáveis
    local unhealthy_list
    if [[ ${#unhealthy_containers[@]} -eq 0 ]]; then
        unhealthy_list="[]"
    else
        unhealthy_list="[$(printf '"%s",' "${unhealthy_containers[@]}" | sed 's/,$/')]"
    fi

    # Gera saída JSON final
    cat << EOF
{
    "status": "$overall_status",
    "running_count": $running_containers,
    "total_count": $total_containers,
    "healthy_count": $healthy_containers,
    "unhealthy_count": ${#unhealthy_containers[@]},
    "containers": $container_statuses,
    "unhealthy_containers": $unhealthy_list,
    "metadata": {
        "timestamp": "$(date -u +"%Y-%m-%dT%H:%M:%SZ")",
        "timeout_seconds": $CHECK_TIMEOUT,
        "containers_checked": $total_containers
    }
}
EOF

    # Retorna sucesso apenas se todos os containers estiverem rodando e saudáveis
    if [[ $running_containers -eq $total_containers ]] && [[ ${#unhealthy_containers[@]} -eq 0 ]]; then
        log_info "Container diagnostic completed successfully - all containers healthy"
        return 0
    else
        log_warning "Container diagnostic completed with issues - $running_containers/$total_containers running, ${#unhealthy_containers[@]} unhealthy"
        return 1
    fi
}

#===============================================================================
# EXECUTION
#===============================================================================

# Se executado diretamente
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    run_container_diagnostic
fi
