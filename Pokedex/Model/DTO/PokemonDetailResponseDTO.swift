import Foundation

struct PokemonDetailResponseDTO: Decodable {
    let id: Int
    let name: String
    let height: Int
    let weight: Int
    let sprites: SpritesDTO
    let types: [TypeSlotDTO]
    let stats: [StatSlotDTO]
}

struct StatSlotDTO: Decodable {
    let baseStat: Int
    let stat: NamedResourceDTO
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
