#!/bin/bash

# Importa funções de logging e utilitários
source "$(dirname "$0")/../../core/logger.sh"
source "$(dirname "$0")/../../core/utils.sh"

# Carrega configurações
CONFIG_FILE="$(dirname "$0")/config.json"
CONTAINERS=($(jq -r '.containers[]' "$CONFIG_FILE"))
CHECK_TIMEOUT=$(jq -r '.timeouts.container_check' "$CONFIG_FILE")

check_container_status() {
    local container="$1"

    # Verifica se o container está rodando
    if ! docker ps -q -f name="$container" >/dev/null 2>&1; then
        echo "{\"running\":false,\"health\":\"CRITICAL\",\"uptime\":\"0\",\"restarts\":\"N/A\",\"cpu_usage\":0,\"memory_usage\":0}"
        return 1
    fi

    # Coleta informações detalhadas
    local health
    health=$(docker inspect --format='{{.State.Health.Status}}' "$container" 2>/dev/null | tr -d '\n' || echo "none")
    local uptime
    uptime=$(docker inspect --format='{{.State.StartedAt}}' "$container" 2>/dev/null | tr -d '\n' || echo "")
    local restarts
    restarts=$(docker inspect --format='{{.RestartCount}}' "$container" 2>/dev/null | tr -d '\n' || echo "0")

    # Verifica recursos
    local cpu_usage
    cpu_usage=$(docker stats --no-stream --format "{{.CPUPerc}}" "$container" 2>/dev/null | sed 's/%//' | tr -d '\n' || echo "0")
    local mem_usage
    mem_usage=$(docker stats --no-stream --format "{{.MemPerc}}" "$container" 2>/dev/null | sed 's/%//' | tr -d '\n' || echo "0")
    
    # Convert empty values to zero
    [[ -z "$cpu_usage" ]] && cpu_usage="0"
    [[ -z "$mem_usage" ]] && mem_usage="0"
    
    echo "{\"running\":true,\"health\":\"$health\",\"uptime\":\"$uptime\",\"restarts\":\"$restarts\",\"cpu_usage\":$cpu_usage,\"memory_usage\":$mem_usage}"
    return 0
}

run_container_diagnostic() {
    local total_containers=${#CONTAINERS[@]}
    local running_containers=0
    local unhealthy_containers=()
    local container_statuses="{"

    for container in "${CONTAINERS[@]}"; do
        log_info "Checking container: $container"
        
        if [[ -n "$container_statuses" && "$container_statuses" != "{" ]]; then
            container_statuses="$container_statuses,"
        fi
        
        # Get container status as JSON
        local status_json
        status_json=$(check_container_status "$container")
        
        # Add to containers object
        container_statuses="$container_statuses\"$container\": $status_json"
        
        # Update counters
        if [[ $(echo "$status_json" | jq -r '.running') == "true" ]]; then
            ((running_containers++))
            if [[ $(echo "$status_json" | jq -r '.health') != "healthy" ]]; then
                unhealthy_containers+=("$container")
            fi
        fi
    done

    # Close the container statuses object
    container_statuses="$container_statuses}"

    # Generate final JSON output
    local unhealthy_list
    if [[ ${#unhealthy_containers[@]} -eq 0 ]]; then
        unhealthy_list="[]"
    else
        unhealthy_list="[$(printf '"%s",' "${unhealthy_containers[@]}" | sed 's/,$/')]"
    fi

    echo "{
        \"status\": \"$([ $running_containers -eq $total_containers ] && echo 'HEALTHY' || echo 'CRITICAL')\",
        \"running_count\": $running_containers,
        \"total_count\": $total_containers,
        \"containers\": $container_statuses,
        \"unhealthy_containers\": $unhealthy_list
    }"

    # Retorna sucesso apenas se todos os containers estiverem rodando
    return $(( running_containers != total_containers ))
}

# Se executado diretamente
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    run_container_diagnostic
fi
