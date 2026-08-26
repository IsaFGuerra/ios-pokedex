import Foundation

/// Persistência do time. Já está pronta, não precisa mexer aqui.
protocol TeamRepository {
    func load() -> [TeamMember]
    func save(_ members: [TeamMember])
}

final class UserDefaultsTeamRepository: TeamRepository {

    private enum Key {
        static let team = "com.teste.pokedex.team"
    }

    private let defaults: UserDefaults

    init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
    }

    func load() -> [TeamMember] {
        guard let data = defaults.data(forKey: Key.team) else { return [] }
        return (try? JSONDecoder().decode([TeamMember].self, from: data)) ?? []
    }

    func save(_ members: [TeamMember]) {
        guard let data = try? JSONEncoder().encode(members) else { return }
        defaults.set(data, forKey: Key.team)
    }
}
