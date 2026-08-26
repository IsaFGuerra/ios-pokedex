import SwiftUI

/// Linha da lista.
///
/// TODO (Tarefa 2): hoje a linha mostra só o nome raw vindo da API
/// ("bulbasaur"). Ela precisa mostrar:
///   - o nome formatado para leitura ("Bulbasaur", "Mr. Mime");
///   - o número na Pokédex, com três dígitos (#001);
///   - o sprite;
///   - as tags de tipo, coloridas com `Theme.Color.forPokemonType(_:)`.
struct PokemonRow: View {

    let row: PokemonRowModel

    var body: some View {
        HStack(spacing: Theme.Spacing.m) {
            PokemonImage(url: nil)
                .frame(width: 48, height: 48)
                .padding(Theme.Spacing.xs)
                .background(Theme.Color.background, in: Circle())

            Text(row.name)
                .font(Theme.Font.rowTitle)
                .foregroundStyle(Theme.Color.primaryText)

            Spacer(minLength: 0)
        }
        .padding(.vertical, Theme.Spacing.xs)
    }
}
