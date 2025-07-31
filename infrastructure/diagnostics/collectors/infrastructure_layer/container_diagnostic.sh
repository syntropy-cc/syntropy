#!/bin/bash

#===============================================================================
# CONTAINER STATUS DIAGNOSTIC - ULTRA-ROBUST VERSION
#===============================================================================

# Importa funções de logging e utilitários
MODULE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" &> /dev/null && pwd)"
CORE_DIR="$(cd "$MODULE_DIR/../../core" &> /dev/null && pwd)"
source "$CORE_DIR/logger.sh" || exit 1
source "$CORE_DIR/utils.sh" || exit 1

# Carrega configurações
CONFIG_FILE="$MODULE_DIR/config.json"
if [[ -f "$CONFIG_FILE" ]]; then
    CONTAINERS=($(jq -r '.containers[]' "$CONFIG_FILE" 2>/dev/null || echo ""))
    CHECK_TIMEOUT=$(jq -r '.timeouts.container_check' "$CONFIG_FILE" 2>/dev/null || echo "10")
else
    log_warning "Config file not found, using defaults"
    CONTAINERS=("syntropy-db" "syntropy-kong" "syntropy-auth" "syntropy-rest" "syntropy-realtime" "syntropy-storage" "syntropy-imgproxy" "syntropy-nextjs")
    CHECK_TIMEOUT=10
fi

#===============================================================================
# ENHANCED LOGGING AND ERROR HANDLING
#===============================================================================

safe_log() {
    local level="$1"
    local message="$2"
    local error_code="${3:-}"
    
    # Garante que o log funcione mesmo se logger falhar
    if declare -f "log_$level" >/dev/null 2>&1; then
        "log_$level" "$message" "$error_code"
    else
        echo "[$(date '+%Y-%m-%d %H:%M:%S')][$level] $message" >&2
    fi
}

#===============================================================================
# ULTRA-SAFE JSON FUNCTIONS
#===============================================================================

ultra_sanitize_string() {
    local input="$1"
    # Múltiplas camadas de sanitização
    echo "$input" | \
        tr -d '\000-\037\177-\377' | \
        sed 's/[[:cntrl:]]//g' | \
        sed 's/"/\\"/g' | \
        sed 's/\\/\\\\/g' | \
        sed 's/\t/ /g' | \
        sed 's/\r//g' | \
        sed 's/\n/ /g' | \
        tr -cd '[:print:][:space:]' | \
        sed 's/[[:space:]]\+/ /g' | \
        sed 's/^[[:space:]]*//;s/[[:space:]]*$//' | \
        cut -c1-200  # Limita tamanho para evitar strings muito longas
}

ultra_sanitize_number() {
    local value="$1"
    # Remove tudo exceto números e ponto decimal
    value=$(echo "$value" | sed 's/[^0-9.]//g' | tr -d '\000-\037')
    
    # Verifica se é um número válido
    if [[ "$value" =~ ^[0-9]*\.?[0-9]+$ ]] || [[ "$value" =~ ^[0-9]+$ ]]; then
        # Limita casas decimais
        printf "%.2f" "$value" 2>/dev/null || echo "0.00"
    else
        echo "0.00"
    fi
}

#===============================================================================
# ROBUST DOCKER OPERATIONS
#===============================================================================

safe_docker_command() {
    local timeout_duration="$1"
    local description="$2"
    shift 2
    local command=("$@")
    
    safe_log "debug" "Executing: ${command[*]} (timeout: ${timeout_duration}s)"
    
    local result
    if result=$(timeout "$timeout_duration" "${command[@]}" 2>&1); then
        # Sanitiza imediatamente
        result=$(ultra_sanitize_string "$result")
        echo "$result"
        return 0
    else
        local exit_code=$?
        safe_log "warning" "Command failed: $description (exit code: $exit_code)"
        echo ""
        return $exit_code
    fi
}

get_container_basic_info() {
    local container="$1"
    local info=()
    
    # Status básico
    local status=$(safe_docker_command 5 "container status" docker inspect --format='{{.State.Status}}' "$container")
    info+=("status:$(ultra_sanitize_string "${status:-unknown}")")
    
    # Health check
    local health=$(safe_docker_command 5 "container health" docker inspect --format='{{.State.Health.Status}}' "$container")
    info+=("health:$(ultra_sanitize_string "${health:-none}")")
    
    # Uptime
    local started=$(safe_docker_command 5 "container start time" docker inspect --format='{{.State.StartedAt}}' "$container")
    info+=("started:$(ultra_sanitize_string "${started:-unknown}")")
    
    # Restart count
    local restarts=$(safe_docker_command 5 "restart count" docker inspect --format='{{.RestartCount}}' "$container")
    restarts=$(ultra_sanitize_number "${restarts:-0}")
    info+=("restarts:$restarts")
    
    # Exit code
    local exit_code=$(safe_docker_command 5 "exit code" docker inspect --format='{{.State.ExitCode}}' "$container")
    exit_code=$(ultra_sanitize_number "${exit_code:-0}")
    info+=("exit_code:$exit_code")
    
    # Retorna como string estruturada
    printf '%s\n' "${info[@]}"
}

get_container_resources() {
    local container="$1"
    
    # Tenta pegar stats com timeout muito curto
    local stats_output
    if stats_output=$(timeout 2 docker stats --no-stream --format "{{.CPUPerc}}\t{{.MemPerc}}" "$container" 2>/dev/null); then
        # Parse seguro
        local cpu_raw=$(echo "$stats_output" | cut -f1 2>/dev/null | sed 's/%//')
        local mem_raw=$(echo "$stats_output" | cut -f2 2>/dev/null | sed 's/%//')
        
        local cpu_clean=$(ultra_sanitize_number "$cpu_raw")
        local mem_clean=$(ultra_sanitize_number "$mem_raw")
        
        echo "cpu:$cpu_clean,memory:$mem_clean,stats_available:true"
    else
        safe_log "debug" "Stats not available for $container (timeout or error)"
        echo "cpu:0.00,memory:0.00,stats_available:false"
    fi
}

#===============================================================================
# ENHANCED CONTAINER ANALYSIS
#===============================================================================

analyze_container() {
    local container="$1"
    safe_log "info" "Analyzing container: $container"
    
    # Primeiro, verifica se container existe
    if ! docker ps -a --format "{{.Names}}" | grep -q "^${container}$"; then
        safe_log "warning" "Container '$container' not found in docker ps -a"
        return 1
    fi
    
    # Verifica se está rodando
    local is_running=false
    if docker ps --format "{{.Names}}" | grep -q "^${container}$"; then
        is_running=true
        safe_log "debug" "Container $container is running"
    else
        safe_log "warning" "Container $container is not running"
    fi
    
    # Coleta informações básicas
    local basic_info
    basic_info=$(get_container_basic_info "$container")
    
    # Parse das informações básicas
    local status=$(echo "$basic_info" | grep "^status:" | cut -d: -f2-)
    local health=$(echo "$basic_info" | grep "^health:" | cut -d: -f2-)
    local started=$(echo "$basic_info" | grep "^started:" | cut -d: -f2-)
    local restarts=$(echo "$basic_info" | grep "^restarts:" | cut -d: -f2-)
    local exit_code=$(echo "$basic_info" | grep "^exit_code:" | cut -d: -f2-)
    
    # Coleta recursos se estiver rodando
    local cpu_usage="0.00" memory_usage="0.00" stats_available="false"
    if [[ "$is_running" == "true" ]]; then
        local resource_info
        resource_info=$(get_container_resources "$container")
        cpu_usage=$(echo "$resource_info" | cut -d, -f1 | cut -d: -f2)
        memory_usage=$(echo "$resource_info" | cut -d, -f2 | cut -d: -f2)
        stats_available=$(echo "$resource_info" | cut -d, -f3 | cut -d: -f2)
    fi
    
    # Determina health status
    local health_status="UNKNOWN"
    local performance_score=0
    local availability_insight="Container analysis completed"
    
    if [[ "$is_running" == "false" ]]; then
        health_status="CRITICAL"
        performance_score=0
        availability_insight="Container is offline"
    else
        case "$health" in
            "healthy")
                health_status="HEALTHY"
                performance_score=100
                availability_insight="Container is healthy and running"
                ;;
            "unhealthy")
                health_status="CRITICAL"
                performance_score=20
                availability_insight="Container health check failing"
                ;;
            "starting")
                health_status="WARNING"
                performance_score=60
                availability_insight="Container is starting up"
                ;;
            *)
                health_status="HEALTHY"
                performance_score=80
                availability_insight="Container running without health check"
                ;;
        esac
        
        # Ajusta score baseado em restarts
        local restart_num=$(echo "$restarts" | cut -d. -f1)
        if [[ "$restart_num" -gt 5 ]]; then
            performance_score=$((performance_score - 30))
            health_status="WARNING"
        fi
        
        # Ajusta score baseado em recursos
        local cpu_int=$(echo "$cpu_usage" | cut -d. -f1)
        local mem_int=$(echo "$memory_usage" | cut -d. -f1)
        if [[ "$cpu_int" -gt 80 ]] || [[ "$mem_int" -gt 80 ]]; then
            performance_score=$((performance_score - 20))
        fi
    fi
    
    # Garante que performance_score seja válido
    [[ $performance_score -lt 0 ]] && performance_score=0
    [[ $performance_score -gt 100 ]] && performance_score=100
    
    # Calcula uptime legível
    local uptime_human="Unknown"
    if [[ "$started" != "unknown" ]] && [[ -n "$started" ]]; then
        local start_epoch=$(date -d "$started" +%s 2>/dev/null || echo "0")
        local current_epoch=$(date +%s)
        local uptime_seconds=$((current_epoch - start_epoch))
        
        if [[ $uptime_seconds -gt 0 ]]; then
            if [[ $uptime_seconds -lt 60 ]]; then
                uptime_human="${uptime_seconds}s"
            elif [[ $uptime_seconds -lt 3600 ]]; then
                uptime_human="$((uptime_seconds / 60))m"
            elif [[ $uptime_seconds -lt 86400 ]]; then
                uptime_human="$((uptime_seconds / 3600))h"
            else
                uptime_human="$((uptime_seconds / 86400))d"
            fi
        fi
    fi
    
    # Retorna resultado estruturado
    cat << EOF
container_name:$container
running:$is_running
health_status:$health_status
status:$status
health:$health
uptime:$started
uptime_human:$uptime_human
restarts:$restarts
exit_code:$exit_code
cpu_usage:$cpu_usage
memory_usage:$memory_usage
stats_available:$stats_available
performance_score:$performance_score
availability_insight:$availability_insight
EOF
}

#===============================================================================
# ROBUST JSON GENERATION
#===============================================================================

create_container_json() {
    local analysis_result="$1"
    
    # Parse do resultado da análise
    local container_name=$(echo "$analysis_result" | grep "^container_name:" | cut -d: -f2-)
    local running=$(echo "$analysis_result" | grep "^running:" | cut -d: -f2-)
    local health_status=$(echo "$analysis_result" | grep "^health_status:" | cut -d: -f2-)
    local status=$(echo "$analysis_result" | grep "^status:" | cut -d: -f2-)
    local health=$(echo "$analysis_result" | grep "^health:" | cut -d: -f2-)
    local uptime=$(echo "$analysis_result" | grep "^uptime:" | cut -d: -f2-)
    local uptime_human=$(echo "$analysis_result" | grep "^uptime_human:" | cut -d: -f2-)
    local restarts=$(echo "$analysis_result" | grep "^restarts:" | cut -d: -f2-)
    local exit_code=$(echo "$analysis_result" | grep "^exit_code:" | cut -d: -f2-)
    local cpu_usage=$(echo "$analysis_result" | grep "^cpu_usage:" | cut -d: -f2-)
    local memory_usage=$(echo "$analysis_result" | grep "^memory_usage:" | cut -d: -f2-)
    local stats_available=$(echo "$analysis_result" | grep "^stats_available:" | cut -d: -f2-)
    local performance_score=$(echo "$analysis_result" | grep "^performance_score:" | cut -d: -f2-)
    local availability_insight=$(echo "$analysis_result" | grep "^availability_insight:" | cut -d: -f2-)
    
    # Cria JSON de forma ultra-segura
    cat << EOF
{
    "running": $running,
    "health": "$health_status",
    "uptime": "$uptime",
    "uptime_human": "$uptime_human",
    "restarts": $restarts,
    "exit_code": $exit_code,
    "cpu_usage": $cpu_usage,
    "memory_usage": $memory_usage,
    "status": "$status",
    "stats_available": $stats_available,
    "insights": {
        "availability": "$availability_insight",
        "impact": "$(get_impact_assessment "$health_status" "$running")",
        "recommendation": "$(get_recommendation "$health_status" "$running")",
        "performance_score": $performance_score,
        "restart_stability": "$(get_restart_stability "$restarts")",
        "resource_efficiency": "$(get_resource_efficiency "$cpu_usage" "$memory_usage" "$stats_available")"
    }
}
EOF
}

get_impact_assessment() {
    local health_status="$1"
    local running="$2"
    
    if [[ "$running" == "false" ]]; then
        echo "Service functionality compromised - container offline"
    elif [[ "$health_status" == "CRITICAL" ]]; then
        echo "Service degraded - health check failing"
    elif [[ "$health_status" == "WARNING" ]]; then
        echo "Service functional but may have issues"
    else
        echo "Service operating normally"
    fi
}

get_recommendation() {
    local health_status="$1"
    local running="$2"
    
    if [[ "$running" == "false" ]]; then
        echo "Investigate logs and restart container immediately"
    elif [[ "$health_status" == "CRITICAL" ]]; then
        echo "Check application health and restart if needed"
    elif [[ "$health_status" == "WARNING" ]]; then
        echo "Monitor startup progress and check for errors"
    else
        echo "Continue normal monitoring"
    fi
}

get_restart_stability() {
    local restarts="$1"
    local restart_num=$(echo "$restarts" | cut -d. -f1)
    
    if [[ "$restart_num" -eq 0 ]]; then
        echo "Excellent - No restarts"
    elif [[ "$restart_num" -le 2 ]]; then
        echo "Good - Minimal restarts"
    elif [[ "$restart_num" -le 5 ]]; then
        echo "Fair - Some instability"
    else
        echo "Poor - Frequent restarts"
    fi
}

get_resource_efficiency() {
    local cpu_usage="$1"
    local memory_usage="$2"
    local stats_available="$3"
    
    if [[ "$stats_available" != "true" ]]; then
        echo "Unknown - Stats unavailable"
        return
    fi
    
    local cpu_int=$(echo "$cpu_usage" | cut -d. -f1)
    local mem_int=$(echo "$memory_usage" | cut -d. -f1)
    local avg_usage=$(( (cpu_int + mem_int) / 2 ))
    
    if [[ $avg_usage -lt 30 ]]; then
        echo "Excellent - Low resource usage"
    elif [[ $avg_usage -lt 60 ]]; then
        echo "Good - Moderate resource usage"
    elif [[ $avg_usage -lt 80 ]]; then
        echo "Fair - High resource usage"
    else
        echo "Poor - Critical resource usage"
    fi
}

#===============================================================================
# MAIN DIAGNOSTIC FUNCTION
#===============================================================================

run_container_diagnostic() {
    safe_log "info" "Starting ultra-robust container diagnostic"
    
    # Verifica se Docker está funcionando
    if ! docker info >/dev/null 2>&1; then
        safe_log "error" "Docker is not accessible"
        cat << EOF
{
    "status": "CRITICAL",
    "error": "Docker daemon not accessible",
    "running_count": 0,
    "total_count": 0,
    "healthy_count": 0,
    "unhealthy_count": 0,
    "containers": {},
    "unhealthy_containers": [],
    "performance_issues": [],
    "insights": {
        "summary": "Docker daemon is not accessible",
        "impact_assessment": "Cannot assess any container health",
        "overall_performance_score": 0,
        "container_insights": [],
        "recommendations": [{"action": "restart_docker", "priority": "CRITICAL", "description": "Restart Docker daemon"}],
        "health_distribution": {"healthy": 0, "unhealthy": 0, "offline": 0}
    },
    "metadata": {
        "timestamp": "$(date -u +"%Y-%m-%dT%H:%M:%SZ")",
        "diagnostic_version": "2.1.0",
        "error_code": "DOCKER_UNAVAILABLE"
    }
}
EOF
        return 1
    fi
    
    # Verifica se há containers configurados
    if [[ ${#CONTAINERS[@]} -eq 0 ]]; then
        safe_log "error" "No containers configured"
        cat << EOF
{
    "status": "CRITICAL",
    "error": "No containers configured",
    "running_count": 0,
    "total_count": 0,
    "containers": {},
    "insights": {
        "summary": "No containers configured for monitoring",
        "recommendation": "Configure container names in config.json"
    }
}
EOF
        return 1
    fi
    
    local total_containers=${#CONTAINERS[@]}
    local running_containers=0 healthy_containers=0
    local unhealthy_containers=() performance_issues=()
    local container_results=() detailed_insights=()
    local total_performance=0
    
    safe_log "info" "Processing $total_containers containers: ${CONTAINERS[*]}"
    
    # Analisa cada container
    for container in "${CONTAINERS[@]}"; do
        # Sanitiza nome do container
        container=$(ultra_sanitize_string "$container")
        
        if [[ -z "$container" ]]; then
            safe_log "warning" "Empty container name, skipping"
            continue
        fi
        
        safe_log "info" "Processing container: $container"
        
        # Analisa container
        local analysis_result
        if analysis_result=$(analyze_container "$container"); then
            # Cria JSON para este container
            local container_json
            container_json=$(create_container_json "$analysis_result")
            
            # Valida JSON
            if echo "$container_json" | jq '.' >/dev/null 2>&1; then
                container_results+=("\"$container\": $container_json")
                
                # Extrai métricas para contadores
                local is_running=$(echo "$analysis_result" | grep "^running:" | cut -d: -f2-)
                local health_status=$(echo "$analysis_result" | grep "^health_status:" | cut -d: -f2-)
                local performance_score=$(echo "$analysis_result" | grep "^performance_score:" | cut -d: -f2-)
                local availability_insight=$(echo "$analysis_result" | grep "^availability_insight:" | cut -d: -f2-)
                
                # Atualiza contadores
                if [[ "$is_running" == "true" ]]; then
                    ((running_containers++))
                    total_performance=$((total_performance + performance_score))
                    
                    if [[ "$health_status" == "HEALTHY" ]]; then
                        ((healthy_containers++))
                    else
                        unhealthy_containers+=("$container")
                    fi
                    
                    if [[ "$performance_score" -lt 70 ]]; then
                        performance_issues+=("$container")
                    fi
                else
                    unhealthy_containers+=("$container")
                fi
                
                # Adiciona insight
                detailed_insights+=("$container: $availability_insight (Score: $performance_score/100)")
                
            else
                safe_log "error" "Invalid JSON generated for container $container"
                unhealthy_containers+=("$container")
                detailed_insights+=("$container: JSON generation failed")
            fi
        else
            safe_log "error" "Failed to analyze container $container"
            unhealthy_containers+=("$container")
            detailed_insights+=("$container: Analysis failed")
        fi
    done
    
    # Calcula métricas finais
    local overall_performance=0
    if [[ $running_containers -gt 0 ]]; then
        overall_performance=$((total_performance / running_containers))
    fi
    
    # Determina status geral
    local overall_status="HEALTHY"
    local summary_insight="All containers operating normally"
    local impact_assessment="No service impact"
    
    if [[ $running_containers -eq 0 ]]; then
        overall_status="CRITICAL"
        summary_insight="All $total_containers containers are offline"
        impact_assessment="Complete service outage"
    elif [[ $running_containers -lt $total_containers ]]; then
        overall_status="CRITICAL"
        summary_insight="$((total_containers - running_containers)) of $total_containers containers offline"
        impact_assessment="Partial service disruption"
    elif [[ $healthy_containers -lt $running_containers ]]; then
        overall_status="WARNING"
        summary_insight="$((running_containers - healthy_containers)) containers unhealthy"
        impact_assessment="Service functional but degraded"
    elif [[ $overall_performance -lt 80 ]]; then
        overall_status="WARNING"
        summary_insight="Performance below optimal levels"
        impact_assessment="Service may experience slowdowns"
    fi
    
    # Prepara listas JSON
    local container_json_list="$(IFS=','; echo "${container_results[*]}")"
    local unhealthy_json_list=""
    if [[ ${#unhealthy_containers[@]} -gt 0 ]]; then
        local unhealthy_quoted=()
        for container in "${unhealthy_containers[@]}"; do
            unhealthy_quoted+=("\"$container\"")
        done
        unhealthy_json_list="[$(IFS=','; echo "${unhealthy_quoted[*]}")]"
    else
        unhealthy_json_list="[]"
    fi
    
    local performance_issues_json_list=""
    if [[ ${#performance_issues[@]} -gt 0 ]]; then
        local performance_quoted=()
        for container in "${performance_issues[@]}"; do
            performance_quoted+=("\"$container\"")
        done
        performance_issues_json_list="[$(IFS=','; echo "${performance_quoted[*]}")]"
    else
        performance_issues_json_list="[]"
    fi
    
    local insights_json_list=""
    if [[ ${#detailed_insights[@]} -gt 0 ]]; then
        local insights_quoted=()
        for insight in "${detailed_insights[@]}"; do
            insights_quoted+=("\"$(ultra_sanitize_string "$insight")\"")
        done
        insights_json_list="[$(IFS=','; echo "${insights_quoted[*]}")]"
    else
        insights_json_list="[]"
    fi
    
    # Gera JSON final
    local final_json
    final_json=$(cat << EOF
{
    "status": "$overall_status",
    "running_count": $running_containers,
    "total_count": $total_containers,
    "healthy_count": $healthy_containers,
    "unhealthy_count": ${#unhealthy_containers[@]},
    "containers": {$container_json_list},
    "unhealthy_containers": $unhealthy_json_list,
    "performance_issues": $performance_issues_json_list,
    "insights": {
        "summary": "$(ultra_sanitize_string "$summary_insight")",
        "impact_assessment": "$(ultra_sanitize_string "$impact_assessment")",
        "overall_performance_score": $overall_performance,
        "container_insights": $insights_json_list,
        "recommendations": [
            $(generate_recommendations_json "$overall_status" "$running_containers" "$total_containers")
        ],
        "health_distribution": {
            "healthy": $healthy_containers,
            "unhealthy": ${#unhealthy_containers[@]},
            "offline": $((total_containers - running_containers))
        }
    },
    "metadata": {
        "timestamp": "$(date -u +"%Y-%m-%dT%H:%M:%SZ")",
        "timeout_seconds": $CHECK_TIMEOUT,
        "containers_checked": $total_containers,
        "diagnostic_version": "2.1.0",
        "validation_passed": true
    }
}
EOF
)
    
    # Validação final
    if echo "$final_json" | jq '.' >/dev/null 2>&1; then
        safe_log "info" "Container diagnostic completed successfully - $running_containers/$total_containers containers running"
        echo "$final_json"
        return 0
    else
        safe_log "error" "Final JSON validation failed"
        # Retorna JSON mínimo mas válido
        cat << EOF
{
    "status": "CRITICAL",
    "error": "JSON validation failed",
    "running_count": $running_containers,
    "total_count": $total_containers,
    "diagnostic_completed": true,
    "timestamp": "$(date -u +"%Y-%m-%dT%H:%M:%SZ")"
}
EOF
        return 1
    fi
}

generate_recommendations_json() {
    local status="$1"
    local running="$2"
    local total="$3"
    
    case "$status" in
        "CRITICAL")
            if [[ $running -eq 0 ]]; then
                echo '{"action": "emergency_restart", "priority": "CRITICAL", "description": "All containers offline - emergency restart needed"}'
            else
                echo '{"action": "restart_failed", "priority": "HIGH", "description": "Restart offline containers immediately"}'
            fi
            ;;
        "WARNING")
            echo '{"action": "investigate_health", "priority": "MEDIUM", "description": "Investigate unhealthy containers"}'
            ;;
        *)
            echo '{"action": "continue_monitoring", "priority": "INFO", "description": "All systems operational"}'
            ;;
    esac
}

#===============================================================================
# EXECUTION
#===============================================================================

# Se executado diretamente
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    run_container_diagnostic
fi