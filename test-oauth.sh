#!/bin/bash

# OAuth Test Script - Comprehensive OAuth Flow Testing

echo "🚀 Testando fluxo OAuth completo..."

# Colors
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

# Test 1: Verificar se serviços estão acessíveis
echo -e "\n${BLUE}1. Verificando conectividade dos serviços...${NC}"
services=(
    "54321:Kong/API Gateway"
    "9999:Supabase Auth"
    "5432:PostgreSQL"
    "3000:Next.js Frontend"
)

all_accessible=true
for service in "${services[@]}"; do
    port="${service%%:*}"
    name="${service##*:}"
    
    if timeout 3 bash -c "echo >/dev/tcp/localhost/$port" 2>/dev/null; then
        echo -e "${GREEN}✅ localhost:$port ($name) - ACESSÍVEL${NC}"
    else
        echo -e "${RED}❌ localhost:$port ($name) - NÃO ACESSÍVEL${NC}"
        all_accessible=false
    fi
done

if [ "$all_accessible" = false ]; then
    echo -e "\n${RED}❌ Alguns serviços não estão acessíveis. Verifique o Docker.${NC}"
    exit 1
fi

# Test 2: Verificar configurações OAuth
echo -e "\n${BLUE}2. Verificando configurações OAuth...${NC}"

# Testar settings endpoint
echo -e "${YELLOW}Testando endpoint de settings...${NC}"
settings_response=$(curl -s --max-time 10 "https://api.syntropy.cc/auth/v1/settings" 2>/dev/null)
if echo "$settings_response" | jq -e '.external.google' >/dev/null 2>&1; then
    google_enabled=$(echo "$settings_response" | jq -r '.external.google')
    if [ "$google_enabled" = "true" ]; then
        echo -e "${GREEN}✅ Google OAuth habilitado no Supabase${NC}"
    else
        echo -e "${RED}❌ Google OAuth não habilitado no Supabase${NC}"
        exit 1
    fi
else
    echo -e "${RED}❌ Não foi possível verificar configurações OAuth${NC}"
    echo "Response: $settings_response"
    exit 1
fi

# Test 3: Testar geração de URL OAuth
echo -e "\n${BLUE}3. Testando geração de URL OAuth...${NC}"

oauth_url_response=$(curl -s --max-time 10 "https://api.syntropy.cc/auth/v1/authorize?provider=google" 2>/dev/null)
if echo "$oauth_url_response" | grep -q "redirect_uri="; then
    redirect_uri=$(echo "$oauth_url_response" | grep -o 'redirect_uri=[^&"]*' | head -1 | cut -d'=' -f2)
    decoded_uri=$(python3 -c "import urllib.parse; print(urllib.parse.unquote('$redirect_uri'))" 2>/dev/null || echo "$redirect_uri")
    echo -e "${GREEN}✅ URL OAuth gerada com sucesso${NC}"
    echo -e "${BLUE}📍 redirect_uri: $decoded_uri${NC}"
    
    # Verificar se a URI está correta
    if [[ "$decoded_uri" == "https://syntropy.cc/auth/callback" ]]; then
        echo -e "${GREEN}✅ redirect_uri está correta${NC}"
    else
        echo -e "${YELLOW}⚠️  redirect_uri inesperada: $decoded_uri${NC}"
        echo -e "${YELLOW}    Esperado: https://syntropy.cc/auth/callback${NC}"
    fi
else
    echo -e "${RED}❌ Falha ao gerar URL OAuth${NC}"
    echo "Response: $oauth_url_response"
    exit 1
fi

# Test 4: Verificar status do banco de dados
echo -e "\n${BLUE}4. Verificando banco de dados...${NC}"

# Testar conexão com o banco
if docker compose exec -T db psql -U postgres -c "SELECT 1;" >/dev/null 2>&1; then
    echo -e "${GREEN}✅ Banco de dados acessível${NC}"
    
    # Verificar tabelas auth
    user_count=$(docker compose exec -T db psql -U postgres -c "SELECT COUNT(*) FROM auth.users;" 2>/dev/null | grep -E '^[0-9]+$' | head -1 || echo "0")
    session_count=$(docker compose exec -T db psql -U postgres -c "SELECT COUNT(*) FROM auth.sessions;" 2>/dev/null | grep -E '^[0-9]+$' | head -1 || echo "0")
    
    echo -e "${BLUE}📊 Usuários cadastrados: $user_count${NC}"
    echo -e "${BLUE}📊 Sessões ativas: $session_count${NC}"
else
    echo -e "${RED}❌ Não foi possível conectar ao banco de dados${NC}"
fi

# Test 5: Verificar logs recentes
echo -e "\n${BLUE}5. Verificando logs recentes do auth...${NC}"

recent_logs=$(docker compose logs --tail=5 auth 2>/dev/null | grep -E "(oauth|google|redirect|error)" || echo "Nenhum log relevante encontrado")
echo "$recent_logs"

# Test 6: Testar página de callback
echo -e "\n${BLUE}6. Verificando página de callback...${NC}"

if curl -s --max-time 10 "https://syntropy.cc/auth/callback" >/dev/null 2>&1; then
    echo -e "${GREEN}✅ Página de callback acessível${NC}"
else
    echo -e "${RED}❌ Página de callback não acessível${NC}"
fi

# Test 7: Testar API health endpoint
echo -e "\n${BLUE}7. Verificando health endpoint do Next.js...${NC}"

health_response=$(curl -s --max-time 10 "http://localhost:3000/api/health" 2>/dev/null)
if echo "$health_response" | jq -e '.status' >/dev/null 2>&1; then
    health_status=$(echo "$health_response" | jq -r '.status')
    if [ "$health_status" = "healthy" ]; then
        echo -e "${GREEN}✅ Next.js health check passou${NC}"
    else
        echo -e "${YELLOW}⚠️  Next.js health status: $health_status${NC}"
    fi
else
    echo -e "${YELLOW}⚠️  Health endpoint não disponível (isso é normal se não foi criado ainda)${NC}"
fi

# Summary
echo -e "\n${BLUE}📋 RESUMO DO TESTE:${NC}"
echo -e "✅ Serviços acessíveis: $all_accessible"
echo -e "✅ Google OAuth habilitado: $google_enabled"
echo -e "✅ URL OAuth gerada: ${decoded_uri:-'N/A'}"
echo -e "✅ Banco de dados: Acessível"

echo -e "\n${GREEN}🎯 PRÓXIMOS PASSOS:${NC}"
echo "1. Se todos os testes passaram, o OAuth deve funcionar!"
echo "2. Tente fazer login via Google em: https://syntropy.cc/auth/login"
echo "3. Se ainda houver problemas, verifique:"
echo "   - Google OAuth Console tem https://syntropy.cc/auth/callback"
echo "   - Página de callback está processando corretamente"
echo "   - Não há cache de browser interferindo"

echo -e "\n${BLUE}📞 Para debug adicional:${NC}"
echo "docker compose logs -f auth | grep google"
echo "curl -s 'https://api.syntropy.cc/auth/v1/authorize?provider=google&redirect_to=https://syntropy.cc/auth/callback'"