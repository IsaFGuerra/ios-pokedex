import Foundation

struct AppDependencies {

    let fetchPage: FetchPokemonPageUseCase
    let fetchDetail: FetchPokemonDetailUseCase
    let manageTeam: ManageTeamUseCase

    init(client: HTTPClient = URLSessionHTTPClient()) {
        let repository = RemotePokemonRepository(client: client)
        fetchPage = DefaultFetchPokemonPageUseCase(repository: repository)
        fetchDetail = DefaultFetchPokemonDetailUseCase(repository: repository)
        manageTeam = DefaultManageTeamUseCase(repository: UserDefaultsTeamRepository())
    }
}
