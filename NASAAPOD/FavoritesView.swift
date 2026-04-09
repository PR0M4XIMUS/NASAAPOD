import SwiftUI

// View for browsing saved favorite APODs
struct FavoritesView: View {
    @Environment(\.dismiss) var dismiss
    @State private var favorites: [APODResponse] = []
    @State private var selectedAPOD: APODResponse?

    var body: some View {
        NavigationView {
            ZStack {
                Color.black.edgesIgnoringSafeArea(.all)

                if favorites.isEmpty {
                    VStack(spacing: AppTheme.standardPadding) {
                        Image(systemName: "heart.slash")
                            .font(.system(size: 48))
                            .foregroundColor(.gray)

                        Text("No Favorites Yet")
                            .font(.headline)
                            .fontWeight(.semibold)
                            .foregroundColor(.white)

                        Text("Save your favorite APODs to view them here anytime")
                            .font(.subheadline)
                            .foregroundColor(.white.opacity(AppTheme.secondaryTextOpacity))
                            .multilineTextAlignment(.center)
                            .padding(.horizontal)
                    }
                } else {
                    ScrollView {
                        VStack(spacing: AppTheme.mediumPadding) {
                            ForEach(favorites, id: \.date) { apod in
                                FavoriteCard(apod: apod)
                                    .padding(.horizontal, AppTheme.mediumPadding)
                            }
                            Spacer(minLength: AppTheme.standardPadding)
                        }
                        .padding(.vertical, AppTheme.mediumPadding)
                    }
                }
            }
            .navigationTitle("Favorites")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                    .fontWeight(.semibold)
                    .foregroundColor(AppTheme.accentColor)
                }
            }
            .onAppear {
                favorites = PersistenceService.shared.getFavorites()
                    .sorted { $0.date > $1.date }  // Newest first
            }
        }
    }
}

// Individual favorite card
struct FavoriteCard: View {
    let apod: APODResponse
    @State private var showRemoveAlert = false

    var body: some View {
        VStack(alignment: .leading, spacing: AppTheme.mediumPadding) {
            HStack(alignment: .top, spacing: AppTheme.mediumPadding) {
                // Thumbnail
                if let imageURL = apod.validatedImageURL, apod.mediaType.isImage {
                    AsyncImage(url: imageURL) { phase in
                        switch phase {
                        case .empty:
                            ProgressView()
                                .frame(width: 80, height: 80)
                        case .success(let image):
                            image
                                .resizable()
                                .scaledToFill()
                                .frame(width: 80, height: 80)
                                .cornerRadius(AppTheme.smallCornerRadius)
                        case .failure:
                            Image(systemName: "photo")
                                .foregroundColor(.gray)
                                .frame(width: 80, height: 80)
                        @unknown default:
                            EmptyView()
                        }
                    }
                } else {
                    Image(systemName: apod.mediaType.isVideo ? "play.circle.fill" : "photo.circle")
                        .font(.system(size: 32))
                        .foregroundColor(.gray)
                        .frame(width: 80, height: 80)
                }

                // Content
                VStack(alignment: .leading, spacing: AppTheme.smallPadding) {
                    Text(apod.title)
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .foregroundColor(.white)
                        .lineLimit(2)

                    Text(apod.date)
                        .font(.caption)
                        .foregroundColor(.white.opacity(AppTheme.tertiaryTextOpacity))

                    Spacer()

                    // Remove button
                    Button(action: {
                        showRemoveAlert = true
                    }) {
                        HStack(spacing: 4) {
                            Image(systemName: "heart.slash.fill")
                                .font(.caption2)
                            Text("Remove")
                                .font(.caption)
                        }
                        .foregroundColor(.red)
                        .padding(.vertical, 4)
                        .padding(.horizontal, 8)
                        .background(Color.red.opacity(0.1))
                        .cornerRadius(AppTheme.tinyCornerRadius)
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)

                Spacer(minLength: 0)
            }
        }
        .padding(AppTheme.standardPadding)
        .glassBackground(cornerRadius: AppTheme.standardCornerRadius, intensity: 0.85, useMotion: false)
        .alert("Remove Favorite?", isPresented: $showRemoveAlert) {
            Button("Remove", role: .destructive) {
                PersistenceService.shared.removeFavorite(date: apod.date)
            }
            Button("Cancel", role: .cancel) {}
        }
    }
}

#Preview {
    FavoritesView()
        .preferredColorScheme(.dark)
}
