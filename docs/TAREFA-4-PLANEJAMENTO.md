# Tarefa 4 — Meu Time

Planejamento da tela de time e das regras em `DefaultManageTeamUseCase`.
Persistência já existe: `UserDefaultsTeamRepository`.

## Por que TDD primeiro

Mesmo critério da Tarefa 3: View muda fácil e não vale o custo de teste.
Aqui o valor está nas regras puras — `add` / `remove` / `summary`.
View e ViewModel de tela ficam de fora dos testes.

Ordem: **red → green → tela**.

```
View  →  ViewModel  →  UseCase  →  Repository
                         │
                    regras do time
                    (duplicata, teto 6, resumo)
```

O use case **recebe** o repositório. Quem usa alguém, recebe esse alguém.
O disco não conhece “já está no time” nem “máximo 6”.
O use case depende do protocolo `TeamRepository`, não do `UserDefaults` —
por isso o teste injeta `TeamRepositoryStub`.

## Escopo mínimo

- Duplicata: mesmo `id` → `TeamError.alreadyInTeam`
- Time cheio: `count >= Team.maxSize` (6) → `TeamError.teamFull`
- `TeamMember.types` para o resumo conseguir listar tipos cobertos
- Tela Meu Time: lista, remover, vazio, cabeçalho com `TeamSummary`
- Botão “Adicionar ao time” no detalhe com erro de verdade

## Fora desta entrega

Regra extra (tipo principal repetido) só no `TODO.md`:

- `add` rejeita quando `types.first` do novo Pokémon já existe no time
  (Charmander fire + Vulpix fire → erro; Charmander fire + Squirtle water → ok)

## Fases

### 1 — Testes vermelhos (feita)

- `TeamRepositoryStub`: `load` / `save` em memória
- `TeamMember.types` e `TeamError.teamFull` (senão os testes não compilam)
- `ManageTeamUseCaseTests` — quebram no `fatalError` de propósito:

  - `add` persiste o membro e `currentTeam()` devolve na ordem
  - `add` do mesmo `id` lança `alreadyInTeam`
  - `add` com 6 membros lança `teamFull`
  - `remove` tira pelo `id` e persiste
  - `remove` de id inexistente não quebra nem altera o time
  - `summary` vazio → `count == 0`, `coveredTypes` vazio
  - `summary` → count certo e tipos únicos, na ordem em que aparecem
    (grass + poison + fire + grass → `["grass", "poison", "fire"]`)

### 2 — Green no use case

Sem SwiftUI, sem rede.

- `add`: carrega → rejeita duplicata por `id` → rejeita se `count >= 6` → append → `save`
- `remove`: filtra pelo `id` → `save`
- `summary`: `count` + tipos únicos de `member.types`

### 3 — Ligar o app

- `AppDependencies`: um `UserDefaultsTeamRepository` + `DefaultManageTeamUseCase`
- `PokemonDetailViewModel` recebe `ManageTeamUseCase`; `addToTeam()` monta
  `TeamMember` a partir do detalhe (id, name, spriteURL, types)
- Botão do detalhe deixa o placeholder e mostra o `errorDescription` real
  (sucesso: alert curto; a prova pede o erro)

### 4 — Tela Meu Time

`Pokedex/View/Team/` + `TeamViewModel` (ViewModel sem SwiftUI).

- Cabeçalho: “3 / 6” e tags de tipo com `Theme.Color.forPokemonType`
- Lista: sprite + nome formatado + número; swipe ou botão para remover
- Vazio: `StateView(content: .empty(...))` — “Seu time está vazio.”
- Toolbar “Meu Time”: `NavigationLink` com destino concreto (não `Int`),
  para não brigar com o `navigationDestination(for: Int.self)` do detalhe.
  Push, não sheet — alinhado à Tarefa 3.

### 5 — ENTREGA.md

Registrar: TDD primeiro, por que `types` no `TeamMember`, duplicata + teto de 6,
o que o resumo mostra, e o que ficou de fora (tipo principal — só no TODO).
