import Foundation

func formatPokemonName(_ raw: String) -> String {
    raw.split(separator: "-")
        .map(formatNameToken)
        .joined(separator: " ")
}

func formatPokedexNumber(_ id: Int) -> String {
    String(format: "#%03d", id)
}

func formatHeight(_ decimeters: Int) -> String {
    let meters = decimeters / 10
    let tenths = decimeters % 10
    return "\(meters),\(tenths) m"
}

func formatWeight(_ hectograms: Int) -> String {
    let kilograms = hectograms / 10
    let tenths = hectograms % 10
    return "\(kilograms),\(tenths) kg"
}

func statValue(named name: String, in stats: [(name: String, base: Int)]) -> Int? {
    stats.first { $0.name.lowercased() == name.lowercased() }?.base
}

private func formatNameToken(_ token: Substring) -> String {
    switch token.lowercased() {
    case "mr": return "Mr."
    case "mrs": return "Mrs."
    case "jr": return "Jr."
    case "sr": return "Sr."
    default: return token.capitalized
    }
}
