import Foundation
import SwiftUI

enum RecipeListUIState: Equatable {
    case idle
    case loading
    case success([MealSummary])
    case empty(message: String)
    case error(message: String)
}

@MainActor
final class RecipeListViewModel: ObservableObject {
    @Published private(set) var state: RecipeListUIState = .idle
    @Published var criteria = FilterCriteria()
    @Published private(set) var favouriteIds: Set<String> = []
    @Published private(set) var availableCategories: [String] = []
    @Published private(set) var availableIngredients: [String] = []
    @Published var isFilterSheetPresented: Bool = false
    
    private let repository: RecipeRepositoryProtocol
    private let favouritesStore: FavouritesStoreProtocol
    private var searchDebounceTask: Task<Void, Never>? = nil
    
    init(repository: RecipeRepositoryProtocol, favouritesStore: FavouritesStoreProtocol) {
        self.repository = repository
        self.favouritesStore = favouritesStore
        self.favouriteIds = favouritesStore.getFavourites()
    }
    
    func onAppear() {
        if case .idle = state {
            loadInitialData()
        } else {
            // Refresh favourites in case modified on detail screen
            refreshFavourites()
        }
    }
    
    func loadInitialData() {
        state = .loading
        Task {
            // Preload filter lists in background
            async let categoriesTask = try? repository.fetchCategories()
            async let ingredientsTask = try? repository.fetchIngredients()
            
            if let cats = await categoriesTask {
                self.availableCategories = cats
            }
            if let ings = await ingredientsTask {
                self.availableIngredients = ings
            }
            
            await applyFilters()
        }
    }
    
    func onSearchQueryChanged(_ newQuery: String) {
        criteria.searchQuery = newQuery
        searchDebounceTask?.cancel()
        searchDebounceTask = Task {
            // 300ms debounce
            try? await Task.sleep(nanoseconds: 300_000_000)
            guard !Task.isCancelled else { return }
            await applyFilters()
        }
    }
    
    func applyFilters() async {
        state = .loading
        do {
            let results = try await repository.filterMeals(criteria: criteria)
            if results.isEmpty {
                state = .empty(message: "No Indian recipes found matching your current filter and search criteria.")
            } else {
                state = .success(results)
            }
        } catch {
            state = .error(message: error.localizedDescription)
        }
    }
    
    func clearAllFilters() {
        criteria.clear()
        Task {
            await applyFilters()
        }
    }
    
    func toggleFavourite(for mealId: String) {
        _ = favouritesStore.toggleFavourite(id: mealId)
        refreshFavourites()
        
        // If in favourites-only mode, re-apply filter to update list
        if criteria.favouritesOnly {
            Task {
                await applyFilters()
            }
        }
    }
    
    func refreshFavourites() {
        self.favouriteIds = favouritesStore.getFavourites()
    }
}
