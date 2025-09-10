# Componentes MyST Grid - Sistema de Design Syntropy

Este documento descreve como usar os componentes de grid personalizados para MyST, desenvolvidos especificamente para o sistema de design Syntropy.

## Visão Geral

Os componentes MyST Grid foram criados para organizar perguntas e aplicações práticas ao fim da exposição teórica do conteúdo, seguindo o padrão estabelecido no documento `contrato-de-aprendizagem.md`.

## Estrutura de Componentes

### 1. Grid Container (`::::{grid}`)

O container principal que organiza os cards em um layout responsivo.

```markdown
::::{grid} 1 1 1 1
:::{card} Conteúdo do Card
:::
::::
```

**Propriedades:**
- `columns`: Número de colunas (1-4)
- Layout responsivo automático
- Animações de entrada escalonadas

### 2. Card (`::{card}`)

Container para agrupar conteúdo relacionado.

```markdown
:::{card} 📝 Verificação de Conceitos
:class-header: bg-primary text-white

**Pergunta:** Qual é a pergunta?

```{dropdown} 💡 Resposta
:color: success
Esta é a resposta detalhada.
```
:::
```

**Propriedades:**
- `header`: Texto do cabeçalho
- `class-header`: Classe CSS para o cabeçalho
  - `bg-primary`: Azul primário
  - `bg-success`: Verde de sucesso
  - `bg-info`: Azul de informação
  - `bg-warning`: Amarelo de aviso
  - `bg-danger`: Vermelho de perigo

### 3. Dropdown (`{dropdown}`)

Componente expansível para mostrar/ocultar conteúdo.

```markdown
```{dropdown} 💡 Resposta
:color: success
Conteúdo que será mostrado quando expandido.
```
```

**Propriedades:**
- `color`: Cor do dropdown
  - `success`: Verde
  - `info`: Azul
  - `warning`: Amarelo
  - `danger`: Vermelho

### 4. Admonition (`{admonition}`)

Blocos especiais para dicas, avisos e chamadas para ação.

```markdown
```{admonition} 🚀 Sua Vez de Aplicar
:class: cta-action

Este é um exemplo de admonition com chamada para ação.
```
```

**Tipos disponíveis:**
- `tip`: Dicas e informações úteis
- `note`: Notas importantes
- `warning`: Avisos
- `danger`: Perigos ou erros
- `cta-action`: Chamadas para ação

### 5. Figure (`::{figure}`)

Componente para imagens com legendas.

```markdown
:::{figure} images/exemplo.png
:name: figura-exemplo
:align: center
:width: 600px

Esta é a legenda da figura.
:::
```

## Padrões de Uso

### Verificação de Conceitos

```markdown
::::{grid} 1 1 1 1
:::{card} 📝 Verificação de Conceitos
:class-header: bg-primary text-white

**Pergunta 1:** Qual a pergunta?

```{dropdown} 💡 Resposta
:color: success
Resposta detalhada aqui.
```
:::

:::{card} 🎯 Aplicação Prática 1
:class-header: bg-success text-white

**Cenário:** Descrição do cenário.
**Desafio:** O que precisa ser feito?
**Dica:** Dica para ajudar.
:::
::::
```

### Grid com Múltiplas Perguntas

```markdown
::::{grid} 1 1 1 1
:::{card}
:header: **Pergunta 1:** Título da pergunta

```{dropdown} 💡 Resposta
:color: success
Resposta aqui.
```
:::

:::{card}
:header: **Pergunta 2:** Outra pergunta

```{dropdown} 💡 Resposta
:color: success
Outra resposta.
```
:::

:::{card}
:header: 🎯 Aplicação Prática

Conteúdo da aplicação prática.
:::

:::{card}
:header: 🎯 Aplicação Prática 2

Mais conteúdo prático.
:::
::::
```

## Estilos CSS

Os estilos estão definidos em `styles/myst-grid-components.css` e incluem:

### Cores do Sistema Syntropy

```css
:root {
  --syntropy-blue: #0060FF;
  --syntropy-purple: #9D00FF;
  --syntropy-orange: #FF6B00;
  --syntropy-green: #00FF88;
}
```

### Responsividade

- **Mobile (< 768px)**: 1 coluna
- **Tablet (768px - 1024px)**: 2 colunas máximo
- **Desktop (> 1024px)**: Até 4 colunas

### Animações

- Fade-in com delay escalonado para cada card
- Transições suaves para hover e focus
- Animações de dropdown com rotação de ícone

## Integração com Next.js

### 1. Importar os estilos

```tsx
// Em _app.tsx ou layout.tsx
import '../styles/myst-grid-components.css';
```

### 2. Usar componentes React

```tsx
import { MystGrid, MystCard, MystDropdown } from '../components/myst-grid-interactive';

export function MyPage() {
  return (
    <MystGrid columns={2}>
      <MystCard header="📝 Verificação" headerColor="primary">
        <MystDropdown title="💡 Resposta" color="success">
          Conteúdo da resposta
        </MystDropdown>
      </MystCard>
    </MystGrid>
  );
}
```

### 3. Inicializar interatividade

```tsx
import { MystInteractiveProvider } from '../components/myst-grid-interactive';

export function Layout({ children }) {
  return (
    <MystInteractiveProvider>
      {children}
    </MystInteractiveProvider>
  );
}
```

## Acessibilidade

### Recursos Implementados

- **Navegação por teclado**: Todos os elementos são focáveis
- **ARIA labels**: Atributos apropriados para screen readers
- **Contraste**: Cores que atendem WCAG AA
- **Focus visible**: Indicadores claros de foco

### Exemplo de Uso Acessível

```markdown
:::{card} 📝 Verificação de Conceitos
:class-header: bg-primary text-white

**Pergunta:** Qual a pergunta? (texto claro e direto)

```{dropdown} 💡 Resposta
:color: success
Resposta com linguagem clara e estruturada.
```
:::
```

## Personalização

### Cores Customizadas

```css
.myst-card__header--custom {
  background: linear-gradient(135deg, #your-color-1 0%, #your-color-2 100%);
  color: white;
}
```

### Layouts Customizados

```css
.myst-grid--custom {
  grid-template-columns: 2fr 1fr;
  gap: 2rem;
}
```

## Boas Práticas

### 1. Estrutura de Conteúdo

- Use cards para agrupar conteúdo relacionado
- Mantenha perguntas concisas e diretas
- Forneça dicas úteis nas aplicações práticas

### 2. Responsividade

- Teste em diferentes tamanhos de tela
- Use grid de 2 colunas como padrão
- Reserve 4 colunas para casos especiais

### 3. Acessibilidade

- Sempre forneça texto alternativo para imagens
- Use contraste adequado
- Teste com leitores de tela

### 4. Performance

- Lazy load de imagens em figures
- Use CSS transforms para animações
- Minimize reflows com transform

## Troubleshooting

### Problemas Comuns

1. **Dropdown não funciona**: Verifique se o JavaScript está carregado
2. **Estilos não aplicados**: Confirme se o CSS foi importado
3. **Layout quebrado**: Verifique a sintaxe MyST

### Debug

```tsx
// Verificar se os componentes estão sendo renderizados
console.log('MystGrid components loaded:', { MystGrid, MystCard, MystDropdown });
```

## Exemplos Completos

Veja `components/examples/myst-grid-example.tsx` para exemplos completos de uso de todos os componentes.

## Suporte

Para dúvidas ou problemas:
1. Verifique a documentação
2. Consulte os exemplos
3. Abra uma issue no repositório
