import Foundation
@testable import TasteIndia

final class MockAPIClient: APIClientProtocol, @unchecked Sendable {
    var fixtureDataMap: [String: Data] = [:]
    var simulatedError: Error?
    
    init() {}
    
    func register(endpointKeyword: String, data: Data) {
        fixtureDataMap[endpointKeyword] = data
    }
    
    func execute<T: Decodable>(url: URL) async throws -> T {
        if let error = simulatedError {
            throw error
        }
        
        let urlString = url.absoluteString
        for (keyword, data) in fixtureDataMap {
            if urlString.contains(keyword) {
                do {
                    return try JSONDecoder().decode(T.self, from: data)
                } catch {
                    throw NetworkError.decodingError(error.localizedDescription)
                }
            }
        }
        
        throw NetworkError.noData
    }
}

final class MockFavouritesStore: FavouritesStoreProtocol, @unchecked Sendable {
    private var storedIds: Set<String>
    
    init(initialIds: Set<String> = []) {
        self.storedIds = initialIds
    }
    
    func getFavourites() -> Set<String> {
        storedIds
    }
    
    func isFavourite(id: String) -> Bool {
        storedIds.contains(id)
    }
    
    func toggleFavourite(id: String) -> Bool {
        if storedIds.contains(id) {
            storedIds.remove(id)
            return false
        } else {
            storedIds.insert(id)
            return true
        }
    }
    
    func addFavourite(id: String) {
        storedIds.insert(id)
    }
    
    func removeFavourite(id: String) {
        storedIds.remove(id)
    }
}
