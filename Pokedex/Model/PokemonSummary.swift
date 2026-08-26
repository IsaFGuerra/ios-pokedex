import Foundation

/// O que a listagem da PokéAPI devolve sobre cada Pokémon
/// `name`: nome do Pokémon
/// `detailUrl`: a url contendo mais informações sobre o Pokémon
struct PokemonSummary: Equatable {
    let name: String
    let detailURL: URL
}
