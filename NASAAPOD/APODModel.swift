import Foundation

// Data model for Astronomy Picture of the Day response
struct APODResponse: Codable, Equatable {
    let date: String
    let explanation: String
    let hdurl: String?
    let mediaType: MediaType
    let serviceVersion: String
    let title: String
    let url: String

    // Get the best available image URL (prefer HD)
    var imageURL: String? {
        guard mediaType == .image else { return nil }
        return hdurl ?? url
    }

    // Validate URL is properly formatted
    var validatedURL: URL? {
        URL(string: url)
    }

    var validatedImageURL: URL? {
        guard let imageURL = imageURL else { return nil }
        return URL(string: imageURL)
    }

    // Map JSON keys to Swift properties
    enum CodingKeys: String, CodingKey {
        case date
        case explanation
        case hdurl
        case mediaType = "media_type"
        case serviceVersion = "service_version"
        case title
        case url
    }

    // Implement Equatable for view updates
    static func == (lhs: APODResponse, rhs: APODResponse) -> Bool {
        return lhs.date == rhs.date &&
               lhs.title == rhs.title &&
               lhs.url == rhs.url &&
               lhs.mediaType == rhs.mediaType
    }
}
