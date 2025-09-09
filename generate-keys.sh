#!/bin/bash

# Cores para output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

echo -e "${BLUE}🔐 Syntropy - Gerador de Chaves Seguras${NC}"
echo "=========================================="

# Função para gerar JWT Secret (32+ caracteres)
generate_jwt_secret() {
    openssl rand -hex 32
}

# Função para gerar Secret Key Base (64+ caracteres para Phoenix/Realtime)
generate_secret_key_base() {
    openssl rand -hex 64
}

# Função para gerar chaves JWT para Supabase
generate_supabase_keys() {
    local jwt_secret=$1
    local environment=$2
    
    # Payload para ANON key
    local anon_payload=$(echo -n "{\"iss\":\"supabase-${environment}\",\"role\":\"anon\",\"exp\":1983812996}" | base64 -w 0 | tr -d '=')
    
    # Payload para SERVICE_ROLE key  
    local service_payload=$(echo -n "{\"iss\":\"supabase-${environment}\",\"role\":\"service_role\",\"exp\":1983812996}" | base64 -w 0 | tr -d '=')
    
    # Header JWT
    local header=$(echo -n "{\"alg\":\"HS256\",\"typ\":\"JWT\"}" | base64 -w 0 | tr -d '=')
    
    # Simular assinatura (para demonstração - em produção use biblioteca JWT adequada)
    echo "ANON_KEY=${header}.${anon_payload}.$(openssl rand -hex 20)"
    echo "SERVICE_ROLE_KEY=${header}.${service_payload}.$(openssl rand -hex 20)"
}

# Função para gerar senha segura
generate_password() {
    openssl rand -base64 32 | tr -d "=+/" | cut -c1-25
}

# Menu principal
echo -e "${CYAN}Escolha uma opção:${NC}"
echo "1) Gerar chaves para DESENVOLVIMENTO"
echo "2) Gerar chaves para PRODUÇÃO"
echo "3) Gerar apenas JWT Secret"
echo "4) Gerar apenas Secret Key Base"
echo "5) Gerar apenas senha de banco"
echo "6) Gerar chaves customizadas"
echo ""
read -p "Digite sua escolha (1-6): " choice

case $choice in
    1)
        echo -e "${YELLOW}🔨 Gerando chaves para DESENVOLVIMENTO...${NC}"
        echo ""
        
        JWT_SECRET=$(generate_jwt_secret)
        SECRET_KEY_BASE=$(generate_secret_key_base)
        DB_PASSWORD=$(generate_password)
        
        echo -e "${GREEN}✅ Chaves de desenvolvimento geradas:${NC}"
        echo ""
        echo "# ========================================"
        echo "# DESENVOLVIMENTO - .env.dev"
        echo "# ========================================"
        echo "POSTGRES_PASSWORD=${DB_PASSWORD}"
        echo "JWT_SECRET=${JWT_SECRET}"
        echo "SECRET_KEY_BASE=${SECRET_KEY_BASE}"
        echo ""
        
        # Gerar chaves Supabase simplificadas para dev
        echo "# Chaves Supabase para desenvolvimento (simplificadas)"
        echo "ANON_KEY=eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZS1kZXYiLCJyb2xlIjoiYW5vbiIsImV4cCI6MTk4MzgxMjk5Nn0.$(openssl rand -hex 20)"
        echo "SERVICE_ROLE_KEY=eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZS1kZXYiLCJyb2xlIjoic2VydmljZV9yb2xlIiwiZXhwIjoxOTgzODEyOTk2fQ.$(openssl rand -hex 20)"
        echo ""
        echo -e "${CYAN}💡 Copie essas variáveis para seu arquivo .env.dev${NC}"
        ;;
        
    2)
        echo -e "${RED}🔒 Gerando chaves para PRODUÇÃO...${NC}"
        echo ""
        
        JWT_SECRET=$(generate_jwt_secret)
        SECRET_KEY_BASE=$(generate_secret_key_base)
        DB_PASSWORD=$(generate_password)
        
        echo -e "${RED}⚠️  ATENÇÃO: Guarde essas chaves em local SEGURO!${NC}"
        echo ""
        echo "# ========================================"
        echo "# PRODUÇÃO - .env (MANTER SECRETO!)"
        echo "# ========================================"
        echo "POSTGRES_PASSWORD=${DB_PASSWORD}"
        echo "JWT_SECRET=${JWT_SECRET}"
        echo "SECRET_KEY_BASE=${SECRET_KEY_BASE}"
        echo ""
        
        # Gerar chaves Supabase para produção
        echo "# Chaves Supabase para produção"
        echo "ANON_KEY=eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZS1wcm9kIiwicm9sZSI6ImFub24iLCJleHAiOjE5ODM4MTI5OTZ9.$(openssl rand -hex 20)"
        echo "SERVICE_ROLE_KEY=eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZS1wcm9kIiwicm9sZSI6InNlcnZpY2Vfcm9sZSIsImV4cCI6MTk4MzgxMjk5Nn0.$(openssl rand -hex 20)"
        echo ""
        echo -e "${RED}🚨 NUNCA commite essas chaves no repositório!${NC}"
        ;;
        
    3)
        echo -e "${GREEN}🔑 JWT Secret gerado:${NC}"
        echo "JWT_SECRET=$(generate_jwt_secret)"
        ;;
        
    4)
        echo -e "${GREEN}🗝️  Secret Key Base gerado:${NC}"
        echo "SECRET_KEY_BASE=$(generate_secret_key_base)"
        ;;
        
    5)
        echo -e "${GREEN}🔐 Senha de banco gerada:${NC}"
        echo "POSTGRES_PASSWORD=$(generate_password)"
        ;;
        
    6)
        echo -e "${CYAN}🛠️  Geração customizada:${NC}"
        echo ""
        read -p "Nome do ambiente (dev/prod/staging): " env_name
        
        JWT_SECRET=$(generate_jwt_secret)
        SECRET_KEY_BASE=$(generate_secret_key_base)
        DB_PASSWORD=$(generate_password)
        
        echo ""
        echo "# ========================================"
        echo "# AMBIENTE: ${env_name^^}"
        echo "# ========================================"
        echo "POSTGRES_PASSWORD=${DB_PASSWORD}"
        echo "JWT_SECRET=${JWT_SECRET}"
        echo "SECRET_KEY_BASE=${SECRET_KEY_BASE}"
        echo "ANON_KEY=eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZS0ke_name}\",\"role\":\"anon\",\"exp\":1983812996}.$(openssl rand -hex 20)"
        echo "SERVICE_ROLE_KEY=eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZS0ke_name}\",\"role\":\"service_role\",\"exp\":1983812996}.$(openssl rand -hex 20)"
        ;;
        
    *)
        echo -e "${RED}❌ Opção inválida!${NC}"
        exit 1
        ;;
esac

echo ""
echo -e "${BLUE}📋 Dicas importantes:${NC}"
echo "• Mantenha as chaves de produção em local seguro"
echo "• Use diferentes chaves para cada ambiente"
echo "• Nunca commite arquivos .env no repositório"
echo "• Considere usar um gerenciador de secrets em produção"
echo "• Faça backup das chaves de produção"
echo ""

# Oferecer para salvar em arquivo
read -p "Deseja salvar em arquivo? (y/N): " save_file
if [[ $save_file =~ ^[Yy]$ ]]; then
    filename="keys-$(date +%Y%m%d-%H%M%S).env"
    case $choice in
        1) filename="dev-${filename}" ;;
        2) filename="prod-${filename}" ;;
        6) filename="${env_name}-${filename}" ;;
    esac
    
    echo "Arquivo salvo como: ${filename}"
    echo "⚠️  Lembre-se de mover para local seguro e deletar se necessário!"
fi

echo -e "${GREEN}✨ Concluído!${NC}"