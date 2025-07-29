#!/bin/bash

#===============================================================================
# SYSTEM UTILITIES
#===============================================================================

get_cpu_count() {
    nproc 2>/dev/null || echo "1"
}

get_load_average() {
    local minutes="${1:-1}"
    case "$minutes" in
        1) cut -d' ' -f1 /proc/loadavg ;;
        5) cut -d' ' -f2 /proc/loadavg ;;
        15) cut -d' ' -f3 /proc/loadavg ;;
        *) cut -d' ' -f1 /proc/loadavg ;;
    esac
}

get_memory_usage() {
    free | awk '/Mem:/ {printf "%.2f", $3/$2 * 100}'
}

get_disk_usage() {
    local mount_point="${1:-/}"
    df -h "$mount_point" | awk 'NR==2 {print $5}' | tr -d '%'
}

get_process_status() {
    local pid="$1"
    [[ -d "/proc/$pid" ]]
}

#===============================================================================
# NETWORK UTILITIES
#===============================================================================

is_port_open() {
    local host="$1"
    local port="$2"
    local timeout="${3:-5}"
    
    timeout "$timeout" bash -c ">/dev/tcp/$host/$port" 2>/dev/null
}

is_valid_url() {
    local url="$1"
    local regex='(https?|ftp|file)://[-[:alnum:]\+&@#/%?=~_|!:,.;]*[-[:alnum:]\+&@#/%=~_|]'
    [[ "$url" =~ $regex ]]
}

get_http_status() {
    local url="$1"
    local timeout="${2:-10}"
    curl -s -o /dev/null -w "%{http_code}" --connect-timeout "$timeout" "$url"
}

#===============================================================================
# FILE SYSTEM UTILITIES
#===============================================================================

ensure_directory() {
    local dir="$1"
    local mode="${2:-755}"
    
    if [[ ! -d "$dir" ]]; then
        mkdir -p "$dir" && chmod "$mode" "$dir"
        return $?
    fi
    return 0
}

cleanup_old_files() {
    local dir="$1"
    local pattern="$2"
    local days="${3:-7}"
    
    find "$dir" -name "$pattern" -type f -mtime +"$days" -delete
}

get_file_age() {
    local file="$1"
    local now=$(date +%s)
    local file_time=$(stat -c %Y "$file" 2>/dev/null || echo "$now")
    echo $((now - file_time))
}

#===============================================================================
# STRING UTILITIES
#===============================================================================

trim_string() {
    local var="$*"
    # remove leading whitespace characters
    var="${var#"${var%%[![:space:]]*}"}"
    # remove trailing whitespace characters
    var="${var%"${var##*[![:space:]]}"}"   
    echo "$var"
}

generate_uuid() {
    cat /proc/sys/kernel/random/uuid 2>/dev/null || 
    python -c 'import uuid; print(str(uuid.uuid4()))' 2>/dev/null ||
    date +%s%N
}

escape_string() {
    local str="$1"
    echo "$str" | sed 's/["\\/]/\\&/g'
}

#===============================================================================
# TIME UTILITIES
#===============================================================================

get_timestamp() {
    date +"%Y-%m-%dT%H:%M:%S.%3NZ"
}

execute_with_timeout() {
    local timeout="$1"
    local command="$2"
    local description="${3:-command}"
    
    local start_time=$(date +%s%3N)
    
    if timeout "$timeout" bash -c "$command" 2>/dev/null; then
        local end_time=$(date +%s%3N)
        local duration=$((end_time - start_time))
        return 0
    else
        local status=$?
        log_error "Command '$description' timed out after ${timeout}s" "TIMEOUT"
        return $status
    fi
}

#===============================================================================
# VERSION UTILITIES
#===============================================================================

version_gt() {
    local v1="$1"
    local v2="$2"
    
    if [[ "$(printf '%s\n' "$v1" "$v2" | sort -V | head -n1)" != "$v1" ]]; then
        return 0
    else
        return 1
    fi
}

version_gte() {
    local v1="$1"
    local v2="$2"
    
    if [[ "$(printf '%s\n' "$v1" "$v2" | sort -V | head -n1)" = "$v2" ]]; then
        return 0
    else
        return 1
    fi
}

#===============================================================================
# DOCKER UTILITIES
#===============================================================================

is_docker_running() {
    docker info >/dev/null 2>&1
}

get_container_status() {
    local container="$1"
    docker inspect --format='{{.State.Status}}' "$container" 2>/dev/null
}

get_container_health() {
    local container="$1"
    docker inspect --format='{{.State.Health.Status}}' "$container" 2>/dev/null
}

#===============================================================================
# EXPORT FUNCTIONS
#===============================================================================

# System utilities
export -f get_cpu_count get_load_average get_memory_usage get_disk_usage get_process_status

# Network utilities
export -f is_port_open is_valid_url get_http_status

# File system utilities
export -f ensure_directory cleanup_old_files get_file_age

# String utilities
export -f trim_string generate_uuid escape_string

# Time utilities
export -f get_timestamp execute_with_timeout

# Version utilities
export -f version_gt version_gte

# Docker utilities
export -f is_docker_running get_container_status get_container_health
