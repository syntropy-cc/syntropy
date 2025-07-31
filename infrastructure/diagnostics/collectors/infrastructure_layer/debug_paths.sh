#!/bin/bash

echo "=== DEBUG: Verificando estrutura de diretórios ==="
echo ""

# Mostra onde estamos
echo "1. Diretório atual:"
pwd
echo ""

# Calcula SCRIPT_DIR
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" &> /dev/null && pwd)"
echo "2. SCRIPT_DIR calculado:"
echo "   $SCRIPT_DIR"
echo ""

# Verifica conteúdo do SCRIPT_DIR
echo "3. Conteúdo do SCRIPT_DIR:"
ls -la "$SCRIPT_DIR"
echo ""

# Calcula CORE_DIR
CORE_DIR="$(cd "$SCRIPT_DIR/../../core" &> /dev/null && pwd)"
echo "4. CORE_DIR calculado:"
echo "   $CORE_DIR"
echo ""

# Verifica se CORE_DIR existe
if [[ -d "$CORE_DIR" ]]; then
    echo "5. CORE_DIR existe! Conteúdo:"
    ls -la "$CORE_DIR"
else
    echo "5. CORE_DIR NÃO EXISTE!"
    echo "   Tentando encontrar o diretório 'core'..."
    find "$SCRIPT_DIR/../.." -name "core" -type d 2>/dev/null
fi
echo ""

# Calcula ENV_FILE
ENV_FILE="$(cd "$SCRIPT_DIR/../../../../" &> /dev/null && pwd)/.env"
echo "6. ENV_FILE calculado:"
echo "   $ENV_FILE"
if [[ -f "$ENV_FILE" ]]; then
    echo "   ✅ Arquivo .env existe"
else
    echo "   ❌ Arquivo .env NÃO existe"
    echo "   Procurando arquivos .env..."
    find "$SCRIPT_DIR/../../../.." -name ".env" -type f 2>/dev/null | head -5
fi
echo ""

# Verifica arquivos de diagnóstico necessários
echo "7. Verificando arquivos de diagnóstico:"
files=("docker_diagnostic.sh" "container_diagnostic.sh" "resource_monitoring.sh" "container_lifecycle.sh" "config.json")

for file in "${files[@]}"; do
    if [[ -f "$SCRIPT_DIR/$file" ]]; then
        echo "   ✅ $file"
    else
        echo "   ❌ $file"
    fi
done
echo ""

# Mostra estrutura completa para entender melhor
echo "8. Estrutura de diretórios (3 níveis):"
tree "$SCRIPT_DIR/../.." -L 3 2>/dev/null || {
    echo "   (comando 'tree' não disponível, usando find)"
    find "$SCRIPT_DIR/../.." -maxdepth 3 -type d | sort
}
echo ""

echo "=== FIM DO DEBUG ==="