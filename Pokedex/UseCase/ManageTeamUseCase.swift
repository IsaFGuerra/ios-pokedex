import Foundation

/// Adicione aqui regras de negócio com relação à adição de novos Pokémon no time
/// Já foi criado aqui a regra "Não deve ser possível adicionar no time um pokemon que já faz parte dele" para servir de exemplo
/// Você é livre para adicionar quaisquer outras regras que ache válidas
enum TeamError: LocalizedError, Equatable {
    case alreadyInTeam(name: String)

    var errorDescription: String? {
        switch self {
        case .alreadyInTeam(let name):
            return "\(name) já está no seu time."
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

    // MARK: - TODO (Tarefa 4)
    //
    // O contrato esperado:
    //
    // - `add`: adiciona novo Pokémon no time
    // - `remove`: remove Pokémon do time pelo id
    // - `summary`: ver a documentação de `TeamSummary` em `Model/Team.swift`.

    func currentTeam() -> [TeamMember] {
        repository.load()
    }

    func add(_ member: TeamMember) throws {
        fatalError("TODO: Tarefa 4")
    }

    func remove(id: Int) {
        fatalError("TODO: Tarefa 4")
    }

    func summary() -> TeamSummary {
        fatalError("TODO: Tarefa 4")
    }
}
