import Foundation
import Combine

// Service to handle network requests
class NetworkService {
    // NASA API configuration
    private let apiKey = APIConfig.nasaAPIKey
    private let baseURL = "https://api.nasa.gov/planetary/apod"

    // Configure URLSession with timeouts
    private lazy var urlSession: URLSession = {
        let config = URLSessionConfiguration.default
        config.timeoutIntervalForRequest = 15  // 15 seconds per request
        config.timeoutIntervalForResource = 30  // 30 seconds total resource timeout
        config.waitsForConnectivity = true

        // Configure cache
        config.urlCache = URLCache(
            memoryCapacity: 500_000_000,  // 500 MB
            diskCapacity: 1_000_000_000,   // 1 GB
            diskPath: "nasaapod_cache"
        )
        config.requestCachePolicy = .returnCacheDataElseLoad

        return URLSession(configuration: config)
    }()

    // Fetch APOD data for a specific date
    func fetchAPOD(date: Date? = nil) -> AnyPublisher<APODResponse, APODError> {
        // Build URL safely without force unwrap
        guard var urlComponents = URLComponents(string: baseURL) else {
            return Fail(error: APODError.invalidURL).eraseToAnyPublisher()
        }

        // Build query parameters
        var queryItems = [URLQueryItem(name: "api_key", value: apiKey)]

        // Add date parameter if provided
        if let date = date {
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd"
            let dateString = dateFormatter.string(from: date)
            queryItems.append(URLQueryItem(name: "date", value: dateString))
        }

        urlComponents.queryItems = queryItems

        guard let url = urlComponents.url else {
            return Fail(error: APODError.invalidURL).eraseToAnyPublisher()
        }

        // Make network request using Combine with error handling
        return urlSession.dataTaskPublisher(for: url)
            .mapError { error -> APODError in
                // Distinguish between different error types
                if error.code == .timedOut || error.code == .networkConnectionLost {
                    return .networkTimeout
                } else if error.code == .notConnectedToInternet {
                    return .noInternetConnection
                } else {
                    return .unknown(error)
                }
            }
            .map(\.data)
            .decode(type: APODResponse.self, decoder: JSONDecoder())
            .mapError { error -> APODError in
                if let decodingError = error as? DecodingError {
                    return .decodingError("Failed to parse APOD data")
                }
                return .unknown(error)
            }
            .receive(on: DispatchQueue.main)
            .eraseToAnyPublisher()
    }
}
