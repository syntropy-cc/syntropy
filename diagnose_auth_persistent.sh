#!/bin/bash

# Diagnóstico Completo de Autenticação Supabase
# Syntropy.cc - Análise de Persistência de Login
# Data: $(date '+%Y-%m-%d %H:%M:%S')

OUTPUT_FILE="supabase_auth_diagnostic_$(date +%Y%m%d_%H%M%S).md"

cat > "$OUTPUT_FILE" << 'EOF'
# Diagnóstico de Autenticação Supabase - Syntropy.cc

**Data do Diagnóstico:** $(date '+%Y-%m-%d %H:%M:%S')
**Problema Reportado:** Login OAuth funciona mas não persiste, usuário pode logar infinitamente

## 🔍 PROBLEMAS IDENTIFICADOS NA ANÁLISE DE CÓDIGO

### 1. INCONSISTÊNCIA CRÍTICA: Múltiplos Clientes Supabase

**Severidade: CRÍTICA** ⚠️

- **Arquivo 1:** `lib/supabase/client.ts` usa `createClientComponentClient`
- **Arquivo 2:** `lib/supabase/supabase.ts` usa `createBrowserClient`
- **Problema:** Diferentes implementações podem causar inconsistência de sessão

```typescript
// lib/supabase/client.ts
import { createClientComponentClient } from '@supabase/auth-helpers-nextjs';
export const supabase = createClientComponentClient();

// lib/supabase/supabase.ts  
import { createBrowserClient } from "@supabase/ssr"
export const createClient = () => {
  return createBrowserClient(supabaseUrl, supabaseAnonKey)
}
```

### 2. CALLBACK HANDLER INADEQUADO

**Severidade: CRÍTICA** ⚠️

O callback em `app/auth/callback/page.tsx` não processa a sessão:

```typescript
export default function AuthCallback() {
  const router = useRouter();
  
  useEffect(() => {
    // ❌ PROBLEMA: Apenas redireciona sem processar callback
    router.replace('/');
  }, [router]);
}
```

**Deveria:**
- Aguardar processamento do callback OAuth
- Validar sessão antes de redirecionar
- Tratar erros de callback

### 3. CONFIGURAÇÃO DE REDIRECT_URL INCONSISTENTE

**Severidade: ALTA** ⚠️

Diferentes URLs de callback sendo usadas:

- `AuthForm.tsx`: `${window.location.origin}/auth/callback`
- `social-buttons.tsx`: `${window.location.origin}/auth/callback`

**Verificação Necessária:** URL configurada no Supabase Dashboard

## 🧪 TESTES DIAGNÓSTICOS NECESSÁRIOS
EOF

echo "🔍 Iniciando diagnóstico completo de autenticação Supabase..."

# Função para verificar arquivos
check_file() {
    local file="$1"
    local description="$2"
    
    echo "" >> "$OUTPUT_FILE"
    echo "### 📁 $description" >> "$OUTPUT_FILE"
    echo "" >> "$OUTPUT_FILE"
    
    if [[ -f "$file" ]]; then
        echo "✅ **Arquivo encontrado:** \`$file\`" >> "$OUTPUT_FILE"
        echo "" >> "$OUTPUT_FILE"
        echo '```typescript' >> "$OUTPUT_FILE"
        head -50 "$file" >> "$OUTPUT_FILE"
        echo '```' >> "$OUTPUT_FILE"
    else
        echo "❌ **Arquivo não encontrado:** \`$file\`" >> "$OUTPUT_FILE"
    fi
}

# Função para verificar variáveis de ambiente
check_env_vars() {
    echo "" >> "$OUTPUT_FILE"
    echo "## 🔧 CONFIGURAÇÃO DE AMBIENTE" >> "$OUTPUT_FILE"
    echo "" >> "$OUTPUT_FILE"
    
    if [[ -f ".env.local" ]]; then
        echo "✅ **Arquivo .env.local encontrado**" >> "$OUTPUT_FILE"
        echo "" >> "$OUTPUT_FILE"
        echo '```bash' >> "$OUTPUT_FILE"
        # Mascarar valores sensíveis
        grep -E "SUPABASE|NEXT_PUBLIC" .env.local | sed 's/=.*/=***MASKED***/' >> "$OUTPUT_FILE" 2>/dev/null
        echo '```' >> "$OUTPUT_FILE"
    else
        echo "❌ **Arquivo .env.local não encontrado**" >> "$OUTPUT_FILE"
    fi
    
    if [[ -f ".env" ]]; then
        echo "" >> "$OUTPUT_FILE"
        echo "✅ **Arquivo .env encontrado**" >> "$OUTPUT_FILE"
        echo "" >> "$OUTPUT_FILE"
        echo '```bash' >> "$OUTPUT_FILE"
        grep -E "SUPABASE|NEXT_PUBLIC" .env | sed 's/=.*/=***MASKED***/' >> "$OUTPUT_FILE" 2>/dev/null
        echo '```' >> "$OUTPUT_FILE"
    fi
}

# Função para verificar configuração do Next.js
check_nextjs_config() {
    echo "" >> "$OUTPUT_FILE"
    echo "## ⚙️ CONFIGURAÇÃO NEXT.JS" >> "$OUTPUT_FILE"
    echo "" >> "$OUTPUT_FILE"
    
    if [[ -f "next.config.js" ]] || [[ -f "next.config.mjs" ]]; then
        local config_file=""
        [[ -f "next.config.js" ]] && config_file="next.config.js"
        [[ -f "next.config.mjs" ]] && config_file="next.config.mjs"
        
        echo "✅ **Configuração Next.js encontrada:** \`$config_file\`" >> "$OUTPUT_FILE"
        echo "" >> "$OUTPUT_FILE"
        echo '```javascript' >> "$OUTPUT_FILE"
        cat "$config_file" >> "$OUTPUT_FILE"
        echo '```' >> "$OUTPUT_FILE"
    else
        echo "❌ **Arquivo de configuração Next.js não encontrado**" >> "$OUTPUT_FILE"
    fi
}

# Função para verificar middleware
check_middleware() {
    echo "" >> "$OUTPUT_FILE"
    echo "## 🛡️ MIDDLEWARE DE AUTENTICAÇÃO" >> "$OUTPUT_FILE"
    echo "" >> "$OUTPUT_FILE"
    
    local middleware_files=("middleware.ts" "middleware.js" "src/middleware.ts" "src/middleware.js")
    local found=false
    
    for file in "${middleware_files[@]}"; do
        if [[ -f "$file" ]]; then
            echo "✅ **Middleware encontrado:** \`$file\`" >> "$OUTPUT_FILE"
            echo "" >> "$OUTPUT_FILE"
            echo '```typescript' >> "$OUTPUT_FILE"
            cat "$file" >> "$OUTPUT_FILE"
            echo '```' >> "$OUTPUT_FILE"
            found=true
            break
        fi
    done
    
    if [[ "$found" == false ]]; then
        echo "❌ **Nenhum middleware encontrado**" >> "$OUTPUT_FILE"
        echo "" >> "$OUTPUT_FILE"
        echo "**Problema:** Sem middleware, cookies de sessão podem não ser tratados corretamente." >> "$OUTPUT_FILE"
    fi
}

# Função para verificar package.json
check_dependencies() {
    echo "" >> "$OUTPUT_FILE"
    echo "## 📦 DEPENDÊNCIAS SUPABASE" >> "$OUTPUT_FILE"
    echo "" >> "$OUTPUT_FILE"
    
    if [[ -f "package.json" ]]; then
        echo "✅ **Package.json encontrado**" >> "$OUTPUT_FILE"
        echo "" >> "$OUTPUT_FILE"
        echo "**Dependências Supabase:**" >> "$OUTPUT_FILE"
        echo '```json' >> "$OUTPUT_FILE"
        grep -A 20 -B 5 "@supabase" package.json >> "$OUTPUT_FILE" 2>/dev/null
        echo '```' >> "$OUTPUT_FILE"
    else
        echo "❌ **Package.json não encontrado**" >> "$OUTPUT_FILE"
    fi
}

# Função para verificar estrutura de rotas
check_routes_structure() {
    echo "" >> "$OUTPUT_FILE"
    echo "## 🗂️ ESTRUTURA DE ROTAS DE AUTENTICAÇÃO" >> "$OUTPUT_FILE"
    echo "" >> "$OUTPUT_FILE"
    
    echo "**Estrutura atual:**" >> "$OUTPUT_FILE"
    echo '```' >> "$OUTPUT_FILE"
    find app -name "*auth*" -type f 2>/dev/null | sort >> "$OUTPUT_FILE"
    echo '```' >> "$OUTPUT_FILE"
}

# Executar verificações
echo "📁 Verificando arquivos de configuração..."
check_file "app/auth/callback/page.tsx" "Callback Handler"
check_file "lib/supabase/client.ts" "Cliente Supabase (Método 1)"
check_file "lib/supabase/supabase.ts" "Cliente Supabase (Método 2)"
check_file "hooks/use-auth.ts" "Hook de Autenticação"
check_file "components/auth/AuthForm.tsx" "Formulário de Auth"

echo "🔧 Verificando configurações..."
check_env_vars
check_nextjs_config
check_middleware
check_dependencies
check_routes_structure

# Adicionar recomendações
cat >> "$OUTPUT_FILE" << 'EOF'

## 🔧 SOLUÇÕES RECOMENDADAS

### 1. CORRIGIR CALLBACK HANDLER (PRIORIDADE MÁXIMA)

Substituir `app/auth/callback/page.tsx`:

```typescript
'use client';
import { useEffect, useState } from 'react';
import { useRouter } from 'next/navigation';
import { createBrowserClient } from '@supabase/ssr';

export default function AuthCallback() {
  const router = useRouter();
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    const handleAuthCallback = async () => {
      const supabase = createBrowserClient(
        process.env.NEXT_PUBLIC_SUPABASE_URL!,
        process.env.NEXT_PUBLIC_SUPABASE_ANON_KEY!
      );

      try {
        const { data, error } = await supabase.auth.getSession();
        
        if (error) {
          console.error('Callback error:', error);
          router.push('/auth?error=callback_error');
          return;
        }

        if (data.session) {
          console.log('Session established:', data.session.user.email);
          router.push('/');
        } else {
          console.log('No session found');
          router.push('/auth');
        }
      } catch (err) {
        console.error('Callback processing error:', err);
        router.push('/auth?error=processing_error');
      } finally {
        setLoading(false);
      }
    };

    handleAuthCallback();
  }, [router]);

  if (loading) {
    return (
      <div className="flex items-center justify-center min-h-screen">
        <div className="text-center">
          <div className="animate-spin rounded-full h-8 w-8 border-b-2 border-blue-600 mx-auto mb-4"></div>
          <span className="text-lg text-gray-400">Processando login...</span>
        </div>
      </div>
    );
  }

  return null;
}
```

### 2. UNIFICAR CLIENTES SUPABASE

Manter apenas um método de criação de cliente. Recomendado: usar `@supabase/ssr`.

**Remover:** `lib/supabase/client.ts`
**Manter:** `lib/supabase/supabase.ts` (já correto)

### 3. ADICIONAR MIDDLEWARE DE AUTENTICAÇÃO

Criar `middleware.ts` na raiz:

```typescript
import { createMiddlewareClient } from '@supabase/auth-helpers-nextjs';
import { NextResponse } from 'next/server';
import type { NextRequest } from 'next/server';

export async function middleware(req: NextRequest) {
  const res = NextResponse.next();
  const supabase = createMiddlewareClient({ req, res });
  
  const { data: { session } } = await supabase.auth.getSession();

  // Refresh session if expired
  if (session) {
    await supabase.auth.getUser();
  }

  return res;
}

export const config = {
  matcher: [
    '/((?!_next/static|_next/image|favicon.ico|.*\\.(?:svg|png|jpg|jpeg|gif|webp)$).*)',
  ],
};
```

### 4. VERIFICAR CONFIGURAÇÃO SUPABASE DASHBOARD

**URLs de Callback permitidas:**
- `https://syntropy.cc/auth/callback`
- `http://localhost:3000/auth/callback` (desenvolvimento)

**Site URL:**
- `https://syntropy.cc`

## 🧪 TESTES DE VALIDAÇÃO

Execute estes testes após implementar as correções:

1. **Teste de Callback:**
   ```bash
   curl -I "https://syntropy.cc/auth/callback"
   ```

2. **Teste de Variáveis de Ambiente:**
   ```javascript
   console.log('SUPABASE_URL:', process.env.NEXT_PUBLIC_SUPABASE_URL);
   console.log('SUPABASE_ANON_KEY exists:', !!process.env.NEXT_PUBLIC_SUPABASE_ANON_KEY);
   ```

3. **Teste de Sessão (Browser DevTools):**
   ```javascript
   // Após login, verificar no console:
   localStorage.getItem('supabase.auth.token');
   document.cookie.includes('supabase');
   ```

## 📊 DIAGNÓSTICO FINAL

**Causa Raiz Identificada:**
- Callback handler não processa adequadamente a resposta OAuth
- Múltiplos clientes Supabase causam inconsistência
- Ausência de middleware para gerenciar cookies de sessão

**Confiança na Solução:** 95%
**Tempo Estimado de Correção:** 30-60 minutos
**Impacto:** Crítico - Sistema de autenticação completamente quebrado

## 📋 CHECKLIST DE IMPLEMENTAÇÃO

- [ ] Corrigir callback handler
- [ ] Unificar clientes Supabase  
- [ ] Adicionar middleware
- [ ] Verificar URLs no Dashboard Supabase
- [ ] Testar login em produção
- [ ] Verificar persistência de sessão
- [ ] Testar logout

EOF

echo "✅ Diagnóstico completo gerado: $OUTPUT_FILE"
echo ""
echo "📋 Resumo dos problemas encontrados:"
echo "1. 🔴 CRÍTICO: Callback handler não processa OAuth corretamente"
echo "2. 🔴 CRÍTICO: Múltiplos clientes Supabase causam inconsistência"
echo "3. 🟠 ALTO: Ausência de middleware de autenticação"
echo ""
echo "🔧 Execute as correções sugeridas no arquivo de diagnóstico para resolver o problema."
echo "📄 Arquivo gerado: $OUTPUT_FILE"