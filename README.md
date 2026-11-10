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

## 🚧 Status do projeto

Em desenvolvimento.

Projeto de estudo com foco no aprofundamento dos fundamentos do desenvolvimento iOS nativo utilizando Swift e UIKit.
