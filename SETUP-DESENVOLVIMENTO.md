# 🚀 Setup do Ambiente de Desenvolvimento - Syntropy

Este guia te ajudará a configurar um ambiente de desenvolvimento local completo que espelha sua produção.

## 📋 Pré-requisitos

- Docker e Docker Compose instalados
- Git configurado
- Acesso ao repositório do projeto

## 🛠️ Configuração Inicial

### 1. Clone e Prepare o Projeto

```bash
# Clone o repositório (se ainda não fez)
git clone <seu-repositorio>
cd syntropy

# Torne os scripts executáveis
chmod +x dev.sh generate-keys.sh validate-keys.sh
```

### 2. Configure o Ambiente de Desenvolvimento

```bash
# Copie o arquivo de exemplo
cp .env.dev.example .env.dev

# Gere chaves seguras para desenvolvimento
./dev.sh generate-keys
# OU
./generate-keys.sh
```

### 3. Edite o arquivo .env.dev

Abra o arquivo `.env.dev` e substitua os valores `SUBSTITUA_POR_*` pelas chaves geradas:

```bash
# Exemplo do .env.dev após configuração
POSTGRES_PASSWORD=abc123def456
JWT_SECRET=sua-chave-jwt-gerada-de-32-caracteres
ANON_KEY=eyJhbGciOiJIUzI1NiI...
SERVICE_ROLE_KEY=eyJhbGciOiJIUzI1NiI...
SECRET_KEY_BASE=sua-secret-key-base-de-64-caracteres...
```

### 4. Valide as Configurações

```bash
# Valide se as chaves estão corretas
./dev.sh validate-keys
# OU
./validate-keys.sh
```

## 🚀 Executando o Ambiente

### Comandos Principais

```bash
# Iniciar ambiente completo
./dev.sh start

# Ver logs em tempo real
./dev.sh logs

# Ver status dos containers
./dev.sh status

# Parar ambiente
./dev.sh stop

# Reiniciar ambiente completo
./dev.sh restart

# Limpeza completa (remove volumes)
./dev.sh clean
```

### Comandos Específicos

```bash
# Reiniciar apenas o Next.js (para mudanças rápidas)
./dev.sh restart-next

# Gerar novas chaves
./dev.sh generate-keys

# Validar chaves existentes
./dev.sh validate-keys
```

## 🌐 Acessos Disponíveis

Após executar `./dev.sh start`, você terá acesso a:

| Serviço | URL Local | Descrição |
|---------|-----------|-----------|
| **Aplicação Next.js** | http://localhost:3000 | Sua aplicação principal |
| **API Gateway (Kong)** | http://localhost:8000 | Gateway para todas as APIs |
| **Kong Admin** | http://localhost:8001 | Painel administrativo do Kong |
| **PostgREST** | http://localhost:3001 | API REST automática |
| **GoTrue Auth** | http://localhost:9999 | Serviço de autenticação |
| **Realtime** | http://localhost:4000 | WebSockets/Realtime |
| **Storage API** | http://localhost:5000 | API de arquivos |
| **PostgreSQL** | localhost:5433 | Banco de dados |

## 🔄 Workflow de Desenvolvimento

### 1. Desenvolvimento Local
```bash
# Inicie o ambiente
./dev.sh start

# Faça suas mudanças no código
# O Next.js tem hot reload automático

# Acesse http://localhost:3000 para testar
```

### 2. Teste e Validação
```bash
# Veja os logs se algo não funcionar
./dev.sh logs

# Reinicie serviços específicos se necessário
./dev.sh restart-next
```

### 3. Deploy para Produção
```bash
# Após testar localmente
git add .
git commit -m "feature: nova funcionalidade"
git push origin main

# No servidor de produção
git pull origin main
docker-compose up --build -d
```

## 🔐 Segurança e Chaves

### ⚠️ IMPORTANTE: Ambientes Separados

- **DESENVOLVIMENTO**: Use chaves geradas pelo script
- **PRODUÇÃO**: Use chaves diferentes e seguras
- **NUNCA** use as mesmas chaves entre ambientes!

### Gerando Chaves para Produção

```bash
# Gere chaves para produção
./generate-keys.sh
# Escolha opção 2 (Produção)

# Guarde as chaves em local seguro!
# Configure no servidor de produção
```

### Validando Segurança

```bash
# Verifique se dev e prod são diferentes
./validate-keys.sh
# Escolha opção 5 (Comparar ambientes)
```

## 🐛 Solução de Problemas

### Problema: Container não inicia
```bash
# Veja os logs detalhados
./dev.sh logs

# Limpe e reinicie
./dev.sh clean
./dev.sh start
```

### Problema: Porta em uso
```bash
# Verifique se há outros containers rodando
docker ps

# Pare outros containers da aplicação
docker stop $(docker ps -q)
```

### Problema: Banco não conecta
```bash
# Verifique se o container do DB está saudável
./dev.sh status

# Reinicie apenas o banco
docker-compose -f docker-compose.dev.yml restart db
```

### Problema: Chaves inválidas
```bash
# Valide as chaves
./dev.sh validate-keys

# Se necessário, gere novas
./dev.sh generate-keys
```

## 📁 Estrutura de Arquivos

```
projeto/
├── docker-compose.yml          # Produção
├── docker-compose.dev.yml      # Desenvolvimento
├── docker-compose.override.yml # Overrides
├── Dockerfile                  # Build produção
├── Dockerfile.dev             # Build desenvolvimento
├── .env                       # Produção (não versionar!)
├── .env.dev                   # Desenvolvimento (não versionar!)
├── .env.dev.example           # Exemplo versionado
├── dev.sh                     # Script principal
├── generate-keys.sh           # Gerador de chaves
├── validate-keys.sh           # Validador de chaves
└── configs/
    ├── kong/
    │   ├── kong.yml           # Produção
    │   └── kong.dev.yml       # Desenvolvimento
    └── init-db.sql
```

## 📚 Comandos de Referência Rápida

```bash
# Setup inicial
./dev.sh generate-keys && ./dev.sh start

# Desenvolvimento diário
./dev.sh start && ./dev.sh logs

# Reset completo
./dev.sh clean && ./dev.sh start

# Verificação de segurança
./dev.sh validate-keys
```

## 🎯 Próximos Passos

1. ✅ Configure o ambiente de desenvolvimento
2. ✅ Teste todas as funcionalidades localmente
3. ✅ Configure chaves de produção diferentes
4. 🔄 Desenvolva com confiança!

---

💡 **Dica**: Mantenha este README atualizado conforme seu projeto evolui!