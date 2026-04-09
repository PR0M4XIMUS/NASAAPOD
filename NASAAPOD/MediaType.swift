import Foundation

// Type-safe media type enum instead of string comparisons
enum MediaType: String, Codable {
    case image = "image"
    case video = "video"

    var isImage: Bool {
        return self == .image
    }

    var isVideo: Bool {
        return self == .video
    }
}
