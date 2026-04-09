import SwiftUI
import Combine

// Main view of the application
struct ContentView: View {
    // State objects and properties
    @StateObject private var viewModel = APODViewModel()
    @State private var isDatePickerShown = false
    @State private var isSettingsShown = false
    @State private var isFavoritesShown = false
    
    var body: some View {
        NavigationView {
            GeometryReader { geometry in
                ZStack {
                    // App background
                    Color.black.edgesIgnoringSafeArea(.all)
                    
                    // Main content based on state
                    if viewModel.isLoading {
                        // Loading state
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle(tint: .white))
                            .scaleEffect(1.5)
                    } else if viewModel.error != nil {
                        // Error state
                        VStack(spacing: 16) {
                            Image(systemName: "exclamationmark.circle.fill")
                                .font(.system(size: 48))
                                .foregroundColor(AppTheme.errorColor)

                            Text("Unable to Load")
                                .font(.headline)
                                .fontWeight(.semibold)
                                .foregroundColor(.white)

                            Text(viewModel.errorMessage ?? "An error occurred")
                                .font(.subheadline)
                                .foregroundColor(.white.opacity(AppTheme.secondaryTextOpacity))
                                .multilineTextAlignment(.center)
                                .padding(.horizontal)

                            VStack(spacing: AppTheme.smallPadding) {
                                Button(action: {
                                    viewModel.retryLoading()
                                }) {
                                    HStack(spacing: 8) {
                                        Image(systemName: "arrow.clockwise")
                                            .fontWeight(.semibold)
                                        Text("Retry")
                                            .fontWeight(.semibold)
                                    }
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, AppTheme.standardPadding)
                                    .foregroundColor(.white)
                                    .glassBackground(cornerRadius: AppTheme.smallCornerRadius, intensity: 0.9)
                                }

                                if viewModel.cachedAPOD != nil {
                                    Text("Showing cached data")
                                        .font(.caption)
                                        .foregroundColor(.white.opacity(0.6))
                                }
                            }
                        }
                        .frame(width: geometry.size.width * 0.85)
                        .padding(AppTheme.standardPadding)
                        .glassBackground(cornerRadius: AppTheme.largeCornerRadius, intensity: 0.95)
                    } else if let apod = viewModel.apod {
                        // Content state - showing APOD data
                        ScrollView {
                            VStack(alignment: .leading, spacing: AppTheme.standardPadding) {
                                // Title with glass background
                                VStack(alignment: .leading, spacing: AppTheme.smallPadding) {
                                    HStack(alignment: .top) {
                                        Text(apod.title)
                                            .font(.title2)
                                            .fontWeight(.bold)
                                            .tracking(0.3)
                                            .foregroundColor(.white)
                                            .lineLimit(4)

                                        // Share button in title
                                        if let imageURL = apod.validatedImageURL {
                                            ShareLink(item: imageURL, subject: Text(apod.title), message: Text(apod.explanation)) {
                                                Image(systemName: "square.and.arrow.up")
                                                    .font(.subheadline)
                                                    .foregroundColor(AppTheme.accentColor)
                                            }
                                        }
                                    }
                                }
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .padding(AppTheme.standardPadding)
                                .glassBackground(cornerRadius: AppTheme.standardCornerRadius, intensity: 0.85)
                                .padding(.horizontal, AppTheme.mediumPadding)
                                .padding(.top, AppTheme.smallPadding)
                                
                                // Media content - image or video
                                if apod.mediaType.isImage {
                                    AsyncImage(url: apod.validatedImageURL) { phase in
                                        switch phase {
                                        case .empty:
                                            ProgressView()
                                                .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                                .frame(height: geometry.size.height * 0.3)
                                        case .success(let image):
                                            image
                                                .resizable()
                                                .aspectRatio(contentMode: .fit)
                                                .frame(maxHeight: geometry.size.height * 0.5)
                                                .cornerRadius(AppTheme.standardCornerRadius)
                                        case .failure:
                                            VStack(spacing: 8) {
                                                Image(systemName: "photo.circle")
                                                    .font(.system(size: 32))
                                                Text("Image unavailable")
                                                    .font(.caption)
                                            }
                                            .foregroundColor(.gray)
                                            .frame(height: geometry.size.height * 0.3)
                                        @unknown default:
                                            EmptyView()
                                        }
                                    }
                                    .frame(maxWidth: geometry.size.width)
                                    .padding(.horizontal, AppTheme.mediumPadding)
                                } else if apod.mediaType.isVideo {
                                    // Video link button - safe URL handling
                                    if let videoURL = apod.validatedURL {
                                        Link(destination: videoURL) {
                                            HStack(spacing: 8) {
                                                Image(systemName: "play.circle.fill")
                                                    .font(.title3)
                                                    .foregroundColor(AppTheme.accentColor)
                                                Text("Watch Video")
                                                    .font(.subheadline)
                                                    .fontWeight(.semibold)
                                                    .foregroundColor(.white)
                                            }
                                            .frame(maxWidth: .infinity)
                                            .padding(.vertical, AppTheme.standardPadding)
                                            .padding(.horizontal, AppTheme.standardPadding)
                                            .glassBackground(cornerRadius: AppTheme.smallCornerRadius, intensity: 0.95)
                                        }
                                        .padding(.horizontal, AppTheme.mediumPadding)
                                    } else {
                                        Text("Video URL unavailable")
                                            .font(.caption)
                                            .foregroundColor(.gray)
                                            .padding()
                                    }
                                }
                                
                                // Date and explanation text
                                VStack(alignment: .leading, spacing: AppTheme.mediumPadding) {
                                    Text(apod.date)
                                        .font(.caption)
                                        .fontWeight(.semibold)
                                        .tracking(0.5)
                                        .foregroundColor(.white.opacity(AppTheme.secondaryTextOpacity))

                                    Text(apod.explanation)
                                        .font(.footnote)
                                        .foregroundColor(.white.opacity(AppTheme.primaryTextOpacity))
                                        .lineSpacing(4)
                                }
                                .padding(AppTheme.standardPadding)
                                .glassBackground(intensity: 0.9)
                                .padding(.horizontal, AppTheme.mediumPadding)

                                Spacer(minLength: AppTheme.standardPadding)
                            }
                            .padding(.vertical, 12)
                        }
                    }
                    
                    // Date Picker overlay - shown when date button is tapped
                    if isDatePickerShown {
                        // Semi-transparent background overlay
                        Rectangle()
                            .fill(Color.black.opacity(0.7))
                            .edgesIgnoringSafeArea(.all)
                            .onTapGesture {
                                isDatePickerShown = false
                            }
                        
                        // Date picker container with enhanced glass effect
                        VStack(spacing: 0) {
                            // Header with accent
                            VStack(spacing: AppTheme.smallPadding) {
                                Text("Select Date")
                                    .font(.headline)
                                    .fontWeight(.semibold)
                                    .foregroundColor(.white)

                                Text("Browse APOD history since June 1995")
                                    .font(.caption)
                                    .foregroundColor(.white.opacity(AppTheme.tertiaryTextOpacity))
                            }
                            .padding(.top, AppTheme.standardPadding)
                            .padding(.bottom, AppTheme.mediumPadding)

                            // Date Picker with enhanced visibility
                            ZStack {
                                // Glass background for picker
                                RoundedRectangle(cornerRadius: AppTheme.smallCornerRadius)
                                    .fill(
                                        LinearGradient(
                                            gradient: Gradient(colors: [
                                                Color.white.opacity(0.05),
                                                Color.blue.opacity(0.03)
                                            ]),
                                            startPoint: .topLeading,
                                            endPoint: .bottomTrailing
                                        )
                                    )
                                    .background(
                                        RoundedRectangle(cornerRadius: AppTheme.smallCornerRadius)
                                            .fill(Color.black.opacity(0.3))
                                    )

                                // Date picker control - scaled down
                                DatePicker("",
                                          selection: $viewModel.selectedDate,
                                          in: viewModel.minDate...viewModel.maxDate,
                                          displayedComponents: .date)
                                    .datePickerStyle(GraphicalDatePickerStyle())
                                    .padding(AppTheme.smallPadding)
                                    .colorScheme(.dark)
                                    .accentColor(AppTheme.accentColor)
                                    .scaleEffect(0.83)
                                    .frame(height: geometry.size.height * 0.4)
                            }
                            .overlay(
                                RoundedRectangle(cornerRadius: AppTheme.smallCornerRadius)
                                    .stroke(Color.white.opacity(0.15), lineWidth: 0.5)
                            )
                            .padding(.horizontal, AppTheme.mediumPadding)

                            // Control buttons with glass effect
                            HStack(spacing: AppTheme.mediumPadding) {
                                Button(action: {
                                    isDatePickerShown = false
                                }) {
                                    HStack {
                                        Image(systemName: "xmark")
                                            .fontWeight(.semibold)
                                        Text("Cancel")
                                            .fontWeight(.semibold)
                                    }
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, AppTheme.standardPadding)
                                    .foregroundColor(.white)
                                    .glassBackground(cornerRadius: AppTheme.smallCornerRadius, intensity: 0.75)
                                }

                                Button(action: {
                                    viewModel.loadAPOD(for: viewModel.selectedDate)
                                    isDatePickerShown = false
                                }) {
                                    HStack {
                                        Image(systemName: "checkmark.circle.fill")
                                            .fontWeight(.semibold)
                                        Text("View APOD")
                                            .fontWeight(.semibold)
                                    }
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, AppTheme.standardPadding)
                                    .foregroundColor(.white)
                                    .background(AppTheme.accentColor.opacity(0.8))
                                    .cornerRadius(AppTheme.smallCornerRadius)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: AppTheme.smallCornerRadius)
                                            .stroke(AppTheme.accentColor.opacity(0.5), lineWidth: 1)
                                    )
                                }
                            }
                            .padding(.horizontal, AppTheme.mediumPadding)
                            .padding(.top, AppTheme.mediumPadding)
                            .padding(.bottom, AppTheme.standardPadding)
                        }
                        .background(
                            ZStack {
                                // Glass morphism background layers
                                RoundedRectangle(cornerRadius: AppTheme.largeCornerRadius)
                                    .fill(
                                        LinearGradient(
                                            gradient: Gradient(colors: [
                                                Color.white.opacity(0.06),
                                                Color.blue.opacity(0.03)
                                            ]),
                                            startPoint: .topLeading,
                                            endPoint: .bottomTrailing
                                        )
                                    )

                                RoundedRectangle(cornerRadius: AppTheme.largeCornerRadius)
                                    .fill(Color.black.opacity(0.4))

                                // Blur effect
                                RoundedRectangle(cornerRadius: AppTheme.largeCornerRadius)
                                    .fill(Color.white.opacity(0.01))
                                    .blur(radius: 20)
                            }
                            .shadow(color: .black.opacity(0.4), radius: 20, x: 0, y: 10)
                        )
                        .overlay(
                            // Sophisticated border
                            RoundedRectangle(cornerRadius: AppTheme.largeCornerRadius)
                                .stroke(
                                    LinearGradient(
                                        gradient: Gradient(colors: [
                                            Color.white.opacity(0.3),
                                            Color.white.opacity(0.1)
                                        ]),
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    ),
                                    lineWidth: 1
                                )
                        )
                        .frame(width: geometry.size.width * 0.85)
                        .frame(maxHeight: geometry.size.height * 0.75)
                    }
                }
                .navigationTitle("NASA APOD")
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    // Date selector and favorites buttons
                    ToolbarItem(placement: .navigationBarLeading) {
                        HStack(spacing: AppTheme.smallPadding) {
                            Button(action: {
                                isFavoritesShown = true
                            }) {
                                Image(systemName: "heart.fill")
                                    .font(.subheadline)
                                    .fontWeight(.semibold)
                                    .foregroundColor(.red)
                                    .padding(.vertical, 8)
                                    .padding(.horizontal, AppTheme.mediumPadding)
                                    .glassBackground(cornerRadius: AppTheme.smallCornerRadius, intensity: 0.85)
                            }

                            Button(action: {
                                isDatePickerShown = true
                            }) {
                                HStack(spacing: 6) {
                                    Image(systemName: "calendar")
                                        .font(.subheadline)
                                        .fontWeight(.semibold)
                                    Text("Date")
                                        .font(.subheadline)
                                        .fontWeight(.semibold)
                                }
                                .foregroundColor(.white)
                                .padding(.vertical, 8)
                                .padding(.horizontal, AppTheme.mediumPadding)
                                .glassBackground(cornerRadius: AppTheme.smallCornerRadius, intensity: 0.85)
                            }

                            if viewModel.isLoadingUpdate {
                                ProgressView()
                                    .scaleEffect(0.8)
                                    .tint(.white)
                            }
                        }
                    }

                    // Settings, Favorite, and Today buttons
                    ToolbarItem(placement: .navigationBarTrailing) {
                        HStack(spacing: AppTheme.smallPadding) {
                            // Settings button
                            Button(action: {
                                isSettingsShown = true
                            }) {
                                Image(systemName: "gear")
                                    .font(.subheadline)
                                    .fontWeight(.semibold)
                                    .foregroundColor(.white)
                                    .padding(.vertical, 8)
                                    .padding(.horizontal, AppTheme.mediumPadding)
                                    .glassBackground(cornerRadius: AppTheme.smallCornerRadius, intensity: 0.85)
                            }

                            // Favorite button
                            Button(action: {
                                viewModel.toggleFavorite()
                            }) {
                                Image(systemName: viewModel.isFavorite ? "heart.fill" : "heart")
                                    .font(.subheadline)
                                    .fontWeight(.semibold)
                                    .foregroundColor(viewModel.isFavorite ? .red : .white)
                                    .padding(.vertical, 8)
                                    .padding(.horizontal, AppTheme.mediumPadding)
                                    .glassBackground(cornerRadius: AppTheme.smallCornerRadius, intensity: 0.85)
                            }

                            // Today button
                            Button(action: {
                                viewModel.loadAPOD(for: Date())
                            }) {
                                HStack(spacing: 6) {
                                    Image(systemName: "arrow.clockwise")
                                        .font(.subheadline)
                                        .fontWeight(.semibold)
                                    Text("Today")
                                        .font(.subheadline)
                                        .fontWeight(.semibold)
                                }
                                .foregroundColor(.white)
                                .padding(.vertical, 8)
                                .padding(.horizontal, AppTheme.mediumPadding)
                                .glassBackground(cornerRadius: AppTheme.smallCornerRadius, intensity: 0.85)
                            }
                        }
                    }
                }
            }
        }
        .sheet(isPresented: $isSettingsShown) {
            SettingsView()
        }
        .sheet(isPresented: $isFavoritesShown) {
            FavoritesView()
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
            .preferredColorScheme(.dark)
            .environmentObject(MotionManager())
    }
}

