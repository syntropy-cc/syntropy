#!/usr/bin/env bash

#===============================================================================
# SYNTROPY PLATFORM - ADVANCED DIAGNOSTIC SUITE
#===============================================================================
# Comprehensive health, performance, and integrity testing for Next.js + Supabase
# Distributed architecture running via Docker Compose
#
# Author: DevOps Senior QA Specialist
# Version: 2.0.0
# Optimized for LLM analysis and automated troubleshooting
#===============================================================================

set -euo pipefail

#===============================================================================
# GLOBAL CONFIGURATION & CONSTANTS
#===============================================================================

# Script metadata
readonly SCRIPT_VERSION="2.0.0"
readonly SCRIPT_NAME="Syntropy Platform Diagnostic Suite"
readonly EXECUTION_ID="$(date +%Y%m%d_%H%M%S)_$$"
readonly START_TIME=$(date +%s)
readonly ISO_TIMESTAMP=$(date -u +"%Y-%m-%dT%H:%M:%S.%3NZ")

# Environment configuration
readonly ENV_FILE="${1:-.env.production}"
readonly WORKSPACE_DIR="$(pwd)"
readonly LOG_DIR="${WORKSPACE_DIR}/diagnose"
readonly CACHE_DIR="${LOG_DIR}/.cache"
readonly RESULTS_FILE="${LOG_DIR}/diagnostic_results_${EXECUTION_ID}.json"
readonly SUMMARY_FILE="${LOG_DIR}/diagnostic_summary_${EXECUTION_ID}.txt"

# Network and service configuration
readonly API_HOST="${API_HOST:-api.syntropy.cc}"
readonly APP_HOST="${APP_HOST:-syntropy.cc}"
readonly API_PORT=54321
readonly APP_PORT=3000
readonly DB_PORT=5432

# Container names
readonly CONTAINERS=(
    "syntropy-db"
    "syntropy-kong" 
    "syntropy-auth"
    "syntropy-rest"
    "syntropy-realtime"
    "syntropy-storage"
    "syntropy-imgproxy"
    "syntropy-nextjs"
)

# Service endpoints mapping
declare -A SERVICE_ENDPOINTS=(
    ["kong"]="http://127.0.0.1:${API_PORT}"
    ["auth"]="http://127.0.0.1:9999"
    ["rest"]="http://127.0.0.1:3001"
    ["realtime"]="http://127.0.0.1:4000"
    ["storage"]="http://127.0.0.1:5000"
    ["nextjs"]="http://127.0.0.1:${APP_PORT}"
)

# Color codes for output formatting
readonly RED='\033[0;31m'
readonly GREEN='\033[0;32m'
readonly YELLOW='\033[1;33m'
readonly BLUE='\033[0;34m'
readonly PURPLE='\033[0;35m'
readonly CYAN='\033[0;36m'
readonly WHITE='\033[1;37m'
readonly GRAY='\033[0;90m'
readonly BOLD='\033[1m'
readonly NC='\033[0m' # No Color

# Status indicators
readonly STATUS_SUCCESS="✅"
readonly STATUS_WARNING="⚠️"
readonly STATUS_ERROR="❌"
readonly STATUS_INFO="ℹ️"
readonly STATUS_RUNNING="🔄"
readonly STATUS_CRITICAL="🚨"

#===============================================================================
# UTILITY FUNCTIONS
#===============================================================================

# Initialize diagnostic environment
init_diagnostic_environment() {
    echo -e "${BLUE}${BOLD}╔══════════════════════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${BLUE}${BOLD}║                    SYNTROPY PLATFORM DIAGNOSTIC SUITE                       ║${NC}"
    echo -e "${BLUE}${BOLD}║                           Version ${SCRIPT_VERSION}                                    ║${NC}"
    echo -e "${BLUE}${BOLD}╚══════════════════════════════════════════════════════════════════════════════╝${NC}"
    echo
    
    # Create necessary directories
    mkdir -p "${LOG_DIR}" "${CACHE_DIR}"
    
    # Initialize results file
    cat > "${RESULTS_FILE}" << EOF
{
    "execution_id": "${EXECUTION_ID}",
    "timestamp": "${ISO_TIMESTAMP}",
    "version": "${SCRIPT_VERSION}",
    "environment": {
        "workspace": "${WORKSPACE_DIR}",
        "env_file": "${ENV_FILE}",
        "api_host": "${API_HOST}",
        "app_host": "${APP_HOST}"
    },
    "system_info": {
        "os": "$(uname -s)",
        "kernel": "$(uname -r)",
        "architecture": "$(uname -m)",
        "hostname": "$(hostname)",
        "user": "$(whoami)",
        "shell": "${SHELL}",
        "docker_version": "$(docker --version 2>/dev/null || echo 'Not available')",
        "docker_compose_version": "$(docker compose version 2>/dev/null || echo 'Not available')"
    },
    "tests": {},
    "summary": {
        "total_tests": 0,
        "passed": 0,
        "warnings": 0,
        "failed": 0,
        "critical": 0,
        "execution_time": 0
    }
}
EOF

    log_info "Diagnostic environment initialized"
    log_info "Execution ID: ${EXECUTION_ID}"
    log_info "Results will be saved to: ${RESULTS_FILE}"
}

# Enhanced logging functions with structured output
log_message() {
    local level="$1"
    local message="$2"
    local timestamp=$(date -u +"%Y-%m-%dT%H:%M:%S.%3NZ")
    local color=""
    local icon=""
    
    case "$level" in
        "SUCCESS") color="${GREEN}"; icon="${STATUS_SUCCESS}" ;;
        "WARNING") color="${YELLOW}"; icon="${STATUS_WARNING}" ;;
        "ERROR") color="${RED}"; icon="${STATUS_ERROR}" ;;
        "CRITICAL") color="${RED}${BOLD}"; icon="${STATUS_CRITICAL}" ;;
        "INFO") color="${BLUE}"; icon="${STATUS_INFO}" ;;
        "RUNNING") color="${CYAN}"; icon="${STATUS_RUNNING}" ;;
        *) color="${NC}"; icon="" ;;
    esac
    
    echo -e "${color}[${timestamp}] ${icon} ${level}: ${message}${NC}"
    
    # Also log to file without colors
    echo "[${timestamp}] ${level}: ${message}" >> "${LOG_DIR}/diagnostic.log"
}

log_success() { log_message "SUCCESS" "$1"; }
log_warning() { log_message "WARNING" "$1"; }
log_error() { log_message "ERROR" "$1"; }
log_critical() { log_message "CRITICAL" "$1"; }
log_info() { log_message "INFO" "$1"; }
log_running() { log_message "RUNNING" "$1"; }

# Section headers for better organization
print_section_header() {
    local title="$1"
    local width=80
    local padding=$(( (width - ${#title} - 2) / 2 ))
    
    echo
    echo -e "${PURPLE}${BOLD}╔$(printf '═%.0s' $(seq 1 $((width-2))))╗${NC}"
    echo -e "${PURPLE}${BOLD}║$(printf ' %.0s' $(seq 1 $padding))${title}$(printf ' %.0s' $(seq 1 $padding))║${NC}"
    echo -e "${PURPLE}${BOLD}╚$(printf '═%.0s' $(seq 1 $((width-2))))╝${NC}"
    echo
}

# Load and validate environment variables
load_environment() {
    log_running "Loading environment configuration from ${ENV_FILE}"
    
    if [[ ! -f "$ENV_FILE" ]]; then
        log_critical "Environment file not found: $ENV_FILE"
        return 1
    fi
    
    # Source environment file safely
    set -a
    source <(grep -E '^[A-Z_][A-Z0-9_]*=' "$ENV_FILE" | grep -v '^#')
    set +a
    
    # Validate critical environment variables
    local required_vars=(
        "POSTGRES_PASSWORD"
        "JWT_SECRET"
        "ANON_KEY"
        "SERVICE_ROLE_KEY"
    )
    
    local missing_vars=()
    for var in "${required_vars[@]}"; do
        if [[ -z "${!var:-}" ]]; then
            missing_vars+=("$var")
        fi
    done
    
    if [[ ${#missing_vars[@]} -gt 0 ]]; then
        log_critical "Missing required environment variables: ${missing_vars[*]}"
        return 1
    fi
    
    log_success "Environment configuration loaded successfully"
    return 0
}

# Enhanced retry mechanism with exponential backoff
retry_with_backoff() {
    local max_attempts="$1"
    local base_delay="$2"
    local max_delay="$3"
    local command="$4"
    local description="${5:-command}"
    
    local attempt=1
    local delay="$base_delay"
    
    while [[ $attempt -le $max_attempts ]]; do
        log_running "Attempting ${description} (${attempt}/${max_attempts})"
        
        if eval "$command"; then
            log_success "${description} succeeded on attempt ${attempt}"
            return 0
        fi
        
        if [[ $attempt -eq $max_attempts ]]; then
            log_error "${description} failed after ${max_attempts} attempts"
            return 1
        fi
        
        log_warning "${description} failed, retrying in ${delay}s..."
        sleep "$delay"
        
        # Exponential backoff with jitter
        delay=$(( delay * 2 ))
        if [[ $delay -gt $max_delay ]]; then
            delay=$max_delay
        fi
        
        # Add jitter (±25%)
        local jitter=$(( delay / 4 ))
        delay=$(( delay + (RANDOM % (jitter * 2)) - jitter ))
        
        ((attempt++))
    done
}

# JSON result recording
record_test_result() {
    local category="$1"
    local test_name="$2"
    local status="$3"
    local message="$4"
    local details="${5:-{}}"
    local duration="${6:-0}"
    
    # Create test result object
    local test_result=$(cat << EOF
{
    "category": "${category}",
    "name": "${test_name}",
    "status": "${status}",
    "message": "${message}",
    "timestamp": "$(date -u +"%Y-%m-%dT%H:%M:%S.%3NZ")",
    "duration_ms": ${duration},
    "details": ${details}
}
EOF
)
    
    # Update results file using jq if available, otherwise use basic approach
    if command -v jq >/dev/null 2>&1; then
        local temp_file=$(mktemp)
        jq --argjson test "$test_result" '.tests["'${category}'_'${test_name}'"] = $test' "$RESULTS_FILE" > "$temp_file"
        mv "$temp_file" "$RESULTS_FILE"
    else
        # Fallback for systems without jq
        echo "Test recorded: ${category}/${test_name} - ${status}" >> "${LOG_DIR}/test_results.log"
    fi
}

#===============================================================================
# INFRASTRUCTURE TESTS
#===============================================================================

test_docker_environment() {
    print_section_header "DOCKER ENVIRONMENT VERIFICATION"
    
    local start_time=$(date +%s%3N)
    
    # Test Docker daemon
    if ! docker info >/dev/null 2>&1; then
        log_critical "Docker daemon is not running or accessible"
        record_test_result "infrastructure" "docker_daemon" "CRITICAL" "Docker daemon not accessible" "{}" $(($(date +%s%3N) - start_time))
        return 1
    fi
    
    log_success "Docker daemon is running"
    
    # Test Docker Compose
    if ! docker compose version >/dev/null 2>&1; then
        log_error "Docker Compose is not available"
        record_test_result "infrastructure" "docker_compose" "ERROR" "Docker Compose not available" "{}" $(($(date +%s%3N) - start_time))
        return 1
    fi
    
    log_success "Docker Compose is available"
    
    # Get Docker system information
    local docker_version=$(docker --version)
    local compose_version=$(docker compose version)
    
    log_info "Docker Version: ${docker_version}"
    log_info "Compose Version: ${compose_version}"
    
    record_test_result "infrastructure" "docker_environment" "SUCCESS" "Docker environment verified" \
        "{\"docker_version\":\"${docker_version}\",\"compose_version\":\"${compose_version}\"}" \
        $(($(date +%s%3N) - start_time))
    
    return 0
}

test_container_status() {
    print_section_header "CONTAINER STATUS & HEALTH CHECKS"
    
    local start_time=$(date +%s%3N)
    local failed_containers=()
    local container_details=()
    
    for container in "${CONTAINERS[@]}"; do
        log_running "Checking container: ${container}"
        
        # Check if container exists and is running
        if ! docker ps --filter "name=${container}" --format "{{.Names}}" | grep -q "^${container}$"; then
            log_error "Container ${container} is not running"
            failed_containers+=("${container}")
            container_details+=("{\"name\":\"${container}\",\"status\":\"not_running\"}")
            continue
        fi
        
        # Get container status details
        local status=$(docker inspect "${container}" --format '{{.State.Status}}' 2>/dev/null || echo "unknown")
        local health=$(docker inspect "${container}" --format '{{.State.Health.Status}}' 2>/dev/null || echo "none")
        local uptime=$(docker inspect "${container}" --format '{{.State.StartedAt}}' 2>/dev/null || echo "unknown")
        local restart_count=$(docker inspect "${container}" --format '{{.RestartCount}}' 2>/dev/null || echo "0")
        
        if [[ "$status" == "running" ]]; then
            if [[ "$health" == "healthy" || "$health" == "none" ]]; then
                log_success "Container ${container}: ${status} (health: ${health})"
            else
                log_warning "Container ${container}: ${status} but health check failed (${health})"
            fi
        else
            log_error "Container ${container}: ${status}"
            failed_containers+=("${container}")
        fi
        
        # Store container details
        container_details+=("{\"name\":\"${container}\",\"status\":\"${status}\",\"health\":\"${health}\",\"uptime\":\"${uptime}\",\"restart_count\":${restart_count}}")
    done
    
    # Record results
    local details="{\"containers\":[$(IFS=,; echo "${container_details[*]}")]}"
    
    if [[ ${#failed_containers[@]} -eq 0 ]]; then
        log_success "All containers are running properly"
        record_test_result "infrastructure" "container_status" "SUCCESS" "All containers healthy" "$details" $(($(date +%s%3N) - start_time))
        return 0
    else
        log_error "Failed containers: ${failed_containers[*]}"
        record_test_result "infrastructure" "container_status" "ERROR" "Some containers failed: ${failed_containers[*]}" "$details" $(($(date +%s%3N) - start_time))
        return 1
    fi
}

#===============================================================================
# DATABASE TESTS
#===============================================================================

test_database_connectivity() {
    print_section_header "DATABASE CONNECTIVITY & BASIC HEALTH"
    
    local start_time=$(date +%s%3N)
    local db_container="syntropy-db"
    
    # Test PostgreSQL connectivity
    log_running "Testing PostgreSQL database connectivity"
    
    if ! docker exec -i "${db_container}" pg_isready -U postgres >/dev/null 2>&1; then
        log_critical "PostgreSQL database is not ready"
        record_test_result "database" "connectivity" "CRITICAL" "PostgreSQL not ready" "{}" $(($(date +%s%3N) - start_time))
        return 1
    fi
    
    log_success "PostgreSQL database is ready and accepting connections"
    
    # Test database version and configuration
    local db_version=$(docker exec -i "${db_container}" psql -U postgres -d postgres -qtAX -c "SELECT version();" 2>/dev/null | head -1)
    local db_size=$(docker exec -i "${db_container}" psql -U postgres -d postgres -qtAX -c "SELECT pg_size_pretty(pg_database_size('postgres'));" 2>/dev/null)
    local connection_count=$(docker exec -i "${db_container}" psql -U postgres -d postgres -qtAX -c "SELECT count(*) FROM pg_stat_activity;" 2>/dev/null)
    
    log_info "Database version: ${db_version}"
    log_info "Database size: ${db_size}"
    log_info "Active connections: ${connection_count}"
    
    record_test_result "database" "connectivity" "SUCCESS" "Database connectivity verified" \
        "{\"version\":\"${db_version}\",\"size\":\"${db_size}\",\"connections\":${connection_count}}" \
        $(($(date +%s%3N) - start_time))
    
    return 0
}

test_database_schema() {
    print_section_header "DATABASE SCHEMA & ROLES VERIFICATION"
    
    local start_time=$(date +%s%3N)
    local db_container="syntropy-db"
    local psql_cmd="docker exec -i ${db_container} psql -U postgres -d postgres -qtAX -c"
    
    # Test required roles
    log_running "Verifying database roles"
    
    local required_roles=("supabase_admin" "authenticator" "service_role")
    local missing_roles=()
    local role_details=()
    
    for role in "${required_roles[@]}"; do
        if $psql_cmd "SELECT 1 FROM pg_roles WHERE rolname = '${role}';" | grep -q "1"; then
            log_success "Role '${role}' exists"
            role_details+=("{\"name\":\"${role}\",\"exists\":true}")
        else
            log_error "Role '${role}' is missing"
            missing_roles+=("${role}")
            role_details+=("{\"name\":\"${role}\",\"exists\":false}")
        fi
    done
    
    # Test auth.users table specifically
    log_running "Verifying auth.users table"
    
    local users_count=$($psql_cmd "SELECT count(*) FROM auth.users;" 2>/dev/null || echo "ERROR")
    if [[ "$users_count" != "ERROR" ]]; then
        log_success "auth.users table accessible (${users_count} users)"
    else
        log_error "auth.users table not accessible"
        missing_roles+=("auth.users")
    fi
    
    # Record results
    local details="{\"roles\":[$(IFS=,; echo "${role_details[*]}")],\"users_count\":\"${users_count}\"}"
    
    if [[ ${#missing_roles[@]} -eq 0 ]]; then
        log_success "Database schema and roles verification completed"
        record_test_result "database" "schema" "SUCCESS" "All required roles and schemas present" "$details" $(($(date +%s%3N) - start_time))
        return 0
    else
        log_error "Missing database components: ${missing_roles[*]}"
        record_test_result "database" "schema" "ERROR" "Missing components: ${missing_roles[*]}" "$details" $(($(date +%s%3N) - start_time))
        return 1
    fi
}

#===============================================================================
# NETWORK CONNECTIVITY TESTS
#===============================================================================

test_service_endpoints() {
    print_section_header "SERVICE ENDPOINT CONNECTIVITY"
    
    local start_time=$(date +%s%3N)
    local failed_endpoints=()
    local endpoint_details=()
    
    for service in "${!SERVICE_ENDPOINTS[@]}"; do
        local endpoint="${SERVICE_ENDPOINTS[$service]}"
        
        log_running "Testing service endpoint: ${service} (${endpoint})"
        
        # Test HTTP connectivity with timeout
        local response_time_start=$(date +%s%3N)
        local http_code=$(curl -s -o /dev/null -w "%{http_code}" --connect-timeout 10 --max-time 30 "${endpoint}/health" 2>/dev/null || echo "000")
        local response_time=$(($(date +%s%3N) - response_time_start))
        
        if [[ "$http_code" =~ ^[2-3][0-9][0-9]$ ]]; then
            log_success "Service ${service} endpoint responding (HTTP ${http_code}, ${response_time}ms)"
            endpoint_details+=("{\"service\":\"${service}\",\"endpoint\":\"${endpoint}\",\"http_code\":${http_code},\"response_time\":${response_time},\"status\":\"success\"}")
        else
            # Try alternative health check endpoints
            local alt_endpoints=("/" "/status" "/ping")
            local success=false
            
            for alt_endpoint in "${alt_endpoints[@]}"; do
                http_code=$(curl -s -o /dev/null -w "%{http_code}" --connect-timeout 5 --max-time 15 "${endpoint}${alt_endpoint}" 2>/dev/null || echo "000")
                if [[ "$http_code" =~ ^[2-3][0-9][0-9]$ ]]; then
                    log_success "Service ${service} responding on alternative endpoint (HTTP ${http_code})"
                    endpoint_details+=("{\"service\":\"${service}\",\"endpoint\":\"${endpoint}${alt_endpoint}\",\"http_code\":${http_code},\"response_time\":${response_time},\"status\":\"success\"}")
                    success=true
                    break
                fi
            done
            
            if [[ "$success" == false ]]; then
                log_error "Service ${service} endpoint not responding (HTTP ${http_code})"
                failed_endpoints+=("${service}")
                endpoint_details+=("{\"service\":\"${service}\",\"endpoint\":\"${endpoint}\",\"http_code\":${http_code},\"response_time\":${response_time},\"status\":\"failed\"}")
            fi
        fi
    done
    
    # Record results
    local details="{\"endpoints\":[$(IFS=,; echo "${endpoint_details[*]}")]}"
    
    if [[ ${#failed_endpoints[@]} -eq 0 ]]; then
        log_success "All service endpoints are responding"
        record_test_result "connectivity" "service_endpoints" "SUCCESS" "All service endpoints responding" "$details" $(($(date +%s%3N) - start_time))
        return 0
    else
        log_error "Failed service endpoints: ${failed_endpoints[*]}"
        record_test_result "connectivity" "service_endpoints" "ERROR" "Some service endpoints failed: ${failed_endpoints[*]}" "$details" $(($(date +%s%3N) - start_time))
        return 1
    fi
}

#===============================================================================
# AUTHENTICATION TESTS
#===============================================================================

test_authentication_service() {
    print_section_header "AUTHENTICATION SERVICE VERIFICATION"
    
    local start_time=$(date +%s%3N)
    local auth_endpoint="http://127.0.0.1:${API_PORT}/auth/v1"
    
    # Test GoTrue health via Kong
    log_running "Testing GoTrue authentication service via Kong"
    
    local health_response=$(curl -s -w "%{http_code}" \
        -H "Host: ${API_HOST}" \
        --connect-timeout 10 --max-time 30 \
        "${auth_endpoint}/settings" 2>/dev/null || echo "000")
    local http_code="${health_response: -3}"
    
    if [[ "$http_code" == "200" ]]; then
        log_success "GoTrue authentication service is accessible via Kong"
    else
        log_error "GoTrue authentication service not accessible via Kong (HTTP ${http_code})"
        record_test_result "authentication" "service_health" "ERROR" "GoTrue not accessible via Kong" "{\"http_code\":${http_code}}" $(($(date +%s%3N) - start_time))
        return 1
    fi
    
    # Test admin users endpoint if SERVICE_ROLE_KEY is available
    if [[ -n "${SERVICE_ROLE_KEY:-}" ]]; then
        log_running "Testing admin users API endpoint"
        
        local admin_endpoint="${auth_endpoint}/admin/users"
        local admin_response=$(curl -s -w "%{http_code}" \
            -H "Host: ${API_HOST}" \
            -H "apikey: ${SERVICE_ROLE_KEY}" \
            -H "Authorization: Bearer ${SERVICE_ROLE_KEY}" \
            -H "Content-Type: application/json" \
            --connect-timeout 10 --max-time 30 \
            "${admin_endpoint}?limit=1" 2>/dev/null || echo "000")
        
        local admin_http_code="${admin_response: -3}"
        
        if [[ "$admin_http_code" == "200" ]]; then
            log_success "Admin users API is accessible"
        else
            log_warning "Admin users API not accessible (HTTP ${admin_http_code})"
        fi
    else
        log_info "SERVICE_ROLE_KEY not available, skipping admin API test"
    fi
    
    record_test_result "authentication" "service_health" "SUCCESS" "Authentication service verified" \
        "{\"settings_code\":${http_code}}" \
        $(($(date +%s%3N) - start_time))
    
    return 0
}

#===============================================================================
# API TESTS
#===============================================================================

test_kong_gateway() {
    print_section_header "KONG GATEWAY ROUTING VERIFICATION"
    
    local start_time=$(date +%s%3N)
    local kong_endpoint="http://127.0.0.1:${API_PORT}"
    
    # Test Kong gateway routing
    log_running "Testing Kong gateway routing"
    
    local kong_routes=(
        "/auth/v1/settings"
        "/rest/v1/"
        "/storage/v1/buckets"
    )
    
    local routing_results=()
    local failed_routes=()
    
    for route in "${kong_routes[@]}"; do
        log_running "Testing Kong route: ${route}"
        
        local route_response=$(curl -s -w "%{http_code}" \
            -H "Host: ${API_HOST}" \
            --connect-timeout 10 --max-time 30 \
            "${kong_endpoint}${route}" 2>/dev/null || echo "000")
        
        local route_http_code="${route_response: -3}"
        
        # Routes should return appropriate HTTP codes (not 502/503/504)
        if [[ "$route_http_code" =~ ^[2-4][0-9][0-9]$ ]]; then
            log_success "Kong route ${route} responding (HTTP ${route_http_code})"
            routing_results+=("{\"route\":\"${route}\",\"http_code\":${route_http_code},\"status\":\"success\"}")
        else
            log_error "Kong route ${route} not responding properly (HTTP ${route_http_code})"
            failed_routes+=("${route}")
            routing_results+=("{\"route\":\"${route}\",\"http_code\":${route_http_code},\"status\":\"failed\"}")
        fi
    done
    
    # Record results
    local details="{\"routes\":[$(IFS=,; echo "${routing_results[*]}")]}"
    
    if [[ ${#failed_routes[@]} -eq 0 ]]; then
        log_success "Kong gateway routing verification completed"
        record_test_result "api" "kong_gateway" "SUCCESS" "Kong gateway routing verified" "$details" $(($(date +%s%3N) - start_time))
        return 0
    else
        log_error "Failed Kong routes: ${failed_routes[*]}"
        record_test_result "api" "kong_gateway" "ERROR" "Some Kong routes failed: ${failed_routes[*]}" "$details" $(($(date +%s%3N) - start_time))
        return 1
    fi
}

test_postgrest_api() {
    print_section_header "POSTGREST API FUNCTIONALITY"
    
    local start_time=$(date +%s%3N)
    local rest_endpoint="http://127.0.0.1:${API_PORT}/rest/v1"
    
    # Test PostgREST root endpoint
    log_running "Testing PostgREST root endpoint"
    
    local root_response=$(curl -s -w "%{http_code}" \
        -H "Host: ${API_HOST}" \
        -H "apikey: ${ANON_KEY}" \
        --connect-timeout 10 --max-time 30 \
        "${rest_endpoint}/" 2>/dev/null || echo "000")
    
    local root_http_code="${root_response: -3}"
    
    if [[ "$root_http_code" == "200" ]]; then
        log_success "PostgREST root endpoint responding"
    else
        log_error "PostgREST root endpoint not responding (HTTP ${root_http_code})"
        record_test_result "api" "postgrest" "ERROR" "PostgREST root endpoint failed" "{\"http_code\":${root_http_code}}" $(($(date +%s%3N) - start_time))
        return 1
    fi
    
    record_test_result "api" "postgrest" "SUCCESS" "PostgREST API verified" \
        "{\"root_code\":${root_http_code}}" \
        $(($(date +%s%3N) - start_time))
    
    return 0
}

#===============================================================================
# PERFORMANCE BENCHMARKING
#===============================================================================

test_response_times() {
    print_section_header "RESPONSE TIME BENCHMARKING"
    
    local start_time=$(date +%s%3N)
    local performance_results=()
    
    # Define endpoints to benchmark
    local benchmark_endpoints=(
        "kong:http://127.0.0.1:${API_PORT}/auth/v1/settings"
        "rest:http://127.0.0.1:${API_PORT}/rest/v1/"
        "nextjs:http://127.0.0.1:${APP_PORT}/robots.txt"
    )
    
    for endpoint_def in "${benchmark_endpoints[@]}"; do
        IFS=':' read -r service_name endpoint_url <<< "$endpoint_def"
        
        log_running "Benchmarking ${service_name} response time"
        
        # Perform multiple requests to get average
        local total_time=0
        local successful_requests=0
        local failed_requests=0
        local min_time=999999
        local max_time=0
        
        for i in {1..5}; do
            local request_start=$(date +%s%3N)
            
            local headers=()
            if [[ "$service_name" != "nextjs" ]]; then
                headers+=("-H" "Host: ${API_HOST}")
                if [[ "$service_name" == "rest" ]]; then
                    headers+=("-H" "apikey: ${ANON_KEY}")
                fi
            fi
            
            if curl -s -o /dev/null --connect-timeout 5 --max-time 15 "${headers
