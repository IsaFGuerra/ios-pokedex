# TODO — backlog pessoal

Itens fora do escopo mínimo das tarefas do README, para fazer depois das entregas principais.

---

## Testes — `PokemonListViewModel` (Tarefa 1)

Pré-requisito: injetar `FetchPokemonPageUseCase` no init; usar `PokemonRepositoryStub`.

- `load` → `.loading` depois `.loaded`
- `load` com página vazia → `.empty`
- `load` com erro → `.failure`
- `reload` → busca com `offset = 0`
- `loadNextPageIfNeeded` com index longe do fim → não chama API
- `loadNextPageIfNeeded` nos últimos 5 → chama API com `offset` correto
- `loadNextPageIfNeeded` → append (`20 → 40` itens)
- `hasNextPage = false` → não busca mais
- `state != .loaded` → não busca
- página nova vazia → para paginação
- erro na paginação → `state` inalterado

---

## Paginação — erro ao carregar próxima página

**Contexto:** hoje `loadNextPageIfNeeded` tem `catch` vazio — se a paginação falhar no meio do scroll, a lista parcial continua visível e o usuário pode rolar de novo para tentar outra vez.

**Ideia:** melhorar UX sem trocar `state` para `.failure` (isso apagaria a lista inteira).

### Comportamento desejado

1. Se a requisição da próxima página falhar, tentar **uma vez** de novo automaticamente.
2. Se a segunda tentativa também falhar, mostrar um **aviso leve** (banner/toast no fim da lista), não tela cheia de erro.
3. Manter a lista parcial visível o tempo todo.
4. Permitir retry manual: scroll de novo ou botão “Tentar de novo” no aviso.

### Implementação sugerida

- **ViewModel:** adicionar algo como `paginationError: String?`, separado do `State` principal.
- **View:** exibir banner/toast quando `paginationError != nil`, sem substituir `StateView` de erro global.
- **Evitar:** retry em loop (`.task` nas linhas pode disparar várias vezes); cooldown ou flag de “já tentou retry”.
- **Evitar:** `state = .failure(...)` na paginação.
