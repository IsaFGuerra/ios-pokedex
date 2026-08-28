import SwiftUI

/// View de estado (carregando / vazio / erro), usada no lugar do conteúdo.
///
/// Reaproveite nas telas novas em vez de espalhar `ProgressView` e `Text`.
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
                ProgressView()
                    .controlSize(.large)
                if let message {
                    messageText(message)
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
