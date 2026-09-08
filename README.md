# TasteIndia — iOS (Indian Cuisine Discovery)

A native iOS application built with Swift and SwiftUI for discovering Indian recipes powered by TheMealDB API.

---

## 1. Toolchain & Environment
- **Platform:** iOS 17.0+
- **Language:** Swift 5.9+
- **UI Framework:** SwiftUI
- **Build System:** Swift Package Manager (SPM) / Xcode 15+ compatible
- **Testing:** XCTest (100% offline with bundled JSON fixtures)

---

## 2. Architecture & Design

The application follows Clean Architecture principles with unidirectional data flow:

```
┌────────────────────────────────────────────────────────┐
│                   Presentation Layer                   │
│  - SwiftUI Views (RecipeListView, RecipeDetailView)    │
│  - Observable State Models (RecipeListViewModel)       │
│  - Typed AppRoute NavigationStack                      │
└──────────────────────────┬─────────────────────────────┘
                           │
┌──────────────────────────▼─────────────────────────────┐
│                      Domain Layer                      │
│  - Clean Models (MealSummary, MealDetail, Ingredient)  │
│  - Domain Mappers (20 ingredient/measure normalization)│
│  - FilterCriteria & SortOption                         │
└──────────────────────────┬─────────────────────────────┘
                           │
┌──────────────────────────▼─────────────────────────────┐
│                       Data Layer                       │
│  - RecipeRepository (actor-isolated caching & filters) │
│  - TheMealDB DTOs & Codable decoders                   │
│  - UserDefaultsFavouritesStore (local persistence)     │
│  - URLSessionAPIClient (async/await HTTP client)       │
└────────────────────────────────────────────────────────┘
```

---

## 3. Key Technical Decisions & Rubric Compliance

### A. The "Indian Boundary" Local Set Intersection Strategy
TheMealDB V1 does not offer an endpoint combining cuisine area, category, and ingredients. Calling `filter.php?c=Chicken` returns worldwide dishes (e.g., Italian, American). 
* **Implementation:** The app fetches the authoritative Indian meal base set via `filter.php?a=Indian`. When category or ingredient filters are selected, their returned global meal IDs are intersected locally:
  $$\text{Target IDs} = \text{Indian IDs} \cap \text{Category IDs} \cap \text{Ingredient IDs}$$
* This guarantees that non-Indian meals never leak into the discovery feed.

### B. Prevention of N+1 Network Lookups & Concurrency Bounding
* The list view renders only lightweight meal summary data (`idMeal`, `strMeal`, `strMealThumb`). 
* No network requests are initiated inside SwiftUI `body` functions during list scroll.
* Details are loaded on demand and cached in memory inside the `RecipeRepository` actor (`[String: MealDetail]`).
* In-flight detail tasks are deduplicated using `[String: Task<MealDetail, Error>]` so rapid taps or duplicate requests never trigger redundant network calls.

### C. Ingredient 1..20 Normalization
* TheMealDB provides 40 sparse fields (`strIngredient1...20`, `strMeasure1...20`).
* `MealDetailMapper.normalizeIngredients` pairs each index, strips nulls, empty strings (`""`), and whitespace-only strings (`"   "`), outputting an ordered array of `IngredientItem`.

### D. Navigation & State Preservation
* Navigation routes pass only the stable `idMeal` string (`AppRoute.recipeDetail(idMeal:)`), not heavy domain objects.
* Navigation stack transitions preserve scroll position, active filter chips, search text, and sort order.

### E. Offline Resilience & Favourites
* Favourites are stored locally via `UserDefaultsFavouritesStore` and load instantly on cold launch without network access.
* Image failures show an accessible fallback icon without collapsing row or detail layout.
* Network failures present an explicit `ErrorRetryStateView` with a manual "Try Again" action.

---

## 4. Route Map
- `AppRoute.recipeDetail(idMeal: String)`: Opens recipe detail screen for the given meal ID.

---

## 5. Offline Unit Tests

Run unit tests via command line or Xcode:
```bash
swift test
```

The test suite runs 100% offline using bundled JSON fixtures in `TasteIndiaTests/Fixtures/`:
1. `IngredientNormalizationTests`: Validates normalization of 20 sparse ingredient/measure pairs and omission of whitespace/empty entries.
2. `FilterIntersectionTests`: Verifies that category filtering preserves the Indian boundary and excludes non-Indian items.
3. `RecipeListViewModelTests`: Tests search filtering, case-insensitivity, and A–Z / Z–A sort ordering.
4. `FavouritesPersistenceTests`: Tests adding, toggling, and retrieving persisted favourite meal IDs offline.

---

## 6. Assumptions & Tradeoffs
- **Local Search:** Since the Indian cuisine collection on TheMealDB contains ~30-40 meals, performing name filtering locally across the loaded Indian set is instantaneous, preserves the Indian boundary, and avoids unnecessary network requests.
- **In-Memory Detail Cache:** Caching viewed details in memory provides fast re-navigation without disk overhead.

---

## 7. AI Tool Disclosure
- AI assistance was used for generating boilerplate DTO structures, JSON mock fixtures, and initial test setup.
- All domain mappings, set intersection logic, concurrency controls, and SwiftUI components were reviewed, adapted, and verified manually.
