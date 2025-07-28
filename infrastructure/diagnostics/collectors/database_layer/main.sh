#!/usr/bin/env bash

# Database Layer - Main File
# This file contains functions related to database connectivity and schema verification

# Test database connectivity
function test_database_connectivity() {
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

# Test database schema and roles
function test_database_schema() {
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

# Export functions to be available when sourced
export -f test_database_connectivity
export -f test_database_schema