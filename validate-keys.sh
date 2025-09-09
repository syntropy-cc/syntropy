#!/bin/bash

# Cores para output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${BLUE}🔍 Syntropy - Validador de Chaves${NC}"
echo "================================="

# Função para validar comprimento mínimo
validate_length() {
    local key="$1"
    local min_length="$2"
    local current_length=${#key}
    
    if [ $current_length -ge $min_length ]; then
        echo -e "${GREEN}✅${NC}"
        return 0
    else
        echo -e "${RED}❌ (${current_length}/${min_length})${NC}"
        return 1
    fi
}

# Função para validar formato JWT
validate_jwt_format() {
    local jwt="$1"
    
    # Contar pontos (JWT deve ter exatamente 2 pontos)
    local dot_count=$(echo "$jwt" | tr -cd '.' | wc -c)
    
    if [ "$dot_count" -eq 2 ]; then
        echo -e "${GREEN}✅ Formato válido${NC}"
        return 0
    else
        echo -e "${RED}❌ Formato inválido (dots: $dot_count/2)${NC}"
        return 1
    fi
}

# Função para verificar se a chave está vazia ou é padrão
validate_not_default() {
    local key="$1"
    local key_name="$2"
    
    if [ -z "$key" ]; then
        echo -e "${RED}❌ Vazia${NC}"
        return 1
    fi
    
    # Verificar algumas chaves comuns/inseguras
    case "$key" in
        "your-super-secret"* | "dev123" | "password" | "secret" | "changeme")
            echo -e "${YELLOW}⚠️  Chave padrão/insegura${NC}"
            return 1
            ;;
        *)
            echo -e "${GREEN}✅ Personalizada${NC}"
            return 0
            ;;
    esac
}

# Verificar se arquivo existe
check_env_file() {
    local file="$1"
    
    echo -e "${BLUE}📁 Verificando arquivo: $file${NC}"
    
    if [ ! -f "$file" ]; then
        echo -e "${RED}❌ Arquivo não encontrado!${NC}"
        return 1
    fi
    
    echo -e "${GREEN}✅ Arquivo encontrado${NC}"
    
    # Carregar variáveis do arquivo
    set -a  # automatically export all variables
    source "$file" 2>/dev/null || {
        echo -e "${RED}❌ Erro ao carregar arquivo!${NC}"
        return 1
    }
    set +a
    
    echo ""
    echo -e "${CYAN}🔍 Validando chaves...${NC}"
    echo "----------------------------------------"
    
    local all_valid=true
    
    # Validar POSTGRES_PASSWORD
    echo -n "POSTGRES_PASSWORD (min 8 chars): "
    if ! validate_length "$POSTGRES_PASSWORD" 8; then
        all_valid=false
    fi
    echo -n "  └─ Segurança: "
    if ! validate_not_default "$POSTGRES_PASSWORD" "POSTGRES_PASSWORD"; then
        all_valid=false
    fi
    
    # Validar JWT_SECRET
    echo -n "JWT_SECRET (min 32 chars): "
    if ! validate_length "$JWT_SECRET" 32; then
        all_valid=false
    fi
    echo -n "  └─ Segurança: "
    if ! validate_not_default "$JWT_SECRET" "JWT_SECRET"; then
        all_valid=false
    fi
    
    # Validar SECRET_KEY_BASE
    echo -n "SECRET_KEY_BASE (min 64 chars): "
    if ! validate_length "$SECRET_KEY_BASE" 64; then
        all_valid=false
    fi
    echo -n "  └─ Segurança: "
    if ! validate_not_default "$SECRET_KEY_BASE" "SECRET_KEY_BASE"; then
        all_valid=false
    fi
    
    # Validar ANON_KEY
    echo -n "ANON_KEY (formato JWT): "
    if ! validate_jwt_format "$ANON_KEY"; then
        all_valid=false
    fi
    echo -n "  └─ Segurança: "
    if ! validate_not_default "$ANON_KEY" "ANON_KEY"; then
        all_valid=false
    fi
    
    # Validar SERVICE_ROLE_KEY
    echo -n "SERVICE_ROLE_KEY (formato JWT): "
    if ! validate_jwt_format "$SERVICE_ROLE_KEY"; then
        all_valid=false
    fi
    echo -n "  └─ Segurança: "
    if ! validate_not_default "$SERVICE_ROLE_KEY" "SERVICE_ROLE_KEY"; then
        all_valid=false
    fi
    
    echo ""
    echo "----------------------------------------"
    
    if $all_valid; then
        echo -e "${GREEN}🎉 Todas as chaves estão válidas!${NC}"
        return 0
    else
        echo -e "${RED}⚠️  Algumas chaves precisam de atenção!${NC}"
        return 1
    fi
}

# Função para mostrar informações sobre as chaves
show_key_info() {
    local file="$1"
    
    if [ ! -f "$file" ]; then
        echo -e "${RED}❌ Arquivo $file não encontrado!${NC}"
        return 1
    fi
    
    source "$file" 2>/dev/null
    
    echo -e "${CYAN}📊 Informações das chaves em $file:${NC}"
    echo "----------------------------------------"
    echo "POSTGRES_PASSWORD: ${#POSTGRES_PASSWORD} caracteres"
    echo "JWT_SECRET: ${#JWT_SECRET} caracteres"
    echo "SECRET_KEY_BASE: ${#SECRET_KEY_BASE} caracteres"
    echo "ANON_KEY: ${#ANON_KEY} caracteres"
    echo "SERVICE_ROLE_KEY: ${#SERVICE_ROLE_KEY} caracteres"
    echo ""
}

# Menu principal
echo ""
echo "Escolha uma opção:"
echo "1) Validar .env.dev"
echo "2) Validar .env (produção)"
echo "3) Validar arquivo customizado"
echo "4) Mostrar informações das chaves"
echo "5) Comparar desenvolvimento vs produção"
echo ""
read -p "Digite sua escolha (1-5): " choice

case $choice in
    1)
        check_env_file ".env.dev"
        ;;
    2)
        check_env_file ".env"
        ;;
    3)
        read -p "Digite o caminho do arquivo: " custom_file
        check_env_file "$custom_file"
        ;;
    4)
        echo "Escolha o arquivo:"
        echo "1) .env.dev"
        echo "2) .env"
        echo "3) Arquivo customizado"
        read -p "Opção: " info_choice
        
        case $info_choice in
            1) show_key_info ".env.dev" ;;
            2) show_key_info ".env" ;;
            3) 
                read -p "Digite o caminho do arquivo: " custom_file
                show_key_info "$custom_file"
                ;;
        esac
        ;;
    5)
        echo -e "${CYAN}🆚 Comparando ambientes:${NC}"
        echo ""
        
        if [ -f ".env.dev" ] && [ -f ".env" ]; then
            echo "DESENVOLVIMENTO (.env.dev):"
            show_key_info ".env.dev"
            echo ""
            echo "PRODUÇÃO (.env):"
            show_key_info ".env"
            
            # Verificar se as chaves são iguais (ERRO!)
            source ".env.dev"
            dev_jwt="$JWT_SECRET"
            dev_anon="$ANON_KEY"
            
            source ".env"
            prod_jwt="$JWT_SECRET"
            prod_anon="$ANON_KEY"
            
            echo -e "${YELLOW}🔍 Verificação de segurança:${NC}"
            if [ "$dev_jwt" = "$prod_jwt" ]; then
                echo -e "${RED}❌ JWT_SECRET é igual em dev e prod! ALTERE IMEDIATAMENTE!${NC}"
            else
                echo -e "${GREEN}✅ JWT_SECRET diferente entre ambientes${NC}"
            fi
            
            if [ "$dev_anon" = "$prod_anon" ]; then
                echo -e "${RED}❌ ANON_KEY é igual em dev e prod! ALTERE IMEDIATAMENTE!${NC}"
            else
                echo -e "${GREEN}✅ ANON_KEY diferente entre ambientes${NC}"
            fi
        else
            echo -e "${RED}❌ Arquivos .env.dev ou .env não encontrados!${NC}"
        fi
        ;;
    *)
        echo -e "${RED}❌ Opção inválida!${NC}"
        exit 1
        ;;
esac

echo ""
echo -e "${BLUE}💡 Dicas de segurança:${NC}"
echo "• Use chaves diferentes para cada ambiente"
echo "• Mantenha chaves de produção em local seguro"
echo "• Gere novas chaves regularmente"
echo "• Nunca commite arquivos .env no repositório"
echo "• Use gerenciadores de secret em produção"