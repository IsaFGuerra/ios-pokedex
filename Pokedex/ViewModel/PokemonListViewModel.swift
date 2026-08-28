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
    private var offset = 0
    private var hasNextPage = true
    private var isLoadingNextPage = false

    init() {
        let repository = RemotePokemonRepository(client: URLSessionHTTPClient())
        self.fetchPage = DefaultFetchPokemonPageUseCase(repository: repository)
    }

    func load() async {
        state = .loading
        resetPagination()
        await loadFirstPage()
    }

    func reload() async {
        resetPagination()
        await loadFirstPage()
    }

    private func resetPagination() {
        offset = 0
        hasNextPage = true
        isLoadingNextPage = false
    }

    private func loadFirstPage() async {
        do {
            let page = try await fetchPage.execute(offset: offset)
            let rows = page.items.map(PokemonRowModel.init(summary:))
            offset += page.items.count
            hasNextPage = page.hasNextPage
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
        guard case .loaded(let rows) = state else { return }
        guard hasNextPage, !isLoadingNextPage else { return }

        let thresholdIndex = max(rows.count - 5, 0)
        guard index >= thresholdIndex else { return }

        isLoadingNextPage = true
        defer { isLoadingNextPage = false }

        do {
            let page = try await fetchPage.execute(offset: offset)
            let newRows = page.items.map(PokemonRowModel.init(summary:))
            guard !newRows.isEmpty else {
                hasNextPage = false
                return
            }

            offset += page.items.count
            hasNextPage = page.hasNextPage
            state = .loaded(rows + newRows)
        } catch {
            // Mantém a lista visível se a paginação falhar no meio do scroll.
        }
    }
}
