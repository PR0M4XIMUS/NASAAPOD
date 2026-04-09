import SwiftUI

// Settings view for app configuration
struct SettingsView: View {
    @Environment(\.dismiss) var dismiss
    @State private var settings = PersistenceService.shared.getSettings()
    @State private var hasChanges = false

    var body: some View {
        NavigationView {
            ZStack {
                Color.black.edgesIgnoringSafeArea(.all)

                ScrollView {
                    VStack(alignment: .leading, spacing: AppTheme.standardPadding) {
                        // Glass Effect Section
                        VStack(alignment: .leading, spacing: AppTheme.mediumPadding) {
                            Text("Glass Effect")
                                .font(.headline)
                                .fontWeight(.semibold)
                                .foregroundColor(.white)

                            VStack(alignment: .leading, spacing: AppTheme.smallPadding) {
                                Text("Intensity")
                                    .font(.subheadline)
                                    .foregroundColor(.white.opacity(AppTheme.secondaryTextOpacity))

                                HStack(spacing: AppTheme.mediumPadding) {
                                    Slider(
                                        value: $settings.glassEffectIntensity,
                                        in: 0.1...1.0,
                                        step: 0.1,
                                        onEditingChanged: { _ in
                                            hasChanges = true
                                        }
                                    )
                                    .tint(AppTheme.accentColor)

                                    Text(String(format: "%.0f%%", settings.glassEffectIntensity * 100))
                                        .font(.caption)
                                        .foregroundColor(.white.opacity(AppTheme.secondaryTextOpacity))
                                        .frame(minWidth: 35)
                                }
                            }
                            .padding(AppTheme.standardPadding)
                            .glassBackground(cornerRadius: AppTheme.standardCornerRadius, intensity: 0.9, useMotion: false)
                        }

                        // Motion Effects Section
                        VStack(alignment: .leading, spacing: AppTheme.mediumPadding) {
                            Text("Motion & Effects")
                                .font(.headline)
                                .fontWeight(.semibold)
                                .foregroundColor(.white)

                            Toggle("Enable Motion Effects", isOn: $settings.enableMotionEffects)
                                .tint(AppTheme.accentColor)
                                .onChange(of: settings.enableMotionEffects) { _ in
                                    hasChanges = true
                                }
                                .padding(AppTheme.standardPadding)
                                .glassBackground(cornerRadius: AppTheme.standardCornerRadius, intensity: 0.9, useMotion: false)

                            Text("Device tilt will affect glass border and shadows (requires gyroscope)")
                                .font(.caption)
                                .foregroundColor(.white.opacity(AppTheme.tertiaryTextOpacity))
                                .padding(.horizontal, AppTheme.mediumPadding)
                        }

                        // Image Preferences Section
                        VStack(alignment: .leading, spacing: AppTheme.mediumPadding) {
                            Text("Image Preferences")
                                .font(.headline)
                                .fontWeight(.semibold)
                                .foregroundColor(.white)

                            Toggle("Prefer High Resolution", isOn: $settings.preferHighResolution)
                                .tint(AppTheme.accentColor)
                                .onChange(of: settings.preferHighResolution) { _ in
                                    hasChanges = true
                                }
                                .padding(AppTheme.standardPadding)
                                .glassBackground(cornerRadius: AppTheme.standardCornerRadius, intensity: 0.9, useMotion: false)

                            Text("Uses more data but displays higher quality images")
                                .font(.caption)
                                .foregroundColor(.white.opacity(AppTheme.tertiaryTextOpacity))
                                .padding(.horizontal, AppTheme.mediumPadding)
                        }

                        // Offline & Notifications Section
                        VStack(alignment: .leading, spacing: AppTheme.mediumPadding) {
                            Text("Features")
                                .font(.headline)
                                .fontWeight(.semibold)
                                .foregroundColor(.white)

                            Toggle("Allow Offline Content", isOn: $settings.allowOfflineContent)
                                .tint(AppTheme.accentColor)
                                .onChange(of: settings.allowOfflineContent) { _ in
                                    hasChanges = true
                                }
                                .padding(AppTheme.standardPadding)
                                .glassBackground(cornerRadius: AppTheme.standardCornerRadius, intensity: 0.9, useMotion: false)

                            Text("Allows viewing previously loaded APODs when offline")
                                .font(.caption)
                                .foregroundColor(.white.opacity(AppTheme.tertiaryTextOpacity))
                                .padding(.horizontal, AppTheme.mediumPadding)

                            Toggle("Show Notifications", isOn: $settings.showNotifications)
                                .tint(AppTheme.accentColor)
                                .onChange(of: settings.showNotifications) { _ in
                                    hasChanges = true
                                }
                                .padding(AppTheme.standardPadding)
                                .glassBackground(cornerRadius: AppTheme.standardCornerRadius, intensity: 0.9, useMotion: false)

                            Text("Receive notifications for new daily APODs")
                                .font(.caption)
                                .foregroundColor(.white.opacity(AppTheme.tertiaryTextOpacity))
                                .padding(.horizontal, AppTheme.mediumPadding)
                        }

                        // About Section
                        VStack(alignment: .leading, spacing: AppTheme.mediumPadding) {
                            Text("About")
                                .font(.headline)
                                .fontWeight(.semibold)
                                .foregroundColor(.white)

                            VStack(alignment: .leading, spacing: AppTheme.smallPadding) {
                                Text("NASA APOD Explorer")
                                    .font(.subheadline)
                                    .fontWeight(.semibold)
                                    .foregroundColor(.white)

                                Text("Version 2.0")
                                    .font(.caption)
                                    .foregroundColor(.white.opacity(AppTheme.secondaryTextOpacity))

                                Text("Powered by NASA's Astronomy Picture of the Day API")
                                    .font(.caption)
                                    .foregroundColor(.white.opacity(AppTheme.tertiaryTextOpacity))
                                    .lineSpacing(2)
                            }
                            .padding(AppTheme.standardPadding)
                            .glassBackground(cornerRadius: AppTheme.standardCornerRadius, intensity: 0.9, useMotion: false)
                        }

                        Spacer(minLength: AppTheme.standardPadding)
                    }
                    .padding(AppTheme.mediumPadding)
                }
            }
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        if hasChanges {
                            PersistenceService.shared.saveSettings(settings)
                        }
                        dismiss()
                    }
                    .fontWeight(.semibold)
                    .foregroundColor(AppTheme.accentColor)
                }
            }
        }
    }
}

#Preview {
    SettingsView()
        .preferredColorScheme(.dark)
        .environmentObject(MotionManager())
}
