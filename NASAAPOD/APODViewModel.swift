import Foundation
import Combine

// View model to handle business logic and data for APOD
class APODViewModel: ObservableObject {
    // Published properties for UI updates
    @Published var apod: APODResponse?
    @Published var isLoading = true
    @Published var errorMessage: String?
    @Published var selectedDate: Date = Date()
    
    // NASA APOD started on June 16, 1995
    let minDate: Date = {
        var components = DateComponents()
        components.year = 1995
        components.month = 6
        components.day = 16
        return Calendar.current.date(from: components) ?? Date()
    }()
    
    // Maximum date is today
    let maxDate: Date = Date()
    
    // Services and state
    private var networkService = NetworkService()
    private var cancellables = Set<AnyCancellable>()
    
    // Initialize and load today's APOD
    init() {
        loadAPOD(for: selectedDate)
    }
    
    // Fetch APOD data for the specified date
    func loadAPOD(for date: Date? = nil) {
        if let date = date {
            selectedDate = date
        }
        
        isLoading = true
        errorMessage = nil
        
        // Network request using Combine
        networkService.fetchAPOD(date: selectedDate)
            .sink(receiveCompletion: { [weak self] completion in
                self?.isLoading = false
                if case let .failure(error) = completion {
                    self?.errorMessage = error.localizedDescription
                }
            }, receiveValue: { [weak self] response in
                self?.apod = response
                self?.isLoading = false
            })
            .store(in: &cancellables)
    }
    
    // Helper method to select a date and load its data
    func selectDate(_ date: Date) {
        if date != selectedDate {
            loadAPOD(for: date)
        }
    }
}
