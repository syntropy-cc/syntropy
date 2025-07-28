#!/usr/bin/env bash

#===============================================================================
# SYNTROPY PLATFORM - ENHANCED DIAGNOSTIC SUITE
#===============================================================================
# Comprehensive health, performance, and integrity testing for Next.js + Supabase
# Distributed architecture with remote SSH execution capability
#
# Author: DevOps Senior QA Specialist
# Version: 3.0.0
# Enhanced with SSH remote execution, dynamic directories, and interactive input
#===============================================================================

set -euo pipefail

#===============================================================================
# GLOBAL CONFIGURATION & CONSTANTS
#===============================================================================

# Script metadata
readonly SCRIPT_VERSION="3.0.0"
readonly SCRIPT_NAME="Syntropy Platform Enhanced Diagnostic Suite"
readonly EXECUTION_TIMESTAMP="$(date +%Y%m%d_%H%M%S)"
readonly EXECUTION_ID="${EXECUTION_TIMESTAMP}_$$"
readonly START_TIME=$(date +%s)
readonly ISO_TIMESTAMP=$(date -u +"%Y-%m-%dT%H:%M:%S.%3NZ")

# Dynamic directory structure
readonly WORKSPACE_DIR="$(pwd)"
readonly LOG_BASE_DIR="${WORKSPACE_DIR}/diagnose"
readonly LOG_DIR="${LOG_BASE_DIR}/${EXECUTION_TIMESTAMP}"
readonly CACHE_DIR="${LOG_DIR}/.cache"
readonly RESULTS_FILE="${LOG_DIR}/diagnostic_results_${EXECUTION_ID}.json"
readonly SUMMARY_FILE="${LOG_DIR}/diagnostic_summary_${EXECUTION_ID}.txt"
readonly DETAILED_LOG="${LOG_DIR}/diagnostic_detailed.log"

# Remote execution configuration
REMOTE_EXECUTION=false
REMOTE_HOST=""
REMOTE_USER=""
REMOTE_PASSWORD=""
REMOTE_KEY_FILE=""
REMOTE_DIRECTORY=""
SSH_CONNECTION_STRING=""

# Interactive configuration variables
ENV_FILE=""
POSTGRES_PASSWORD=""
JWT_SECRET=""
ANON_KEY=""
SERVICE_ROLE_KEY=""
API_HOST=""
APP_HOST=""

# Network and service configuration
readonly DEFAULT_API_HOST="api.syntropy.cc"
readonly DEFAULT_APP_HOST="syntropy.cc"
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

# Required tools for validation
readonly REQUIRED_TOOLS=(
    "curl"
    "docker"
    "openssl"
    "grep"
    "awk"
    "sed"
    "jq"
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
readonly STATUS_SKIPPED="⏭️"

#===============================================================================
# UTILITY FUNCTIONS
#===============================================================================

# Enhanced logging functions with detailed output
log_message() {
    local level="$1"
    local message="$2"
    local error_code="${3:-}"
    local context="${4:-}"
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
        "SKIPPED") color="${GRAY}"; icon="${STATUS_SKIPPED}" ;;
        *) color="${NC}"; icon="" ;;
    esac
    
    # Format message with error code and context
    local formatted_message="$message"
    if [[ -n "$error_code" ]]; then
        formatted_message="${formatted_message} [Error: ${error_code}]"
    fi
    if [[ -n "$context" ]]; then
        formatted_message="${formatted_message} (Context: ${context})"
    fi
    
    echo -e "${color}[${timestamp}] ${icon} ${level}: ${formatted_message}${NC}"
    
    # Also log to detailed file without colors
    if [[ -f "$DETAILED_LOG" ]]; then
        echo "[${timestamp}] ${level}: ${formatted_message}" >> "${DETAILED_LOG}"
    fi
}

log_success() { log_message "SUCCESS" "$1" "${2:-}" "${3:-}"; }
log_warning() { log_message "WARNING" "$1" "${2:-}" "${3:-}"; }
log_error() { log_message "ERROR" "$1" "${2:-}" "${3:-}"; }
log_critical() { log_message "CRITICAL" "$1" "${2:-}" "${3:-}"; }
log_info() { log_message "INFO" "$1" "${2:-}" "${3:-}"; }
log_running() { log_message "RUNNING" "$1" "${2:-}" "${3:-}"; }
log_skipped() { log_message "SKIPPED" "$1" "${2:-}" "${3:-}"; }

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

# Secure input function for sensitive data
secure_read() {
    local prompt="$1"
    local var_name="$2"
    local is_password="${3:-false}"
    
    if [[ "$is_password" == "true" ]]; then
        echo -n "$prompt: "
        read -s value
        echo
    else
        echo -n "$prompt: "
        read value
    fi
    
    if [[ -z "$value" ]]; then
        log_error "Empty value provided for $var_name"
        return 1
    fi
    
    eval "$var_name='$value'"
    return 0
}

# Pre-execution validation checks
validate_prerequisites() {
    print_section_header "PRE-EXECUTION VALIDATION"
    
    local validation_errors=()
    
    # Check required tools
    log_running "Validating required tools and dependencies"
    
    for tool in "${REQUIRED_TOOLS[@]}"; do
        if ! command -v "$tool" >/dev/null 2>&1; then
            validation_errors+=("Missing required tool: $tool")
            log_error "Required tool not found: $tool" "TOOL_MISSING" "Prerequisites validation"
        else
            log_success "Tool available: $tool"
        fi
    done
    
    # Check permissions
    log_running "Validating file system permissions"
    
    if [[ ! -w "$WORKSPACE_DIR" ]]; then
        validation_errors+=("No write permission in workspace directory: $WORKSPACE_DIR")
        log_error "No write permission in workspace directory" "PERMISSION_DENIED" "$WORKSPACE_DIR"
    else
        log_success "Workspace directory is writable"
    fi
    
    # Check Docker daemon if not remote execution
    if [[ "$REMOTE_EXECUTION" == "false" ]]; then
        log_running "Validating Docker daemon accessibility"
        
        if ! docker info >/dev/null 2>&1; then
            validation_errors+=("Docker daemon not accessible")
            log_error "Docker daemon not accessible" "DOCKER_UNAVAILABLE" "Local execution"
        else
            log_success "Docker daemon is accessible"
        fi
    fi
    
    # Check SSH connectivity for remote execution
    if [[ "$REMOTE_EXECUTION" == "true" ]]; then
        log_running "Validating SSH connectivity to remote server"
        
        if ! test_ssh_connection; then
            validation_errors+=("SSH connection to remote server failed")
            log_error "SSH connection failed" "SSH_CONNECTION_FAILED" "$SSH_CONNECTION_STRING"
        else
            log_success "SSH connection to remote server verified"
        fi
    fi
    
    # Report validation results
    if [[ ${#validation_errors[@]} -gt 0 ]]; then
        log_critical "Pre-execution validation failed with ${#validation_errors[@]} errors:"
        for error in "${validation_errors[@]}"; do
            log_error "  - $error"
        done
        return 1
    else
        log_success "All pre-execution validations passed"
        return 0
    fi
}

# Test SSH connection
test_ssh_connection() {
    local ssh_cmd=""
    
    if [[ -n "$REMOTE_KEY_FILE" ]]; then
        ssh_cmd="ssh -i '$REMOTE_KEY_FILE' -o ConnectTimeout=10 -o BatchMode=yes '$REMOTE_USER@$REMOTE_HOST' 'echo SSH_TEST_SUCCESS'"
    else
        ssh_cmd="sshpass -p '$REMOTE_PASSWORD' ssh -o ConnectTimeout=10 -o StrictHostKeyChecking=no '$REMOTE_USER@$REMOTE_HOST' 'echo SSH_TEST_SUCCESS'"
    fi
    
    local result
    result=$(eval "$ssh_cmd" 2>/dev/null)
    
    if [[ "$result" == "SSH_TEST_SUCCESS" ]]; then
        return 0
    else
        return 1
    fi
}

# Interactive configuration setup
interactive_setup() {
    print_section_header "INTERACTIVE CONFIGURATION SETUP"
    
    echo -e "${CYAN}Welcome to the Syntropy Platform Enhanced Diagnostic Suite${NC}"
    echo -e "${CYAN}This tool will guide you through the configuration process.${NC}"
    echo
    
    # Execution mode selection
    echo -e "${YELLOW}Select execution mode:${NC}"
    echo "1) Local execution (current machine)"
    echo "2) Remote execution via SSH"
    echo -n "Choose option [1-2]: "
    read execution_choice
    
    case "$execution_choice" in
        "1")
            REMOTE_EXECUTION=false
            log_info "Selected local execution mode"
            ;;
        "2")
            REMOTE_EXECUTION=true
            log_info "Selected remote execution mode"
            setup_remote_connection
            ;;
        *)
            log_error "Invalid choice. Defaulting to local execution."
            REMOTE_EXECUTION=false
            ;;
    esac
    
    # Environment file configuration
    echo
    echo -e "${YELLOW}Environment Configuration:${NC}"
    
    if [[ "$REMOTE_EXECUTION" == "false" ]]; then
        echo "Available .env files in current directory:"
        find . -maxdepth 1 -name "*.env*" -type f 2>/dev/null | sed 's|^\./||' || echo "No .env files found"
        echo
    fi
    
    secure_read "Enter environment file path (e.g., .env.production)" "ENV_FILE"
    
    # Database credentials
    echo
    echo -e "${YELLOW}Database Configuration:${NC}"
    secure_read "PostgreSQL password" "POSTGRES_PASSWORD" "true"
    
    # JWT and API keys
    echo
    echo -e "${YELLOW}Authentication Configuration:${NC}"
    secure_read "JWT Secret" "JWT_SECRET" "true"
    secure_read "Anonymous Key (ANON_KEY)" "ANON_KEY" "true"
    secure_read "Service Role Key" "SERVICE_ROLE_KEY" "true"
    
    # Host configuration
    echo
    echo -e "${YELLOW}Host Configuration:${NC}"
    echo -n "API Host (default: $DEFAULT_API_HOST): "
    read api_host_input
    API_HOST="${api_host_input:-$DEFAULT_API_HOST}"
    
    echo -n "App Host (default: $DEFAULT_APP_HOST): "
    read app_host_input
    APP_HOST="${app_host_input:-$DEFAULT_APP_HOST}"
    
    log_success "Interactive configuration completed"
}

# Setup remote SSH connection
setup_remote_connection() {
    echo
    echo -e "${YELLOW}Remote SSH Configuration:${NC}"
    
    secure_read "Remote hostname/IP (e.g., syntropy-server)" "REMOTE_HOST"
    secure_read "Remote username (default: syntropy)" "REMOTE_USER"
    
    if [[ -z "$REMOTE_USER" ]]; then
        REMOTE_USER="syntropy"
    fi
    
    echo
    echo "Authentication method:"
    echo "1) SSH key file"
    echo "2) Password"
    echo -n "Choose option [1-2]: "
    read auth_choice
    
    case "$auth_choice" in
        "1")
            secure_read "SSH private key file path" "REMOTE_KEY_FILE"
            if [[ ! -f "$REMOTE_KEY_FILE" ]]; then
                log_error "SSH key file not found: $REMOTE_KEY_FILE"
                exit 1
            fi
            SSH_CONNECTION_STRING="$REMOTE_USER@$REMOTE_HOST (key: $REMOTE_KEY_FILE)"
            ;;
        "2")
            secure_read "SSH password" "REMOTE_PASSWORD" "true"
            SSH_CONNECTION_STRING="$REMOTE_USER@$REMOTE_HOST (password auth)"
            
            # Check if sshpass is available
            if ! command -v sshpass >/dev/null 2>&1; then
                log_error "sshpass is required for password authentication but not found"
                exit 1
            fi
            ;;
        *)
            log_error "Invalid authentication method selected"
            exit 1
            ;;
    esac
    
    # Remote directory configuration
    echo
    secure_read "Remote directory path (default: ~/apps/syntropy/)" "REMOTE_DIRECTORY"
    if [[ -z "$REMOTE_DIRECTORY" ]]; then
        REMOTE_DIRECTORY="~/apps/syntropy/"
    fi
    
    log_info "Remote SSH configuration completed"
}

# Execute command (local or remote)
execute_command() {
    local command="$1"
    local description="${2:-command}"
    local timeout_duration="${3:-30}"
    
    if [[ "$REMOTE_EXECUTION" == "true" ]]; then
        execute_remote_command "$command" "$description" "$timeout_duration"
    else
        execute_local_command "$command" "$description" "$timeout_duration"
    fi
}

# Execute local command with timeout and error handling
execute_local_command() {
    local command="$1"
    local description="${2:-command}"
    local timeout_duration="${3:-30}"
    
    log_running "Executing locally: $description"
    
    local output
    local exit_code
    
    if output=$(timeout "$timeout_duration" bash -c "$command" 2>&1); then
        exit_code=0
        log_success "Local execution successful: $description"
    else
        exit_code=$?
        if [[ $exit_code -eq 124 ]]; then
            log_error "Local execution timed out: $description" "TIMEOUT" "${timeout_duration}s"
        else
            log_error "Local execution failed: $description" "EXIT_CODE_$exit_code" "$output"
        fi
    fi
    
    echo "$output"
    return $exit_code
}

# Execute remote command via SSH
execute_remote_command() {
    local command="$1"
    local description="${2:-command}"
    local timeout_duration="${3:-30}"
    
    log_running "Executing remotely: $description"
    
    # Prepare SSH command
    local ssh_cmd=""
    local remote_command="cd '$REMOTE_DIRECTORY' && $command"
    
    if [[ -n "$REMOTE_KEY_FILE" ]]; then
        ssh_cmd="ssh -i '$REMOTE_KEY_FILE' -o ConnectTimeout=10 '$REMOTE_USER@$REMOTE_HOST' '$remote_command'"
    else
        ssh_cmd="sshpass -p '$REMOTE_PASSWORD' ssh -o ConnectTimeout=10 -o StrictHostKeyChecking=no '$REMOTE_USER@$REMOTE_HOST' '$remote_command'"
    fi
    
    local output
    local exit_code
    
    if output=$(timeout "$timeout_duration" bash -c "$ssh_cmd" 2>&1); then
        exit_code=0
        log_success "Remote execution successful: $description"
    else
        exit_code=$?
        if [[ $exit_code -eq 124 ]]; then
            log_error "Remote execution timed out: $description" "TIMEOUT" "${timeout_duration}s"
        else
            log_error "Remote execution failed: $description" "EXIT_CODE_$exit_code" "$output"
        fi
    fi
    
    echo "$output"
    return $exit_code
}

# Initialize diagnostic environment with dynamic directories
init_diagnostic_environment() {
    echo -e "${BLUE}${BOLD}╔══════════════════════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${BLUE}${BOLD}║                SYNTROPY PLATFORM ENHANCED DIAGNOSTIC SUITE                  ║${NC}"
    echo -e "${BLUE}${BOLD}║                           Version ${SCRIPT_VERSION}                                    ║${NC}"
    echo -e "${BLUE}${BOLD}╚══════════════════════════════════════════════════════════════════════════════╝${NC}"
    echo
    
    # Create dynamic directory structure
    mkdir -p "${LOG_DIR}" "${CACHE_DIR}"
    
    # Initialize detailed log
    touch "${DETAILED_LOG}"
    
    # Initialize results file with comprehensive metadata
    cat > "${RESULTS_FILE}" << EOF
{
    "execution_id": "${EXECUTION_ID}",
    "timestamp": "${ISO_TIMESTAMP}",
    "version": "${SCRIPT_VERSION}",
    "execution_mode": "$(if [[ "$REMOTE_EXECUTION" == "true" ]]; then echo "remote"; else echo "local"; fi)",
    "environment": {
        "workspace": "${WORKSPACE_DIR}",
        "log_directory": "${LOG_DIR}",
        "env_file": "${ENV_FILE}",
        "api_host": "${API_HOST}",
        "app_host": "${APP_HOST}",
        "remote_execution": ${REMOTE_EXECUTION},
        "remote_host": "${REMOTE_HOST:-null}",
        "remote_user": "${REMOTE_USER:-null}",
        "remote_directory": "${REMOTE_DIRECTORY:-null}"
    },
    "system_info": {
        "os": "$(uname -s)",
        "kernel": "$(uname -r)",
        "architecture": "$(uname -m)",
        "hostname": "$(hostname)",
        "user": "$(whoami)",
        "shell": "${SHELL}",
        "execution_timestamp": "${EXECUTION_TIMESTAMP}"
    },
    "tests": {},
    "summary": {
        "total_tests": 0,
        "passed": 0,
        "warnings": 0,
        "failed": 0,
        "critical": 0,
        "skipped": 0,
        "execution_time": 0
    }
}
EOF

    log_info "Diagnostic environment initialized with dynamic directory structure"
    log_info "Execution ID: ${EXECUTION_ID}"
    log_info "Log Directory: ${LOG_DIR}"
    log_info "Results will be saved to: ${RESULTS_FILE}"
}

# Enhanced JSON result recording with validation
record_test_result() {
    local category="$1"
    local test_name="$2"
    local status="$3"
    local message="$4"
    local details="${5:-{}}"
    local duration="${6:-0}"
    local error_code="${7:-}"
    local context="${8:-}"
    
    # Validate inputs
    if [[ -z "$category" || -z "$test_name" || -z "$status" || -z "$message" ]]; then
        log_error "Invalid test result parameters" "INVALID_PARAMS" "record_test_result"
        return 1
    fi
    
    # Ensure status is valid
    case "$status" in
        "SUCCESS"|"WARNING"|"ERROR"|"CRITICAL"|"SKIPPED") ;;
        *) 
            log_error "Invalid test status: $status" "INVALID_STATUS" "record_test_result"
            return 1
            ;;
    esac
    
    # Create comprehensive test result object
    local test_result=$(cat << EOF
{
    "category": "${category}",
    "name": "${test_name}",
    "status": "${status}",
    "message": "${message}",
    "timestamp": "$(date -u +"%Y-%m-%dT%H:%M:%S.%3NZ")",
    "duration_ms": ${duration},
    "error_code": "${error_code}",
    "context": "${context}",
    "details": ${details}
}
EOF
)
    
    # Update results file using jq
    if command -v jq >/dev/null 2>&1; then
        local temp_file=$(mktemp)
        if jq --argjson test "$test_result" '.tests["'${category}'_'${test_name}'"] = $test' "$RESULTS_FILE" > "$temp_file" 2>/dev/null; then
            mv "$temp_file" "$RESULTS_FILE"
            log_info "Test result recorded: ${category}/${test_name} - ${status}"
        else
            log_error "Failed to update results file with jq" "JQ_UPDATE_FAILED" "record_test_result"
            rm -f "$temp_file"
            # Fallback to basic logging
            echo "Test recorded: ${category}/${test_name} - ${status} - ${message}" >> "${LOG_DIR}/test_results_fallback.log"
        fi
    else
        # Fallback for systems without jq
        echo "Test recorded: ${category}/${test_name} - ${status} - ${message}" >> "${LOG_DIR}/test_results_fallback.log"
        log_warning "jq not available, using fallback logging" "JQ_UNAVAILABLE" "record_test_result"
    fi
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
            log_error "${description} failed after ${max_attempts} attempts" "MAX_RETRIES_EXCEEDED" "$description"
            return 1
        fi
        
        log_warning "${description} failed, retrying in ${delay}s..." "RETRY_ATTEMPT_$attempt" "$description"
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

#===============================================================================
# ENHANCED INFRASTRUCTURE TESTS
#===============================================================================

test_docker_environment() {
    print_section_header "DOCKER ENVIRONMENT VERIFICATION"
    
    local start_time=$(date +%s%3N)
    
    # Test Docker daemon
    log_running "Testing Docker daemon accessibility"
    
    local docker_info_output
    if docker_info_output=$(execute_command "docker info" "Docker daemon info check" 15); then
        log_success "Docker daemon is running and accessible"
        
        # Extract Docker version information
        local docker_version
        docker_version=$(execute_command "docker --version" "Docker version check" 5)
        
        local compose_version
        compose_version=$(execute_command "docker compose version" "Docker Compose version check" 5)
        
        if [[ -n "$docker_version" && -n "$compose_version" ]]; then
            log_info "Docker Version: ${docker_version}"
            log_info "Compose Version: ${compose_version}"
            
            record_test_result "infrastructure" "docker_environment" "SUCCESS" "Docker environment verified" \
                "{\"docker_version\":\"${docker_version}\",\"compose_version\":\"${compose_version}\",\"info_available\":true}" \
                $(($(date +%s%3N) - start_time))
        else
            log_warning "Docker version information incomplete"
            record_test_result "infrastructure" "docker_environment" "WARNING" "Docker accessible but version info incomplete" \
                "{\"docker_version\":\"${docker_version:-unknown}\",\"compose_version\":\"${compose_version:-unknown}\",\"info_available\":false}" \
                $(($(date +%s%3N) - start_time)) "VERSION_INFO_INCOMPLETE"
        fi
    else
        log_critical "Docker daemon is not running or accessible" "DOCKER_DAEMON_UNAVAILABLE" "Infrastructure test"
        record_test_result "infrastructure" "docker_environment" "CRITICAL" "Docker daemon not accessible" \
            "{\"docker_available\":false}" \
            $(($(date +%s%3N) - start_time)) "DOCKER_DAEMON_UNAVAILABLE"
        return 1
    fi
    
    return 0
}

test_container_status() {
    print_section_header "CONTAINER STATUS & HEALTH CHECKS"
    
    local start_time=$(date +%s%3N)
    local failed_containers=()
    local container_details=()
    local total_containers=${#CONTAINERS[@]}
    local running_containers=0
    
    for container in "${CONTAINERS[@]}"; do
        log_running "Checking container: ${container}"
        
        # Check if container exists and is running
        local container_status
        container_status=$(execute_command "docker ps --filter 'name=${container}' --format '{{.Names}}\t{{.Status}}'" "Container status check for ${container}" 10)
        
        if [[ -z "$container_status" ]]; then
            log_error "Container ${container} is not running" "CONTAINER_NOT_RUNNING" "$container"
            failed_containers+=("${container}")
            container_details+=("{\"name\":\"${container}\",\"status\":\"not_running\",\"error\":\"container_not_found\"}")
            continue
        fi
        
        # Get detailed container information
        local detailed_info
        detailed_info=$(execute_command "docker inspect ${container} --format '{{.State.Status}}\t{{.State.Health.Status}}\t{{.State.StartedAt}}\t{{.RestartCount}}'" "Container details for ${container}" 10)
        
        if [[ -n "$detailed_info" ]]; then
            IFS=$'\t' read -r status health uptime restart_count <<< "$detailed_info"
            
            if [[ "$status" == "running" ]]; then
                ((running_containers++))
                if [[ "$health" == "healthy" || "$health" == "none" || "$health" == "<no value>" ]]; then
                    log_success "Container ${container}: ${status} (health: ${health:-none})"
                    container_details+=("{\"name\":\"${container}\",\"status\":\"${status}\",\"health\":\"${health:-none}\",\"uptime\":\"${uptime}\",\"restart_count\":${restart_count}}")
                else
                    log_warning "Container ${container}: ${status} but health check failed (${health})" "HEALTH_CHECK_FAILED" "$container"
                    container_details+=("{\"name\":\"${container}\",\"status\":\"${status}\",\"health\":\"${health}\",\"uptime\":\"${uptime}\",\"restart_count\":${restart_count},\"warning\":\"health_check_failed\"}")
                fi
            else
                log_error "Container ${container}: ${status}" "CONTAINER_NOT_RUNNING" "$container"
                failed_containers+=("${container}")
                container_details+=("{\"name\":\"${container}\",\"status\":\"${status}\",\"health\":\"${health:-unknown}\",\"uptime\":\"${uptime}\",\"restart_count\":${restart_count}}")
            fi
        else
            log_error "Failed to get detailed info for container ${container}" "CONTAINER_INSPECT_FAILED" "$container"
            failed_containers+=("${container}")
            container_details+=("{\"name\":\"${container}\",\"status\":\"unknown\",\"error\":\"inspect_failed\"}")
        fi
    done
    
    # Record comprehensive results
    local details="{\"total_containers\":${total_containers},\"running_containers\":${running_containers},\"failed_containers\":${#failed_containers[@]},\"containers\":[$(IFS=,; echo "${container_details[*]}")]}"
    
    if [[ ${#failed_containers[@]} -eq 0 ]]; then
        log_success "All ${total_containers} containers are running properly"
        record_test_result "infrastructure" "container_status" "SUCCESS" "All containers healthy" "$details" $(($(date +%s%3N) - start_time))
        return 0
    else
        log_error "Failed containers (${#failed_containers[@]}/${total_containers}): ${failed_containers[*]}" "CONTAINERS_FAILED" "Container status check"
        record_test_result "infrastructure" "container_status" "ERROR" "Some containers failed: ${failed_containers[*]}" "$details" $(($(date +%s%3N) - start_time)) "CONTAINERS_FAILED"
        return 1
    fi
}

#===============================================================================
# ENHANCED DATABASE TESTS
#===============================================================================

test_database_connectivity() {
    print_section_header "DATABASE CONNECTIVITY & BASIC HEALTH"
    
    local start_time=$(date +%s%3N)
    local db_container="syntropy-db"
    
    # Test PostgreSQL connectivity
    log_running "Testing PostgreSQL database connectivity"
    
    local pg_ready_output
    if pg_ready_output=$(execute_command "docker exec -i ${db_container} pg_isready -U postgres" "PostgreSQL readiness check" 15); then
        log_success "PostgreSQL database is ready and accepting connections"
        
        # Test database version and configuration
        local db_version
        db_version=$(execute_command "docker exec -i ${db_container} psql -U postgres -d postgres -qtAX -c \"SELECT version();\"" "Database version check" 10)
        
        local db_size
        db_size=$(execute_command "docker exec -i ${db_container} psql -U postgres -d postgres -qtAX -c \"SELECT pg_size_pretty(pg_database_size('postgres'));\"" "Database size check" 10)
        
        local connection_count
        connection_count=$(execute_command "docker exec -i ${db_container} psql -U postgres -d postgres -qtAX -c \"SELECT count(*) FROM pg_stat_activity;\"" "Connection count check" 10)
        
        if [[ -n "$db_version" && -n "$db_size" && -n "$connection_count" ]]; then
            log_info "Database version: ${db_version}"
            log_info "Database size: ${db_size}"
            log_info "Active connections: ${connection_count}"
            
            record_test_result "database" "connectivity" "SUCCESS" "Database connectivity verified" \
                "{\"version\":\"${db_version}\",\"size\":\"${db_size}\",\"connections\":${connection_count},\"ready\":true}" \
                $(($(date +%s%3N) - start_time))
        else
            log_warning "Database accessible but some metrics unavailable"
            record_test_result "database" "connectivity" "WARNING" "Database accessible but metrics incomplete" \
                "{\"version\":\"${db_version:-unknown}\",\"size\":\"${db_size:-unknown}\",\"connections\":\"${connection_count:-unknown}\",\"ready\":true}" \
                $(($(date +%s%3N) - start_time)) "METRICS_INCOMPLETE"
        fi
    else
        log_critical "PostgreSQL database is not ready" "DATABASE_NOT_READY" "Database connectivity test"
        record_test_result "database" "connectivity" "CRITICAL" "PostgreSQL not ready" \
            "{\"ready\":false,\"error\":\"pg_isready_failed\"}" \
            $(($(date +%s%3N) - start_time)) "DATABASE_NOT_READY"
        return 1
    fi
    
    return 0
}

test_database_schema() {
    print_section_header "DATABASE SCHEMA & ROLES VERIFICATION"
    
    local start_time=$(date +%s%3N)
    local db_container="syntropy-db"
    local psql_base_cmd="docker exec -i ${db_container} psql -U postgres -d postgres -qtAX -c"
    
    # Test required roles
    log_running "Verifying database roles"
    
    local required_roles=("supabase_admin" "authenticator" "service_role")
    local missing_roles=()
    local role_details=()
    
    for role in "${required_roles[@]}"; do
        local role_check
        role_check=$(execute_command "${psql_base_cmd} \"SELECT 1 FROM pg_roles WHERE rolname = '${role}';\"" "Role check for ${role}" 10)
        
        if [[ "$role_check" == "1" ]]; then
            log_success "Role '${role}' exists"
            role_details+=("{\"name\":\"${role}\",\"exists\":true}")
        else
            log_error "Role '${role}' is missing" "ROLE_MISSING" "$role"
            missing_roles+=("${role}")
            role_details+=("{\"name\":\"${role}\",\"exists\":false}")
        fi
    done
    
    # Test auth.users table specifically
    log_running "Verifying auth.users table"
    
    local users_count
    users_count=$(execute_command "${psql_base_cmd} \"SELECT count(*) FROM auth.users;\"" "Auth users count check" 10)
    
    if [[ -n "$users_count" && "$users_count" =~ ^[0-9]+$ ]]; then
        log_success "auth.users table accessible (${users_count} users)"
    else
        log_error "auth.users table not accessible" "AUTH_TABLE_INACCESSIBLE" "Schema verification"
        missing_roles+=("auth.users")
        users_count="ERROR"
    fi
    
    # Test additional schema components
    log_running "Verifying additional schema components"
    
    local schema_components=("auth" "storage" "realtime")
    local schema_details=()
    
    for schema in "${schema_components[@]}"; do
        local schema_check
        schema_check=$(execute_command "${psql_base_cmd} \"SELECT 1 FROM information_schema.schemata WHERE schema_name = '${schema}';\"" "Schema check for ${schema}" 10)
        
        if [[ "$schema_check" == "1" ]]; then
            log_success "Schema '${schema}' exists"
            schema_details+=("{\"name\":\"${schema}\",\"exists\":true}")
        else
            log_warning "Schema '${schema}' is missing" "SCHEMA_MISSING" "$schema"
            schema_details+=("{\"name\":\"${schema}\",\"exists\":false}")
        fi
    done
    
    # Record comprehensive results
    local details="{\"roles\":[$(IFS=,; echo "${role_details[*]}")],\"schemas\":[$(IFS=,; echo "${schema_details[*]}")],\"users_count\":\"${users_count}\"}"
    
    if [[ ${#missing_roles[@]} -eq 0 ]]; then
        log_success "Database schema and roles verification completed successfully"
        record_test_result "database" "schema" "SUCCESS" "All required roles and schemas present" "$details" $(($(date +%s%3N) - start_time))
        return 0
    else
        log_error "Missing database components (${#missing_roles[@]}): ${missing_roles[*]}" "SCHEMA_COMPONENTS_MISSING" "Schema verification"
        record_test_result "database" "schema" "ERROR" "Missing components: ${missing_roles[*]}" "$details" $(($(date +%s%3N) - start_time)) "SCHEMA_COMPONENTS_MISSING"
        return 1
    fi
}

#===============================================================================
# ENHANCED NETWORK CONNECTIVITY TESTS
#===============================================================================

test_service_endpoints() {
    print_section_header "SERVICE ENDPOINT CONNECTIVITY"
    
    local start_time=$(date +%s%3N)
    local failed_endpoints=()
    local endpoint_details=()
    local total_endpoints=${#SERVICE_ENDPOINTS[@]}
    local successful_endpoints=0
    
    for service in "${!SERVICE_ENDPOINTS[@]}"; do
        local endpoint="${SERVICE_ENDPOINTS[$service]}"
        
        log_running "Testing service endpoint: ${service} (${endpoint})"
        
        # Test HTTP connectivity with comprehensive error handling
        local response_time_start=$(date +%s%3N)
        local curl_output
        local http_code="000"
        
        # Try primary health endpoint
        if curl_output=$(execute_command "curl -s -o /dev/null -w '%{http_code}' --connect-timeout 10 --max-time 30 '${endpoint}/health'" "HTTP health check for ${service}" 35); then
            http_code="$curl_output"
        fi
        
        local response_time=$(($(date +%s%3N) - response_time_start))
        
        if [[ "$http_code" =~ ^[2-3][0-9][0-9]$ ]]; then
            log_success "Service ${service} endpoint responding (HTTP ${http_code}, ${response_time}ms)"
            endpoint_details+=("{\"service\":\"${service}\",\"endpoint\":\"${endpoint}/health\",\"http_code\":${http_code},\"response_time\":${response_time},\"status\":\"success\"}")
            ((successful_endpoints++))
        else
            # Try alternative health check endpoints
            local alt_endpoints=("/" "/status" "/ping" "")
            local success=false
            
            for alt_endpoint in "${alt_endpoints[@]}"; do
                local test_url="${endpoint}${alt_endpoint}"
                local alt_response
                
                if alt_response=$(execute_command "curl -s -o /dev/null -w '%{http_code}' --connect-timeout 5 --max-time 15 '${test_url}'" "Alternative endpoint check for ${service}" 20); then
                    if [[ "$alt_response" =~ ^[2-3][0-9][0-9]$ ]]; then
                        log_success "Service ${service} responding on alternative endpoint (HTTP ${alt_response})"
                        endpoint_details+=("{\"service\":\"${service}\",\"endpoint\":\"${test_url}\",\"http_code\":${alt_response},\"response_time\":${response_time},\"status\":\"success\",\"alternative\":true}")
                        success=true
                        ((successful_endpoints++))
                        break
                    fi
                fi
            done
            
            if [[ "$success" == false ]]; then
                log_error "Service ${service} endpoint not responding (HTTP ${http_code})" "ENDPOINT_NOT_RESPONDING" "$service"
                failed_endpoints+=("${service}")
                endpoint_details+=("{\"service\":\"${service}\",\"endpoint\":\"${endpoint}\",\"http_code\":${http_code},\"response_time\":${response_time},\"status\":\"failed\"}")
            fi
        fi
    done
    
    # Record comprehensive results
    local details="{\"total_endpoints\":${total_endpoints},\"successful_endpoints\":${successful_endpoints},\"failed_endpoints\":${#failed_endpoints[@]},\"endpoints\":[$(IFS=,; echo "${endpoint_details[*]}")]}"
    
    if [[ ${#failed_endpoints[@]} -eq 0 ]]; then
        log_success "All ${total_endpoints} service endpoints are responding"
        record_test_result "connectivity" "service_endpoints" "SUCCESS" "All service endpoints responding" "$details" $(($(date +%s%3N) - start_time))
        return 0
    else
        log_error "Failed service endpoints (${#failed_endpoints[@]}/${total_endpoints}): ${failed_endpoints[*]}" "ENDPOINTS_FAILED" "Service endpoint test"
        record_test_result "connectivity" "service_endpoints" "ERROR" "Some service endpoints failed: ${failed_endpoints[*]}" "$details" $(($(date +%s%3N) - start_time)) "ENDPOINTS_FAILED"
        return 1
    fi
}

#===============================================================================
# ENHANCED AUTHENTICATION TESTS
#===============================================================================

test_authentication_service() {
    print_section_header "AUTHENTICATION SERVICE VERIFICATION"
    
    local start_time=$(date +%s%3N)
    local auth_endpoint="http://127.0.0.1:${API_PORT}/auth/v1"
    
    # Test GoTrue health via Kong
    log_running "Testing GoTrue authentication service via Kong"
    
    local health_response
    local http_code="000"
    
    if health_response=$(execute_command "curl -s -w '%{http_code}' -H 'Host: ${API_HOST}' --connect-timeout 10 --max-time 30 '${auth_endpoint}/settings'" "GoTrue settings endpoint check" 35); then
        http_code="${health_response: -3}"
    fi
    
    if [[ "$http_code" == "200" ]]; then
        log_success "GoTrue authentication service is accessible via Kong"
        
        # Test admin users endpoint if SERVICE_ROLE_KEY is available
        if [[ -n "${SERVICE_ROLE_KEY:-}" ]]; then
            log_running "Testing admin users API endpoint"
            
            local admin_endpoint="${auth_endpoint}/admin/users"
            local admin_response
            local admin_http_code="000"
            
            if admin_response=$(execute_command "curl -s -w '%{http_code}' -H 'Host: ${API_HOST}' -H 'apikey: ${SERVICE_ROLE_KEY}' -H 'Authorization: Bearer ${SERVICE_ROLE_KEY}' -H 'Content-Type: application/json' --connect-timeout 10 --max-time 30 '${admin_endpoint}?limit=1'" "Admin users API check" 35); then
                admin_http_code="${admin_response: -3}"
            fi
            
            if [[ "$admin_http_code" == "200" ]]; then
                log_success "Admin users API is accessible"
                record_test_result "authentication" "service_health" "SUCCESS" "Authentication service fully verified" \
                    "{\"settings_code\":${http_code},\"admin_code\":${admin_http_code},\"admin_api_available\":true}" \
                    $(($(date +%s%3N) - start_time))
            else
                log_warning "Admin users API not accessible (HTTP ${admin_http_code})" "ADMIN_API_INACCESSIBLE" "Authentication test"
                record_test_result "authentication" "service_health" "WARNING" "Authentication service accessible but admin API failed" \
                    "{\"settings_code\":${http_code},\"admin_code\":${admin_http_code},\"admin_api_available\":false}" \
                    $(($(date +%s%3N) - start_time)) "ADMIN_API_INACCESSIBLE"
            fi
        else
            log_info "SERVICE_ROLE_KEY not available, skipping admin API test"
            record_test_result "authentication" "service_health" "SUCCESS" "Authentication service verified (admin API skipped)" \
                "{\"settings_code\":${http_code},\"admin_api_skipped\":true}" \
                $(($(date +%s%3N) - start_time))
        fi
    else
        log_error "GoTrue authentication service not accessible via Kong (HTTP ${http_code})" "AUTH_SERVICE_INACCESSIBLE" "Authentication test"
        record_test_result "authentication" "service_health" "ERROR" "GoTrue not accessible via Kong" \
            "{\"settings_code\":${http_code},\"accessible\":false}" \
            $(($(date +%s%3N) - start_time)) "AUTH_SERVICE_INACCESSIBLE"
        return 1
    fi
    
    return 0
}

#===============================================================================
# ENHANCED API TESTS
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
        "/realtime/v1/"
    )
    
    local routing_results=()
    local failed_routes=()
    local successful_routes=0
    
    for route in "${kong_routes[@]}"; do
        log_running "Testing Kong route: ${route}"
        
        local route_response
        local route_http_code="000"
        
        if route_response=$(execute_command "curl -s -w '%{http_code}' -H 'Host: ${API_HOST}' --connect-timeout 10 --max-time 30 '${kong_endpoint}${route}'" "Kong route test for ${route}" 35); then
            route_http_code="${route_response: -3}"
        fi
        
        # Routes should return appropriate HTTP codes (not 502/503/504)
        if [[ "$route_http_code" =~ ^[2-4][0-9][0-9]$ && ! "$route_http_code" =~ ^50[2-4]$ ]]; then
            log_success "Kong route ${route} responding (HTTP ${route_http_code})"
            routing_results+=("{\"route\":\"${route}\",\"http_code\":${route_http_code},\"status\":\"success\"}")
            ((successful_routes++))
        else
            log_error "Kong route ${route} not responding properly (HTTP ${route_http_code})" "KONG_ROUTE_FAILED" "$route"
            failed_routes+=("${route}")
            routing_results+=("{\"route\":\"${route}\",\"http_code\":${route_http_code},\"status\":\"failed\"}")
        fi
    done
    
    # Record comprehensive results
    local details="{\"total_routes\":${#kong_routes[@]},\"successful_routes\":${successful_routes},\"failed_routes\":${#failed_routes[@]},\"routes\":[$(IFS=,; echo "${routing_results[*]}")]}"
    
    if [[ ${#failed_routes[@]} -eq 0 ]]; then
        log_success "Kong gateway routing verification completed successfully"
        record_test_result "api" "kong_gateway" "SUCCESS" "Kong gateway routing verified" "$details" $(($(date +%s%3N) - start_time))
        return 0
    else
        log_error "Failed Kong routes (${#failed_routes[@]}/${#kong_routes[@]}): ${failed_routes[*]}" "KONG_ROUTES_FAILED" "Kong gateway test"
        record_test_result "api" "kong_gateway" "ERROR" "Some Kong routes failed: ${failed_routes[*]}" "$details" $(($(date +%s%3N) - start_time)) "KONG_ROUTES_FAILED"
        return 1
    fi
}

test_postgrest_api() {
    print_section_header "POSTGREST API FUNCTIONALITY"
    
    local start_time=$(date +%s%3N)
    local rest_endpoint="http://127.0.0.1:${API_PORT}/rest/v1"
    
    # Test PostgREST root endpoint
    log_running "Testing PostgREST root endpoint"
    
    local root_response
    local root_http_code="000"
    
    if [[ -n "${ANON_KEY:-}" ]]; then
        if root_response=$(execute_command "curl -s -w '%{http_code}' -H 'Host: ${API_HOST}' -H 'apikey: ${ANON_KEY}' --connect-timeout 10 --max-time 30 '${rest_endpoint}/'" "PostgREST root endpoint check" 35); then
            root_http_code="${root_response: -3}"
        fi
    else
        log_warning "ANON_KEY not available, testing without authentication"
        if root_response=$(execute_command "curl -s -w '%{http_code}' -H 'Host: ${API_HOST}' --connect-timeout 10 --max-time 30 '${rest_endpoint}/'" "PostgREST root endpoint check (no auth)" 35); then
            root_http_code="${root_response: -3}"
        fi
    fi
    
    if [[ "$root_http_code" == "200" ]]; then
        log_success "PostgREST root endpoint responding"
        record_test_result "api" "postgrest" "SUCCESS" "PostgREST API verified" \
            "{\"root_code\":${root_http_code},\"authenticated\":$(if [[ -n "${ANON_KEY:-}" ]]; then echo "true"; else echo "false"; fi)}" \
            $(($(date +%s%3N) - start_time))
    else
        log_error "PostgREST root endpoint not responding (HTTP ${root_http_code})" "POSTGREST_ENDPOINT_FAILED" "PostgREST test"
        record_test_result "api" "postgrest" "ERROR" "PostgREST root endpoint failed" \
            "{\"root_code\":${root_http_code},\"authenticated\":$(if [[ -n "${ANON_KEY:-}" ]]; then echo "true"; else echo "false"; fi)}" \
            $(($(date +%s%3N) - start_time)) "POSTGREST_ENDPOINT_FAILED"
        return 1
    fi
    
    return 0
}

#===============================================================================
# ENHANCED PERFORMANCE BENCHMARKING
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
        local response_times=()
        
        for i in {1..5}; do
            local request_start=$(date +%s%3N)
            
            local headers=()
            if [[ "$service_name" != "nextjs" ]]; then
                headers+=("-H" "Host: ${API_HOST}")
                if [[ "$service_name" == "rest" && -n "${ANON_KEY:-}" ]]; then
                    headers+=("-H" "apikey: ${ANON_KEY}")
                fi
            fi
            
            local curl_result
            if curl_result=$(execute_command "curl -s -o /dev/null --connect-timeout 5 --max-time 15 ${headers[*]} '${endpoint_url}'" "Performance test ${i} for ${service_name}" 20); then
                local request_time=$(($(date +%s%3N) - request_start))
                total_time=$((total_time + request_time))
                successful_requests=$((successful_requests + 1))
                response_times+=("$request_time")
                
                if [[ $request_time -lt $min_time ]]; then
                    min_time=$request_time
                fi
                if [[ $request_time -gt $max_time ]]; then
                    max_time=$request_time
                fi
            else
                failed_requests=$((failed_requests + 1))
            fi
        done
        
        if [[ $successful_requests -gt 0 ]]; then
            local avg_time=$((total_time / successful_requests))
            
            # Calculate median
            IFS=$'\n' sorted_times=($(sort -n <<<"${response_times[*]}"))
            local median_time=${sorted_times[$((successful_requests/2))]}
            
            log_success "Service ${service_name} performance: avg=${avg_time}ms, median=${median_time}ms, min=${min_time}ms, max=${max_time}ms"
            performance_results+=("{\"service\":\"${service_name}\",\"avg_time\":${avg_time},\"median_time\":${median_time},\"min_time\":${min_time},\"max_time\":${max_time},\"successful\":${successful_requests},\"failed\":${failed_requests}}")
        else
            log_error "Service ${service_name} performance test failed - no successful requests" "PERFORMANCE_TEST_FAILED" "$service_name"
            performance_results+=("{\"service\":\"${service_name}\",\"successful\":0,\"failed\":${failed_requests},\"error\":\"no_successful_requests\"}")
        fi
    done
    
    record_test_result "performance" "response_times" "SUCCESS" "Response time benchmarking completed" \
        "{\"results\":[$(IFS=,; echo "${performance_results[*]}")]}" \
        $(($(date +%s%3N) - start_time))
    
    return 0
}

#===============================================================================
# ENHANCED SSL/TLS & SECURITY TESTS
#===============================================================================

test_ssl_certificates() {
    print_section_header "SSL/TLS CERTIFICATE VERIFICATION"
    
    local start_time=$(date +%s%3N)
    local ssl_results=()
    
    # Test external SSL certificates
    local ssl_hosts=("${API_HOST}" "${APP_HOST}")
    
    for host in "${ssl_hosts[@]}"; do
        log_running "Testing SSL certificate for ${host}"
        
        # Test SSL certificate validity
        local ssl_info
        if ssl_info=$(execute_command "echo | timeout 10 openssl s_client -servername '${host}' -connect '${host}:443' 2>/dev/null | openssl x509 -noout -dates 2>/dev/null" "SSL certificate check for ${host}" 15); then
            if [[ -n "$ssl_info" && "$ssl_info" != "ERROR" ]]; then
                local not_before=$(echo "$ssl_info" | grep "notBefore" | cut -d= -f2)
                local not_after=$(echo "$ssl_info" | grep "notAfter" | cut -d= -f2)
                
                # Check if certificate is still valid
                local current_date=$(date +%s)
                local cert_expiry=$(date -d "$not_after" +%s 2>/dev/null || echo "0")
                
                if [[ $cert_expiry -gt $current_date ]]; then
                    local days_until_expiry=$(( (cert_expiry - current_date) / 86400 ))
                    log_success "SSL certificate for ${host} is valid (expires in ${days_until_expiry} days)"
                    ssl_results+=("{\"host\":\"${host}\",\"status\":\"valid\",\"not_before\":\"${not_before}\",\"not_after\":\"${not_after}\",\"days_until_expiry\":${days_until_expiry}}")
                else
                    log_error "SSL certificate for ${host} has expired" "SSL_CERT_EXPIRED" "$host"
                    ssl_results+=("{\"host\":\"${host}\",\"status\":\"expired\",\"not_before\":\"${not_before}\",\"not_after\":\"${not_after}\"}")
                fi
            else
                log_warning "Could not verify SSL certificate for ${host}" "SSL_CERT_UNVERIFIABLE" "$host"
                ssl_results+=("{\"host\":\"${host}\",\"status\":\"unverifiable\"}")
            fi
        else
            log_warning "SSL certificate check failed for ${host}" "SSL_CHECK_FAILED" "$host"
            ssl_results+=("{\"host\":\"${host}\",\"status\":\"check_failed\"}")
        fi
    done
    
    record_test_result "security" "ssl_certificates" "SUCCESS" "SSL certificate verification completed" \
        "{\"certificates\":[$(IFS=,; echo "${ssl_results[*]}")]}" \
        $(($(date +%s%3N) - start_time))
    
    return 0
}

#===============================================================================
# ENHANCED LOG ANALYSIS & ERROR CORRELATION
#===============================================================================

test_log_analysis() {
    print_section_header "LOG ANALYSIS & ERROR CORRELATION"
    
    local start_time=$(date +%s%3N)
    local log_analysis=()
    
    # Analyze container logs for errors
    for container in "${CONTAINERS[@]}"; do
        log_running "Analyzing logs for container: ${container}"
        
        local container_running
        if container_running=$(execute_command "docker ps --filter 'name=${container}' --format '{{.Names}}'" "Container status check for ${container}" 10); then
            if [[ -n "$container_running" ]]; then
                # Get recent logs and count error patterns
                local log_output
                if log_output=$(execute_command "docker logs '${container}' --since='1h' 2>&1" "Log retrieval for ${container}" 15); then
                    local error_count=$(echo "$log_output" | grep -i -E "(error|exception|fatal|panic|critical)" | wc -l || echo "0")
                    local warning_count=$(echo "$log_output" | grep -i -E "(warning|warn)" | wc -l || echo "0")
                    local total_lines=$(echo "$log_output" | wc -l || echo "0")
                    
                    # Extract recent error samples
                    local recent_errors
                    recent_errors=$(echo "$log_output" | grep -i -E "(error|exception|fatal|panic|critical)" | tail -3 | sed 's/"/\\"/g' || echo "")
                    
                    if [[ $error_count -gt 0 ]]; then
                        log_warning "Container ${container}: ${error_count} errors, ${warning_count} warnings in last hour" "ERRORS_FOUND" "$container"
                    else
                        log_success "Container ${container}: No errors in last hour (${warning_count} warnings)"
                    fi
                    
                    log_analysis+=("{\"container\":\"${container}\",\"errors\":${error_count},\"warnings\":${warning_count},\"total_lines\":${total_lines},\"recent_errors\":\"${recent_errors}\",\"status\":\"analyzed\"}")
                else
                    log_error "Failed to retrieve logs for container ${container}" "LOG_RETRIEVAL_FAILED" "$container"
                    log_analysis+=("{\"container\":\"${container}\",\"status\":\"log_retrieval_failed\"}")
                fi
            else
                log_error "Container ${container} not running - cannot analyze logs" "CONTAINER_NOT_RUNNING" "$container"
                log_analysis+=("{\"container\":\"${container}\",\"status\":\"not_running\"}")
            fi
        else
            log_error "Failed to check status of container ${container}" "STATUS_CHECK_FAILED" "$container"
            log_analysis+=("{\"container\":\"${container}\",\"status\":\"status_check_failed\"}")
        fi
    done
    
    record_test_result "monitoring" "log_analysis" "SUCCESS" "Log analysis completed" \
        "{\"containers\":[$(IFS=,; echo "${log_analysis[*]}")]}" \
        $(($(date +%s%3N) - start_time))
    
    return 0
}

#===============================================================================
# ENHANCED RESILIENCE & FAILOVER TESTS
#===============================================================================

test_service_resilience() {
    print_section_header "SERVICE RESILIENCE TESTING"
    
    local start_time=$(date +%s%3N)
    local resilience_results=()
    
    # Test service restart capability
    log_running "Testing service resilience with consecutive requests"
    
    # Test connection pooling and recovery
    local test_endpoints=(
        "http://127.0.0.1:${API_PORT}/auth/v1/settings"
        "http://127.0.0.1:${API_PORT}/rest/v1/"
    )
    
    for endpoint in "${test_endpoints[@]}"; do
        log_running "Testing resilience for endpoint: ${endpoint}"
        
        # Perform rapid consecutive requests to test connection handling
        local consecutive_success=0
        local consecutive_failures=0
        local response_times=()
        
        for i in {1..10}; do
            local request_start=$(date +%s%3N)
            local curl_result
            
            if curl_result=$(execute_command "curl -s -o /dev/null -w '%{http_code}' -H 'Host: ${API_HOST}' --connect-timeout 2 --max-time 5 '${endpoint}'" "Resilience test ${i} for ${endpoint}" 10); then
                if [[ "$curl_result" =~ ^[2-3][0-9][0-9]$ ]]; then
                    consecutive_success=$((consecutive_success + 1))
                    local request_time=$(($(date +%s%3N) - request_start))
                    response_times+=("$request
_time")
                else
                    consecutive_failures=$((consecutive_failures + 1))
                fi
            else
                consecutive_failures=$((consecutive_failures + 1))
            fi
            sleep 0.1
        done
        
        local success_rate=$((consecutive_success * 100 / 10))
        
        # Calculate average response time for successful requests
        local avg_response_time=0
        if [[ ${#response_times[@]} -gt 0 ]]; then
            local total_response_time=0
            for time in "${response_times[@]}"; do
                total_response_time=$((total_response_time + time))
            done
            avg_response_time=$((total_response_time / ${#response_times[@]}))
        fi
        
        if [[ $success_rate -ge 80 ]]; then
            log_success "Endpoint resilience: ${success_rate}% success rate (avg: ${avg_response_time}ms)"
        elif [[ $success_rate -ge 60 ]]; then
            log_warning "Endpoint resilience: ${success_rate}% success rate (acceptable, avg: ${avg_response_time}ms)" "RESILIENCE_ACCEPTABLE" "$endpoint"
        else
            log_error "Endpoint resilience: ${success_rate}% success rate (poor, avg: ${avg_response_time}ms)" "RESILIENCE_POOR" "$endpoint"
        fi
        
        resilience_results+=("{\"endpoint\":\"${endpoint}\",\"success_rate\":${success_rate},\"successful\":${consecutive_success},\"failed\":${consecutive_failures},\"avg_response_time\":${avg_response_time}}")
    done
    
    record_test_result "resilience" "service_resilience" "SUCCESS" "Service resilience testing completed" \
        "{\"results\":[$(IFS=,; echo "${resilience_results[*]}")]}" \
        $(($(date +%s%3N) - start_time))
    
    return 0
}

#===============================================================================
# MAIN EXECUTION FLOW
#===============================================================================

# Source infrastructure layer functions
source infrastructure/diagnostics/collectors/infrastructure_layer/main.sh

# Source database layer functions
source infrastructure/diagnostics/collectors/database_layer/main.sh

# Execute all test categories with enhanced error handling
run_all_tests() {
    local total_tests=0
    local passed_tests=0
    local failed_tests=0
    local warning_tests=0
    local critical_tests=0
    local skipped_tests=0
    
    # Infrastructure tests
    print_section_header "INFRASTRUCTURE LAYER TESTING"
    
    if test_docker_environment; then
        ((passed_tests++))
    else
        ((critical_tests++))
    fi
    ((total_tests++))
    
    if test_container_status; then
        ((passed_tests++))
    else
        ((failed_tests++))
    fi
    ((total_tests++))
    
    # Database tests
    print_section_header "DATABASE LAYER TESTING"
    
    if test_database_connectivity; then
        ((passed_tests++))
        
        # Only run schema test if connectivity passed
        if test_database_schema; then
            ((passed_tests++))
        else
            ((failed_tests++))
        fi
        ((total_tests++))
    else
        ((critical_tests++))
        log_skipped "Skipping database schema test due to connectivity failure"
        ((skipped_tests++))
        ((total_tests++))
    fi
    ((total_tests++))
    
    # Network connectivity tests
    print_section_header "NETWORK CONNECTIVITY TESTING"
    
    if test_service_endpoints; then
        ((passed_tests++))
    else
        ((failed_tests++))
    fi
    ((total_tests++))
    
    # Authentication tests
    print_section_header "AUTHENTICATION LAYER TESTING"
    
    if test_authentication_service; then
        ((passed_tests++))
    else
        ((failed_tests++))
    fi
    ((total_tests++))
    
    # API tests
    print_section_header "API LAYER TESTING"
    
    if test_kong_gateway; then
        ((passed_tests++))
    else
        ((failed_tests++))
    fi
    ((total_tests++))
    
    if test_postgrest_api; then
        ((passed_tests++))
    else
        ((failed_tests++))
    fi
    ((total_tests++))
    
    # Security tests
    print_section_header "SECURITY LAYER TESTING"
    
    if test_ssl_certificates; then
        ((passed_tests++))
    else
        ((warning_tests++))
    fi
    ((total_tests++))
    
    # Performance tests
    print_section_header "PERFORMANCE TESTING"
    
    if test_response_times; then
        ((passed_tests++))
    else
        ((warning_tests++))
    fi
    ((total_tests++))
    
    # Monitoring tests
    print_section_header "MONITORING & LOGGING"
    
    if test_log_analysis; then
        ((passed_tests++))
    else
        ((warning_tests++))
    fi
    ((total_tests++))
    
    # Resilience tests
    print_section_header "RESILIENCE TESTING"
    
    if test_service_resilience; then
        ((passed_tests++))
    else
        ((warning_tests++))
    fi
    ((total_tests++))
    
    # Update summary in results file
    if command -v jq >/dev/null 2>&1; then
        local temp_file=$(mktemp)
        jq --argjson total "$total_tests" \
           --argjson passed "$passed_tests" \
           --argjson failed "$failed_tests" \
           --argjson warnings "$warning_tests" \
           --argjson critical "$critical_tests" \
           --argjson skipped "$skipped_tests" \
           --argjson exec_time "$(($(date +%s) - START_TIME))" \
           '.summary.total_tests = $total | .summary.passed = $passed | .summary.failed = $failed | .summary.warnings = $warnings | .summary.critical = $critical | .summary.skipped = $skipped | .summary.execution_time = $exec_time' \
           "$RESULTS_FILE" > "$temp_file"
        mv "$temp_file" "$RESULTS_FILE"
    fi
    
    # Return overall status
    if [[ $critical_tests -gt 0 ]]; then
        return 2  # Critical failures
    elif [[ $failed_tests -gt 0 ]]; then
        return 1  # Some failures
    else
        return 0  # All tests passed or warnings only
    fi
}

# Generate comprehensive summary report with enhanced details
generate_summary_report() {
    print_section_header "DIAGNOSTIC SUMMARY REPORT"
    
    local end_time=$(date +%s)
    local execution_time=$((end_time - START_TIME))
    
    # Extract summary data from results file
    local total_tests=0
    local passed_tests=0
    local failed_tests=0
    local warning_tests=0
    local critical_tests=0
    local skipped_tests=0
    
    if command -v jq >/dev/null 2>&1 && [[ -f "$RESULTS_FILE" ]]; then
        total_tests=$(jq -r '.summary.total_tests' "$RESULTS_FILE" 2>/dev/null || echo "0")
        passed_tests=$(jq -r '.summary.passed' "$RESULTS_FILE" 2>/dev/null || echo "0")
        failed_tests=$(jq -r '.summary.failed' "$RESULTS_FILE" 2>/dev/null || echo "0")
        warning_tests=$(jq -r '.summary.warnings' "$RESULTS_FILE" 2>/dev/null || echo "0")
        critical_tests=$(jq -r '.summary.critical' "$RESULTS_FILE" 2>/dev/null || echo "0")
        skipped_tests=$(jq -r '.summary.skipped' "$RESULTS_FILE" 2>/dev/null || echo "0")
    fi
    
    # Create comprehensive summary report
    cat > "${SUMMARY_FILE}" << EOF
╔══════════════════════════════════════════════════════════════════════════════╗
║                SYNTROPY PLATFORM ENHANCED DIAGNOSTIC SUMMARY                ║
║                              $(date -u +"%Y-%m-%d %H:%M:%S UTC")                              ║
╚══════════════════════════════════════════════════════════════════════════════╝

EXECUTION DETAILS:
├─ Execution ID: ${EXECUTION_ID}
├─ Execution Timestamp: ${EXECUTION_TIMESTAMP}
├─ Total Execution Time: ${execution_time}s
├─ Execution Mode: $(if [[ "$REMOTE_EXECUTION" == "true" ]]; then echo "Remote SSH"; else echo "Local"; fi)
├─ Environment File: ${ENV_FILE}
├─ API Host: ${API_HOST}
├─ App Host: ${APP_HOST}
$(if [[ "$REMOTE_EXECUTION" == "true" ]]; then
    echo "├─ Remote Host: ${REMOTE_HOST}"
    echo "├─ Remote User: ${REMOTE_USER}"
    echo "└─ Remote Directory: ${REMOTE_DIRECTORY}"
else
    echo "└─ Local Workspace: ${WORKSPACE_DIR}"
fi)

SYSTEM INFORMATION:
├─ Operating System: $(uname -s) $(uname -r)
├─ Architecture: $(uname -m)
├─ Hostname: $(hostname)
├─ User: $(whoami)
├─ Shell: ${SHELL}
$(if [[ "$REMOTE_EXECUTION" == "false" ]]; then
    echo "├─ Docker Version: $(docker --version 2>/dev/null || echo 'Not available')"
    echo "└─ Docker Compose Version: $(docker compose version 2>/dev/null || echo 'Not available')"
else
    echo "└─ Remote Execution: SSH connection established"
fi)

TEST RESULTS SUMMARY:
├─ Total Tests: ${total_tests}
├─ Passed: ${passed_tests} $(if [[ $total_tests -gt 0 ]]; then echo "($(( passed_tests * 100 / total_tests ))%)"; fi)
├─ Failed: ${failed_tests} $(if [[ $total_tests -gt 0 ]]; then echo "($(( failed_tests * 100 / total_tests ))%)"; fi)
├─ Warnings: ${warning_tests} $(if [[ $total_tests -gt 0 ]]; then echo "($(( warning_tests * 100 / total_tests ))%)"; fi)
├─ Critical: ${critical_tests} $(if [[ $total_tests -gt 0 ]]; then echo "($(( critical_tests * 100 / total_tests ))%)"; fi)
└─ Skipped: ${skipped_tests} $(if [[ $total_tests -gt 0 ]]; then echo "($(( skipped_tests * 100 / total_tests ))%)"; fi)

HEALTH ASSESSMENT:
$(if [[ $critical_tests -gt 0 ]]; then
    echo "🚨 CRITICAL: ${critical_tests} critical issues found - IMMEDIATE ATTENTION REQUIRED"
    echo "   System is in a critical state and may not be operational."
elif [[ $failed_tests -gt 0 ]]; then
    echo "❌ DEGRADED: ${failed_tests} tests failed - investigation and remediation needed"
    echo "   System has significant issues that impact functionality."
elif [[ $warning_tests -gt 0 ]]; then
    echo "⚠️  STABLE: ${warning_tests} warnings detected - monitoring recommended"
    echo "   System is operational but has minor issues or potential concerns."
else
    echo "✅ HEALTHY: All critical systems are operational and performing well"
    echo "   System is in excellent condition with no detected issues."
fi)

RECOMMENDATIONS:
$(if [[ $critical_tests -gt 0 ]]; then
    echo "1. Address critical infrastructure issues immediately"
    echo "2. Check Docker daemon and container status"
    echo "3. Verify database connectivity and configuration"
    echo "4. Review system logs for error patterns"
elif [[ $failed_tests -gt 0 ]]; then
    echo "1. Investigate failed test components"
    echo "2. Check service configurations and network connectivity"
    echo "3. Review authentication and API endpoint status"
    echo "4. Monitor system performance and logs"
elif [[ $warning_tests -gt 0 ]]; then
    echo "1. Monitor warning conditions for potential escalation"
    echo "2. Review SSL certificate expiration dates"
    echo "3. Optimize performance where possible"
    echo "4. Maintain regular monitoring schedule"
else
    echo "1. Continue regular monitoring and maintenance"
    echo "2. Keep system components updated"
    echo "3. Maintain backup and disaster recovery procedures"
    echo "4. Schedule periodic comprehensive diagnostics"
fi)

DETAILED ANALYSIS:
$(if command -v jq >/dev/null 2>&1 && [[ -f "$RESULTS_FILE" ]]; then
    echo "├─ Infrastructure Layer: $(jq -r '[.tests | to_entries[] | select(.key | startswith("infrastructure_"))] | length' "$RESULTS_FILE" 2>/dev/null || echo "N/A") tests"
    echo "├─ Database Layer: $(jq -r '[.tests | to_entries[] | select(.key | startswith("database_"))] | length' "$RESULTS_FILE" 2>/dev/null || echo "N/A") tests"
    echo "├─ Network Layer: $(jq -r '[.tests | to_entries[] | select(.key | startswith("connectivity_"))] | length' "$RESULTS_FILE" 2>/dev/null || echo "N/A") tests"
    echo "├─ Authentication Layer: $(jq -r '[.tests | to_entries[] | select(.key | startswith("authentication_"))] | length' "$RESULTS_FILE" 2>/dev/null || echo "N/A") tests"
    echo "├─ API Layer: $(jq -r '[.tests | to_entries[] | select(.key | startswith("api_"))] | length' "$RESULTS_FILE" 2>/dev/null || echo "N/A") tests"
    echo "├─ Security Layer: $(jq -r '[.tests | to_entries[] | select(.key | startswith("security_"))] | length' "$RESULTS_FILE" 2>/dev/null || echo "N/A") tests"
    echo "├─ Performance Layer: $(jq -r '[.tests | to_entries[] | select(.key | startswith("performance_"))] | length' "$RESULTS_FILE" 2>/dev/null || echo "N/A") tests"
    echo "├─ Monitoring Layer: $(jq -r '[.tests | to_entries[] | select(.key | startswith("monitoring_"))] | length' "$RESULTS_FILE" 2>/dev/null || echo "N/A") tests"
    echo "└─ Resilience Layer: $(jq -r '[.tests | to_entries[] | select(.key | startswith("resilience_"))] | length' "$RESULTS_FILE" 2>/dev/null || echo "N/A") tests"
else
    echo "└─ Detailed layer analysis not available (jq not installed or results file missing)"
fi)

FILES GENERATED:
├─ Detailed Results (JSON): ${RESULTS_FILE}
├─ Summary Report (Text): ${SUMMARY_FILE}
├─ Detailed Log: ${DETAILED_LOG}
└─ Log Directory: ${LOG_DIR}

NEXT STEPS:
1. Review the detailed JSON results file for comprehensive analysis
2. Share results with LLM or monitoring systems for automated analysis
3. Archive diagnostic results for historical comparison
4. Schedule next diagnostic run based on system criticality

For automated analysis, use: jq '.' ${RESULTS_FILE}
For error analysis, use: jq '.tests | to_entries[] | select(.value.status != "SUCCESS")' ${RESULTS_FILE}
EOF
    
    # Display summary to console
    cat "${SUMMARY_FILE}"
    
    log_success "Comprehensive diagnostic summary report generated: ${SUMMARY_FILE}"
    log_success "Detailed results available: ${RESULTS_FILE}"
    log_info "All diagnostic files saved to: ${LOG_DIR}"
}

# Main execution function with enhanced error handling
main() {
    # Trap signals for cleanup
    trap 'log_error "Script interrupted by user" "USER_INTERRUPT"; exit 130' INT TERM
    
    # Interactive setup
    interactive_setup
    
    # Pre-execution validation
    if ! validate_prerequisites; then
        log_critical "Pre-execution validation failed. Cannot proceed with diagnostics."
        exit 1
    fi
    
    # Initialize environment
    init_diagnostic_environment
    
    # Run all diagnostic tests
    log_info "Starting comprehensive enhanced diagnostic suite..."
    
    local test_result
    if run_all_tests; then
        test_result=0
        log_success "Enhanced diagnostic suite completed successfully"
    else
        test_result=$?
        if [[ $test_result -eq 2 ]]; then
            log_critical "Enhanced diagnostic suite completed with CRITICAL issues"
        else
            log_warning "Enhanced diagnostic suite completed with some issues"
        fi
    fi
    
    # Generate summary report
    generate_summary_report
    
    # Final status and recommendations
    local end_time=$(date +%s)
    local total_time=$((end_time - START_TIME))
    
    echo
    print_section_header "EXECUTION COMPLETED"
    
    log_success "Syntropy Platform Enhanced Diagnostic Suite completed in ${total_time}s"
    log_info "Execution ID: ${EXECUTION_ID}"
    log_info "Results directory: ${LOG_DIR}"
    
    if [[ $test_result -eq 0 ]]; then
        log_success "All tests passed or completed with warnings only"
    elif [[ $test_result -eq 1 ]]; then
        log_warning "Some tests failed - review results for details"
    else
        log_critical "Critical issues detected - immediate attention required"
    fi
    
    echo
    log_info "Review the generated reports for detailed analysis and recommendations"
    log_info "Use 'jq' to analyze the JSON results file for automated processing"
    
    return $test_result
}

# Script entry point with argument handling
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    # Handle command line arguments
    case "${1:-}" in
        "--help"|"-h")
            echo "Syntropy Platform Enhanced Diagnostic Suite v${SCRIPT_VERSION}"
            echo
            echo "Usage: $0 [options]"
            echo
            echo "Options:"
            echo "  --help, -h     Show this help message"
            echo "  --version, -v  Show version information"
            echo
            echo "This script provides comprehensive diagnostics for the Syntropy Platform"
            echo "with support for both local and remote SSH execution."
            echo
            echo "Features:"
            echo "  • Interactive configuration setup"
            echo "  • Remote SSH execution capability"
            echo "  • Dynamic timestamp-based directories"
            echo "  • Comprehensive error detection and reporting"
            echo "  • Enhanced logging with detailed context"
            echo "  • Pre-execution validation checks"
            echo "  • Structured JSON output for LLM analysis"
            exit 0
            ;;
        "--version"|"-v")
            echo "Syntropy Platform Enhanced Diagnostic Suite"
            echo "Version: ${SCRIPT_VERSION}"
            echo "Author: DevOps Senior QA Specialist"
            exit 0
            ;;
        "")
            # No arguments, proceed with normal execution
            main "$@"
            ;;
        *)
            echo "Unknown option: $1"
            echo "Use --help for usage information"
            exit 1
            ;;
    esac
fi