import SwiftUI

struct RecipeDetailView: View {
    @StateObject private var viewModel: RecipeDetailViewModel
    @Environment(\.openURL) private var openURL
    
    init(mealId: String) {
        _viewModel = StateObject(wrappedValue: RecipeDetailViewModel(mealId: mealId))
    }
    
    var body: some View {
        ScrollView {
            switch viewModel.state {
            case .loading:
                LoadingStateView()
                    .padding(.top, 60)
            case .error(let message):
                ErrorRetryStateView(errorDescription: message) {
                    Task {
                        await viewModel.loadDetail()
                    }
                }
                .padding(.top, 60)
            case .success(let detail, let isFav):
                VStack(alignment: .leading, spacing: 18) {
                    // Responsive Hero Image with error fallback
                    AsyncImage(url: detail.thumbnailURL) { phase in
                        switch phase {
                        case .empty:
                            Rectangle()
                                .fill(Color.gray.opacity(0.2))
                                .frame(height: 240)
                                .overlay(ProgressView())
                        case .success(let image):
                            image
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                                .frame(maxWidth: .infinity, maxHeight: 280)
                                .clipped()
                        case .failure:
                            Rectangle()
                                .fill(Color.gray.opacity(0.15))
                                .frame(height: 200)
                                .overlay(
                                    Image(systemName: "photo")
                                        .font(.largeTitle)
                                        .foregroundColor(.secondary)
                                )
                        @unknown default:
                            EmptyView()
                        }
                    }
                    .clipShape(RoundedRectangle(cornerRadius: 16))
                    .padding(.horizontal)
                    
                    VStack(alignment: .leading, spacing: 14) {
                        // Title
                        Text(detail.name)
                            .font(.title.bold())
                            .foregroundColor(.primary)
                        
                        // Metadata Badges (Category & Area)
                        HStack(spacing: 8) {
                            if !detail.category.isEmpty {
                                Label(detail.category, systemImage: "tag.fill")
                                    .font(.caption.bold())
                                    .padding(.horizontal, 10)
                                    .padding(.vertical, 5)
                                    .background(AppTheme.primaryAccent.opacity(0.12))
                                    .foregroundColor(AppTheme.primaryAccent)
                                    .clipShape(Capsule())
                            }
                            if !detail.area.isEmpty {
                                Label(detail.area, systemImage: "globe.asia.australia.fill")
                                    .font(.caption.bold())
                                    .padding(.horizontal, 10)
                                    .padding(.vertical, 5)
                                    .background(AppTheme.secondaryBadge.opacity(0.12))
                                    .foregroundColor(AppTheme.secondaryBadge)
                                    .clipShape(Capsule())
                            }
                        }
                        
                        // Tags Chips
                        if !detail.tags.isEmpty {
                            ScrollView(.horizontal, showsIndicators: false) {
                                HStack(spacing: 6) {
                                    ForEach(detail.tags, id: \.self) { tag in
                                        Text("#\(tag)")
                                            .font(.caption2)
                                            .padding(.horizontal, 8)
                                            .padding(.vertical, 4)
                                            .background(Color(uiColor: .tertiarySystemGroupedBackground))
                                            .clipShape(RoundedRectangle(cornerRadius: 6))
                                    }
                                }
                            }
                        }
                        
                        Divider().padding(.vertical, 4)
                        
                        // Ingredients & Measures Section
                        VStack(alignment: .leading, spacing: 10) {
                            Text("Ingredients")
                                .font(.headline)
                            
                            VStack(spacing: 8) {
                                ForEach(detail.ingredients) { item in
                                    HStack {
                                        Text(item.name)
                                            .font(.subheadline)
                                        Spacer()
                                        Text(item.measure)
                                            .font(.subheadline.bold())
                                            .foregroundColor(.secondary)
                                    }
                                    .padding(.vertical, 4)
                                    Divider()
                                }
                            }
                            .padding()
                            .background(Color(uiColor: .secondarySystemGroupedBackground))
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                        }
                        
                        Divider().padding(.vertical, 4)
                        
                        // Instructions Section (multi-paragraph, preserving line breaks)
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Instructions")
                                .font(.headline)
                            Text(detail.instructions)
                                .font(.body)
                                .lineSpacing(5)
                                .foregroundColor(.primary)
                        }
                        
                        // Links Section (Source and YouTube buttons)
                        if detail.sourceURL != nil || detail.youtubeURL != nil {
                            Divider().padding(.vertical, 4)
                            VStack(alignment: .leading, spacing: 10) {
                                Text("External Resources")
                                    .font(.headline)
                                
                                HStack(spacing: 12) {
                                    if let yt = detail.youtubeURL {
                                        Button {
                                            openURL(yt)
                                        } label: {
                                            Label("Watch on YouTube", systemImage: "play.rectangle.fill")
                                                .font(.subheadline.bold())
                                        }
                                        .buttonStyle(.borderedProminent)
                                        .tint(.red)
                                    }
                                    
                                    if let src = detail.sourceURL {
                                        Button {
                                            openURL(src)
                                        } label: {
                                            Label("Original Recipe", systemImage: "arrow.up.right.square")
                                                .font(.subheadline.bold())
                                        }
                                        .buttonStyle(.bordered)
                                        .tint(AppTheme.primaryAccent)
                                    }
                                }
                            }
                        }
                    }
                    .padding(.horizontal)
                }
                .padding(.bottom, 24)
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                if case .success(_, let isFav) = viewModel.state {
                    Button {
                        viewModel.toggleFavourite()
                    } label: {
                        Image(systemName: isFav ? "heart.fill" : "heart")
                            .foregroundColor(isFav ? .red : .gray)
                    }
                    .accessibilityLabel(isFav ? "Remove favourite" : "Add to favourites")
                }
            }
        }
        .task {
            await viewModel.loadDetail()
        }
    }
}
