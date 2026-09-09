import SwiftUI

@MainActor
struct RecipeListView: View {
    @StateObject var viewModel: RecipeListViewModel
    @State private var navigationPath = NavigationPath()
    
    var body: some View {
        NavigationStack(path: $navigationPath) {
            VStack(spacing: 0) {
                // Active filter banner when criteria are active
                if viewModel.criteria.isActive {
                    HStack {
                        Image(systemName: "line.3.horizontal.decrease.circle.fill")
                            .foregroundColor(AppTheme.primaryAccent)
                        Text("Filters active")
                            .font(.caption.bold())
                        Spacer()
                        Button("Clear all") {
                            viewModel.clearAllFilters()
                        }
                        .font(.caption.bold())
                        .foregroundColor(AppTheme.primaryAccent)
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 8)
                    .background(AppTheme.tertiaryBackground)
                }
                
                // Content State
                Group {
                    switch viewModel.state {
                    case .idle, .loading:
                        LoadingStateView()
                    case .empty(let message):
                        EmptyResultsStateView(message: message) {
                            viewModel.clearAllFilters()
                        }
                    case .error(let message):
                        ErrorRetryStateView(errorDescription: message) {
                            Task {
                                await viewModel.applyFilters()
                            }
                        }
                    case .success(let meals):
                        List {
                            Section(header: Text("\(meals.count) recipes found")) {
                                ForEach(meals) { meal in
                                    NavigationLink(value: AppRoute.recipeDetail(idMeal: meal.id)) {
                                        RecipeRowView(
                                            meal: meal,
                                            isFavourite: viewModel.favouriteIds.contains(meal.id),
                                            onToggleFavourite: {
                                                viewModel.toggleFavourite(for: meal.id)
                                            }
                                        )
                                    }
                                }
                            }
                        }
                        #if os(iOS)
                        .listStyle(.insetGrouped)
#else
                        .listStyle(.automatic)
#endif
                        .refreshable {
                            await viewModel.applyFilters()
                        }
                    }
                }
            }
            .navigationTitle("TasteIndia")
            .searchable(
                text: Binding(
                    get: { viewModel.criteria.searchQuery },
                    set: { viewModel.onSearchQueryChanged($0) }
                ),
                prompt: "Search Indian dishes…"
            )
            .toolbar {
                ToolbarItem(#if os(iOS)
                placement: .navigationBarTrailing
#else
                placement: .automatic
#endif) {
                    Button {
                        viewModel.isFilterSheetPresented = true
                    } label: {
                        Image(systemName: viewModel.criteria.isActive ? "line.3.horizontal.decrease.circle.fill" : "line.3.horizontal.decrease.circle")
                            .tint(AppTheme.primaryAccent)
                    }
                    .accessibilityLabel("Filter recipes")
                }
            }
            .sheet(isPresented: $viewModel.isFilterSheetPresented) {
                FilterSheetView(
                    criteria: $viewModel.criteria,
                    availableCategories: viewModel.availableCategories,
                    availableIngredients: viewModel.availableIngredients,
                    onApply: {
                        Task {
                            await viewModel.applyFilters()
                        }
                    }
                )
            }
            .navigationDestination(for: AppRoute.self) { route in
                switch route {
                case .recipeDetail(let idMeal):
                    RecipeDetailView(mealId: idMeal)
                }
            }
            .onAppear {
                viewModel.onAppear()
            }
        }
    }
}
