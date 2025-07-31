#!/bin/bash

#===============================================================================
# DEBUG JSON ISSUES - INFRASTRUCTURE LAYER
#===============================================================================

# Resolve caminhos absolutos
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" &> /dev/null && pwd)"
INFRASTRUCTURE_DIR="$SCRIPT_DIR/collectors/infrastructure_layer"

# Cores para output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Função para log colorido
log_info() { echo -e "${BLUE}[INFO]${NC} $1"; }
log_success() { echo -e "${GREEN}[SUCCESS]${NC} $1"; }
log_warning() { echo -e "${YELLOW}[WARNING]${NC} $1"; }
log_error() { echo -e "${RED}[ERROR]${NC} $1"; }

#===============================================================================
# FUNÇÕES DE DEBUG
#===============================================================================

debug_json_content() {
    local content="$1"
    local description="$2"
    
    log_info "=== DEBUG: $description ==="
    
    if [[ -z "$content" ]]; then
        log_error "Conteúdo vazio"
        return 1
    fi
    
    log_info "Tamanho do conteúdo: ${#content} caracteres"
    log_info "Primeiros 200 caracteres:"
    echo "${content:0:200}..."
    
    # Tenta validar com jq
    if echo "$content" | jq '.' >/dev/null 2>&1; then
        log_success "JSON válido"
        return 0
    else
        log_error "JSON inválido"
        log_info "Erro de validação:"
        echo "$content" | jq '.' 2>&1 | head -5
        return 1
    fi
}

debug_file_content() {
    local file="$1"
    local description="$2"
    
    log_info "=== DEBUG: $description ==="
    
    if [[ ! -f "$file" ]]; then
        log_error "Arquivo não encontrado: $file"
        return 1
    fi
    
    log_info "Arquivo: $file"
    log_info "Tamanho: $(stat -c%s "$file") bytes"
    
    # Mostra primeiras linhas
    log_info "Primeiras 10 linhas:"
    head -10 "$file"
    
    # Tenta validar JSON
    if jq '.' "$file" >/dev/null 2>&1; then
        log_success "Arquivo JSON válido"
        return 0
    else
        log_error "Arquivo JSON inválido"
        log_info "Erro de validação:"
        jq '.' "$file" 2>&1 | head -5
        return 1
    fi
}

debug_function_output() {
    local function_name="$1"
    local description="$2"
    
    log_info "=== DEBUG: $description ==="
    
    # Importa funções necessárias
    source "$INFRASTRUCTURE_DIR/main.sh" 2>/dev/null || {
        log_error "Falha ao importar main.sh"
        return 1
    }
    
    # Testa a função com dados de exemplo
    local test_docker='{"docker_daemon": {"status": "HEALTHY", "version": "24.0.7"}}'
    local test_container='{"status": "HEALTHY", "running_count": 8, "total_count": 8}'
    local test_resource='{"status": "HEALTHY", "cpu": {"usage": 45.2, "status": "HEALTHY"}}'
    local test_lifecycle='{"status": "HEALTHY", "lifecycle_checks": []}'
    local test_duration=1500
    
    local output
    if output=$($function_name "$test_docker" "$test_container" "$test_resource" "$test_lifecycle" "$test_duration" 2>&1); then
        debug_json_content "$output" "Saída da função $function_name"
    else
        log_error "Falha na execução da função $function_name"
        log_info "Erro: $output"
        return 1
    fi
}

#===============================================================================
# TESTES ESPECÍFICOS
#===============================================================================

test_docker_diagnostic() {
    log_info "=== TESTANDO DOCKER DIAGNOSTIC ==="
    
    if [[ -f "$INFRASTRUCTURE_DIR/docker_diagnostic.sh" ]]; then
        source "$INFRASTRUCTURE_DIR/docker_diagnostic.sh" 2>/dev/null || {
            log_error "Falha ao importar docker_diagnostic.sh"
            return 1
        }
        
        local output
        if output=$(run_docker_diagnostic 2>&1); then
            debug_json_content "$output" "Docker Diagnostic Output"
        else
            log_error "Docker diagnostic falhou"
            log_info "Erro: $output"
            return 1
        fi
    else
        log_error "docker_diagnostic.sh não encontrado"
        return 1
    fi
}

test_container_diagnostic() {
    log_info "=== TESTANDO CONTAINER DIAGNOSTIC ==="
    
    if [[ -f "$INFRASTRUCTURE_DIR/container_diagnostic.sh" ]]; then
        source "$INFRASTRUCTURE_DIR/container_diagnostic.sh" 2>/dev/null || {
            log_error "Falha ao importar container_diagnostic.sh"
            return 1
        }
        
        local output
        if output=$(run_container_diagnostic 2>&1); then
            debug_json_content "$output" "Container Diagnostic Output"
        else
            log_error "Container diagnostic falhou"
            log_info "Erro: $output"
            return 1
        fi
    else
        log_error "container_diagnostic.sh não encontrado"
        return 1
    fi
}

test_resource_monitoring() {
    log_info "=== TESTANDO RESOURCE MONITORING ==="
    
    if [[ -f "$INFRASTRUCTURE_DIR/resource_monitoring.sh" ]]; then
        source "$INFRASTRUCTURE_DIR/resource_monitoring.sh" 2>/dev/null || {
            log_error "Falha ao importar resource_monitoring.sh"
            return 1
        }
        
        local output
        if output=$(run_resource_monitoring 2>&1); then
            debug_json_content "$output" "Resource Monitoring Output"
        else
            log_error "Resource monitoring falhou"
            log_info "Erro: $output"
            return 1
        fi
    else
        log_error "resource_monitoring.sh não encontrado"
        return 1
    fi
}

test_container_lifecycle() {
    log_info "=== TESTANDO CONTAINER LIFECYCLE ==="
    
    if [[ -f "$INFRASTRUCTURE_DIR/container_lifecycle.sh" ]]; then
        source "$INFRASTRUCTURE_DIR/container_lifecycle.sh" 2>/dev/null || {
            log_error "Falha ao importar container_lifecycle.sh"
            return 1
        }
        
        local output
        if output=$(run_container_lifecycle 2>&1); then
            debug_json_content "$output" "Container Lifecycle Output"
        else
            log_error "Container lifecycle falhou"
            log_info "Erro: $output"
            return 1
        fi
    else
        log_error "container_lifecycle.sh não encontrado"
        return 1
    fi
}

test_output_handler() {
    log_info "=== TESTANDO OUTPUT HANDLER ==="
    
    if [[ -f "$SCRIPT_DIR/core/output_handler.sh" ]]; then
        source "$SCRIPT_DIR/core/output_handler.sh" 2>/dev/null || {
            log_error "Falha ao importar output_handler.sh"
            return 1
        }
        
        # Inicializa output handler
        if init_output_handler "debug"; then
            log_success "Output handler inicializado"
            
            # Testa geração de JSON
            local test_json='{"test": "data", "timestamp": "'$(date -u +"%Y-%m-%dT%H:%M:%SZ")'"}'
            
            if generate_results_json "$test_json"; then
                log_success "JSON gerado com sucesso"
                
                # Verifica arquivo gerado
                local output_file="$OUTPUT_DIR/debug_diagnostic.json"
                if [[ -f "$output_file" ]]; then
                    debug_file_content "$output_file" "Arquivo JSON gerado"
                else
                    log_error "Arquivo não foi criado"
                    return 1
                fi
            else
                log_error "Falha na geração de JSON"
                return 1
            fi
        else
            log_error "Falha na inicialização do output handler"
            return 1
        fi
    else
        log_error "output_handler.sh não encontrado"
        return 1
    fi
}

#===============================================================================
# EXECUÇÃO PRINCIPAL
#===============================================================================

main() {
    log_info "=== DEBUG JSON ISSUES - INFRASTRUCTURE LAYER ==="
    log_info "Diretório: $INFRASTRUCTURE_DIR"
    log_info "Timestamp: $(date)"
    echo ""
    
    local tests_passed=0
    local tests_failed=0
    
    # Teste 1: Docker Diagnostic
    if test_docker_diagnostic; then
        ((tests_passed++))
    else
        ((tests_failed++))
    fi
    echo ""
    
    # Teste 2: Container Diagnostic
    if test_container_diagnostic; then
        ((tests_passed++))
    else
        ((tests_failed++))
    fi
    echo ""
    
    # Teste 3: Resource Monitoring
    if test_resource_monitoring; then
        ((tests_passed++))
    else
        ((tests_failed++))
    fi
    echo ""
    
    # Teste 4: Container Lifecycle
    if test_container_lifecycle; then
        ((tests_passed++))
    else
        ((tests_failed++))
    fi
    echo ""
    
    # Teste 5: Output Handler
    if test_output_handler; then
        ((tests_passed++))
    else
        ((tests_failed++))
    fi
    echo ""
    
    # Teste 6: Função de geração de resultados
    if debug_function_output "generate_infrastructure_results_json" "Infrastructure Results JSON Generation"; then
        ((tests_passed++))
    else
        ((tests_failed++))
    fi
    echo ""
    
    # Relatório final
    log_info "=== RELATÓRIO DE DEBUG ==="
    log_info "Testes passaram: $tests_passed"
    log_info "Testes falharam: $tests_failed"
    log_info "Total de testes: $((tests_passed + tests_failed))"
    
    if [[ $tests_failed -eq 0 ]]; then
        log_success "Todos os testes passaram! JSON está funcionando corretamente."
        return 0
    else
        log_error "Alguns testes falharam. Verifique os logs acima para identificar problemas."
        return 1
    fi
}

# Executa main se chamado diretamente
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi 