import SwiftUI

enum Theme {

    enum Color {
        static let background = SwiftUI.Color(.systemGroupedBackground)
        static let surface = SwiftUI.Color(.secondarySystemGroupedBackground)
        static let primaryText = SwiftUI.Color.primary
        static let secondaryText = SwiftUI.Color.secondary
        static let accent = SwiftUI.Color.indigo

        static let loadingTriviaLabel = SwiftUI.Color.primary.opacity(0.45)
        static let loadingTriviaFact = SwiftUI.Color.primary.opacity(0.62)

        static func forPokemonType(_ type: String) -> SwiftUI.Color {
            switch type.lowercased() {
            case "normal":   return SwiftUI.Color(red: 0.66, green: 0.66, blue: 0.47)
            case "fire":     return SwiftUI.Color(red: 0.94, green: 0.50, blue: 0.19)
            case "water":    return SwiftUI.Color(red: 0.39, green: 0.56, blue: 0.94)
            case "electric": return SwiftUI.Color(red: 0.97, green: 0.82, blue: 0.19)
            case "grass":    return SwiftUI.Color(red: 0.48, green: 0.78, blue: 0.30)
            case "ice":      return SwiftUI.Color(red: 0.59, green: 0.85, blue: 0.84)
            case "fighting": return SwiftUI.Color(red: 0.76, green: 0.18, blue: 0.16)
            case "poison":   return SwiftUI.Color(red: 0.64, green: 0.24, blue: 0.63)
            case "ground":   return SwiftUI.Color(red: 0.88, green: 0.75, blue: 0.41)
            case "flying":   return SwiftUI.Color(red: 0.66, green: 0.56, blue: 0.95)
            case "psychic":  return SwiftUI.Color(red: 0.98, green: 0.34, blue: 0.53)
            case "bug":      return SwiftUI.Color(red: 0.65, green: 0.73, blue: 0.10)
            case "rock":     return SwiftUI.Color(red: 0.71, green: 0.63, blue: 0.21)
            case "ghost":    return SwiftUI.Color(red: 0.45, green: 0.34, blue: 0.59)
            case "dragon":   return SwiftUI.Color(red: 0.44, green: 0.21, blue: 0.98)
            case "dark":     return SwiftUI.Color(red: 0.44, green: 0.34, blue: 0.27)
            case "steel":    return SwiftUI.Color(red: 0.72, green: 0.72, blue: 0.81)
            case "fairy":    return SwiftUI.Color(red: 0.93, green: 0.60, blue: 0.67)
            default:         return SwiftUI.Color.gray
            }
        }
    }

    enum Font {
        static let title = SwiftUI.Font.title2
        static let body = SwiftUI.Font.body
        static let caption = SwiftUI.Font.caption
        static let rowTitle = SwiftUI.Font.body.bold()
        static let loadingTriviaLabel = SwiftUI.Font.system(size: 12, weight: .semibold)
        static let loadingTriviaBody = SwiftUI.Font.system(size: 17)
    }

    enum Spacing {
        static let xs: CGFloat = 4
        static let s: CGFloat = 8
        static let m: CGFloat = 16
        static let l: CGFloat = 24
        static let loadingBlock: CGFloat = 32
        static let loadingTrivia: CGFloat = 6
    }
}
