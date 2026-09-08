import Foundation

final class DependencyContainer: @unchecked Sendable {
    static let shared = DependencyContainer()
    
    let apiClient: APIClientProtocol
    let favouritesStore: FavouritesStoreProtocol
    let recipeRepository: RecipeRepositoryProtocol
    
    init(
        apiClient: APIClientProtocol = URLSessionAPIClient(),
        favouritesStore: FavouritesStoreProtocol = UserDefaultsFavouritesStore()
    ) {
        self.apiClient = apiClient
        self.favouritesStore = favouritesStore
        self.recipeRepository = RecipeRepository(apiClient: apiClient, favouritesStore: favouritesStore)
    }
}
