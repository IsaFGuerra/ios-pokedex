import SwiftUI

@main
struct PokedexApp: App {

    var body: some Scene {
        WindowGroup {
            NavigationStack {
                PokemonListView(viewModel: PokemonListViewModel())
            }
        }
    }
}
