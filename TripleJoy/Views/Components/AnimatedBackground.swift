import SwiftUI

struct AnimatedBackground: View {
    @State private var animate = false
    
    var body: some View {
        ZStack {
            // Dark blue base gradient
            LinearGradient(
                gradient: Gradient(colors: [
                    Color(red: 0.05, green: 0.1, blue: 0.3),  // Very dark blue
                    Color(red: 0.1, green: 0.2, blue: 0.5),   // Dark blue
                    Color(red: 0.15, green: 0.3, blue: 0.7),  // Medium dark blue
                    Color(red: 0.2, green: 0.4, blue: 0.8)    // Lighter dark blue
                ]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            
            // Animated floating orbs
            ForEach(0..<8, id: \.self) { index in
                Circle()
                    .fill(
                        RadialGradient(
                            gradient: Gradient(colors: [
                                Color.cyan.opacity(0.3),
                                Color.blue.opacity(0.2),
                                Color.clear
                            ]),
                            center: .center,
                            startRadius: 0,
                            endRadius: 100
                        )
                    )
                    .frame(width: CGFloat.random(in: 80...200))
                    .position(
                        x: CGFloat.random(in: 0...UIScreen.main.bounds.width),
                        y: CGFloat.random(in: 0...UIScreen.main.bounds.height)
                    )
                    .scaleEffect(animate ? 1.3 : 0.7)
                    .opacity(animate ? 0.4 : 0.1)
                    .animation(
                        .easeInOut(duration: Double.random(in: 4...8))
                        .repeatForever(autoreverses: true)
                        .delay(Double(index) * 0.8),
                        value: animate
                    )
            }
            
            // Floating particles
            ForEach(0..<15, id: \.self) { index in
                Circle()
                    .fill(Color.white.opacity(0.1))
                    .frame(width: CGFloat.random(in: 2...6))
                    .position(
                        x: CGFloat.random(in: 0...UIScreen.main.bounds.width),
                        y: CGFloat.random(in: 0...UIScreen.main.bounds.height)
                    )
                    .opacity(animate ? 0.8 : 0.2)
                    .animation(
                        .easeInOut(duration: Double.random(in: 2...5))
                        .repeatForever(autoreverses: true)
                        .delay(Double(index) * 0.3),
                        value: animate
                    )
            }
            
            // Subtle overlay for depth
            LinearGradient(
                gradient: Gradient(colors: [
                    Color.black.opacity(0.1),
                    Color.clear,
                    Color.black.opacity(0.05)
                ]),
                startPoint: .top,
                endPoint: .bottom
            )
        }
        .onAppear {
            animate = true
        }
    }
}

struct FloatingParticles: View {
    @State private var particles: [Particle] = []
    
    var body: some View {
        ZStack {
            ForEach(particles, id: \.id) { particle in
                Circle()
                    .fill(particle.color)
                    .frame(width: particle.size, height: particle.size)
                    .position(particle.position)
                    .opacity(particle.opacity)
                    .scaleEffect(particle.scale)
            }
        }
        .onAppear {
            createParticles()
            animateParticles()
        }
    }
    
    private func createParticles() {
        particles = (0..<20).map { _ in
            Particle(
                position: CGPoint(
                    x: CGFloat.random(in: 0...UIScreen.main.bounds.width),
                    y: CGFloat.random(in: 0...UIScreen.main.bounds.height)
                ),
                color: [Color.blue, Color.purple, Color.pink, Color.yellow].randomElement() ?? .blue,
                size: CGFloat.random(in: 2...6),
                opacity: Double.random(in: 0.1...0.3),
                scale: Double.random(in: 0.5...1.5)
            )
        }
    }
    
    private func animateParticles() {
        withAnimation(.easeInOut(duration: 3).repeatForever(autoreverses: true)) {
            for i in particles.indices {
                particles[i].position = CGPoint(
                    x: CGFloat.random(in: 0...UIScreen.main.bounds.width),
                    y: CGFloat.random(in: 0...UIScreen.main.bounds.height)
                )
                particles[i].opacity = Double.random(in: 0.1...0.5)
                particles[i].scale = Double.random(in: 0.5...2.0)
            }
        }
    }
}

struct Particle: Identifiable {
    let id = UUID()
    var position: CGPoint
    let color: Color
    let size: CGFloat
    var opacity: Double
    var scale: Double
}

struct PulsingView: View {
    @State private var isPulsing = false
    let content: AnyView
    
    init<Content: View>(@ViewBuilder content: () -> Content) {
        self.content = AnyView(content())
    }
    
    var body: some View {
        content
            .scaleEffect(isPulsing ? 1.05 : 1.0)
            .animation(.easeInOut(duration: 1.0).repeatForever(autoreverses: true), value: isPulsing)
            .onAppear {
                isPulsing = true
            }
    }
}

struct ShimmerEffect: View {
    @State private var phase: CGFloat = 0
    
    var body: some View {
        LinearGradient(
            gradient: Gradient(colors: [
                Color.white.opacity(0.3),
                Color.white.opacity(0.6),
                Color.white.opacity(0.3)
            ]),
            startPoint: .leading,
            endPoint: .trailing
        )
        .mask(
            Rectangle()
                .fill(
                    LinearGradient(
                        gradient: Gradient(stops: [
                            .init(color: .clear, location: 0),
                            .init(color: .black, location: 0.5),
                            .init(color: .clear, location: 1)
                        ]),
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
                .rotationEffect(.degrees(30))
                .offset(x: phase * 200 - 100)
        )
        .onAppear {
            withAnimation(.linear(duration: 2).repeatForever(autoreverses: false)) {
                phase = 1
            }
        }
    }
}

// MARK: - Dark Blue Background Variants

struct DarkBlueBackground: View {
    @State private var animate = false
    
    var body: some View {
        ZStack {
            // Deep space-like gradient
            LinearGradient(
                gradient: Gradient(colors: [
                    Color(red: 0.02, green: 0.05, blue: 0.2),  // Deep space
                    Color(red: 0.05, green: 0.1, blue: 0.4),   // Dark nebula
                    Color(red: 0.1, green: 0.2, blue: 0.6),    // Medium space
                    Color(red: 0.15, green: 0.3, blue: 0.8)    // Lighter space
                ]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            
            // Animated stars
            ForEach(0..<20, id: \.self) { index in
                Circle()
                    .fill(Color.white.opacity(0.8))
                    .frame(width: CGFloat.random(in: 1...3))
                    .position(
                        x: CGFloat.random(in: 0...UIScreen.main.bounds.width),
                        y: CGFloat.random(in: 0...UIScreen.main.bounds.height)
                    )
                    .opacity(animate ? 1.0 : 0.3)
                    .animation(
                        .easeInOut(duration: Double.random(in: 1...3))
                        .repeatForever(autoreverses: true)
                        .delay(Double(index) * 0.2),
                        value: animate
                    )
            }
            
            // Glowing orbs
            ForEach(0..<6, id: \.self) { index in
                Circle()
                    .fill(
                        RadialGradient(
                            gradient: Gradient(colors: [
                                Color.cyan.opacity(0.4),
                                Color.blue.opacity(0.2),
                                Color.clear
                            ]),
                            center: .center,
                            startRadius: 0,
                            endRadius: 120
                        )
                    )
                    .frame(width: CGFloat.random(in: 100...250))
                    .position(
                        x: CGFloat.random(in: 0...UIScreen.main.bounds.width),
                        y: CGFloat.random(in: 0...UIScreen.main.bounds.height)
                    )
                    .scaleEffect(animate ? 1.4 : 0.6)
                    .opacity(animate ? 0.3 : 0.05)
                    .animation(
                        .easeInOut(duration: Double.random(in: 5...10))
                        .repeatForever(autoreverses: true)
                        .delay(Double(index) * 1.2),
                        value: animate
                    )
            }
        }
        .onAppear {
            animate = true
        }
    }
}

struct OceanDepthBackground: View {
    @State private var animate = false
    
    var body: some View {
        ZStack {
            // Ocean depth gradient
            LinearGradient(
                gradient: Gradient(colors: [
                    Color(red: 0.0, green: 0.1, blue: 0.3),    // Deep ocean
                    Color(red: 0.05, green: 0.2, blue: 0.5),   // Mid ocean
                    Color(red: 0.1, green: 0.3, blue: 0.7),    // Shallow ocean
                    Color(red: 0.15, green: 0.4, blue: 0.9)    // Surface
                ]),
                startPoint: .top,
                endPoint: .bottom
            )
            
            // Bubbles
            ForEach(0..<12, id: \.self) { index in
                Circle()
                    .fill(
                        RadialGradient(
                            gradient: Gradient(colors: [
                                Color.white.opacity(0.3),
                                Color.cyan.opacity(0.1),
                                Color.clear
                            ]),
                            center: .center,
                            startRadius: 0,
                            endRadius: 50
                        )
                    )
                    .frame(width: CGFloat.random(in: 20...80))
                    .position(
                        x: CGFloat.random(in: 0...UIScreen.main.bounds.width),
                        y: CGFloat.random(in: 0...UIScreen.main.bounds.height)
                    )
                    .offset(y: animate ? -UIScreen.main.bounds.height : UIScreen.main.bounds.height)
                    .opacity(animate ? 0.8 : 0.2)
                    .animation(
                        .linear(duration: Double.random(in: 3...6))
                        .repeatForever(autoreverses: false)
                        .delay(Double(index) * 0.5),
                        value: animate
                    )
            }
        }
        .onAppear {
            animate = true
        }
    }
}

#Preview {
    ZStack {
        AnimatedBackground()
        Text("Animated Background")
            .font(.largeTitle)
            .fontWeight(.bold)
            .foregroundColor(.white)
    }
}
