#!/bin/bash

#===============================================================================
# TESTE DO OUTPUT HANDLER
#===============================================================================

# Resolve caminhos absolutos
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" &> /dev/null && pwd)"
CORE_DIR="$SCRIPT_DIR/core"

# Importa dependências
source "$CORE_DIR/logger.sh" || exit 1
source "$CORE_DIR/utils.sh" || exit 1
source "$CORE_DIR/output_handler.sh" || exit 1

#===============================================================================
# FUNÇÃO DE TESTE
#===============================================================================

test_output_handler() {
    echo "=== Testando Output Handler ==="
    
    # Testa inicialização do output handler
    echo "1. Testando init_output_handler..."
    if init_output_handler "test_layer"; then
        echo "   ✓ Output handler inicializado com sucesso"
        echo "   - OUTPUT_DIR: $OUTPUT_DIR"
        echo "   - LOGS_DIR: $(get_logs_dir)"
        echo "   - LAYER_NAME: $LAYER_NAME"
        echo "   - TIMESTAMP: $TIMESTAMP"
    else
        echo "   ✗ Falha ao inicializar output handler"
        return 1
    fi
    
    # Verifica se os diretórios foram criados
    echo "2. Verificando criação de diretórios..."
    if [[ -d "$OUTPUT_DIR" ]]; then
        echo "   ✓ Output directory criado: $OUTPUT_DIR"
    else
        echo "   ✗ Output directory não foi criado: $OUTPUT_DIR"
        return 1
    fi
    
    if [[ -d "$(get_logs_dir)" ]]; then
        echo "   ✓ Logs directory criado: $(get_logs_dir)"
    else
        echo "   ✗ Logs directory não foi criado: $(get_logs_dir)"
        return 1
    fi
    
    # Testa inicialização do logger
    echo "3. Testando init_logger..."
    if init_logger "$LAYER_NAME" "$TIMESTAMP" "$(get_logs_dir)"; then
        echo "   ✓ Logger inicializado com sucesso"
        echo "   - LOG_FILE: $LOG_FILE"
    else
        echo "   ✗ Falha ao inicializar logger"
        return 1
    fi
    
    # Testa geração de arquivos
    echo "4. Testando geração de arquivos..."
    
    # Testa generate_summary_md
    if generate_summary_md "Test Report" "This is a test content"; then
        echo "   ✓ infrastructure_summary.md gerado com sucesso"
    else
        echo "   ✗ Falha ao gerar infrastructure_summary.md"
        return 1
    fi
    
    # Testa generate_results_json
    local test_json='{"test": "data", "status": "success"}'
    if generate_results_json "$test_json"; then
        echo "   ✓ infrastructure_diagnostic.json gerado com sucesso"
    else
        echo "   ✗ Falha ao gerar infrastructure_diagnostic.json"
        return 1
    fi
    
    # Testa copy_detailed_log
    echo "Test log content" > "$(get_logs_dir)/test.log"
    if copy_detailed_log "$(get_logs_dir)/test.log"; then
        echo "   ✓ infrastructure_detailed.log copiado com sucesso"
    else
        echo "   ✗ Falha ao copiar infrastructure_detailed.log"
        return 1
    fi
    
    echo "5. Verificando arquivos gerados..."
    local files_created=0
    [[ -f "$OUTPUT_DIR/${LAYER_NAME}_summary.md" ]] && ((files_created++))
    [[ -f "$OUTPUT_DIR/${LAYER_NAME}_diagnostic.json" ]] && ((files_created++))
    [[ -f "$OUTPUT_DIR/${LAYER_NAME}_detailed.log" ]] && ((files_created++))
    
    echo "   ✓ $files_created arquivos criados no diretório de output"
    
    echo "=== Teste concluído com sucesso ==="
    return 0
}

#===============================================================================
# EXECUÇÃO
#===============================================================================

main() {
    echo "Iniciando teste do Output Handler..."
    echo "Base directory: $DIAGNOSTIC_BASE_DIR"
    echo ""
    
    if test_output_handler; then
        echo ""
        echo "✓ Todos os testes passaram!"
        echo "Arquivos criados em: $OUTPUT_DIR"
        return 0
    else
        echo ""
        echo "✗ Alguns testes falharam!"
        return 1
    fi
}

# Executa main se chamado diretamente
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi 