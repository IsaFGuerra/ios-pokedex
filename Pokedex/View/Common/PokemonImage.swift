import SwiftUI

/// Imagem de um Pokémon, baixada da URL. Mostra um marcador enquanto não há
/// imagem — inclusive quando a URL é `nil`.
///
/// TODO (bônus): `AsyncImage` não guarda nada em memória: rolar a lista para
/// cima e para baixo refaz o download. A própria PokéAPI pede, na política de
/// uso justo, que os clientes façam cache local dos recursos.
struct PokemonImage: View {

    let url: URL?

    var body: some View {
        AsyncImage(url: url) { image in
            image
                .resizable()
                .scaledToFit()
        } placeholder: {
            Image(systemName: "questionmark.circle")
                .resizable()
                .scaledToFit()
                .foregroundStyle(Theme.Color.secondaryText)
                .padding(Theme.Spacing.xs)
        }
    }
}
