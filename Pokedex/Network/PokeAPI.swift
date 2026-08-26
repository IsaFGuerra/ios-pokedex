import Foundation

/// Endpoints da PokéAPI (https://pokeapi.co/docs/v2).
/// Não precisa de chave nem autenticação.
enum PokeAPI {

    static let baseURL = URL(string: "https://pokeapi.co/api/v2")!

    static func pokemonList(limit: Int, offset: Int) -> URL {
        var components = URLComponents(
            url: baseURL.appendingPathComponent("pokemon"),
            resolvingAgainstBaseURL: false
        )!
        components.queryItems = [
            URLQueryItem(name: "limit", value: String(limit)),
            URLQueryItem(name: "offset", value: String(offset))
        ]
        return components.url!
    }

    static func pokemon(id: Int) -> URL {
        baseURL.appendingPathComponent("pokemon").appendingPathComponent(String(id))
    }
}
