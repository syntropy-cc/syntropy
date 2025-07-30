#!/bin/bash

#===============================================================================
# DOCKER ENVIRONMENT DIAGNOSTIC
#===============================================================================

# Importa funções de logging e utilitários
MODULE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" &> /dev/null && pwd)"
CORE_DIR="$(cd "$MODULE_DIR/../../core" &> /dev/null && pwd)"
source "$CORE_DIR/logger.sh" || exit 1
source "$CORE_DIR/utils.sh" || exit 1
# Carrega configurações
CONFIG_FILE="$MODULE_DIR/config.json"
DOCKER_INFO_TIMEOUT=$(jq -r '.timeouts.docker_info' "$CONFIG_FILE" 2>/dev/null || echo "15")
MIN_DOCKER_VERSION="20.0.0"

#===============================================================================
# DOCKER DAEMON CHECKS
#===============================================================================

check_docker_daemon() {
    log_debug "Checking Docker daemon accessibility"
    
    if ! execute_with_timeout "$DOCKER_INFO_TIMEOUT" "docker info" "Docker daemon check"; then
        log_error "Docker daemon is not accessible (timeout: ${DOCKER_INFO_TIMEOUT}s)"
        return 1
    fi
    
    log_debug "Docker daemon is accessible"
    return 0
}

check_docker_version() {
    log_debug "Checking Docker version compatibility"
    
    local version
    version=$(docker version --format '{{.Server.Version}}' 2>/dev/null)
    
    if [[ -z "$version" ]]; then
        log_error "Could not retrieve Docker version"
        return 1
    fi

    if version_gt "$version" "$MIN_DOCKER_VERSION" || version_gte "$version" "$MIN_DOCKER_VERSION"; then
        log_debug "Docker version $version meets minimum requirement ($MIN_DOCKER_VERSION)"
        return 0
    else
        log_error "Docker version $version does not meet minimum requirement ($MIN_DOCKER_VERSION)"
        return 1
    fi
}

check_docker_api_response() {
    log_debug "Checking Docker API response time"
    
    local start_time=$(date +%s%3N)
    
    if docker info >/dev/null 2>&1; then
        local end_time=$(date +%s%3N)
        local response_time=$((end_time - start_time))
        echo "$response_time"
        return 0
    else
        log_error "Docker API is not responding"
        return 1
    fi
}

#===============================================================================
# DOCKER COMPOSE CHECKS
#===============================================================================

check_docker_compose() {
    log_debug "Checking Docker Compose availability"
    
    # Tenta Docker Compose V2 primeiro (recomendado)
    if docker compose version >/dev/null 2>&1; then
        local compose_version
        compose_version=$(docker compose version --short 2>/dev/null || echo "V2")
        log_debug "Docker Compose V2 is available (version: $compose_version)"
        echo "v2:$compose_version"
        return 0
    fi
    
    # Fallback para Docker Compose V1
    if command -v docker-compose >/dev/null 2>&1; then
        local compose_version
        compose_version=$(docker-compose version --short 2>/dev/null || echo "V1")
        log_debug "Docker Compose V1 is available (version: $compose_version)"
        echo "v1:$compose_version"
        return 0
    fi
    
    log_warning "Docker Compose is not available"
    return 1
}

#===============================================================================
# DOCKER SYSTEM CHECKS
#===============================================================================

check_docker_system_info() {
    log_debug "Collecting Docker system information"
    
    local system_info="{}"
    
    # Coleta informações do sistema Docker
    if docker info >/dev/null 2>&1; then
        local containers_count
        containers_count=$(docker ps -q | wc -l)
        
        local images_count
        images_count=$(docker images -q | wc -l)
        
        local volumes_count
        volumes_count=$(docker volume ls -q | wc -l)
        
        local networks_count
        networks_count=$(docker network ls -q | wc -l)
        
        system_info=$(cat << EOF
{
    "containers_running": $containers_count,
    "images_count": $images_count,
    "volumes_count": $volumes_count,
    "networks_count": $networks_count
}
EOF
)
    fi
    
    echo "$system_info"
}

#===============================================================================
# MAIN DIAGNOSTIC FUNCTION
#===============================================================================

run_docker_diagnostic() {
    log_info "Starting Docker environment diagnostic"
    
    local daemon_status="CRITICAL"
    local version_status="WARNING"
    local compose_status="WARNING"
    local version=""
    local compose_version="N/A"
    local response_time="0"
    local system_info="{}"
    
    # Verifica daemon
    if check_docker_daemon; then
        daemon_status="HEALTHY"
        
        # Coleta versão
        version=$(docker version --format '{{.Server.Version}}' 2>/dev/null || echo "UNKNOWN")
        
        # Verifica compatibilidade da versão
        if check_docker_version; then
            version_status="HEALTHY"
        fi
        
        # Verifica tempo de resposta da API
        response_time=$(check_docker_api_response || echo "0")
        
        # Coleta informações do sistema
        system_info=$(check_docker_system_info)
    else
        log_error "Docker daemon check failed - cannot proceed with other checks"
        daemon_status="CRITICAL"
        version="UNKNOWN"
    fi
    
    # Verifica Docker Compose (independente do daemon)
    local compose_result
    if compose_result=$(check_docker_compose 2>/dev/null); then
        compose_status="HEALTHY"
        compose_version="$compose_result"
    fi
    
    # Gera saída JSON estruturada
    cat << EOF
{
    "docker_daemon": {
        "status": "$daemon_status",
        "accessible": $([ "$daemon_status" = "HEALTHY" ] && echo "true" || echo "false"),
        "version": "$version",
        "meets_requirements": $([ "$version_status" = "HEALTHY" ] && echo "true" || echo "false"),
        "api_response_time_ms": $response_time
    },
    "docker_compose": {
        "available": $([ "$compose_status" = "HEALTHY" ] && echo "true" || echo "false"),
        "version": "$compose_version",
        "status": "$compose_status"
    },
    "system_info": $system_info,
    "metadata": {
        "timestamp": "$(date -u +"%Y-%m-%dT%H:%M:%SZ")",
        "min_required_version": "$MIN_DOCKER_VERSION",
        "timeout_seconds": $DOCKER_INFO_TIMEOUT
    }
}
EOF
    
    # Retorna código de saída baseado no status do daemon
    if [[ "$daemon_status" == "HEALTHY" ]]; then
        log_info "Docker environment diagnostic completed successfully"
        return 0
    else
        log_error "Docker environment diagnostic failed"
        return 1
    fi
}

#===============================================================================
# UTILITY FUNCTIONS (Mantidas para compatibilidade)
#===============================================================================

# Monitora recursos do sistema (movido para resource_monitoring.sh)
run_resource_monitoring() {
    log_warning "run_resource_monitoring() is deprecated - use resource_monitoring.sh instead"
    return 1
}

# Funções de ciclo de vida de containers (movido para container_lifecycle.sh)
run_container_lifecycle() {
    log_warning "run_container_lifecycle() is deprecated - use container_lifecycle.sh instead"
    return 1
}

#===============================================================================
# EXECUTION
#===============================================================================

# Se executado diretamente
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    run_docker_diagnostic
fi
