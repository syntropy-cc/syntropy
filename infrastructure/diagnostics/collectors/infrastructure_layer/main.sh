#!/bin/bash

#===============================================================================
# INFRASTRUCTURE LAYER DIAGNOSTIC - MAIN ENTRY POINT
#===============================================================================

# Resolve caminhos absolutos
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" &> /dev/null && pwd)"

# Carrega configuração da camada
CONFIG_FILE="$SCRIPT_DIR/config.json"

# Importa módulos de diagnóstico da camada
source "$SCRIPT_DIR/docker_diagnostic.sh" || exit 1
source "$SCRIPT_DIR/container_diagnostic.sh" || exit 1
source "$SCRIPT_DIR/resource_monitoring.sh" || exit 1
source "$SCRIPT_DIR/container_lifecycle.sh" || exit 1


CORE_DIR="$(cd "$SCRIPT_DIR/../../core" &> /dev/null && pwd)"
ENV_FILE="$(cd "$SCRIPT_DIR/../../../../" &> /dev/null && pwd)/.env"

# Importa dependências core primeiro
source "$CORE_DIR/logger.sh" || exit 1
source "$ENV_FILE" 2>/dev/null || log_warning "Environment file not found"
source "$CORE_DIR/utils.sh" || exit 1
source "$CORE_DIR/json_handler.sh" || exit 1
source "$CORE_DIR/output_handler.sh" || exit 1

#==========================================================================
# VALIDATION FUNCTIONS
#===============================================================================

validate_environment() {
    log_info "Validating environment for infrastructure layer"
    
    # Verifica versão do bash
    if [[ "${BASH_VERSION%%.*}" -lt 4 ]]; then
        log_error "Bash version 4.0 or higher is required (current: $BASH_VERSION)"
        return 1
    fi
    
    # Verifica se docker está instalado
    if ! command -v docker >/dev/null 2>&1; then
        log_error "Docker is not installed or not in PATH"
        return 1
    fi
    
    # Verifica se jq está instalado
    if ! command -v jq >/dev/null 2>&1; then
        log_error "jq is not installed or not in PATH"
        return 1
    fi
    
    # Verifica se arquivo de configuração existe
    if [[ ! -f "$CONFIG_FILE" ]]; then
        log_error "Configuration file not found: $CONFIG_FILE"
        return 1
    fi
    
    log_debug "Environment validation completed successfully"
    return 0
}

#===============================================================================
# DIAGNOSTIC EXECUTION
#===============================================================================

execute_docker_diagnostic() {
    log_info "Executing Docker environment diagnostic"
    local result
    if result=$(run_docker_diagnostic 2>/dev/null); then
        echo "$result"
        return 0
    else
        log_error "Docker diagnostic failed"
        return 1
    fi
}

execute_container_diagnostic() {
    log_info "Executing container status diagnostic"
    local result
    if result=$(run_container_diagnostic 2>/dev/null); then
        echo "$result"
        return 0
    else
        log_error "Container diagnostic failed"
        return 1
    fi
}

execute_resource_monitoring() {
    log_info "Executing resource monitoring diagnostic"
    local result
    if result=$(run_resource_monitoring 2>/dev/null); then
        echo "$result"
        return 0
    else
        log_error "Resource monitoring failed"
        return 1
    fi
}

execute_container_lifecycle() {
    log_info "Executing container lifecycle diagnostic"
    local result
    if result=$(run_container_lifecycle 2>/dev/null); then
        echo "$result"
        return 0
    else
        log_error "Container lifecycle diagnostic failed"
        return 1
    fi
}

#===============================================================================
# OUTPUT GENERATION
#===============================================================================

generate_summary_content() {
    local docker_status="$1"
    local container_status="$2"
    local resource_status="$3"
    local lifecycle_status="$4"
    local duration="$5"
    
    local summary_content=""
    summary_content+="## Infrastructure Layer Diagnostic Report\n\n"
    summary_content+="**Execution Time:** $(date -u +"%Y-%m-%dT%H:%M:%SZ")\n"
    summary_content+="**Duration:** ${duration}ms\n"
    summary_content+="**Status:** $(get_overall_status "$docker_status" "$container_status" "$resource_status")\n\n"
    
    summary_content+="### Docker Environment\n"
    summary_content+="$(echo "$docker_status" | jq -r '.docker_daemon | "• **Daemon:** \(.status) (v\(.version))"' 2>/dev/null || echo "• **Daemon:** UNKNOWN")\n"
    summary_content+="$(echo "$docker_status" | jq -r '.docker_compose | "• **Compose:** \(if .available then "Available" else "Not Available" end) (v\(.version))"' 2>/dev/null || echo "• **Compose:** UNKNOWN")\n\n"
    
    summary_content+="### Container Status\n"
    summary_content+="$(echo "$container_status" | jq -r '"• **Running:** \(.running_count)/\(.total_count) containers"' 2>/dev/null || echo "• **Running:** UNKNOWN")\n"
    summary_content+="$(echo "$container_status" | jq -r '"• **Health:** \(.status)"' 2>/dev/null || echo "• **Health:** UNKNOWN")\n\n"
    
    summary_content+="### System Resources\n"
    summary_content+="$(echo "$resource_status" | jq -r '.cpu | "• **CPU:** \(.usage)% (\(.status))"' 2>/dev/null || echo "• **CPU:** UNKNOWN")\n"
    summary_content+="$(echo "$resource_status" | jq -r '.memory | "• **Memory:** \(.usage_percent)% (\(.status))"' 2>/dev/null || echo "• **Memory:** UNKNOWN")\n"
    summary_content+="$(echo "$resource_status" | jq -r '.disk[0] | "• **Disk:** \(.usage_percent)% (\(.status))"' 2>/dev/null || echo "• **Disk:** UNKNOWN")\n\n"
    
    summary_content+="### Recommendations\n"
    summary_content+="$(generate_recommendations "$docker_status" "$container_status" "$resource_status")\n"
    
    echo "$summary_content"
}

generate_infrastructure_results_json() {
    local docker_status="$1"
    local container_status="$2"
    local resource_status="$3"
    local lifecycle_status="$4"
    local duration="$5"
    
    local overall_status
    overall_status=$(get_overall_status "$docker_status" "$container_status" "$resource_status")
    
    cat << EOF
{
    "metadata": {
        "layer": "infrastructure",
        "timestamp": "$(date -u +"%Y-%m-%dT%H:%M:%SZ")",
        "duration_ms": $duration,
        "version": "2.1.0"
    },
    "status": "$overall_status",
    "components": {
        "docker": $docker_status,
        "containers": $container_status,
        "resources": $resource_status,
        "lifecycle": $lifecycle_status
    },
    "anomalies": $(generate_anomalies_json "$docker_status" "$container_status" "$resource_status"),
    "recommendations": $(generate_recommendations_json "$docker_status" "$container_status" "$resource_status")
}
EOF
}

generate_anomalies_json() {
    local docker_status="$1"
    local container_status="$2"
    local resource_status="$3"
    
    local anomalies=()
    
    # Verifica problemas do Docker
    if [[ $(echo "$docker_status" | jq -r '.docker_daemon.status' 2>/dev/null) == "CRITICAL" ]]; then
        anomalies+=('{"component": "docker_daemon", "severity": "CRITICAL", "message": "Docker daemon is not accessible"}')
    fi
    
    # Verifica problemas de containers
    if [[ $(echo "$container_status" | jq -r '.running_count' 2>/dev/null) -lt $(echo "$container_status" | jq -r '.total_count' 2>/dev/null) ]]; then
        anomalies+=('{"component": "containers", "severity": "WARNING", "message": "Some containers are not running"}')
    fi
    
    # Verifica problemas de recursos
    if [[ $(echo "$resource_status" | jq -r '.cpu.status' 2>/dev/null) == "CRITICAL" ]]; then
        anomalies+=('{"component": "cpu", "severity": "CRITICAL", "message": "CPU usage is critical"}')
    fi
    
    if [[ $(echo "$resource_status" | jq -r '.memory.status' 2>/dev/null) == "CRITICAL" ]]; then
        anomalies+=('{"component": "memory", "severity": "CRITICAL", "message": "Memory usage is critical"}')
    fi
    
    if [[ ${#anomalies[@]} -eq 0 ]]; then
        echo "[]"
    else
        echo "[$(IFS=,; echo "${anomalies[*]}")]"
    fi
}

generate_recommendations_json() {
    local docker_status="$1"
    local container_status="$2"
    local resource_status="$3"
    
    local recommendations=()
    
    # Recomendações baseadas no status
    if [[ $(echo "$docker_status" | jq -r '.docker_daemon.status' 2>/dev/null) != "HEALTHY" ]]; then
        recommendations+=('{"priority": "P1", "action": "Check Docker daemon status and restart if necessary", "component": "docker"}')
    fi
    
    if [[ $(echo "$container_status" | jq -r '.running_count' 2>/dev/null) -lt $(echo "$container_status" | jq -r '.total_count' 2>/dev/null) ]]; then
        recommendations+=('{"priority": "P2", "action": "Investigate and restart stopped containers", "component": "containers"}')
    fi
    
    if [[ $(echo "$resource_status" | jq -r '.cpu.status' 2>/dev/null) == "WARNING" ]]; then
        recommendations+=('{"priority": "P3", "action": "Monitor CPU usage trend", "component": "resources"}')
    fi
    
    if [[ $(echo "$resource_status" | jq -r '.memory.status' 2>/dev/null) == "WARNING" ]]; then
        recommendations+=('{"priority": "P3", "action": "Monitor memory usage trend", "component": "resources"}')
    fi
    
    if [[ ${#recommendations[@]} -eq 0 ]]; then
        echo '[{"priority": "P4", "action": "No immediate action required", "component": "system"}]'
    else
        echo "[$(IFS=,; echo "${recommendations[*]}")]"
    fi
}

generate_recommendations() {
    local docker_status="$1"
    local container_status="$2"
    local resource_status="$3"
    
    local recommendations=""
    
    if [[ $(echo "$docker_status" | jq -r '.docker_daemon.status' 2>/dev/null) != "HEALTHY" ]]; then
        recommendations+="• **CRITICAL:** Docker daemon needs attention\n"
    fi
    
    if [[ $(echo "$container_status" | jq -r '.running_count' 2>/dev/null) -lt $(echo "$container_status" | jq -r '.total_count' 2>/dev/null) ]]; then
        recommendations+="• **WARNING:** Some containers are not running\n"
    fi
    
    if [[ $(echo "$resource_status" | jq -r '.cpu.status' 2>/dev/null) == "WARNING" ]]; then
        recommendations+="• **WARNING:** High CPU usage detected\n"
    fi
    
    if [[ $(echo "$resource_status" | jq -r '.memory.status' 2>/dev/null) == "WARNING" ]]; then
        recommendations+="• **WARNING:** High memory usage detected\n"
    fi
    
    if [[ -z "$recommendations" ]]; then
        recommendations="• **INFO:** No immediate action required\n"
    fi
    
    echo "$recommendations"
}

get_overall_status() {
    local docker_status="$1"
    local container_status="$2"
    local resource_status="$3"
    
    # Determina status geral baseado nos componentes
    if [[ $(echo "$docker_status" | jq -r '.docker_daemon.status' 2>/dev/null) == "CRITICAL" ]] || \
       [[ $(echo "$container_status" | jq -r '.status' 2>/dev/null) == "CRITICAL" ]] || \
       [[ $(echo "$resource_status" | jq -r '.status' 2>/dev/null) == "CRITICAL" ]]; then
        echo "CRITICAL"
    elif [[ $(echo "$docker_status" | jq -r '.docker_daemon.status' 2>/dev/null) == "WARNING" ]] || \
         [[ $(echo "$container_status" | jq -r '.status' 2>/dev/null) == "WARNING" ]] || \
         [[ $(echo "$resource_status" | jq -r '.status' 2>/dev/null) == "WARNING" ]]; then
        echo "WARNING"
    else
        echo "HEALTHY"
    fi
}

#===============================================================================
# MAIN EXECUTION
#===============================================================================

main() {
    local start_time=$(date +%s%3N)
    
    log_info "Starting infrastructure layer diagnostics"
    
    # Valida ambiente
    if ! validate_environment; then
        log_error "Environment validation failed"
        exit 1
    fi
    
    # Inicializa output handler primeiro
    if ! init_output_handler "infrastructure"; then
        log_critical "Failed to initialize output handler"
        exit 1
    fi
    
    # Verifica se os diretórios foram criados corretamente
    if [[ ! -d "$OUTPUT_DIR" ]]; then
        log_critical "Output directory was not created: $OUTPUT_DIR"
        exit 1
    fi
    
    if [[ ! -d "$(get_logs_dir)" ]]; then
        log_critical "Logs directory was not created: $(get_logs_dir)"
        exit 1
    fi
    
    # Inicializa logger após criar diretórios
    if ! init_logger "$LAYER_NAME" "$TIMESTAMP" "$(get_logs_dir)"; then
        log_critical "Failed to initialize logger"
        exit 1
    fi
    
    # Executa diagnósticos
    local docker_status="{}"
    local container_status="{}"
    local resource_status="{}"
    local lifecycle_status="{}"
    
    log_info "Executing Docker diagnostic"
    docker_status=$(execute_docker_diagnostic) || docker_status='{"docker_daemon": {"status": "CRITICAL", "error": "Diagnostic failed"}}'
    
    log_info "Executing container diagnostic"
    container_status=$(execute_container_diagnostic) || container_status='{"status": "CRITICAL", "error": "Diagnostic failed"}'
    
    log_info "Executing resource monitoring"
    resource_status=$(execute_resource_monitoring) || resource_status='{"status": "CRITICAL", "error": "Diagnostic failed"}'
    
    log_info "Executing container lifecycle"
    lifecycle_status=$(execute_container_lifecycle) || lifecycle_status='{"error": "Diagnostic failed"}'
    
    # Calcula duração
    local end_time=$(date +%s%3N)
    local duration=$((end_time - start_time))
    
    # Gera outputs
    log_info "Generating diagnostic outputs"
    
    local summary_content
    summary_content=$(generate_summary_content "$docker_status" "$container_status" "$resource_status" "$lifecycle_status" "$duration")
    generate_summary_md "Infrastructure Layer Diagnostics" "$summary_content" || log_error "Failed to generate summary.md"
    
    local results_json
    results_json=$(generate_infrastructure_results_json "$docker_status" "$container_status" "$resource_status" "$lifecycle_status" "$duration")
    generate_results_json "$results_json" || log_error "Failed to generate results.json"
    
    copy_detailed_log "$(get_logs_dir)/infrastructure.log" || log_error "Failed to copy detailed.log"
    
    # Limpa outputs antigos
    cleanup_old_outputs 7
    
    log_info "Infrastructure layer diagnostics completed in ${duration}ms"
    
    # Inicia monitoramento se não estiver rodando
    if ! pgrep -f "monitor.sh" >/dev/null; then
        log_info "Starting infrastructure monitoring"
        "$SCRIPT_DIR/monitor.sh" start
    fi
    
    return 0
}

# Executa main se chamado diretamente
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi
