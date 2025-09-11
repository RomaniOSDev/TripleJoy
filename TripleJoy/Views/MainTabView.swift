import SwiftUI

struct MainTabView: View {
    @StateObject private var settingsViewModel = SettingsViewModel()
    @StateObject private var achievementsViewModel = AchievementsViewModel()
    @State private var selectedTab = 0
    
    init(){        
        let navBarAppearance = UINavigationBarAppearance()
        navBarAppearance.titleTextAttributes = [.foregroundColor: UIColor.white] // Цвет заголовка
        navBarAppearance.largeTitleTextAttributes = [.foregroundColor: UIColor.white] // Для largeTitle
        
        UINavigationBar.appearance().standardAppearance = navBarAppearance
        UINavigationBar.appearance().compactAppearance = navBarAppearance
    }

    
    var body: some View {
        TabView(selection: $selectedTab) {
            // Game Tab
            NavigationStack {
                GameSelectionView(settingsViewModel: settingsViewModel)
                    .environmentObject(achievementsViewModel)
            }
            .tabItem {
                Image(systemName: selectedTab == 0 ? "gamecontroller.fill" : "gamecontroller")
                Text("Game")
            }
            .tag(0)
            
            // Achievements Tab
            AchievementsView()
                .environmentObject(achievementsViewModel)
                .tabItem {
                    Image(systemName: selectedTab == 1 ? "trophy.fill" : "trophy")
                    Text("Achievements")
                }
                .tag(1)
            
            // Settings Tab
            SettingsView()
                .tabItem {
                    Image(systemName: selectedTab == 2 ? "gear.fill" : "gear")
                    Text("Settings")
                }
                .tag(2)
        }
        .accentColor(.blue)
        .preferredColorScheme(settingsViewModel.currentColorScheme == .system ? nil : (settingsViewModel.currentColorScheme == .light ? .light : .dark))
    }
}

// MARK: - Game Selection View

struct GameSelectionView: View {
    @ObservedObject var settingsViewModel: SettingsViewModel
    @EnvironmentObject var achievementsViewModel: AchievementsViewModel
    @State private var showingGame = false
    @State private var selectedDifficulty: DifficultyLevel = .easy
    
    var body: some View {
        ZStack {
            // Background
            AnimatedBackground()
                .ignoresSafeArea()
            
            ScrollView {
                VStack(spacing: 30) {
                    // Header
                    headerView
                    
                    // Difficulty Selection
                    difficultySelectionView
                    
                    // Quick Start Button
                    quickStartButton
                    
                    // Game Rules
                    gameRulesView
                }
                .padding()
            }
        }
        .navigationTitle("TripleJoy")
        .navigationBarTitleDisplayMode(.large)
        .sheet(isPresented: $showingGame) {
            GameView(difficulty: selectedDifficulty)
                .environmentObject(achievementsViewModel)
        }
    }
    
    // MARK: - Header View
    
    private var headerView: some View {
        VStack(spacing: 15) {
            Image(systemName: "sparkles")
                .font(.system(size: 60))
                .foregroundColor(.blue)
                .scaleEffect(1.0)
                .animation(.easeInOut(duration: 2.0).repeatForever(autoreverses: true), value: UUID())
            
            Text("Welcome to TripleJoy!")
                .font(.largeTitle)
                .fontWeight(.bold)
                .multilineTextAlignment(.center)
            
            Text("Match 3 or more gems to clear them and score points")
                .font(.title3)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(20)
        .shadow(radius: 5)
    }
    
    // MARK: - Difficulty Selection View
    
    private var difficultySelectionView: some View {
        VStack(alignment: .leading, spacing: 15) {
            Text("Select Difficulty")
                .font(.title2)
                .fontWeight(.bold)
            
            VStack(spacing: 10) {
                ForEach(DifficultyLevel.allCases, id: \.self) { difficulty in
                    DifficultySelectionCard(
                        difficulty: difficulty,
                        isSelected: selectedDifficulty == difficulty,
                        onTap: {
                            selectedDifficulty = difficulty
                        }
                    )
                }
            }
        }
    }
    
    // MARK: - Quick Start Button
    
    private var quickStartButton: some View {
        PulsingButton(title: "Start Game", icon: "play.fill") {
            showingGame = true
        }
    }
    
    // MARK: - Game Rules View
    
    private var gameRulesView: some View {
        VStack(alignment: .leading, spacing: 15) {
            Text("How to Play")
                .font(.title2)
                .fontWeight(.bold)
            
            VStack(spacing: 10) {
                RuleItemView(
                    icon: "hand.tap.fill",
                    text: "Tap adjacent gems to swap their positions"
                )
                
                RuleItemView(
                    icon: "sparkles",
                    text: "Create lines of 3 or more matching gems"
                )
                
                RuleItemView(
                    icon: "star.fill",
                    text: "Earn points for each gem you clear"
                )
                
                RuleItemView(
                    icon: "timer",
                    text: "Complete levels within the time limit"
                )
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(15)
        .shadow(radius: 2)
    }
}

// MARK: - Difficulty Selection Card

struct DifficultySelectionCard: View {
    let difficulty: DifficultyLevel
    let isSelected: Bool
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            HStack {
                VStack(alignment: .leading, spacing: 5) {
                    Text(difficulty.rawValue)
                        .font(.headline)
                        .fontWeight(.semibold)
                        .foregroundColor(.primary)
                    
                    Text("\(difficulty.gridSize)x\(difficulty.gridSize) grid • \(difficulty.timeLimit / 60) min")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                if isSelected {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(.blue)
                        .font(.title2)
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

// MARK: - Rule Item View

struct RuleItemView: View {
    let icon: String
    let text: String
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .foregroundColor(.blue)
                .frame(width: 20)
            
            Text(text)
                .font(.body)
                .foregroundColor(.primary)
            
            Spacer()
        }
    }
}

// MARK: - Preview

#Preview {
    MainTabView()
}
