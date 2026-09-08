import Foundation

protocol RecipeRepositoryProtocol: Sendable {
    func fetchIndianMeals(forceRefresh: Bool) async throws -> [MealSummary]
    func fetchMealDetail(id: String) async throws -> MealDetail
    func fetchCategories() async throws -> [String]
    func fetchIngredients() async throws -> [String]
    func filterMeals(criteria: FilterCriteria) async throws -> [MealSummary]
}

actor RecipeRepository: RecipeRepositoryProtocol {
    private let apiClient: APIClientProtocol
    private let favouritesStore: FavouritesStoreProtocol
    
    // In-memory caches to prevent uncontrolled N+1 lookups
    private var cachedIndianMeals: [MealSummary]? = nil
    private var detailCache: [String: MealDetail] = [:]
    private var inFlightDetailTasks: [String: Task<MealDetail, Error>] = [:]
    private var cachedCategories: [String]? = nil
    private var cachedIngredients: [String]? = nil
    
    init(apiClient: APIClientProtocol, favouritesStore: FavouritesStoreProtocol) {
        self.apiClient = apiClient
        self.favouritesStore = favouritesStore
    }
    
    func fetchIndianMeals(forceRefresh: Bool = false) async throws -> [MealSummary] {
        if !forceRefresh, let cached = cachedIndianMeals {
            return cached
        }
        
        guard let url = Endpoint.indianMeals.url else {
            throw NetworkError.invalidURL
        }
        
        let response: MealsResponseDTO = try await apiClient.execute(url: url)
        guard let dtos = response.meals else {
            throw NetworkError.noData
        }
        
        let summaries = dtos.map { MealDetailMapper.mapSummary($0) }
        self.cachedIndianMeals = summaries
        return summaries
    }
    
    func fetchMealDetail(id: String) async throws -> MealDetail {
        if let cached = detailCache[id] {
            return cached
        }
        
        if let inFlight = inFlightDetailTasks[id] {
            return try await inFlight.value
        }
        
        let task = Task<MealDetail, Error> {
            guard let url = Endpoint.mealDetail(id: id).url else {
                throw NetworkError.invalidURL
            }
            
            let response: MealDetailResponseDTO = try await apiClient.execute(url: url)
            guard let dto = response.meals?.first else {
                throw NetworkError.noData
            }
            
            return MealDetailMapper.mapDetail(dto)
        }
        
        inFlightDetailTasks[id] = task
        
        do {
            let detail = try await task.value
            detailCache[id] = detail
            inFlightDetailTasks[id] = nil
            return detail
        } catch {
            inFlightDetailTasks[id] = nil
            throw error
        }
    }
    
    func fetchCategories() async throws -> [String] {
        if let cached = cachedCategories {
            return cached
        }
        guard let url = Endpoint.categoriesList.url else {
            throw NetworkError.invalidURL
        }
        let response: CategoryListResponseDTO = try await apiClient.execute(url: url)
        let list = response.meals?.map { $0.strCategory } ?? []
        cachedCategories = list
        return list
    }
    
    func fetchIngredients() async throws -> [String] {
        if let cached = cachedIngredients {
            return cached
        }
        guard let url = Endpoint.ingredientsList.url else {
            throw NetworkError.invalidURL
        }
        let response: IngredientListResponseDTO = try await apiClient.execute(url: url)
        let list = response.meals?.map { $0.strIngredient } ?? []
        cachedIngredients = list
        return list
    }
    
    func filterMeals(criteria: FilterCriteria) async throws -> [MealSummary] {
        // Step 1: Ensure Indian base collection is authoritative
        let baseIndianMeals = try await fetchIndianMeals()
        let indianIdSet = Set(baseIndianMeals.map { $0.id })
        var candidateIds = indianIdSet
        
        // Step 2: Category filter with local Set Intersection
        if let category = criteria.selectedCategory, !category.isEmpty {
            guard let url = Endpoint.filterByCategory(category: category).url else {
                throw NetworkError.invalidURL
            }
            let response: MealsResponseDTO = try await apiClient.execute(url: url)
            let categoryIds = Set(response.meals?.map { $0.idMeal } ?? [])
            // Intersect with Indian boundary
            candidateIds = candidateIds.intersection(categoryIds)
        }
        
        // Step 3: Ingredient filter with local Set Intersection
        if let ingredient = criteria.selectedIngredient, !ingredient.isEmpty {
            guard let url = Endpoint.filterByIngredient(ingredient: ingredient).url else {
                throw NetworkError.invalidURL
            }
            let response: MealsResponseDTO = try await apiClient.execute(url: url)
            let ingredientIds = Set(response.meals?.map { $0.idMeal } ?? [])
            // Intersect with current candidates
            candidateIds = candidateIds.intersection(ingredientIds)
        }
        
        // Step 4: Favourites-only filter
        if criteria.favouritesOnly {
            let favIds = favouritesStore.getFavourites()
            candidateIds = candidateIds.intersection(favIds)
        }
        
        // Step 5: Filter master Indian meal objects by the intersected IDs
        var filteredMeals = baseIndianMeals.filter { candidateIds.contains($0.id) }
        
        // Step 6: Apply local name search query (case-insensitive)
        let trimmedQuery = criteria.searchQuery.trimmingCharacters(in: .whitespacesAndNewlines)
        if !trimmedQuery.isEmpty {
            filteredMeals = filteredMeals.filter {
                $0.name.localizedCaseInsensitiveContains(trimmedQuery)
            }
        }
        
        // Step 7: Apply sorting
        switch criteria.sortOption {
        case .nameAscending:
            filteredMeals.sort { $0.name.localizedCaseInsensitiveCompare($1.name) == .orderedAscending }
        case .nameDescending:
            filteredMeals.sort { $0.name.localizedCaseInsensitiveCompare($1.name) == .orderedDescending }
        }
        
        return filteredMeals
    }
}
