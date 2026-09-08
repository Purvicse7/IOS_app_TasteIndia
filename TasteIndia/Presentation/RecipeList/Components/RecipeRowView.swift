import SwiftUI

struct RecipeRowView: View {
    let meal: MealSummary
    let isFavourite: Bool
    let onToggleFavourite: () -> Void
    
    var body: some View {
        HStack(spacing: 14) {
            // Meal Thumbnail with responsive loading and error placeholder
            AsyncImage(url: meal.thumbnailURL) { phase in
                switch phase {
                case .empty:
                    Rectangle()
                        .fill(Color.gray.opacity(0.2))
                        .overlay(ProgressView())
                case .success(let image):
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                case .failure:
                    Rectangle()
                        .fill(Color.gray.opacity(0.15))
                        .overlay(
                            Image(systemName: "fork.knife")
                                .font(.title3)
                                .foregroundColor(.secondary)
                        )
                @unknown default:
                    EmptyView()
                }
            }
            .frame(width: 72, height: 72)
            .clipShape(RoundedRectangle(cornerRadius: 10))
            
            VStack(alignment: .leading, spacing: 4) {
                Text(meal.name)
                    .font(.headline)
                    .foregroundColor(.primary)
                    .lineLimit(2)
                
                if let category = meal.category {
                    Text(category)
                        .font(.caption)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 2)
                        .background(AppTheme.secondaryBadge.opacity(0.12))
                        .foregroundColor(AppTheme.secondaryBadge)
                        .clipShape(Capsule())
                }
            }
            
            Spacer()
            
            Button(action: onToggleFavourite) {
                Image(systemName: isFavourite ? "heart.fill" : "heart")
                    .foregroundColor(isFavourite ? .red : .gray)
                    .font(.title3)
                    .padding(8)
            }
            .buttonStyle(.borderless)
            .accessibilityLabel(isFavourite ? "Remove \(meal.name) from favourites" : "Add \(meal.name) to favourites")
        }
        .padding(.vertical, 4)
    }
}
