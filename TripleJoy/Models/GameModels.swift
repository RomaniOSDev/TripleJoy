import Foundation
import UIKit

// MARK: - Game Models

enum GemType: String, CaseIterable {
    case red = "red"
    case blue = "blue"
    case green = "green"
    case yellow = "yellow"
    case purple = "purple"
    case orange = "orange"
    
    var color: String {
        return self.rawValue
    }
}

struct Gem: Identifiable, Equatable {
    let id = UUID()
    let type: GemType
    var position: GridPosition
    var isMatched: Bool = false
    
    static func == (lhs: Gem, rhs: Gem) -> Bool {
        return lhs.id == rhs.id
    }
}

struct GridPosition: Equatable, Hashable {
    let row: Int
    let column: Int
    
    static func == (lhs: GridPosition, rhs: GridPosition) -> Bool {
        return lhs.row == rhs.row && lhs.column == rhs.column
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(row)
        hasher.combine(column)
    }
}

enum DifficultyLevel: String, CaseIterable, Codable {
    case easy = "Easy"
    case medium = "Medium"
    case hard = "Hard"
    
    var gridSize: Int {
        switch self {
        case .easy: return 5
        case .medium: return 7
        case .hard: return 9
        }
    }
    
    var timeLimit: Int {
        switch self {
        case .easy: return 120 // 2 minutes
        case .medium: return 180 // 3 minutes
        case .hard: return 240 // 4 minutes
        }
    }
}

struct GameState {
    var score: Int = 0
    var timeRemaining: Int = 0
    var level: Int = 1
    var difficulty: DifficultyLevel = .easy
    var isGameActive: Bool = false
    var isGamePaused: Bool = false
}

// MARK: - Achievement Models

struct Achievement: Identifiable, Codable {
    let id = UUID()
    let title: String
    let description: String
    let icon: String
    let targetValue: Int
    var currentValue: Int = 0
    var isUnlocked: Bool = false
    var unlockedDate: Date?
    
    var progress: Double {
        return min(Double(currentValue) / Double(targetValue), 1.0)
    }
}

// MARK: - Settings Models

enum ColorScheme: String, CaseIterable, Codable {
    case light = "Light"
    case dark = "Dark"
    case system = "System"
    
    var userInterfaceStyle: UIUserInterfaceStyle {
        switch self {
        case .light: return .light
        case .dark: return .dark
        case .system: return .unspecified
        }
    }
}

struct GameSettings: Codable {
    var soundEnabled: Bool = true
    var musicEnabled: Bool = true
    var difficulty: DifficultyLevel = .easy
    var hasCompletedOnboarding: Bool = false
    var colorScheme: ColorScheme = .light
}
