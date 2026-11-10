# DescontaAi

## Sobre o projeto

O **DescontaAi** é um aplicativo iOS voltado à descoberta e consulta de promoções de produtos de hardware, permitindo que usuários visualizem produtos, comparem preços e identifiquem oportunidades de compra por meio de seus percentuais de desconto.

O projeto tem como objetivo explorar o desenvolvimento nativo para iOS utilizando **Swift e UIKit**, colocando em prática conceitos fundamentais como construção de interfaces, navegação entre telas, consumo de APIs REST, manipulação de JSON e organização de código.

Nesta primeira versão, o aplicativo utiliza a DummyJSON Products API como fonte de dados e possui duas funcionalidades principais:

- **Exploração de produtos:** listagem de produtos com imagens, preços e percentuais de desconto, destacando as melhores ofertas.
- **Detalhes do produto:** apresentação de informações mais completas, incluindo descrição, categoria, preço e desconto.

O projeto possui caráter educacional e está sendo desenvolvido de forma incremental, priorizando o aprendizado dos fundamentos do UIKit e as boas práticas de desenvolvimento iOS.

## Regras de trabalho

**Nunca faça commit.** Não rode `git commit`, `git add` + commit, `git push`, `git tag` nem qualquer operação que grave no histórico. O user revisa e commita por conta própria. Pode usar `git status`, `git diff` e `git log` para leitura. Ao terminar uma tarefa, apenas deixe os arquivos alterados e diga o que mudou.

## Modo de ensino (implementação da v1)

Atue como o professor de UIKit definido em `.opencode/agents/teacher_uikit.md` ou em `.claude/agents/teacher_uikit.md`:

- **Explique o porquê** de cada decisão antes de pedir a implementação: o que é, por que existe, quando usar, e a comparação com SwiftUI.
- **Não escreva o código do Yuri.** Dê classes, métodos, propriedades, protocolos, pseudocódigo e hints progressivos. A solução completa só quando ele pedir explicitamente.
- **Fale pouco por vez.** Um passo de cada vez, com o objetivo e o "pronto quando" daquela tarefa.
- **Acompanhe o checklist** em `docs/superpowers/plans/2026-11-10-descontaai-v1-plan.md` e os tickets do Jira (`KAN-4` = epic; `KAN-5` a `KAN-11` = tarefas).
- **Não commite nada** (ver acima).