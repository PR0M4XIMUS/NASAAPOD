# NASA APOD App 🚀

A beautiful iOS application that displays NASA's Astronomy Picture of the Day (APOD) with an immersive glassmorphism interface that responds to device motion.

![iOS](https://img.shields.io/badge/iOS-15.0+-black?style=flat-square&logo=apple)
![Swift](https://img.shields.io/badge/Swift-5.5+-FA7343?style=flat-square&logo=swift&logoColor=white)
![Xcode](https://img.shields.io/badge/Xcode-13.0+-1575F9?style=flat-square&logo=xcode&logoColor=white)
![License](https://img.shields.io/badge/License-MIT-green?style=flat-square)

## 📚 Table of Contents

- [✨ Features](#-features)
- [🛠 Setup & Installation](#-setup--installation)
- [🎮 Controls & Usage](#-controls--usage)
- [🏗 Architecture](#-architecture)
- [🤝 Contributing](#-contributing)
- [🔧 Development](#-development)
- [🌟 NASA APOD API](#-nasa-apod-api)
- [📱 System Requirements](#-system-requirements)
- [📝 License](#-license)

## ✨ Features

- **Daily Astronomy Content**: View NASA's carefully curated Astronomy Picture of the Day
- **Historical Browsing**: Explore APODs dating back to June 16, 1995 (over 28 years of content!)
- **Multi-Media Support**: Seamlessly handle both stunning images and educational videos
- **Motion-Responsive UI**: Beautiful glassmorphism interface that responds to device movement
- **Intuitive Date Selection**: Easy calendar-based date picker for exploring historical content
- **Dark Theme Design**: Optimized for nighttime stargazing sessions
- **Offline-Friendly**: Graceful error handling when network is unavailable

## 🛠 Setup & Installation

### Prerequisites

- macOS 12.0+ (for Xcode compatibility)
- Xcode 13.0 or later
- iOS device or simulator running iOS 15.0+
- Active internet connection for API requests

### Installation Steps

1. **Clone the Repository**
   ```bash
   git clone https://github.com/PR0M4XIMUS/NASAAPOD.git
   cd NASAAPOD
   ```

2. **Get NASA API Key**
   - Visit the [NASA API Portal](https://api.nasa.gov/)
   - Click "Get Started" and fill out the form (it's free!)
   - You'll receive your API key via email instantly

3. **Configure API Key**
   ```bash
   # Copy the sample configuration file
   cp NASAAPOD/APIConfig-Sample.swift NASAAPOD/APIConfig.swift
   ```
   
   - Open `NASAAPOD/APIConfig.swift` in Xcode or your preferred editor
   - Replace `"YOUR_NASA_API_KEY"` with your actual NASA API key:
   ```swift
   struct APiConfig {
       static let nasaAPIKey = "your_actual_api_key_here"
   }
   ```

4. **Build and Run**
   - Open `NASAAPOD.xcodeproj` in Xcode
   - Select your target device or simulator
   - Press `⌘ + R` to build and run

### Troubleshooting Setup

- **Build Error "Cannot find 'APIConfig'"**: Make sure you've created `APIConfig.swift` from the sample file
- **API Key Invalid**: Verify your API key is correct and has no extra spaces or quotes
- **Network Errors**: Check your internet connection and API key validity
- **Motion Not Working**: The motion effects only work on physical devices, not simulators

## 🎮 Controls & Usage

### Navigation

- **Date Button** (📅): Tap the calendar icon in the top-left to open the date picker
- **Today Button** (🔄): Tap the refresh icon in the top-right to return to today's APOD

### Date Selection

1. Tap the **Date** button to open the calendar modal
2. **Scroll through months/years** or tap dates directly
3. Tap **"View APOD"** to load the selected date
4. Tap **"Cancel"** or the background to close without changing dates

### Viewing Content

- **Images**: Automatically display in high resolution with loading indicators
- **Videos**: Shows a "Watch Video" button that opens the content in your default browser
- **Text Content**: Scroll down to read the full explanation and details
- **Motion Effects**: Tilt your device to see the subtle glass UI effects (physical device only)

### Interface Elements

- **Glass Background Effects**: UI elements respond to device tilt for an immersive experience
- **Loading States**: Progress indicators show when content is being fetched
- **Error Handling**: Clear error messages if content fails to load
- **Responsive Layout**: Adapts to different screen sizes and orientations

## 🏗 Architecture

The app follows the MVVM (Model-View-ViewModel) pattern with SwiftUI and uses only Apple's native frameworks:

### Framework Dependencies
- **SwiftUI**: Modern declarative UI framework
- **Combine**: Reactive programming for API calls and state management
- **CoreMotion**: Device motion tracking for responsive UI effects
- **Foundation**: Core utilities and networking

### Project Structure

```
NASAAPOD/
├── NASAAPODApp.swift          # App entry point and configuration
├── ContentView.swift          # Main UI view with glassmorphism design
├── APODViewModel.swift        # Business logic and state management
├── APODModel.swift           # Data models for API responses
├── NetworkService.swift      # API service layer with Combine
├── MotionManager.swift       # CoreMotion integration for UI effects
├── GlassBackground.swift     # Custom glassmorphism UI modifier
├── APIConfig-Sample.swift    # Template for API configuration
└── Assets.xcassets/         # App icons and visual assets
```

### Key Components

- **APODViewModel**: Manages app state, API calls, and date selection using Combine
- **NetworkService**: Handles NASA API communication with proper error handling
- **MotionManager**: Tracks device motion for responsive UI effects
- **GlassBackground**: Custom SwiftUI modifier for glassmorphism effects

## 🤝 Contributing

We welcome contributions! Please follow these guidelines:

### Getting Started

1. **Fork the repository** on GitHub
2. **Clone your fork** locally:
   ```bash
   git clone https://github.com/your-username/NASAAPOD.git
   ```
3. **Create a feature branch**:
   ```bash
   git checkout -b feature/your-feature-name
   ```

### Development Setup

1. Follow the installation steps above
2. Ensure you have a valid NASA API key configured
3. Test the app on both simulator and physical device
4. Verify motion effects work on physical devices

### Code Style Guidelines

- **Swift Style**: Follow Apple's Swift style guide
- **Naming**: Use descriptive, camelCase naming for variables and functions
- **Comments**: Add comments for complex logic, especially motion calculations
- **Architecture**: Maintain MVVM pattern separation
- **Error Handling**: Always provide graceful error handling for network requests

### Making Changes

1. **Write clear commit messages** describing what and why
2. **Test thoroughly** on both simulator and device
3. **Verify API key security** - never commit actual API keys
4. **Check motion effects** work properly on physical devices
5. **Ensure UI responsiveness** across different screen sizes

### Pull Request Process

1. **Update documentation** if your changes affect user-facing features
2. **Test edge cases** like network failures, invalid dates, etc.
3. **Provide clear PR description** with:
   - What changes were made
   - Why they were needed
   - How to test the changes
   - Screenshots for UI changes

### Areas for Contribution

- 🎨 **UI/UX Improvements**: Enhanced animations, better loading states
- 🔧 **Feature Additions**: Favorites system, sharing capabilities, offline mode
- 🐛 **Bug Fixes**: Network handling, date validation, motion edge cases
- 📱 **Platform Support**: iPad optimization, macOS Catalyst support
- 🧪 **Testing**: Unit tests, UI tests, performance optimization
- 📚 **Documentation**: Code comments, user guides, architecture docs
- 📸 **Screenshots**: App store screenshots, documentation images

### Documentation Guidelines

When contributing documentation or UI changes:

1. **Screenshots**: Capture high-quality screenshots for UI changes
   - Use iPhone 14 Pro simulator or actual device
   - Show both light and dark mode if applicable
   - Include before/after comparisons for changes
2. **GIFs**: For interactive features, consider adding animated GIFs
3. **Markdown**: Follow consistent formatting and style
4. **Code Examples**: Include Swift code snippets where helpful

## 🔧 Development

### Building the Project

```bash
# Open in Xcode
open NASAAPOD.xcodeproj

# Or use command line (requires xcode-select)
xcodebuild -project NASAAPOD.xcodeproj -scheme NASAAPOD -destination 'platform=iOS Simulator,name=iPhone 14' build
```

### Testing Motion Effects

Motion-responsive UI elements only work on physical devices with gyroscope support. To test:

1. Build to a physical iPhone/iPad
2. Hold device normally and tilt gently
3. Observe subtle glass border shifts following device orientation

### API Rate Limits

NASA's API has the following limits:
- **Demo Key**: 30 requests per hour, 50 requests per day
- **Registered Key**: 1,000 requests per hour

For development, the demo key is usually sufficient since APODs are cached daily.

## 🌟 NASA APOD API

This app uses NASA's Astronomy Picture of the Day API:
- **Base URL**: `https://api.nasa.gov/planetary/apod`
- **Documentation**: [NASA API Docs](https://api.nasa.gov/)
- **Data**: High-quality astronomy images and videos with educational descriptions
- **History**: Content available from June 16, 1995 to present

## 🔒 Security

- **API Keys**: Never commit actual API keys to version control
- **Sample Config**: Use `APIConfig-Sample.swift` as template
- **Private Keys**: Add `APIConfig.swift` to `.gitignore` (already configured)

## 📱 System Requirements

- **iOS**: 15.0 or later
- **Xcode**: 13.0 or later  
- **Swift**: 5.5 or later
- **Device**: iPhone or iPad with internet connectivity
- **Motion Features**: Requires device with gyroscope (physical device only)

## 📝 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 🙏 Acknowledgments

- **NASA** for providing the incredible APOD API and content
- **Apple** for SwiftUI and CoreMotion frameworks
- **Community** for feedback and contributions

## 📞 Support

If you encounter issues:

1. Check the [Troubleshooting](#troubleshooting-setup) section above
2. Verify your API key is valid and properly configured
3. Ensure you're testing motion features on a physical device
4. Open an issue on GitHub with detailed error information

---

*Explore the cosmos, one picture at a time* ⭐
