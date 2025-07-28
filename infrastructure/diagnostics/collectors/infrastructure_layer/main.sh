#!/usr/bin/env bash

# Infrastructure Layer - Main File
# This file contains functions related to Docker and container checks

# Test Docker environment and connectivity
function test_docker_environment() {
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

# Test container status and health checks
function test_container_status() {
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

# Export functions to be available when sourced
export -f test_docker_environment
export -f test_container_status