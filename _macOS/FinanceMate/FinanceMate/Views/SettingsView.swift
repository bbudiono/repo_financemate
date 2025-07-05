import SwiftUI

/**
 * SettingsView.swift
 * 
 * Purpose: SwiftUI view for application settings and user preferences
 * Issues & Complexity Summary: Glassmorphism UI with theme, currency, and notification controls
 * Key Complexity Drivers:
 *   - Logic Scope (Est. LoC): ~300
 *   - Core Algorithm Complexity: Medium (Form controls and validation)
 *   - Dependencies: 3 New (SwiftUI, SettingsViewModel, GlassmorphismModifier)
 *   - State Management Complexity: Medium (Multiple preference bindings)
 *   - Novelty/Uncertainty Factor: Low (Established UI patterns)
 * AI Pre-Task Self-Assessment: 85%
 * Problem Estimate: 80%
 * Initial Code Complexity Estimate: 75%
 * Final Code Complexity: 82%
 * Overall Result Score: 88%
 * Key Variances/Learnings: Glassmorphism integration smoother than expected
 * Last Updated: 2025-07-05
 */

struct SettingsView: View {
    @EnvironmentObject var settingsViewModel: SettingsViewModel
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // Background gradient
                LinearGradient(
                    gradient: Gradient(colors: [
                        colorScheme == .dark ? 
                            Color.black.opacity(0.9) : Color.white.opacity(0.9),
                        colorScheme == .dark ? 
                            Color.blue.opacity(0.3) : Color.blue.opacity(0.1)
                    ]),
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 20) {
                        // Header
                        headerSection
                        
                        // Theme Settings
                        themeSection
                        
                        // Currency Settings
                        currencySection
                        
                        // Notification Settings
                        notificationSection
                        
                        // Actions Section
                        actionsSection
                        
                        Spacer()
                    }
                    .padding()
                }
            }
        }
        .navigationTitle("Settings")
        .navigationBarTitleDisplayMode(.large)
        .preferredColorScheme(settingsViewModel.applyTheme())
        .accessibilityIdentifier("SettingsView")
    }
    
    // MARK: - Header Section
    
    private var headerSection: some View {
        VStack(spacing: 12) {
            Image(systemName: "gearshape.fill")
                .font(.system(size: 50))
                .foregroundColor(.blue)
                .accessibilityIdentifier("SettingsIcon")
            
            Text("Application Settings")
                .font(.largeTitle)
                .fontWeight(.bold)
                .foregroundColor(.primary)
            
            Text("Customize your FinanceMate experience")
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
        .modifier(GlassmorphismModifier(.primary))
        .accessibilityIdentifier("SettingsHeader")
    }
    
    // MARK: - Theme Section
    
    private var themeSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Image(systemName: "paintbrush.fill")
                    .foregroundColor(.purple)
                Text("Theme")
                    .font(.headline)
                    .fontWeight(.semibold)
                Spacer()
            }
            
            VStack(spacing: 12) {
                ForEach(SettingsViewModel.availableThemes, id: \.self) { theme in
                    themeRow(theme: theme)
                }
            }
        }
        .modifier(GlassmorphismModifier(.secondary))
        .accessibilityIdentifier("ThemeSection")
    }
    
    private func themeRow(theme: String) -> some View {
        HStack {
            Circle()
                .fill(settingsViewModel.theme == theme ? Color.blue : Color.clear)
                .frame(width: 20, height: 20)
                .overlay(
                    Circle()
                        .stroke(Color.blue, lineWidth: 2)
                )
                .accessibilityIdentifier("ThemeSelector_\(theme)")
            
            VStack(alignment: .leading, spacing: 2) {
                Text(theme)
                    .font(.body)
                    .fontWeight(.medium)
                
                Text(themeDescription(for: theme))
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            if settingsViewModel.theme == theme {
                Image(systemName: "checkmark")
                    .foregroundColor(.blue)
                    .font(.body)
                    .fontWeight(.semibold)
            }
        }
        .contentShape(Rectangle())
        .onTapGesture {
            withAnimation(.easeInOut(duration: 0.3)) {
                settingsViewModel.theme = theme
            }
        }
        .accessibilityIdentifier("ThemeRow_\(theme)")
        .accessibilityLabel("Theme option: \(theme)")
        .accessibilityHint("Tap to select \(theme) theme")
    }
    
    private func themeDescription(for theme: String) -> String {
        switch theme {
        case "System":
            return "Follow system appearance"
        case "Light":
            return "Always use light mode"
        case "Dark":
            return "Always use dark mode"
        default:
            return "Unknown theme"
        }
    }
    
    // MARK: - Currency Section
    
    private var currencySection: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Image(systemName: "dollarsign.circle.fill")
                    .foregroundColor(.green)
                Text("Currency")
                    .font(.headline)
                    .fontWeight(.semibold)
                Spacer()
            }
            
            LazyVGrid(columns: [
                GridItem(.flexible()),
                GridItem(.flexible()),
                GridItem(.flexible())
            ], spacing: 12) {
                ForEach(SettingsViewModel.availableCurrencies, id: \.self) { currency in
                    currencyCard(currency: currency)
                }
            }
        }
        .modifier(GlassmorphismModifier(.secondary))
        .accessibilityIdentifier("CurrencySection")
    }
    
    private func currencyCard(currency: String) -> some View {
        VStack(spacing: 8) {
            Text(settingsViewModel.currencySymbol())
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(settingsViewModel.currency == currency ? .white : .primary)
            
            Text(currency)
                .font(.caption)
                .fontWeight(.medium)
                .foregroundColor(settingsViewModel.currency == currency ? .white : .secondary)
        }
        .frame(height: 60)
        .frame(maxWidth: .infinity)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(settingsViewModel.currency == currency ? 
                      Color.blue.gradient : Color.clear)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(settingsViewModel.currency == currency ? 
                       Color.blue : Color.gray.opacity(0.3), lineWidth: 1)
        )
        .contentShape(Rectangle())
        .onTapGesture {
            withAnimation(.easeInOut(duration: 0.3)) {
                settingsViewModel.currency = currency
            }
        }
        .accessibilityIdentifier("CurrencyCard_\(currency)")
        .accessibilityLabel("Currency: \(currency)")
        .accessibilityHint("Tap to select \(currency) as default currency")
    }
    
    // MARK: - Notification Section
    
    private var notificationSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Image(systemName: "bell.fill")
                    .foregroundColor(.orange)
                Text("Notifications")
                    .font(.headline)
                    .fontWeight(.semibold)
                Spacer()
            }
            
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Enable Notifications")
                        .font(.body)
                        .fontWeight(.medium)
                    
                    Text("Receive alerts and reminders")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                Toggle("", isOn: $settingsViewModel.notifications)
                    .toggleStyle(SwitchToggleStyle(tint: .blue))
                    .accessibilityIdentifier("NotificationToggle")
                    .accessibilityLabel("Enable notifications")
            }
        }
        .modifier(GlassmorphismModifier(.secondary))
        .accessibilityIdentifier("NotificationSection")
    }
    
    // MARK: - Actions Section
    
    private var actionsSection: some View {
        VStack(spacing: 16) {
            // Reset Settings Button
            Button(action: {
                withAnimation(.easeInOut(duration: 0.5)) {
                    settingsViewModel.resetSettings()
                }
            }) {
                HStack {
                    Image(systemName: "arrow.clockwise")
                        .font(.body)
                        .fontWeight(.semibold)
                    
                    Text("Reset to Defaults")
                        .font(.body)
                        .fontWeight(.semibold)
                }
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .frame(height: 50)
                .background(
                    LinearGradient(
                        gradient: Gradient(colors: [Color.red, Color.red.opacity(0.8)]),
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
                .cornerRadius(12)
            }
            .accessibilityIdentifier("ResetSettingsButton")
            .accessibilityLabel("Reset all settings to default values")
            
            // Save Settings Button
            Button(action: {
                settingsViewModel.saveSettings()
            }) {
                HStack {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.body)
                        .fontWeight(.semibold)
                    
                    Text("Save Settings")
                        .font(.body)
                        .fontWeight(.semibold)
                }
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .frame(height: 50)
                .background(
                    LinearGradient(
                        gradient: Gradient(colors: [Color.green, Color.green.opacity(0.8)]),
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
                .cornerRadius(12)
            }
            .accessibilityIdentifier("SaveSettingsButton")
            .accessibilityLabel("Save current settings")
        }
        .modifier(GlassmorphismModifier(.minimal))
        .accessibilityIdentifier("ActionsSection")
    }
}

// MARK: - Preview

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            NavigationView {
                SettingsView()
                    .environmentObject(SettingsViewModel())
            }
            .preferredColorScheme(.light)
            .previewDisplayName("Light Mode")
            
            NavigationView {
                SettingsView()
                    .environmentObject(SettingsViewModel())
            }
            .preferredColorScheme(.dark)
            .previewDisplayName("Dark Mode")
            
            NavigationView {
                SettingsView()
                    .environmentObject({
                        let vm = SettingsViewModel()
                        vm.theme = "Dark"
                        vm.currency = "EUR"
                        vm.notifications = false
                        return vm
                    }())
            }
            .preferredColorScheme(.dark)
            .previewDisplayName("Custom Settings")
        }
    }
}