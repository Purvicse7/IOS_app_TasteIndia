import Foundation

struct MealSummary: Identifiable, Hashable, Sendable {
    let id: String
    let name: String
    let thumbnailURL: URL?
    var category: String?
}

struct IngredientItem: Identifiable, Hashable, Sendable {
    let id = UUID()
    let name: String
    let measure: String
}

struct MealDetail: Identifiable, Hashable, Sendable {
    let id: String
    let name: String
    let category: String
    let area: String
    let instructions: String
    let thumbnailURL: URL?
    let tags: [String]
    let youtubeURL: URL?
    let sourceURL: URL?
    let ingredients: [IngredientItem]
}

enum SortOption: String, CaseIterable, Identifiable, Sendable {
    case nameAscending = "Name (A–Z)"
    case nameDescending = "Name (Z–A)"
    
    var id: String { rawValue }
}

struct FilterCriteria: Equatable, Sendable {
    var searchQuery: String = ""
    var selectedCategory: String? = nil
    var selectedIngredient: String? = nil
    var favouritesOnly: Bool = false
    var sortOption: SortOption = .nameAscending
    
    var isActive: Bool {
        !searchQuery.trimmingCharacters(in: .whitespaces).isEmpty ||
        selectedCategory != nil ||
        selectedIngredient != nil ||
        favouritesOnly
    }
    
    mutating func clear() {
        searchQuery = ""
        selectedCategory = nil
        selectedIngredient = nil
        favouritesOnly = false
        sortOption = .nameAscending
    }
}
