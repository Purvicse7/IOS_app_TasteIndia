import SwiftUI

@main
struct TasteIndiaApp: App {
    @StateObject private var listViewModel: RecipeListViewModel
    
    init() {
        let container = DependencyContainer.shared
        _listViewModel = StateObject(
            wrappedValue: RecipeListViewModel(
                repository: container.recipeRepository,
                favouritesStore: container.favouritesStore
            )
        )
    }
    
    var body: some Scene {
        WindowGroup {
            RecipeListView(viewModel: listViewModel)
        }
    }
}
