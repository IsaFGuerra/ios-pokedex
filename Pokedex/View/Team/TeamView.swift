import SwiftUI

struct TeamView: View {

    @State private var viewModel: TeamViewModel

    init(viewModel: TeamViewModel) {
        _viewModel = State(initialValue: viewModel)
    }

    var body: some View {
        Group {
            if viewModel.members.isEmpty {
                StateView(content: .empty(message: "Seu time está vazio."))
            } else {
                teamList
            }
        }
        .navigationTitle("Meu Time")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear { viewModel.load() }
    }

    private var teamList: some View {
        List {
            Section {
                summaryHeader
            }

            Section {
                ForEach(viewModel.members, id: \.id) { member in
                    teamRow(member)
                        .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                            Button("Remover", role: .destructive) {
                                viewModel.remove(id: member.id)
                            }
                        }
                }
            }
        }
        .listStyle(.insetGrouped)
    }

    private var summaryHeader: some View {
        VStack(alignment: .leading, spacing: Theme.Spacing.s) {
            Text("\(viewModel.summary.count) / \(Team.maxSize)")
                .font(Theme.Font.title)
                .foregroundStyle(Theme.Color.primaryText)

            if viewModel.summary.coveredTypes.isEmpty {
                Text("Nenhum tipo ainda")
                    .font(Theme.Font.caption)
                    .foregroundStyle(Theme.Color.secondaryText)
            } else {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: Theme.Spacing.xs) {
                        ForEach(viewModel.summary.coveredTypes, id: \.self) { type in
                            PokemonTypeTag(type: type)
                        }
                    }
                }
            }
        }
        .padding(.vertical, Theme.Spacing.xs)
        .accessibilityElement(children: .combine)
        .accessibilityLabel(summaryAccessibilityLabel)
    }

    private func teamRow(_ member: TeamMember) -> some View {
        HStack(spacing: Theme.Spacing.m) {
            PokemonImage(url: member.spriteURL)
                .frame(width: 48, height: 48)
                .padding(Theme.Spacing.xs)
                .background(Theme.Color.background, in: Circle())

            VStack(alignment: .leading, spacing: Theme.Spacing.xs) {
                Text(formatPokemonName(member.name))
                    .font(Theme.Font.rowTitle)
                    .foregroundStyle(Theme.Color.primaryText)
                    .lineLimit(1)

                Text(formatPokedexNumber(member.id))
                    .font(Theme.Font.caption)
                    .foregroundStyle(Theme.Color.secondaryText)
            }
        }
        .padding(.vertical, Theme.Spacing.xs)
        .accessibilityElement(children: .combine)
        .accessibilityLabel(
            "\(formatPokemonName(member.name)), \(formatPokedexNumber(member.id))"
        )
        .accessibilityHint("Deslize para remover do time")
    }

    private var summaryAccessibilityLabel: String {
        let types = viewModel.summary.coveredTypes
        if types.isEmpty {
            return "\(viewModel.summary.count) de \(Team.maxSize) Pokémon"
        }
        return "\(viewModel.summary.count) de \(Team.maxSize) Pokémon, tipos \(types.joined(separator: ", "))"
    }
}
