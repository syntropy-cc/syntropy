import { MystGrid, MystCard, MystDropdown, MystAdmonition, MystFigure } from '@/components/myst-grid-interactive';
import { MystInteractiveProvider } from '@/components/myst-grid-interactive';

/**
 * Página de exemplo mostrando como usar os componentes MyST Grid
 * em uma página de curso do Syntropy Learn
 */

export default function ExemploMystPage() {
  return (
    <MystInteractiveProvider>
      <div className="min-h-screen bg-background">
        {/* Header da página */}
        <div className="border-b border-border bg-card">
          <div className="container mx-auto px-4 py-6">
            <div className="flex items-center justify-between">
              <div>
                <h1 className="text-2xl font-bold text-foreground">
                  Exemplo de Componentes MyST Grid
                </h1>
                <p className="text-muted-foreground mt-1">
                  Demonstração dos componentes para organização de conteúdo educacional
                </p>
              </div>
              <div className="text-sm text-muted-foreground">
                Syntropy Learn
              </div>
            </div>
          </div>
        </div>

        {/* Conteúdo principal */}
        <main className="container mx-auto px-4 py-8">
          {/* Seção 1: Verificação de Conceitos */}
          <section className="mb-12">
            <h2 className="text-3xl font-bold mb-6 text-foreground">
              Testando Sua Compreensão da Mudança
            </h2>
            
            <MystGrid columns={2}>
              <MystCard header="📝 Verificação de Conceitos" headerColor="primary">
                <p className="mb-4">
                  <strong>Pergunta 1:</strong> Qual a principal crítica de John Dewey ao modelo de educação tradicional, 
                  e como a filosofia "Project-First" aborda essa crítica?
                </p>
                
                <MystDropdown title="💡 Resposta" color="success">
                  Dewey criticava o modelo que trata alunos como receptores passivos de informação. 
                  A filosofia "Project-First" aborda isso diretamente ao colocar o aluno em um papel ativo, 
                  onde ele constrói conhecimento através da experiência de resolver um problema real, 
                  alinhando-se ao princípio de "aprender fazendo".
                </MystDropdown>

                <p className="mb-4 mt-6">
                  <strong>Pergunta 2:</strong> Por que aprender teoria dentro do contexto de um projeto é, 
                  frequentemente, mais eficaz do que aprendê-la de forma isolada?
                </p>
                
                <MystDropdown title="💡 Resposta" color="success">
                  Dentro de um projeto, a teoria tem um propósito imediato e uma aplicação concreta. 
                  Isso aumenta a motivação e a retenção, pois o cérebro conecta o novo conhecimento a um 
                  problema significativo, em vez de armazená-lo como uma informação abstrata e desconectada.
                </MystDropdown>
              </MystCard>

              <MystCard header="🎯 Aplicação Prática 1" headerColor="success">
                <p className="mb-2">
                  <strong>Cenário:</strong> Você quer aprender uma nova linguagem de programação que nunca viu antes.
                </p>
                <p className="mb-2">
                  <strong>Desafio:</strong> Usando a filosofia "Project-First", como você estruturaria seu aprendizado, 
                  em contraste com a abordagem tradicional de ler toda a documentação primeiro?
                </p>
                <p className="text-sm text-muted-foreground">
                  <strong>Dica:</strong> Pense em um mini-projeto simples, mas completo (do início ao fim), 
                  que te forçaria a aprender os 80% mais importantes da linguagem para colocá-lo no ar.
                </p>
              </MystCard>
            </MystGrid>
          </section>

          {/* Seção 2: Grid com 4 colunas */}
          <section className="mb-12">
            <h2 className="text-3xl font-bold mb-6 text-foreground">
              Verificando seu Novo "GPS" de Aprendizagem
            </h2>
            
            <MystGrid columns={4}>
              <MystCard header="Pergunta 1" headerColor="primary">
                <p className="mb-4">
                  <strong>O que é "Aprendizado Situado" e qual sua relação com o aprendizado "Just-in-Time"?</strong>
                </p>
                
                <MystDropdown title="💡 Resposta" color="success">
                  "Aprendizado Situado", de Lave e Wenger, é a teoria de que o aprendizado é um processo social 
                  inseparável do contexto e da prática. O aprendizado "Just-in-Time" é uma manifestação prática 
                  dessa teoria, onde o conhecimento é adquirido e aplicado dentro do contexto autêntico de um 
                  problema real, na hora exata da necessidade.
                </MystDropdown>
              </MystCard>

              <MystCard header="Pergunta 2" headerColor="primary">
                <p className="mb-4">
                  <strong>Dê um exemplo prático de como a "Aprendizagem Cognitiva" pode ser aplicada no aprendizado de programação.</strong>
                </p>
                
                <MystDropdown title="💡 Resposta" color="success">
                  Um exemplo seria um programador sênior fazendo "pair programming" com um júnior. 
                  O sênior primeiro modela a solução de um problema (modeling), depois orienta o júnior 
                  enquanto ele tenta (coaching), oferecendo ajuda pontual (scaffolding), até que o júnior 
                  consiga resolver problemas similares sozinho. O conhecimento é passado no contexto da tarefa.
                </MystDropdown>
              </MystCard>

              <MystCard header="Pergunta 3" headerColor="primary">
                <p className="mb-4">
                  <strong>Qual a principal desvantagem do aprendizado "Just-in-Case" em comparação com o "Just-in-Time"?</strong>
                </p>
                
                <MystDropdown title="💡 Resposta" color="success">
                  A principal desvantagem do "Just-in-Case" é a baixa retenção de conhecimento. 
                  Como a informação é aprendida sem um contexto de aplicação imediata, o cérebro não a 
                  considera relevante e tende a descartá-la. O "Just-in-Time" resolve isso conectando 
                  diretamente o aprendizado à ação.
                </MystDropdown>
              </MystCard>

              <MystCard header="🎯 Aplicação Prática 1" headerColor="info">
                <p className="mb-2">
                  <strong>Cenário:</strong> Você está construindo seu projeto e se depara com a necessidade de conectar a uma API externa pela primeira vez.
                </p>
                <p className="mb-2">
                  <strong>Desafio:</strong> Em vez de ler um livro inteiro sobre APIs, como você aplicaria o "Just-in-Time Learning" para resolver essa tarefa específica de forma rápida e eficaz?
                </p>
                <p className="text-sm text-muted-foreground">
                  <strong>Dica:</strong> Foque sua pesquisa em exemplos de código que realizam a tarefa exata que você precisa.
                </p>
              </MystCard>
            </MystGrid>
          </section>

          {/* Seção 3: Admonitions */}
          <section className="mb-12">
            <h2 className="text-3xl font-bold mb-6 text-foreground">
              Exemplos de Admonitions
            </h2>
            
            <div className="space-y-6">
              <MystAdmonition type="tip" title="Dica Importante">
                Pense no "Project-First" como aprender a cozinhar. Você não lê um compêndio de química dos alimentos 
                por seis meses antes de fritar um ovo. Você decide fazer um omelete (o projeto), percebe que precisa 
                de ovos e uma frigideira (recursos), e talvez pesquise rapidamente a melhor temperatura para não queimar (teoria sob demanda).
              </MystAdmonition>

              <MystAdmonition type="cta-action" title="Sua Vez de Aplicar">
                Este é o seu ponto de partida. Guarde este documento. No decorrer do curso, você vai refiná-lo, 
                talvez até mudá-lo completamente. E está tudo bem. O objetivo deste artefato não é a perfeição, 
                mas a intenção. É o primeiro passo para sair do campo das ideias e entrar no campo da construção.
              </MystAdmonition>

              <MystAdmonition type="warning">
                O objetivo do projeto-exemplo <strong>não é</strong> que você o copie. É que você observe as decisões de design, 
                as escolhas de arquitetura e os trade-offs que fazemos. É um estudo de caso ao vivo.
              </MystAdmonition>
            </div>
          </section>

          {/* Seção 4: Figura */}
          <section className="mb-12">
            <h2 className="text-3xl font-bold mb-6 text-foreground">
              Exemplo de Figura
            </h2>
            
            <MystFigure
              src="/courses/agentes-em-producao/images/unidade0-figura1-diferenca-modelos-ensino.png"
              alt="Diagrama mostrando a diferença entre modelos de ensino tradicional e Project-First"
              caption="Este diagrama ilustra a inversão do modelo tradicional. No ensino passivo, a teoria vem primeiro e a prática (se vier) é uma aplicação isolada. No modelo 'Project-First', o projeto é o centro, e a teoria é 'puxada' conforme a necessidade, garantindo relevância e contexto imediatos."
              width="600px"
              align="center"
            />
          </section>

          {/* Seção 5: Grid responsivo */}
          <section className="mb-12">
            <h2 className="text-3xl font-bold mb-6 text-foreground">
              Grid Responsivo com Diferentes Tipos
            </h2>
            
            <MystGrid columns={3}>
              <MystCard header="Card Primário" headerColor="primary">
                <p>Este é um card com header primário. Perfeito para conteúdo principal.</p>
              </MystCard>

              <MystCard header="Card de Sucesso" headerColor="success">
                <p>Este é um card com header de sucesso. Ideal para feedback positivo.</p>
              </MystCard>

              <MystCard header="Card de Informação" headerColor="info">
                <p>Este é um card com header de informação. Bom para dicas e orientações.</p>
              </MystCard>
            </MystGrid>
          </section>
        </main>

        {/* Footer */}
        <footer className="border-t border-border bg-card mt-16">
          <div className="container mx-auto px-4 py-6">
            <div className="text-center text-muted-foreground">
              <p>&copy; 2024 Syntropy. Todos os direitos reservados.</p>
            </div>
          </div>
        </footer>
      </div>
    </MystInteractiveProvider>
  );
}
