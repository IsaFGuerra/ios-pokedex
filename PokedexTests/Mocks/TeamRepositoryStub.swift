import Foundation
@testable import Pokedex

/// Dublê do time: guarda os membros em memória. Sem UserDefaults.
final class TeamRepositoryStub: TeamRepository {

    var members: [TeamMember]

    init(members: [TeamMember] = []) {
        self.members = members
    }

    func load() -> [TeamMember] {
        members
    }

    func save(_ members: [TeamMember]) {
        self.members = members
    }
}

extension TeamMember {
    static func stub(
        id: Int = 1,
        name: String = "bulbasaur",
        spriteURL: URL? = URL(string: "https://example.com/sprite.png"),
        types: [String] = ["grass", "poison"]
    ) -> TeamMember {
        TeamMember(id: id, name: name, spriteURL: spriteURL, types: types)
    }
}
