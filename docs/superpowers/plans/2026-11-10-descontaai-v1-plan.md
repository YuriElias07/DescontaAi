# Plano de implementação — DescontaAí v1

**Spec:** `docs/superpowers/specs/2026-11-10-descontaai-v1-design.md`
**Data:** 2026-11-10

Como funciona: você escreve o código, tarefa por tarefa. Cada tarefa tem o objetivo,
as APIs de UIKit que entram em jogo, um "pronto quando" verificável e uma pergunta de
checagem. Eu explico o conceito antes, reviso o que você escreveu e aponto o caminho
quando travar — sem entregar a solução pronta.

Regra de ouro: **não avance com o "pronto quando" falhando.** Cada tarefa é pequena de
propósito; empilhar dúvidas é o que faz o aprendizado desandar.

---

## Fase 0 — Preparar o projeto (base sem storyboard)

### T1. Ajustar as configurações de build
- Trocar `SWIFT_DEFAULT_ACTOR_ISOLATION` de `MainActor` para `nonisolated`.
- Conferir que o target continua compilando sem mudanças.

**Pronto quando:** o build passa e nenhum arquivo foi alterado ainda.

### T2. Desconectar o storyboard do launch e montar a janela
O arquivo `Main.storyboard` **fica no projeto** (reversibilidade). O que sai é o
vínculo dele com o launch:
1. `Info.plist` → *Application Scene Manifest* → remover a chave `UISceneStoryboardFile`.
2. Build Settings → `INFOPLIST_KEY_UIMainStoryboardFile` → limpar o valor `Main`.

Depois, no `SceneDelegate`: criar a `UIWindow`, definir
`UINavigationController(rootViewController: ProductListViewController())` como
`rootViewController` e chamar `makeKeyAndVisible()`.

**Conceitos:** `UIWindowScene`, `UIWindow`, `UINavigationController`, por que a window
precisa existir antes de qualquer tela.
**Pronto quando:** o app abre numa tela vazia, com a navigation bar no topo e sem crash.
**Checagem:** por que a tela não apareceria se a `window` não fosse `makeKeyAndVisible()`?

---

## Fase 1 — Modelo

### T3. `Product` e `ProductsResponse`
Criar os dois `struct` em `Models/`, conformando com `Decodable`, com os campos da spec
(incluindo `images: [String]`).

**Pronto quando:** um JSON de exemplo da DummyJSON decodifica sem erro e um `print`
mostra título, preço e desconto corretos.
**Conceitos:** `Codable`, `CodingKeys` (só se precisar), opcional vs. obrigatório.
**Checagem:** o que acontece com o decode se `images` vier ausente da resposta?

---

## Fase 2 — Rede

### T4. `ProductService`
Criar `ProductServiceError`, o protocolo `ProductServiceProtocol` e a implementação com
`URLSession.shared.dataTask`, `JSONDecoder` e completion handler entregue na main thread.

**Pronto quando:** chamando o service no `viewDidLoad` da lista, o console mostra a
contagem de produtos; em modo avião, o completion chega com `.network`.
**Conceitos:** `URLSession`, completion handler, `@escaping`, `Result`, `DispatchQueue.main`.
**Checagem:** por que o service não pode importar `UIKit`?
**Armadilha comum:** `[weak self]` ausente gerando retain cycle quando o controller
segurar o service.

---

## Fase 3 — Lista (sem imagem ainda)

### T5. Tabela simples
`ProductListViewController` com `UITableView` fixada nas bordas, `dataSource`/`delegate`,
`numberOfRowsInSection` e `cellForRowAt` usando `UITableViewCell` padrão com
`titleLabel`/`detailTextLabel`.

**Pronto quando:** 30 linhas aparecem com título e preço.
**Conceitos:** `UITableViewDataSource`, reuso (`dequeueReusableCell`), por que não criar
célula com `UITableViewCell()`.

### T6. Ordenação por desconto
Ordenar o array recebido por `discountPercentage` decrescente antes de recarregar.

**Pronto quando:** a primeira linha é o produto com maior desconto.
**Checagem:** se você ordenar dentro de `cellForRowAt`, o que quebra?

### T7. Estados de tela
Um `enum` de estado (`loading`, `loaded`, `error`, `empty`) que decide o que aparece:
`UIActivityIndicatorView`, tabela, ou uma view de erro com botão "Tentar novamente".

**Pronto quando:** abre mostrando o indicador; em modo avião mostra o erro; tocar em
"Tentar novamente" com rede de volta carrega a lista.
**Conceitos:** estado explícito em vez de flags soltas, `addSubview`/`bringSubviewToFront`.

### T8. `ProductCell`
Célula customizada em `Views/`, registrada com `register(_:forCellReuseIdentifier:)`,
com thumbnail, título, preço e selo via Auto Layout em código.

**Pronto quando:** a lista mostra a célula nova com o layout da spec (96pt de altura).
**Conceitos:** `translatesAutoresizingMaskIntoConstraints = false`, `layoutSubviews`,
`prepareForReuse`.
**Checagem:** onde ficam as constraints de uma subview criada no `init` da célula?

### T9. Selo de desconto
Selo `-X%` com cor de ênfase quando o desconto for ≥ 15%.

**Pronto quando:** o selo aparece em todos e muda de cor no limiar.
**Conceitos:** `layer.cornerRadius`, formatação com `NumberFormatter`.

---

## Fase 4 — Imagens

### T10. `ImageLoader`
Função que baixa a imagem por `URLSession` e entrega na main thread. **Sem cache** — a
v1 só precisa funcionar; baixar de novo ao rolar é aceitável.

**Pronto quando:** as thumbnails aparecem na lista.
**Conceitos:** `URLSession.shared.dataTask` retornando `Data`, `UIImage(data:)`, entrega
na main thread.
**Checagem:** por que transformar `Data` em `UIImage` fora da main thread não é problema,
mas mexer no `UIImageView` é?

### T11. Integrar na célula com proteção de reuso
Carregar a imagem na célula, guardando a URL atual: quando a resposta chegar, só aplica
se a célula ainda estiver esperando aquela URL.

**Pronto quando:** rolar rápido até o fim e voltar não mostra imagem trocada.
**Checagem:** por que comparar a URL ao invés de simplesmente setar `image` no completion?

---

## Fase 5 — Detalhe

### T12. `ProductDetailViewController`
`UIScrollView` + `UIStackView` vertical com imagem grande (`images.first ?? thumbnail`),
categoria, título, preço, selo e descrição. Recebe o `Product` no `init`.

**Pronto quando:** instanciando direto (temporariamente) a tela mostra os dados completos
de um produto, sem cortar texto nem estourar o layout no iPhone menor.

### T13. Navegação
`didSelectRowAt` faz `navigationController?.pushViewController(...)` passando o produto.

**Pronto quando:** tocar numa linha abre o detalhe certo e voltar retorna na mesma
posição de scroll.

---

## Fase 6 — Fechamento

### T14. Revisão dos critérios de aceite
Percorrer a lista do §11 da spec, item por item, com o app rodando.

### T15. Limpeza
Zero warnings no build, zero `force unwrap`, nenhum `print` esquecido, `ProductService`
sem `UIKit`.

---

## Mapa dos critérios de aceite → tarefas

| Critério (§11) | Tarefa |
|---|---|
| Abre sem storyboard | T1, T2 || 30 produtos ordenados | T5, T6 |
| Célula reutilizada correta | T11 |
| Toque abre detalhe correto | T13 |
| Voltar preserva scroll | T13 |
| Erro + retry funcionam | T7 |
| UI sempre na main thread | T4, T11 |
| Sem force unwrap / warnings | T15, transversal |
| Service sem UIKit | T4 |
