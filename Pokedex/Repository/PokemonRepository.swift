import Foundation

/// Uma página da listagem de Pokémon.
struct PokemonPage: Equatable {
    let items: [PokemonSummary]
    let totalCount: Int
    let hasNextPage: Bool
}

protocol PokemonRepository {
    func fetchPage(offset: Int, limit: Int) async throws -> PokemonPage
}

final class RemotePokemonRepository: PokemonRepository {

    private let client: HTTPClient

    init(client: HTTPClient) {
        self.client = client
    }

    func fetchPage(offset: Int, limit: Int) async throws -> PokemonPage {
        let url = PokeAPI.pokemonList(limit: limit, offset: offset)
        let dto = try await client.get(url, as: PokemonListResponseDTO.self)

        let items = dto.results.compactMap { item -> PokemonSummary? in
            guard let url = URL(string: item.url) else { return nil }
            return PokemonSummary(name: item.name, detailURL: url)
        }

        return PokemonPage(
            items: items,
            totalCount: dto.count,
            hasNextPage: dto.next != nil
        )
    }
}
