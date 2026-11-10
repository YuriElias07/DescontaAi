DescontaAí
App iOS de estudo em UIKit para explorar promoções de hardware, consumindo a DummyJSON Products API (https://dummyjson.com/products).
Sobre o projeto
Projeto focado em praticar fundamentos do desenvolvimento iOS nativo com uma navegação simples de duas telas (lista → detalhe) usando UINavigationController.
Funcionalidades
- Lista de produtos: busca dados via URLSession + Codable e exibe em UITableView com thumbnail, nome, preço e percentual de desconto, destacando as melhores ofertas.
- Detalhe do produto: ao tocar em um item, abre uma tela com imagem em destaque, descrição, preço, desconto e categoria.
Tecnologias e conceitos
- UIKit
- UITableView com reutilização de células
- UINavigationController
- Networking com URLSession
- Decodificação de JSON com Codable
- Auto Layout, estados de loading/erro e boas práticas (UI na main thread, separação de responsabilidades)
API
- Endpoint: https://dummyjson.com/products
- Campos: title, price, discountPercentage, thumbnail, description, category
Status
🚧 Em desenvolvimento para fins de aprendizado.