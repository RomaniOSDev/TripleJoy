import SwiftUI

struct GameView: View {
    @StateObject private var gameViewModel: GameViewModel
    @EnvironmentObject var achievementsViewModel: AchievementsViewModel
    @Environment(\.dismiss) private var dismiss
    @State private var showingGameOver = false
    @State private var showingPauseMenu = false
    
    init(difficulty: DifficultyLevel = .easy) {
        self._gameViewModel = StateObject(wrappedValue: GameViewModel(difficulty: difficulty))
    }
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // Background
                AnimatedBackground()
                    .ignoresSafeArea()
                
                VStack(spacing: 15) {
                    // Header with score and timer
                    headerView
                        .padding(.horizontal, 20)
                    
                    // Game board - центрируем и ограничиваем размер
                    gameBoardView(geometry: geometry)
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .padding(.horizontal, 20)
                    
                    // Control buttons
                    controlButtonsView
                        .padding(.horizontal, 20)
                }
                .padding(.vertical, 10)
            }
        }
        .navigationBarHidden(true)
        .onAppear {
            if !gameViewModel.gameState.isGameActive {
                gameViewModel.setupGame()
            }
        }
        .onChange(of: gameViewModel.gameState.isGameActive) { isActive in
            if !isActive {
                showingGameOver = true
                achievementsViewModel.updateScore(gameViewModel.gameState.score)
                achievementsViewModel.completeLevel()
            }
        }
        .onChange(of: gameViewModel.gameState.timeRemaining) { timeRemaining in
            if timeRemaining <= 0 && gameViewModel.gameState.isGameActive {
                // Принудительно завершаем игру, если время закончилось
                gameViewModel.endGame()
            }
        }
        .sheet(isPresented: $showingGameOver) {
            GameOverView(
                score: gameViewModel.gameState.score,
                level: gameViewModel.gameState.level,
                onPlayAgain: {
                    gameViewModel.resetGame()
                    showingGameOver = false
                },
                onMainMenu: {
                    showingGameOver = false
                    dismiss()
                }
            )
        }
        .sheet(isPresented: $showingPauseMenu) {
            PauseMenuView(
                onResume: {
                    gameViewModel.resumeGame()
                    showingPauseMenu = false
                },
                onRestart: {
                    gameViewModel.resetGame()
                    showingPauseMenu = false
                },
                onMainMenu: {
                    showingPauseMenu = false
                    dismiss()
                }
            )
        }
    }
    
    // MARK: - Header View
    
    private var headerView: some View {
        HStack {
            VStack(alignment: .leading) {
                Text("Score")
                    .font(.caption)
                    .foregroundColor(.secondary)
                Text("\(gameViewModel.gameState.score)")
                    .font(.title2)
                    .fontWeight(.bold)
            }
            
            Spacer()
            
            VStack {
                Text("Time")
                    .font(.caption)
                    .foregroundColor(.secondary)
                Text("\(formatTime(gameViewModel.gameState.timeRemaining))")
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(gameViewModel.gameState.timeRemaining <= 30 ? .red : .primary)
            }
            
            Spacer()
            
            VStack(alignment: .trailing) {
                Text("Level")
                    .font(.caption)
                    .foregroundColor(.secondary)
                Text("\(gameViewModel.gameState.level)")
                    .font(.title2)
                    .fontWeight(.bold)
            }
        }
        .padding()
        .background(Color(.systemBackground).opacity(0.9))
        .cornerRadius(15)
        .shadow(radius: 8, x: 0, y: 4)
    }
    
    // MARK: - Game Board View
    
    private func gameBoardView(geometry: GeometryProxy) -> some View {
        let padding: CGFloat = 20
        let availableWidth = geometry.size.width - (padding * 2)
        let availableHeight = geometry.size.height - 300
        let gridSize = CGFloat(gameViewModel.gems.count)
        let spacing: CGFloat = 1.5 // Уменьшаем промежуток для больших сеток
        let totalSpacing = spacing * (gridSize - 1)
        
        // Рассчитываем размер ячейки с учетом отступов и промежутков
        let cellSize = min(
            (availableWidth - totalSpacing) / gridSize,
            (availableHeight - totalSpacing) / gridSize
        )
        
        // Более строгие ограничения для больших сеток
        let maxCellSize: CGFloat = gameViewModel.gameState.difficulty == .easy ? 60 : 
                                  gameViewModel.gameState.difficulty == .medium ? 45 : 35
        let minCellSize: CGFloat = gameViewModel.gameState.difficulty == .easy ? 30 : 
                                  gameViewModel.gameState.difficulty == .medium ? 25 : 20
        
        let finalCellSize = max(minCellSize, min(cellSize, maxCellSize))
        
        // Проверяем, что игровое поле помещается на экране
        let totalWidth = (finalCellSize * gridSize) + totalSpacing + (padding * 2)
        let totalHeight = (finalCellSize * gridSize) + totalSpacing + (padding * 2)
        
        return VStack(spacing: spacing) {
            ForEach(0..<gameViewModel.gems.count, id: \.self) { row in
                HStack(spacing: spacing) {
                    ForEach(0..<gameViewModel.gems[row].count, id: \.self) { column in
                        GemView(
                            gem: gameViewModel.gems[row][column],
                            size: finalCellSize,
                            isSelected: gameViewModel.selectedGem?.id == gameViewModel.gems[row][column].id,
                            isAnimating: gameViewModel.isAnimating
                        )
                        .onTapGesture {
                            gameViewModel.selectGem(gameViewModel.gems[row][column])
                        }
                    }
                }
            }
        }
        .padding(padding)
        .background(Color(.systemBackground).opacity(0.9))
        .cornerRadius(15)
        .shadow(radius: 8, x: 0, y: 4)
        .frame(
            width: min(totalWidth, availableWidth + (padding * 2)),
            height: min(totalHeight, availableHeight + (padding * 2)),
            alignment: .center
        )
        .clipped() // Обрезаем содержимое, если оно выходит за границы
    }
    
    // MARK: - Control Buttons View
    
    private var controlButtonsView: some View {
        HStack(spacing: 20) {
            Button(action: {
                showingPauseMenu = true
                gameViewModel.pauseGame()
            }) {
                Image(systemName: "pause.circle.fill")
                    .font(.title)
                    .foregroundColor(.blue)
            }
            
            Button(action: {
                gameViewModel.resetGame()
            }) {
                Image(systemName: "arrow.clockwise.circle.fill")
                    .font(.title)
                    .foregroundColor(.orange)
            }
        }
    }
    
    // MARK: - Helper Functions
    
    private func formatTime(_ seconds: Int) -> String {
        let minutes = seconds / 60
        let remainingSeconds = seconds % 60
        return String(format: "%d:%02d", minutes, remainingSeconds)
    }
}

// MARK: - Gem View

struct GemView: View {
    let gem: Gem
    let size: CGFloat
    let isSelected: Bool
    let isAnimating: Bool
    
    @State private var isAnimatingMatch = false
    
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 8)
                .fill(gemColor)
                .frame(width: size, height: size)
                .scaleEffect(isSelected ? 1.1 : 1.0)
                .scaleEffect(isAnimatingMatch ? 0.8 : 1.0)
                .opacity(gem.isMatched ? 0.3 : 1.0)
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(isSelected ? Color.blue : Color.clear, lineWidth: 3)
                )
                .animation(.easeInOut(duration: 0.2), value: isSelected)
                .animation(.easeInOut(duration: 0.3), value: isAnimatingMatch)
            
            if gem.isMatched {
                Image(systemName: "sparkles")
                    .font(.system(size: size * 0.4))
                    .foregroundColor(.yellow)
                    .scaleEffect(isAnimatingMatch ? 1.5 : 0.5)
                    .opacity(isAnimatingMatch ? 0 : 1)
                    .animation(.easeOut(duration: 0.5), value: isAnimatingMatch)
            }
        }
        .onChange(of: gem.isMatched) { matched in
            if matched {
                isAnimatingMatch = true
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    isAnimatingMatch = false
                }
            }
        }
    }
    
    private var gemColor: Color {
        switch gem.type {
        case .red:
            return .red
        case .blue:
            return .blue
        case .green:
            return .green
        case .yellow:
            return .yellow
        case .purple:
            return .purple
        case .orange:
            return .orange
        }
    }
}

// MARK: - Game Over View

struct GameOverView: View {
    let score: Int
    let level: Int
    let onPlayAgain: () -> Void
    let onMainMenu: () -> Void
    
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        VStack(spacing: 30) {
            Text("Game Over!")
                .font(.largeTitle)
                .fontWeight(.bold)
                .foregroundColor(.red)
            
            VStack(spacing: 15) {
                Text("Final Score: \(score)")
                    .font(.title2)
                    .fontWeight(.semibold)
                
                Text("Level: \(level)")
                    .font(.title3)
                    .foregroundColor(.secondary)
            }
            
            VStack(spacing: 15) {
                Button(action: onPlayAgain) {
                    Text("Play Again")
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue)
                        .cornerRadius(10)
                }
                
                Button(action: {
                    dismiss()
                    onMainMenu()
                }) {
                    Text("Main Menu")
                        .font(.headline)
                        .foregroundColor(.blue)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue.opacity(0.1))
                        .cornerRadius(10)
                }
            }
        }
        .padding(40)
        .background(Color(.systemBackground))
        .cornerRadius(20)
        .shadow(radius: 10)
    }
}

// MARK: - Pause Menu View

struct PauseMenuView: View {
    let onResume: () -> Void
    let onRestart: () -> Void
    let onMainMenu: () -> Void
    
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        VStack(spacing: 30) {
            Text("Game Paused")
                .font(.largeTitle)
                .fontWeight(.bold)
            
            VStack(spacing: 15) {
                Button(action: onResume) {
                    Text("Resume")
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue)
                        .cornerRadius(10)
                }
                
                Button(action: onRestart) {
                    Text("Restart")
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.orange)
                        .cornerRadius(10)
                }
                
                Button(action: {
                    dismiss()
                    onMainMenu()
                }) {
                    Text("Main Menu")
                        .font(.headline)
                        .foregroundColor(.blue)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue.opacity(0.1))
                        .cornerRadius(10)
                }
            }
        }
        .padding(40)
        .background(Color(.systemBackground))
        .cornerRadius(20)
        .shadow(radius: 10)
    }
}

#Preview {
    GameView(difficulty: .easy)
}
