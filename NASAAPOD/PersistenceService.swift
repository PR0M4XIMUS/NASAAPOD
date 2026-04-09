import Foundation

// Service for local data persistence (offline mode, caching)
class PersistenceService {
    static let shared = PersistenceService()

    private let userDefaults = UserDefaults.standard
    private let apodKey = "cached_apod"
    private let favoritesKey = "favorite_apods"
    private let settingsKey = "app_settings"

    // MARK: - APOD Caching

    /// Save APOD to local storage
    func saveAPOD(_ apod: APODResponse) {
        if let encoded = try? JSONEncoder().encode(apod) {
            userDefaults.set(encoded, forKey: apodKey)
        }
    }

    /// Retrieve cached APOD
    func getCachedAPOD() -> APODResponse? {
        guard let data = userDefaults.data(forKey: apodKey) else { return nil }
        return try? JSONDecoder().decode(APODResponse.self, from: data)
    }

    /// Clear cached APOD
    func clearCachedAPOD() {
        userDefaults.removeObject(forKey: apodKey)
    }

    // MARK: - Favorites Management

    /// Get all favorite APODs
    func getFavorites() -> [APODResponse] {
        guard let data = userDefaults.data(forKey: favoritesKey) else { return [] }
        return (try? JSONDecoder().decode([APODResponse].self, from: data)) ?? []
    }

    /// Add APOD to favorites
    func addFavorite(_ apod: APODResponse) {
        var favorites = getFavorites()

        // Don't add duplicates
        if !favorites.contains(where: { $0.date == apod.date }) {
            favorites.append(apod)
            saveFavorites(favorites)
        }
    }

    /// Remove APOD from favorites
    func removeFavorite(date: String) {
        var favorites = getFavorites()
        favorites.removeAll { $0.date == date }
        saveFavorites(favorites)
    }

    /// Check if APOD is favorite
    func isFavorite(date: String) -> Bool {
        return getFavorites().contains { $0.date == date }
    }

    private func saveFavorites(_ favorites: [APODResponse]) {
        if let encoded = try? JSONEncoder().encode(favorites) {
            userDefaults.set(encoded, forKey: favoritesKey)
        }
    }

    // MARK: - Settings Management

    /// Get app settings
    func getSettings() -> AppSettings {
        guard let data = userDefaults.data(forKey: settingsKey) else {
            return AppSettings()
        }
        return (try? JSONDecoder().decode(AppSettings.self, from: data)) ?? AppSettings()
    }

    /// Save app settings
    func saveSettings(_ settings: AppSettings) {
        if let encoded = try? JSONEncoder().encode(settings) {
            userDefaults.set(encoded, forKey: settingsKey)
        }
    }

    /// Clear all user data
    func clearAllData() {
        userDefaults.removeObject(forKey: apodKey)
        userDefaults.removeObject(forKey: favoritesKey)
    }
}

// App-wide settings
struct AppSettings: Codable {
    var glassEffectIntensity: Double = 1.0
    var enableMotionEffects: Bool = true
    var preferHighResolution: Bool = true
    var allowOfflineContent: Bool = true
    var showNotifications: Bool = true

    enum CodingKeys: String, CodingKey {
        case glassEffectIntensity
        case enableMotionEffects
        case preferHighResolution
        case allowOfflineContent
        case showNotifications
    }
}
