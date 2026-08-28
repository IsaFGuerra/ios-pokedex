import Foundation

struct PokemonDetailResponseDTO: Decodable {
    let id: Int
    let name: String
    let sprites: SpritesDTO
    let types: [TypeSlotDTO]
}

struct SpritesDTO: Decodable {
    let frontDefault: String?
}

struct TypeSlotDTO: Decodable {
    let slot: Int
    let type: NamedResourceDTO
}

struct NamedResourceDTO: Decodable {
    let name: String
}
