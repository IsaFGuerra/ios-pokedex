import Foundation

func formatPokemonName(_ raw: String) -> String {
    raw.split(separator: "-")
        .map(formatNameToken)
        .joined(separator: " ")
}

func formatPokedexNumber(_ id: Int) -> String {
    String(format: "#%03d", id)
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
