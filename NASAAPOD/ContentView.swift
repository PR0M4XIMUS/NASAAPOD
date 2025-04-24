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
                        VStack(spacing: 12) {
                            Text("Error")
                                .font(.headline)
                                .foregroundColor(.white)
                            Text(errorMessage)
                                .font(.subheadline)
                                .foregroundColor(.white.opacity(0.8))
                                .multilineTextAlignment(.center)
                                .padding(.horizontal)
                            Button("Try Again") {
                                viewModel.loadAPOD()
                            }
                            .padding(.horizontal, 20)
                            .padding(.vertical, 8)
                            .glassBackground(cornerRadius: 8)
                        }
                        .frame(width: geometry.size.width * 0.85)
                        .padding()
                        .glassBackground()
                    } else if let apod = viewModel.apod {
                        // Content state - showing APOD data
                        ScrollView {
                            VStack(alignment: .leading, spacing: 16) {
                                // Title
                                Text(apod.title)
                                    .font(.title3)
                                    .fontWeight(.bold)
                                    .foregroundColor(.white)
                                    .padding(.horizontal)
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
                                        HStack {
                                            Image(systemName: "play.circle.fill")
                                                .font(.title3)
                                            Text("Watch Video")
                                                .font(.subheadline)
                                        }
                                        .frame(width: geometry.size.width * 0.7)
                                        .padding(.vertical, 10)
                                        .glassBackground(cornerRadius: 10)
                                    }
                                    .padding(.horizontal)
                                }
                                
                                // Date and explanation text
                                VStack(alignment: .leading, spacing: 12) {
                                    Text(apod.date)
                                        .font(.caption)
                                        .foregroundColor(.white.opacity(0.7))
                                    
                                    Text(apod.explanation)
                                        .font(.footnote)
                                        .foregroundColor(.white.opacity(0.9))
                                        .lineSpacing(3)
                                }
                                .padding(16)
                                .glassBackground()
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
                        
                        // Date picker container - REDUCED SIZE
                        VStack(spacing: 0) {
                            // Header
                            Text("Select Date")
                                .font(.headline)
                                .foregroundColor(.white)
                                .padding(.top, 12)
                                .padding(.bottom, 8)
                            
                            // Date Picker with enhanced visibility but more compact
                            ZStack {
                                // Solid background to ensure visibility
                                RoundedRectangle(cornerRadius: 12)
                                    .fill(Color(red: 0.15, green: 0.15, blue: 0.2))
                                
                                // Date picker control - scaled down
                                DatePicker("",
                                          selection: $viewModel.selectedDate,
                                          in: viewModel.minDate...viewModel.maxDate,
                                          displayedComponents: .date)
                                    .datePickerStyle(GraphicalDatePickerStyle())
                                    .padding(8)
                                    .colorScheme(.dark)
                                    .accentColor(.blue)
                                    .scaleEffect(0.83) // Scale down to fit better
                                    .frame(height: geometry.size.height * 0.4) // Constrain height
                            }
                            .padding(.horizontal, 12)
                            
                            // Control buttons
                            HStack(spacing: 16) {
                                Button("Cancel") {
                                    isDatePickerShown = false
                                }
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 12)
                                .background(Color(red: 0.3, green: 0.3, blue: 0.35))
                                .foregroundColor(.white)
                                .cornerRadius(10)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 10)
                                        .stroke(Color.white.opacity(0.3), lineWidth: 1)
                                )
                                
                                Button("View APOD") {
                                    viewModel.loadAPOD(for: viewModel.selectedDate)
                                    isDatePickerShown = false
                                }
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 12)
                                .background(Color.blue)
                                .foregroundColor(.white)
                                .cornerRadius(10)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 10)
                                        .stroke(Color.white.opacity(0.3), lineWidth: 1)
                                )
                            }
                            .padding(.horizontal, 12)
                            .padding(.top, 12)
                            .padding(.bottom, 16)
                        }
                        .background(
                            // Modal background with shadowing
                            RoundedRectangle(cornerRadius: 20)
                                .fill(Color(red: 0.1, green: 0.1, blue: 0.15).opacity(0.95))
                                .shadow(color: .black.opacity(0.5), radius: 16, x: 0, y: 8)
                        )
                        .overlay(
                            // Subtle border for glass effect
                            RoundedRectangle(cornerRadius: 20)
                                .stroke(Color.white.opacity(0.2), lineWidth: 1)
                        )
                        .frame(width: geometry.size.width * 0.85)
                        .frame(maxHeight: geometry.size.height * 0.7) // Limit maximum height
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
                            HStack(spacing: 4) {
                                Image(systemName: "calendar")
                                    .font(.subheadline)
                                Text("Date")
                                    .font(.subheadline)
                            }
                            .foregroundColor(.white)
                            .padding(.vertical, 6)
                            .padding(.horizontal, 10)
                            .glassBackground(cornerRadius: 8)
                        }
                    }
                    
                    // Today button to reset to current date
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button(action: {
                            viewModel.loadAPOD(for: Date())
                        }) {
                            HStack(spacing: 4) {
                                Image(systemName: "arrow.clockwise")
                                    .font(.subheadline)
                                Text("Today")
                                    .font(.subheadline)
                            }
                            .foregroundColor(.white)
                            .padding(.vertical, 6)
                            .padding(.horizontal, 10)
                            .glassBackground(cornerRadius: 8)
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

