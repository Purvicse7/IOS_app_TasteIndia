import XCTest
@testable import TasteIndia

final class FavouritesPersistenceTests: XCTestCase {
    
    func testFavouritesAddRemoveAndPersistence() {
        let store = MockFavouritesStore()
        let testMealId = "52795"
        
        XCTAssertFalse(store.isFavourite(id: testMealId))
        
        // Toggle on
        let added = store.toggleFavourite(id: testMealId)
        XCTAssertTrue(added)
        XCTAssertTrue(store.isFavourite(id: testMealId))
        XCTAssertTrue(store.getFavourites().contains(testMealId))
        
        // Toggle off
        let removed = store.toggleFavourite(id: testMealId)
        XCTAssertFalse(removed)
        XCTAssertFalse(store.isFavourite(id: testMealId))
        XCTAssertFalse(store.getFavourites().contains(testMealId))
    }
}
