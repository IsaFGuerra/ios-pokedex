import Foundation

@MainActor
@Observable
final class PokemonDetailViewModel {

    enum State: Equatable {
        case loading
        case loaded(PokemonDetail)
        case failure(message: String)
    }

    private(set) var state: State = .loading

    private let pokemonID: Int
    private let fetchDetail: FetchPokemonDetailUseCase

    init(pokemonID: Int, fetchDetail: FetchPokemonDetailUseCase) {
        self.pokemonID = pokemonID
        self.fetchDetail = fetchDetail
    }

    func load() async {
        state = .loading

        do {
            let detail = try await fetchDetail.execute(id: pokemonID)
            state = .loaded(detail)
        } catch {
            state = .failure(message: error.localizedDescription)
        }
    }
}
