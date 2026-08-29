import Foundation

/// Composition root: um repositório compartilhado para lista e detalhe
/// reutilizarem o mesmo cache de `PokemonDetail`.
struct AppDependencies {

    let fetchPage: FetchPokemonPageUseCase
    let fetchDetail: FetchPokemonDetailUseCase

    init(client: HTTPClient = URLSessionHTTPClient()) {
        let repository = RemotePokemonRepository(client: client)
        fetchPage = DefaultFetchPokemonPageUseCase(repository: repository)
        fetchDetail = DefaultFetchPokemonDetailUseCase(repository: repository)
    }
}
