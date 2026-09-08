import XCTest
@testable import TasteIndia

final class RecipeListViewModelTests: XCTestCase {
    
    func testSearchAndSortOrdering() async throws {
        let mockClient = MockAPIClient()
        guard let indianURL = Bundle.module.url(forResource: "indian_meals_fixture", withExtension: "json") else {
            XCTFail("indian_meals_fixture.json not found")
            return
        }
        let indianData = try Data(contentsOf: indianURL)
        mockClient.register(endpointKeyword: "a=Indian", data: indianData)
        
        let mockFavStore = MockFavouritesStore()
        let repository = RecipeRepository(apiClient: mockClient, favouritesStore: mockFavStore)
        
        // Test A-Z sort
        var criteriaAsc = FilterCriteria()
        criteriaAsc.sortOption = .nameAscending
        let ascResults = try await repository.filterMeals(criteria: criteriaAsc)
        
        XCTAssertGreaterThan(ascResults.count, 1)
        for i in 0..<(ascResults.count - 1) {
            XCTAssertLessThanOrEqual(
                ascResults[i].name.localizedCaseInsensitiveCompare(ascResults[i + 1].name),
                .orderedSame
            )
        }
        
        // Test search query
        var criteriaSearch = FilterCriteria()
        criteriaSearch.searchQuery = "paneer"
        let searchResults = try await repository.filterMeals(criteria: criteriaSearch)
        
        XCTAssertEqual(searchResults.count, 1)
        XCTAssertEqual(searchResults.first?.name, "Matar Paneer")
    }
}
