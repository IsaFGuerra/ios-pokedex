import SwiftUI
import UIKit

/// Imagem de um Pokémon baixada da URL, com cache em memória.
struct PokemonImage: View {

    let url: URL?

    @State private var image: UIImage?

    var body: some View {
        Group {
            if let image {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFit()
            } else {
                Image(systemName: "questionmark.circle")
                    .resizable()
                    .scaledToFit()
                    .foregroundStyle(Theme.Color.secondaryText)
                    .padding(Theme.Spacing.xs)
            }
        }
        .task(id: url) {
            image = await PokemonImageCache.image(for: url)
        }
    }
}
