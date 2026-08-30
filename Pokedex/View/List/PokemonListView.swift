import SwiftUI

struct PokemonListView: View {

    @State private var viewModel: PokemonListViewModel
    @State private var loadingMessage = PokemonTrivia.random()

    private let fetchDetail: FetchPokemonDetailUseCase
    private let manageTeam: ManageTeamUseCase

    init(
        viewModel: PokemonListViewModel,
        fetchDetail: FetchPokemonDetailUseCase,
        manageTeam: ManageTeamUseCase
    ) {
        _viewModel = State(initialValue: viewModel)
        self.fetchDetail = fetchDetail
        self.manageTeam = manageTeam
    }

    var body: some View {
        content
            .navigationTitle("Pokédex")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    NavigationLink("Meu Time") {
                        TeamView(viewModel: TeamViewModel(manageTeam: manageTeam))
                    }
                }
            }
            .task { await viewModel.load() }
    }

    @ViewBuilder
    private var content: some View {
        switch viewModel.state {
        case .loading:
            StateView(content: .loading(message: loadingMessage))

        case .loaded(let rows):
            list(rows)

        case .empty:
            StateView(content: .empty(message: "Nenhum Pokémon encontrado."))

        case .failure(let message):
            StateView(content: .failure(message: message)) {
                Task {
                    loadingMessage = PokemonTrivia.random()
                    await viewModel.load()
                }
            }
        }
    }

    private func list(_ rows: [PokemonRowModel]) -> some View {
        List {
            ForEach(Array(rows.enumerated()), id: \.element.id) { index, row in
                NavigationLink(value: row.id) {
                    PokemonRow(row: row)
                }
                .buttonStyle(.plain)
                .task { await viewModel.loadNextPageIfNeeded(displayingRowAt: index) }
            }
        }
        .listStyle(.insetGrouped)
        .refreshable { await viewModel.reload() }
        .navigationDestination(for: Int.self) { id in
            PokemonDetailView(
                viewModel: PokemonDetailViewModel(
                    pokemonID: id,
                    fetchDetail: fetchDetail,
                    manageTeam: manageTeam
                )
            )
        }
    }
}
