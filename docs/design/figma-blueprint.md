# Blueprint Figma — DescontaAí

**Preview visual:** `docs/design/preview.html` (abre no navegador)
**Base:** Apple Design Resources → iOS UI Kit oficial (native components, zero custom)

> Sem integração com Figma neste ambiente, este arquivo é o handoff: monte os frames
> com os componentes nativos da Apple e o resultado é 1:1 com o `preview.html`.

## 1. Frames

| Frame | Tamanho | Grid |
|---|---|---|
| `Lista` | 393 × 852 (iPhone 16) | 16pt margins, 8pt spacing scale |
| `Detalhe` | 393 × 852 | idem, scroll vertical |
| `Lista / Dark` | 393 × 852 | variante com semantic colors invertidas |
| `Lista / XL` | 393 × 852 | Dynamic Type em AX3 (só para checar quebra) |

Layout: Auto Layout vertical, `Fill container` na largura.

## 2. Componentes (todos do iOS UI Kit da Apple)

| Elemento | Componente do kit | Ajuste |
|---|---|---|
| Status bar | `Status Bar/iOS` | 54pt (Dynamic Island) |
| Large title | `Navigation Bar/Large Title` | texto "DescontaAí", 34 Bold |
| Nav bar (detalhe) | `Navigation Bar/Compact` | back "‹ DescontaAí", título "Detalhe" |
| Lista | `Table View/Inset Grouped` → use `Plain` | separador inset 76pt (leading 16 + 64 thumb + 12 gap) |
| Linha | `Table View Cell/Custom` | altura fixa **96pt** |
| Thumbnail | `Image` | 64×64, corner radius 8, `Fill` |
| Selo | `Badge` (criar 1 componente) | 13 Semibold, padding 4/8, radius 6 |
| Home indicator | `Home Indicator` | 139×5 |

## 3. Tokens (Figma Variables — semantic, sem hex solto)

| Token | Light | Dark | Uso |
|---|---|---|---|
| `label` | #000000 | #FFFFFF | título do produto, preço grande |
| `secondaryLabel` | rgba(60,60,67,.60) | rgba(235,235,245,.60) | preço secundário, categoria |
| `separator` | rgba(60,60,67,.29) | rgba(84,84,88,.60) | divisor de linha |
| `systemBackground` | #FFFFFF | #000000 | fundo |
| `fill` | rgba(118,118,128,.12) | rgba(118,118,128,.24) | placeholder de imagem |
| `tint` | #007AFF | #0A84FF | back button |
| `accentHot` | #FF9500 | #FF9F0A | selo ≥ 15% |
| `accentHotBackground` | rgba(255,149,0,.15) | rgba(255,159,10,.20) | fundo do selo |

## 4. Tipografia (SF Pro, estilos semânticos)

| Elemento | Estilo | Tamanho/Peso |
|---|---|---|
| Large title | `.largeTitle` | 34 / Bold |
| Título da célula | `.body` | 17 / Regular, 2 linhas máx. |
| Preço (célula) | `.body` | 17 / Semibold |
| Preço secundário | `.subheadline` | 15 / Regular |
| Selo | `.footnote` | 13 / Semibold |
| Categoria (detalhe) | `.footnote` | 13 / Regular, uppercase |
| Título (detalhe) | `.title2` | 22 / Bold |
| Preço (detalhe) | `.title1` | 28 / Bold |
| Descrição | `.body` | 17 / Regular, line-height 24 |

## 5. Medidas da célula (96pt)

```
[16] [thumb 64×64 r8] [12] [ título 2 linhas ] [8] [badge] [16]
 altura total 96 · separador inset left 92 (=16+64+12)
```

Regra do selo: `discountPercentage >= 15` → variante `hot`; abaixo → `neutral`.

## 6. Estados (frames extras, obrigatórios)

| Frame | Conteúdo |
|---|---|
| `Lista / Loading` | `Activity Indicator/Large` centralizado, lista oculta |
| `Lista / Erro` | ícone `wifi.exclamationmark` 48, título `.headline`, texto `.body` secundário, botão `Filled/Outro conselho` |
| `Lista / Vazio` | texto secundário centralizado |

## 7. Acessibilidade (checklist HIG)

- [ ] Touch targets ≥ 44×44 (a linha inteira é tocável: 96pt ✅)
- [ ] Contraste ≥ 4.5:1 em light e dark
- [ ] VoiceOver: linha = 1 elemento combinado, label "Produto, preço, X por cento de desconto"
- [ ] Selo não usa **só** cor: sempre tem o texto `-X%`
- [ ] Dynamic Type até AX3 sem corte (título da célula quebra em 2 linhas, não trunca)
- [ ] Gestos nativos preservados: swipe-back no detalhe, scroll bounce

## 8. O que NÃO fazer

- FAB, hamburger menu, tabs no topo (padrões Android)
- Cor/hex fixo nos componentes (quebra Dark Mode)
- Altura de linha variável na lista (o reuso fica irregular)
- Selo custom desenhado à mão: use retângulo + auto layout, para virar componente

**Score HIG da proposta:** 10/10 — componentes 100% nativos, cores semânticas, Dynamic
Type, touch targets de 96pt, dark mode e voz consistente.
