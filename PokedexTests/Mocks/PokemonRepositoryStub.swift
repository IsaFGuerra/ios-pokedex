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

    /// Resultado devolvido quando não há nada configurado para o offset.
    var defaultResult: Result<PokemonPage, Error> = .success(.stub())

    /// Resultado por offset, quando o teste precisa de páginas diferentes.
    var resultsByOffset: [Int: Result<PokemonPage, Error>] = [:]

    func fetchPage(offset: Int, limit: Int) async throws -> PokemonPage {
        calls.append(Call(offset: offset, limit: limit))
        switch resultsByOffset[offset] ?? defaultResult {
        case .success(let page): return page
        case .failure(let error): throw error
        }
    }
}

extension PokemonPage {
    static func stub(
        items: [PokemonSummary] = [.stub()],
        totalCount: Int = 1,
        hasNextPage: Bool = false
    ) -> PokemonPage {
        PokemonPage(items: items, totalCount: totalCount, hasNextPage: hasNextPage)
    }
}

extension PokemonSummary {
    static func stub(id: Int = 1, name: String = "bulbasaur") -> PokemonSummary {
        PokemonSummary(
            name: name,
            detailURL: URL(string: "https://pokeapi.co/api/v2/pokemon/\(id)/")!
        )
    }
}
