import Foundation

@MainActor
@Observable
final class TeamViewModel {

    private(set) var members: [TeamMember] = []
    private(set) var summary = TeamSummary(count: 0, coveredTypes: [])

    private let manageTeam: ManageTeamUseCase

    init(manageTeam: ManageTeamUseCase) {
        self.manageTeam = manageTeam
    }

    func load() {
        members = manageTeam.currentTeam()
        summary = manageTeam.summary()
    }

    func remove(id: Int) {
        manageTeam.remove(id: id)
        load()
    }
}
