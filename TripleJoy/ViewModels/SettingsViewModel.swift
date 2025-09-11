import Foundation
import SwiftUI

class SettingsViewModel: ObservableObject {
    @Published var settings = GameSettings()
    
    private let userDefaults = UserDefaults.standard
    private let settingsKey = "gameSettings"
    
    init() {
        loadSettings()
    }
    
    // MARK: - Settings Management
    
    private func loadSettings() {
        if let data = userDefaults.data(forKey: settingsKey),
           let decodedSettings = try? JSONDecoder().decode(GameSettings.self, from: data) {
            settings = decodedSettings
        }
    }
    
    private func saveSettings() {
        if let data = try? JSONEncoder().encode(settings) {
            userDefaults.set(data, forKey: settingsKey)
        }
    }
    
    // MARK: - Settings Actions
    
    func toggleSound() {
        settings.soundEnabled.toggle()
        saveSettings()
    }
    
    func toggleMusic() {
        settings.musicEnabled.toggle()
        saveSettings()
    }
    
    func setDifficulty(_ difficulty: DifficultyLevel) {
        settings.difficulty = difficulty
        saveSettings()
    }
    
    func completeOnboarding() {
        settings.hasCompletedOnboarding = true
        saveSettings()
    }
    
    func setColorScheme(_ colorScheme: ColorScheme) {
        settings.colorScheme = colorScheme
        saveSettings()
    }
    
    func resetProgress() {
        // Reset all game progress
        userDefaults.removeObject(forKey: "achievements")
        userDefaults.removeObject(forKey: "totalScore")
        userDefaults.removeObject(forKey: "levelsCompleted")
        
        // Reset settings to default
        settings = GameSettings()
        saveSettings()
        
        // Trigger haptic feedback
        let impactFeedback = UIImpactFeedbackGenerator(style: .heavy)
        impactFeedback.impactOccurred()
    }
    
    // MARK: - Computed Properties
    
    var isOnboardingCompleted: Bool {
        settings.hasCompletedOnboarding
    }
    
    var currentDifficulty: DifficultyLevel {
        settings.difficulty
    }
    
    var isSoundEnabled: Bool {
        settings.soundEnabled
    }
    
    var isMusicEnabled: Bool {
        settings.musicEnabled
    }
    
    var currentColorScheme: ColorScheme {
        settings.colorScheme
    }
}
