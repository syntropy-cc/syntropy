import { MystRenderer } from '@/lib/myst/main';
import { MystInteractiveProvider } from '@/components/myst-grid-interactive';

const testContent = `# Teste dos Componentes Grid

Este é um arquivo de teste para verificar se os componentes MyST Grid estão funcionando corretamente.

## Teste Básico

::::{grid} 1 1 1 1
:::{card} 📝 Verificação de Conceitos
:class-header: bg-primary text-white

**Pergunta 1:** Qual a principal crítica de John Dewey ao modelo de educação tradicional?

\`\`\`{dropdown} 💡 Resposta
:color: success
Dewey criticava o modelo que trata alunos como receptores passivos de informação. A filosofia "Project-First" aborda isso diretamente ao colocar o aluno em um papel ativo, onde ele constrói conhecimento através da experiência de resolver um problema real.
\`\`\`

**Pergunta 2:** Por que aprender teoria dentro do contexto de um projeto é mais eficaz?

\`\`\`{dropdown} 💡 Resposta
:color: success
Dentro de um projeto, a teoria tem um propósito imediato e uma aplicação concreta. Isso aumenta a motivação e a retenção, pois o cérebro conecta o novo conhecimento a um problema significativo.
\`\`\`
:::

:::{card} 🎯 Aplicação Prática 1
:class-header: bg-success text-white

**Cenário:** Você quer aprender uma nova linguagem de programação.

**Desafio:** Como estruturaria seu aprendizado usando a filosofia "Project-First"?

**Dica:** Pense em um mini-projeto simples, mas completo.
:::
::::

## Teste com Grid de 2 Colunas

::::{grid} 1 1
:::{card} Card 1
:class-header: bg-info text-white

Conteúdo do primeiro card.

\`\`\`{dropdown} Dropdown 1
:color: info
Conteúdo do primeiro dropdown.
\`\`\`
:::

:::{card} Card 2
:class-header: bg-warning text-white

Conteúdo do segundo card.

\`\`\`{dropdown} Dropdown 2
:color: warning
Conteúdo do segundo dropdown.
\`\`\`
:::
::::

## Teste com Grid de 4 Colunas

::::{grid} 1 1 1 1
:::{card} Card 1
:class-header: bg-primary text-white

Conteúdo 1
:::

:::{card} Card 2
:class-header: bg-success text-white

Conteúdo 2
:::

:::{card} Card 3
:class-header: bg-info text-white

Conteúdo 3
:::

:::{card} Card 4
:class-header: bg-warning text-white

Conteúdo 4
:::
::::`;

export default function TesteGridPage() {
  return (
    <MystInteractiveProvider>
      <div className="min-h-screen bg-background">
        <div className="container mx-auto px-4 py-8">
          <h1 className="text-3xl font-bold mb-8">Teste dos Componentes MyST Grid</h1>
          
          <MystRenderer 
            content={testContent}
            courseSlug="teste"
          />
        </div>
      </div>
    </MystInteractiveProvider>
  );
}
