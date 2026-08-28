import Foundation

struct PokemonListEntry: Equatable {
    let name: String
    let detailURL: URL

    var detailID: Int? {
        let last = detailURL.pathComponents.last { $0 != "/" && Int($0) != nil }
        return last.flatMap(Int.init)
    }
}
