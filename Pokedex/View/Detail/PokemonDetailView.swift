import SwiftUI

struct PokemonDetailView: View {

    @State private var viewModel: PokemonDetailViewModel
    @State private var showTeamAlert = false

    init(viewModel: PokemonDetailViewModel) {
        _viewModel = State(initialValue: viewModel)
    }

    var body: some View {
        content
            .navigationBarTitleDisplayMode(.inline)
            .task { await viewModel.load() }
            .alert("Adicionar ao time", isPresented: $showTeamAlert) {
                Button("OK", role: .cancel) {}
            } message: {
                Text("Meu Time será implementado na Tarefa 4.")
            }
    }

    @ViewBuilder
    private var content: some View {
        switch viewModel.state {
        case .loading:
            StateView(content: .loading())

        case .loaded(let detail):
            detailContent(detail)

        case .failure(let message):
            StateView(content: .failure(message: message)) {
                Task { await viewModel.load() }
            }
        }
    }

    private func detailContent(_ detail: PokemonDetail) -> some View {
        ScrollView {
            VStack(spacing: Theme.Spacing.l) {
                PokemonImage(url: detail.spriteURL)
                    .frame(width: 160, height: 160)
                    .padding(Theme.Spacing.m)
                    .background(Theme.Color.surface, in: Circle())

                VStack(spacing: Theme.Spacing.xs) {
                    Text(formatPokemonName(detail.name))
                        .font(Theme.Font.title)
                        .foregroundStyle(Theme.Color.primaryText)

                    Text(formatPokedexNumber(detail.id))
                        .font(Theme.Font.caption)
                        .foregroundStyle(Theme.Color.secondaryText)
                }

                HStack(spacing: Theme.Spacing.xs) {
                    ForEach(detail.types, id: \.self) { type in
                        Text(type)
                            .font(Theme.Font.caption.bold())
                            .foregroundStyle(.white)
                            .padding(.horizontal, Theme.Spacing.s)
                            .padding(.vertical, Theme.Spacing.xs)
                            .background(Theme.Color.forPokemonType(type), in: Capsule())
                    }
                }

                HStack(spacing: Theme.Spacing.l) {
                    statLine(title: "Altura", value: formatHeight(detail.height))
                    statLine(title: "Peso", value: formatWeight(detail.weight))
                }

                VStack(spacing: Theme.Spacing.s) {
                    statLine(title: "HP", value: "\(detail.hp)")
                    statLine(title: "Ataque", value: "\(detail.attack)")
                    statLine(title: "Defesa", value: "\(detail.defense)")
                }
                .frame(maxWidth: .infinity, alignment: .leading)

                Button("Adicionar ao time") {
                    showTeamAlert = true
                }
                .buttonStyle(.borderedProminent)
                .tint(Theme.Color.accent)
            }
            .padding(Theme.Spacing.l)
            .frame(maxWidth: .infinity)
        }
        .background(Theme.Color.background)
    }

    private func statLine(title: String, value: String) -> some View {
        HStack {
            Text(title)
                .font(Theme.Font.body)
                .foregroundStyle(Theme.Color.secondaryText)
            Spacer()
            Text(value)
                .font(Theme.Font.body.bold())
                .foregroundStyle(Theme.Color.primaryText)
        }
    }
}
