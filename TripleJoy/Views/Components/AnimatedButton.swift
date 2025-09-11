import SwiftUI

struct AnimatedButton: View {
    let title: String
    let icon: String?
    let action: () -> Void
    let style: ButtonStyle
    
    @State private var isPressed = false
    @State private var isAnimating = false
    
    enum ButtonStyle {
        case primary
        case secondary
        case destructive
        case success
    }
    
    init(
        title: String,
        icon: String? = nil,
        style: ButtonStyle = .primary,
        action: @escaping () -> Void
    ) {
        self.title = title
        self.icon = icon
        self.style = style
        self.action = action
    }
    
    var body: some View {
        Button(action: {
            withAnimation(.easeInOut(duration: 0.1)) {
                isPressed = true
            }
            
            // Haptic feedback
            let impactFeedback = UIImpactFeedbackGenerator(style: .medium)
            impactFeedback.impactOccurred()
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                withAnimation(.easeInOut(duration: 0.1)) {
                    isPressed = false
                }
                action()
            }
        }) {
            HStack(spacing: 8) {
                if let icon = icon {
                    Image(systemName: icon)
                        .font(.headline)
                        .scaleEffect(isAnimating ? 1.2 : 1.0)
                        .animation(.easeInOut(duration: 0.3), value: isAnimating)
                }
                
                Text(title)
                    .font(.headline)
                    .fontWeight(.semibold)
            }
            .foregroundColor(foregroundColor)
            .frame(maxWidth: .infinity)
            .padding()
            .background(backgroundColor)
            .cornerRadius(12)
            .scaleEffect(isPressed ? 0.95 : 1.0)
            .shadow(radius: isPressed ? 2 : 5)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(borderColor, lineWidth: 2)
            )
        }
        .buttonStyle(PlainButtonStyle())
        .onAppear {
            withAnimation(.easeInOut(duration: 2.0).repeatForever(autoreverses: true)) {
                isAnimating = true
            }
        }
    }
    
    private var backgroundColor: Color {
        switch style {
        case .primary:
            return Color.blue
        case .secondary:
            return Color.gray.opacity(0.2)
        case .destructive:
            return Color.red
        case .success:
            return Color.green
        }
    }
    
    private var foregroundColor: Color {
        switch style {
        case .primary, .destructive, .success:
            return .white
        case .secondary:
            return .primary
        }
    }
    
    private var borderColor: Color {
        switch style {
        case .primary:
            return Color.blue.opacity(0.3)
        case .secondary:
            return Color.gray.opacity(0.3)
        case .destructive:
            return Color.red.opacity(0.3)
        case .success:
            return Color.green.opacity(0.3)
        }
    }
}

struct PulsingButton: View {
    let title: String
    let icon: String?
    let action: () -> Void
    
    @State private var isPulsing = false
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 8) {
                if let icon = icon {
                    Image(systemName: icon)
                        .font(.headline)
                }
                
                Text(title)
                    .font(.headline)
                    .fontWeight(.semibold)
            }
            .foregroundColor(.white)
            .frame(maxWidth: .infinity)
            .padding()
            .background(
                LinearGradient(
                    gradient: Gradient(colors: [Color.blue, Color.purple]),
                    startPoint: .leading,
                    endPoint: .trailing
                )
            )
            .cornerRadius(12)
            .scaleEffect(isPulsing ? 1.05 : 1.0)
            .shadow(radius: isPulsing ? 8 : 5)
            .animation(.easeInOut(duration: 1.0).repeatForever(autoreverses: true), value: isPulsing)
        }
        .buttonStyle(PlainButtonStyle())
        .onAppear {
            isPulsing = true
        }
    }
}

struct ShimmerButton: View {
    let title: String
    let icon: String?
    let action: () -> Void
    
    @State private var phase: CGFloat = 0
    
    var body: some View {
        Button(action: action) {
            ZStack {
                // Background
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color.blue)
                
                // Shimmer effect
                RoundedRectangle(cornerRadius: 12)
                    .fill(
                        LinearGradient(
                            gradient: Gradient(colors: [
                                Color.white.opacity(0.3),
                                Color.white.opacity(0.6),
                                Color.white.opacity(0.3)
                            ]),
                            startPoint: .leading,
                            endPoint: .trailing
                        )
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
                
                // Content
                HStack(spacing: 8) {
                    if let icon = icon {
                        Image(systemName: icon)
                            .font(.headline)
                    }
                    
                    Text(title)
                        .font(.headline)
                        .fontWeight(.semibold)
                }
                .foregroundColor(.white)
            }
            .frame(maxWidth: .infinity)
            .padding()
        }
        .buttonStyle(PlainButtonStyle())
        .onAppear {
            withAnimation(.linear(duration: 2).repeatForever(autoreverses: false)) {
                phase = 1
            }
        }
    }
}

#Preview {
    VStack(spacing: 20) {
        AnimatedButton(title: "Primary Button", icon: "star.fill", style: .primary) {
            print("Primary tapped")
        }
        
        AnimatedButton(title: "Secondary Button", icon: "gear", style: .secondary) {
            print("Secondary tapped")
        }
        
        PulsingButton(title: "Pulsing Button", icon: "heart.fill") {
            print("Pulsing tapped")
        }
        
        ShimmerButton(title: "Shimmer Button", icon: "sparkles") {
            print("Shimmer tapped")
        }
    }
    .padding()
}
