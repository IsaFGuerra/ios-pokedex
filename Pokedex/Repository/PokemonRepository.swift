import Foundation

struct PokemonPage: Equatable {
    let items: [PokemonListEntry]
    let totalCount: Int
    let hasNextPage: Bool
}

protocol PokemonRepository {
    func fetchPage(offset: Int, limit: Int) async throws -> PokemonPage
    func fetchDetail(id: Int) async throws -> PokemonDetail
}

actor RemotePokemonRepository: PokemonRepository {

    private let client: HTTPClient
    private var detailCache: [Int: PokemonDetail] = [:]

    init(client: HTTPClient) {
        self.client = client
    }

    func fetchPage(offset: Int, limit: Int) async throws -> PokemonPage {
        let url = PokeAPI.pokemonList(limit: limit, offset: offset)
        let dto = try await client.get(url, as: PokemonListResponseDTO.self)

        let items = dto.results.compactMap { item -> PokemonListEntry? in
            guard let url = URL(string: item.url) else { return nil }
            return PokemonListEntry(name: item.name, detailURL: url)
        }

        return PokemonPage(
            items: items,
            totalCount: dto.count,
            hasNextPage: dto.next != nil
        )
    }

    func fetchDetail(id: Int) async throws -> PokemonDetail {
        if let cached = detailCache[id] {
            return cached
        }

        let url = PokeAPI.pokemon(id: id)
        let dto = try await client.get(url, as: PokemonDetailResponseDTO.self)
        let detail = mapDetail(from: dto)
        detailCache[id] = detail
        return detail
    }

    private func mapDetail(from dto: PokemonDetailResponseDTO) -> PokemonDetail {
        let stats = dto.stats.map { (name: $0.stat.name, base: $0.baseStat) }

        return PokemonDetail(
            id: dto.id,
            name: dto.name,
            spriteURL: dto.sprites.frontDefault.flatMap(URL.init(string:)),
            types: dto.types.sorted { $0.slot < $1.slot }.map(\.type.name),
            height: dto.height,
            weight: dto.weight,
            hp: statValue(named: "hp", in: stats) ?? 0,
            attack: statValue(named: "attack", in: stats) ?? 0,
            defense: statValue(named: "defense", in: stats) ?? 0
        )
    }
}
