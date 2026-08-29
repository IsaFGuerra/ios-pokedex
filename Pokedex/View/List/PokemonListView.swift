import SwiftUI

struct PokemonListView: View {

    @State private var viewModel: PokemonListViewModel
    @State private var notImplemented: String?
    @State private var loadingMessage = PokemonTrivia.random()

    private let fetchDetail: FetchPokemonDetailUseCase

    init(viewModel: PokemonListViewModel, fetchDetail: FetchPokemonDetailUseCase) {
        _viewModel = State(initialValue: viewModel)
        self.fetchDetail = fetchDetail
    }

    var body: some View {
        content
            .navigationTitle("Pokédex")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Meu Time") {
                        // TODO (Tarefa 4): apresentar a tela "Meu Time".
                        notImplemented = "Meu Time"
                    }
                }
            }
            .alert(
                notImplemented ?? "",
                isPresented: .constant(notImplemented != nil)
            ) {
                Button("OK") { notImplemented = nil }
            } message: {
                Text("Tela ainda não implementada.")
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
                viewModel: PokemonDetailViewModel(pokemonID: id, fetchDetail: fetchDetail)
            )
        }
    }
}
