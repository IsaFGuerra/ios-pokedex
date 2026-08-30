import Foundation

/// Um Pokémon salvo no time do usuário.
/// Inicialmente contém apenas o `id` ,`name` e  `spriteURL` mas você pode incluir outros valores que achar necessário, como, por ex, o tipo.
struct TeamMember: Codable, Equatable {
    let id: Int
    let name: String
    let spriteURL: URL?
    let types: [String]
}

/// Resumo do time para ser exibido no topo da tela "Meu Time"
/// Você pode adicionar outras informações que ache relevante.
struct TeamSummary: Equatable {
    /// Quantidade de Pokémon no time.
    let count: Int
    
    /// Tipos (água, fogo, pedra, etc) cobertos pelo time, sem repetição.
    let coveredTypes: [String]
}
