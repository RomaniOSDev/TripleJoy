import SwiftUI

struct AchievementsView: View {
    @EnvironmentObject var achievementsViewModel: AchievementsViewModel
    @State private var showingResetAlert = false
    
    var body: some View {
        NavigationView {
            ZStack {
                // Background
                AnimatedBackground()
                    .ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 20) {
                        // Statistics Header
                        statisticsHeaderView
                        
                        // Achievements List
                        achievementsListView
                    }
                    .padding()
                }
            }
            .navigationTitle("Achievements")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Reset") {
                        showingResetAlert = true
                    }
                    .foregroundColor(.red)
                }
            }
        }
        .alert("Reset All Progress", isPresented: $showingResetAlert) {
            Button("Cancel", role: .cancel) { }
            Button("Reset", role: .destructive) {
                achievementsViewModel.resetAllProgress()
            }
        } message: {
            Text("This will reset all your achievements and progress. This action cannot be undone.")
        }
    }
    
    // MARK: - Statistics Header View
    
    private var statisticsHeaderView: some View {
        VStack(spacing: 15) {
            Text("Your Progress")
                .font(.title2)
                .fontWeight(.bold)
            
            HStack(spacing: 20) {
                StatisticCard(
                    title: "Total Score",
                    value: "\(achievementsViewModel.totalScore)",
                    icon: "star.fill",
                    color: .yellow
                )
                
                StatisticCard(
                    title: "Levels Completed",
                    value: "\(achievementsViewModel.levelsCompleted)",
                    icon: "gamecontroller.fill",
                    color: .blue
                )
            }
            
            HStack(spacing: 20) {
                StatisticCard(
                    title: "Achievements",
                    value: "\(achievementsViewModel.unlockedAchievementsCount)/\(achievementsViewModel.totalAchievementsCount)",
                    icon: "trophy.fill",
                    color: .orange
                )
                
                StatisticCard(
                    title: "Completion",
                    value: "\(Int(achievementsViewModel.completionPercentage * 100))%",
                    icon: "chart.pie.fill",
                    color: .green
                )
            }
        }
        .padding()
        .background(Color(.systemBackground).opacity(0.9))
        .cornerRadius(15)
        .shadow(radius: 8, x: 0, y: 4)
    }
    
    // MARK: - Achievements List View
    
    private var achievementsListView: some View {
        VStack(alignment: .leading, spacing: 15) {
            Text("Achievements")
                .font(.title2)
                .fontWeight(.bold)
                .padding(.horizontal)
                .foregroundStyle(.white)
            
            LazyVStack(spacing: 10) {
                ForEach(achievementsViewModel.achievements) { achievement in
                    AchievementRowView(achievement: achievement)
                }
            }
        }
    }
}

// MARK: - Statistic Card View

struct StatisticCard: View {
    let title: String
    let value: String
    let icon: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(color)
            
            Text(value)
                .font(.title3)
                .fontWeight(.bold)
            
            Text(title)
                .font(.caption)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(color.opacity(0.1))
        .cornerRadius(10)
    }
}

// MARK: - Achievement Row View

struct AchievementRowView: View {
    let achievement: Achievement
    @State private var isAnimating = false
    
    var body: some View {
        HStack(spacing: 15) {
            // Icon
            ZStack {
                Circle()
                    .fill(achievement.isUnlocked ? Color.green : Color.gray.opacity(0.3))
                    .frame(width: 50, height: 50)
                
                Image(systemName: achievement.icon)
                    .font(.title2)
                    .foregroundColor(achievement.isUnlocked ? .white : .gray)
                    .scaleEffect(isAnimating ? 1.2 : 1.0)
                    .animation(.easeInOut(duration: 0.3), value: isAnimating)
            }
            
            // Content
            VStack(alignment: .leading, spacing: 5) {
                HStack {
                    Text(achievement.title)
                        .font(.headline)
                        .foregroundColor(achievement.isUnlocked ? .primary : .secondary)
                    
                    Spacer()
                    
                    if achievement.isUnlocked {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundColor(.green)
                            .font(.title3)
                    }
                }
                
                Text(achievement.description)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                
                // Progress bar
                if !achievement.isUnlocked {
                    VStack(alignment: .leading, spacing: 2) {
                        HStack {
                            Text("\(achievement.currentValue)/\(achievement.targetValue)")
                                .font(.caption)
                                .foregroundColor(.secondary)
                            
                            Spacer()
                            
                            Text("\(Int(achievement.progress * 100))%")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        
                        ProgressView(value: achievement.progress)
                            .progressViewStyle(LinearProgressViewStyle(tint: .blue))
                            .scaleEffect(y: 2)
                    }
                } else if let unlockedDate = achievement.unlockedDate {
                    Text("Unlocked \(formatDate(unlockedDate))")
                        .font(.caption)
                        .foregroundColor(.green)
                }
            }
        }
        .padding()
        .background(Color(.systemBackground).opacity(0.9))
        .cornerRadius(12)
        .shadow(radius: 4, x: 0, y: 2)
        .opacity(achievement.isUnlocked ? 1.0 : 0.7)
        .onAppear {
            if achievement.isUnlocked {
                withAnimation(.easeInOut(duration: 0.5).delay(0.1)) {
                    isAnimating = true
                }
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    isAnimating = false
                }
            }
        }
    }
    
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
}

// MARK: - Preview

#Preview {
    AchievementsView()
}
