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
        @Bindable var viewModel = viewModel

        content
            .navigationTitle("Pokédex")
            .searchable(text: $viewModel.searchText, prompt: "Buscar por nome")
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

        case .loaded:
            list(viewModel.filteredRows)

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
            if rows.isEmpty, viewModel.isSearching {
                Text("Nenhum Pokémon encontrado para \"\(viewModel.searchText)\".")
                    .font(Theme.Font.body)
                    .foregroundStyle(Theme.Color.secondaryText)
                    .frame(maxWidth: .infinity, alignment: .center)
                    .listRowBackground(Color.clear)
            } else {
                ForEach(Array(rows.enumerated()), id: \.element.id) { index, row in
                    NavigationLink(value: row.id) {
                        PokemonRow(row: row)
                    }
                    .buttonStyle(.plain)
                    .task {
                        guard !viewModel.isSearching else { return }
                        await viewModel.loadNextPageIfNeeded(displayingRowAt: index)
                    }
                }
            }
        }
        .listStyle(.insetGrouped)
        .refreshable {
            viewModel.searchText = ""
            await viewModel.reload()
        }
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
