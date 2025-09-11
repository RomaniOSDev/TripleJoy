import Foundation
import SwiftUI

class AchievementsViewModel: ObservableObject {
    @Published var achievements: [Achievement] = []
    @Published var totalScore: Int = 0
    @Published var levelsCompleted: Int = 0
    
    private let userDefaults = UserDefaults.standard
    private let achievementsKey = "achievements"
    private let totalScoreKey = "totalScore"
    private let levelsCompletedKey = "levelsCompleted"
    
    init() {
        loadData()
        setupDefaultAchievements()
    }
    
    // MARK: - Data Management
    
    private func loadData() {
        totalScore = userDefaults.integer(forKey: totalScoreKey)
        levelsCompleted = userDefaults.integer(forKey: levelsCompletedKey)
        
        if let data = userDefaults.data(forKey: achievementsKey),
           let decodedAchievements = try? JSONDecoder().decode([Achievement].self, from: data) {
            achievements = decodedAchievements
        }
    }
    
    private func saveData() {
        userDefaults.set(totalScore, forKey: totalScoreKey)
        userDefaults.set(levelsCompleted, forKey: levelsCompletedKey)
        
        if let data = try? JSONEncoder().encode(achievements) {
            userDefaults.set(data, forKey: achievementsKey)
        }
    }
    
    private func setupDefaultAchievements() {
        if achievements.isEmpty {
            achievements = [
                Achievement(
                    title: "First Steps",
                    description: "Complete your first level",
                    icon: "star.fill",
                    targetValue: 1
                ),
                Achievement(
                    title: "Score Master",
                    description: "Reach 1000 points in total",
                    icon: "trophy.fill",
                    targetValue: 1000
                ),
                Achievement(
                    title: "Level Hunter",
                    description: "Complete 10 levels",
                    icon: "gamecontroller.fill",
                    targetValue: 10
                ),
                Achievement(
                    title: "Gem Collector",
                    description: "Collect 100 gems in total",
                    icon: "diamond.fill",
                    targetValue: 100
                ),
                Achievement(
                    title: "Speed Demon",
                    description: "Complete a level in under 60 seconds",
                    icon: "bolt.fill",
                    targetValue: 1
                ),
                Achievement(
                    title: "Perfectionist",
                    description: "Complete 5 levels without pausing",
                    icon: "checkmark.circle.fill",
                    targetValue: 5
                ),
                Achievement(
                    title: "High Scorer",
                    description: "Score 500 points in a single level",
                    icon: "crown.fill",
                    targetValue: 500
                ),
                Achievement(
                    title: "Dedicated Player",
                    description: "Complete 25 levels",
                    icon: "medal.fill",
                    targetValue: 25
                )
            ]
            saveData()
        }
    }
    
    // MARK: - Achievement Updates
    
    func updateScore(_ newScore: Int) {
        totalScore += newScore
        checkAchievements()
        saveData()
    }
    
    func completeLevel() {
        levelsCompleted += 1
        checkAchievements()
        saveData()
    }
    
    func collectGems(_ count: Int) {
        // This would be called when gems are collected
        // For now, we'll simulate it based on score
        let gemsCollected = count
        updateAchievementProgress(for: "Gem Collector", by: gemsCollected)
    }
    
    func completeLevelInTime(_ timeInSeconds: Int) {
        if timeInSeconds <= 60 {
            updateAchievementProgress(for: "Speed Demon", by: 1)
        }
    }
    
    func completeLevelWithoutPause() {
        updateAchievementProgress(for: "Perfectionist", by: 1)
    }
    
    func scoreInSingleLevel(_ score: Int) {
        if score >= 500 {
            updateAchievementProgress(for: "High Scorer", by: 1)
        }
    }
    
    private func checkAchievements() {
        for i in 0..<achievements.count {
            var achievement = achievements[i]
            
            switch achievement.title {
            case "First Steps":
                if levelsCompleted >= 1 && !achievement.isUnlocked {
                    unlockAchievement(at: i)
                }
            case "Score Master":
                if totalScore >= 1000 && !achievement.isUnlocked {
                    unlockAchievement(at: i)
                }
            case "Level Hunter":
                if levelsCompleted >= 10 && !achievement.isUnlocked {
                    unlockAchievement(at: i)
                }
            case "Dedicated Player":
                if levelsCompleted >= 25 && !achievement.isUnlocked {
                    unlockAchievement(at: i)
                }
            default:
                break
            }
        }
    }
    
    private func updateAchievementProgress(for title: String, by amount: Int) {
        if let index = achievements.firstIndex(where: { $0.title == title }) {
            achievements[index].currentValue += amount
            if achievements[index].currentValue >= achievements[index].targetValue && !achievements[index].isUnlocked {
                unlockAchievement(at: index)
            }
            saveData()
        }
    }
    
    private func unlockAchievement(at index: Int) {
        achievements[index].isUnlocked = true
        achievements[index].unlockedDate = Date()
        
        // Trigger haptic feedback
        let impactFeedback = UIImpactFeedbackGenerator(style: .medium)
        impactFeedback.impactOccurred()
    }
    
    // MARK: - Reset Progress
    
    func resetAllProgress() {
        totalScore = 0
        levelsCompleted = 0
        
        for i in 0..<achievements.count {
            achievements[i].currentValue = 0
            achievements[i].isUnlocked = false
            achievements[i].unlockedDate = nil
        }
        
        saveData()
    }
    
    // MARK: - Statistics
    
    var unlockedAchievementsCount: Int {
        achievements.filter { $0.isUnlocked }.count
    }
    
    var totalAchievementsCount: Int {
        achievements.count
    }
    
    var completionPercentage: Double {
        guard totalAchievementsCount > 0 else { return 0 }
        return Double(unlockedAchievementsCount) / Double(totalAchievementsCount)
    }
}
