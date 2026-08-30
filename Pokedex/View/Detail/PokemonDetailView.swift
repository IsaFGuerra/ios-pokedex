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
                Text(viewModel.teamAlertMessage ?? "")
            }
    }

    @ViewBuilder
    private var content: some View {
        switch viewModel.state {
        case .loading:
            StateView(content: .loading())

        case .loaded(let pokemon):
            loadedDetail(pokemon)

        case .failure(let message):
            StateView(content: .failure(message: message)) {
                Task { await viewModel.load() }
            }
        }
    }

    private func loadedDetail(_ pokemon: PokemonDetail) -> some View {
        ScrollView {
            VStack(spacing: Theme.Spacing.l) {
                header(pokemon)
                heightAndWeightCard(pokemon)
                hpAttackDefenseCard(pokemon)
                addToTeamButton
            }
            .padding(.horizontal, Theme.Spacing.m)
            .padding(.vertical, Theme.Spacing.l)
            .frame(maxWidth: .infinity)
        }
        .background(Theme.Color.background)
    }

    private func header(_ pokemon: PokemonDetail) -> some View {
        VStack(spacing: Theme.Spacing.s) {
            PokemonImage(url: pokemon.spriteURL)
                .frame(width: 160, height: 160)
                .padding(Theme.Spacing.m)
                .background(Theme.Color.surface, in: Circle())
                .shadow(color: .black.opacity(0.06), radius: 12, y: 4)

            Text(formatPokemonName(pokemon.name))
                .font(Theme.Font.display)
                .foregroundStyle(Theme.Color.primaryText)

            Text(formatPokedexNumber(pokemon.id))
                .font(Theme.Font.caption)
                .foregroundStyle(Theme.Color.secondaryText)

            HStack(spacing: Theme.Spacing.xs) {
                ForEach(pokemon.types, id: \.self) { type in
                    PokemonTypeTag(type: type)
                }
            }
        }
        .accessibilityElement(children: .combine)
    }

    private func heightAndWeightCard(_ pokemon: PokemonDetail) -> some View {
        HStack(spacing: 0) {
            labelAboveValue(title: "Altura", value: formatHeight(pokemon.height))
            Divider()
                .frame(height: 44)
            labelAboveValue(title: "Peso", value: formatWeight(pokemon.weight))
        }
        .padding(.vertical, Theme.Spacing.m)
        .background(Theme.Color.surface, in: RoundedRectangle(cornerRadius: Theme.Radius.card, style: .continuous))
    }

    private func labelAboveValue(title: String, value: String) -> some View {
        VStack(spacing: Theme.Spacing.xs) {
            Text(title)
                .font(Theme.Font.caption)
                .foregroundStyle(Theme.Color.secondaryText)
            Text(value)
                .font(Theme.Font.rowTitle)
                .foregroundStyle(Theme.Color.primaryText)
        }
        .frame(maxWidth: .infinity)
    }

    private func hpAttackDefenseCard(_ pokemon: PokemonDetail) -> some View {
        VStack(spacing: 0) {
            statRow(
                icon: "heart.fill",
                color: Color(red: 0.91, green: 0.30, blue: 0.32),
                title: "HP",
                value: "\(pokemon.hp)"
            )
            Divider()
                .padding(.leading, 56)
            statRow(
                icon: "flame.fill",
                color: Color(red: 0.96, green: 0.55, blue: 0.22),
                title: "Ataque",
                value: "\(pokemon.attack)"
            )
            Divider()
                .padding(.leading, 56)
            statRow(
                icon: "shield.fill",
                color: Color(red: 0.35, green: 0.56, blue: 0.91),
                title: "Defesa",
                value: "\(pokemon.defense)"
            )
        }
        .padding(.horizontal, Theme.Spacing.m)
        .padding(.vertical, Theme.Spacing.s)
        .background(Theme.Color.surface, in: RoundedRectangle(cornerRadius: Theme.Radius.card, style: .continuous))
    }

    private func statRow(icon: String, color: Color, title: String, value: String) -> some View {
        HStack(spacing: Theme.Spacing.s) {
            Image(systemName: icon)
                .font(.caption.bold())
                .foregroundStyle(color)
                .frame(width: 32, height: 32)
                .background(color.opacity(0.14), in: Circle())

            Text(title)
                .font(Theme.Font.body)
                .foregroundStyle(Theme.Color.secondaryText)

            Spacer()

            Text(value)
                .font(Theme.Font.rowTitle)
                .foregroundStyle(Theme.Color.primaryText)
        }
        .padding(.vertical, Theme.Spacing.s)
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(title), \(value)")
    }

    private var addToTeamButton: some View {
        Button {
            viewModel.addToTeam()
            showTeamAlert = true
        } label: {
            HStack(spacing: Theme.Spacing.s) {
                Image(systemName: "person.2.fill")
                Text(viewModel.isAlreadyInTeam ? "Já está no time" : "Adicionar ao time")
                    .font(Theme.Font.rowTitle)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, Theme.Spacing.m)
        }
        .buttonStyle(.plain)
        .foregroundStyle(viewModel.isAlreadyInTeam ? Theme.Color.secondaryText : .white)
        .background(
            viewModel.isAlreadyInTeam ? Color.primary.opacity(0.08) : Theme.Color.accent,
            in: Capsule()
        )
        .disabled(viewModel.isAlreadyInTeam)
    }
}
