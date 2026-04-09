import Foundation
import Combine

// View model to handle business logic and data for APOD
class APODViewModel: ObservableObject {
    // MARK: - Published Properties
    @Published var apod: APODResponse?
    @Published var isLoading = true
    @Published var error: APODError?
    @Published var selectedDate: Date = Date()
    @Published var isFavorite = false
    @Published var isLoadingUpdate = false
    @Published var cachedAPOD: APODResponse?

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

    // MARK: - Private Properties
    private var networkService = NetworkService()
    private var cancellables = Set<AnyCancellable>()
    private var retryCount = 0

    // Convenience property for error message
    var errorMessage: String? {
        error?.errorDescription
    }

    // Initialize and load today's APOD
    init() {
        // Load cached APOD if available
        loadCachedAPOD()
        loadAPOD(for: selectedDate)
    }

    // MARK: - Public Methods

    /// Fetch APOD data for the specified date with retry logic
    func loadAPOD(for date: Date? = nil) {
        if let date = date {
            selectedDate = date
        }

        isLoading = true
        isLoadingUpdate = true
        error = nil
        retryCount = 0

        fetchAPODWithRetry()
    }

    /// Retry loading the current APOD
    func retryLoading() {
        loadAPOD()
    }

    /// Toggle favorite status
    func toggleFavorite() {
        guard let apod = apod else { return }

        if PersistenceService.shared.isFavorite(date: apod.date) {
            PersistenceService.shared.removeFavorite(date: apod.date)
            isFavorite = false
        } else {
            PersistenceService.shared.addFavorite(apod)
            isFavorite = true
        }
    }

    // MARK: - Private Methods

    private func fetchAPODWithRetry() {
        networkService.fetchAPOD(date: selectedDate)
            .sink(receiveCompletion: { [weak self] completion in
                guard let self = self else { return }

                if case let .failure(error) = completion {
                    self.handleFetchError(error)
                }
            }, receiveValue: { [weak self] response in
                guard let self = self else { return }

                self.apod = response
                self.isLoading = false
                self.isLoadingUpdate = false
                self.error = nil
                self.isFavorite = PersistenceService.shared.isFavorite(date: response.date)

                // Save to persistence
                PersistenceService.shared.saveAPOD(response)
            })
            .store(in: &cancellables)
    }

    private func handleFetchError(_ error: APODError) {
        self.error = error

        // Try loading from cache if available
        if let cached = cachedAPOD {
            self.apod = cached
            self.isLoading = false
            self.isLoadingUpdate = false
            return
        }

        // Implement exponential backoff retry
        if retryCount < AppTheme.maxRetryAttempts {
            let delay = min(
                AppTheme.maxRetryDelay,
                AppTheme.initialRetryDelay * pow(2.0, Double(retryCount))
            )

            retryCount += 1

            DispatchQueue.main.asyncAfter(deadline: .now() + delay) { [weak self] in
                self?.fetchAPODWithRetry()
            }
        } else {
            self.isLoading = false
            self.isLoadingUpdate = false
        }
    }

    private func loadCachedAPOD() {
        cachedAPOD = PersistenceService.shared.getCachedAPOD()
        if let cached = cachedAPOD {
            apod = cached
            isFavorite = PersistenceService.shared.isFavorite(date: cached.date)
        }
    }
}
