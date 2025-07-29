#!/bin/bash

# Importa funções de logging e utilitários
source "$(dirname "$0")/../../core/logger.sh"
source "$(dirname "$0")/../../core/utils.sh"

# Carrega configurações
CONFIG_FILE="$(dirname "$0")/config.json"
DOCKER_INFO_TIMEOUT=$(jq -r '.timeouts.docker_info' "$CONFIG_FILE")
MIN_DOCKER_VERSION="20.0.0"

check_docker_daemon() {
    log_info "Checking Docker daemon status..."
    if timeout "$DOCKER_INFO_TIMEOUT" docker info >/dev/null 2>&1; then
        log_debug "Docker daemon is accessible"
        return 0
    else
        log_error "Docker daemon is not accessible"
        return 1
    fi
}

check_docker_version() {
    local version=$(docker version --format '{{.Server.Version}}' 2>/dev/null)
    if [[ -z "$version" ]]; then
        log_error "Could not get Docker version"
        return 1
    fi

    if version_gt "$version" "$MIN_DOCKER_VERSION"; then
        log_debug "Docker version $version meets requirements"
        return 0
    else
        log_error "Docker version $version does not meet minimum requirement of $MIN_DOCKER_VERSION"
        return 1
    fi
}

check_docker_compose() {
    if command -v docker-compose >/dev/null 2>&1; then
        local compose_version=$(docker-compose version --short 2>/dev/null)
        log_debug "Docker Compose is available (version $compose_version)"
        return 0
    else
        if docker compose version >/dev/null 2>&1; then
            log_debug "Docker Compose V2 is available"
            return 0
        else
            log_error "Docker Compose is not available"
            return 1
        fi
    fi
}

run_docker_diagnostic() {
    local daemon_status="CRITICAL"
    local version_status="WARNING"
    local compose_status="WARNING"
    local version=""

    # Verifica daemon
    if check_docker_daemon; then
        daemon_status="HEALTHY"
    else
        return 1
    fi

    # Verifica versão
    version=$(docker version --format '{{.Server.Version}}' 2>/dev/null)
    if check_docker_version; then
        version_status="HEALTHY"
    fi

    # Verifica compose
    if check_docker_compose; then
        compose_status="HEALTHY"
    fi

    # Coleta versão do compose
    local compose_version
    compose_version=$(docker-compose version --short 2>/dev/null || docker compose version --short 2>/dev/null || echo 'N/A')

    # Gera saída JSON usando printf para garantir formatação correta
    printf '{
        "docker_daemon": {
            "status": "%s",
            "accessible": true,
            "version": "%s",
            "meets_requirements": %s
        },
        "docker_compose": {
            "available": %s,
            "version": "%s"
        }
    }\n' \
        "$daemon_status" \
        "$version" \
        "$([ "$version_status" = "HEALTHY" ] && echo true || echo false)" \
        "$([ "$compose_status" = "HEALTHY" ] && echo true || echo false)" \
        "$compose_version"

    return 0
}

# Monitora recursos do sistema
run_resource_monitoring() {
    local disk_usage=$(df / | awk 'NR==2 {print $5}' | sed 's/%//')
    local mem_info=$(free | awk '/Mem:/ {printf "%.1f", $3/$2 * 100}')
    local cpu_info=$(top -bn1 | awk '/%Cpu/ {printf "%.1f", 100 - $8}')

    echo "{
        \"system\": {
            \"disk_usage\": $disk_usage,
            \"memory_usage\": $mem_info,
            \"cpu_usage\": $cpu_info
        },
        \"timestamp\": \"$(date -u +"%Y-%m-%dT%H:%M:%SZ")\"
    }"
}

# Funções de ciclo de vida de containers
run_container_lifecycle() {
    local uptime_info="{}"
    if [[ -f "$CONFIG_FILE" ]]; then
        local containers=($(jq -r '.containers[]' "$CONFIG_FILE"))
        uptime_info="{"
        for container in "${containers[@]}"; do
            [[ "$uptime_info" != "{" ]] && uptime_info="$uptime_info,"
            local start_time=$(docker inspect --format='{{.State.StartedAt}}' "$container" 2>/dev/null || echo "")
            local restarts=$(docker inspect --format='{{.RestartCount}}' "$container" 2>/dev/null || echo "0")
            uptime_info="$uptime_info\"$container\": {\"start_time\": \"$start_time\", \"restarts\": $restarts}"
        done
        uptime_info="$uptime_info}"
    fi

    echo "{
        \"lifecycle\": $uptime_info,
        \"timestamp\": \"$(date -u +"%Y-%m-%dT%H:%M:%SZ")\"
    }"
}

# Se executado diretamente
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    run_docker_diagnostic
fi
