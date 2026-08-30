import XCTest
@testable import Pokedex

final class ManageTeamUseCaseTests: XCTestCase {

    private var repository: TeamRepositoryStub!
    private var sut: DefaultManageTeamUseCase!

    override func setUp() {
        super.setUp()
        repository = TeamRepositoryStub()
        sut = DefaultManageTeamUseCase(repository: repository)
    }

    override func tearDown() {
        repository = nil
        sut = nil
        super.tearDown()
    }

    func test_add_persisteOMembroNaOrdem() throws {
        let bulbasaur = TeamMember.stub(id: 1, name: "bulbasaur")
        let charmander = TeamMember.stub(id: 4, name: "charmander", types: ["fire"])

        try sut.add(bulbasaur)
        try sut.add(charmander)

        XCTAssertEqual(sut.currentTeam(), [bulbasaur, charmander])
        XCTAssertEqual(repository.members, [bulbasaur, charmander])
    }

    func test_add_rejeitaDuplicataPeloId() {
        let first = TeamMember.stub(id: 1, name: "bulbasaur")
        repository.members = [first]

        do {
            try sut.add(TeamMember.stub(id: 1, name: "outro-nome"))
            XCTFail("Deveria ter lançado erro")
        } catch {
            XCTAssertEqual(error as? TeamError, .alreadyInTeam(name: "outro-nome"))
            XCTAssertEqual(repository.members, [first])
        }
    }

    func test_add_rejeitaQuandoTimeCheio() {
        repository.members = (1...Team.maxSize).map { TeamMember.stub(id: $0, name: "p\($0)") }
        let extra = TeamMember.stub(id: 99, name: "mew")

        do {
            try sut.add(extra)
            XCTFail("Deveria ter lançado erro")
        } catch {
            XCTAssertEqual(error as? TeamError, .teamFull)
            XCTAssertEqual(repository.members.count, Team.maxSize)
            XCTAssertFalse(repository.members.contains(where: { $0.id == 99 }))
        }
    }

    func test_remove_removePeloIdEPersiste() {
        let bulbasaur = TeamMember.stub(id: 1, name: "bulbasaur")
        let charmander = TeamMember.stub(id: 4, name: "charmander", types: ["fire"])
        repository.members = [bulbasaur, charmander]

        sut.remove(id: 1)

        XCTAssertEqual(sut.currentTeam(), [charmander])
        XCTAssertEqual(repository.members, [charmander])
    }

    func test_remove_idInexistenteNaoAlteraOTime() {
        let bulbasaur = TeamMember.stub(id: 1, name: "bulbasaur")
        repository.members = [bulbasaur]

        sut.remove(id: 999)

        XCTAssertEqual(repository.members, [bulbasaur])
    }

    func test_summary_timeVazio() {
        let summary = sut.summary()

        XCTAssertEqual(summary.count, 0)
        XCTAssertEqual(summary.coveredTypes, [])
    }

    func test_summary_contaMembrosETiposUnicosNaOrdem() {
        repository.members = [
            .stub(id: 1, name: "bulbasaur", types: ["grass", "poison"]),
            .stub(id: 4, name: "charmander", types: ["fire"]),
            .stub(id: 43, name: "oddish", types: ["grass", "poison"]),
        ]

        let summary = sut.summary()

        XCTAssertEqual(summary.count, 3)
        XCTAssertEqual(summary.coveredTypes, ["grass", "poison", "fire"])
    }
}
