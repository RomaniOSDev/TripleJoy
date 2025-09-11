import Foundation
import SwiftUI

class GameViewModel: ObservableObject {
    @Published var gameState = GameState()
    @Published var gems: [[Gem]] = []
    @Published var selectedGem: Gem?
    @Published var isAnimating = false
    
    private let gridSize: Int
    private var timer: Timer?
    private let soundManager = SoundManager.shared
    
    init(difficulty: DifficultyLevel = .easy) {
        self.gridSize = difficulty.gridSize
        self.gameState.difficulty = difficulty
        self.gameState.timeRemaining = difficulty.timeLimit
        setupGame()
    }
    
    // MARK: - Game Setup
    
    func setupGame() {
        gems = []
        gameState.score = 0
        gameState.isGameActive = true
        gameState.isGamePaused = false
        
        // Create initial grid
        for row in 0..<gridSize {
            var rowGems: [Gem] = []
            for column in 0..<gridSize {
                let gemType = GemType.allCases.randomElement() ?? .red
                let gem = Gem(type: gemType, position: GridPosition(row: row, column: column))
                rowGems.append(gem)
            }
            gems.append(rowGems)
        }
        
        // Remove initial matches
        removeInitialMatches()
        startTimer()
    }
    
    private func removeInitialMatches() {
        var hasMatches = true
        while hasMatches {
            hasMatches = false
            for row in 0..<gridSize {
                for column in 0..<gridSize {
                    if checkForMatch(at: GridPosition(row: row, column: column)) {
                        hasMatches = true
                        let newType = GemType.allCases.randomElement() ?? .red
                        gems[row][column] = Gem(type: newType, position: GridPosition(row: row, column: column))
                    }
                }
            }
        }
    }
    
    // MARK: - Game Logic
    
    func selectGem(_ gem: Gem) {
        guard !isAnimating else { return }
        
        soundManager.playButtonTap()
        
        if let selected = selectedGem {
            if selected.id == gem.id {
                selectedGem = nil
            } else if areAdjacent(selected, gem) {
                swapGems(selected, gem)
                selectedGem = nil
            } else {
                selectedGem = gem
            }
        } else {
            selectedGem = gem
        }
    }
    
    private func areAdjacent(_ gem1: Gem, _ gem2: Gem) -> Bool {
        let pos1 = gem1.position
        let pos2 = gem2.position
        
        let rowDiff = abs(pos1.row - pos2.row)
        let colDiff = abs(pos1.column - pos2.column)
        
        return (rowDiff == 1 && colDiff == 0) || (rowDiff == 0 && colDiff == 1)
    }
    
    private func swapGems(_ gem1: Gem, _ gem2: Gem) {
        let pos1 = gem1.position
        let pos2 = gem2.position
        
        soundManager.playGemSwap()
        
        // Swap positions
        gems[pos1.row][pos1.column] = Gem(type: gem2.type, position: pos1)
        gems[pos2.row][pos2.column] = Gem(type: gem1.type, position: pos2)
        
        // Check for matches after swap
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            self.checkAndProcessMatches()
        }
    }
    
    private func checkAndProcessMatches() {
        var matchedGems: Set<GridPosition> = []
        
        // Check horizontal matches
        for row in 0..<gridSize {
            var count = 1
            var currentType = gems[row][0].type
            
            for column in 1..<gridSize {
                if gems[row][column].type == currentType {
                    count += 1
                } else {
                    if count >= 3 {
                        for i in (column - count)..<column {
                            matchedGems.insert(GridPosition(row: row, column: i))
                        }
                    }
                    count = 1
                    currentType = gems[row][column].type
                }
            }
            
            if count >= 3 {
                for i in (gridSize - count)..<gridSize {
                    matchedGems.insert(GridPosition(row: row, column: i))
                }
            }
        }
        
        // Check vertical matches
        for column in 0..<gridSize {
            var count = 1
            var currentType = gems[0][column].type
            
            for row in 1..<gridSize {
                if gems[row][column].type == currentType {
                    count += 1
                } else {
                    if count >= 3 {
                        for i in (row - count)..<row {
                            matchedGems.insert(GridPosition(row: i, column: column))
                        }
                    }
                    count = 1
                    currentType = gems[row][column].type
                }
            }
            
            if count >= 3 {
                for i in (gridSize - count)..<gridSize {
                    matchedGems.insert(GridPosition(row: i, column: column))
                }
            }
        }
        
        if !matchedGems.isEmpty {
            processMatches(matchedGems)
        } else {
            // If no matches, check if game is over
            checkGameOver()
        }
    }
    
    private func processMatches(_ matchedPositions: Set<GridPosition>) {
        isAnimating = true
        
        // Play match sound
        soundManager.playGemMatch()
        
        // Update score
        gameState.score += matchedPositions.count * 10
        
        // Mark gems as matched
        for position in matchedPositions {
            gems[position.row][position.column].isMatched = true
        }
        
        // Animate removal and drop new gems
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            self.dropGems()
            self.fillEmptySpaces()
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                self.isAnimating = false
                self.checkAndProcessMatches()
            }
        }
    }
    
    private func dropGems() {
        for column in 0..<gridSize {
            var writeIndex = gridSize - 1
            
            for row in stride(from: gridSize - 1, through: 0, by: -1) {
                if !gems[row][column].isMatched {
                    if writeIndex != row {
                        gems[writeIndex][column] = Gem(type: gems[row][column].type, position: GridPosition(row: writeIndex, column: column))
                    }
                    writeIndex -= 1
                }
            }
        }
    }
    
    private func fillEmptySpaces() {
        for column in 0..<gridSize {
            for row in 0..<gridSize {
                if gems[row][column].isMatched {
                    let newType = GemType.allCases.randomElement() ?? .red
                    gems[row][column] = Gem(type: newType, position: GridPosition(row: row, column: column))
                }
            }
        }
    }
    
    private func checkForMatch(at position: GridPosition) -> Bool {
        let row = position.row
        let column = position.column
        let gemType = gems[row][column].type
        
        // Check horizontal
        var horizontalCount = 1
        var left = column - 1
        while left >= 0 && gems[row][left].type == gemType {
            horizontalCount += 1
            left -= 1
        }
        var right = column + 1
        while right < gridSize && gems[row][right].type == gemType {
            horizontalCount += 1
            right += 1
        }
        
        // Check vertical
        var verticalCount = 1
        var up = row - 1
        while up >= 0 && gems[up][column].type == gemType {
            verticalCount += 1
            up -= 1
        }
        var down = row + 1
        while down < gridSize && gems[down][column].type == gemType {
            verticalCount += 1
            down += 1
        }
        
        return horizontalCount >= 3 || verticalCount >= 3
    }
    
    private func checkGameOver() {
        // Check if there are any possible moves
        for row in 0..<gridSize {
            for column in 0..<gridSize {
                if canMakeMove(at: GridPosition(row: row, column: column)) {
                    return
                }
            }
        }
        
        // No more moves available
        endGame()
    }
    
    private func canMakeMove(at position: GridPosition) -> Bool {
        let row = position.row
        let column = position.column
        let gemType = gems[row][column].type
        
        // Check all adjacent positions
        let directions = [(0, 1), (0, -1), (1, 0), (-1, 0)]
        
        for (dr, dc) in directions {
            let newRow = row + dr
            let newCol = column + dc
            
            if newRow >= 0 && newRow < gridSize && newCol >= 0 && newCol < gridSize {
                // Temporarily swap
                let temp = gems[row][column]
                gems[row][column] = gems[newRow][newCol]
                gems[newRow][newCol] = temp
                
                // Check if this creates a match
                let hasMatch = checkForMatch(at: position) || checkForMatch(at: GridPosition(row: newRow, column: newCol))
                
                // Swap back
                let temp2 = gems[row][column]
                gems[row][column] = gems[newRow][newCol]
                gems[newRow][newCol] = temp2
                
                if hasMatch {
                    return true
                }
            }
        }
        
        return false
    }
    
    // MARK: - Timer
    
    private func startTimer() {
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { _ in
            if self.gameState.isGameActive && !self.gameState.isGamePaused {
                if self.gameState.timeRemaining > 0 {
                    self.gameState.timeRemaining -= 1
                } else {
                    // Время закончилось - завершаем игру
                    self.endGame()
                }
            }
        }
    }
    
    func endGame() {
        gameState.isGameActive = false
        timer?.invalidate()
        timer = nil
        
        // Определяем причину завершения игры
        if gameState.timeRemaining <= 0 {
            // Игра завершилась по времени
            soundManager.playGameOver()
        } else {
            // Игра завершилась успешно (есть возможные ходы)
            soundManager.playLevelComplete()
        }
    }
    
    func pauseGame() {
        gameState.isGamePaused = true
    }
    
    func resumeGame() {
        gameState.isGamePaused = false
    }
    
    func resetGame() {
        timer?.invalidate()
        timer = nil
        setupGame()
    }
    
    deinit {
        timer?.invalidate()
    }
}
