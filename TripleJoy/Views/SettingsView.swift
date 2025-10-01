//
//  SettingsView.swift
//  TripleJoy
//
//  Created by Jack Foster on 10.09.2025.
//

import SwiftUI
import StoreKit

struct SettingsView: View {
    @StateObject private var settingsViewModel = SettingsViewModel()
    @State private var showingResetAlert = false
    @State private var showingDifficultyAlert = false
    
    var body: some View {
        NavigationView {
            ZStack {
                // Background
                AnimatedBackground()
                    .ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 20) {
                        // Audio Settings
                        audioSettingsSection
                        
                        // Appearance Settings
                        appearanceSettingsSection
                        
                        // Game Settings
                        gameSettingsSection
                        
                        // Data Management
                        dataManagementSection
                        
                        // App Actions
                        appActionsSection
                        
                        // App Info
                        appInfoSection
                    }
                    .padding()
                }
            }
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.large)
        }
        .alert("Reset All Data", isPresented: $showingResetAlert) {
            Button("Cancel", role: .cancel) { }
            Button("Reset", role: .destructive) {
                settingsViewModel.resetProgress()
            }
        } message: {
            Text("This will reset all your game progress, achievements, and settings. This action cannot be undone.")
        }
        .alert("Difficulty Changed", isPresented: $showingDifficultyAlert) {
            Button("OK") { }
        } message: {
            Text("Difficulty has been changed to \(settingsViewModel.currentDifficulty.rawValue). This will affect new games.")
        }
    }
    
    // MARK: - App Actions
    
    private func rateApp() {
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene {
            SKStoreReviewController.requestReview(in: windowScene)
        }
    }
    
    private func openPrivacyPolicy() {
        // Открываем политику конфиденциальности
        if let url = URL(string: "https://www.termsfeed.com/live/c86db12b-809e-42f8-b16d-cfd5b1ee5dfe") {
            UIApplication.shared.open(url)
        } else {
            // Fallback - показываем алерт
            showAlert(title: "Privacy Policy", message: "Privacy Policy: We respect your privacy and do not collect personal data. All game progress is stored locally on your device.")
        }
    }
    
    private func showAlert(title: String, message: String) {
        // Показываем алерт с информацией
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let window = windowScene.windows.first {
            window.rootViewController?.present(alert, animated: true)
        }
    }
    
    // MARK: - Audio Settings Section
    
    private var audioSettingsSection: some View {
        VStack(alignment: .leading, spacing: 15) {
            SectionHeaderView(title: "Audio", icon: "speaker.wave.2.fill", color: .blue)
                .foregroundStyle(.white)
            
            VStack(spacing: 0) {
                SettingsRowView(
                    title: "Sound Effects",
                    icon: "speaker.fill",
                    trailing: {
                        Toggle("", isOn: Binding(
                            get: { settingsViewModel.isSoundEnabled },
                            set: { _ in settingsViewModel.toggleSound() }
                        ))
                        .toggleStyle(SwitchToggleStyle(tint: .blue))
                    }
                )
                
                Divider()
                    .padding(.leading, 50)
                
                SettingsRowView(
                    title: "Background Music",
                    icon: "music.note",
                    trailing: {
                        Toggle("", isOn: Binding(
                            get: { settingsViewModel.isMusicEnabled },
                            set: { _ in settingsViewModel.toggleMusic() }
                        ))
                        .toggleStyle(SwitchToggleStyle(tint: .blue))
                    }
                )
            }
            .background(Color(.systemBackground))
            .cornerRadius(12)
            .shadow(radius: 2)
        }
    }
    
    // MARK: - Appearance Settings Section
    
    private var appearanceSettingsSection: some View {
        VStack(alignment: .leading, spacing: 15) {
            SectionHeaderView(title: "Appearance", icon: "paintbrush.fill", color: .purple)
                .foregroundStyle(.white)
            
            VStack(spacing: 0) {
                SettingsRowView(
                    title: "Color Scheme",
                    icon: "moon.fill",
                    trailing: {
                        Button(settingsViewModel.currentColorScheme.rawValue) {
                            // Cycle through color schemes
                            let currentIndex = ColorScheme.allCases.firstIndex(of: settingsViewModel.currentColorScheme) ?? 0
                            let nextIndex = (currentIndex + 1) % ColorScheme.allCases.count
                            settingsViewModel.setColorScheme(ColorScheme.allCases[nextIndex])
                        }
                        .foregroundColor(.blue)
                    }
                )
            }
            .background(Color(.systemBackground))
            .cornerRadius(12)
            .shadow(radius: 2)
        }
    }
    
    // MARK: - Game Settings Section
    
    private var gameSettingsSection: some View {
        VStack(alignment: .leading, spacing: 15) {
            SectionHeaderView(title: "Game", icon: "gamecontroller.fill", color: .green)
                .foregroundStyle(.white)
            
            VStack(spacing: 0) {
                SettingsRowView(
                    title: "Difficulty",
                    icon: "slider.horizontal.3",
                    trailing: {
                        Button(settingsViewModel.currentDifficulty.rawValue) {
                            showingDifficultyAlert = true
                        }
                        .foregroundColor(.blue)
                    }
                )
                
                Divider()
                    .padding(.leading, 50)
                
                NavigationLink(destination: DifficultySelectionView(settingsViewModel: settingsViewModel)) {
                    SettingsRowView(
                        title: "Change Difficulty",
                        icon: "gear",
                        trailing: {
                            Image(systemName: "chevron.right")
                                .foregroundColor(.secondary)
                                .font(.caption)
                        }
                    )
                }
                .buttonStyle(PlainButtonStyle())
            }
            .background(Color(.systemBackground))
            .cornerRadius(12)
            .shadow(radius: 2)
        }
    }
    
    // MARK: - Data Management Section
    
    private var dataManagementSection: some View {
        VStack(alignment: .leading, spacing: 15) {
            SectionHeaderView(title: "Data", icon: "externaldrive.fill", color: .orange)
                .foregroundStyle(.white)
            
            VStack(spacing: 0) {
                SettingsRowView(
                    title: "Reset Progress",
                    icon: "trash.fill",
                    trailing: {
                        Button("Reset") {
                            showingResetAlert = true
                        }
                        .foregroundColor(.red)
                    }
                )
            }
            .background(Color(.systemBackground))
            .cornerRadius(12)
            .shadow(radius: 2)
        }
    }
    
    // MARK: - App Actions Section
    
    private var appActionsSection: some View {
        VStack(alignment: .leading, spacing: 15) {
            SectionHeaderView(title: "App Actions", icon: "star.fill", color: .yellow)
                .foregroundStyle(.white)
            
            VStack(spacing: 0) {
                Button(action: {
                    rateApp()
                }) {
                    SettingsRowView(
                        title: "Rate App",
                        icon: "star.fill",
                        trailing: {
                            Image(systemName: "chevron.right")
                                .foregroundColor(.secondary)
                                .font(.caption)
                        }
                    )
                }
                .buttonStyle(PlainButtonStyle())
                
                Divider()
                    .padding(.leading, 50)
                
                Button(action: {
                    openPrivacyPolicy()
                }) {
                    SettingsRowView(
                        title: "Privacy Policy",
                        icon: "doc.text.fill",
                        trailing: {
                            Image(systemName: "chevron.right")
                                .foregroundColor(.secondary)
                                .font(.caption)
                        }
                    )
                }
                .buttonStyle(PlainButtonStyle())
            }
            .background(Color(.systemBackground))
            .cornerRadius(12)
            .shadow(radius: 2)
        }
    }
    
    // MARK: - App Info Section
    
    private var appInfoSection: some View {
        VStack(alignment: .leading, spacing: 15) {
            SectionHeaderView(title: "About", icon: "info.circle.fill", color: .purple)
                .foregroundStyle(.white)
            
            VStack(spacing: 0) {
                SettingsRowView(
                    title: "Version",
                    icon: "app.badge",
                    trailing: {
                        Text("1.0.0")
                            .foregroundColor(.secondary)
                    }
                )
                
                Divider()
                    .padding(.leading, 50)
                
                SettingsRowView(
                    title: "TripleJoy",
                    icon: "sparkles",
                    trailing: {
                        Text("Match-3 Game")
                            .foregroundColor(.secondary)
                    }
                )
            }
            .background(Color(.systemBackground))
            .cornerRadius(12)
            .shadow(radius: 2)
        }
    }
}

// MARK: - Section Header View

struct SectionHeaderView: View {
    let title: String
    let icon: String
    let color: Color
    
    var body: some View {
        HStack(spacing: 10) {
            Image(systemName: icon)
                .foregroundColor(color)
                .font(.title3)
            
            Text(title)
                .font(.headline)
                .fontWeight(.semibold)
        }
    }
}

// MARK: - Settings Row View

struct SettingsRowView<Content: View>: View {
    let title: String
    let icon: String
    let trailing: () -> Content
    
    var body: some View {
        HStack(spacing: 15) {
            Image(systemName: icon)
                .foregroundColor(.blue)
                .frame(width: 20)
            
            Text(title)
                .font(.body)
            
            Spacer()
            
            trailing()
        }
        .padding()
    }
}

// MARK: - Difficulty Selection View

struct DifficultySelectionView: View {
    @ObservedObject var settingsViewModel: SettingsViewModel
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        VStack(spacing: 20) {
            Text("Select Difficulty")
                .font(.largeTitle)
                .fontWeight(.bold)
                .padding(.top)
            
            VStack(spacing: 15) {
                ForEach(DifficultyLevel.allCases, id: \.self) { difficulty in
                    DifficultyCard(
                        difficulty: difficulty,
                        isSelected: settingsViewModel.currentDifficulty == difficulty,
                        onTap: {
                            settingsViewModel.setDifficulty(difficulty)
                            dismiss()
                        }
                    )
                }
            }
            .padding()
            
            Spacer()
        }
        .navigationTitle("Difficulty")
        .navigationBarTitleDisplayMode(.inline)
    }
}

// MARK: - Difficulty Card View

struct DifficultyCard: View {
    let difficulty: DifficultyLevel
    let isSelected: Bool
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            VStack(alignment: .leading, spacing: 10) {
                HStack {
                    Text(difficulty.rawValue)
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.primary)
                    
                    Spacer()
                    
                    if isSelected {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundColor(.blue)
                            .font(.title2)
                    }
                }
                
                VStack(alignment: .leading, spacing: 5) {
                    Text("Grid Size: \(difficulty.gridSize)x\(difficulty.gridSize)")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    
                    Text("Time Limit: \(difficulty.timeLimit / 60) minutes")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
            }
            .padding()
            .background(isSelected ? Color.blue.opacity(0.1) : Color(.systemBackground))
            .cornerRadius(12)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(isSelected ? Color.blue : Color.clear, lineWidth: 2)
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// MARK: - Preview

#Preview {
    SettingsView()
}
