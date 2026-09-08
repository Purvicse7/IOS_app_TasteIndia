import XCTest
@testable import TasteIndia

final class IngredientNormalizationTests: XCTestCase {
    
    func testIngredientNormalizationOmitsBlankAndWhitespaceEntries() throws {
        // Load fixture
        guard let fixtureURL = Bundle.module.url(forResource: "meal_lookup_52772_fixture", withExtension: "json") else {
            XCTFail("Fixture meal_lookup_52772_fixture.json not found in test bundle")
            return
        }
        
        let data = try Data(contentsOf: fixtureURL)
        let response = try JSONDecoder().decode(MealDetailResponseDTO.self, from: data)
        guard let dto = response.meals?.first else {
            XCTFail("Failed to decode MealDetailDTO from fixture")
            return
        }
        
        // Map to domain
        let mealDetail = MealDetailMapper.mapDetail(dto)
        
        // Assert exactly 6 valid non-empty ingredients exist
        XCTAssertEqual(mealDetail.ingredients.count, 6)
        
        // Verify individual pairs
        XCTAssertEqual(mealDetail.ingredients[0].name, "Chicken")
        XCTAssertEqual(mealDetail.ingredients[0].measure, "1.2 kg")
        
        XCTAssertEqual(mealDetail.ingredients[5].name, "Coriander Leaves")
        XCTAssertEqual(mealDetail.ingredients[5].measure, "A handful")
        
        // Verify empty string ("") and whitespace ("   ") at indices 7 & 8 were omitted
        let ingredientNames = mealDetail.ingredients.map { $0.name }
        XCTAssertFalse(ingredientNames.contains(""))
        XCTAssertFalse(ingredientNames.contains("   "))
        
        // Verify tags parsed
        XCTAssertEqual(mealDetail.tags, ["Curry", "Spicy", "Dinner"])
    }
}
