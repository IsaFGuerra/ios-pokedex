import Foundation

enum PokemonTrivia {
    static let facts: [String] = [
        "Pikachu quase não foi a mascote — Clefairy era a favorita no início.",
        "Existem mais de 1000 espécies de Pokémon registradas na franquia.",
        "Os jogos originais saíram em 1996 para o Game Boy no Japão.",
        "MissingNo. é um dos glitches mais famosos da história dos games.",
        "O nome Pokémon vem de 'Pocket Monsters' (monstros de bolso).",
        "Charizard é tipo fogo/voador, apesar de parecer um dragão.",
        "Magikarp evolui para Gyarados — uma das evoluções mais surpreendentes.",
        "A região de Kanto no jogo foi inspirada em Tóquio e arredores.",
        "Mewtwo foi criado a partir do DNA de Mew na lore dos jogos.",
        "Slowpoke usa a cauda como isca — e às vezes é mordida por Shellder."
    ]

    static func random() -> String {
        facts.randomElement() ?? facts[0]
    }
}
