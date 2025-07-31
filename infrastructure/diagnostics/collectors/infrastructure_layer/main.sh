#!/bin/bash

# PROTEGE O SCRIPT_DIR CONTRA SOBREPOSIÇÃO!
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
            log_warning "⚠️  Module $module_name returned invalid JSON"
            log_debug "JSON validation error: $(echo "$result" | jq '.' 2>&1 | head -3)"
            log_warning "🔄 Using default JSON for $module_name"
            echo "$default_json"
        fi
    else
        log_error "❌ $module_name diagnostic failed"
        log_debug "Error details: $result"
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

# Funções para criar JSONs padrão em caso de falha otimizados para LLMs
get_default_docker_json() {
    cat << EOF
{
    "docker_daemon": {
        "status": "CRITICAL",
        "accessible": false,
        "version": "unknown",
        "meets_requirements": false
    },
    "docker_compose": {
        "available": false,
        "version": "N/A"
    },
    "insights": {
        "summary": "Docker environment unavailable",
        "impact": "Complete infrastructure failure - no containers can run",
        "recommendation": "Install and start Docker service immediately",
        "severity": "CRITICAL"
    }
}
EOF
}

get_default_container_json() {
    cat << EOF
{
    "status": "CRITICAL",
    "running_count": 0,
    "total_count": 8,
    "containers": {},
    "unhealthy_containers": [],
    "insights": {
        "summary": "Container diagnostic failed to execute",
        "impact": "Cannot assess application container health",
        "recommendation": "Check Docker daemon and container configuration",
        "health_distribution": {"healthy": 0, "unhealthy": 0, "offline": 8}
    }
}
EOF
}

get_default_resource_json() {
    cat << EOF
{
    "status": "UNKNOWN",
    "cpu": {"usage": 0, "status": "UNKNOWN"},
    "memory": {"usage_percent": 0, "status": "UNKNOWN"},
    "disk": [{"usage_percent": 0, "status": "UNKNOWN"}],
    "network": {"rx_bytes": 0, "tx_bytes": 0},
    "timestamp": "$(date -u +"%Y-%m-%dT%H:%M:%SZ")",
    "insights": {
        "summary": "Resource monitoring unavailable",
        "impact": "Cannot assess system resource health",
        "recommendation": "Check system monitoring tools and permissions"
    }
}
EOF
}

get_default_lifecycle_json() {
    cat << EOF
{
    "lifecycle_checks": [],
    "timestamp": "$(date -u +"%Y-%m-%dT%H:%M:%SZ")",
    "insights": {
        "summary": "Container lifecycle analysis unavailable", 
        "impact": "Cannot assess container stability and recovery capabilities",
        "recommendation": "Verify container management tools and policies"
    }
}
EOF
}

generate_outputs() {
    local start_time="$1"
    local current_time=$(date +%s%3N)
    local duration=$((current_time - start_time))
    
    log_info "📊 Generating LLM-optimized diagnostic outputs"
    
    # Executa módulos com tratamento seguro
    log_info "🔄 Running diagnostic modules..."
    local docker_status=$(execute_module_safe "docker" "run_docker_diagnostic" "$(get_default_docker_json)")
    local container_status=$(execute_module_safe "container" "run_container_diagnostic" "$(get_default_container_json)")
    local resource_status=$(execute_module_safe "resource" "run_resource_monitoring" "$(get_default_resource_json)")
    local lifecycle_status=$(execute_module_safe "lifecycle" "run_container_lifecycle" "$(get_default_lifecycle_json)")
    
    log_info "🎯 All modules executed, determining overall status..."
    
    # Determina status geral
    local overall_status summary_insight impact_assessment key_metrics
    overall_analysis=$(get_overall_analysis "$docker_status" "$container_status" "$resource_status" "$lifecycle_status")
    overall_status=$(echo "$overall_analysis" | jq -r '.status')
    summary_insight=$(echo "$overall_analysis" | jq -r '.summary')
    impact_assessment=$(echo "$overall_analysis" | jq -r '.impact')
    key_metrics=$(echo "$overall_analysis" | jq -r '.key_metrics')
    
    log_info "📈 Overall status: $overall_status"
    
    # Gera conteúdo do summary otimizado para LLMs
    local summary_content
    summary_content=$(generate_markdown_summary "$overall_status" "$summary_insight" "$impact_assessment" "$docker_status" "$container_status" "$resource_status" "$duration")
    
    # Cria JSON final otimizado para LLMs
    local results_json
    results_json=$(generate_enhanced_json "$overall_status" "$duration" "$docker_status" "$container_status" "$resource_status" "$lifecycle_status" "$summary_insight" "$impact_assessment")
    
    # Valida JSON antes de salvar
    if ! echo "$results_json" | jq '.' >/dev/null 2>&1; then
        log_critical "❌ Generated JSON is invalid, creating minimal fallback"
        results_json=$(create_fallback_json "$overall_status" "$duration")
    fi
    
    log_info "💾 Saving LLM-optimized output files..."
    
    # Exporta outputs usando output handler melhorado
    if ! generate_summary_md "Infrastructure Layer Diagnostics" "$summary_content"; then
        log_error "❌ Failed to generate summary.md"
    else
        log_info "✅ LLM-optimized summary.md generated successfully"
    fi
    
    if ! generate_results_json "$results_json"; then
        log_error "❌ Failed to generate results.json"
    else
        log_info "✅ Enhanced results.json generated successfully"
    fi
    
    # Gera análises específicas para LLMs
    generate_llm_analysis_summary "$LAYER_NAME" "$overall_status" "$key_metrics" "$(extract_recommendations_from_json "$results_json")"
    generate_performance_insights "$LAYER_NAME" "$start_time" "$current_time"
    
    # Copia log detalhado se existir
    local detailed_log="$LOG_BASE_DIR/${LAYER_NAME}_${TIMESTAMP}.log"
    if [[ -f "$detailed_log" ]]; then
        if copy_detailed_log "$detailed_log"; then
            log_info "✅ Enhanced detailed.log copied successfully"
        else
            log_error "❌ Failed to copy detailed.log"
        fi
    fi
    
    # Limpa outputs antigos
    cleanup_old_outputs 7
    
    log_info "🎉 LLM-optimized diagnostic outputs generated successfully"
}

generate_markdown_summary() {
    local status="$1" summary="$2" impact="$3" docker_status="$4" container_status="$5" resource_status="$6" duration="$7"
    
    cat << EOF
## Executive Summary

**Overall Status:** $status  
**Execution Time:** ${duration}ms  
**Summary:** $summary  
**Impact Assessment:** $impact  

## Component Health Analysis

### Docker Environment
- **Status:** $(echo "$docker_status" | jq -r '.docker_daemon.status // "UNKNOWN"')
- **Version:** $(echo "$docker_status" | jq -r '.docker_daemon.version // "unknown"')
- **Accessibility:** $(echo "$docker_status" | jq -r '.docker_daemon.accessible // false')
- **Insight:** $(echo "$docker_status" | jq -r '.insights.summary // "No insights available"')

### Container Infrastructure  
- **Running Containers:** $(echo "$container_status" | jq -r '.running_count // 0')/$(echo "$container_status" | jq -r '.total_count // 8')
- **Health Status:** $(echo "$container_status" | jq -r '.status // "UNKNOWN"')
- **Performance Score:** $(echo "$container_status" | jq -r '.insights.overall_performance_score // 0')/100
- **Key Issues:** $(echo "$container_status" | jq -r '.insights.summary // "No analysis available"')

### System Resources
- **CPU Usage:** $(echo "$resource_status" | jq -r '.cpu.usage // 0')% ($(echo "$resource_status" | jq -r '.cpu.status // "UNKNOWN"'))
- **Memory Usage:** $(echo "$resource_status" | jq -r '.memory.usage_percent // 0')% ($(echo "$resource_status" | jq -r '.memory.status // "UNKNOWN"'))
- **Disk Usage:** $(echo "$resource_status" | jq -r '.disk[0].usage_percent // 0')% ($(echo "$resource_status" | jq -r '.disk[0].status // "UNKNOWN"'))
- **Network Activity:** $(echo "$resource_status" | jq -r '.network.active_connections // 0') active connections

## LLM Processing Guide

### Critical Data Points
- **Decision Factor:** Overall status indicates immediate action needs
- **Performance Indicators:** Container performance scores and resource utilization
- **Trend Analysis:** Look for restart patterns and resource growth
- **Priority Actions:** Focus on CRITICAL status components first

### Interpretation Framework
- **HEALTHY:** System operating normally, continue monitoring
- **WARNING:** Issues detected but system functional, plan improvements  
- **CRITICAL:** Immediate attention required, service at risk
- **UNKNOWN:** Insufficient data, investigate monitoring systems

### Actionable Insights
$(generate_actionable_insights_text "$docker_status" "$container_status" "$resource_status")

EOF
}

generate_actionable_insights_text() {
    local docker_status="$1" container_status="$2" resource_status="$3"
    
    local insights=()
    
    # Docker insights
    if [[ $(echo "$docker_status" | jq -r '.docker_daemon.status') != "HEALTHY" ]]; then
        insights+=("- **CRITICAL:** Docker daemon requires immediate attention - restart Docker service")
    fi
    
    # Container insights
    local running_count=$(echo "$container_status" | jq -r '.running_count // 0')
    local total_count=$(echo "$container_status" | jq -r '.total_count // 8')
    if [[ $running_count -lt $total_count ]]; then
        insights+=("- **HIGH:** $((total_count - running_count)) containers offline - investigate and restart failed containers")
    fi
    
    # Resource insights
    local cpu_usage=$(echo "$resource_status" | jq -r '.cpu.usage // 0' | cut -d. -f1)
    local mem_usage=$(echo "$resource_status" | jq -r '.memory.usage_percent // 0' | cut -d. -f1)
    
    if [[ $cpu_usage -gt 80 ]]; then
        insights+=("- **MEDIUM:** High CPU usage ($cpu_usage%) - consider scaling or optimization")
    fi
    
    if [[ $mem_usage -gt 85 ]]; then
        insights+=("- **MEDIUM:** High memory usage ($mem_usage%) - monitor for memory leaks or scale resources")
    fi
    
    # Performance insights
    local performance_score=$(echo "$container_status" | jq -r '.insights.overall_performance_score // 0')
    if [[ $performance_score -lt 70 ]]; then
        insights+=("- **LOW:** Overall performance score low ($performance_score/100) - review container health and resource allocation")
    fi
    
    # If no issues found
    if [[ ${#insights[@]} -eq 0 ]]; then
        insights+=("- **INFO:** All systems operating within normal parameters")
        insights+=("- **INFO:** Continue regular monitoring and maintenance")
    fi
    
    printf '%s\n' "${insights[@]}"
}

generate_enhanced_json() {
    local status="$1" duration="$2" docker_status="$3" container_status="$4" resource_status="$5" lifecycle_status="$6" summary="$7" impact="$8"
    
    cat << EOF
{
    "layer": "$LAYER_NAME",
    "timestamp": "$(date -u +"%Y-%m-%dT%H:%M:%SZ")",
    "duration_ms": $duration,
    "status": "$status",
    "executive_summary": {
        "overall_health": "$status",
        "summary": "$summary",
        "impact_assessment": "$impact",
        "confidence_level": "high",
        "data_freshness": "real-time",
        "diagnostic_quality": "validated"
    },
    "components": {
        "docker": $docker_status,
        "containers": $container_status,
        "resources": $resource_status,
        "lifecycle": $lifecycle_status
    },
    "llm_analysis": {
        "decision_factors": $(generate_decision_factors "$docker_status" "$container_status" "$resource_status"),
        "priority_actions": $(generate_priority_actions "$docker_status" "$container_status" "$resource_status"),
        "performance_indicators": $(generate_performance_indicators "$container_status" "$resource_status"),
        "trend_analysis": $(generate_trend_analysis "$container_status" "$resource_status"),
        "risk_assessment": $(generate_risk_assessment "$status" "$docker_status" "$container_status")
    },
    "recommendations": $(generate_comprehensive_recommendations "$docker_status" "$container_status" "$resource_status"),
    "metadata": {
        "diagnostic_version": "2.0.0",
        "optimized_for": "LLM analysis and automated decision making",
        "processing_hints": {
            "focus_areas": ["executive_summary", "llm_analysis", "recommendations"],
            "critical_thresholds": {
                "container_availability": "< 100%",
                "cpu_usage": "> 80%",
                "memory_usage": "> 85%",
                "performance_score": "< 70"
            },
            "escalation_triggers": ["CRITICAL status", "multiple container failures", "resource exhaustion"]
        }
    }
}
EOF
}

generate_decision_factors() {
    local docker_status="$1" container_status="$2" resource_status="$3"
    
    local factors=()
    
    # Docker availability
    local docker_accessible=$(echo "$docker_status" | jq -r '.docker_daemon.accessible // false')
    factors+=("{\"factor\": \"docker_availability\", \"value\": $docker_accessible, \"weight\": \"critical\", \"description\": \"Docker daemon accessibility\"}")
    
    # Container health ratio
    local running_count=$(echo "$container_status" | jq -r '.running_count // 0')
    local total_count=$(echo "$container_status" | jq -r '.total_count // 8')
    local availability_ratio=$(echo "scale=2; $running_count * 100 / $total_count" | bc 2>/dev/null || echo "0")
    factors+=("{\"factor\": \"container_availability\", \"value\": $availability_ratio, \"weight\": \"high\", \"description\": \"Percentage of containers running\"}")
    
    # Resource utilization
    local cpu_usage=$(echo "$resource_status" | jq -r '.cpu.usage // 0')
    local memory_usage=$(echo "$resource_status" | jq -r '.memory.usage_percent // 0')
    factors+=("{\"factor\": \"resource_pressure\", \"value\": {\"cpu\": $cpu_usage, \"memory\": $memory_usage}, \"weight\": \"medium\", \"description\": \"System resource utilization\"}")
    
    # Performance score
    local performance_score=$(echo "$container_status" | jq -r '.insights.overall_performance_score // 0')
    factors+=("{\"factor\": \"performance_quality\", \"value\": $performance_score, \"weight\": \"medium\", \"description\": \"Overall container performance score\"}")
    
    echo "[$(IFS=','; echo "${factors[*]}")]"
}

generate_priority_actions() {
    local docker_status="$1" container_status="$2" resource_status="$3"
    
    local actions=()
    
    # Check Docker status
    if [[ $(echo "$docker_status" | jq -r '.docker_daemon.status') != "HEALTHY" ]]; then
        actions+=("{\"priority\": 1, \"urgency\": \"immediate\", \"action\": \"restart_docker_daemon\", \"description\": \"Docker daemon is not accessible - restart required\", \"estimated_time\": \"2-5 minutes\"}")
    fi
    
    # Check container status
    local running_count=$(echo "$container_status" | jq -r '.running_count // 0')
    local total_count=$(echo "$container_status" | jq -r '.total_count // 8')
    if [[ $running_count -lt $total_count ]]; then
        actions+=("{\"priority\": 2, \"urgency\": \"high\", \"action\": \"restart_failed_containers\", \"description\": \"$((total_count - running_count)) containers are offline\", \"estimated_time\": \"1-3 minutes per container\"}")
    fi
    
    # Check resource pressure
    local cpu_usage=$(echo "$resource_status" | jq -r '.cpu.usage // 0' | cut -d. -f1)
    local memory_usage=$(echo "$resource_status" | jq -r '.memory.usage_percent // 0' | cut -d. -f1)
    
    if [[ $cpu_usage -gt 90 ]]; then
        actions+=("{\"priority\": 3, \"urgency\": \"medium\", \"action\": \"address_cpu_pressure\", \"description\": \"CPU usage is critical ($cpu_usage%)\", \"estimated_time\": \"10-30 minutes\"}")
    fi
    
    if [[ $memory_usage -gt 95 ]]; then
        actions+=("{\"priority\": 3, \"urgency\": \"medium\", \"action\": \"address_memory_pressure\", \"description\": \"Memory usage is critical ($memory_usage%)\", \"estimated_time\": \"5-15 minutes\"}")
    fi
    
    # If no critical actions needed
    if [[ ${#actions[@]} -eq 0 ]]; then
        actions+=("{\"priority\": 4, \"urgency\": \"low\", \"action\": \"continue_monitoring\", \"description\": \"All systems operational - maintain monitoring\", \"estimated_time\": \"ongoing\"}")
    fi
    
    echo "[$(IFS=','; echo "${actions[*]}")]"
}

generate_performance_indicators() {
    local container_status="$1" resource_status="$2"
    
    local running_count=$(echo "$container_status" | jq -r '.running_count // 0')
    local total_count=$(echo "$container_status" | jq -r '.total_count // 8')
    local performance_score=$(echo "$container_status" | jq -r '.insights.overall_performance_score // 0')
    local cpu_usage=$(echo "$resource_status" | jq -r '.cpu.usage // 0')
    local memory_usage=$(echo "$resource_status" | jq -r '.memory.usage_percent // 0')
    
    cat << EOF
{
    "availability_score": $(echo "scale=0; $running_count * 100 / $total_count" | bc 2>/dev/null || echo "0"),
    "performance_score": $performance_score,
    "resource_efficiency": {
        "cpu_utilization": $cpu_usage,
        "memory_utilization": $memory_usage,
        "efficiency_rating": "$(calculate_efficiency_rating "$cpu_usage" "$memory_usage")"
    },
    "stability_indicators": {
        "container_restarts": $(echo "$container_status" | jq '[.containers[] | select(.restarts != null) | .restarts] | add // 0'),
        "unhealthy_count": $(echo "$container_status" | jq '.unhealthy_count // 0'),
        "stability_rating": "$(calculate_stability_rating "$container_status")"
    }
}
EOF
}

calculate_efficiency_rating() {
    local cpu_usage="$1" memory_usage="$2"
    
    local cpu_int=$(echo "$cpu_usage" | cut -d. -f1)
    local mem_int=$(echo "$memory_usage" | cut -d. -f1)
    local avg_usage=$(( (cpu_int + mem_int) / 2 ))
    
    if [[ $avg_usage -lt 30 ]]; then
        echo "excellent"
    elif [[ $avg_usage -lt 60 ]]; then
        echo "good"
    elif [[ $avg_usage -lt 80 ]]; then
        echo "fair"
    else
        echo "poor"
    fi
}

calculate_stability_rating() {
    local container_status="$1"
    
    local unhealthy_count=$(echo "$container_status" | jq -r '.unhealthy_count // 0')
    local total_restarts=$(echo "$container_status" | jq '[.containers[] | select(.restarts != null) | .restarts] | add // 0')
    
    if [[ $unhealthy_count -eq 0 ]] && [[ $total_restarts -lt 5 ]]; then
        echo "excellent"
    elif [[ $unhealthy_count -le 1 ]] && [[ $total_restarts -lt 15 ]]; then
        echo "good"
    elif [[ $unhealthy_count -le 2 ]] && [[ $total_restarts -lt 30 ]]; then
        echo "fair"
    else
        echo "poor"
    fi
}

generate_trend_analysis() {
    local container_status="$1" resource_status="$2"
    
    # Simplified trend analysis (in production, this would use historical data)
    local cpu_status=$(echo "$resource_status" | jq -r '.cpu.status // "UNKNOWN"')
    local memory_status=$(echo "$resource_status" | jq -r '.memory.status // "UNKNOWN"')
    local container_health_ratio=$(echo "scale=0; $(echo "$container_status" | jq '.healthy_count // 0') * 100 / $(echo "$container_status" | jq '.total_count // 1')" | bc 2>/dev/null || echo "0")
    
    cat << EOF
{
    "resource_trends": {
        "cpu_trend": "$(get_status_trend "$cpu_status")",
        "memory_trend": "$(get_status_trend "$memory_status")",
        "prediction": "$(predict_resource_trend "$cpu_status" "$memory_status")"
    },
    "container_trends": {
        "health_ratio": $container_health_ratio,
        "trend": "$(get_health_trend "$container_health_ratio")",
        "prediction": "$(predict_container_trend "$container_health_ratio")"
    },
    "recommendations": {
        "monitoring_focus": "$(get_monitoring_focus "$cpu_status" "$memory_status" "$container_health_ratio")",
        "proactive_actions": $(get_proactive_actions "$cpu_status" "$memory_status" "$container_health_ratio")
    }
}
EOF
}

get_status_trend() {
    local status="$1"
    case "$status" in
        "HEALTHY") echo "stable" ;;
        "WARNING") echo "degrading" ;;
        "CRITICAL") echo "critical" ;;
        *) echo "unknown" ;;
    esac
}

predict_resource_trend() {
    local cpu_status="$1" memory_status="$2"
    
    if [[ "$cpu_status" == "WARNING" ]] || [[ "$memory_status" == "WARNING" ]]; then
        echo "Resource pressure may increase - monitor closely"
    elif [[ "$cpu_status" == "CRITICAL" ]] || [[ "$memory_status" == "CRITICAL" ]]; then
        echo "Immediate intervention required to prevent service degradation"
    else
        echo "Resources stable - continue normal monitoring"
    fi
}

get_health_trend() {
    local health_ratio="$1"
    
    if [[ $health_ratio -eq 100 ]]; then
        echo "optimal"
    elif [[ $health_ratio -ge 80 ]]; then
        echo "good"
    elif [[ $health_ratio -ge 60 ]]; then
        echo "concerning"
    else
        echo "critical"
    fi
}

predict_container_trend() {
    local health_ratio="$1"
    
    if [[ $health_ratio -eq 100 ]]; then
        echo "Maintain current operational practices"
    elif [[ $health_ratio -ge 80 ]]; then
        echo "Monitor unhealthy containers for patterns"
    else
        echo "Investigate root causes of container failures"
    fi
}

get_monitoring_focus() {
    local cpu_status="$1" memory_status="$2" health_ratio="$3"
    
    local focus_areas=()
    
    if [[ "$cpu_status" != "HEALTHY" ]]; then
        focus_areas+=("CPU utilization")
    fi
    
    if [[ "$memory_status" != "HEALTHY" ]]; then
        focus_areas+=("Memory usage")
    fi
    
    if [[ $health_ratio -lt 100 ]]; then
        focus_areas+=("Container health")
    fi
    
    if [[ ${#focus_areas[@]} -eq 0 ]]; then
        echo "General system monitoring"
    else
        echo "$(IFS=', '; echo "${focus_areas[*]}")"
    fi
}

get_proactive_actions() {
    local cpu_status="$1" memory_status="$2" health_ratio="$3"
    
    local actions=()
    
    if [[ "$cpu_status" == "WARNING" ]]; then
        actions+=("\"Implement CPU usage alerts\"")
    fi
    
    if [[ "$memory_status" == "WARNING" ]]; then
        actions+=("\"Set up memory leak detection\"")
    fi
    
    if [[ $health_ratio -lt 100 ]]; then
        actions+=("\"Implement automated container recovery\"")
    fi
    
    if [[ ${#actions[@]} -eq 0 ]]; then
        actions+=("\"Maintain current monitoring strategy\"")
    fi
    
    echo "[$(IFS=','; echo "${actions[*]}")]"
}

generate_risk_assessment() {
    local status="$1" docker_status="$2" container_status="$3"
    
    local risk_level="low"
    local risk_factors=()
    local mitigation_strategies=()
    
    # Assess Docker risk
    if [[ $(echo "$docker_status" | jq -r '.docker_daemon.status') == "CRITICAL" ]]; then
        risk_level="critical"
        risk_factors+=("\"Docker daemon failure\"")
        mitigation_strategies+=("\"Immediate Docker service restart\"")
    fi
    
    # Assess container risk
    local running_count=$(echo "$container_status" | jq -r '.running_count // 0')
    local total_count=$(echo "$container_status" | jq -r '.total_count // 8')
    local availability_percent=$(echo "scale=0; $running_count * 100 / $total_count" | bc 2>/dev/null || echo "0")
    
    if [[ $availability_percent -lt 50 ]]; then
        risk_level="critical"
        risk_factors+=("\"Majority of containers offline\"")
        mitigation_strategies+=("\"Emergency container restart procedure\"")
    elif [[ $availability_percent -lt 80 ]]; then
        risk_level="high"
        risk_factors+=("\"Significant container availability issues\"")
        mitigation_strategies+=("\"Investigate and restart failed containers\"")
    elif [[ $availability_percent -lt 100 ]]; then
        risk_level="medium"
        risk_factors+=("\"Some containers offline\"")
        mitigation_strategies+=("\"Monitor and restart affected containers\"")
    fi
    
    cat << EOF
{
    "overall_risk_level": "$risk_level",
    "risk_factors": [$(IFS=','; echo "${risk_factors[*]}")],
    "mitigation_strategies": [$(IFS=','; echo "${mitigation_strategies[*]}")],
    "business_impact": "$(assess_business_impact "$risk_level" "$availability_percent")",
    "recovery_time_estimate": "$(estimate_recovery_time "$risk_level")"
}
EOF
}

assess_business_impact() {
    local risk_level="$1" availability="$2"
    
    case "$risk_level" in
        "critical") echo "Service completely unavailable or severely degraded" ;;
        "high") echo "Significant service disruption affecting user experience" ;;
        "medium") echo "Partial service impact with reduced functionality" ;;
        *) echo "Minimal to no business impact" ;;
    esac
}

estimate_recovery_time() {
    local risk_level="$1"
    
    case "$risk_level" in
        "critical") echo "5-15 minutes with immediate intervention" ;;
        "high") echo "2-10 minutes with prompt action" ;;
        "medium") echo "1-5 minutes with standard procedures" ;;
        *) echo "No recovery needed" ;;
    esac
}

generate_comprehensive_recommendations() {
    local docker_status="$1" container_status="$2" resource_status="$3"
    
    local recommendations=()
    
    # Docker recommendations
    if [[ $(echo "$docker_status" | jq -r '.docker_daemon.status') != "HEALTHY" ]]; then
        recommendations+=("{\"priority\": \"CRITICAL\", \"category\": \"infrastructure\", \"action\": \"restart_docker\", \"description\": \"Docker daemon requires immediate restart\", \"automation_possible\": true}")
    fi
    
    # Container recommendations
    local running_count=$(echo "$container_status" | jq -r '.running_count // 0')
    local total_count=$(echo "$container_status" | jq -r '.total_count // 8')
    if [[ $running_count -lt $total_count ]]; then
        recommendations+=("{\"priority\": \"HIGH\", \"category\": \"containers\", \"action\": \"restart_containers\", \"description\": \"Restart $((total_count - running_count)) offline containers\", \"automation_possible\": true}")
    fi
    
    # Resource recommendations
    local cpu_usage=$(echo "$resource_status" | jq -r '.cpu.usage // 0' | cut -d. -f1)
    local memory_usage=$(echo "$resource_status" | jq -r '.memory.usage_percent // 0' | cut -d. -f1)
    
    if [[ $cpu_usage -gt 80 ]]; then
        recommendations+=("{\"priority\": \"MEDIUM\", \"category\": \"performance\", \"action\": \"optimize_cpu\", \"description\": \"High CPU usage detected - consider scaling or optimization\", \"automation_possible\": false}")
    fi
    
    if [[ $memory_usage -gt 85 ]]; then
        recommendations+=("{\"priority\": \"MEDIUM\", \"category\": \"performance\", \"action\": \"optimize_memory\", \"description\": \"High memory usage detected - investigate memory leaks\", \"automation_possible\": false}")
    fi
    
    # Default recommendation if all is well
    if [[ ${#recommendations[@]} -eq 0 ]]; then
        recommendations+=("{\"priority\": \"INFO\", \"category\": \"maintenance\", \"action\": \"continue_monitoring\", \"description\": \"All systems operational - maintain current monitoring\", \"automation_possible\": true}")
    fi
    
    echo "[$(IFS=','; echo "${recommendations[*]}")]"
}

get_overall_analysis() {
    local docker_status="$1" container_status="$2" resource_status="$3" lifecycle_status="$4"
    
    local status="HEALTHY"
    local summary="" impact="" key_metrics=""
    
    # Determine overall status
    local docker_health=$(echo "$docker_status" | jq -r '.docker_daemon.status // "UNKNOWN"')
    local container_health=$(echo "$container_status" | jq -r '.status // "UNKNOWN"')
    local resource_health=$(echo "$resource_status" | jq -r '.status // "UNKNOWN"')
    
    if [[ "$docker_health" == "CRITICAL" ]] || [[ "$container_health" == "CRITICAL" ]] || [[ "$resource_health" == "CRITICAL" ]]; then
        status="CRITICAL"
        summary="Critical infrastructure issues detected requiring immediate attention"
        impact="Service availability severely compromised"
    elif [[ "$docker_health" == "WARNING" ]] || [[ "$container_health" == "WARNING" ]] || [[ "$resource_health" == "WARNING" ]]; then
        status="WARNING"
        summary="Infrastructure operating with warnings - monitoring and optimization needed"
        impact="Service functional but may experience performance issues"
    else
        status="HEALTHY"
        summary="Infrastructure operating normally across all components"
        impact="No negative impact on service availability or performance"
    fi
    
    # Generate key metrics
    local running_containers=$(echo "$container_status" | jq -r '.running_count // 0')
    local total_containers=$(echo "$container_status" | jq -r '.total_count // 8')
    local cpu_usage=$(echo "$resource_status" | jq -r '.cpu.usage // 0')
    local memory_usage=$(echo "$resource_status" | jq -r '.memory.usage_percent // 0')
    
    key_metrics="- **Container Availability:** $running_containers/$total_containers ($(echo "scale=0; $running_containers * 100 / $total_containers" | bc 2>/dev/null || echo "0")%)
- **Resource Utilization:** CPU ${cpu_usage}%, Memory ${memory_usage}%
- **Docker Status:** $docker_health
- **Overall Health Score:** $(calculate_overall_health_score "$docker_health" "$container_health" "$resource_health")/100"
    
    cat << EOF
{
    "status": "$status",
    "summary": "$summary",
    "impact": "$impact",
    "key_metrics": "$key_metrics"
}
EOF
}

calculate_overall_health_score() {
    local docker_health="$1" container_health="$2" resource_health="$3"
    
    local score=0
    
    # Docker component (30% weight)
    case "$docker_health" in
        "HEALTHY") score=$((score + 30)) ;;
        "WARNING") score=$((score + 15)) ;;
        "CRITICAL") score=$((score + 0)) ;;
    esac
    
    # Container component (40% weight)  
    case "$container_health" in
        "HEALTHY") score=$((score + 40)) ;;
        "WARNING") score=$((score + 20)) ;;
        "CRITICAL") score=$((score + 0)) ;;
    esac
    
    # Resource component (30% weight)
    case "$resource_health" in
        "HEALTHY") score=$((score + 30)) ;;
        "WARNING") score=$((score + 15)) ;;
        "CRITICAL") score=$((score + 0)) ;;
    esac
    
    echo "$score"
}

create_fallback_json() {
    local status="$1" duration="$2"
    
    cat << EOF
{
    "layer": "$LAYER_NAME",
    "timestamp": "$(date -u +"%Y-%m-%dT%H:%M:%SZ")",
    "duration_ms": $duration,
    "status": "$status",
    "error": "Failed to generate complete diagnostic JSON",
    "llm_context": {
        "data_quality": "incomplete",
        "alternative_sources": ["markdown summary", "detailed logs"],
        "recovery_action": "Check individual module outputs for partial data"
    }
}
EOF
}

extract_recommendations_from_json() {
    local json="$1"
    echo "$json" | jq -r '.recommendations[]?.description // "Continue monitoring"' 2>/dev/null | head -3 | while read -r rec; do
        echo "- $rec"
    done
}

main() {
    local start_time=$(date +%s%3N)
    
    echo ""
    echo "🚀 ==============================================="
    echo "🚀    INFRASTRUCTURE LAYER DIAGNOSTICS v2.0"
    echo "🚀    LLM-OPTIMIZED ANALYSIS SYSTEM"
    echo "🚀 ==============================================="
    echo "📍 Working directory: $(pwd)"
    echo "📁 Script directory: $ORIGINAL_SCRIPT_DIR"
    echo "⏰ Started at: $(date)"
    echo "🤖 Optimized for: Large Language Model Analysis"
    echo ""
    
    log_info "🚀 Starting $LAYER_NAME layer diagnostics v2.0"
    
    # Valida ambiente
    if ! validate_environment; then
        log_error "❌ Environment validation failed - exiting"
        exit 1
    fi
    
    log_info "✅ Environment validation passed"
    
    # Gera outputs otimizados para LLMs
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
    echo "🎉    LLM-OPTIMIZED OUTPUTS GENERATED"
    echo "🎉 ==============================================="
    echo "📊 Check the outputs in: $(get_output_dir 2>/dev/null || echo 'diagnostic output directory')"
    echo "📝 Detailed logs in: $LOG_BASE_DIR/${LAYER_NAME}_${TIMESTAMP}.log"
    echo "🤖 LLM analysis files: summary.md, diagnostic.json, llm_analysis.md"
    echo "⏰ Completed at: $(date)"
    echo ""
    
    log_info "🎉 Infrastructure layer diagnostics completed successfully"
}

# Executa main se chamado diretamente
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi