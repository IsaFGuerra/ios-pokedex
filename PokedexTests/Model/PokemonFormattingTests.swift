import XCTest
@testable import Pokedex

final class PokemonFormattingTests: XCTestCase {

    func test_formatPokemonName_capitalizaNomeSimples() {
        XCTAssertEqual(formatPokemonName("bulbasaur"), "Bulbasaur")
    }

    func test_formatPokemonName_trataMrMime() {
        XCTAssertEqual(formatPokemonName("mr-mime"), "Mr. Mime")
    }

    func test_formatPokemonName_trataMimeJr() {
        XCTAssertEqual(formatPokemonName("mime-jr"), "Mime Jr.")
    }

    func test_formatPokedexNumber_completaComTresDigitos() {
        XCTAssertEqual(formatPokedexNumber(1), "#001")
        XCTAssertEqual(formatPokedexNumber(7), "#007")
        XCTAssertEqual(formatPokedexNumber(25), "#025")
        XCTAssertEqual(formatPokedexNumber(150), "#150")
    }

    func test_detailID_extraiIdDaURLDeDetalhe() {
        let entry = PokemonListEntry.stub(id: 7, name: "squirtle")
        XCTAssertEqual(entry.detailID, 7)
    }

    func test_rowModel_formataCamposAPartirDoDetalhe() {
        let detail = PokemonDetail.stub(id: 122, name: "mr-mime", types: ["psychic", "fairy"])
        let row = PokemonRowModel(
            detail: detail,
            detailURL: URL(string: "https://pokeapi.co/api/v2/pokemon/122/")!
        )

        XCTAssertEqual(row.id, 122)
        XCTAssertEqual(row.displayName, "Mr. Mime")
        XCTAssertEqual(row.pokedexNumber, "#122")
        XCTAssertEqual(row.types, ["psychic", "fairy"])
    }

    // MARK: - Tarefa 3 (Red)

    func test_formatHeight_decimetrosParaMetros() {
        XCTAssertEqual(formatHeight(7), "0,7 m")
    }

    func test_formatHeight_valorInteiroEmMetros() {
        XCTAssertEqual(formatHeight(10), "1,0 m")
    }

    func test_formatWeight_hectogramasParaQuilos() {
        XCTAssertEqual(formatWeight(69), "6,9 kg")
    }

    func test_formatWeight_valorInteiroEmQuilos() {
        XCTAssertEqual(formatWeight(100), "10,0 kg")
    }

    func test_statValue_extraiHP() {
        XCTAssertEqual(statValue(named: "hp", in: Self.bulbasaurStats), 45)
    }

    func test_statValue_extraiAttack() {
        XCTAssertEqual(statValue(named: "attack", in: Self.bulbasaurStats), 49)
    }

    func test_statValue_extraiDefense() {
        XCTAssertEqual(statValue(named: "defense", in: Self.bulbasaurStats), 49)
    }

    func test_statValue_retornaNilQuandoStatNaoExiste() {
        XCTAssertNil(statValue(named: "speed", in: Self.bulbasaurStats))
    }

    private static let bulbasaurStats: [(name: String, base: Int)] = [
        (name: "hp", base: 45),
        (name: "attack", base: 49),
        (name: "defense", base: 49),
    ]
}
