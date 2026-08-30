import SwiftUI

struct PokemonTypeTag: View {

    let type: String

    var body: some View {
        Text(type)
            .font(Theme.Font.caption.bold())
            .foregroundStyle(.white)
            .lineLimit(1)
            .fixedSize()
            .padding(.horizontal, Theme.Spacing.s)
            .padding(.vertical, Theme.Spacing.xs)
            .background(Theme.Color.forPokemonType(type), in: Capsule())
    }
}
