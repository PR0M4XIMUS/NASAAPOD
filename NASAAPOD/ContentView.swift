import SwiftUI
import Combine

// Main view of the application
struct ContentView: View {
    // State objects and properties
    @StateObject private var viewModel = APODViewModel()
    @State private var isDatePickerShown = false
    
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
                    } else if let errorMessage = viewModel.errorMessage {
                        // Error state
                        VStack(spacing: 16) {
                            Image(systemName: "exclamationmark.circle.fill")
                                .font(.system(size: 48))
                                .foregroundColor(.orange)

                            Text("Unable to Load")
                                .font(.headline)
                                .fontWeight(.semibold)
                                .foregroundColor(.white)

                            Text(errorMessage)
                                .font(.subheadline)
                                .foregroundColor(.white.opacity(0.8))
                                .multilineTextAlignment(.center)
                                .padding(.horizontal)

                            Button(action: {
                                viewModel.loadAPOD()
                            }) {
                                HStack(spacing: 8) {
                                    Image(systemName: "arrow.clockwise")
                                        .fontWeight(.semibold)
                                    Text("Try Again")
                                        .fontWeight(.semibold)
                                }
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 12)
                                .foregroundColor(.white)
                                .glassBackground(cornerRadius: 10, intensity: 0.9)
                            }
                        }
                        .frame(width: geometry.size.width * 0.85)
                        .padding(20)
                        .glassBackground(cornerRadius: 20, intensity: 0.95)
                    } else if let apod = viewModel.apod {
                        // Content state - showing APOD data
                        ScrollView {
                            VStack(alignment: .leading, spacing: 16) {
                                // Title with glass background
                                VStack(alignment: .leading, spacing: 8) {
                                    Text(apod.title)
                                        .font(.title2)
                                        .fontWeight(.bold)
                                        .tracking(0.3)
                                        .foregroundColor(.white)
                                        .lineLimit(3)
                                }
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .padding(16)
                                .glassBackground(cornerRadius: 14, intensity: 0.85)
                                .padding(.horizontal, 12)
                                .padding(.top, 8)
                                
                                // Media content - image or video
                                if apod.mediaType == "image" {
                                    AsyncImage(url: URL(string: apod.url)) { phase in
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
                                                .cornerRadius(12)
                                        case .failure:
                                            Image(systemName: "photo")
                                                .resizable()
                                                .aspectRatio(contentMode: .fit)
                                                .foregroundColor(.gray)
                                                .frame(height: geometry.size.height * 0.3)
                                        @unknown default:
                                            EmptyView()
                                        }
                                    }
                                    .frame(maxWidth: geometry.size.width)
                                    .padding(.horizontal, 12)
                                } else if apod.mediaType == "video" {
                                    // Video link button
                                    Link(destination: URL(string: apod.url)!) {
                                        HStack(spacing: 8) {
                                            Image(systemName: "play.circle.fill")
                                                .font(.title3)
                                                .foregroundColor(.blue)
                                            Text("Watch Video")
                                                .font(.subheadline)
                                                .fontWeight(.semibold)
                                                .foregroundColor(.white)
                                        }
                                        .frame(maxWidth: .infinity)
                                        .padding(.vertical, 12)
                                        .padding(.horizontal, 16)
                                        .glassBackground(cornerRadius: 12, intensity: 0.95)
                                    }
                                    .padding(.horizontal, 12)
                                }
                                
                                // Date and explanation text
                                VStack(alignment: .leading, spacing: 12) {
                                    Text(apod.date)
                                        .font(.caption)
                                        .fontWeight(.semibold)
                                        .tracking(0.5)
                                        .foregroundColor(.white.opacity(0.8))

                                    Text(apod.explanation)
                                        .font(.footnote)
                                        .foregroundColor(.white.opacity(0.85))
                                        .lineSpacing(4)
                                }
                                .padding(16)
                                .glassBackground(intensity: 0.9)
                                .padding(.horizontal, 12)
                                
                                Spacer(minLength: 16)
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
                            VStack(spacing: 8) {
                                Text("Select Date")
                                    .font(.headline)
                                    .fontWeight(.semibold)
                                    .foregroundColor(.white)

                                Text("Browse APOD history since June 1995")
                                    .font(.caption)
                                    .foregroundColor(.white.opacity(0.7))
                            }
                            .padding(.top, 16)
                            .padding(.bottom, 12)

                            // Date Picker with enhanced visibility
                            ZStack {
                                // Glass background for picker
                                RoundedRectangle(cornerRadius: 12)
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
                                        RoundedRectangle(cornerRadius: 12)
                                            .fill(Color.black.opacity(0.3))
                                    )

                                // Date picker control - scaled down
                                DatePicker("",
                                          selection: $viewModel.selectedDate,
                                          in: viewModel.minDate...viewModel.maxDate,
                                          displayedComponents: .date)
                                    .datePickerStyle(GraphicalDatePickerStyle())
                                    .padding(8)
                                    .colorScheme(.dark)
                                    .accentColor(.blue)
                                    .scaleEffect(0.83)
                                    .frame(height: geometry.size.height * 0.4)
                            }
                            .overlay(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(Color.white.opacity(0.15), lineWidth: 0.5)
                            )
                            .padding(.horizontal, 12)

                            // Control buttons with glass effect
                            HStack(spacing: 12) {
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
                                    .padding(.vertical, 12)
                                    .foregroundColor(.white)
                                    .glassBackground(cornerRadius: 10, intensity: 0.75)
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
                                    .padding(.vertical, 12)
                                    .foregroundColor(.white)
                                    .background(Color.blue.opacity(0.8))
                                    .cornerRadius(10)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 10)
                                            .stroke(Color.blue.opacity(0.5), lineWidth: 1)
                                    )
                                }
                            }
                            .padding(.horizontal, 12)
                            .padding(.top, 12)
                            .padding(.bottom, 16)
                        }
                        .background(
                            ZStack {
                                // Glass morphism background layers
                                RoundedRectangle(cornerRadius: 20)
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

                                RoundedRectangle(cornerRadius: 20)
                                    .fill(Color.black.opacity(0.4))

                                // Blur effect
                                RoundedRectangle(cornerRadius: 20)
                                    .fill(Color.white.opacity(0.01))
                                    .blur(radius: 20)
                            }
                            .shadow(color: .black.opacity(0.4), radius: 20, x: 0, y: 10)
                        )
                        .overlay(
                            // Sophisticated border
                            RoundedRectangle(cornerRadius: 20)
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
                    // Date selector button
                    ToolbarItem(placement: .navigationBarLeading) {
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
                            .padding(.horizontal, 12)
                            .glassBackground(cornerRadius: 10, intensity: 0.85)
                        }
                    }

                    // Today button to reset to current date
                    ToolbarItem(placement: .navigationBarTrailing) {
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
                            .padding(.horizontal, 12)
                            .glassBackground(cornerRadius: 10, intensity: 0.85)
                        }
                    }
                }
            }
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

