# DescontaAí — v1: listagem e detalhe de ofertas

**Data:** 2026-11-10
**Status:** aprovado para planejamento
**Escopo:** primeira versão funcional do app (2 telas)

---

## 1. Intenção e por quê

O DescontaAí existe para aprender desenvolvimento iOS nativo na prática. O objetivo
não é entregar rápido: é passar pelos fundamentos do UIKit — ciclo de vida, Auto
Layout, `UITableView` e reuso de célula, `UINavigationController`, `URLSession`,
`Codable`, thread principal e separação de responsabilidades — de um jeito que dê
para explicar cada peça depois.

Consequência direta: **o código é escrito pelo Yuri**, não pelo agente. A spec
descreve o que construir e os contratos entre as partes, para que a implementação
seja um exercício guiado e não uma cópia.

Sucesso é: o app abre, lista as ofertas da DummyJSON ordenadas por desconto, abre o
detalhe de cada uma, trata carregando/erro, e o autor consegue justificar cada
decisão de código.

## 2. Objetivos

- Listagem de produtos com thumbnail, título, preço e percentual de desconto.
- Destaque visual das melhores ofertas (maior percentual de desconto).
- Tela de detalhe com imagem, título, categoria, preço, desconto e descrição.
- Navegação lista → detalhe por push, com botão de voltar nativo.
- Estados de carregando, erro (com tentar de novo) e lista vazia.
- Imagens baixadas de forma assíncrona, com cache em memória.
- Código separado em Models, Services, Views e Controllers.

## 3. Não-objetivos (v1)

- Busca, filtro, categorias, ordenação escolhida pelo usuário.
- Favoritos, carrinho, comparação de preços.
- Paginação / scroll infinito — usa o `limit` padrão da API (30 itens).
- Pull to refresh.
- Persistência offline.
- Biblioteca externa de qualquer tipo (Kingfisher, Alamofire, SnapKit).
- SwiftUI, storyboard, XIB.
- Testes automatizados de UI; testes unitários ficam opcionais.
- Localização e acessibilidade avançada (só o básico que o UIKit já entrega).

## 4. Anti-objetivos

Cenários que contam como fracasso mesmo com o app rodando:

- Atualizar a interface fora da main thread.
- `retain cycle` entre controller e closure do service.
- Imagem errada aparecendo numa célula reutilizada (race de reuso).
- Crash por `force unwrap` ou por JSON inesperado.
- Baixar a mesma imagem de novo a cada scroll.
- `ProductService` importando `UIKit`.
- Lógica de rede dentro do `UIViewController`.
- Storyboard remanescente quebrando o launch sem ninguém notar.

## 5. Restrições

- Swift + UIKit, sem dependências externas.
- Projeto Xcode existente (`DescontaAi.xcodeproj`), deployment target o que já está
  configurado.
- Fonte de dados: `https://dummyjson.com/products`
  - Resposta: `{ "products": [...], "total": 194, "skip": 0, "limit": 30 }`
  - Campos usados: `id`, `title`, `price`, `discountPercentage`, `thumbnail`,
    `description`, `category`.
- Preços vêm em **USD**: exibir com `NumberFormatter` na moeda dólar. Não converter
  para BRL — o app é sobre desconto, não câmbio.
- `price` é o preço **já com desconto**; `discountPercentage` é o percentual
  aplicado. Exibir preço atual + selo `-X%`. Não calcular preço "de" nesta versão.
- O projeto já está configurado com `SWIFT_DEFAULT_ACTOR_ISOLATION = MainActor`,
  `SWIFT_APPROACHABLE_CONCURRENCY = YES`, Swift 5 e deployment target 27.2.
  Consequência para o plano: ver §6.1.- A remoção do storyboard toca três pontos: apagar `Main.storyboard`, remover
  `UISceneStoryboardFile` do `Info.plist` e remover
  `INFOPLIST_KEY_UIMainStoryboardFile = Main` do build settings. O
  `LaunchScreen.storyboard` **permanece**.

## 6. Abordagens consideradas

**A — MVC clássico (escolhida).** `Product` + `ProductService` com completion
handler + `ProductListViewController` com `UITableViewDataSource`/`Delegate` e
célula customizada em código. Custo: mais Auto Layout manual. Ganho: cobre todos
os fundamentos que o projeto existe para ensinar.

**B — MVC com Diffable Data Source + async/await.** Menos boilerplate, mas esconde
`numberOfRows`/`cellForRowAt`/`reloadData`, que é exatamente o que se quer aprender
primeiro.

**C — MVVM com ViewModel.** Separação melhor, porém camada extra sem retorno em duas
telas e desvio do foco.

Escolha do autor: **A**. Interface em **View Code** (sem storyboard), decisão tomada
na conversa.

### 6.1 Modelo de concorrência

O projeto vem com `SWIFT_DEFAULT_ACTOR_ISOLATION = MainActor`, que obriga anotações
de concorrência em todo tipo novo. Para a v1 isso é ruído antes da base de UIKit:
o `ProductService` nasceria com `@MainActor`/`nonisolated` sem que o autor saiba
explicá-los.

Decisão (tomada pelo agente, revisável): trocar para
`SWIFT_DEFAULT_ACTOR_ISOLATION = nonisolated` e seguir o modelo clássico — o
`ProductService` chama o completion na thread da `URLSession` e o controller faz o
salto para a main thread explicitamente com `DispatchQueue.main.async`. Assim o
problema que a regra resolve é sentido na prática.

Revisitar concorrência estruturada (`@MainActor`, `async/await`) depois que as duas
telas estiverem funcionando.

## 7. Estrutura de arquivos

```
DescontaAi/
  App/
    AppDelegate.swift            (já existe, sem mudança)
    SceneDelegate.swift          (passa a montar a window com UINavigationController)
  Models/
    Product.swift                struct Product: Decodable
    ProductsResponse.swift       struct ProductsResponse: Decodable
  Services/
    ProductService.swift         protocolo + implementação URLSession
    ImageLoader.swift            download + cache em memória
  Views/
    ProductCell.swift            UITableViewCell customizada
    DiscountBadge.swift          (opcional) view do selo "-X%"
  Controllers/
    ProductListViewController.swift
    ProductDetailViewController.swift
  Support/
    Formatters.swift             NumberFormatter de moeda e de percentual
```

O grupo `DescontaAi` no projeto usa pasta sincronizada, então os arquivos novos são
incluídos no target automaticamente — não é preciso adicionar um a um no Xcode.

## 8. Contratos

```swift
struct Product: Decodable, Equatable {
    let id: Int
    let title: String
    let price: Double
    let discountPercentage: Double
    let thumbnail: String
    let images: [String]        // pode vir vazio; decodificar com default []
    let description: String
    let category: String
}

struct ProductsResponse: Decodable {
    let products: [Product]
}
```

```swift
enum ProductServiceError: Error {
    case invalidURL
    case network(Error)
    case decoding(Error)
}

protocol ProductServiceProtocol {
    func fetchProducts(completion: @escaping (Result<[Product], ProductServiceError>) -> Void)
}
```

- A implementação entrega o `completion` **na main thread**.
- `ProductService` não conhece UIKit.
- `ImageLoader` é um singleton com `NSCache<NSString, UIImage>`, entrega a imagem na
  main thread e não faz cancelamento de requisição na v1.

## 9. Comportamento das telas

**Lista** (`ProductListViewController`)

- Título da navigation bar: "DescontaAí".
- `UITableView` ocupando a tela, células com 96pt de altura, separador padrão.
- Célula: thumbnail 64×64 com cantos arredondados à esquerda; à direita, título
  (2 linhas), preço em destaque e selo de desconto.
- Ordenação: `discountPercentage` decrescente.
- Formatação de preço: `NumberFormatter` `.currency`, `currencyCode = "USD"` e locale
  `pt_BR` do device, produzindo `US$ 1.234,56`.
- Destaque: produtos com desconto ≥ 15% usam o selo em cor de ênfase (ex.: laranja);
  abaixo disso, selo neutro.
- Estados: `loading` (indicador centralizado), `loaded` (tabela), `error` (mensagem
  amigável + botão "Tentar novamente" que refaz a requisição), `empty` (mensagem).
- Toque na célula faz push do detalhe passando o `Product` já carregado.

**Detalhe** (`ProductDetailViewController`)

- `UIScrollView` + `UIStackView` vertical: imagem grande (proporção 1:1),
  categoria, título, preço + selo, descrição.
- Imagem grande usa `images.first ?? thumbnail` (a `thumbnail` é pequena demais para
  ocupar a largura da tela).
- Título da navigation bar: "Detalhe" (o título do produto já aparece no corpo).
- Botão voltar padrão do `UINavigationController`.
- Recebe o `Product` no `init`; não faz requisição própria nesta versão.

## 10. O que fica para quem implementa

- Nomes exatos de propriedades internas, cores, fontes, espaçamentos e valores de
  constraint.
- Construção das constraints (anchors vs. `NSLayoutConstraint`).
- Estrutura interna da célula e se o selo vira uma view separada.
- Uso de `UIStackView` versus constraints soltas onde for equivalente.
- Ordem de implementação e commits.

## 11. Critérios de aceite

- [ ] App abre direto na lista, sem storyboard (`Main.storyboard` removido do
      target e `UISceneStoryboardFile` ajustado no `Info.plist`).
- [ ] Lista exibe 30 produtos ordenados por desconto decrescente.
- [ ] Scroll contínuo não refaz download da mesma imagem.
- [ ] Célula reutilizada nunca mostra imagem de outro produto.
- [ ] Toque abre o detalhe com os dados do produto correto.
- [ ] Voltar retorna à lista na mesma posição de scroll.
- [ ] Em modo avião aparece erro com botão de tentar novamente, e o retry funciona.
- [ ] Nenhuma atualização de UI fora da main thread.
- [ ] Nenhum `force unwrap`, nenhum warning no build.
- [ ] `ProductService` não importa `UIKit`.

## 12. Ordem pedagógica sugerida

1. Remover storyboard e montar a window + `UINavigationController` no `SceneDelegate`.
2. `Product` e `ProductsResponse`, com um JSON de exemplo para validar o decode.
3. `ProductService` com `URLSession` + `Codable`.
4. `ProductListViewController` com tabela simples (só título e preço).
5. Célula customizada com Auto Layout.
6. `ImageLoader` com cache e proteção contra reuso.
7. `ProductDetailViewController` e navegação por push.
8. Estados de carregando/erro/vazio e polimento visual.
