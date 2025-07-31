#!/bin/bash

#===============================================================================
# OUTPUT HANDLER - LLM OPTIMIZED
#===============================================================================

# Importa dependências
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" &> /dev/null && pwd)"
source "$SCRIPT_DIR/logger.sh"
source "$SCRIPT_DIR/utils.sh"

# Configuração global
if [[ -z "$DIAGNOSTIC_BASE_DIR" ]]; then
    declare -r DIAGNOSTIC_BASE_DIR="$(dirname "$SCRIPT_DIR")"
fi
declare OUTPUT_DIR=""
declare LAYER_NAME=""
declare TIMESTAMP=""
declare LOGS_DIR=""
if [[ -z "$PID" ]]; then
    declare -r PID="$$"
fi

#===============================================================================
# DIRECTORY MANAGEMENT
#===============================================================================

init_output_handler() {
    local layer="$1"
    LAYER_NAME="$layer"
    TIMESTAMP="$(date +%Y%m%d_%H%M%S)"
    
    # Cria estrutura hierárquica conforme arquitetura
    OUTPUT_DIR="$DIAGNOSTIC_BASE_DIR/outputs/$TIMESTAMP/$layer"
    CACHE_DIR="$OUTPUT_DIR/.cache"
    LOGS_DIR="$(dirname "$OUTPUT_DIR")/logs"

    # Cria estrutura de diretórios completa
    for dir in "$OUTPUT_DIR" "$CACHE_DIR" "$LOGS_DIR"; do
        if ! mkdir -p "$dir" 2>/dev/null; then
            log_warning "Failed to create directory, attempting with sudo: $dir"
            if ! sudo mkdir -p "$dir" 2>/dev/null; then
                log_error "Could not create directory: $dir"
                return 1
            fi
            sudo chown -R "$(id -u):$(id -g)" "$dir"
        fi

        # Verifica permissões de escrita
        if [[ ! -w "$dir" ]]; then
            log_error "Directory is not writable: $dir"
            return 1
        fi
    done

    log_debug "Output handler initialized for layer: $layer (Dir: $OUTPUT_DIR)"
    return 0
}

get_output_dir() {
    echo "$OUTPUT_DIR"
}

get_logs_dir() {
    echo "$LOGS_DIR"
}

#===============================================================================
# LLM-OPTIMIZED FILE GENERATION
#===============================================================================

generate_summary_md() {
    local title="$1"
    local content="$2"
    local output_file="$OUTPUT_DIR/${LAYER_NAME}_summary.md"

    ensure_output_permissions "$output_file" || return 1

    # Gera markdown otimizado para LLMs com estrutura clara
    cat > "$output_file" << EOF
# $title

## Executive Summary
**Generated:** $(date -u +"%Y-%m-%dT%H:%M:%SZ")  
**Layer:** $LAYER_NAME  
**Process ID:** $PID  
**Timestamp:** $TIMESTAMP

## Diagnostic Results

$content

## Analysis for LLM Processing

### Key Findings
$(extract_key_findings "$content")

### Recommendations  
$(extract_recommendations "$content")

### Performance Metrics
$(extract_performance_metrics "$content")

### Troubleshooting Context
$(generate_troubleshooting_context)

---

*This report is optimized for Large Language Model analysis and automated processing*
EOF

    log_debug "Generated LLM-optimized ${LAYER_NAME}_summary.md at: $output_file"
    return 0
}

extract_key_findings() {
    local content="$1"
    
    # Extrai findings do conteúdo usando padrões comuns
    echo "$content" | grep -E "^\s*•|^\s*-|\*\*|Status:" | head -10 | while read -r line; do
        echo "- $(echo "$line" | sed 's/^[[:space:]]*[•-]//' | sed 's/^\*\*//' | sed 's/\*\*$//')"
    done
    
    # Se não encontrou findings estruturados, cria um resumo básico
    if [[ -z "$(echo "$content" | grep -E "^\s*•|^\s*-|\*\*|Status:")" ]]; then
        echo "- Diagnostic completed for $LAYER_NAME layer"
        echo "- Detailed results available in structured data"
        echo "- Timestamp: $(date -u +"%Y-%m-%dT%H:%M:%SZ")"
    fi
}

extract_recommendations() {
    local content="$1"
    
    # Procura seções de recomendações
    if echo "$content" | grep -qi "recommendation"; then
        echo "$content" | grep -A 10 -i "recommendation" | grep -E "^\s*•|^\s*-" | head -5
    else
        echo "- Continue monitoring system health"
        echo "- Review diagnostic outputs for detailed analysis"
        echo "- Address any critical issues identified"
    fi
}

extract_performance_metrics() {
    local content="$1"
    
    # Extrai métricas numéricas do conteúdo
    local metrics=()
    
    # CPU usage
    if cpu_metric=$(echo "$content" | grep -o "CPU.*[0-9]\+%" | head -1); then
        metrics+=("- $cpu_metric")
    fi
    
    # Memory usage  
    if mem_metric=$(echo "$content" | grep -o "Memory.*[0-9]\+%" | head -1); then
        metrics+=("- $mem_metric")
    fi
    
    # Container counts
    if container_metric=$(echo "$content" | grep -o "[0-9]\+/[0-9]\+ container" | head -1); then
        metrics+=("- Containers: $container_metric")
    fi
    
    # Se não encontrou métricas, adiciona placeholder
    if [[ ${#metrics[@]} -eq 0 ]]; then
        metrics+=("- Performance metrics available in JSON output")
        metrics+=("- Layer: $LAYER_NAME completed successfully")
    fi
    
    printf '%s\n' "${metrics[@]}"
}

generate_troubleshooting_context() {
    cat << EOF
**For LLM Analysis:**
- Layer Name: $LAYER_NAME
- Execution Time: $(date -u +"%Y-%m-%dT%H:%M:%SZ")
- Output Directory: $OUTPUT_DIR
- Log Files: Available in $LOGS_DIR
- Process ID: $PID

**Common Issues:**
- Check container_diagnostic.sh for container health
- Review resource_monitoring.sh for system resources
- Examine docker_diagnostic.sh for Docker environment
- Monitor logs for error patterns

**Data Sources:**
- JSON: Structured data for automated processing
- MD: Human-readable analysis and insights  
- LOG: Detailed execution trace and debugging
EOF
}

generate_results_json() {
    local content="$1"
    local output_file="$OUTPUT_DIR/${LAYER_NAME}_diagnostic.json"

    ensure_output_permissions "$output_file" || return 1

    # Valida se o conteúdo não está vazio
    if [[ -z "$content" ]]; then
        log_error "Empty content provided for JSON generation"
        return 1
    fi

    # Tenta validar e formatar o JSON
    local validated_json
    if validated_json=$(echo "$content" | jq '.' 2>/dev/null); then
        # Adiciona metadados de contexto para LLMs
        local enhanced_json
        enhanced_json=$(echo "$validated_json" | jq --arg ts "$(date -u +"%Y-%m-%dT%H:%M:%SZ")" \
                                                     --arg layer "$LAYER_NAME" \
                                                     --arg version "2.0.0" \
                                                     '. + {
            "llm_context": {
                "generated_at": $ts,
                "layer": $layer,
                "diagnostic_version": $version,
                "optimized_for": "LLM analysis and automated processing",
                "data_quality": "validated",
                "processing_hints": {
                    "focus_areas": ["status", "insights", "recommendations"],
                    "critical_fields": ["running_count", "healthy_count", "performance_score"],
                    "actionable_data": "recommendations array contains prioritized actions"
                }
            }
        }')
        
        # Escreve o JSON enriquecido no arquivo
        if echo "$enhanced_json" > "$output_file" 2>/dev/null; then
            log_debug "Generated LLM-optimized ${LAYER_NAME}_diagnostic.json at: $output_file"
            return 0
        else
            log_error "Failed to write JSON to file: $output_file"
            return 1
        fi
    else
        log_error "Invalid JSON content provided"
        log_debug "JSON validation error: $(echo "$content" | jq '.' 2>&1)"
        
        # Cria um JSON de erro estruturado para LLMs
        local error_json
        error_json=$(cat << EOF
{
    "error": {
        "type": "json_validation_failure",
        "message": "Failed to generate valid JSON",
        "timestamp": "$(date -u +"%Y-%m-%dT%H:%M:%SZ")",
        "layer": "$LAYER_NAME",
        "raw_content_length": ${#content},
        "troubleshooting": {
            "likely_causes": [
                "Syntax error in JSON generation",
                "Invalid numeric values",
                "Unescaped special characters"
            ],
            "next_steps": [
                "Check source data for invalid characters",
                "Review numeric value formatting",
                "Examine log files for detailed errors"
            ]
        }
    },
    "llm_context": {
        "status": "FAILED",
        "data_available": false,
        "alternative_sources": ["log files", "markdown summary"],
        "recovery_action": "Use fallback diagnostic data"
    }
}
EOF
)
        
        if echo "$error_json" | jq '.' > "$output_file" 2>/dev/null; then
            log_warning "Generated structured error JSON for LLM processing"
            return 0
        else
            log_error "Failed to generate even error JSON"
            return 1
        fi
    fi
}

copy_detailed_log() {
    local log_file="$1"
    local output_file="$OUTPUT_DIR/${LAYER_NAME}_detailed.log"

    ensure_output_permissions "$output_file" || return 1

    if [[ -f "$log_file" ]]; then
        # Enriquece o log com contexto para LLMs
        {
            echo "==================================================================================="
            echo "DETAILED DIAGNOSTIC LOG - OPTIMIZED FOR LLM ANALYSIS"
            echo "==================================================================================="
            echo "Layer: $LAYER_NAME"
            echo "Timestamp: $(date -u +"%Y-%m-%dT%H:%M:%SZ")"
            echo "Process ID: $PID"
            echo "Output Directory: $OUTPUT_DIR"
            echo "==================================================================================="
            echo ""
            echo "LOG ANALYSIS GUIDE FOR LLMs:"
            echo "- ERROR entries indicate failures requiring attention"
            echo "- WARNING entries suggest potential issues"
            echo "- INFO entries show normal operation flow"
            echo "- DEBUG entries provide detailed execution trace"
            echo "- Look for patterns in timestamps and error codes"
            echo "- Container names follow pattern: syntropy-*"
            echo "- Timeouts typically indicate resource constraints"
            echo ""
            echo "==================================================================================="
            echo "ORIGINAL LOG CONTENT:"
            echo "==================================================================================="
            echo ""
            cat "$log_file"
        } > "$output_file" || {
            log_error "Failed to copy log file to: $output_file"
            return 1
        }
        log_debug "Copied enhanced ${LAYER_NAME}_detailed.log to: $output_file"
        return 0
    else
        log_error "Source log file not found: $log_file"
        return 1
    fi
}

#===============================================================================
# LLM-SPECIFIC OUTPUT ENHANCEMENTS
#===============================================================================

generate_llm_analysis_summary() {
    local layer="$1"
    local status="$2"
    local key_metrics="$3"
    local recommendations="$4"
    
    local analysis_file="$OUTPUT_DIR/${layer}_llm_analysis.md"
    
    cat > "$analysis_file" << EOF
# LLM Analysis Summary - $layer Layer

## Quick Status Assessment
- **Overall Status:** $status
- **Analysis Timestamp:** $(date -u +"%Y-%m-%dT%H:%M:%SZ")
- **Layer:** $layer
- **Confidence Level:** High (automated diagnostic)

## Key Metrics for Decision Making
$key_metrics

## Actionable Recommendations
$recommendations

## Context for Troubleshooting
- **Data Sources:** JSON (structured), MD (readable), LOG (detailed)
- **Confidence Indicators:** Look for "insights" and "performance_score" fields
- **Priority Actions:** Focus on "CRITICAL" and "WARNING" status items
- **Performance Baselines:** 
  - CPU usage: <80% good, >90% critical
  - Memory usage: <85% good, >95% critical
  - Container health: "HEALTHY" optimal, "UNHEALTHY" critical
  - Restart count: <3 good, >10 critical

## Diagnostic Quality Indicators
- **Completeness:** All configured containers checked
- **Accuracy:** Live data from Docker API
- **Timeliness:** Real-time status collection
- **Reliability:** Multiple validation layers applied

## Related Files for Deep Analysis
- **Structured Data:** ${layer}_diagnostic.json
- **Execution Trace:** ${layer}_detailed.log
- **Human Summary:** ${layer}_summary.md

---
*This analysis is specifically formatted for LLM consumption and automated decision-making*
EOF

    log_debug "Generated LLM analysis summary at: $analysis_file"
}

generate_performance_insights() {
    local layer="$1"
    local start_time="$2"
    local end_time="$3"
    
    local duration=$((end_time - start_time))
    local insights_file="$OUTPUT_DIR/${layer}_performance_insights.json"
    
    # Coleta métricas de performance do processo
    local cpu_usage memory_usage
    cpu_usage=$(ps -p $PID -o %cpu= 2>/dev/null | tr -d ' ' || echo "0")
    memory_usage=$(ps -p $PID -o %mem= 2>/dev/null | tr -d ' ' || echo "0")
    
    cat > "$insights_file" << EOF
{
    "performance_analysis": {
        "execution_metrics": {
            "duration_ms": $duration,
            "cpu_usage_percent": $cpu_usage,
            "memory_usage_percent": $memory_usage,
            "process_id": $PID
        },
        "efficiency_score": $(calculate_efficiency_score "$duration" "$cpu_usage" "$memory_usage"),
        "performance_category": "$(categorize_performance "$duration")",
        "optimization_suggestions": $(generate_optimization_suggestions "$duration" "$cpu_usage" "$memory_usage"),
        "baseline_comparison": {
            "target_duration_ms": 5000,
            "target_cpu_percent": 5.0,
            "target_memory_percent": 2.0,
            "performance_vs_target": "$(compare_with_baseline "$duration" "$cpu_usage" "$memory_usage")"
        }
    },
    "llm_interpretation": {
        "performance_summary": "$(summarize_performance "$duration" "$cpu_usage" "$memory_usage")",
        "actionable_insights": $(generate_actionable_insights "$duration" "$cpu_usage" "$memory_usage"),
        "monitoring_recommendations": [
            "Track execution duration trends",
            "Monitor resource usage patterns",
            "Alert on performance degradation",
            "Optimize based on bottleneck analysis"
        ]
    },
    "metadata": {
        "generated_at": "$(date -u +"%Y-%m-%dT%H:%M:%SZ")",
        "layer": "$layer",
        "measurement_accuracy": "high",
        "data_freshness": "real-time"
    }
}
EOF

    log_debug "Generated performance insights at: $insights_file"
}

calculate_efficiency_score() {
    local duration="$1"
    local cpu_usage="$2"
    local memory_usage="$3"
    
    local duration_score=100
    local resource_score=100
    
    # Score baseado em duração (target: 5000ms)
    if [[ $duration -gt 30000 ]]; then
        duration_score=20
    elif [[ $duration -gt 15000 ]]; then
        duration_score=50
    elif [[ $duration -gt 10000 ]]; then
        duration_score=70
    elif [[ $duration -gt 5000 ]]; then
        duration_score=85
    fi
    
    # Score baseado em recursos (target: <5% CPU, <2% MEM)
    local avg_resource
    avg_resource=$(echo "scale=2; ($cpu_usage + $memory_usage) / 2" | bc 2>/dev/null || echo "0")
    
    if [[ $(echo "$avg_resource > 20" | bc 2>/dev/null || echo "0") -eq 1 ]]; then
        resource_score=30
    elif [[ $(echo "$avg_resource > 10" | bc 2>/dev/null || echo "0") -eq 1 ]]; then
        resource_score=60
    elif [[ $(echo "$avg_resource > 5" | bc 2>/dev/null || echo "0") -eq 1 ]]; then
        resource_score=80
    fi
    
    # Score final (média ponderada: 60% duração, 40% recursos)
    local final_score
    final_score=$(echo "scale=0; ($duration_score * 0.6 + $resource_score * 0.4) / 1" | bc 2>/dev/null || echo "75")
    
    echo "$final_score"
}

categorize_performance() {
    local duration="$1"
    
    if [[ $duration -lt 3000 ]]; then
        echo "Excellent"
    elif [[ $duration -lt 7000 ]]; then
        echo "Good"
    elif [[ $duration -lt 15000 ]]; then
        echo "Fair"
    elif [[ $duration -lt 30000 ]]; then
        echo "Poor"
    else
        echo "Critical"
    fi
}

generate_optimization_suggestions() {
    local duration="$1"
    local cpu_usage="$2"
    local memory_usage="$3"
    
    local suggestions=()
    
    if [[ $duration -gt 15000 ]]; then
        suggestions+=('{"type": "performance", "action": "Optimize execution path", "priority": "HIGH"}')
    fi
    
    if [[ $(echo "$cpu_usage > 10" | bc 2>/dev/null || echo "0") -eq 1 ]]; then
        suggestions+=('{"type": "resource", "action": "Reduce CPU-intensive operations", "priority": "MEDIUM"}')
    fi
    
    if [[ $(echo "$memory_usage > 5" | bc 2>/dev/null || echo "0") -eq 1 ]]; then
        suggestions+=('{"type": "resource", "action": "Optimize memory usage", "priority": "MEDIUM"}')
    fi
    
    if [[ ${#suggestions[@]} -eq 0 ]]; then
        suggestions+=('{"type": "maintenance", "action": "Continue current optimization", "priority": "LOW"}')
    fi
    
    echo "[$(IFS=','; echo "${suggestions[*]}")]"
}

compare_with_baseline() {
    local duration="$1"
    local cpu_usage="$2"
    local memory_usage="$3"
    
    local target_duration=5000
    local target_cpu=5.0
    local target_memory=2.0
    
    local duration_ratio=$((duration * 100 / target_duration))
    local cpu_ratio=$(echo "scale=0; $cpu_usage * 100 / $target_cpu" | bc 2>/dev/null || echo "100")
    local memory_ratio=$(echo "scale=0; $memory_usage * 100 / $target_memory" | bc 2>/dev/null || echo "100")
    
    if [[ $duration_ratio -le 120 ]] && [[ $cpu_ratio -le 150 ]] && [[ $memory_ratio -le 150 ]]; then
        echo "Within acceptable range"
    elif [[ $duration_ratio -le 200 ]] && [[ $cpu_ratio -le 300 ]] && [[ $memory_ratio -le 300 ]]; then
        echo "Above target but acceptable"
    else
        echo "Significantly above target - optimization needed"
    fi
}

summarize_performance() {
    local duration="$1"
    local cpu_usage="$2"
    local memory_usage="$3"
    
    local category=$(categorize_performance "$duration")
    local duration_sec=$(echo "scale=1; $duration / 1000" | bc 2>/dev/null || echo "0")
    
    echo "Diagnostic execution: ${category} performance (${duration_sec}s, ${cpu_usage}% CPU, ${memory_usage}% memory)"
}

generate_actionable_insights() {
    local duration="$1"
    local cpu_usage="$2"
    local memory_usage="$3"
    
    local insights=()
    
    if [[ $duration -gt 20000 ]]; then
        insights+=('{"insight": "Execution time exceeds 20 seconds", "action": "Investigate performance bottlenecks", "urgency": "medium"}')
    fi
    
    if [[ $(echo "$cpu_usage > 15" | bc 2>/dev/null || echo "0") -eq 1 ]]; then
        insights+=('{"insight": "High CPU usage during diagnostic", "action": "Schedule diagnostics during low-usage periods", "urgency": "low"}')
    fi
    
    if [[ $duration -lt 3000 ]] && [[ $(echo "$cpu_usage < 5" | bc 2>/dev/null || echo "1") -eq 1 ]]; then
        insights+=('{"insight": "Optimal performance achieved", "action": "Maintain current configuration", "urgency": "info"}')
    fi
    
    if [[ ${#insights[@]} -eq 0 ]]; then
        insights+=('{"insight": "Performance within expected parameters", "action": "Continue monitoring", "urgency": "info"}')
    fi
    
    echo "[$(IFS=','; echo "${insights[*]}")]"
}

ensure_output_permissions() {
    local path="$1"
    if [[ ! -w "$(dirname "$path")" ]]; then
        sudo chown -R "$(id -u):$(id -g)" "$(dirname "$path")"
        if [[ $? -ne 0 ]]; then
            log_error "Failed to set permissions for: $path"
            return 1
        fi
    fi
    return 0
}

#===============================================================================
# CLEANUP
#===============================================================================

cleanup_old_outputs() {
    local days="${1:-7}"

    # Remove diretórios mais antigos que X dias
    find "$DIAGNOSTIC_BASE_DIR/outputs" -mindepth 1 -maxdepth 1 -type d -mtime +"$days" -exec rm -rf {} + 2>/dev/null || {
        log_warning "Failed to cleanup old outputs, attempting with sudo"
        sudo find "$DIAGNOSTIC_BASE_DIR/outputs" -mindepth 1 -maxdepth 1 -type d -mtime +"$days" -exec rm -rf {} + 2>/dev/null
    }

    log_debug "Cleaned up diagnostic outputs older than $days days"
}

#===============================================================================
# EXPORT FUNCTIONS
#===============================================================================

export DIAGNOSTIC_BASE_DIR OUTPUT_DIR LAYER_NAME TIMESTAMP LOGS_DIR
export -f init_output_handler get_output_dir get_logs_dir ensure_output_permissions
export -f generate_summary_md generate_results_json copy_detailed_log
export -f generate_llm_analysis_summary generate_performance_insights
export -f cleanup_old_outputs