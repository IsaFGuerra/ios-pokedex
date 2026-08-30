import Foundation

struct PokemonRowModel: Identifiable, Equatable {
    let id: Int
    let displayName: String
    let pokedexNumber: String
    let spriteURL: URL?
    let types: [String]
    let detailURL: URL

    init(detail: PokemonDetail, detailURL: URL) {
        self.id = detail.id
        self.displayName = formatPokemonName(detail.name)
        self.pokedexNumber = formatPokedexNumber(detail.id)
        self.spriteURL = detail.spriteURL
        self.types = detail.types
        self.detailURL = detailURL
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

    private(set) var state: State = .loading

    private let fetchPage: FetchPokemonPageUseCase
    private let fetchDetail: FetchPokemonDetailUseCase
    private var offset = 0
    private var hasNextPage = true
    private var isLoadingNextPage = false

    init(
        fetchPage: FetchPokemonPageUseCase,
        fetchDetail: FetchPokemonDetailUseCase
    ) {
        self.fetchPage = fetchPage
        self.fetchDetail = fetchDetail
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
            let rows = try await fetchDetails(for: page.items)
            offset += page.items.count
            hasNextPage = page.hasNextPage
            state = rows.isEmpty ? .empty : .loaded(rows)
        } catch {
            state = .failure(message: error.localizedDescription)
        }
    }

    func loadNextPageIfNeeded(displayingRowAt index: Int) async {
        guard case .loaded(let rows) = state else { return }
        guard hasNextPage, !isLoadingNextPage else { return }

        let thresholdIndex = max(rows.count - 5, 0)
        guard index >= thresholdIndex else { return }

        isLoadingNextPage = true
        defer { isLoadingNextPage = false }

        do {
            let page = try await fetchPage.execute(offset: offset)
            let newRows = try await fetchDetails(for: page.items)
            guard !newRows.isEmpty else {
                hasNextPage = false
                return
            }

            offset += page.items.count
            hasNextPage = page.hasNextPage
            state = .loaded(rows + newRows)
        } catch {
        }
    }

    private func fetchDetails(for entries: [PokemonListEntry]) async throws -> [PokemonRowModel] {
        try await withThrowingTaskGroup(of: (Int, PokemonRowModel).self) { group in
            for (index, entry) in entries.enumerated() {
                group.addTask {
                    guard let id = entry.detailID else {
                        throw NetworkError.decodingFailed
                    }
                    let detail = try await self.fetchDetail.execute(id: id)
                    let row = PokemonRowModel(detail: detail, detailURL: entry.detailURL)
                    return (index, row)
                }
            }
            var pairs: [(Int, PokemonRowModel)] = []
            for try await pair in group {
                pairs.append(pair)
            }
            return pairs.sorted { $0.0 < $1.0 }.map(\.1)
        }
    }
}
