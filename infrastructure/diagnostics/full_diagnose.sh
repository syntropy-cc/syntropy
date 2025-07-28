#!/usr/bin/env bash
set -euo pipefail
ENV_FILE="${1:-.env.production}"
source <(grep -E '^(POSTGRES_PASSWORD|SERVICE_ROLE_KEY)=' "$ENV_FILE")

API_HOST="${API_HOST:-api.syntropy.cc}"
API_PORT=54321
DB_CONTAINER="syntropy-db"
PSQL="docker exec -i ${DB_CONTAINER} psql -U postgres -d postgres -qtAX -c"

div(){ printf "\n==== %s ====\n" "$1"; }

div "Containers & Health"
docker ps --filter name=syntropy- --format "table {{.Names}}\t{{.Status}}"

div "REST via Kong"
/usr/bin/curl -s -o /dev/null -w "%{http_code}\n" \
  -H "Host: $API_HOST" "http://127.0.0.1:${API_PORT}/rest/v1/?select=1"

div "Roles existentes"
$PSQL "SELECT rolname FROM pg_roles WHERE rolname IN ('supabase_admin','authenticator','service_role');" | sed 's/^/ • /'

div "Contagem de usuários"
$PSQL "SELECT count(*) FROM auth.users;" || echo "tabela users ausente"

div "Admin /auth/v1/admin/users (limit=1)"
if [[ -n "$SERVICE_ROLE_KEY" ]]; then
  curl -s -H "apikey: $SERVICE_ROLE_KEY" \
       -H "Authorization: Bearer $SERVICE_ROLE_KEY" \
       "http://127.0.0.1:${API_PORT}/auth/v1/admin/users?limit=1" | jq .
else
  echo "SKIP: defina SERVICE_ROLE_KEY"
fi
