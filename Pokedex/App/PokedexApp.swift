import SwiftUI

@main
struct PokedexApp: App {

    private let dependencies = AppDependencies()

    var body: some Scene {
        WindowGroup {
            NavigationStack {
                PokemonListView(
                    viewModel: PokemonListViewModel(
                        fetchPage: dependencies.fetchPage,
                        fetchDetail: dependencies.fetchDetail
                    ),
                    fetchDetail: dependencies.fetchDetail,
                    manageTeam: dependencies.manageTeam
                )
            }
        }
    }
}
