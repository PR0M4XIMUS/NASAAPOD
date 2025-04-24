import Foundation
import Combine

// Service to handle network requests
class NetworkService {
    // NASA API configuration
    private let apiKey = APIConfig.nasaAPIKey
    private let baseURL = "https://api.nasa.gov/planetary/apod"
    
    // Fetch APOD data for a specific date
    func fetchAPOD(date: Date? = nil) -> AnyPublisher<APODResponse, Error> {
        var urlComponents = URLComponents(string: baseURL)!
        
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
            return Fail(error: URLError(.badURL)).eraseToAnyPublisher()
        }
        
        // Make network request using Combine
        return URLSession.shared.dataTaskPublisher(for: url)
            .map(\.data)
            .decode(type: APODResponse.self, decoder: JSONDecoder())
            .receive(on: DispatchQueue.main)
            .eraseToAnyPublisher()
    }
}
