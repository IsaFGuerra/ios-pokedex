# Prova prática iOS — Pokédex (SwiftUI)

Olá! Este é um app **inacabado**. A ideia da prova não é você começar de uma
folha em branco: é pegar um projeto que já existe, entender como ele está
organizado e terminá-lo mantendo a coerência.

---

## Como rodar

Xcode 16 ou superior, simulador de iPhone com iOS 17+.

> Existe uma versão equivalente desta prova em **UIKit**, com exatamente as
> mesmas quatro tarefas. Escolha a que você preferir, as duas valem igual.

A API usada é a [PokéAPI](https://pokeapi.co/docs/v2). Ela é pública, sem cadastro e
sem chave de acesso. **Todas** as informações que você precisa podem ser obtidas através dela.

## O que o app já faz

- Lista os **20 primeiros** Pokémon (`GET /pokemon?limit=20&offset=0`).
- Mostra estados de carregando, vazio e erro, com botão de "tentar de novo".
- Pull to refresh.
- Tem os botões de navegação para o detalhe e para "Meu Time" (que hoje só
  abrem um alerta dizendo que a tela não existe).

## Como o projeto está organizado

O fluxo de dados é sempre na mesma direção:

```
View  ──▶  ViewModel  ──▶  UseCase  ──▶  Repository  ──▶  HTTPClient
(SwiftUI)  (sem SwiftUI)   (regras)      (API/disco)      (URLSession)
```

| Pasta           | Responsabilidade |
|-----------------|------------------|
| `App/`          | Ponto de entrada (`PokedexApp`) e o `NavigationStack` da raiz |
| `Network/`      | `HTTPClient` e as URLs da PokéAPI |
| `Model/`        | Modelos de domínio e DTOs (o que vem da API) |
| `Repository/`   | Acesso a dados: rede e persistência |
| `UseCase/`      | Regras de negócio, sem SwiftUI e sem rede direta |
| `ViewModel/`    | Estado de cada tela, publicado com `@Observable` |
| `View/`         | Telas e componentes. `View/Common/` é reaproveitável |
| `DesignSystem/` | Cores, fontes e espaçamentos (`Theme`) |

Duas convenções que valem para o código novo:

1. **O ViewModel não importa SwiftUI.** Ele publica um `state`, e a View só
   observa e desenha. Regra de negócio não mora dentro de `body`.
2. **Componentes pequenos, em `View/Common/`.** Já existem `StateView` e
   `PokemonImage`. Prefira reaproveitá-los a repetir `ProgressView` e
   `AsyncImage` em cada tela.

`PokemonListView` é a tela de referência: se ficar em dúvida sobre
estilo, copie o que está lá.

---

## As tarefas

### Tarefa 1 — Paginação na lista

Hoje a lista trava nos 20 primeiros. Ela precisa carregar as páginas seguintes
conforme o usuário rola, até o fim da Pokédex.

O ponto de partida está em `PokemonListViewModel.loadNextPageIfNeeded(displayingRowAt:)`,
que já é chamado pela View.

### Tarefa 2 — Completar a linha da lista

Cada linha da lista (`PokemonRow`) deve mostrar:

- o **nome formatado** para leitura (a API devolve `"bulbasaur"`, `"mr-mime"`);
- o **número na Pokédex** com três dígitos (`#001`);
- o **sprite** do Pokémon;
- as **tags de tipo** (grass, poison, ...), coloridas com
  `Theme.Color.forPokemonType(_:)`.

> A listagem da PokéAPI devolve apenas `name` e `url` de cada Pokémon, nada
> mais. Sprite, número e tipos **existem na API**, mas em outro endpoint: o de
> detalhe de cada Pokémon, para onde a `url` da listagem aponta. Ou seja, são
> dados disponíveis, só que cada um exige a sua própria requisição.
>
> **Como e quando buscá-los é decisão sua**, e é uma das coisas que mais nos
> interessa: escreva no `ENTREGA.md` por que você escolheu esse caminho.

### Tarefa 3 — Tela de detalhe

Ao tocar em um Pokémon, abrir uma tela com:

- sprite grande, nome, número e tipos;
- **altura em metros** e **peso em quilos** (ex.: `0,7 m` e `6,9 kg`);
- os stats base de **HP, Ataque e Defesa**;
- um botão **"Adicionar ao time"**, que mostra o erro quando não for possível.

Endpoint: `GET /pokemon/{id}` — veja `PokeAPI.pokemon(id:)`.

### Tarefa 4 — Meu Time

O usuário monta um time de até **6** Pokémon, que **sobrevive ao fechar o app**
(a persistência já está pronta em `UserDefaultsTeamRepository`).

Duas partes:

**a) As regras**, em `DefaultManageTeamUseCase` — os métodos estão lá com
`fatalError("TODO")` e o contrato documentado.

**b) A tela**, aberta pelo botão "Meu Time": lista dos membros, opção de
remover, estado vazio, e um cabeçalho com um resumo do time.

O que entra nesse resumo é escolha sua. `TeamSummary` tem um começo e pedimos
que implemente pelo menos as duas informações já listadas nele.

### Bônus (só se sobrar tempo)

Nenhum destes é obrigatório, e não fazer nenhum não tira ponto:

- **Testes unitários** do que você escreveu de regra de negócio.`PokedexTests` já
  tem um teste de exemplo e um stub de repositório para usar como modelo. Não é
  preciso testar SwiftUI (Views).
- Cache de imagens em `PokemonImage` (veja o `TODO` de lá): `AsyncImage` não
  guarda nada em memória.
- Busca por nome na lista.
- Animação ou transição na entrada do detalhe.

---

## Regras

- **Sem bibliotecas externas.** SwiftUI e Foundation dão conta de tudo.
- Pode consultar documentação, Stack Overflow e IA à vontade, **mas você vai
  conversar com a gente sobre o seu próprio código na entrevista.**
  Não entregue nada que você não saiba explicar e defender.
- Não precisa criar tela de login, dark mode customizado, ícone do app,
  onboarding, animações elaboradas nem suporte a iPad.

### Sobre o código que já está aqui

O projeto tem um jeito de fazer as coisas, mas **isso não é lei.** Você está
livre para mudar o que quiser: assinaturas, camadas, como as telas recebem suas
dependências, como o estado chega na View, a organização das pastas. A arquitetura inteira, se for o caso. 
Trocar o padrão existente por um melhor **não é desrespeitar o enunciado, é o tipo de coisa que a gente quer ver.**

O que pedimos é só isto: **se você mudar algo estrutural, escreva por que no
`ENTREGA.md`.** Uma frase basta. Nos mostre o seu raciocínio.

Seguir o que já existe também é uma escolha válida. Só queremos saber se foi escolha ou piloto automático.

## O que entregar

1. O projeto (repositório Git ou um `.zip`).
2. Um **`ENTREGA.md`** curto respondendo:
   - as decisões técnicas que você tomou e por quê
   - o que você mudou no que já existia, se mudou, e o que te incomodou ali
   - o que ficou de fora e o motivo
   - o que você faria diferente com mais tempo

Esse arquivo pesa tanto quanto o código. Boa prova!
