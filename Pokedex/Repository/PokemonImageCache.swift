import UIKit

/// Cache em memória dos sprites baixados da rede.
enum PokemonImageCache {

    private static let storage: NSCache<NSURL, UIImage> = {
        let cache = NSCache<NSURL, UIImage>()
        cache.countLimit = 200
        return cache
    }()

    static func image(for url: URL?) async -> UIImage? {
        guard let url else { return nil }

        let key = url as NSURL
        if let cached = storage.object(forKey: key) {
            return cached
        }

        guard let (data, _) = try? await URLSession.shared.data(from: url),
              let image = UIImage(data: data) else {
            return nil
        }

        storage.setObject(image, forKey: key)
        return image
    }
}
