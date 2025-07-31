#!/bin/bash

#===============================================================================
# TESTE DE GERAÇÃO DE JSON - INFRASTRUCTURE LAYER
#===============================================================================

# Resolve caminhos absolutos
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" &> /dev/null && pwd)"
INFRASTRUCTURE_DIR="$SCRIPT_DIR/collectors/infrastructure_layer"

# Importa dependências
source "$SCRIPT_DIR/core/logger.sh" || exit 1
source "$SCRIPT_DIR/core/output_handler.sh" || exit 1

# Configuração de teste
TIMESTAMP="$(date +%Y%m%d_%H%M%S)"
TEST_OUTPUT_DIR="$SCRIPT_DIR/outputs/test_${TIMESTAMP}"

#===============================================================================
# FUNÇÕES DE TESTE
#===============================================================================

test_json_validation() {
    local test_name="$1"
    local json_content="$2"
    
    log_info "Testing: $test_name"
    
    if echo "$json_content" | jq '.' >/dev/null 2>&1; then
        log_info "✓ $test_name: JSON válido"
        return 0
    else
        log_error "✗ $test_name: JSON inválido"
        log_debug "JSON content: $json_content"
        return 1
    fi
}

test_file_generation() {
    local test_name="$1"
    local content="$2"
    local filename="$3"
    
    log_info "Testing: $test_name"
    
    if echo "$content" | jq '.' > "$filename" 2>/dev/null; then
        log_info "✓ $test_name: Arquivo gerado com sucesso"
        return 0
    else
        log_error "✗ $test_name: Falha na geração do arquivo"
        return 1
    fi
}

#===============================================================================
# TESTES ESPECÍFICOS
#===============================================================================

test_docker_diagnostic_json() {
    log_info "=== Testando JSON do Docker Diagnostic ==="
    
    # Simula JSON do Docker
    local docker_json='{"docker_daemon": {"status": "HEALTHY", "version": "24.0.7"}, "docker_compose": {"available": true, "version": "2.20.3"}}'
    
    test_json_validation "Docker Diagnostic JSON" "$docker_json"
}

test_container_diagnostic_json() {
    log_info "=== Testando JSON do Container Diagnostic ==="
    
    # Simula JSON do Container
    local container_json='{"status": "HEALTHY", "running_count": 8, "total_count": 8, "containers": []}'
    
    test_json_validation "Container Diagnostic JSON" "$container_json"
}

test_resource_monitoring_json() {
    log_info "=== Testando JSON do Resource Monitoring ==="
    
    # Simula JSON do Resource Monitoring
    local resource_json='{"status": "HEALTHY", "cpu": {"usage": 45.2, "status": "HEALTHY"}, "memory": {"usage_percent": 67.8, "status": "HEALTHY"}}'
    
    test_json_validation "Resource Monitoring JSON" "$resource_json"
}

test_lifecycle_diagnostic_json() {
    log_info "=== Testando JSON do Lifecycle Diagnostic ==="
    
    # Simula JSON do Lifecycle
    local lifecycle_json='{"status": "HEALTHY", "lifecycle_checks": [], "summary": {"total_containers": 8, "healthy_containers": 8}}'
    
    test_json_validation "Lifecycle Diagnostic JSON" "$lifecycle_json"
}

test_infrastructure_results_json() {
    log_info "=== Testando JSON Final da Infrastructure ==="
    
    # Importa a função do main.sh
    source "$INFRASTRUCTURE_DIR/main.sh" 2>/dev/null || {
        log_error "Failed to source main.sh"
        return 1
    }
    
    # Dados de teste
    local docker_status='{"docker_daemon": {"status": "HEALTHY", "version": "24.0.7"}}'
    local container_status='{"status": "HEALTHY", "running_count": 8, "total_count": 8}'
    local resource_status='{"status": "HEALTHY", "cpu": {"usage": 45.2, "status": "HEALTHY"}}'
    local lifecycle_status='{"status": "HEALTHY", "lifecycle_checks": []}'
    local duration=1500
    
    # Testa a função
    local result
    if result=$(generate_infrastructure_results_json "$docker_status" "$container_status" "$resource_status" "$lifecycle_status" "$duration" 2>&1); then
        test_json_validation "Infrastructure Results JSON" "$result"
        test_file_generation "Infrastructure Results File" "$result" "$TEST_OUTPUT_DIR/infrastructure_test.json"
    else
        log_error "Failed to generate infrastructure results JSON"
        return 1
    fi
}

test_output_handler() {
    log_info "=== Testando Output Handler ==="
    
    # Inicializa output handler
    if init_output_handler "test"; then
        log_info "✓ Output handler initialized"
        
        # Testa geração de JSON
        local test_json='{"test": "data", "timestamp": "'$(date -u +"%Y-%m-%dT%H:%M:%SZ")'"}'
        
        if generate_results_json "$test_json"; then
            log_info "✓ Output handler JSON generation successful"
            return 0
        else
            log_error "✗ Output handler JSON generation failed"
            return 1
        fi
    else
        log_error "✗ Failed to initialize output handler"
        return 1
    fi
}

#===============================================================================
# EXECUÇÃO DOS TESTES
#===============================================================================

main() {
    log_info "Iniciando testes de geração de JSON"
    
    # Cria diretório de teste
    mkdir -p "$TEST_OUTPUT_DIR"
    
    # Executa testes
    local tests_passed=0
    local tests_failed=0
    
    # Teste 1: Docker Diagnostic
    if test_docker_diagnostic_json; then
        ((tests_passed++))
    else
        ((tests_failed++))
    fi
    
    # Teste 2: Container Diagnostic
    if test_container_diagnostic_json; then
        ((tests_passed++))
    else
        ((tests_failed++))
    fi
    
    # Teste 3: Resource Monitoring
    if test_resource_monitoring_json; then
        ((tests_passed++))
    else
        ((tests_failed++))
    fi
    
    # Teste 4: Lifecycle Diagnostic
    if test_lifecycle_diagnostic_json; then
        ((tests_passed++))
    else
        ((tests_failed++))
    fi
    
    # Teste 5: Infrastructure Results
    if test_infrastructure_results_json; then
        ((tests_passed++))
    else
        ((tests_failed++))
    fi
    
    # Teste 6: Output Handler
    if test_output_handler; then
        ((tests_passed++))
    else
        ((tests_failed++))
    fi
    
    # Relatório final
    log_info "=== RELATÓRIO DE TESTES ==="
    log_info "Testes passaram: $tests_passed"
    log_info "Testes falharam: $tests_failed"
    log_info "Total de testes: $((tests_passed + tests_failed))"
    
    if [[ $tests_failed -eq 0 ]]; then
        log_info "✓ Todos os testes passaram!"
        return 0
    else
        log_error "✗ Alguns testes falharam"
        return 1
    fi
}

# Executa main se chamado diretamente
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi 