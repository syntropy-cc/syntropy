#!/bin/bash

#===============================================================================
# LOGGER CONFIGURATION
#===============================================================================

# Log levels
declare -A LOG_LEVELS
LOG_LEVELS["DEBUG"]=0
LOG_LEVELS["INFO"]=1
LOG_LEVELS["WARNING"]=2
LOG_LEVELS["ERROR"]=3
LOG_LEVELS["CRITICAL"]=4

# Default configuration
LOG_LEVEL="INFO"
LOG_FILE=""
LOG_CONTEXT=""
LOG_TIMESTAMP_FORMAT="%Y-%m-%d %H:%M:%S"
LOG_MAX_SIZE=$((10 * 1024 * 1024)) # 10MB
LOG_BACKUP_COUNT=5

#===============================================================================
# LOGGER SETUP
#===============================================================================

init_logger() {
    local context="$1"
    local timestamp="${2:-$(date +%Y%m%d_%H%M%S)}"
    local base_dir="${3:-${HOME}/.syntropy/diagnostics/logs}"
    
    LOG_CONTEXT="$context"
    LOG_FILE="${base_dir}/${context}_${timestamp}.log"
    
    # Ensure log directory exists
    mkdir -p "$(dirname "$LOG_FILE")"
    
    # Initialize log file with header
    cat > "$LOG_FILE" << EOF
==========================================================================
Diagnostic Log - $context
Started: $(date +"$LOG_TIMESTAMP_FORMAT")
==========================================================================

EOF
}

set_log_level() {
    local level="${1^^}"
    if [[ -n "${LOG_LEVELS[$level]}" ]]; then
        LOG_LEVEL="$level"
        return 0
    else
        echo "Invalid log level: $level" >&2
        return 1
    fi
}

set_log_file() {
    local file="$1"
    if [[ -w "$(dirname "$file")" ]]; then
        LOG_FILE="$file"
        return 0
    else
        echo "Cannot write to log file: $file" >&2
        return 1
    fi
}

#===============================================================================
# LOGGING FUNCTIONS
#===============================================================================

_format_log_message() {
    local level="$1"
    local message="$2"
    local error_code="${3:-}"
    local timestamp="$(date +"$LOG_TIMESTAMP_FORMAT")"
    
    local formatted="[$timestamp][$level]"
    [[ -n "$LOG_CONTEXT" ]] && formatted="$formatted[$LOG_CONTEXT]"
    formatted="$formatted $message"
    [[ -n "$error_code" ]] && formatted="$formatted (Code: $error_code)"
    
    echo "$formatted"
}

_should_log() {
    local level="$1"
    if [[ -z "${LOG_LEVELS[$level]}" ]] || [[ -z "${LOG_LEVELS[$LOG_LEVEL]}" ]]; then
        return 1
    fi
    [[ "${LOG_LEVELS[$level]}" -ge "${LOG_LEVELS[$LOG_LEVEL]}" ]]
}

_write_log() {
    local formatted_message="$1"
    local level="$2"
    
    # Write to file if configured
    if [[ -n "$LOG_FILE" ]]; then
        echo "$formatted_message" >> "$LOG_FILE"
        
        # Rotate log if needed
        if [[ -f "$LOG_FILE" ]] && [[ "$(stat -f%z "$LOG_FILE" 2>/dev/null || stat -c%s "$LOG_FILE")" -gt $LOG_MAX_SIZE ]]; then
            rotate_logs
        fi
    fi
    
    # Always write to stderr for WARNING and above
    if [[ -n "$level" ]] && [[ -n "${LOG_LEVELS[$level]}" ]] && [[ -n "${LOG_LEVELS[WARNING]}" ]] && \
       [[ "${LOG_LEVELS[$level]}" -ge "${LOG_LEVELS[WARNING]}" ]]; then
        echo "$formatted_message" >&2
    fi
}

rotate_logs() {
    for i in $(seq $((LOG_BACKUP_COUNT-1)) -1 1); do
        [[ -f "${LOG_FILE}.$i" ]] && mv "${LOG_FILE}.$i" "${LOG_FILE}.$((i+1))"
    done
    [[ -f "$LOG_FILE" ]] && mv "$LOG_FILE" "${LOG_FILE}.1"
}

#===============================================================================
# PUBLIC LOGGING INTERFACE
#===============================================================================

log_debug() {
    local message="$1"
    local error_code="${2:-}"
    
    if _should_log "DEBUG"; then
        local formatted=$(_format_log_message "DEBUG" "$message" "$error_code")
        _write_log "$formatted" "DEBUG"
    fi
}

log_info() {
    local message="$1"
    local error_code="${2:-}"
    
    if _should_log "INFO"; then
        local formatted=$(_format_log_message "INFO" "$message" "$error_code")
        _write_log "$formatted" "INFO"
    fi
}

log_warning() {
    local message="$1"
    local error_code="${2:-}"
    
    if _should_log "WARNING"; then
        local formatted=$(_format_log_message "WARNING" "$message" "$error_code")
        _write_log "$formatted" "WARNING"
    fi
}

log_error() {
    local message="$1"
    local error_code="${2:-}"
    
    if _should_log "ERROR"; then
        local formatted=$(_format_log_message "ERROR" "$message" "$error_code")
        _write_log "$formatted" "ERROR"
    fi
}

log_critical() {
    local message="$1"
    local error_code="${2:-}"
    
    if _should_log "CRITICAL"; then
        local formatted=$(_format_log_message "CRITICAL" "$message" "$error_code")
        _write_log "$formatted" "CRITICAL"
    fi
}

log_section_header() {
    local section="$1"
    log_info "========== $section =========="
}

log_execution_time() {
    local start_time="$1"
    local operation="$2"
    local end_time=$(date +%s%3N)
    local duration=$((end_time - start_time))
    
    log_info "Operation '$operation' completed in ${duration}ms"
}

#===============================================================================
# CONTEXT MANAGEMENT
#===============================================================================

set_log_context() {
    LOG_CONTEXT="$1"
}

get_log_context() {
    echo "$LOG_CONTEXT"
}

#===============================================================================
# EXPORT FUNCTIONS
#===============================================================================

export LOG_LEVEL LOG_FILE LOG_CONTEXT
export -f init_logger set_log_level set_log_file
export -f log_debug log_info log_warning log_error log_critical
export -f log_section_header log_execution_time
export -f set_log_context get_log_context
