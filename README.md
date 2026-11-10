# 🛍️ DescontaAí

Aplicativo iOS desenvolvido em **UIKit** para explorar ofertas e promoções de produtos de hardware, consumindo dados da [DummyJSON Products API](https://dummyjson.com/products).

## 📱 Sobre o projeto

O **DescontaAí** é um projeto desenvolvido com foco no aprendizado e na prática dos fundamentos do desenvolvimento iOS nativo. 

A aplicação possui uma navegação simples e intuitiva, dividida em duas telas: listagem de produtos e detalhes da oferta, utilizando `UINavigationController`.

## ✨ Funcionalidades

- **Listagem de produtos:** consumo de dados da API e exibição em uma `UITableView`, com thumbnail, nome, preço e percentual de desconto.
- **Destaque de ofertas:** identificação visual dos produtos com maiores percentuais de desconto.
- **Detalhes do produto:** visualização de imagem em destaque, descrição, preço, desconto e categoria.
- **Estados da aplicação:** tratamento de carregamento e erros durante a requisição de dados.

## 🛠️ Tecnologias e conceitos

- **UIKit:** construção das interfaces nativas.
- **UITableView:** listagem dinâmica com reutilização de células.
- **UINavigationController:** gerenciamento da navegação entre telas.
- **URLSession:** comunicação com a API REST.
- **Codable:** decodificação e mapeamento de respostas JSON.
- **Auto Layout:** construção de interfaces adaptáveis.
- **Thread Safety:** atualização da interface na main thread.
- **Separação de responsabilidades:** organização do código e das camadas da aplicação.

## 🌐 API

O projeto utiliza a [DummyJSON Products API](https://dummyjson.com/products) para obtenção dos dados dos produtos.

**Endpoint principal:**
```http
GET https://dummyjson.com/products
```

**Principais campos utilizados:**

| Campo | Descrição |
|---|---|
| `title` | Nome do produto |
| `price` | Preço |
| `discountPercentage` | Percentual de desconto |
| `thumbnail` | Imagem em miniatura |
| `description` | Descrição do produto |
| `category` | Categoria |

## 🔍 Lint (SwiftLint)

O "ESLint" do mundo Swift é o **[SwiftLint](https://github.com/realm/SwiftLint)**.
Ele já vem instalado no projeto (via Homebrew) e é configurado em `.swiftlint.yml`.

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
| `ci.yml` | push em `main`, qualquer PR, ou manual | 4 jobs: **SwiftLint**, **Build**, **Unit Tests** (`DescontaAiTests`) e **UI Tests** (`DescontaAiUITests`). Publica os `.xcresult` como artifact. |
| `nightly.yml` | todo dia às 05:00 UTC, ou manual | roda a suíte completa (unit + UI) sem depender de push. |
| `release.yml` | ao criar a tag `v*` | gera o `.xcarchive` assinado e envia para o TestFlight. |

**Runner:** `xcode-27` (imagem preview do GitHub) com Xcode 27.2, porque o projeto tem
deployment target iOS 27.2. A assinatura é desligada nos jobs de teste
(`CODE_SIGNING_ALLOWED=NO`) — no simulador não há certificado involved.

**Para o `release.yml` funcionar**, crie em *Settings → Secrets and variables → Actions*:

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
