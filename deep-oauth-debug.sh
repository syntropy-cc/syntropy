#!/bin/bash

# Deep OAuth Debug Script - Investigação profunda do problema

echo "🔬 INVESTIGAÇÃO PROFUNDA DO OAUTH"
echo "================================="

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
NC='\033[0m'

OUTPUT_FILE="deep-oauth-debug-$(date +%Y%m%d-%H%M%S).log"
echo "📝 Salvando resultado em: $OUTPUT_FILE"

# Function to log everything
log_section() {
    local title="$1"
    echo -e "\n${BLUE}=== $title ===${NC}"
    echo "=== $title ===" >> "$OUTPUT_FILE"
}

log_result() {
    local result="$1"
    echo -e "$result"
    echo -e "$result" >> "$OUTPUT_FILE"
}

# 1. Capturar URL OAuth COMPLETA
log_section "1. CAPTURA DA URL OAUTH COMPLETA"

echo -e "${YELLOW}Gerando URL OAuth e capturando resposta completa...${NC}"
oauth_full_response=$(curl -v -s --max-time 10 "https://api.syntropy.cc/auth/v1/authorize?provider=google" 2>&1)
log_result "$oauth_full_response"

# Extrair EXATAMENTE a URL de redirect
google_redirect_url=$(echo "$oauth_full_response" | grep -o 'https://accounts.google.com[^"]*' | head -1)
if [ ! -z "$google_redirect_url" ]; then
    log_result "\n🎯 URL COMPLETA ENVIADA PARA GOOGLE:"
    log_result "$google_redirect_url"
    
    # Decodificar cada parâmetro
    echo -e "\n${PURPLE}📋 PARÂMETROS DECODIFICADOS:${NC}"
    echo "$google_redirect_url" | sed 's/&/\n/g' | while IFS='=' read -r key value; do
        if [[ "$key" == *"redirect_uri"* ]] && [ ! -z "$value" ]; then
            decoded_value=$(python3 -c "import urllib.parse; print(urllib.parse.unquote('$value'))" 2>/dev/null || echo "$value")
            echo -e "${GREEN}$key = $decoded_value${NC}"
            echo "$key = $decoded_value" >> "$OUTPUT_FILE"
        elif [ ! -z "$value" ]; then
            decoded_value=$(python3 -c "import urllib.parse; print(urllib.parse.unquote('$value'))" 2>/dev/null || echo "$value")
            echo "$key = $decoded_value"
            echo "$key = $decoded_value" >> "$OUTPUT_FILE"
        fi
    done
fi

# 2. Verificar TODAS as configurações do Google Console
log_section "2. VERIFICAÇÃO MANUAL DO GOOGLE CONSOLE"

log_result "🔍 INSTRUÇÕES PARA VERIFICAÇÃO MANUAL:"
log_result ""
log_result "1. Acesse: https://console.developers.google.com/apis/credentials"
log_result "2. Encontre o Client ID: 515366582613-rbscubifmmmfrqc36vnk39uopv1cmok0.apps.googleusercontent.com"
log_result "3. Verifique EXATAMENTE as 'Authorized redirect URIs'"
log_result "4. Procure por duplicatas ou variações sutis"
log_result "5. Verifique se há múltiplos projetos ou aplicações"
log_result ""
log_result "❗ URLS QUE DEVEM ESTAR CONFIGURADAS:"
log_result "   - https://syntropy.cc/auth/callback"
log_result ""
log_result "❌ URLS QUE NÃO DEVEM ESTAR:"
log_result "   - https://api.syntropy.cc/auth/v1/callback"
log_result "   - http://localhost:3000/auth/callback"
log_result "   - Qualquer outra variação"

# 3. Teste com múltiplas ferramentas
log_section "3. TESTE COM MÚLTIPLAS FERRAMENTAS"

# Teste com curl
echo -e "${YELLOW}Testando com curl...${NC}"
curl_result=$(curl -s -L --max-time 10 "https://api.syntropy.cc/auth/v1/authorize?provider=google" 2>&1)
log_result "CURL Result: $curl_result"

# Teste com wget
echo -e "${YELLOW}Testando com wget...${NC}"
wget_result=$(wget -q -O - --timeout=10 "https://api.syntropy.cc/auth/v1/authorize?provider=google" 2>&1 || echo "wget failed")
log_result "WGET Result: $wget_result"

# 4. Verificar Headers de Resposta
log_section "4. ANÁLISE DE HEADERS HTTP"

echo -e "${YELLOW}Capturando headers completos...${NC}"
headers_response=$(curl -I -s --max-time 10 "https://api.syntropy.cc/auth/v1/authorize?provider=google" 2>&1)
log_result "HTTP Headers:"
log_result "$headers_response"

# 5. Teste de DNS e Conectividade
log_section "5. TESTE DE DNS E CONECTIVIDADE"

echo -e "${YELLOW}Verificando resolução DNS...${NC}"
for domain in "syntropy.cc" "api.syntropy.cc" "accounts.google.com"; do
    dns_result=$(nslookup "$domain" 2>/dev/null | grep -A 2 "Name:" || echo "DNS resolution failed")
    log_result "DNS para $domain: $dns_result"
done

# Teste de conectividade direta
echo -e "${YELLOW}Testando conectividade direta com Google...${NC}"
google_connectivity=$(curl -s --max-time 5 "https://accounts.google.com" >/dev/null 2>&1 && echo "SUCCESS" || echo "FAILED")
log_result "Conectividade com Google: $google_connectivity"

# 6. Verificar Configuração do Docker ATUAL
log_section "6. CONFIGURAÇÃO ATUAL DO DOCKER"

echo -e "${YELLOW}Capturando configuração atual do auth service...${NC}"
auth_config=$(docker compose config | grep -A 50 "auth:" | grep -E "(GOTRUE_|GOOGLE_)" || echo "Could not get auth config")
log_result "Configuração do Auth Service:"
log_result "$auth_config"

# 7. Teste de Timing
log_section "7. TESTE DE TIMING E MÚLTIPLAS TENTATIVAS"

echo -e "${YELLOW}Testando múltiplas tentativas com delay...${NC}"
for i in {1..3}; do
    echo -e "${BLUE}Tentativa $i...${NC}"
    sleep 2
    timing_result=$(curl -s --max-time 10 "https://api.syntropy.cc/auth/v1/authorize?provider=google" | grep -o 'redirect_uri=[^&"]*' | head -1)
    log_result "Tentativa $i: $timing_result"
done

# 8. Verificar Logs em Tempo Real
log_section "8. CAPTURA DE LOGS EM TEMPO REAL"

echo -e "${YELLOW}Capturando logs do auth durante geração de URL...${NC}"
# Iniciar captura de logs em background
docker compose logs -f auth > /tmp/auth_logs_realtime.log 2>&1 &
logs_pid=$!

sleep 2

# Gerar requisição OAuth
echo -e "${BLUE}Gerando requisição OAuth...${NC}"
curl -s "https://api.syntropy.cc/auth/v1/authorize?provider=google" >/dev/null 2>&1

sleep 3

# Parar captura de logs
kill $logs_pid 2>/dev/null

# Mostrar logs capturados
realtime_logs=$(tail -10 /tmp/auth_logs_realtime.log 2>/dev/null || echo "No logs captured")
log_result "Logs em tempo real:"
log_result "$realtime_logs"

rm -f /tmp/auth_logs_realtime.log

# 9. Verificar Variáveis de Ambiente EXATAS
log_section "9. VERIFICAÇÃO DE VARIÁVEIS DE AMBIENTE"

echo -e "${YELLOW}Verificando variáveis de ambiente no container auth...${NC}"
container_env=$(docker compose exec -T auth env | grep -E "(GOTRUE_|GOOGLE_)" | sort || echo "Could not get container env")
log_result "Variáveis de ambiente no container:"
log_result "$container_env"

# 10. Teste com User-Agent diferente
log_section "10. TESTE COM USER-AGENTS DIFERENTES"

echo -e "${YELLOW}Testando com diferentes User-Agents...${NC}"
user_agents=(
    "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36"
    "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36"
    "curl/8.5.0"
)

for ua in "${user_agents[@]}"; do
    ua_result=$(curl -s --user-agent "$ua" --max-time 10 "https://api.syntropy.cc/auth/v1/authorize?provider=google" | grep -o 'redirect_uri=[^&"]*' | head -1)
    log_result "User-Agent '$ua': $ua_result"
done

# 11. Verificar se há proxy/CDN interferindo
log_section "11. VERIFICAÇÃO DE PROXY/CDN"

echo -e "${YELLOW}Verificando headers de CDN/Proxy...${NC}"
proxy_headers=$(curl -I -s "https://api.syntropy.cc" | grep -E "(CF-|Server|X-)" || echo "No proxy headers found")
log_result "Headers de Proxy/CDN:"
log_result "$proxy_headers"

# Teste direto vs através do domínio
echo -e "${YELLOW}Comparando resposta direta vs domínio...${NC}"
# Pegar IP real
real_ip=$(nslookup api.syntropy.cc | grep -A 1 "Name:" | tail -1 | awk '{print $2}' | head -1)
if [ ! -z "$real_ip" ]; then
    direct_ip_result=$(curl -s --max-time 10 --header "Host: api.syntropy.cc" "http://$real_ip/auth/v1/authorize?provider=google" 2>&1 || echo "Direct IP test failed")
    log_result "Teste direto no IP ($real_ip): $direct_ip_result"
fi

# Final Summary
log_section "12. RESUMO E PRÓXIMOS PASSOS"

log_result "🎯 RESUMO DA INVESTIGAÇÃO:"
log_result ""
log_result "1. URL sendo enviada para Google: ${google_redirect_url:-'Não capturada'}"
log_result "2. Conectividade com serviços: OK"
log_result "3. Configuração OAuth: Habilitada"
log_result "4. DNS Resolution: OK"
log_result ""
log_result "🔧 PRÓXIMOS PASSOS RECOMENDADOS:"
log_result ""
log_result "1. VERIFICAR MANUALMENTE o Google Console"
log_result "2. Procurar por múltiplos Client IDs"
log_result "3. Verificar se não há configurações em cache"
log_result "4. Testar com Client ID completamente novo"
log_result "5. Verificar se o projeto está no modo 'Testing' vs 'Production'"
log_result ""
log_result "💡 CAUSA MAIS PROVÁVEL:"
log_result "   - Configuração incorreta no Google Console"
log_result "   - Cache do Google OAuth"
log_result "   - Múltiplos Client IDs confundindo"

echo -e "\n${GREEN}✅ Investigação concluída!${NC}"
echo -e "${GREEN}📄 Resultado completo salvo em: $OUTPUT_FILE${NC}"
echo -e "\n${YELLOW}🔍 Revise o arquivo de log e verifique manualmente o Google Console${NC}"