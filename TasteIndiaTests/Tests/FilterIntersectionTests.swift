import XCTest
@testable import TasteIndia

final class FilterIntersectionTests: XCTestCase {
    
    func testIndianBoundaryPreservedWhenFilteringByCategory() async throws {
        let mockClient = MockAPIClient()
        
        guard let indianURL = Bundle.testFixtureURL(named: "indian_meals_fixture"),
              let categoryURL = Bundle.testFixtureURL(named: "category_chicken_fixture") else {
            XCTFail("Required test fixtures not found")
            return
        }
        
        let indianData = try Data(contentsOf: indianURL)
        let categoryData = try Data(contentsOf: categoryURL)
        
        mockClient.register(endpointKeyword: "a=Indian", data: indianData)
        mockClient.register(endpointKeyword: "c=Chicken", data: categoryData)
        
        let mockFavStore = MockFavouritesStore()
        let repository = RecipeRepository(apiClient: mockClient, favouritesStore: mockFavStore)
        
        var criteria = FilterCriteria()
        criteria.selectedCategory = "Chicken"
        
        let results = try await repository.filterMeals(criteria: criteria)
        let resultIds = Set(results.map { $0.id })
        
        XCTAssertEqual(resultIds.count, 2)
        XCTAssertTrue(resultIds.contains("52795"), "Must include Indian Chicken Handi")
        XCTAssertTrue(resultIds.contains("52894"), "Must include Indian Chicken Tikka Masala")
        XCTAssertFalse(resultIds.contains("52920"), "Must NOT include non-Indian Chicken Marengo")
        XCTAssertFalse(resultIds.contains("52813"), "Must NOT include non-Indian KFC")
    }
}
