import SwiftUI

struct OnboardingView: View {
    @StateObject private var settingsViewModel = SettingsViewModel()
    @State private var currentPage = 0
    @State private var showingMainApp = false
    
    var body: some View {
        if showingMainApp {
            MainTabView()
        } else {
            ZStack {
                // Background
                AnimatedBackground()
                    .ignoresSafeArea()
                
                VStack {
                    // Page indicator
                    pageIndicator
                    
                    // Content
                    TabView(selection: $currentPage) {
                        // Page 1: Game Rules
                        OnboardingPageView(
                            title: "Welcome to TripleJoy!",
                            subtitle: "Match-3 Puzzle Game",
                            content: {
                                VStack(spacing: 20) {
                                    // Game board preview
                                    gameBoardPreview
                                    
                                    VStack(spacing: 15) {
                                        OnboardingFeatureView(
                                            icon: "hand.tap.fill",
                                            title: "Tap to Swap",
                                            description: "Tap adjacent gems to swap their positions"
                                        )
                                        
                                        OnboardingFeatureView(
                                            icon: "sparkles",
                                            title: "Match 3 or More",
                                            description: "Create lines of 3 or more matching gems to clear them"
                                        )
                                        
                                        OnboardingFeatureView(
                                            icon: "star.fill",
                                            title: "Score Points",
                                            description: "Earn points for each gem you clear"
                                        )
                                    }
                                }
                            }
                        )
                        .tag(0)
                        
                        // Page 2: Features
                        OnboardingPageView(
                            title: "Game Features",
                            subtitle: "Discover what awaits you",
                            content: {
                                VStack(spacing: 20) {
                                    // Features showcase
                                    VStack(spacing: 15) {
                                        OnboardingFeatureView(
                                            icon: "trophy.fill",
                                            title: "Achievements",
                                            description: "Unlock achievements as you play and complete challenges"
                                        )
                                        
                                        OnboardingFeatureView(
                                            icon: "slider.horizontal.3",
                                            title: "Difficulty Levels",
                                            description: "Choose from Easy (5x5), Medium (7x7), or Hard (9x9) grids"
                                        )
                                        
                                        OnboardingFeatureView(
                                            icon: "gear",
                                            title: "Customizable Settings",
                                            description: "Adjust sound, music, and other preferences to your liking"
                                        )
                                        
                                        OnboardingFeatureView(
                                            icon: "timer",
                                            title: "Time Challenges",
                                            description: "Complete levels within the time limit for extra points"
                                        )
                                    }
                                }
                            }
                        )
                        .tag(1)
                    }
                    .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
                    
                    // Navigation buttons
                    navigationButtons
                }
                .padding()
            }
        }
    }
    
    // MARK: - Page Indicator
    
    private var pageIndicator: some View {
        HStack(spacing: 8) {
            ForEach(0..<2, id: \.self) { index in
                Circle()
                    .fill(index == currentPage ? Color.blue : Color.gray.opacity(0.3))
                    .frame(width: 8, height: 8)
                    .animation(.easeInOut(duration: 0.3), value: currentPage)
            }
        }
        .padding(.top, 20)
    }
    
    // MARK: - Game Board Preview
    
    private var gameBoardPreview: some View {
        VStack(spacing: 2) {
            ForEach(0..<3, id: \.self) { row in
                HStack(spacing: 2) {
                    ForEach(0..<3, id: \.self) { column in
                        RoundedRectangle(cornerRadius: 6)
                            .fill(previewColors[row * 3 + column])
                            .frame(width: 30, height: 30)
                    }
                }
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(radius: 5)
    }
    
    private var previewColors: [Color] {
        [.red, .blue, .green, .yellow, .purple, .orange, .red, .blue, .green]
    }
    
    // MARK: - Navigation Buttons
    
    private var navigationButtons: some View {
        HStack {
            if currentPage > 0 {
                Button("Previous") {
                    withAnimation(.easeInOut(duration: 0.3)) {
                        currentPage -= 1
                    }
                }
                .foregroundColor(.blue)
                .padding()
            }
            
            Spacer()
            
            if currentPage < 1 {
                Button("Next") {
                    withAnimation(.easeInOut(duration: 0.3)) {
                        currentPage += 1
                    }
                }
                .foregroundColor(.white)
                .padding(.horizontal, 30)
                .padding(.vertical, 12)
                .background(Color.blue)
                .cornerRadius(25)
            } else {
                ShimmerButton(title: "Start Playing!", icon: "sparkles") {
                    settingsViewModel.completeOnboarding()
                    withAnimation(.easeInOut(duration: 0.5)) {
                        showingMainApp = true
                    }
                }
            }
        }
        .padding(.horizontal)
        .padding(.bottom, 20)
    }
}

// MARK: - Onboarding Page View

struct OnboardingPageView<Content: View>: View {
    let title: String
    let subtitle: String
    let content: () -> Content
    
    var body: some View {
        VStack(spacing: 30) {
            VStack(spacing: 10) {
                Text(title)
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .multilineTextAlignment(.center)
                
                Text(subtitle)
                    .font(.title3)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
            }
            
            content()
            
            Spacer()
        }
        .padding()
    }
}

// MARK: - Onboarding Feature View

struct OnboardingFeatureView: View {
    let icon: String
    let title: String
    let description: String
    @State private var isAnimating = false
    
    var body: some View {
        HStack(spacing: 15) {
            ZStack {
                Circle()
                    .fill(Color.blue.opacity(0.1))
                    .frame(width: 50, height: 50)
                
                Image(systemName: icon)
                    .font(.title2)
                    .foregroundColor(.blue)
                    .scaleEffect(isAnimating ? 1.1 : 1.0)
                    .animation(.easeInOut(duration: 1.0).repeatForever(autoreverses: true), value: isAnimating)
            }
            
            VStack(alignment: .leading, spacing: 5) {
                Text(title)
                    .font(.headline)
                    .fontWeight(.semibold)
                
                Text(description)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.leading)
            }
            
            Spacer()
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(radius: 2)
        .onAppear {
            isAnimating = true
        }
    }
}

// MARK: - Preview

#Preview {
    OnboardingView()
}
