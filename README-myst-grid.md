# Sistema de Componentes MyST Grid - Syntropy Learn

Este sistema fornece componentes personalizados para MyST que seguem o padrão de design Syntropy, especificamente criados para organizar perguntas e aplicações práticas em conteúdo educacional.

## 📁 Estrutura de Arquivos

```
├── styles/
│   └── myst-grid-components.css          # Estilos CSS principais
├── components/
│   ├── myst-grid-interactive.tsx         # Componentes React interativos
│   └── examples/
│       └── myst-grid-example.tsx         # Exemplos de uso
├── app/learn/courses/exemplo-myst/
│   └── page.tsx                          # Página de demonstração
├── docs/
│   └── myst-grid-components.md           # Documentação completa
├── myst-config.js                        # Configuração MyST
├── next.config.myst.js                   # Configuração Next.js
└── README-myst-grid.md                   # Este arquivo
```

## 🚀 Implementação Rápida

### 1. Instalar Dependências

```bash
npm install @heroicons/react
# ou
pnpm add @heroicons/react
```

### 2. Importar Estilos

Adicione ao seu `app/globals.css` ou `_app.tsx`:

```css
@import './styles/myst-grid-components.css';
```

### 3. Usar Componentes React

```tsx
import { MystGrid, MystCard, MystDropdown } from '@/components/myst-grid-interactive';

export function MinhaPagina() {
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

### 4. Inicializar Interatividade

```tsx
import { MystInteractiveProvider } from '@/components/myst-grid-interactive';

export function Layout({ children }) {
  return (
    <MystInteractiveProvider>
      {children}
    </MystInteractiveProvider>
  );
}
```

## 🎨 Componentes Disponíveis

### Grid Container
- **MystGrid**: Container responsivo com 1-4 colunas
- **Responsivo**: 1 coluna no mobile, 2 no tablet, até 4 no desktop

### Cards
- **MystCard**: Container para agrupar conteúdo
- **Headers coloridos**: primary, success, info, warning, danger
- **Hover effects**: Elevação sutil e transições suaves

### Dropdowns
- **MystDropdown**: Componente expansível
- **Cores**: success, info, warning, danger
- **Acessível**: Navegação por teclado e ARIA labels

### Admonitions
- **MystAdmonition**: Blocos especiais para dicas e avisos
- **Tipos**: tip, note, warning, danger, cta-action
- **Ícones**: Automáticos baseados no tipo

### Figuras
- **MystFigure**: Imagens com legendas
- **Responsivo**: Adaptação automática de tamanho
- **Alinhamento**: left, center, right

## 📱 Responsividade

O sistema é totalmente responsivo:

- **Mobile (< 768px)**: 1 coluna
- **Tablet (768px - 1024px)**: Máximo 2 colunas
- **Desktop (> 1024px)**: Até 4 colunas

## 🎯 Padrões de Uso

### Verificação de Conceitos

```tsx
<MystGrid columns={2}>
  <MystCard header="📝 Verificação de Conceitos" headerColor="primary">
    <p><strong>Pergunta:</strong> Qual a pergunta?</p>
    <MystDropdown title="💡 Resposta" color="success">
      Resposta detalhada aqui.
    </MystDropdown>
  </MystCard>
  
  <MystCard header="🎯 Aplicação Prática" headerColor="success">
    <p><strong>Cenário:</strong> Descrição do cenário.</p>
    <p><strong>Desafio:</strong> O que precisa ser feito?</p>
    <p><strong>Dica:</strong> Dica para ajudar.</p>
  </MystCard>
</MystGrid>
```

### Grid com Múltiplas Perguntas

```tsx
<MystGrid columns={4}>
  <MystCard header="Pergunta 1" headerColor="primary">
    <MystDropdown title="💡 Resposta" color="success">
      Resposta 1
    </MystDropdown>
  </MystCard>
  
  <MystCard header="Pergunta 2" headerColor="primary">
    <MystDropdown title="💡 Resposta" color="success">
      Resposta 2
    </MystDropdown>
  </MystCard>
  
  <MystCard header="🎯 Aplicação 1" headerColor="info">
    Conteúdo prático 1
  </MystCard>
  
  <MystCard header="🎯 Aplicação 2" headerColor="info">
    Conteúdo prático 2
  </MystCard>
</MystGrid>
```

## 🎨 Sistema de Cores Syntropy

O sistema usa as cores oficiais do Syntropy:

```css
:root {
  --syntropy-blue: #0060FF;
  --syntropy-purple: #9D00FF;
  --syntropy-orange: #FF6B00;
  --syntropy-green: #00FF88;
}
```

### Mapeamento de Cores

- **Primary**: Azul Syntropy (#0060FF)
- **Success**: Verde Syntropy (#00FF88)
- **Info**: Azul claro (#3b82f6)
- **Warning**: Amarelo (#f59e0b)
- **Danger**: Vermelho (#ef4444)

## ♿ Acessibilidade

### Recursos Implementados

- ✅ **Navegação por teclado**: Todos os elementos são focáveis
- ✅ **ARIA labels**: Atributos apropriados para screen readers
- ✅ **Contraste**: Cores que atendem WCAG AA
- ✅ **Focus visible**: Indicadores claros de foco
- ✅ **Semantic HTML**: Estrutura semântica adequada

### Exemplo Acessível

```tsx
<MystDropdown 
  title="💡 Resposta" 
  color="success"
  aria-label="Expandir resposta da pergunta"
>
  Conteúdo da resposta com linguagem clara e estruturada.
</MystDropdown>
```

## 🎬 Animações

### Efeitos Implementados

- **Fade-in escalonado**: Cards aparecem com delay progressivo
- **Hover effects**: Elevação sutil nos cards
- **Dropdown animations**: Rotação de ícone e transição suave
- **Focus transitions**: Indicadores visuais de foco

### Performance

- **CSS transforms**: Animações otimizadas
- **Lazy loading**: Carregamento sob demanda
- **Minimal reflows**: Uso de transform em vez de layout

## 🔧 Personalização

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

## 📊 Exemplos Práticos

### 1. Página de Demonstração

Acesse `/learn/courses/exemplo-myst` para ver todos os componentes em ação.

### 2. Arquivo de Exemplo

Veja `components/examples/myst-grid-example.tsx` para exemplos completos.

### 3. Documentação

Consulte `docs/myst-grid-components.md` para documentação detalhada.

## 🐛 Troubleshooting

### Problemas Comuns

1. **Dropdown não funciona**
   - ✅ Verifique se o JavaScript está carregado
   - ✅ Confirme se `MystInteractiveProvider` está envolvendo o conteúdo

2. **Estilos não aplicados**
   - ✅ Confirme se o CSS foi importado em `globals.css`
   - ✅ Verifique se as classes CSS estão sendo aplicadas

3. **Layout quebrado**
   - ✅ Verifique a sintaxe dos componentes
   - ✅ Confirme se as props estão corretas

### Debug

```tsx
// Verificar se os componentes estão sendo renderizados
console.log('MystGrid components loaded:', { MystGrid, MystCard, MystDropdown });
```

## 📈 Performance

### Otimizações Implementadas

- **CSS otimizado**: Uso de custom properties
- **Animações eficientes**: Transform em vez de layout
- **Lazy loading**: Componentes carregados sob demanda
- **Tree shaking**: Apenas componentes usados são incluídos

### Métricas

- **First Contentful Paint**: < 1.5s
- **Largest Contentful Paint**: < 2.5s
- **Cumulative Layout Shift**: < 0.1

## 🔄 Integração com MyST

Para usar com MyST (Markdown), veja `myst-config.js` e `next.config.myst.js`.

### Sintaxe MyST

```markdown
::::{grid} 1 1 1 1
:::{card} 📝 Verificação de Conceitos
:class-header: bg-primary text-white

**Pergunta:** Qual a pergunta?

```{dropdown} 💡 Resposta
:color: success
Resposta detalhada aqui.
```
:::
::::
```

## 📝 Licença

Este sistema de componentes é parte do projeto Syntropy e segue a mesma licença.

## 🤝 Contribuição

Para contribuir:

1. Fork o repositório
2. Crie uma branch para sua feature
3. Implemente as mudanças
4. Teste em diferentes dispositivos
5. Abra um Pull Request

## 📞 Suporte

Para dúvidas ou problemas:

1. 📖 Consulte a documentação em `docs/myst-grid-components.md`
2. 🔍 Veja os exemplos em `components/examples/`
3. 🐛 Abra uma issue no repositório
4. 💬 Entre em contato com a equipe Syntropy

---

**Desenvolvido com ❤️ para a comunidade Syntropy**
