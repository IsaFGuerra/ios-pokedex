import Foundation

struct AppDependencies {

    let fetchPage: FetchPokemonPageUseCase
    let fetchDetail: FetchPokemonDetailUseCase

    init(client: HTTPClient = URLSessionHTTPClient()) {
        let repository = RemotePokemonRepository(client: client)
        fetchPage = DefaultFetchPokemonPageUseCase(repository: repository)
        fetchDetail = DefaultFetchPokemonDetailUseCase(repository: repository)
    }
}
