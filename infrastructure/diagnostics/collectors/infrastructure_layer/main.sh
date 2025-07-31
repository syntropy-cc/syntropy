#!/bin/bash

# PROTEGE O SCRIPT_DIR CONTRA SOBREPOSIÇÃO!
# Salva o SCRIPT_DIR original antes de importar qualquer arquivo
ORIGINAL_SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" &> /dev/null && pwd)"
readonly ORIGINAL_SCRIPT_DIR

# Calcula outros paths baseados no original protegido
CORE_DIR="$(cd "$ORIGINAL_SCRIPT_DIR/../../core" &> /dev/null && pwd)"
ENV_FILE="$(cd "$ORIGINAL_SCRIPT_DIR/../../../../" &> /dev/null && pwd)/.env"

echo "🔒 PROTECTED: ORIGINAL_SCRIPT_DIR = $ORIGINAL_SCRIPT_DIR"
echo "📂 CORE_DIR = $CORE_DIR"
echo "⚙️  ENV_FILE = $ENV_FILE"

# Importa dependências do core
if [[ -f "$ENV_FILE" ]]; then
    source "$ENV_FILE"
    echo "✅ .env loaded successfully"
else
    echo "⚠️  WARNING: .env not found at $ENV_FILE"
fi

# Importa core files (que podem tentar sobrescrever SCRIPT_DIR)
source "$CORE_DIR/logger.sh" || { echo "❌ ERROR: logger.sh not found in $CORE_DIR"; exit 1; }
source "$CORE_DIR/utils.sh" || { echo "❌ ERROR: utils.sh not found in $CORE_DIR"; exit 1; }
source "$CORE_DIR/json_handler.sh" || { echo "❌ ERROR: json_handler.sh not found in $CORE_DIR"; exit 1; }
source "$CORE_DIR/output_handler.sh" || { echo "❌ ERROR: output_handler.sh not found in $CORE_DIR"; exit 1; }

# VERIFICA SE SCRIPT_DIR FOI ALTERADO E RESTAURA
if [[ "$SCRIPT_DIR" != "$ORIGINAL_SCRIPT_DIR" ]]; then
    echo "⚠️  WARNING: SCRIPT_DIR was modified from '$ORIGINAL_SCRIPT_DIR' to '$SCRIPT_DIR'"
    echo "🔧 RESTORING: Setting SCRIPT_DIR back to original value"
    SCRIPT_DIR="$ORIGINAL_SCRIPT_DIR"
fi

echo "📍 USING SCRIPT_DIR = $SCRIPT_DIR"

# Agora importa módulos de diagnóstico do diretório correto
echo "📦 Loading diagnostic modules from $SCRIPT_DIR"
source "$SCRIPT_DIR/docker_diagnostic.sh" || { echo "❌ ERROR: docker_diagnostic.sh not found in $SCRIPT_DIR"; exit 1; }
source "$SCRIPT_DIR/container_diagnostic.sh" || { echo "❌ ERROR: container_diagnostic.sh not found in $SCRIPT_DIR"; exit 1; }
source "$SCRIPT_DIR/resource_monitoring.sh" || { echo "❌ ERROR: resource_monitoring.sh not found in $SCRIPT_DIR"; exit 1; }
source "$SCRIPT_DIR/container_lifecycle.sh" || { echo "❌ ERROR: container_lifecycle.sh not found in $SCRIPT_DIR"; exit 1; }

echo "✅ All modules loaded successfully!"

# Carrega configuração da camada
CONFIG_FILE="$SCRIPT_DIR/config.json"
LAYER_NAME="infrastructure"

# Configura diretórios base
LOG_BASE_DIR="${HOME}/diagnose/logs"
mkdir -p "$LOG_BASE_DIR"

# Inicializa handlers
TIMESTAMP="$(date +%Y%m%d_%H%M%S)"
init_output_handler "$LAYER_NAME" || exit 1
init_logger "$LAYER_NAME" "$TIMESTAMP" "$LOG_BASE_DIR" || exit 1

log_info "🚀 Infrastructure diagnostics initialization complete"

# Função para executar módulo com tratamento de erro
execute_module_safe() {
    local module_name="$1"
    local module_function="$2"
    local default_json="$3"
    
    log_info "🔄 Executing module: $module_name"
    
    # Verifica se a função existe
    if ! declare -f "$module_function" >/dev/null; then
        log_warning "⚠️  Function $module_function not available, using default"
        echo "$default_json"
        return 0
    fi
    
    local result
    if result=$($module_function 2>&1); then
        # Verifica se o resultado é JSON válido
        if echo "$result" | jq '.' >/dev/null 2>&1; then
            log_debug "✅ Module $module_name completed successfully"
            echo "$result"
        else
            log_warning "⚠️  Module $module_name returned invalid JSON: $result"
            log_warning "🔄 Using default JSON for $module_name"
            echo "$default_json"
        fi
    else
        log_error "❌ $module_name diagnostic failed with: $result"
        echo "$default_json"
    fi
}

validate_environment() {
    log_info "🔍 Validating environment for $LAYER_NAME layer"
    
    # Verifica versão do bash
    if [[ "${BASH_VERSION%%.*}" -lt 4 ]]; then
        log_error "❌ Bash version 4.0 or higher is required (current: $BASH_VERSION)"
        return 1
    fi
    
    # Verifica se docker está instalado
    if ! command -v docker >/dev/null 2>&1; then
        log_error "❌ Docker is not installed"
        return 1
    fi
    
    # Verifica se jq está instalado
    if ! command -v jq >/dev/null 2>&1; then
        log_error "❌ jq is not installed"
        return 1
    fi
    
    # Verifica se config existe
    if [[ ! -f "$CONFIG_FILE" ]]; then
        log_error "❌ Config file not found: $CONFIG_FILE"
        return 1
    fi
    
    log_info "✅ Environment validation passed"
    return 0
}

# Funções para criar JSONs padrão em caso de falha
get_default_docker_json() {
    echo '{
        "docker_daemon": {
            "status": "CRITICAL",
            "accessible": false,
            "version": "unknown",
            "meets_requirements": false
        },
        "docker_compose": {
            "available": false,
            "version": "N/A"
        }
    }'
}

get_default_container_json() {
    echo '{
        "status": "CRITICAL",
        "running_count": 0,
        "total_count": 8,
        "containers": {},
        "unhealthy_containers": []
    }'
}

get_default_resource_json() {
    echo '{
        "status": "UNKNOWN",
        "cpu": {"usage": 0, "status": "UNKNOWN"},
        "memory": {"usage_percent": 0, "status": "UNKNOWN"},
        "disk": [{"usage_percent": 0, "status": "UNKNOWN"}],
        "network": {"rx_bytes": 0, "tx_bytes": 0},
        "timestamp": "'$(date -u +"%Y-%m-%dT%H:%M:%SZ")'"
    }'
}

get_default_lifecycle_json() {
    echo '{
        "lifecycle_checks": [],
        "timestamp": "'$(date -u +"%Y-%m-%dT%H:%M:%SZ")'"
    }'
}

generate_outputs() {
    local start_time="$1"
    local current_time=$(date +%s%3N)
    local duration=$((current_time - start_time))
    
    log_info "📊 Generating diagnostic outputs"
    
    # Executa módulos com tratamento seguro
    log_info "🔄 Running diagnostic modules..."
    local docker_status=$(execute_module_safe "docker" "run_docker_diagnostic" "$(get_default_docker_json)")
    local container_status=$(execute_module_safe "container" "run_container_diagnostic" "$(get_default_container_json)")
    local resource_status=$(execute_module_safe "resource" "run_resource_monitoring" "$(get_default_resource_json)")
    local lifecycle_status=$(execute_module_safe "lifecycle" "run_container_lifecycle" "$(get_default_lifecycle_json)")
    
    log_info "🎯 All modules executed, determining overall status..."
    
    # Determina status geral
    local overall_status=$(get_overall_status "$docker_status" "$container_status" "$resource_status")
    
    log_info "📈 Overall status: $overall_status"
    
    # Gera conteúdo do summary
    local summary_content
    summary_content="[INFRASTRUCTURE DIAGNOSTIC REPORT]
Timestamp: $(date -u +"%Y-%m-%dT%H:%M:%SZ")
Duration: ${duration}ms
Status: $overall_status

-- DOCKER ENVIRONMENT --
• Docker Daemon: $(echo "$docker_status" | jq -r '.docker_daemon.status // "UNKNOWN"')
• Docker Version: $(echo "$docker_status" | jq -r '.docker_daemon.version // "unknown"')
• Docker Compose: $(echo "$docker_status" | jq -r '.docker_compose.available // false')

-- CONTAINER STATUS --
• Running: $(echo "$container_status" | jq -r '.running_count // 0')/$(echo "$container_status" | jq -r '.total_count // 8') containers
• Health Status: $(echo "$container_status" | jq -r '.status // "UNKNOWN"')

-- SYSTEM RESOURCES --
• CPU Usage: $(echo "$resource_status" | jq -r '.cpu.usage // 0')% ($(echo "$resource_status" | jq -r '.cpu.status // "UNKNOWN"'))
• Memory Usage: $(echo "$resource_status" | jq -r '.memory.usage_percent // 0')% ($(echo "$resource_status" | jq -r '.memory.status // "UNKNOWN"'))
• Disk Usage: $(echo "$resource_status" | jq -r '.disk[0].usage_percent // 0')% ($(echo "$resource_status" | jq -r '.disk[0].status // "UNKNOWN"'))

-- RECOMMENDATIONS --
$(generate_recommendations "$docker_status" "$container_status" "$resource_status")"

    log_info "🏗️  Creating final JSON output..."
    
    # Cria JSON final - usando template seguro
    local results_json
    results_json=$(cat << EOF
{
    "layer": "$LAYER_NAME",
    "timestamp": "$(date -u +"%Y-%m-%dT%H:%M:%SZ")",
    "duration_ms": $duration,
    "status": "$overall_status",
    "components": {
        "docker": $docker_status,
        "containers": $container_status,
        "resources": $resource_status,
        "lifecycle": $lifecycle_status
    },
    "recommendations": $(generate_recommendations_json "$docker_status" "$container_status" "$resource_status")
}
EOF
)
    
    # Valida JSON antes de salvar
    if ! echo "$results_json" | jq '.' >/dev/null 2>&1; then
        log_critical "❌ Generated JSON is invalid, creating minimal fallback"
        results_json="{
            \"layer\": \"$LAYER_NAME\",
            \"timestamp\": \"$(date -u +"%Y-%m-%dT%H:%M:%SZ")\",
            \"status\": \"CRITICAL\",
            \"error\": \"Failed to generate complete diagnostic\"
        }"
    fi
    
    log_info "💾 Saving output files..."
    
    # Exporta outputs usando output handler
    if ! generate_summary_txt "Infrastructure Layer Diagnostics" "$summary_content"; then
        log_error "❌ Failed to generate summary.txt"
    else
        log_info "✅ summary.txt generated successfully"
    fi
    
    if ! generate_results_json "$results_json"; then
        log_error "❌ Failed to generate results.json"
    else
        log_info "✅ results.json generated successfully"
    fi
    
    # Copia log detalhado se existir
    local detailed_log="$LOG_BASE_DIR/${LAYER_NAME}_${TIMESTAMP}.log"
    if [[ -f "$detailed_log" ]]; then
        if copy_detailed_log "$detailed_log"; then
            log_info "✅ detailed.log copied successfully"
        else
            log_error "❌ Failed to copy detailed.log"
        fi
    fi
    
    # Limpa outputs antigos
    cleanup_old_outputs 7
    
    log_info "🎉 Diagnostic outputs generated successfully"
}

generate_recommendations() {
    local docker_status="$1"
    local container_status="$2"
    local resource_status="$3"
    
    local recommendations=""
    
    # Verifica Docker
    if [[ $(echo "$docker_status" | jq -r '.docker_daemon.status') != "HEALTHY" ]]; then
        recommendations+="• CRITICAL: Docker daemon needs attention\n"
    fi
    
    # Verifica containers
    local running_containers=$(echo "$container_status" | jq -r '.running_count // 0')
    if [[ $running_containers -lt 6 ]]; then
        recommendations+="• WARNING: Some containers are not running ($running_containers/8)\n"
    fi
    
    # Verifica recursos
    if [[ $(echo "$resource_status" | jq -r '.cpu.status') == "WARNING" ]]; then
        recommendations+="• WARNING: High CPU usage detected\n"
    fi
    
    if [[ $(echo "$resource_status" | jq -r '.memory.status') == "WARNING" ]]; then
        recommendations+="• WARNING: High memory usage detected\n"
    fi
    
    if [[ -z "$recommendations" ]]; then
        recommendations="• All systems operational\n• No action required"
    fi
    
    echo -e "$recommendations"
}

generate_recommendations_json() {
    local docker_status="$1"
    local container_status="$2"
    local resource_status="$3"
    
    local recommendations="["
    local has_recommendations=false
    
    # Verifica Docker
    if [[ $(echo "$docker_status" | jq -r '.docker_daemon.status') != "HEALTHY" ]]; then
        [[ "$has_recommendations" == true ]] && recommendations+=","
        recommendations+='{
            "priority": "CRITICAL",
            "message": "Docker daemon needs attention",
            "action": "check_docker_service"
        }'
        has_recommendations=true
    fi
    
    # Verifica containers
    local running_containers=$(echo "$container_status" | jq -r '.running_count // 0')
    if [[ $running_containers -lt 6 ]]; then
        [[ "$has_recommendations" == true ]] && recommendations+=","
        recommendations+='{
            "priority": "WARNING", 
            "message": "Some containers are not running",
            "action": "restart_containers"
        }'
        has_recommendations=true
    fi
    
    # Se não há recomendações, adiciona uma padrão
    if [[ "$has_recommendations" == false ]]; then
        recommendations+='{
            "priority": "INFO",
            "message": "All systems operational",
            "action": "continue_monitoring"
        }'
    fi
    
    recommendations+="]"
    echo "$recommendations"
}

get_overall_status() {
    local docker_status="$1"
    local container_status="$2"
    local resource_status="$3"
    
    # Verifica status críticos
    if [[ $(echo "$docker_status" | jq -r '.docker_daemon.status') == "CRITICAL" ]] || \
       [[ $(echo "$container_status" | jq -r '.status') == "CRITICAL" ]] || \
       [[ $(echo "$resource_status" | jq -r '.status') == "CRITICAL" ]]; then
        echo "CRITICAL"
        return
    fi
    
    # Verifica status de warning
    if [[ $(echo "$docker_status" | jq -r '.docker_daemon.status') == "WARNING" ]] || \
       [[ $(echo "$container_status" | jq -r '.status') == "WARNING" ]] || \
       [[ $(echo "$resource_status" | jq -r '.status') == "WARNING" ]]; then
        echo "WARNING"
        return
    fi
    
    # Se chegou até aqui, está saudável
    echo "HEALTHY"
}

main() {
    local start_time=$(date +%s%3N)
    
    echo ""
    echo "🚀 ==============================================="
    echo "🚀    INFRASTRUCTURE LAYER DIAGNOSTICS"
    echo "🚀 ==============================================="
    echo "📍 Working directory: $(pwd)"
    echo "📁 Script directory: $ORIGINAL_SCRIPT_DIR"
    echo "⏰ Started at: $(date)"
    echo ""
    
    log_info "🚀 Starting $LAYER_NAME layer diagnostics"
    
    # Valida ambiente
    if ! validate_environment; then
        log_error "❌ Environment validation failed - exiting"
        exit 1
    fi
    
    log_info "✅ Environment validation passed"
    
    # Gera outputs (com tratamento de erro interno)
    generate_outputs "$start_time"
    
    # Verifica se o monitoramento está rodando
    if ! pgrep -f "monitor.sh" >/dev/null; then
        log_info "🔄 Starting infrastructure monitoring"
        if [[ -f "$SCRIPT_DIR/monitor.sh" ]]; then
            "$SCRIPT_DIR/monitor.sh" start 2>/dev/null || log_warning "⚠️  Failed to start monitoring"
        fi
    fi
    
    echo ""
    echo "🎉 ==============================================="
    echo "🎉    DIAGNOSTICS COMPLETED SUCCESSFULLY"
    echo "🎉 ==============================================="
    echo "📊 Check the outputs in: $(get_output_dir 2>/dev/null || echo 'diagnostic output directory')"
    echo "📝 Detailed logs in: $LOG_BASE_DIR/${LAYER_NAME}_${TIMESTAMP}.log"
    echo "⏰ Completed at: $(date)"
    echo ""
    
    log_info "🎉 Infrastructure layer diagnostics completed successfully"
}

# Executa main se chamado diretamente
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi