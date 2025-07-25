#!/usr/bin/env bash
set -euo pipefail

###############################################################################
# diagnose_auth.sh – verifica rede, containers e rotas de autenticação Supabase
# Autor: ChatGPT – 2025‑07‑25
###############################################################################

API_HOST="${API_HOST:-api.syntropy.cc}"   # domínio público configurado no OAuth
HTTP_PORT="${HTTP_PORT:-54321}"           # hostPort → Kong 8000
ADMIN_PORT="${ADMIN_PORT:-54320}"         # hostPort → Kong 8001 (Admin)
AUTH_CONTAINER="syntropy-auth"
KONG_CONTAINER="syntropy-kong"

divider() { printf "\n%s\n\n" "==================== $* ===================="; }

# 1. DNS / domínio público
divider "1. Resolução do domínio público ($API_HOST)"
getent hosts "$API_HOST" || echo "⚠️  Falha ao resolver $API_HOST"

# 2. Status dos containers importantes
divider "2. Containers + health‑checks"
docker ps --filter "name=syntropy-" --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}"
echo
for c in syntropy-db "$AUTH_CONTAINER" "$KONG_CONTAINER"; do
  echo -n "$c health: "
  docker inspect -f '{{.State.Health.Status}}' "$c" 2>/dev/null || echo "não definido"
done

# 3. Verifica se o host consegue falar com Kong / Auth via portas mapeadas
divider "3. Curl da máquina host → Kong (porta $HTTP_PORT) e Auth (via Host header)"
curl -s -o /dev/null -w "↳ HTTP %{http_code} (%.3fs)\n" \
     -H "Host: ${API_HOST}" "http://127.0.0.1:${HTTP_PORT}/auth/v1/health" || true

# 4. Verifica Kong Admin API
divider "4. Kong Admin API (porta $ADMIN_PORT)"
curl -s "http://127.0.0.1:${ADMIN_PORT}/status" | jq -r '.database,.server' 2>/dev/null || \
echo "⚠️  Falha ao falar com a Admin API (jq não instalado ou Kong offline)"

# 5. Teste de rede interno (dentro do Kong → Auth)
divider "5. Dentro de Kong: HTTP para http://auth:9999/health"
docker exec "$KONG_CONTAINER" curl -s -o /dev/null -w "↳ HTTP %{http_code}\n" \
             http://auth:9999/health || echo "⚠️  Falha (rede interna/outra)"

# 6. Verifica variáveis críticas no contêiner de Auth
divider "6. GOTRUE_* envs dentro de $AUTH_CONTAINER"
docker exec "$AUTH_CONTAINER" /bin/sh -c 'env | grep -E "^GOTRUE_(SITE_URL|EXTERNAL_URL|DB_DATABASE_URL|JWT_SECRET)"'

# 7. Teste rápido de conexão DB a partir do Auth
divider "7. Dentro de Auth: teste TCP para db:5432"
docker exec "$AUTH_CONTAINER" sh -c 'command -v nc >/dev/null && nc -z -w2 db 5432 && echo "↳ Porta 5432 aberta" || echo "nc não disponível – pular teste"'

# 8. Lista de rotas configuradas no Kong (filtra /auth)
divider "8. Rotas em Kong contendo /auth"
docker exec "$KONG_CONTAINER" curl -s http://localhost:8001/routes | jq -r '.data[] | select(.paths[]? | test("/auth")) | (.name + " -> " + (.paths|tostring))' 2>/dev/null || \
echo "⚠️  Não foi possível obter rotas (jq não instalado no host ou container)"

echo -e "\n🟢  Diagnóstico concluído. Copie tudo acima e envie para análise.\n"
