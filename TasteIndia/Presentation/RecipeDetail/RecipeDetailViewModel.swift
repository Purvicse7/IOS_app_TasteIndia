import Foundation

enum RecipeDetailUIState {
    case loading
    case success(detail: MealDetail, isFavourite: Bool)
    case error(message: String)
}

@MainActor
final class RecipeDetailViewModel: ObservableObject {
    @Published private(set) var state: RecipeDetailUIState = .loading
    
    private let mealId: String
    private let repository: RecipeRepositoryProtocol
    private let favouritesStore: FavouritesStoreProtocol
    
    init(
        mealId: String,
        repository: RecipeRepositoryProtocol = DependencyContainer.shared.recipeRepository,
        favouritesStore: FavouritesStoreProtocol = DependencyContainer.shared.favouritesStore
    ) {
        self.mealId = mealId
        self.repository = repository
        self.favouritesStore = favouritesStore
    }
    
    func loadDetail() async {
        state = .loading
        do {
            let detail = try await repository.fetchMealDetail(id: mealId)
            let isFav = favouritesStore.isFavourite(id: mealId)
            state = .success(detail: detail, isFavourite: isFav)
        } catch {
            state = .error(message: error.localizedDescription)
        }
    }
    
    func toggleFavourite() {
        guard case .success(let detail, _) = state else { return }
        let nowFav = favouritesStore.toggleFavourite(id: detail.id)
        state = .success(detail: detail, isFavourite: nowFav)
    }
}
