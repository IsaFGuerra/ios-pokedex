import Foundation

struct PokemonDetail: Equatable {
    let id: Int
    let name: String
    let spriteURL: URL?
    let types: [String]
    let height: Int
    let weight: Int
    let hp: Int
    let attack: Int
    let defense: Int
}
