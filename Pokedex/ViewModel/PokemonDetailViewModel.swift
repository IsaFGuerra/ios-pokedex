import Foundation

@MainActor
@Observable
final class PokemonDetailViewModel {

    enum State: Equatable {
        case loading
        case loaded(PokemonDetail)
        case failure(message: String)
    }

    private(set) var state: State = .loading
    private(set) var teamAlertMessage: String?
    private(set) var isAlreadyInTeam = false

    private let pokemonID: Int
    private let fetchDetail: FetchPokemonDetailUseCase
    private let manageTeam: ManageTeamUseCase

    init(
        pokemonID: Int,
        fetchDetail: FetchPokemonDetailUseCase,
        manageTeam: ManageTeamUseCase
    ) {
        self.pokemonID = pokemonID
        self.fetchDetail = fetchDetail
        self.manageTeam = manageTeam
    }

    func load() async {
        state = .loading

        do {
            let detail = try await fetchDetail.execute(id: pokemonID)
            state = .loaded(detail)
            isAlreadyInTeam = manageTeam.currentTeam().contains { $0.id == pokemonID }
        } catch {
            state = .failure(message: error.localizedDescription)
        }
    }

    func addToTeam() {
        guard !isAlreadyInTeam else { return }
        guard case .loaded(let detail) = state else { return }

        let member = TeamMember(
            id: detail.id,
            name: detail.name,
            spriteURL: detail.spriteURL,
            types: detail.types
        )

        do {
            try manageTeam.add(member)
            isAlreadyInTeam = true
            teamAlertMessage = "\(formatPokemonName(detail.name)) foi adicionado ao time."
        } catch {
            teamAlertMessage = error.localizedDescription
        }
    }
}
