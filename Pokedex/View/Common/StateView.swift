import SwiftUI

struct StateView: View {

    enum Content: Equatable {
        case loading(message: String? = nil)
        case empty(message: String)
        case failure(message: String)
    }

    let content: Content
    var onRetry: (() -> Void)?

    var body: some View {
        VStack(spacing: Theme.Spacing.m) {
            switch content {
            case .loading(let message):
                VStack(spacing: Theme.Spacing.loadingBlock) {
                    PokeballLoading()

                    if let message {
                        VStack(spacing: Theme.Spacing.xs) {
                            Text("VOCÊ SABIA?")
                                .font(Theme.Font.loadingTriviaLabel)
                                .foregroundStyle(Theme.Color.loadingTriviaLabel)

                            Text(message)
                                .font(Theme.Font.loadingTriviaBody)
                                .foregroundStyle(Theme.Color.loadingTriviaFact)
                                .multilineTextAlignment(.center)
                                .lineSpacing(2)
                                .lineLimit(3)
                                .frame(maxWidth: 300)
                        }
                        .accessibilityElement(children: .combine)
                        .accessibilityLabel("Você sabia? \(message)")
                    }
                }

            case .empty(let text):
                messageText(text)

            case .failure(let text):
                messageText(text)
                Button("Tentar de novo") { onRetry?() }
            }
        }
        .padding(Theme.Spacing.l)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Theme.Color.background)
    }

    private func messageText(_ text: String) -> some View {
        Text(text)
            .font(Theme.Font.body)
            .foregroundStyle(Theme.Color.secondaryText)
            .multilineTextAlignment(.center)
    }
}
