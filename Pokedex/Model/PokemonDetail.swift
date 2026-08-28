import Foundation

struct PokemonDetail: Equatable {
    let id: Int
    let name: String
    let spriteURL: URL?
    let types: [String]
}
