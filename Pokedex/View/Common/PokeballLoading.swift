import ImageIO
import SwiftUI
import UIKit

/// Pokébola animada para o estado de loading (`Pokeball.gif`).
struct PokeballLoading: View {

    private let size: CGFloat = 56

    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @Environment(\.displayScale) private var displayScale

    var body: some View {
        PokeballGIFView(animates: !reduceMotion, pointSize: size, scale: displayScale)
            .frame(width: size, height: size)
            .accessibilityElement()
            .accessibilityLabel("Carregando")
            .accessibilityAddTraits(.updatesFrequently)
    }
}

private struct PokeballGIFView: UIViewRepresentable {

    let animates: Bool
    let pointSize: CGFloat
    let scale: CGFloat

    func makeCoordinator() -> Coordinator {
        Coordinator()
    }

    func makeUIView(context: Context) -> UIImageView {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.image = gifImage(animates: animates)
        context.coordinator.lastAnimates = animates
        return imageView
    }

    func updateUIView(_ imageView: UIImageView, context: Context) {
        guard context.coordinator.lastAnimates != animates else { return }
        context.coordinator.lastAnimates = animates
        imageView.image = gifImage(animates: animates)
    }

    func sizeThatFits(_ proposal: ProposedViewSize, uiView: UIImageView, context: Context) -> CGSize? {
        CGSize(width: pointSize, height: pointSize)
    }

    private func gifImage(animates: Bool) -> UIImage? {
        guard let url = Bundle.main.url(forResource: "Pokeball", withExtension: "gif"),
              let data = try? Data(contentsOf: url),
              let source = CGImageSourceCreateWithData(data as CFData, nil) else {
            return nil
        }

        let frameCount = CGImageSourceGetCount(source)
        guard frameCount > 0 else { return nil }

        let pixelSize = pointSize * scale
        let drawSize = CGSize(width: pixelSize, height: pixelSize)

        func frame(at index: Int) -> UIImage? {
            guard let cgImage = CGImageSourceCreateImageAtIndex(source, index, nil) else { return nil }

            let format = UIGraphicsImageRendererFormat()
            format.scale = 1
            format.opaque = false

            return UIGraphicsImageRenderer(size: drawSize, format: format).image { _ in
                UIImage(cgImage: cgImage).draw(in: CGRect(origin: .zero, size: drawSize))
            }
        }

        if !animates {
            return frame(at: 0)
        }

        var images: [UIImage] = []
        var duration = 0.0

        for index in 0..<frameCount {
            guard let image = frame(at: index) else { continue }
            images.append(image)

            if let properties = CGImageSourceCopyPropertiesAtIndex(source, index, nil) as? [CFString: Any],
               let gif = properties[kCGImagePropertyGIFDictionary] as? [CFString: Any] {
                let delay = gif[kCGImagePropertyGIFUnclampedDelayTime] as? TimeInterval
                    ?? gif[kCGImagePropertyGIFDelayTime] as? TimeInterval
                    ?? 0.1
                duration += max(delay, 0.02)
            } else {
                duration += 0.1
            }
        }

        return UIImage.animatedImage(with: images, duration: duration)
    }

    final class Coordinator {
        var lastAnimates: Bool?
    }
}
