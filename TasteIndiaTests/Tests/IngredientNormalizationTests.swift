import XCTest
@testable import TasteIndia

final class IngredientNormalizationTests: XCTestCase {
    
    func testIngredientNormalizationOmitsBlankAndWhitespaceEntries() throws {
        guard let fixtureURL = Bundle.testFixtureURL(named: "meal_lookup_52772_fixture") else {
            XCTFail("Fixture meal_lookup_52772_fixture.json not found")
            return
        }
        
        let data = try Data(contentsOf: fixtureURL)
        let response = try JSONDecoder().decode(MealDetailResponseDTO.self, from: data)
        guard let dto = response.meals?.first else {
            XCTFail("Failed to decode MealDetailDTO from fixture")
            return
        }
        
        let mealDetail = MealDetailMapper.mapDetail(dto)
        
        XCTAssertEqual(mealDetail.ingredients.count, 6)
        XCTAssertEqual(mealDetail.ingredients[0].name, "Chicken")
        XCTAssertEqual(mealDetail.ingredients[0].measure, "1.2 kg")
        XCTAssertEqual(mealDetail.ingredients[5].name, "Coriander Leaves")
        XCTAssertEqual(mealDetail.ingredients[5].measure, "A handful")
        
        let ingredientNames = mealDetail.ingredients.map { $0.name }
        XCTAssertFalse(ingredientNames.contains(""))
        XCTAssertFalse(ingredientNames.contains("   "))
        
        XCTAssertEqual(mealDetail.tags, ["Curry", "Spicy", "Dinner"])
    }
}
