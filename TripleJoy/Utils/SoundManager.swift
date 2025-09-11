import AVFoundation
import UIKit

class SoundManager: ObservableObject {
    static let shared = SoundManager()
    
    private var audioPlayers: [String: AVAudioPlayer] = [:]
    private var isSoundEnabled = true
    private var isMusicEnabled = true
    
    private init() {
        setupAudioSession()
        loadSettings()
    }
    
    // MARK: - Audio Session Setup
    
    private func setupAudioSession() {
        do {
            try AVAudioSession.sharedInstance().setCategory(.ambient, mode: .default)
            try AVAudioSession.sharedInstance().setActive(true)
        } catch {
            print("Failed to setup audio session: \(error)")
        }
    }
    
    // MARK: - Settings
    
    private func loadSettings() {
        let userDefaults = UserDefaults.standard
        isSoundEnabled = userDefaults.bool(forKey: "soundEnabled")
        isMusicEnabled = userDefaults.bool(forKey: "musicEnabled")
    }
    
    func updateSoundSettings(soundEnabled: Bool, musicEnabled: Bool) {
        isSoundEnabled = soundEnabled
        isMusicEnabled = musicEnabled
        
        let userDefaults = UserDefaults.standard
        userDefaults.set(soundEnabled, forKey: "soundEnabled")
        userDefaults.set(musicEnabled, forKey: "musicEnabled")
    }
    
    // MARK: - Sound Effects
    
    func playMatchSound() {
        guard isSoundEnabled else { return }
        playSound(named: "match", volume: 0.3)
    }
    
    func playSwapSound() {
        guard isSoundEnabled else { return }
        playSound(named: "swap", volume: 0.2)
    }
    
    func playLevelCompleteSound() {
        guard isSoundEnabled else { return }
        playSound(named: "level_complete", volume: 0.5)
    }
    
    func playButtonSound() {
        guard isSoundEnabled else { return }
        playSound(named: "button", volume: 0.1)
    }
    
    func playAchievementSound() {
        guard isSoundEnabled else { return }
        playSound(named: "achievement", volume: 0.4)
    }
    
    func playGameOverSound() {
        guard isSoundEnabled else { return }
        playSound(named: "game_over", volume: 0.3)
    }
    
    // MARK: - Private Methods
    
    private func playSound(named: String, volume: Float) {
        // Временно используем системные звуки вместо файлов
        switch named {
        case "match":
            playSystemSound(1104) // Pop sound
        case "swap":
            playSystemSound(1103) // Tock sound
        case "level_complete":
            playSystemSound(1057) // Success sound
        case "button":
            playSystemSound(1104) // Pop sound
        case "achievement":
            playSystemSound(1057) // Success sound
        case "game_over":
            playSystemSound(1005) // Error sound
        default:
            playSystemSound(1104) // Default pop sound
        }
    }
    
    private func playSystemSound(_ soundID: SystemSoundID = 1104) {
        // Use system sound as fallback
        AudioServicesPlaySystemSound(soundID)
    }
    
    // MARK: - Haptic Feedback
    
    func playHapticFeedback(_ style: UIImpactFeedbackGenerator.FeedbackStyle = .medium) {
        let impactFeedback = UIImpactFeedbackGenerator(style: style)
        impactFeedback.impactOccurred()
    }
    
    func playSuccessHaptic() {
        let notificationFeedback = UINotificationFeedbackGenerator()
        notificationFeedback.notificationOccurred(.success)
    }
    
    func playErrorHaptic() {
        let notificationFeedback = UINotificationFeedbackGenerator()
        notificationFeedback.notificationOccurred(.error)
    }
    
    func playWarningHaptic() {
        let notificationFeedback = UINotificationFeedbackGenerator()
        notificationFeedback.notificationOccurred(.warning)
    }
}

// MARK: - Sound Effects Extension

extension SoundManager {
    func playGemMatch() {
        playMatchSound()
        playHapticFeedback(.light)
    }
    
    func playGemSwap() {
        playSwapSound()
        playHapticFeedback(.medium)
    }
    
    func playLevelComplete() {
        playLevelCompleteSound()
        playSuccessHaptic()
    }
    
    func playAchievementUnlock() {
        playAchievementSound()
        playSuccessHaptic()
    }
    
    func playButtonTap() {
        playButtonSound()
        playHapticFeedback(.light)
    }
    
    func playGameOver() {
        playGameOverSound()
        playErrorHaptic()
    }
}
