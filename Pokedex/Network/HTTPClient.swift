import Foundation

/// Erros de rede
enum NetworkError: LocalizedError, Equatable {
    case invalidResponse
    case unexpectedStatusCode(Int)
    case decodingFailed
    case noConnection

    var errorDescription: String? {
        switch self {
        case .invalidResponse:
            return "Resposta inesperada do servidor."
        case .unexpectedStatusCode(let code):
            return "O servidor respondeu com erro (\(code))."
        case .decodingFailed:
            return "Não foi possível ler os dados recebidos."
        case .noConnection:
            return "Sem conexão com a internet."
        }
    }
}

protocol HTTPClient {
    func get<T: Decodable>(_ url: URL, as type: T.Type) async throws -> T
}

final class URLSessionHTTPClient: HTTPClient {

    private let session: URLSession
    private let decoder: JSONDecoder

    init(session: URLSession = .shared) {
        self.session = session

        let decoder = JSONDecoder()
        // A PokéAPI usa snake_case (front_default, base_stat, ...).
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        self.decoder = decoder
    }

    func get<T: Decodable>(_ url: URL, as type: T.Type) async throws -> T {
        let data: Data
        let response: URLResponse

        do {
            (data, response) = try await session.data(from: url)
        } catch let error as URLError where error.code == .notConnectedToInternet {
            throw NetworkError.noConnection
        }

        guard let http = response as? HTTPURLResponse else {
            throw NetworkError.invalidResponse
        }
        guard (200..<300).contains(http.statusCode) else {
            throw NetworkError.unexpectedStatusCode(http.statusCode)
        }

        do {
            return try decoder.decode(type, from: data)
        } catch {
            throw NetworkError.decodingFailed
        }
    }
}
