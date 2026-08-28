import SwiftUI

struct PokemonRow: View {

    let row: PokemonRowModel

    var body: some View {
        HStack(spacing: Theme.Spacing.m) {
            PokemonImage(url: row.spriteURL)
                .frame(width: 48, height: 48)
                .padding(Theme.Spacing.xs)
                .background(Theme.Color.background, in: Circle())

            VStack(alignment: .leading, spacing: Theme.Spacing.xs) {
                Text(row.displayName)
                    .font(Theme.Font.rowTitle)
                    .foregroundStyle(Theme.Color.primaryText)
                    .lineLimit(1)

                Text(row.pokedexNumber)
                    .font(Theme.Font.caption)
                    .foregroundStyle(Theme.Color.secondaryText)
            }

            Spacer(minLength: Theme.Spacing.s)

            HStack(spacing: Theme.Spacing.xs) {
                ForEach(row.types, id: \.self) { type in
                    Text(type)
                        .font(Theme.Font.caption.bold())
                        .foregroundStyle(.white)
                        .padding(.horizontal, Theme.Spacing.s)
                        .padding(.vertical, Theme.Spacing.xs)
                        .background(Theme.Color.forPokemonType(type), in: Capsule())
                }
            }
        }
        .padding(.vertical, Theme.Spacing.xs)
        .accessibilityElement(children: .combine)
        .accessibilityLabel(accessibilityLabel)
    }

    private var accessibilityLabel: String {
        let typesText = row.types.joined(separator: ", ")
        if typesText.isEmpty {
            return "\(row.displayName), \(row.pokedexNumber)"
        }
        return "\(row.displayName), \(row.pokedexNumber), tipos \(typesText)"
    }
}
