# Entrega — Pokédex SwiftUI

## Como abordei o projeto

Antes de implementar, procurei entender o fluxo que o starter já propunha: `View → ViewModel → UseCase → Repository → HTTPClient`. A separação fazia sentido para o tamanho da prova, então preferi não reestruturar o projeto só por reestruturar. Mantive a base e fui mudando o que começou a limitar as próximas tarefas.

O principal ponto estrutural que alterei foi a criação das dependências. No starter, o `PokemonListViewModel` montava o próprio repositório no `init`. Isso funcionava para uma única tela, mas deixou de ser interessante quando lista e detalhe passaram a consumir os mesmos dados. Criei `AppDependencies` como composition root para compartilhar uma única instância de `RemotePokemonRepository` e, com ela, o mesmo cache.

Nos testes, segui TDD principalmente onde havia regra ou transformação determinística. Minha ideia foi testar o que eu conseguia isolar bem de SwiftUI e deixar a parte visual fora dos testes unitários.

## Tarefa 1 — Paginação

Usei o `loadNextPageIfNeeded(displayingRowAt:)` que já estava preparado no starter e mantive no ViewModel o estado necessário para a paginação: `offset`, `hasNextPage` e `isLoadingNextPage`.

Escolhi antecipar a próxima requisição quando o usuário entra nos últimos cinco itens, em vez de esperar chegar exatamente ao fim. O `max(rows.count - 5, 0)` mantém o cálculo válido mesmo se a lista tiver menos de cinco elementos. Também uso uma flag de carregamento com `defer` para impedir que várias linhas aparecendo quase ao mesmo tempo iniciem a mesma página em paralelo.

Na primeira carga e no refresh, um erro leva a tela para `.failure`. Durante a paginação preferi preservar o que já foi carregado em vez de substituir toda a lista por um erro. Hoje essa falha é silenciosa; com mais tempo eu mostraria um aviso não bloqueante no fim da lista e permitiria retry sem perder os Pokémon já exibidos.

## Tarefa 2 — Completar a linha

Essa foi a decisão que mais precisei avaliar por causa do formato da PokéAPI. A listagem entrega apenas `name` e `url`, então número, sprite e tipos exigem uma requisição de detalhe para cada Pokémon.

Considerei publicar as linhas aos poucos conforme os detalhes chegassem. Preferi não seguir esse caminho porque a lista poderia mudar visualmente enquanto o usuário estivesse olhando e algumas linhas apareceriam incompletas. Tratei cada página como uma unidade: busco os detalhes de forma concorrente com `withThrowingTaskGroup` e só publico a página quando os dados daquela página estão prontos.

Como as tasks terminam em ordens diferentes, retorno também o índice original de cada entrada e reordeno o resultado antes de atualizar o estado. Preferi isso a ordenar pelo `id`, porque quero preservar a ordem que veio da listagem da API sem assumir que ela sempre terá alguma relação específica com o identificador.

O trade-off é que uma falha em um dos detalhes pode fazer a carga daquela página falhar inteira. Para o escopo da prova, preferi linhas completas e consistentes; numa evolução eu consideraria retry ou falha parcial por item.

Essa estratégia também aumentou o tempo perceptível de loading, principalmente na primeira carga. Foi por isso que decidi trabalhar melhor esse estado na UI: substituí o `ProgressView` por uma pokébola animada e adicionei curiosidades durante a espera, para que o loading não parecesse apenas um bloqueio.

Eu nunca tinha trabalhado diretamente com `ImageIO`. Como a prova não permite bibliotecas externas, aproveitei essa parte para aprender a ler os frames e o tempo de um GIF usando APIs nativas (`ImageIO` + `UIImage`) em vez de adicionar uma dependência de animação. A implementação também respeita `accessibilityReduceMotion`, mostrando apenas o primeiro frame quando o usuário reduz animações.

O `RemotePokemonRepository` passou a ser um `actor` porque as requisições de detalhe são concorrentes e compartilham um cache mutável. Usei `[Int: PokemonDetail]`, já que o acesso posterior ao detalhe é pelo id. O `actor` isola esse estado e evita acesso concorrente inseguro ao dicionário. Esse mesmo cache passou a ser útil na Tarefa 3.

Também renomeei `PokemonSummary` para `PokemonListEntry`. O nome anterior me passava a ideia de um modelo já enriquecido, enquanto esse tipo representa apenas a entrada crua da listagem (`name` + `detailURL`).

## Tarefa 3 — Detalhe

Para a navegação escolhi push, não sheet. A lista já estava em um `NavigationStack` e o chevron indicava uma navegação hierárquica; manter o push me pareceu mais coerente e preserva o comportamento nativo de voltar.

Mesmo depois de a Tarefa 2 já ter buscado o detalhe, mantive o fluxo `ViewModel → UseCase → Repository` na tela nova. Como lista e detalhe compartilham o mesmo repositório, normalmente o detalhe é devolvido do cache e não gera outra chamada HTTP. Preferi manter o mesmo caminho de acesso aos dados entre as telas em vez de criar um fluxo específico apenas para o detalhe.

Para altura, peso e stats, escrevi os casos dos formatters antes da implementação e segui red → green. Também acrescentei testes do `FetchPokemonDetailUseCase` usando stub de repositório.

Depois das tarefas principais, adicionei uma transição simples de opacidade na entrada do conteúdo do detalhe. Mantive a animação curta e local à View para não misturar esse comportamento com as regras do ViewModel.

## Tarefa 4 — Meu Time

Aqui segui TDD de forma mais completa. Escrevi os testes de `DefaultManageTeamUseCase` usando um `TeamRepositoryStub` em memória antes de implementar as regras reais; depois fiz o green do use case e liguei a tela.

Implementei o contrato mínimo do README: um Pokémon não pode ser adicionado duas vezes pelo mesmo `id` e o time tem no máximo `Team.maxSize` (6) membros. Mantive essas regras no use case, sem colocá-las no `UserDefaultsTeamRepository` ou na View.

O starter tinha `id`, `name` e `spriteURL` em `TeamMember`. Acrescentei `types` porque o resumo do time precisa mostrar a cobertura de tipos e eu não queria abrir “Meu Time” fazendo novas requisições. No momento da adição, essa informação já existe no `PokemonDetail`.

No `TeamSummary`, implementei `count` e `coveredTypes`. Os tipos são apresentados sem repetição e mantendo a ordem em que aparecem nos membros do time.

A tela usa `TeamView` + `TeamViewModel`, reaproveita `StateView` no estado vazio, permite remover por swipe e mostra o resumo no cabeçalho. Também extraí `PokemonTypeTag` para `View/Common/`, já que a mesma representação de tipo passou a aparecer na lista, no detalhe e no time. A persistência existente em `UserDefaultsTeamRepository` foi mantida.

A regra adicional de impedir Pokémon com o mesmo tipo principal ficou como melhoria futura. Além de não fazer parte do contrato mínimo, ela exigiria definir explicitamente o que o domínio considera como tipo principal. Para esta entrega, priorizei duplicidade por `id` e limite de seis membros.

## Bônus — busca, imagens e pequenos refinamentos

Depois de concluir as quatro tarefas, implementei a busca por nome na lista. Ela filtra localmente os Pokémon que já foram carregados e ignora diferenças de maiúsculas/minúsculas. Enquanto há texto de busca, suspendo a paginação para não misturar o filtro atual com novas páginas chegando pelo scroll. Uma busca global em toda a Pokédex seria uma evolução diferente e eu trataria isso separadamente.

Como `PokemonListViewModel` usa `@Observable`, a View mantém a instância em `@State`. Para o `.searchable`, que precisa de um `Binding<String>`, crio um `@Bindable` local no `body` e uso `$viewModel.searchText`. Foi uma parte pequena da implementação, mas importante para eu entender melhor a diferença entre observar o objeto e criar um binding para uma propriedade editável dele.

Quando a busca não encontra resultados, eu não altero o `state` para `.empty`: a lista original foi carregada e continua existindo; o que está vazio é apenas o resultado do filtro. Por isso mantenho `.loaded` e mostro a mensagem de “nenhum Pokémon encontrado” dentro da própria `List`. O `.empty` global continua reservado para uma carga realmente vazia.

Também implementei o bônus de cache de imagens. `PokemonImage` deixou de depender de `AsyncImage` e passou a consultar um `NSCache<NSURL, UIImage>` em memória antes de baixar o sprite. Mantive esse cache separado do cache de `PokemonDetail`, porque são dados com responsabilidades e tipos diferentes.

Além disso, acrescentei labels combinados de acessibilidade nas linhas e no time para que número e tipos não dependam apenas da composição visual.

## O que mudou no que já existia

No geral, mantive a arquitetura do starter. O ponto que começou a me incomodar foi o ViewModel criar a própria infraestrutura, porque isso dificultava compartilhar dependências e cache conforme novas telas apareciam; por isso extraí `AppDependencies`.

Na minha solução, `PokemonListView` ainda recebe `fetchDetail` e `manageTeam` para construir os ViewModels das telas de destino. Para o tamanho da prova achei aceitável manter a composição explícita. Se a navegação crescesse, eu provavelmente moveria essa criação para uma factory/coordinator para não fazer a View carregar dependências de outras telas.

## O que ficou de fora

## O que ficou de fora

O principal ponto que ficou de fora são testes do `PokemonListViewModel`. Ele concentra boa parte do comportamento da lista, então considero essa a próxima cobertura de testes mais importante. Durante o desenvolvimento, separei os cenários que gostaria de cobrir: transições de `load` para `.loading`, `.loaded`, `.empty` e `.failure`; `reload` voltando ao `offset = 0`; não paginar quando o usuário ainda está longe do fim; iniciar a próxima página ao entrar nos últimos cinco itens; validar o `offset` usado; fazer append da nova página; interromper novas buscas quando `hasNextPage` for `false`, quando o estado não for `.loaded` ou quando uma página nova vier vazia; e preservar o estado atual caso a paginação falhe.

Também deixei para uma evolução o tratamento visual de erro durante a paginação. Hoje, se a próxima página falha, mantenho a lista já carregada e não troco o estado principal para `.failure`. Com mais tempo, eu faria uma tentativa automática adicional e, se ela também falhasse, mostraria um aviso leve no fim da lista, mantendo o conteúdo existente e permitindo retry manual sem entrar em um loop de novas tentativas.

Na Tarefa 4, a regra extra de impedir dois Pokémon com o mesmo tipo principal também ficou de fora do escopo mínimo. Caso ela virasse uma regra do produto, além de definir explicitamente o que representa o “tipo principal”, eu adicionaria testes cobrindo tanto a rejeição de dois membros com o mesmo tipo quanto a adição de tipos principais diferentes.

Por fim, o cache de detalhes ainda não deduplica duas requisições que estejam simultaneamente em andamento para o mesmo `id`. O `actor` protege o estado compartilhado do cache, mas uma evolução seria também acompanhar requests em andamento para evitar trabalho de rede duplicado.

## Com mais tempo

Minha ordem de prioridade seria: concluir os testes do `PokemonListViewModel`; melhorar erro e retry da próxima página sem apagar a lista; evoluir a busca local para uma busca global caso isso fosse requisito de produto; definir e testar a regra de tipo principal caso ela entrasse no produto; deduplicar requests de detalhe em andamento para o mesmo `id`; e, conforme a navegação crescesse, simplificar a composição das dependências das telas.
