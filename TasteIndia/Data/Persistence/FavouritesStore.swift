import Foundation

protocol FavouritesStoreProtocol: AnyObject, Sendable {
    func getFavourites() -> Set<String>
    func isFavourite(id: String) -> Bool
    func toggleFavourite(id: String) -> Bool
    func addFavourite(id: String)
    func removeFavourite(id: String)
}

final class UserDefaultsFavouritesStore: FavouritesStoreProtocol, @unchecked Sendable {
    private let userDefaults: UserDefaults
    private let key = "taste_india_favourite_meal_ids"
    private let queue = DispatchQueue(label: "com.tasteindia.favourites.queue", attributes: .concurrent)
    
    init(userDefaults: UserDefaults = .standard) {
        self.userDefaults = userDefaults
    }
    
    func getFavourites() -> Set<String> {
        queue.sync {
            let array = userDefaults.stringArray(forKey: key) ?? []
            return Set(array)
        }
    }
    
    func isFavourite(id: String) -> Bool {
        queue.sync {
            let set = Set(userDefaults.stringArray(forKey: key) ?? [])
            return set.contains(id)
        }
    }
    
    func toggleFavourite(id: String) -> Bool {
        queue.sync(flags: .barrier) {
            var set = Set(userDefaults.stringArray(forKey: key) ?? [])
            let nowFav: Bool
            if set.contains(id) {
                set.remove(id)
                nowFav = false
            } else {
                set.insert(id)
                nowFav = true
            }
            userDefaults.set(Array(set), forKey: key)
            return nowFav
        }
    }
    
    func addFavourite(id: String) {
        queue.sync(flags: .barrier) {
            var set = Set(userDefaults.stringArray(forKey: key) ?? [])
            set.insert(id)
            userDefaults.set(Array(set), forKey: key)
        }
    }
    
    func removeFavourite(id: String) {
        queue.sync(flags: .barrier) {
            var set = Set(userDefaults.stringArray(forKey: key) ?? [])
            set.remove(id)
            userDefaults.set(Array(set), forKey: key)
        }
    }
}
