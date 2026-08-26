import Foundation

/// O que uma linha da lista precisa para se desenhar.
struct PokemonRowModel: Identifiable, Equatable {
    let name: String
    let detailURL: URL

    var id: URL { detailURL }

    init(summary: PokemonSummary) {
        self.name = summary.name
        self.detailURL = summary.detailURL
    }
}

@MainActor
@Observable
final class PokemonListViewModel {

    enum State: Equatable {
        case loading
        case loaded([PokemonRowModel])
        case empty
        case failure(message: String)
    }

    /// A View observa isto. O ViewModel nunca importa SwiftUI.
    private(set) var state: State = .loading

    private let fetchPage: FetchPokemonPageUseCase

    init() {
        let repository = RemotePokemonRepository(client: URLSessionHTTPClient())
        self.fetchPage = DefaultFetchPokemonPageUseCase(repository: repository)
    }

    func load() async {
        state = .loading
        await loadFirstPage()
    }

    func reload() async {
        await loadFirstPage()
    }

    private func loadFirstPage() async {
        do {
            let page = try await fetchPage.execute(offset: 0)
            let rows = page.items.map(PokemonRowModel.init(summary:))
            state = rows.isEmpty ? .empty : .loaded(rows)
        } catch {
            state = .failure(message: error.localizedDescription)
        }
    }

    // MARK: - TODO (Tarefa 1)
    //
    // A lista carrega só a primeira página (20 Pokémon).
    // Este método é chamado pela View a cada linha que aparece na tela.
    func loadNextPageIfNeeded(displayingRowAt index: Int) async {
    }
}
