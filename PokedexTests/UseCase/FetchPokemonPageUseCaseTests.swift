import XCTest
@testable import Pokedex

/// Teste de exemplo — serve de modelo caso você escreva os seus (é bônus).
final class FetchPokemonPageUseCaseTests: XCTestCase {

    private var repository: PokemonRepositoryStub!
    private var sut: DefaultFetchPokemonPageUseCase!

    override func setUp() {
        super.setUp()
        repository = PokemonRepositoryStub()
        sut = DefaultFetchPokemonPageUseCase(repository: repository)
    }

    override func tearDown() {
        repository = nil
        sut = nil
        super.tearDown()
    }

    func test_execute_pedeAoRepositorioOOffsetInformadoComOTamanhoDePaginaFixo() async throws {
        _ = try await sut.execute(offset: 40)

        XCTAssertEqual(
            repository.calls,
            [.init(offset: 40, limit: DefaultFetchPokemonPageUseCase.pageSize)]
        )
    }

    func test_execute_propagaOErroDoRepositorio() async {
        repository.defaultResult = .failure(NetworkError.noConnection)

        do {
            _ = try await sut.execute(offset: 0)
            XCTFail("Era esperado um erro")
        } catch {
            XCTAssertEqual(error as? NetworkError, .noConnection)
        }
    }
}
