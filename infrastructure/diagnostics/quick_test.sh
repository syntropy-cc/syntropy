#!/bin/bash

#===============================================================================
# TESTE RÁPIDO - INFRASTRUCTURE LAYER
#===============================================================================

# Resolve caminhos absolutos
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" &> /dev/null && pwd)"
INFRASTRUCTURE_DIR="$SCRIPT_DIR/collectors/infrastructure_layer"

echo "=== TESTE RÁPIDO - INFRASTRUCTURE LAYER ==="
echo "Diretório: $INFRASTRUCTURE_DIR"
echo "Timestamp: $(date)"
echo ""

# Verifica se o arquivo main.sh existe
if [[ ! -f "$INFRASTRUCTURE_DIR/main.sh" ]]; then
    echo "❌ ERRO: main.sh não encontrado em $INFRASTRUCTURE_DIR"
    exit 1
fi

echo "✅ main.sh encontrado"

# Verifica se o arquivo é executável
if [[ ! -x "$INFRASTRUCTURE_DIR/main.sh" ]]; then
    echo "⚠️  main.sh não é executável, tornando executável..."
    chmod +x "$INFRASTRUCTURE_DIR/main.sh"
fi

# Verifica dependências
echo ""
echo "=== VERIFICANDO DEPENDÊNCIAS ==="

# Verifica jq
if command -v jq >/dev/null 2>&1; then
    echo "✅ jq encontrado: $(jq --version)"
else
    echo "❌ jq não encontrado - necessário para validação JSON"
    exit 1
fi

# Verifica docker
if command -v docker >/dev/null 2>&1; then
    echo "✅ docker encontrado: $(docker --version)"
else
    echo "⚠️  docker não encontrado - alguns testes podem falhar"
fi

# Verifica bash version
BASH_VERSION_MAJOR="${BASH_VERSION%%.*}"
if [[ "$BASH_VERSION_MAJOR" -ge 4 ]]; then
    echo "✅ bash versão adequada: $BASH_VERSION"
else
    echo "❌ bash versão inadequada: $BASH_VERSION (necessário 4.0+)"
    exit 1
fi

# Verifica arquivos de configuração
echo ""
echo "=== VERIFICANDO CONFIGURAÇÃO ==="

if [[ -f "$INFRASTRUCTURE_DIR/config.json" ]]; then
    echo "✅ config.json encontrado"
    
    # Valida JSON do config
    if jq '.' "$INFRASTRUCTURE_DIR/config.json" >/dev/null 2>&1; then
        echo "✅ config.json é JSON válido"
    else
        echo "❌ config.json não é JSON válido"
        exit 1
    fi
else
    echo "❌ config.json não encontrado"
    exit 1
fi

# Verifica módulos de diagnóstico
echo ""
echo "=== VERIFICANDO MÓDULOS ==="

MODULES=("docker_diagnostic.sh" "container_diagnostic.sh" "resource_monitoring.sh" "container_lifecycle.sh")

for module in "${MODULES[@]}"; do
    if [[ -f "$INFRASTRUCTURE_DIR/$module" ]]; then
        echo "✅ $module encontrado"
    else
        echo "❌ $module não encontrado"
    fi
done

# Testa execução do main.sh
echo ""
echo "=== TESTANDO EXECUÇÃO ==="

# Executa com timeout para evitar travamento
if timeout 30s bash "$INFRASTRUCTURE_DIR/main.sh" >/dev/null 2>&1; then
    echo "✅ main.sh executou com sucesso"
else
    echo "❌ main.sh falhou na execução"
    echo ""
    echo "=== ÚLTIMAS LINHAS DO LOG ==="
    if [[ -d "$SCRIPT_DIR/outputs" ]]; then
        find "$SCRIPT_DIR/outputs" -name "*.log" -type f -exec tail -10 {} \; 2>/dev/null | head -20
    fi
    exit 1
fi

# Verifica se o arquivo JSON foi gerado
echo ""
echo "=== VERIFICANDO SAÍDA ==="

# Procura pelo arquivo JSON mais recente
LATEST_OUTPUT=$(find "$SCRIPT_DIR/outputs" -name "infrastructure_diagnostic.json" -type f -printf '%T@ %p\n' 2>/dev/null | sort -n | tail -1 | cut -d' ' -f2-)

if [[ -n "$LATEST_OUTPUT" ]] && [[ -f "$LATEST_OUTPUT" ]]; then
    echo "✅ infrastructure_diagnostic.json encontrado: $LATEST_OUTPUT"
    
    # Valida JSON
    if jq '.' "$LATEST_OUTPUT" >/dev/null 2>&1; then
        echo "✅ JSON é válido"
        
        # Mostra estrutura básica
        echo ""
        echo "=== ESTRUTURA DO JSON ==="
        jq -r '.metadata | "Layer: \(.layer), Version: \(.version), Status: \(.status)"' "$LATEST_OUTPUT" 2>/dev/null || echo "Estrutura não encontrada"
        
    else
        echo "❌ JSON não é válido"
        exit 1
    fi
else
    echo "❌ infrastructure_diagnostic.json não encontrado"
    exit 1
fi

echo ""
echo "=== TESTE CONCLUÍDO COM SUCESSO ==="
echo "O sistema de diagnóstico está funcionando corretamente!" 