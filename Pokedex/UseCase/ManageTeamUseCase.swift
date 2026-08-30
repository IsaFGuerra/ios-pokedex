import Foundation

/// Adicione aqui regras de negócio com relação à adição de novos Pokémon no time
/// Já foi criado aqui a regra "Não deve ser possível adicionar no time um pokemon que já faz parte dele" para servir de exemplo
/// Você é livre para adicionar quaisquer outras regras que ache válidas
enum TeamError: LocalizedError, Equatable {
    case alreadyInTeam(name: String)
    case teamFull
    
    var errorDescription: String? {
        switch self {
        case .alreadyInTeam(let name):
            return "\(name) já está no seu time."
        case .teamFull:
            return "O time já tem \(Team.maxSize) Pokémon."
        }
    }
}

enum Team {
    static let maxSize = 6
}

protocol ManageTeamUseCase {
    func currentTeam() -> [TeamMember]
    func add(_ member: TeamMember) throws
    func remove(id: Int)
    func summary() -> TeamSummary
}

final class DefaultManageTeamUseCase: ManageTeamUseCase {
    
    private let repository: TeamRepository
    
    init(repository: TeamRepository) {
        self.repository = repository
    }
    
    func currentTeam() -> [TeamMember] {
        repository.load()
    }
    
    func add(_ member: TeamMember) throws {
        var team = repository.load()
        
        if team.contains(where: { $0.id == member.id }) {
            throw TeamError.alreadyInTeam(name: member.name)
        }
        
        if team.count >= Team.maxSize {
            throw TeamError.teamFull
        }
        
        team.append(member)
        repository.save(team)
    }
    
    func remove(id: Int) {
        var team = repository.load()
        team.removeAll { $0.id == id }
        repository.save(team)
    }
    
    func summary() -> TeamSummary {
        let team = repository.load()
        var coveredTypes: [String] = []
        
        for member in team {
            for type in member.types {
                if !coveredTypes.contains(type) {
                    coveredTypes.append(type)
                }
            }
        }
        
        return TeamSummary(count: team.count, coveredTypes: coveredTypes)
    }
}
