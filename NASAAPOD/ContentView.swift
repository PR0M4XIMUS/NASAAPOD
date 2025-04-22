import SwiftUI
import Combine

struct ContentView: View {
    @StateObject private var viewModel = APODViewModel()
    @State private var isDatePickerShown = false
    
    var body: some View {
        NavigationView {
            ZStack {
                Color.black.edgesIgnoringSafeArea(.all)
                
                if viewModel.isLoading {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                        .scaleEffect(1.5)
                } else if let errorMessage = viewModel.errorMessage {
                    VStack {
                        Text("Error")
                            .font(.title)
                            .foregroundColor(.red)
                        Text(errorMessage)
                            .foregroundColor(.white)
                            .multilineTextAlignment(.center)
                            .padding()
                        Button("Try Again") {
                            viewModel.loadAPOD()
                        }
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(8)
                    }
                } else if let apod = viewModel.apod {
                    ScrollView {
                        VStack(alignment: .leading, spacing: 16) {
                            Text(apod.title)
                                .font(.title)
                                .foregroundColor(.white)
                                .padding(.horizontal)
                            
                            if apod.mediaType == "image" {
                                AsyncImage(url: URL(string: apod.url)) { phase in
                                    switch phase {
                                    case .empty:
                                        ProgressView()
                                            .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                    case .success(let image):
                                        image
                                            .resizable()
                                            .aspectRatio(contentMode: .fit)
                                    case .failure:
                                        Image(systemName: "photo")
                                            .resizable()
                                            .aspectRatio(contentMode: .fit)
                                            .foregroundColor(.gray)
                                    @unknown default:
                                        EmptyView()
                                    }
                                }
                                .frame(maxWidth: .infinity)
                                .padding(.horizontal)
                            } else if apod.mediaType == "video" {
                                Link(destination: URL(string: apod.url)!) {
                                    HStack {
                                        Image(systemName: "play.circle.fill")
                                            .font(.largeTitle)
                                        Text("Watch Video")
                                    }
                                    .frame(maxWidth: .infinity)
                                    .padding()
                                    .background(Color.blue)
                                    .foregroundColor(.white)
                                    .cornerRadius(8)
                                }
                                .padding(.horizontal)
                            }
                            
                            Text(apod.date)
                                .font(.caption)
                                .foregroundColor(.gray)
                                .padding(.horizontal)
                            
                            Text(apod.explanation)
                                .foregroundColor(.white)
                                .padding(.horizontal)
                            
                            Spacer()
                        }
                        .padding(.vertical)
                    }
                }
                
                // Date Picker Sheet
                if isDatePickerShown {
                    VStack {
                        Spacer()
                        VStack(spacing: 20) {
                            DatePicker("Select Date",
                                      selection: $viewModel.selectedDate,
                                      in: viewModel.minDate...viewModel.maxDate,
                                      displayedComponents: .date)
                                .datePickerStyle(GraphicalDatePickerStyle())
                                .padding()
                                .background(Color(.systemGray6))
                                .cornerRadius(12)
                                .padding()
                            
                            HStack {
                                Button("Cancel") {
                                    isDatePickerShown = false
                                }
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color.gray)
                                .foregroundColor(.white)
                                .cornerRadius(8)
                                
                                Button("View APOD") {
                                    viewModel.loadAPOD(for: viewModel.selectedDate)
                                    isDatePickerShown = false
                                }
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color.blue)
                                .foregroundColor(.white)
                                .cornerRadius(8)
                            }
                            .padding(.horizontal)
                        }
                        .background(Color.black)
                        .cornerRadius(16)
                        .shadow(radius: 10)
                        .padding()
                    }
                    .background(
                        Color.black.opacity(0.5)
                            .edgesIgnoringSafeArea(.all)
                            .onTapGesture {
                                isDatePickerShown = false
                            }
                    )
                    .transition(.move(edge: .bottom))
                    .animation(.easeInOut, value: isDatePickerShown)
                }
            }
            .navigationTitle("NASA APOD")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: {
                        isDatePickerShown = true
                    }) {
                        HStack {
                            Image(systemName: "calendar")
                            Text("Date")
                        }
                        .foregroundColor(.white)
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        viewModel.loadAPOD(for: Date())
                    }) {
                        HStack {
                            Image(systemName: "arrow.clockwise")
                            Text("Today")
                        }
                        .foregroundColor(.white)
                    }
                }
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
