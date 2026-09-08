import XCTest
@testable import TasteIndia

final class FilterIntersectionTests: XCTestCase {
    
    func testIndianBoundaryPreservedWhenFilteringByCategory() async throws {
        // Prepare mock client with fixtures
        let mockClient = MockAPIClient()
        
        guard let indianURL = Bundle.module.url(forResource: "indian_meals_fixture", withExtension: "json"),
              let categoryURL = Bundle.module.url(forResource: "category_chicken_fixture", withExtension: "json") else {
            XCTFail("Required test fixtures not found")
            return
        }
        
        let indianData = try Data(contentsOf: indianURL)
        let categoryData = try Data(contentsOf: categoryURL)
        
        mockClient.register(endpointKeyword: "a=Indian", data: indianData)
        mockClient.register(endpointKeyword: "c=Chicken", data: categoryData)
        
        let mockFavStore = MockFavouritesStore()
        let repository = RecipeRepository(apiClient: mockClient, favouritesStore: mockFavStore)
        
        // Filter by Chicken
        var criteria = FilterCriteria()
        criteria.selectedCategory = "Chicken"
        
        let results = try await repository.filterMeals(criteria: criteria)
        
        // Indian meals: 52795 (Chicken Handi), 52785 (Dal fry), 52865, 52862, 52894 (Chicken Tikka Masala)
        // Chicken category: 52795 (Chicken Handi), 52920 (Chicken Marengo), 52813 (KFC), 52894 (Chicken Tikka Masala)
        // Intersected set MUST contain 52795 and 52894, and MUST NOT contain 52920 or 52813.
        let resultIds = Set(results.map { $0.id })
        
        XCTAssertEqual(resultIds.count, 2)
        XCTAssertTrue(resultIds.contains("52795"), "Must include Indian Chicken Handi")
        XCTAssertTrue(resultIds.contains("52894"), "Must include Indian Chicken Tikka Masala")
        XCTAssertFalse(resultIds.contains("52920"), "Must NOT include non-Indian Chicken Marengo")
        XCTAssertFalse(resultIds.contains("52813"), "Must NOT include non-Indian KFC")
    }
}
