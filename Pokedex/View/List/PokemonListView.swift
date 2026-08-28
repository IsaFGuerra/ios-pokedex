import SwiftUI

/// Lista de Pokémon. Serve de referência de estilo para as telas novas: a View
/// só observa o estado do ViewModel e desenha, sem regra de negócio aqui dentro.
struct PokemonListView: View {

    @State private var viewModel: PokemonListViewModel
    @State private var notImplemented: String?
    @State private var loadingMessage = PokemonTrivia.random()

    init(viewModel: PokemonListViewModel) {
        _viewModel = State(initialValue: viewModel)
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
                Button {
                    // TODO (Tarefa 3): abrir a tela de detalhe deste Pokémon.
                    notImplemented = "Detalhe de \(row.displayName)"
                } label: {
                    HStack {
                        PokemonRow(row: row)
                        Image(systemName: "chevron.right")
                            .font(Theme.Font.caption.bold())
                            .foregroundStyle(Theme.Color.secondaryText)
                    }
                }
                .buttonStyle(.plain)
                .task { await viewModel.loadNextPageIfNeeded(displayingRowAt: index) }
            }
        }
        .listStyle(.insetGrouped)
        .refreshable { await viewModel.reload() }
    }
}
