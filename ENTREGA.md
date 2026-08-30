# Entrega — Pokédex SwiftUI

## Como abordei o projeto

Antes de começar a implementar, eu tentei entender o fluxo que o starter já propunha: `View → ViewModel → UseCase → Repository → HTTPClient`. A separação fazia sentido para o tamanho da prova, então minha escolha foi **não reestruturar o projeto por reestruturar**. Mantive esse fluxo e fui alterando a base apenas quando apareceu uma necessidade concreta.

O principal ponto estrutural que mudei foi a criação das dependências. No starter, o `PokemonListViewModel` montava o próprio repositório no `init`. Para uma única tela isso era suficiente, mas deixou de ser interessante quando lista e detalhe passaram a precisar dos mesmos dados. Criei `AppDependencies` como composition root para compartilhar uma única instância de `RemotePokemonRepository` e, consequentemente, o mesmo cache entre os fluxos.

## Tarefa 1 — Paginação

Usei o `loadNextPageIfNeeded(displayingRowAt:)` que já estava preparado no starter e mantive no ViewModel o estado necessário para a paginação: `offset`, `hasNextPage` e `isLoadingNextPage`.

Escolhi antecipar a próxima requisição quando o usuário entra nos **últimos cinco itens**, em vez de esperar chegar exatamente ao final. O `max(rows.count - 5, 0)` existe para o cálculo continuar válido mesmo em listas menores que cinco itens. Também usei uma flag de carregamento com `defer` para impedir requisições concorrentes da mesma página quando várias linhas aparecem quase ao mesmo tempo.

Na primeira carga e no refresh, um erro substitui a tela por `.failure`. Já durante a paginação preferi preservar o conteúdo que o usuário já conseguiu carregar em vez de derrubar a lista inteira. Hoje essa falha é silenciosa e esse é um ponto que eu melhoraria: adicionaria um erro não bloqueante no final da lista, com retry, sem perder os Pokémon já exibidos.

## Tarefa 2 — Completar a linha

Essa foi a decisão que mais precisei avaliar por causa do formato da PokéAPI. A listagem entrega apenas `name` e `url`, então número, sprite e tipos exigem uma requisição de detalhe para cada Pokémon.

Considerei publicar as linhas progressivamente conforme cada detalhe chegasse. Descartei essa abordagem porque ela deixava a lista visualmente instável e poderia mostrar informações incompletas. Preferi tratar cada página como uma unidade: busco os detalhes dos Pokémon de forma concorrente com `TaskGroup` e só publico a página quando os dados daquela página estão prontos.

Essa escolha aumentou o tempo perceptível de loading, principalmente na primeira carga. Por isso também trabalhei esse estado na UI: substituí o `ProgressView` por uma pokébola animada e adicionei curiosidades sobre Pokémon durante a espera, para que esse tempo não parecesse apenas um bloqueio da interface. O trade-off da estratégia é que uma falha em um dos detalhes pode fazer a carga daquela página falhar inteira; para o escopo da prova, preferi manter as linhas completas e consistentes.

Como as requisições terminam em ordens diferentes, cada task carrega também o índice original da entrada e eu reordeno o resultado antes de atualizar o estado. Fiz isso de propósito em vez de ordenar pelo `id`: quero preservar a ordem devolvida pela listagem da API, sem depender de uma relação que hoje funciona, mas não faz parte do contrato do meu código.

O `RemotePokemonRepository` passou a ser um `actor` porque as requisições de detalhe são concorrentes e compartilham o mesmo cache. Usei um dicionário `[Int: PokemonDetail]`, já que o acesso posterior é sempre pelo id. Esse cache também passou a ser útil na Tarefa 3.

Também renomeei `PokemonSummary` para `PokemonListEntry`. O nome anterior me dava a impressão de um modelo já enriquecido, mas ele representa apenas a entrada crua da listagem (`name` + `detailURL`).

## Tarefa 3 — Detalhe

Para a navegação escolhi **push**, não sheet. A lista já usava `NavigationStack` e o chevron comunicava uma navegação hierárquica para um detalhe; manter o push me pareceu mais coerente com o restante da interface e dá o comportamento de voltar nativo.

Mesmo depois de a Tarefa 2 já ter buscado o detalhe, mantive o fluxo `ViewModel → UseCase → Repository` na tela nova. Como lista e detalhe compartilham o mesmo repositório, normalmente o detalhe é devolvido do cache e não gera outra chamada de rede. Preferi manter o mesmo fluxo de acesso aos dados entre as telas em vez de criar um caminho específico apenas para o detalhe.

Usei TDD principalmente nas partes em que consegui separar uma regra determinística da UI. Para altura, peso e stats, escrevi os casos dos formatters antes da implementação e segui o ciclo red → green. Também acrescentei testes do `FetchPokemonDetailUseCase` com stub de repositório. Não testei SwiftUI, porque a prioridade aqui foi cobrir transformação de dados e regras sem acoplar os testes à composição visual da tela.

## Tarefa 4 — Meu Time

Aqui segui o TDD de forma mais completa. Escrevi os testes de `DefaultManageTeamUseCase` usando um `TeamRepositoryStub` em memória antes de implementar as regras reais; depois fiz o green do use case e só então liguei a tela.

Implementei o contrato mínimo pedido no README: um Pokémon não pode ser adicionado duas vezes pelo mesmo `id` e o time tem no máximo `Team.maxSize` (6) membros. Mantive esses critérios no use case, sem colocar regra de negócio no `UserDefaultsTeamRepository` ou na View.

O starter tinha `id`, `name` e `spriteURL` em `TeamMember`. Acrescentei `types` porque o resumo do time precisa mostrar os tipos cobertos e eu não queria abrir “Meu Time” disparando novas requisições de rede. No momento da adição, esses dados já existem no `PokemonDetail` carregado.

No `TeamSummary`, implementei `count` e `coveredTypes`. Os tipos são apresentados sem repetição e mantendo a ordem em que aparecem nos membros do time.

A tela de time usa `TeamView` + `TeamViewModel`, reaproveita `StateView` no estado vazio, permite remover por swipe e mostra o resumo no cabeçalho. Também extraí `PokemonTypeTag` para `View/Common/`, porque a mesma representação visual de tipo passou a existir na lista, no detalhe e no time. A persistência existente em `UserDefaultsTeamRepository` foi mantida sem alterações.

A regra adicional de impedir Pokémon com o mesmo tipo principal ficou como melhoria futura no `TODO.md`. Além de não fazer parte do contrato mínimo, ela exigiria definir explicitamente o que o domínio considera como tipo principal. Para esta entrega, priorizei as regras obrigatórias de duplicidade por `id` e limite de seis membros.

## Outras decisões

A animação da pokébola foi feita com `ImageIO`/UIKit, sem biblioteca externa, e respeita `accessibilityReduceMotion`.

Também acrescentei labels combinados de acessibilidade nas linhas e no time. Não era uma tarefa obrigatória, mas achei importante não deixar a informação visual de número e tipos dependente apenas do layout.

## O que eu mudaria no que já existia

No geral, eu manteria a arquitetura do starter. O ponto que começou a me incomodar foi o ViewModel criar a própria infraestrutura, porque isso dificultaria compartilhar cache e dependências conforme o app crescesse; foi por isso que extraí `AppDependencies`.

Ainda há um ponto da minha própria solução que eu melhoraria: `PokemonListView` recebe `fetchDetail` e `manageTeam` para conseguir construir os ViewModels das telas de destino. Funciona, mas deixa a View conhecendo dependências que não são usadas para desenhar a lista. Com mais tempo eu moveria essa criação para uma factory/composition root, ou faria a navegação transportar o modelo já carregado quando isso fosse suficiente.

## O que ficou de fora

Priorizei concluir as quatro tarefas antes dos bônus. Ficaram de fora o cache de imagens em `PokemonImage`, busca por nome e animação de entrada do detalhe. Também não implementei o banner de erro da paginação nem a regra extra de tipo principal repetido.

Nos testes, o principal ponto que ainda falta é `PokemonListViewModel`. Diferente de uma View que só desenha, ele passou a concentrar comportamento de paginação, append, threshold e controle de concorrência; por isso considero esses testes uma próxima etapa importante e deixei os cenários planejados no `TODO.md`.

## Com mais tempo

Minha ordem de prioridade seria: testar a paginação do `PokemonListViewModel`; melhorar o tratamento de erro da próxima página sem apagar a lista; simplificar a criação do detalhe/dependências de navegação; deduplicar requisições de detalhe que estejam em andamento para o mesmo id; e implementar cache de imagens.
