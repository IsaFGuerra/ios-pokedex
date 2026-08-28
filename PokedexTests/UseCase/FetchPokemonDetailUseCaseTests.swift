import XCTest
@testable import Pokedex

final class FetchPokemonDetailUseCaseTests: XCTestCase {

    func test_execute_devolveODetalheDoRepositorio() async throws {
        let stub = PokemonRepositoryStub()
        let charmander = PokemonDetail.stub(id: 4, name: "charmander", types: ["fire"])
        stub.defaultDetailResult = .success(charmander)

        let useCase = DefaultFetchPokemonDetailUseCase(repository: stub)
        let result = try await useCase.execute(id: 4)

        XCTAssertEqual(result, charmander)
    }

    func test_execute_propagaErroDoRepositorio() async {
        let stub = PokemonRepositoryStub()
        stub.defaultDetailResult = .failure(NetworkError.noConnection)

        let useCase = DefaultFetchPokemonDetailUseCase(repository: stub)

        do {
            _ = try await useCase.execute(id: 1)
            XCTFail("Deveria ter lançado erro")
        } catch {
            XCTAssertEqual(error as? NetworkError, .noConnection)
        }
    }
}
