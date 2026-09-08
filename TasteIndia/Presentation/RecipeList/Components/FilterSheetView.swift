import SwiftUI

@MainActor
struct FilterSheetView: View {
    @Binding var criteria: FilterCriteria
    let availableCategories: [String]
    let availableIngredients: [String]
    let onApply: () -> Void
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationStack {
            Form {
                Section(header: Text("Sort By")) {
                    Picker("Sort Order", selection: $criteria.sortOption) {
                        ForEach(SortOption.allCases) { option in
                            Text(option.rawValue).tag(option)
                        }
                    }
                    .pickerStyle(.segmented)
                }
                
                Section(header: Text("Filter Recipes")) {
                    Toggle("Favourites Only", isOn: $criteria.favouritesOnly)
                    
                    Picker("Category", selection: $criteria.selectedCategory) {
                        Text("All Categories").tag(String?.none)
                        ForEach(availableCategories, id: \.self) { cat in
                            Text(cat).tag(String?.some(cat))
                        }
                    }
                    
                    Picker("Main Ingredient", selection: $criteria.selectedIngredient) {
                        Text("All Ingredients").tag(String?.none)
                        ForEach(availableIngredients, id: \.self) { ing in
                            Text(ing).tag(String?.some(ing))
                        }
                    }
                }
                
                Section {
                    Button("Clear All Filters", role: .destructive) {
                        criteria.clear()
                        onApply()
                        dismiss()
                    }
                }
            }
            .navigationTitle("Filters & Sort")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Close") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Apply") {
                        onApply()
                        dismiss()
                    }
                    .fontWeight(.semibold)
                    .tint(AppTheme.primaryAccent)
                }
            }
        }
    }
}
