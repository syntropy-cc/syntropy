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
    openssl rand -hex 32  # 32 bytes = 64 caracteres hex
}

# Função para gerar Secret Key Base (64+ caracteres para Phoenix/Realtime)
generate_secret_key_base() {
    openssl rand -hex 64  # 64 bytes = 128 caracteres hex
}

# Função para gerar chaves JWT para Supabase
generate_supabase_keys() {
    local jwt_secret=$1
    local environment=$2
    
    # Header JWT padrão
    local header='{"alg":"HS256","typ":"JWT"}'
    local header_b64=$(echo -n "$header" | base64 | tr -d '=' | tr '/+' '_-' | tr -d '\n')
    
    # Payload para ANON key
    local anon_payload="{\"iss\":\"supabase-${environment}\",\"role\":\"anon\",\"exp\":1983812996}"
    local anon_payload_b64=$(echo -n "$anon_payload" | base64 | tr -d '=' | tr '/+' '_-' | tr -d '\n')
    
    # Payload para SERVICE_ROLE key  
    local service_payload="{\"iss\":\"supabase-${environment}\",\"role\":\"service_role\",\"exp\":1983812996}"
    local service_payload_b64=$(echo -n "$service_payload" | base64 | tr -d '=' | tr '/+' '_-' | tr -d '\n')
    
    # Gerar assinaturas (sem quebras de linha)
    local anon_signature=$(echo -n "${header_b64}.${anon_payload_b64}" | openssl dgst -sha256 -hmac "$jwt_secret" -binary | base64 | tr -d '=' | tr '/+' '_-' | tr -d '\n')
    local service_signature=$(echo -n "${header_b64}.${service_payload_b64}" | openssl dgst -sha256 -hmac "$jwt_secret" -binary | base64 | tr -d '=' | tr '/+' '_-' | tr -d '\n')
    
    # Retornar chaves em linhas separadas SEM quebras internas
    printf "ANON_KEY=%s.%s.%s\n" "$header_b64" "$anon_payload_b64" "$anon_signature"
    printf "SERVICE_ROLE_KEY=%s.%s.%s" "$header_b64" "$service_payload_b64" "$service_signature"
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
        
        # Gerar chaves (SEM MOSTRAR)
        JWT_SECRET=$(generate_jwt_secret)
        SECRET_KEY_BASE=$(generate_secret_key_base)
        DB_PASSWORD=$(generate_password)
        
        # Criar conteúdo do arquivo .env.dev
        ENV_CONTENT="# ==========================================
# DESENVOLVIMENTO - .env.dev
# ==========================================
# Gerado em: $(date)

# Database
POSTGRES_PASSWORD=${DB_PASSWORD}

# JWT e Keys (APENAS PARA DESENVOLVIMENTO)
JWT_SECRET=${JWT_SECRET}
SECRET_KEY_BASE=${SECRET_KEY_BASE}

# Realtime
APP_NAME=Syntropy-Dev

# URLs de desenvolvimento
API_EXTERNAL_URL=http://localhost:8000

# OAuth (desabilitado para desenvolvimento)
GOOGLE_CLIENT_ID=
GOOGLE_CLIENT_SECRET=
GITHUB_CLIENT_ID=
GITHUB_CLIENT_SECRET=

# Email (autoconfirm ativado)
MAILER_AUTOCONFIRM=true
SMTP_HOST=
SMTP_PORT=587
SMTP_USER=
SMTP_PASS=
SMTP_ADMIN_EMAIL=admin@localhost

# Build context
NEXTJS_BUILD_CONTEXT=.

# Chaves Supabase para desenvolvimento
$(generate_supabase_keys "$JWT_SECRET" "dev")"

        # SALVAR DIRETAMENTE NO ARQUIVO .env.dev
        if [ -f ".env.dev" ]; then
            echo -e "${YELLOW}⚠️  Arquivo .env.dev já existe!${NC}"
            read -p "Deseja sobrescrever? (y/N): " overwrite
            if [[ $overwrite =~ ^[Yy]$ ]]; then
                echo "$ENV_CONTENT" > .env.dev
                echo -e "${GREEN}✅ Arquivo .env.dev atualizado com sucesso!${NC}"
            else
                echo -e "${YELLOW}❌ Operação cancelada${NC}"
                exit 0
            fi
        else
            echo "$ENV_CONTENT" > .env.dev
            echo -e "${GREEN}✅ Arquivo .env.dev criado com sucesso!${NC}"
        fi
        
        echo -e "${BLUE}🔒 Chaves salvas com segurança no arquivo .env.dev${NC}"
        echo -e "${CYAN}🎯 Pronto! Execute: ./dev.sh start${NC}"
        ;;
        
    2)
        echo -e "${RED}🔒 Gerando chaves para PRODUÇÃO...${NC}"
        
        # Gerar chaves (SEM MOSTRAR)
        JWT_SECRET=$(generate_jwt_secret)
        SECRET_KEY_BASE=$(generate_secret_key_base)
        DB_PASSWORD=$(generate_password)
        
        # Criar conteúdo do arquivo .env
        ENV_CONTENT="# ==========================================
# PRODUÇÃO - .env (MANTER SECRETO!)
# ==========================================
# Gerado em: $(date)

# Database
POSTGRES_PASSWORD=${DB_PASSWORD}

# JWT e Keys (PRODUÇÃO - MANTER SEGURO!)
JWT_SECRET=${JWT_SECRET}
SECRET_KEY_BASE=${SECRET_KEY_BASE}

# Realtime
APP_NAME=Syntropy-Prod

# URLs de produção (AJUSTAR CONFORME NECESSÁRIO)
API_EXTERNAL_URL=https://api.syntropy.cc

# OAuth (CONFIGURAR COM CHAVES REAIS)
GOOGLE_CLIENT_ID=SEU_GOOGLE_CLIENT_ID
GOOGLE_CLIENT_SECRET=SEU_GOOGLE_CLIENT_SECRET
GITHUB_CLIENT_ID=SEU_GITHUB_CLIENT_ID
GITHUB_CLIENT_SECRET=SEU_GITHUB_CLIENT_SECRET

# Email (CONFIGURAR SMTP REAL)
MAILER_AUTOCONFIRM=false
SMTP_HOST=seu-smtp-host.com
SMTP_PORT=587
SMTP_USER=seu-usuario-smtp
SMTP_PASS=sua-senha-smtp
SMTP_ADMIN_EMAIL=admin@syntropy.cc

# Build context
NEXTJS_BUILD_CONTEXT=.

# Chaves Supabase para produção
$(generate_supabase_keys "$JWT_SECRET" "prod")"

        # SALVAR DIRETAMENTE NO ARQUIVO .env
        if [ -f ".env" ]; then
            echo -e "${YELLOW}⚠️  Arquivo .env já existe!${NC}"
            echo -e "${RED}🚨 CUIDADO: Este é o arquivo de PRODUÇÃO!${NC}"
            read -p "Tem CERTEZA que deseja sobrescrever? (y/N): " overwrite
            if [[ $overwrite =~ ^[Yy]$ ]]; then
                # Fazer backup antes de sobrescrever
                backup_name=".env.backup.$(date +%Y%m%d-%H%M%S)"
                cp .env "$backup_name"
                echo -e "${BLUE}📦 Backup criado: $backup_name${NC}"
                
                echo "$ENV_CONTENT" > .env
                echo -e "${GREEN}✅ Arquivo .env atualizado com sucesso!${NC}"
            else
                echo -e "${YELLOW}❌ Operação cancelada${NC}"
                exit 0
            fi
        else
            echo "$ENV_CONTENT" > .env
            echo -e "${GREEN}✅ Arquivo .env criado com sucesso!${NC}"
        fi
        
        echo -e "${BLUE}🔒 Chaves salvas com segurança no arquivo .env${NC}"
        echo -e "${RED}🔒 IMPORTANTE: Não commite este arquivo no repositório!${NC}"
        ;;
        
    3)
        echo -e "${GREEN}🔑 JWT Secret gerado${NC}"
        JWT_SECRET=$(generate_jwt_secret)
        echo "Comprimento: ${#JWT_SECRET} caracteres"
        echo -e "${BLUE}🔒 Use este valor manualmente onde necessário${NC}"
        echo -e "${YELLOW}Para ver o valor: echo \$JWT_SECRET${NC}"
        ;;
        
    4)
        echo -e "${GREEN}🗝️  Secret Key Base gerado${NC}"
        SECRET_KEY_BASE=$(generate_secret_key_base)
        echo "Comprimento: ${#SECRET_KEY_BASE} caracteres"
        echo -e "${BLUE}🔒 Use este valor manualmente onde necessário${NC}"
        echo -e "${YELLOW}Para ver o valor: echo \$SECRET_KEY_BASE${NC}"
        ;;
        
    5)
        echo -e "${GREEN}🔐 Senha de banco gerada${NC}"
        DB_PASSWORD=$(generate_password)
        echo "Comprimento: ${#DB_PASSWORD} caracteres"
        echo -e "${BLUE}🔒 Use este valor manualmente onde necessário${NC}"
        echo -e "${YELLOW}Para ver o valor: echo \$DB_PASSWORD${NC}"
        ;;
        
    6)
        echo -e "${CYAN}🛠️  Geração customizada${NC}"
        read -p "Nome do ambiente (dev/prod/staging): " env_name
        
        # Gerar chaves (SEM MOSTRAR)
        JWT_SECRET=$(generate_jwt_secret)
        SECRET_KEY_BASE=$(generate_secret_key_base)
        DB_PASSWORD=$(generate_password)
        
        # Determinar nome do arquivo
        if [ "$env_name" = "prod" ]; then
            env_file=".env"
        else
            env_file=".env.${env_name}"
        fi
        
        # Criar conteúdo do arquivo
        ENV_CONTENT="# ==========================================
# AMBIENTE: ${env_name^^}
# ==========================================
# Gerado em: $(date)

# Database
POSTGRES_PASSWORD=${DB_PASSWORD}

# JWT e Keys
JWT_SECRET=${JWT_SECRET}
SECRET_KEY_BASE=${SECRET_KEY_BASE}

# Realtime
APP_NAME=Syntropy-${env_name^}

# URLs (AJUSTAR CONFORME NECESSÁRIO)
API_EXTERNAL_URL=https://api-${env_name}.syntropy.cc

# Build context
NEXTJS_BUILD_CONTEXT=.

# Chaves Supabase para ${env_name}
$(generate_supabase_keys "$JWT_SECRET" "$env_name")"

        # SALVAR DIRETAMENTE NO ARQUIVO
        if [ -f "$env_file" ]; then
            echo -e "${YELLOW}⚠️  Arquivo $env_file já existe!${NC}"
            read -p "Deseja sobrescrever? (y/N): " overwrite
            if [[ $overwrite =~ ^[Yy]$ ]]; then
                echo "$ENV_CONTENT" > "$env_file"
                echo -e "${GREEN}✅ Arquivo $env_file atualizado com sucesso!${NC}"
            else
                echo -e "${YELLOW}❌ Operação cancelada${NC}"
                exit 0
            fi
        else
            echo "$ENV_CONTENT" > "$env_file"
            echo -e "${GREEN}✅ Arquivo $env_file criado com sucesso!${NC}"
        fi
        
        echo -e "${BLUE}🔒 Chaves salvas com segurança no arquivo $env_file${NC}"
        ;;
        
    *)
        echo -e "${RED}❌ Opção inválida!${NC}"
        exit 1
        ;;
esac

echo ""
echo -e "${BLUE}📋 Dicas importantes:${NC}"
echo "• Chaves nunca são exibidas no terminal por segurança"
echo "• Use diferentes chaves para cada ambiente"
echo "• Nunca commite arquivos .env no repositório"
echo "• Mantenha backups das chaves de produção"

echo -e "${GREEN}✨ Concluído!${NC}"