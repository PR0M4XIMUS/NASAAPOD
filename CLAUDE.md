# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

This is an iOS app (Swift/SwiftUI) that displays NASA's Astronomy Picture of the Day with a glassmorphism UI and device motion-responsive effects. The app uses only native Apple frameworks and follows the MVVM pattern with reactive Combine-based state management.

## Essential Setup

**Before building or testing:**
1. The app requires a NASA API key to function. Users must copy `APIConfig-Sample.swift` to `APIConfig.swift` and add their key
2. The file `APIConfig.swift` is in `.gitignore` and should never be committed
3. Motion effects (roll/pitch tracking) only work on physical devices, not simulators—test motion on actual hardware

## Building & Running

```bash
# Open in Xcode (required for building iOS apps)
open NASAAPOD.xcodeproj

# Command-line build for simulator
xcodebuild -project NASAAPOD.xcodeproj -scheme NASAAPOD -destination 'platform=iOS Simulator,name=iPhone 14'

# Build for physical device (requires signing setup in Xcode)
xcodebuild -project NASAAPOD.xcodeproj -scheme NASAAPOD -destination 'generic/platform=iOS'
```

In Xcode: Select target device/simulator and press `⌘ + R` to build and run.

## Architecture & Key Components

### MVVM + Combine Pattern

The app uses a clean separation of concerns:
- **Views** (SwiftUI): Declarative UI components
- **ViewModels** (Combine): Published properties drive state; business logic handles API calls
- **Models**: Codable structs for JSON decoding
- **Services**: Reusable logic layers (networking, motion)

### Core Files

| File | Purpose | Key Details |
|------|---------|------------|
| `NASAAPODApp.swift` | App entry point | Initializes `MotionManager` and provides it via `@EnvironmentObject` |
| `ContentView.swift` | Main UI | Displays APOD with glassmorphism, date picker, loading states |
| `APODViewModel.swift` | State & logic | Manages APOD data, date selection (1995-06-16 to today), loading/error states; uses Combine `sink()` for async handling |
| `NetworkService.swift` | API communication | Fetches from `https://api.nasa.gov/planetary/apod` via `URLSession` + Combine; handles date formatting |
| `APODModel.swift` | Data types | `APODResponse` struct with Codable; maps JSON keys like `media_type` → `mediaType` |
| `MotionManager.swift` | Device motion | CoreMotion integration; publishes `roll` and `pitch` at 60 Hz for UI effects |
| `GlassBackground.swift` | UI modifier | Custom SwiftUI modifier for glassmorphism effects (blur, transparency) |

### State Flow

1. **App Launch**: `NASAAPODApp` creates `MotionManager`; `ContentView` observes it via `@EnvironmentObject`
2. **Initial Load**: `APODViewModel.init()` calls `loadAPOD()` for today's date
3. **Date Selection**: User picks date → `loadAPOD(for: date)` → `NetworkService.fetchAPOD()` → JSON decode → `@Published apod` updated
4. **Motion Effects**: `MotionManager` publishes roll/pitch continuously → SwiftUI re-renders UI transforms

### Important Constraints

- **Date Range**: NASA APOD data starts June 16, 1995. `APODViewModel` enforces `minDate` and `maxDate`
- **Media Types**: API returns either images or videos (`mediaType` = `"image"` or `"video"`); app handles both
- **Dark Theme**: Forced via `.preferredColorScheme(.dark)` in `NASAAPODApp` for glassmorphism aesthetic
- **Motion**: Only available on physical devices with gyroscope; gracefully skips on simulators

## NASA API Details

- **Base URL**: `https://api.nasa.gov/planetary/apod`
- **Rate Limits**: Demo keys (30/hour, 50/day); registered keys (1000/hour)
- **Response Fields**: `date`, `title`, `explanation`, `url`, `hdurl`, `media_type`, `service_version`
- **Date Format**: Query parameter uses `yyyy-MM-dd` format

## Common Development Tasks

### Adding a New Feature to ContentView
1. Add `@Published` property to `APODViewModel` if state is needed
2. Create SwiftUI `View` in `ContentView.swift` or a new file
3. Use `.environmentObject(motionManager)` to access motion if needed

### Debugging Network Issues
- Check `NetworkService.swift` URL building and parameter formatting
- Verify API key in `APIConfig.swift` is correct
- Use Xcode's network debugger to inspect requests

### Testing Motion Effects
- Must test on physical device (iPhone/iPad)
- `MotionManager` publishes `roll` and `pitch` in radians
- Tilt device gently; UI should respond smoothly at ~60 Hz

### Modifying API Response Handling
- Update `APODResponse` struct in `APODModel.swift` if NASA adds/changes fields
- Update `CodingKeys` enum if JSON key names change
- Error handling in `APODViewModel` catches decode failures and surfaces in `errorMessage`

## Code Style Notes

- **Naming**: camelCase for variables/functions, PascalCase for types
- **Combine**: Use `sink()` for simple subscriptions; `@Published` properties are preferred over manual `PassthroughSubject`
- **SwiftUI**: Use `@StateObject` for view-owned state, `@ObservedObject` / `@EnvironmentObject` for external state
- **Motion**: All motion updates happen on main queue (`DispatchQueue.main`); safe to update UI directly

## Testing Considerations

- **Simulator**: API calls work; motion effects disabled
- **Physical Device**: All features work; gyroscope required for motion
- **Edge Cases**: Invalid dates, network failures (handled with `errorMessage`), missing media (videos show "Watch Video" button)

## Performance Notes

- Motion updates run at 60 Hz (`deviceMotionUpdateInterval = 1/60`)
- Network requests are cancellable via Combine's `cancellables` set
- UI responds immediately to motion without blocking (uses `@Published` properties)
