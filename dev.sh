#!/bin/bash

# Cores para output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${BLUE}🚀 Syntropy - Ambiente de Desenvolvimento${NC}"
echo "============================================"

# Função para parar containers se estiverem rodando
stop_dev() {
    echo -e "${YELLOW}🛑 Parando ambiente de desenvolvimento...${NC}"
    docker-compose -f docker-compose.dev.yml --env-file .env.dev down
}

# Função para limpar volumes (opcional)
clean() {
    echo -e "${RED}🗑️  Limpando volumes de desenvolvimento...${NC}"
    docker-compose -f docker-compose.dev.yml --env-file .env.dev down -v
    docker volume prune -f
}

# Função para iniciar ambiente
start_dev() {
    echo -e "${GREEN}🏗️  Construindo e iniciando ambiente de desenvolvimento...${NC}"
    
    # Verifica se o arquivo .env.dev existe
    if [ ! -f ".env.dev" ]; then
        echo -e "${RED}❌ Arquivo .env.dev não encontrado!${NC}"
        echo "Criando .env.dev com valores padrão..."
        cp .env.dev.example .env.dev 2>/dev/null || echo "Por favor, crie o arquivo .env.dev baseado no .env.dev.example"
        exit 1
    fi
    
    # Para qualquer container que possa estar rodando
    stop_dev
    
    # Sobe o ambiente
    docker-compose -f docker-compose.dev.yml --env-file .env.dev up --build -d
    
    echo ""
    echo -e "${GREEN}✅ Ambiente iniciado com sucesso!${NC}"
    echo ""
    echo "🌐 Acessos disponíveis:"
    echo "   • Aplicação Next.js: http://localhost:3000"
    echo "   • API Gateway (Kong): http://localhost:8000"
    echo "   • Kong Admin: http://localhost:8001"
    echo "   • PostgREST: http://localhost:3001"
    echo "   • GoTrue Auth: http://localhost:9999"
    echo "   • Realtime: http://localhost:4000"
    echo "   • Storage API: http://localhost:5000"
    echo "   • PostgreSQL: localhost:5433"
    echo ""
    echo "📝 Para ver logs: docker-compose -f docker-compose.dev.yml logs -f"
    echo "🛑 Para parar: ./dev.sh stop"
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

# Função para reiniciar apenas o Next.js
restart_nextjs() {
    echo -e "${YELLOW}🔄 Reiniciando Next.js...${NC}"
    docker-compose -f docker-compose.dev.yml --env-file .env.dev restart nextjs
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
    *)
        echo "Uso: $0 {start|stop|restart|clean|logs|status|restart-next|generate-keys|validate-keys}"
        echo ""
        echo "Comandos disponíveis:"
        echo "  start         - Inicia o ambiente de desenvolvimento"
        echo "  stop          - Para o ambiente de desenvolvimento"
        echo "  restart       - Reinicia o ambiente completo"
        echo "  clean         - Para e remove volumes (fresh start)"
        echo "  logs          - Mostra logs em tempo real"
        echo "  status        - Mostra status dos containers"
        echo "  restart-next  - Reinicia apenas o Next.js"
        echo "  generate-keys - Gera chaves seguras para desenvolvimento"
        echo "  validate-keys - Valida chaves existentes"
        exit 1
        ;;
esac ambiente completo"
        echo "  clean       - Para e remove volumes (fresh start)"
        echo "  logs        - Mostra logs em tempo real"
        echo "  status      - Mostra status dos containers"
        echo "  restart-next - Reinicia apenas o Next.js"
        exit 1
        ;;
esac