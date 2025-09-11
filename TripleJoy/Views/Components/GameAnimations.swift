import SwiftUI

struct MatchAnimation: View {
    let position: CGPoint
    @State private var isAnimating = false
    
    var body: some View {
        ZStack {
            // Explosion effect
            ForEach(0..<8, id: \.self) { index in
                Circle()
                    .fill(
                        LinearGradient(
                            gradient: Gradient(colors: [Color.yellow, Color.orange, Color.red]),
                            startPoint: .center,
                            endPoint: .trailing
                        )
                    )
                    .frame(width: 20, height: 20)
                    .position(
                        x: position.x + cos(Double(index) * .pi / 4) * (isAnimating ? 50 : 0),
                        y: position.y + sin(Double(index) * .pi / 4) * (isAnimating ? 50 : 0)
                    )
                    .opacity(isAnimating ? 0 : 1)
                    .scaleEffect(isAnimating ? 2 : 0.5)
            }
            
            // Central sparkle
            Image(systemName: "sparkles")
                .font(.system(size: 30))
                .foregroundColor(.yellow)
                .position(position)
                .scaleEffect(isAnimating ? 1.5 : 0.5)
                .opacity(isAnimating ? 0 : 1)
                .rotationEffect(.degrees(isAnimating ? 360 : 0))
        }
        .onAppear {
            withAnimation(.easeOut(duration: 0.8)) {
                isAnimating = true
            }
        }
    }
}

struct ScoreAnimation: View {
    let score: Int
    let position: CGPoint
    @State private var isAnimating = false
    
    var body: some View {
        Text("+\(score)")
            .font(.title2)
            .fontWeight(.bold)
            .foregroundColor(.green)
            .position(
                x: position.x,
                y: position.y + (isAnimating ? -50 : 0)
            )
            .opacity(isAnimating ? 0 : 1)
            .scaleEffect(isAnimating ? 1.5 : 0.5)
            .onAppear {
                withAnimation(.easeOut(duration: 1.0)) {
                    isAnimating = true
                }
            }
    }
}

struct GemDropAnimation: View {
    let gem: Gem
    let fromPosition: CGPoint
    let toPosition: CGPoint
    @State private var currentPosition: CGPoint
    @State private var isAnimating = false
    
    init(gem: Gem, fromPosition: CGPoint, toPosition: CGPoint) {
        self.gem = gem
        self.fromPosition = fromPosition
        self.toPosition = toPosition
        self._currentPosition = State(initialValue: fromPosition)
    }
    
    var body: some View {
        RoundedRectangle(cornerRadius: 8)
            .fill(gemColor)
            .frame(width: 30, height: 30)
            .position(currentPosition)
            .scaleEffect(isAnimating ? 1.0 : 0.8)
            .onAppear {
                withAnimation(.easeInOut(duration: 0.5)) {
                    currentPosition = toPosition
                    isAnimating = true
                }
            }
    }
    
    private var gemColor: Color {
        switch gem.type {
        case .red: return .red
        case .blue: return .blue
        case .green: return .green
        case .yellow: return .yellow
        case .purple: return .purple
        case .orange: return .orange
        }
    }
}

struct ComboAnimation: View {
    let comboCount: Int
    let position: CGPoint
    @State private var isAnimating = false
    
    var body: some View {
        VStack(spacing: 5) {
            Text("COMBO!")
                .font(.headline)
                .fontWeight(.bold)
                .foregroundColor(.orange)
            
            Text("x\(comboCount)")
                .font(.title)
                .fontWeight(.bold)
                .foregroundColor(.red)
        }
        .position(
            x: position.x,
            y: position.y + (isAnimating ? -30 : 0)
        )
        .opacity(isAnimating ? 0 : 1)
        .scaleEffect(isAnimating ? 1.2 : 0.5)
        .rotationEffect(.degrees(isAnimating ? 10 : -10))
        .onAppear {
            withAnimation(.easeOut(duration: 1.5)) {
                isAnimating = true
            }
        }
    }
}

struct LevelCompleteAnimation: View {
    @State private var isAnimating = false
    
    var body: some View {
        ZStack {
            // Background glow
            Circle()
                .fill(
                    RadialGradient(
                        gradient: Gradient(colors: [Color.yellow.opacity(0.3), Color.clear]),
                        center: .center,
                        startRadius: 0,
                        endRadius: 100
                    )
                )
                .frame(width: 200, height: 200)
                .scaleEffect(isAnimating ? 2 : 0.5)
                .opacity(isAnimating ? 0 : 1)
            
            // Confetti
            ForEach(0..<20, id: \.self) { index in
                RoundedRectangle(cornerRadius: 2)
                    .fill([Color.red, Color.blue, Color.green, Color.yellow, Color.purple].randomElement() ?? .red)
                    .frame(width: 8, height: 8)
                    .position(
                        x: UIScreen.main.bounds.width / 2 + cos(Double(index) * .pi / 10) * (isAnimating ? 150 : 0),
                        y: UIScreen.main.bounds.height / 2 + sin(Double(index) * .pi / 10) * (isAnimating ? 150 : 0)
                    )
                    .opacity(isAnimating ? 0 : 1)
                    .rotationEffect(.degrees(isAnimating ? 360 : 0))
            }
            
            // Main text
            VStack(spacing: 10) {
                Text("LEVEL COMPLETE!")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                    .shadow(radius: 5)
                
                Text("Well Done!")
                    .font(.title2)
                    .foregroundColor(.yellow)
            }
            .scaleEffect(isAnimating ? 1.0 : 0.5)
            .opacity(isAnimating ? 1 : 0)
        }
        .onAppear {
            withAnimation(.easeOut(duration: 2.0)) {
                isAnimating = true
            }
        }
    }
}

struct PulsingGem: View {
    let gem: Gem
    let size: CGFloat
    @State private var isPulsing = false
    
    var body: some View {
        RoundedRectangle(cornerRadius: 8)
            .fill(gemColor)
            .frame(width: size, height: size)
            .scaleEffect(isPulsing ? 1.1 : 1.0)
            .opacity(isPulsing ? 0.8 : 1.0)
            .animation(.easeInOut(duration: 1.0).repeatForever(autoreverses: true), value: isPulsing)
            .onAppear {
                isPulsing = true
            }
    }
    
    private var gemColor: Color {
        switch gem.type {
        case .red: return .red
        case .blue: return .blue
        case .green: return .green
        case .yellow: return .yellow
        case .purple: return .purple
        case .orange: return .orange
        }
    }
}

#Preview {
    ZStack {
        Color.black.ignoresSafeArea()
        
        VStack(spacing: 50) {
            MatchAnimation(position: CGPoint(x: 100, y: 100))
            
            ScoreAnimation(score: 100, position: CGPoint(x: 200, y: 200))
            
            ComboAnimation(comboCount: 3, position: CGPoint(x: 150, y: 300))
            
            LevelCompleteAnimation()
        }
    }
}
