import Foundation
@testable import Pokedex

/// Dublê do repositório: guarda as chamadas recebidas e devolve o resultado
/// que o teste combinar. Sem rede, sem espera.
///
/// Sinta-se livre para estender (ou criar outros dublês seguindo este modelo).
final class PokemonRepositoryStub: PokemonRepository {

    struct Call: Equatable {
        let offset: Int
        let limit: Int
    }

    private(set) var calls: [Call] = []
    private(set) var detailCalls: [Int] = []

    /// Resultado devolvido quando não há nada configurado para o offset.
    var defaultResult: Result<PokemonPage, Error> = .success(.stub())

    /// Resultado por offset, quando o teste precisa de páginas diferentes.
    var resultsByOffset: [Int: Result<PokemonPage, Error>] = [:]

    var defaultDetailResult: Result<PokemonDetail, Error> = .success(.stub())
    var detailsByID: [Int: Result<PokemonDetail, Error>] = [:]

    func fetchPage(offset: Int, limit: Int) async throws -> PokemonPage {
        calls.append(Call(offset: offset, limit: limit))
        switch resultsByOffset[offset] ?? defaultResult {
        case .success(let page): return page
        case .failure(let error): throw error
        }
    }

    func fetchDetail(id: Int) async throws -> PokemonDetail {
        detailCalls.append(id)
        switch detailsByID[id] ?? defaultDetailResult {
        case .success(let detail): return detail
        case .failure(let error): throw error
        }
    }
}

extension PokemonPage {
    static func stub(
        items: [PokemonListEntry] = [.stub()],
        totalCount: Int = 1,
        hasNextPage: Bool = false
    ) -> PokemonPage {
        PokemonPage(items: items, totalCount: totalCount, hasNextPage: hasNextPage)
    }
}

extension PokemonListEntry {
    static func stub(id: Int = 1, name: String = "bulbasaur") -> PokemonListEntry {
        PokemonListEntry(
            name: name,
            detailURL: URL(string: "https://pokeapi.co/api/v2/pokemon/\(id)/")!
        )
    }
}

extension PokemonDetail {
    static func stub(
        id: Int = 1,
        name: String = "bulbasaur",
        spriteURL: URL? = URL(string: "https://example.com/sprite.png"),
        types: [String] = ["grass", "poison"],
        height: Int = 7,
        weight: Int = 69,
        hp: Int = 45,
        attack: Int = 49,
        defense: Int = 49
    ) -> PokemonDetail {
        PokemonDetail(
            id: id,
            name: name,
            spriteURL: spriteURL,
            types: types,
            height: height,
            weight: weight,
            hp: hp,
            attack: attack,
            defense: defense
        )
    }
}
