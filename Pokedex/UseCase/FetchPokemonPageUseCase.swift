import Foundation

protocol FetchPokemonPageUseCase {
    func execute(offset: Int) async throws -> PokemonPage
}

final class DefaultFetchPokemonPageUseCase: FetchPokemonPageUseCase {

    static let pageSize = 20

    private let repository: PokemonRepository

    init(repository: PokemonRepository) {
        self.repository = repository
    }

    func execute(offset: Int) async throws -> PokemonPage {
        try await repository.fetchPage(offset: offset, limit: Self.pageSize)
    }
}
