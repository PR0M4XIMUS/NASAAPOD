import Foundation
import Combine

class APODViewModel: ObservableObject {
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
    
    let maxDate: Date = Date()
    
    private var networkService = NetworkService()
    private var cancellables = Set<AnyCancellable>()
    
    init() {
        loadAPOD(for: selectedDate)
    }
    
    func loadAPOD(for date: Date? = nil) {
        if let date = date {
            selectedDate = date
        }
        
        isLoading = true
        errorMessage = nil
        
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
    
    func selectDate(_ date: Date) {
        if date != selectedDate {
            loadAPOD(for: date)
        }
    }
}
