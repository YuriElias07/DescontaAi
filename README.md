# 🛍️ DescontaAí

Aplicativo iOS desenvolvido em **UIKit** para explorar ofertas e promoções de produtos de hardware, consumindo dados da [DummyJSON Products API](https://dummyjson.com/products).

## 📱 Sobre o projeto

O **DescontaAí** é um projeto desenvolvido com foco no aprendizado e na prática dos fundamentos do desenvolvimento iOS nativo.

A aplicação possui uma navegação simples e intuitiva, dividida em três telas: listagem de produtos, detalhes da oferta e sacola. A navegação entre lista e detalhe usa `UINavigationController`; a sacola abre como modal, também dentro de um `UINavigationController`.

O projeto usa o formato novo de projeto do Xcode 27 (`DescontaAi.xcodeproj/project.xcproj`), então precisa do **Xcode 27** para abrir.

## ✨ Funcionalidades

- **Listagem de produtos:** consumo de dados da API e exibição em uma `UITableView`, com thumbnail, nome, preço, preço original riscado e percentual de desconto.
- **Destaque de ofertas:** o produto com maior desconto ganha um card maior no topo da lista ("Maior desconto da lista"), e o restante aparece em uma segunda seção, ordenado do maior desconto para o menor.
- **Detalhes do produto:** imagem em destaque, categoria, título, preço, quanto você economiza e descrição.
- **Sacola:** adicionar e remover produtos, ver o total, limpar tudo e abrir a sacola direto da tela de detalhes pelo botão "Ver carrinho".
- **Estados da aplicação:** carregamento, erro com botão "Tentar de novo" e lista vazia com estado de "sacola vazia".

## 🛠️ Tecnologias e conceitos

- **UIKit:** construção das interfaces nativas, sem storyboard nas telas (apenas o `LaunchScreen`).
- **UITableView:** listagem dinâmica com reutilização de células (`dequeueReusableCell` + `prepareForReuse`).
- **UINavigationController:** gerenciamento da navegação entre telas.
- **Auto Layout programático:** constraints e `UIStackView` para layouts adaptáveis.
- **URLSession:** comunicação com a API REST e carregamento assíncrono das imagens.
- **Codable:** decodificação e mapeamento de respostas JSON.
- **NotificationCenter:** aviso de "sacola mudou" para as telas se atualizarem sem se conhecerem.
- **Singleton:** `WishlistService.shared` como fonte única do estado da sacola.
- **Thread Safety:** atualização da interface sempre na main thread.
- **Design System:** cores, fontes e formatação de preço centralizadas em `DesignSystem`.
- **Testes:** Swift Testing (`import Testing`) no alvo `DescontaAiTests`.
- **Separação de responsabilidades:** controllers cuidam da tela, células só desenham, services cuidam de rede e estado.

## 🌐 API

O projeto utiliza a [DummyJSON Products API](https://dummyjson.com/products) para obtenção dos dados dos produtos.

**Endpoint principal:**
```http
GET https://dummyjson.com/products?limit=0
```

O `limit=0` traz todos os produtos. Depois do decode, o app filtra apenas as categorias de hardware: `laptops`, `smartphones`, `tablets` e `mobile-accessories`.

**Principais campos utilizados:**

| Campo | Descrição |
|---|---|
| `id` | Identificador do produto |
| `title` | Nome do produto |
| `price` | Preço |
| `discountPercentage` | Percentual de desconto |
| `thumbnail` | Imagem em miniatura |
| `images` | Imagens em tamanho maior (usada no destaque e no detalhe) |
| `description` | Descrição do produto |
| `category` | Categoria |

## 🔍 Lint (SwiftLint)

O "ESLint" do mundo Swift é o **[SwiftLint](https://github.com/realm/SwiftLint)**.
Ele é instalado na máquina de dev (via Homebrew) e configurado em `.swiftlint.yml`.

### Comandos

```bash
make lint        # ou ./scripts/lint.sh check   → mostra erros e avisos
make lint-fix    # ou ./scripts/lint.sh fix     → corrige o que der e re-linta
make lint-errors # ou ./scripts/lint.sh errors  → só o que bloqueia o commit
```

Você também pode passar arquivos específicos:

```bash
./scripts/lint.sh check DescontaAi/AppDelegate.swift
```

### Hook de pre-commit

```bash
make hooks   # git config core.hooksPath .githooks
```

Depois de instalado, **todo commit** roda o SwiftLint automaticamente nos
arquivos `.swift` que estão no stage:

1. o SwiftLint aplica as correções automáticas (`--fix`) e re-adiciona os
   arquivos alterados ao stage;
2. se restar alguma violação de severidade **error**, o commit é bloqueado;
3. violações de severidade **warning** apenas são exibidas, sem bloquear.

O hook vive em `.githooks/pre-commit` (versionado) e é ativado pelo
`core.hooksPath`, então ele funciona para qualquer clone do repositório
depois de `make hooks`.

> Nota: `core.hooksPath` é configuração local do git (não versionada). Rode
> `make hooks` uma vez em cada máquina.

## 🧪 CI/CD (GitHub Actions)

Os workflows ficam em `.github/workflows/`:

| Workflow | Quando roda | O que faz |
|---|---|---|
| `ci.yml` | push em `main`/`develop`, qualquer PR, ou manual | 3 jobs: **SwiftLint**, **Build** e **Unit Tests** (`DescontaAiTests`). Publica o `.xcresult` como artifact. |
| `nightly.yml.disabled` | — | desativado; rodava a suíte completa todo dia às 05:00 UTC. |
| `release.yml.disabled` | — | desativado; gerava o `.xcarchive` assinado para o TestFlight. |

O job de **UI Tests** (`DescontaAiUITests`) existe no `ci.yml`, mas está comentado: a suíte hoje só mede tempo de launch, e rodar UI test no CI é caro e instável.

**Runner:** `xcode-27` (imagem preview do GitHub) com Xcode 27.2 e simulador iPhone 17 / iOS 27.2 — obrigatório porque o projeto usa o formato novo do Xcode 27 e tem deployment target iOS 27.2.

Dois detalhes que evitam falha no CI:

- o job de testes **sobe o simulador antes** (`xcrun simctl boot` + `simctl bootstatus -b`). Sem isso, o `xcodebuild` tenta falar com o app de teste enquanto o simulador ainda está iniciando e cai com *"Channel disconnected"*.
- `CODE_SIGNING_ALLOWED=NO` fica só no job de **Build**. No simulador não existe certificado, mas o bundle de teste precisa de assinatura ad-hoc para ser instalado.

**Para o `release.yml` funcionar** (quando for reativado), crie em *Settings → Secrets and variables → Actions*:

- `ASC_KEY_ID` — App Store Connect → Users and Access → Keys
- `ASC_ISSUER_ID` — ID do issuer da mesma chave
- `ASC_PRIVATE_KEY` — conteúdo do arquivo `.p8` da chave

Usage local equivalente:

```bash
xcodebuild test \
  -project DescontaAi.xcodeproj \
  -scheme DescontaAi \
  -destination 'platform=iOS Simulator,name=iPhone 17,OS=27.2' \
  -only-testing:DescontaAiTests
```

## 🚧 Status do projeto

Em desenvolvimento.

Projeto de estudo com foco no aprofundamento dos fundamentos do desenvolvimento iOS nativo utilizando Swift e UIKit.
