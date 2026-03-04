import SwiftUI
import ImageIO

@Observable
final class ImageCacheService {
    static let shared = ImageCacheService()

    private let cache = NSCache<NSString, UIImage>()
    private var activeTasks: [String: Task<UIImage?, Never>] = [:]

    private init() {
        cache.countLimit = 50
        cache.totalCostLimit = 80 * 1024 * 1024
    }

    func cachedImage(for url: URL?) -> UIImage? {
        guard let url else { return nil }
        return cache.object(forKey: url.absoluteString as NSString)
    }

    func loadImage(from url: URL?, maxPixelSize: CGFloat = 400) async -> UIImage? {
        guard let url else { return nil }
        let key = url.absoluteString as NSString

        if let cached = cache.object(forKey: key) {
            return cached
        }

        if let existing = activeTasks[url.absoluteString] {
            return await existing.value
        }

        let task = Task<UIImage?, Never> {
            do {
                let (data, _) = try await URLSession.shared.data(from: url)
                if let image = downsampledImage(data: data, maxPixelSize: maxPixelSize) {
                    let cost = Int(image.size.width * image.size.height * image.scale * 4)
                    cache.setObject(image, forKey: key, cost: cost)
                    return image
                }
            } catch {}
            return nil
        }

        activeTasks[url.absoluteString] = task
        let result = await task.value
        activeTasks.removeValue(forKey: url.absoluteString)
        return result
    }

    func preloadImages(urls: [URL?]) {
        for url in urls {
            guard let url else { continue }
            let key = url.absoluteString as NSString
            if cache.object(forKey: key) != nil { continue }
            Task {
                _ = await loadImage(from: url)
            }
        }
    }

    nonisolated private func downsampledImage(data: Data, maxPixelSize: CGFloat) -> UIImage? {
        let options: [CFString: Any] = [
            kCGImageSourceCreateThumbnailFromImageAlways: true,
            kCGImageSourceCreateThumbnailWithTransform: true,
            kCGImageSourceThumbnailMaxPixelSize: maxPixelSize,
            kCGImageSourceShouldCacheImmediately: true
        ]
        guard let source = CGImageSourceCreateWithData(data as CFData, nil),
              let cgImage = CGImageSourceCreateThumbnailAtIndex(source, 0, options as CFDictionary) else {
            return UIImage(data: data)
        }
        return UIImage(cgImage: cgImage)
    }
}

struct CachedAsyncImage: View {
    let url: URL?
    let contentMode: ContentMode
    let maxPixelSize: CGFloat

    @State private var image: UIImage?
    @State private var isLoading = true

    init(url: URL?, contentMode: ContentMode = .fill, maxPixelSize: CGFloat = 400) {
        self.url = url
        self.contentMode = contentMode
        self.maxPixelSize = maxPixelSize
    }

    var body: some View {
        Group {
            if let image {
                Image(uiImage: image)
                    .resizable()
                    .aspectRatio(contentMode: contentMode)
                    .transition(.opacity.animation(.easeIn(duration: 0.2)))
            } else if isLoading {
                Color.clear
                    .overlay {
                        ProgressView()
                            .tint(.white.opacity(0.3))
                            .scaleEffect(0.6)
                    }
            } else {
                Color.clear
            }
        }
        .task(id: url) {
            if let url {
                if let cached = ImageCacheService.shared.cachedImage(for: url) {
                    image = cached
                    isLoading = false
                    return
                }
                let loaded = await ImageCacheService.shared.loadImage(from: url, maxPixelSize: maxPixelSize)
                withAnimation(.easeIn(duration: 0.2)) {
                    image = loaded
                }
                isLoading = false
            }
        }
    }
}
