#!/bin/bash

# Cores para output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${BLUE}🚀 Syntropy - Ambiente de Desenvolvimento${NC}"
echo "============================================"

# Função para verificar dependências e instalar automaticamente
check_dependencies() {
    echo -e "${BLUE}🔍 Verificando dependências...${NC}"
    local dependencies_installed=false
    
    # Verificar se Docker está instalado
    if ! command -v docker >/dev/null 2>&1; then
        echo -e "${YELLOW}⚠️  Docker não está instalado${NC}"
        echo -e "${CYAN}💡 O Docker é necessário para executar o ambiente de desenvolvimento${NC}"
        
        read -p "Deseja instalar o Docker automaticamente? (Y/n): " install_docker
        if [[ ! $install_docker =~ ^[Nn]$ ]]; then
            echo -e "${GREEN}📦 Instalando Docker...${NC}"
            
            if [[ "$OSTYPE" == "linux-gnu"* ]]; then
                curl -fsSL https://get.docker.com -o get-docker.sh
                sudo sh get-docker.sh
                sudo usermod -aG docker $USER
                rm -f get-docker.sh
                echo -e "${GREEN}✅ Docker instalado com sucesso!${NC}"
                dependencies_installed=true
            elif [[ "$OSTYPE" == "darwin"* ]]; then
                if command -v brew >/dev/null 2>&1; then
                    brew install --cask docker
                    echo -e "${GREEN}✅ Docker instalado! Abra o Docker Desktop.${NC}"
                else
                    echo -e "${YELLOW}📱 Instale Homebrew primeiro ou baixe Docker Desktop manualmente${NC}"
                    echo -e "${BLUE}https://www.docker.com/products/docker-desktop${NC}"
                    exit 1
                fi
            else
                echo -e "${YELLOW}📱 Visite: https://docs.docker.com/get-docker/${NC}"
                exit 1
            fi
        else
            echo -e "${RED}❌ Docker é obrigatório para continuar${NC}"
            exit 1
        fi
    fi
    
    # Verificar se Docker está rodando
    if command -v docker >/dev/null 2>&1 && ! docker info >/dev/null 2>&1; then
        echo -e "${YELLOW}⚠️  Docker não está rodando${NC}"
        
        read -p "Deseja iniciar o Docker automaticamente? (Y/n): " start_docker
        if [[ ! $start_docker =~ ^[Nn]$ ]]; then
            echo -e "${GREEN}🚀 Iniciando Docker...${NC}"
            
            if [[ "$OSTYPE" == "linux-gnu"* ]]; then
                sudo systemctl start docker
                sudo systemctl enable docker
                sleep 3
                
                if docker info >/dev/null 2>&1; then
                    echo -e "${GREEN}✅ Docker iniciado com sucesso!${NC}"
                else
                    echo -e "${RED}❌ Falha ao iniciar Docker. Verifique: sudo systemctl status docker${NC}"
                    exit 1
                fi
            elif [[ "$OSTYPE" == "darwin"* ]]; then
                open -a Docker
                echo -e "${BLUE}🔄 Aguardando Docker Desktop iniciar...${NC}"
                
                for i in {1..60}; do
                    if docker info >/dev/null 2>&1; then
                        echo -e "${GREEN}✅ Docker iniciado com sucesso!${NC}"
                        break
                    fi
                    sleep 1
                    if [ $i -eq 60 ]; then
                        echo -e "${RED}❌ Docker demorou para iniciar. Abra Docker Desktop manualmente.${NC}"
                        exit 1
                    fi
                done
            fi
        else
            echo -e "${RED}❌ Docker deve estar rodando para continuar${NC}"
            exit 1
        fi
    fi
    
    # Verificar se docker-compose existe
    if ! command -v docker-compose >/dev/null 2>&1; then
        echo -e "${YELLOW}⚠️  docker-compose não está instalado${NC}"
        echo -e "${CYAN}💡 O docker-compose é necessário para orquestrar os containers${NC}"
        
        read -p "Deseja instalar o docker-compose automaticamente? (Y/n): " install_compose
        if [[ ! $install_compose =~ ^[Nn]$ ]]; then
            echo -e "${GREEN}📦 Instalando docker-compose...${NC}"
            
            if [[ "$OSTYPE" == "linux-gnu"* ]]; then
                # Tentar via package manager primeiro
                if command -v apt >/dev/null 2>&1; then
                    sudo apt update && sudo apt install -y docker-compose
                elif command -v yum >/dev/null 2>&1; then
                    sudo yum install -y docker-compose
                elif command -v dnf >/dev/null 2>&1; then
                    sudo dnf install -y docker-compose
                elif command -v pacman >/dev/null 2>&1; then
                    sudo pacman -S --noconfirm docker-compose
                else
                    # Fallback para download direto
                    echo -e "${BLUE}📥 Baixando docker-compose...${NC}"
                    sudo curl -L "https://github.com/docker/compose/releases/latest/download/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
                    sudo chmod +x /usr/local/bin/docker-compose
                fi
                
                echo -e "${GREEN}✅ docker-compose instalado com sucesso!${NC}"
                dependencies_installed=true
                
            elif [[ "$OSTYPE" == "darwin"* ]]; then
                if command -v brew >/dev/null 2>&1; then
                    brew install docker-compose
                    echo -e "${GREEN}✅ docker-compose instalado com sucesso!${NC}"
                else
                    echo -e "${YELLOW}📱 Docker Desktop já inclui docker-compose${NC}"
                    echo -e "${BLUE}💡 Se não funcionar, instale Homebrew primeiro${NC}"
                fi
            fi
            
            # Verificar se a instalação funcionou
            if ! command -v docker-compose >/dev/null 2>&1; then
                echo -e "${RED}❌ Falha na instalação do docker-compose${NC}"
                echo -e "${CYAN}💡 Tente instalar manualmente ou reinicie o terminal${NC}"
                exit 1
            fi
        else
            echo -e "${RED}❌ docker-compose é obrigatório para continuar${NC}"
            exit 1
        fi
    fi
    
    # Verificar permissões do Docker (Linux)
    if [[ "$OSTYPE" == "linux-gnu"* ]] && command -v docker >/dev/null 2>&1; then
        if ! docker ps >/dev/null 2>&1; then
            echo -e "${YELLOW}⚠️  Seu usuário não tem permissão para usar Docker${NC}"
            echo -e "${CYAN}💡 Preciso adicionar seu usuário ao grupo docker${NC}"
            
            read -p "Deseja corrigir as permissões automaticamente? (Y/n): " fix_permissions
            if [[ ! $fix_permissions =~ ^[Nn]$ ]]; then
                echo -e "${GREEN}🔧 Corrigindo permissões do Docker...${NC}"
                sudo usermod -aG docker $USER
                
                echo -e "${GREEN}✅ Usuário adicionado ao grupo docker!${NC}"
                
                if $dependencies_installed; then
                    echo -e "${BLUE}🔄 Reinicie o terminal e execute novamente: ./dev.sh start${NC}"
                    exit 0
                else
                    echo -e "${BLUE}🔄 Aplicando permissões...${NC}"
                    # Tentar aplicar permissões sem reiniciar
                    exec sg docker "$0 $*"
                fi
            else
                echo -e "${RED}❌ Permissões do Docker são necessárias para continuar${NC}"
                exit 1
            fi
        fi
    fi
    
    # Verificação final
    if command -v docker >/dev/null 2>&1 && command -v docker-compose >/dev/null 2>&1 && docker info >/dev/null 2>&1; then
        echo -e "${GREEN}✅ Todas as dependências estão instaladas e funcionando!${NC}"
        if $dependencies_installed; then
            echo -e "${BLUE}🎉 Dependências instaladas com sucesso! Continuando...${NC}"
        fi
    else
        echo -e "${RED}❌ Ainda há problemas com as dependências${NC}"
        exit 1
    fi
}

# Função para verificar arquivos necessários do projeto
check_project_files() {
    echo -e "${BLUE}🔍 Verificando arquivos do projeto...${NC}"
    
    local files_missing=false
    
    # Verificar arquivos essenciais
    required_files=("package.json" "docker-compose.dev.yml" "Dockerfile.dev")
    
    for file in "${required_files[@]}"; do
        if [ ! -f "$file" ]; then
            echo -e "${RED}❌ Arquivo obrigatório ausente: $file${NC}"
            files_missing=true
        fi
    done
    
    # Verificar se package-lock.json existe
    if [ ! -f "package-lock.json" ]; then
        echo -e "${YELLOW}⚠️  package-lock.json não encontrado${NC}"
        echo -e "${CYAN}💡 Isso pode causar problemas no build do Docker${NC}"
        
        if [ -f "package.json" ]; then
            read -p "Deseja gerar package-lock.json automaticamente? (Y/n): " generate_lock
            if [[ ! $generate_lock =~ ^[Nn]$ ]]; then
                echo -e "${GREEN}📦 Executando npm install...${NC}"
                npm install
                echo -e "${GREEN}✅ package-lock.json criado!${NC}"
            fi
        fi
    fi
    
    # Verificar se existem dependências no package.json
    if [ -f "package.json" ]; then
        if ! grep -q '"dependencies"' package.json && ! grep -q '"devDependencies"' package.json; then
            echo -e "${YELLOW}⚠️  package.json parece estar vazio ou inválido${NC}"
            echo -e "${CYAN}💡 Certifique-se de que é um projeto Next.js válido${NC}"
        fi
    fi
    
    if $files_missing; then
        echo -e "${RED}❌ Arquivos obrigatórios estão ausentes!${NC}"
        echo -e "${CYAN}💡 Certifique-se de estar no diretório correto do projeto${NC}"
        exit 1
    fi
    
    echo -e "${GREEN}✅ Arquivos do projeto verificados!${NC}"
}

# Função para verificar e configurar .env.dev
setup_env_dev() {
    echo -e "${BLUE}🔧 Configurando ambiente de desenvolvimento...${NC}"
    
    # Verificar se .env.dev existe
    if [ ! -f ".env.dev" ]; then
        echo -e "${YELLOW}📝 Arquivo .env.dev não encontrado!${NC}"
        echo -e "${CYAN}💡 Vou criar automaticamente com chaves seguras...${NC}"
        
        # Verificar se generate-keys.sh existe
        if [ ! -f "./generate-keys.sh" ]; then
            echo -e "${RED}❌ Script generate-keys.sh não encontrado!${NC}"
            echo -e "${CYAN}💡 Certifique-se de que todos os arquivos do projeto estão presentes.${NC}"
            exit 1
        fi
        
        # Executar generate-keys.sh automaticamente
        chmod +x ./generate-keys.sh
        echo -e "${GREEN}🔐 Gerando chaves automaticamente...${NC}"
        
        # Simular entrada "1" para desenvolvimento + "y" para confirmar
        echo -e "1\ny" | ./generate-keys.sh >/dev/null 2>&1
        
        if [ -f ".env.dev" ]; then
            echo -e "${GREEN}✅ Arquivo .env.dev criado com sucesso!${NC}"
        else
            echo -e "${RED}❌ Falha ao criar .env.dev automaticamente.${NC}"
            echo -e "${CYAN}💡 Execute manualmente: ./generate-keys.sh${NC}"
            exit 1
        fi
    else
        echo -e "${GREEN}✅ Arquivo .env.dev encontrado!${NC}"
    fi
    
    # Validar chaves sempre
    echo -e "${BLUE}🔍 Validando configurações...${NC}"
    
    if [ -f "./validate-keys.sh" ]; then
        chmod +x ./validate-keys.sh
        
        # Executar validação e capturar saída
        validation_output=$(mktemp)
        
        # Simular entrada "1" para validar .env.dev
        echo "1" | ./validate-keys.sh > "$validation_output" 2>&1
        
        # Verificar se há problemas na validação
        if grep -q "❌" "$validation_output"; then
            echo -e "${YELLOW}⚠️  Problemas encontrados nas configurações:${NC}"
            echo ""
            grep "❌" "$validation_output" | head -5
            echo ""
            
            echo -e "${CYAN}💡 Posso corrigir automaticamente gerando novas chaves...${NC}"
            read -p "Deseja regenerar as chaves? (Y/n): " regenerate
            
            if [[ ! $regenerate =~ ^[Nn]$ ]]; then
                echo -e "${GREEN}🔄 Regenerando chaves...${NC}"
                
                # Fazer backup do arquivo atual
                cp .env.dev .env.dev.backup.$(date +%Y%m%d-%H%M%S)
                echo -e "${BLUE}📦 Backup criado${NC}"
                
                # Regenerar chaves automaticamente
                echo -e "1\ny" | ./generate-keys.sh >/dev/null 2>&1
                
                # Validar novamente
                echo "1" | ./validate-keys.sh > "$validation_output" 2>&1
                
                if grep -q "❌" "$validation_output"; then
                    echo -e "${RED}❌ Ainda há problemas após regeneração.${NC}"
                    echo -e "${CYAN}💡 Execute manualmente: ./validate-keys.sh${NC}"
                    rm -f "$validation_output"
                    exit 1
                else
                    echo -e "${GREEN}✅ Chaves regeneradas e validadas com sucesso!${NC}"
                fi
            else
                echo -e "${YELLOW}⚠️  Continuando com configurações atuais...${NC}"
            fi
        else
            echo -e "${GREEN}✅ Todas as configurações estão válidas!${NC}"
        fi
        
        rm -f "$validation_output"
    else
        echo -e "${YELLOW}⚠️  Script validate-keys.sh não encontrado${NC}"
        echo -e "${CYAN}💡 Continuando sem validação detalhada...${NC}"
    fi
    
    echo -e "${GREEN}🎯 Ambiente de desenvolvimento configurado!${NC}"
}

# Função para parar containers
stop_dev() {
    echo -e "${YELLOW}🛑 Parando ambiente de desenvolvimento...${NC}"
    
    # Para containers e remove redes
    docker-compose -f docker-compose.dev.yml --env-file .env.dev down --remove-orphans >/dev/null 2>&1
    
    # Aguardar containers pararem completamente
    echo -e "${BLUE}⏳ Aguardando containers pararem...${NC}"
    sleep 3
    
    echo -e "${GREEN}✅ Ambiente parado!${NC}"
}

# Função para limpar volumes
clean() {
    echo -e "${RED}🗑️  Limpeza completa do ambiente de desenvolvimento...${NC}"
    echo -e "${YELLOW}⚠️  Isso removerá TODOS os dados dos containers (banco, uploads, etc.)${NC}"
    
    read -p "Tem certeza que deseja continuar? (y/N): " confirm_clean
    if [[ ! $confirm_clean =~ ^[Yy]$ ]]; then
        echo -e "${BLUE}Operação cancelada.${NC}"
        return 0
    fi
    
    echo -e "${RED}🧨 Removendo containers, volumes e redes...${NC}"
    
    # Para e remove tudo relacionado ao projeto
    docker-compose -f docker-compose.dev.yml --env-file .env.dev down --volumes --remove-orphans
    
    # Limpar containers órfãos
    echo -e "${BLUE}🗑️  Limpando containers órfãos...${NC}"
    docker container prune -f
    
    # Limpar volumes órfãos
    echo -e "${BLUE}💾 Limpando volumes órfãos...${NC}"
    docker volume prune -f
    
    # Limpar redes órfãs
    echo -e "${BLUE}🌐 Limpando redes órfãs...${NC}"
    docker network prune -f
    
    # Limpar cache de build
    echo -e "${BLUE}🔄 Limpando cache de build...${NC}"
    docker builder prune -f
    
    # Limpar imagens não utilizadas (opcional)
    read -p "Deseja também limpar imagens não utilizadas? (y/N): " clean_images
    if [[ $clean_images =~ ^[Yy]$ ]]; then
        echo -e "${BLUE}🖼️  Limpando imagens órfãs...${NC}"
        docker image prune -f
    fi
    
    echo -e "${GREEN}✅ Limpeza completa finalizada!${NC}"
    echo -e "${CYAN}💡 Agora você pode executar: ./dev.sh start${NC}"
}

# Função para rebuild completo
rebuild() {
    echo -e "${YELLOW}🔨 Rebuild completo do ambiente...${NC}"
    echo -e "${BLUE}Isso vai parar tudo, limpar cache e reconstruir do zero.${NC}"
    
    read -p "Deseja continuar? (Y/n): " confirm_rebuild
    if [[ $confirm_rebuild =~ ^[Nn]$ ]]; then
        echo -e "${BLUE}Operação cancelada.${NC}"
        return 0
    fi
    
    # Limpeza total
    echo -e "${RED}🧨 Limpando ambiente anterior...${NC}"
    docker-compose -f docker-compose.dev.yml --env-file .env.dev down --volumes --remove-orphans --rmi all 2>/dev/null
    docker system prune -af >/dev/null 2>&1
    
    # Verificar dependências
    echo ""
    check_dependencies
    echo ""
    
    # Verificar arquivos do projeto
    check_project_files
    echo ""
    
    # Configurar .env.dev
    setup_env_dev
    echo ""
    
    # Rebuild completo
    echo -e "${GREEN}🏗️  Reconstruindo do zero...${NC}"
    
    compose_output=$(mktemp)
    if docker-compose -f docker-compose.dev.yml --env-file .env.dev up --build -d --force-recreate > "$compose_output" 2>&1; then
        echo -e "${GREEN}✅ Rebuild concluído com sucesso!${NC}"
        
        # Verificar saúde dos serviços
        echo -e "${BLUE}⏳ Verificando saúde dos serviços...${NC}"
        sleep 10
        
        failed_services=()
        critical_services=("db" "auth" "rest" "realtime" "storage" "nextjs" "kong")
        
        for service in "${critical_services[@]}"; do
            if ! docker-compose -f docker-compose.dev.yml --env-file .env.dev ps "$service" | grep -q "Up"; then
                failed_services+=("$service")
            fi
        done
        
        if [ ${#failed_services[@]} -eq 0 ]; then
            echo -e "${GREEN}✅ Todos os serviços estão funcionando!${NC}"
            echo -e "${CYAN}🌐 Acesse: http://localhost:3000${NC}"
        else
            echo -e "${RED}❌ Alguns serviços ainda têm problemas:${NC}"
            for service in "${failed_services[@]}"; do
                echo -e "   • ${RED}$service${NC}"
            done
            echo -e "${CYAN}💡 Execute: ./dev.sh logs${NC}"
            rm -f "$compose_output"
            exit 1
        fi
    else
        echo -e "${RED}❌ Erro no rebuild:${NC}"
        cat "$compose_output"
        rm -f "$compose_output"
        exit 1
    fi
    
    rm -f "$compose_output"
}

# Função para resolver problemas comuns
fix_issues() {
    echo -e "${YELLOW}🔧 Resolvendo problemas comuns do projeto...${NC}"
    
    # Gerar package-lock.json se não existir
    if [ ! -f "package-lock.json" ] && [ -f "package.json" ]; then
        echo -e "${BLUE}📦 Gerando package-lock.json...${NC}"
        npm install
        echo -e "${GREEN}✅ package-lock.json criado!${NC}"
    fi
    
    # Limpar node_modules se existir
    if [ -d "node_modules" ]; then
        echo -e "${BLUE}🗑️  Limpando node_modules...${NC}"
        rm -rf node_modules
        echo -e "${GREEN}✅ node_modules removido!${NC}"
    fi
    
    # Reinstalar dependências
    echo -e "${BLUE}📦 Reinstalando dependências...${NC}"
    npm install
    
    # Limpar cache do npm
    echo -e "${BLUE}🧹 Limpando cache do npm...${NC}"
    npm cache clean --force
    
    # Limpar Docker
    echo -e "${BLUE}🐳 Limpando Docker...${NC}"
    docker system prune -af >/dev/null 2>&1
    
    echo -e "${GREEN}✅ Problemas comuns resolvidos!${NC}"
    echo -e "${CYAN}💡 Agora tente: ./dev.sh start${NC}"
}

# Função para iniciar ambiente
start_dev() {
    echo -e "${GREEN}🚀 Iniciando ambiente de desenvolvimento Syntropy...${NC}"
    echo ""
    
    # Verificar dependências (com instalação automática)
    check_dependencies
    echo ""
    
    # Verificar arquivos do projeto
    check_project_files
    echo ""
    
    # Configurar .env.dev (criação e validação automática)
    setup_env_dev
    echo ""
    
    # Para e limpa containers anteriores COMPLETAMENTE
    echo -e "${BLUE}🧹 Limpando ambiente anterior...${NC}"
    
    # Para todos os containers relacionados
    docker-compose -f docker-compose.dev.yml --env-file .env.dev down --volumes --remove-orphans >/dev/null 2>&1
    
    # Remover containers órfãos que possam ter ficado
    echo -e "${BLUE}🗑️  Removendo containers órfãos...${NC}"
    docker container prune -f >/dev/null 2>&1
    
    # Limpar volumes órfãos
    echo -e "${BLUE}💾 Limpando volumes não utilizados...${NC}"
    docker volume prune -f >/dev/null 2>&1
    
    # Limpar cache de build se necessário
    echo -e "${BLUE}🔄 Limpando cache de build...${NC}"
    docker builder prune -f >/dev/null 2>&1
    
    echo -e "${GREEN}✅ Ambiente anterior limpo!${NC}"
    echo ""
    
    # Subir o ambiente
    echo -e "${GREEN}🏗️  Construindo e iniciando todos os serviços...${NC}"
    
    # Capturar saída do docker-compose para verificar erros
    compose_output=$(mktemp)
    if docker-compose -f docker-compose.dev.yml --env-file .env.dev up --build -d > "$compose_output" 2>&1; then
        echo -e "${GREEN}✅ Containers iniciados com sucesso!${NC}"
        
        # Aguardar um pouco para containers estabilizarem
        echo -e "${BLUE}⏳ Verificando saúde dos serviços...${NC}"
        sleep 10
        
        # Verificar se os containers estão realmente rodando
        failed_services=()
        
        # Lista de serviços críticos para verificar
        critical_services=("db" "auth" "rest" "realtime" "storage" "nextjs" "kong")
        
        for service in "${critical_services[@]}"; do
            if ! docker-compose -f docker-compose.dev.yml --env-file .env.dev ps "$service" | grep -q "Up"; then
                failed_services+=("$service")
            fi
        done
        
        if [ ${#failed_services[@]} -eq 0 ]; then
            # Todos os serviços estão rodando
            echo -e "${GREEN}✅ Todos os serviços estão saudáveis!${NC}"
            echo ""
            echo -e "${GREEN}🎉 Ambiente iniciado com sucesso!${NC}"
            echo ""
            echo -e "${CYAN}🌐 Seus serviços estão disponíveis em:${NC}"
            echo "   • 🌍 Aplicação Next.js: ${GREEN}http://localhost:3000${NC}"
            echo "   • 🚪 API Gateway (Kong): ${GREEN}http://localhost:8000${NC}"
            echo "   • ⚙️  Kong Admin: ${GREEN}http://localhost:8001${NC}"
            echo "   • 📊 PostgREST: ${GREEN}http://localhost:3001${NC}"
            echo "   • 🔐 GoTrue Auth: ${GREEN}http://localhost:9999${NC}"
            echo "   • ⚡ Realtime: ${GREEN}http://localhost:4000${NC}"
            echo "   • 📁 Storage API: ${GREEN}http://localhost:5000${NC}"
            echo "   • 🗄️  PostgreSQL: ${GREEN}localhost:5433${NC}"
            echo ""
            echo -e "${BLUE}📋 Comandos úteis:${NC}"
            echo "   • 📝 Ver logs: ${CYAN}./dev.sh logs${NC}"
            echo "   • 📊 Status: ${CYAN}./dev.sh status${NC}"
            echo "   • 🛑 Parar: ${CYAN}./dev.sh stop${NC}"
            echo "   • 🔄 Reiniciar Next.js: ${CYAN}./dev.sh restart-next${NC}"
            echo ""
            echo -e "${GREEN}✨ Bom desenvolvimento!${NC}"
        else
            # Alguns serviços falharam
            echo -e "${RED}❌ Alguns serviços falharam ao iniciar:${NC}"
            for service in "${failed_services[@]}"; do
                echo -e "   • ${RED}$service${NC}"
            done
            echo ""
            echo -e "${CYAN}💡 Para diagnosticar:${NC}"
            echo "   • Ver logs: ${YELLOW}./dev.sh logs${NC}"
            echo "   • Ver status: ${YELLOW}./dev.sh status${NC}"
            echo "   • Ver logs específicos: ${YELLOW}docker-compose -f docker-compose.dev.yml logs [serviço]${NC}"
            echo ""
            echo -e "${YELLOW}⚠️  Ambiente iniciado parcialmente. Verifique os logs acima.${NC}"
            rm -f "$compose_output"
            exit 1
        fi
        
    else
        # Erro no docker-compose
        echo ""
        echo -e "${RED}❌ Erro ao iniciar o ambiente!${NC}"
        echo ""
        echo -e "${YELLOW}📋 Detalhes do erro:${NC}"
        echo "----------------------------------------"
        cat "$compose_output"
        echo "----------------------------------------"
        echo ""
        
        # Analisar tipos comuns de erro e dar sugestões específicas
        if grep -q "npm.*package-lock.json" "$compose_output"; then
            echo -e "${CYAN}💡 Problema detectado: Arquivo package-lock.json ausente${NC}"
            echo -e "${BLUE}🔧 Soluções:${NC}"
            echo "   1. Execute: ${CYAN}./dev.sh fix${NC}"
            echo "   2. Ou manualmente: ${CYAN}npm install${NC} → ${CYAN}./dev.sh start${NC}"
            echo ""
            echo -e "${YELLOW}🔄 Tentando corrigir automaticamente...${NC}"
            
            # Tentar corrigir automaticamente
            if [ -f "package.json" ]; then
                echo "Executando npm install para criar package-lock.json..."
                npm install
                echo -e "${GREEN}✅ package-lock.json criado!${NC}"
                echo -e "${CYAN}🔄 Tentando iniciar novamente...${NC}"
                
                # Tentar novamente após corrigir
                if docker-compose -f docker-compose.dev.yml --env-file .env.dev up --build -d > "$compose_output" 2>&1; then
                    echo -e "${GREEN}✅ Ambiente iniciado após correção!${NC}"
                    rm -f "$compose_output"
                    return 0
                fi
            else
                echo -e "${RED}❌ Arquivo package.json não encontrado no diretório atual${NC}"
            fi
            
        elif grep -q "invalid type" "$compose_output"; then
            echo -e "${CYAN}💡 Problema detectado: Tipo de variável inválido no docker-compose${NC}"
            echo -e "${BLUE}🔧 Possíveis soluções:${NC}"
            echo "   1. Verifique o arquivo docker-compose.dev.yml"
            echo "   2. Certifique-se de que valores booleanos estão entre aspas:"
            echo "      ❌ GOTRUE_EXTERNAL_GOOGLE_ENABLED: false"
            echo "      ✅ GOTRUE_EXTERNAL_GOOGLE_ENABLED: \"false\""
            echo "   3. Regenere as configurações: ${CYAN}./dev.sh generate-keys${NC}"
            
        elif grep -q "port.*already.*use" "$compose_output"; then
            echo -e "${CYAN}💡 Problema detectado: Porta já está em uso${NC}"
            echo -e "${BLUE}🔧 Possíveis soluções:${NC}"
            echo "   1. Pare outros containers: ${CYAN}docker stop \$(docker ps -q)${NC}"
            echo "   2. Verifique processos nas portas: ${CYAN}lsof -i :3000,8000,5432${NC}"
            echo "   3. Reinicie completamente: ${CYAN}./dev.sh clean && ./dev.sh start${NC}"
            
        elif grep -q "network\|dns" "$compose_output"; then
            echo -e "${CYAN}💡 Problema detectado: Problema de rede/DNS${NC}"
            echo -e "${BLUE}🔧 Possíveis soluções:${NC}"
            echo "   1. Reinicie o Docker: ${CYAN}sudo systemctl restart docker${NC}"
            echo "   2. Limpe redes: ${CYAN}docker network prune -f${NC}"
            echo "   3. Verifique conectividade de internet"
            
        elif grep -q "build\|dockerfile" "$compose_output"; then
            echo -e "${CYAN}💡 Problema detectado: Erro no build da imagem${NC}"
            echo -e "${BLUE}🔧 Possíveis soluções:${NC}"
            echo "   1. Verifique se o Dockerfile.dev existe"
            echo "   2. Limpe cache: ${CYAN}docker system prune -f${NC}"
            echo "   3. Verifique dependências no package.json"
            echo "   4. Execute: ${CYAN}./dev.sh fix${NC}"
            
        elif grep -q "permission\|denied" "$compose_output"; then
            echo -e "${CYAN}💡 Problema detectado: Problema de permissões${NC}"
            echo -e "${BLUE}🔧 Possíveis soluções:${NC}"
            echo "   1. Verifique permissões do Docker: ${CYAN}sudo usermod -aG docker \$USER${NC}"
            echo "   2. Reinicie o terminal ou execute: ${CYAN}newgrp docker${NC}"
            echo "   3. Verifique permissões dos arquivos: ${CYAN}ls -la docker-compose.dev.yml${NC}"
            
        else
            echo -e "${CYAN}💡 Erro genérico detectado${NC}"
            echo -e "${BLUE}🔧 Possíveis soluções:${NC}"
            echo "   1. Execute: ${CYAN}./dev.sh fix${NC}"
            echo "   2. Valide configurações: ${CYAN}./dev.sh validate-keys${NC}"
            echo "   3. Rebuild completo: ${CYAN}./dev.sh rebuild${NC}"
        fi
        
        echo ""
        echo -e "${RED}🚨 Ambiente NÃO foi iniciado com sucesso!${NC}"
        echo -e "${CYAN}💬 Para ajuda adicional, compartilhe o erro acima${NC}"
        
        rm -f "$compose_output"
        exit 1
    fi
    
    rm -f "$compose_output"
}

# Função para mostrar logs
logs() {
    docker-compose -f docker-compose.dev.yml --env-file .env.dev logs -f
}

# Função para mostrar status
status() {
    echo -e "${BLUE}📊 Status dos serviços:${NC}"
    docker-compose -f docker-compose.dev.yml --env-file .env.dev ps
}

# Função para reiniciar apenas o Next.js
restart_nextjs() {
    echo -e "${YELLOW}🔄 Reiniciando Next.js...${NC}"
    docker-compose -f docker-compose.dev.yml --env-file .env.dev restart nextjs
}

# Função para gerar chaves
generate_keys() {
    if [ -f "./generate-keys.sh" ]; then
        chmod +x ./generate-keys.sh
        ./generate-keys.sh
    else
        echo -e "${RED}❌ Script generate-keys.sh não encontrado!${NC}"
        exit 1
    fi
}

# Função para validar chaves
validate_keys() {
    if [ -f "./validate-keys.sh" ]; then
        chmod +x ./validate-keys.sh
        ./validate-keys.sh
    else
        echo -e "${RED}❌ Script validate-keys.sh não encontrado!${NC}"
        exit 1
    fi
}

# Função para mostrar ajuda
show_help() {
    echo "Uso: $0 {start|stop|restart|clean|rebuild|fix|logs|status|restart-next|generate-keys|validate-keys}"
    echo ""
    echo "Comandos disponíveis:"
    echo "  start         - Inicia o ambiente de desenvolvimento"
    echo "  stop          - Para o ambiente de desenvolvimento"
    echo "  restart       - Reinicia o ambiente completo"
    echo "  clean         - Para e remove volumes/dados (fresh start)"
    echo "  rebuild       - Rebuild completo (resolve problemas de cache)"
    echo "  fix           - Resolve problemas comuns (package-lock, node_modules, etc.)"
    echo "  logs          - Mostra logs em tempo real"
    echo "  status        - Mostra status dos containers"
    echo "  restart-next  - Reinicia apenas o Next.js"
    echo "  generate-keys - Gera chaves seguras para desenvolvimento"
    echo "  validate-keys - Valida chaves existentes"
    echo "  help          - Mostra esta ajuda"
}

# Menu de opções
case "${1}" in
    start)
        start_dev
        ;;
    stop)
        stop_dev
        ;;
    restart)
        stop_dev
        start_dev
        ;;
    clean)
        clean
        ;;
    rebuild)
        rebuild
        ;;
    fix)
        fix_issues
        ;;
    logs)
        logs
        ;;
    status)
        status
        ;;
    restart-next)
        restart_nextjs
        ;;
    generate-keys)
        generate_keys
        ;;
    validate-keys)
        validate_keys
        ;;
    help|--help|-h)
        show_help
        ;;
    *)
        show_help
        exit 1
        ;;
esac