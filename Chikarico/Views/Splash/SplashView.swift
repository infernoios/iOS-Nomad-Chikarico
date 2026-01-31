import SwiftUI

struct SplashScreen: View {
    var loading: Bool
    @State private var rotationAngle: Double = 0
    @State private var pulseScale: CGFloat = 1.0
    @State private var gradientOffset: CGFloat = 0
    @State private var particleOffset: CGFloat = 0
    
    var body: some View {
        ZStack {
            // Animated gradient background
            LinearGradient(
                colors: [
                    Color.gradientStart,
                    Color.gradientEnd,
                    Color.backgroundPrimary
                ],
                startPoint: UnitPoint(x: 0.5 + sin(gradientOffset) * 0.3, y: 0.5 + cos(gradientOffset) * 0.3),
                endPoint: UnitPoint(x: 0.5 - sin(gradientOffset) * 0.3, y: 0.5 - cos(gradientOffset) * 0.3)
            )
            .ignoresSafeArea()
            .animation(.linear(duration: 3).repeatForever(autoreverses: true), value: gradientOffset)
            
            // Animated floating particles
            ForEach(0..<8, id: \.self) { index in
                Circle()
                    .fill(
                        RadialGradient(
                            colors: [
                                [Color.accentBlue, Color.accentPurple, Color.accentPink][index % 3].opacity(0.3),
                                [Color.accentBlue, Color.accentPurple, Color.accentPink][index % 3].opacity(0.0)
                            ],
                            center: .center,
                            startRadius: 0,
                            endRadius: 60
                        )
                    )
                    .frame(width: 120, height: 120)
                    .blur(radius: 20)
                    .offset(
                        x: cos(Double(index) * .pi / 4 + particleOffset) * 150,
                        y: sin(Double(index) * .pi / 4 + particleOffset) * 150
                    )
                    .animation(
                        .easeInOut(duration: 4 + Double(index) * 0.5)
                        .repeatForever(autoreverses: true)
                        .delay(Double(index) * 0.2),
                        value: particleOffset
                    )
            }
            
            VStack(spacing: 32) {
                ZStack {
                    // Outer rotating ring
                    Circle()
                        .stroke(
                            AngularGradient(
                                colors: [
                                    Color.accentBlue.opacity(0.3),
                                    Color.accentPurple.opacity(0.5),
                                    Color.accentPink.opacity(0.3),
                                    Color.accentBlue.opacity(0.3)
                                ],
                                center: .center,
                                angle: .degrees(rotationAngle)
                            ),
                            lineWidth: 4
                        )
                        .frame(width: 140, height: 140)
                        .rotationEffect(.degrees(rotationAngle))
                    
                    // Middle pulsing ring
                    Circle()
                        .stroke(
                            LinearGradient(
                                colors: [
                                    Color.accentPurple.opacity(0.4),
                                    Color.accentBlue.opacity(0.2)
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            lineWidth: 3
                        )
                        .frame(width: 120, height: 120)
                        .scaleEffect(pulseScale)
                        .opacity(0.6)
                    
                    // Inner glow
                    Circle()
                        .fill(
                            RadialGradient(
                                colors: [
                                    Color.accentPurple.opacity(0.5),
                                    Color.accentBlue.opacity(0.3),
                                    Color.clear
                                ],
                                center: .center,
                                startRadius: 20,
                                endRadius: 60
                            )
                        )
                        .frame(width: 120, height: 120)
                        .blur(radius: 15)
                        .scaleEffect(pulseScale * 0.9)
                    
                    // App icon
                    Image("icon_app_logo")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 80, height: 80)
                        .shadow(color: .accentPurple.opacity(0.5), radius: 20, x: 0, y: 0)
                }
                
                // App name with gradient
                Text("Chikarico")
                    .font(.system(size: 48, weight: .bold, design: .rounded))
                    .foregroundStyle(
                        LinearGradient(
                            colors: [
                                Color.textPrimary,
                                Color.accentBlue,
                                Color.accentPurple,
                                Color.accentPink
                            ],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .shadow(color: .accentPurple.opacity(0.4), radius: 15, x: 0, y: 5)
                
                // Loading indicator
                HStack(spacing: 8) {
                    ForEach(0..<3, id: \.self) { index in
                        Circle()
                            .fill(
                                LinearGradient(
                                    colors: [
                                        [Color.accentBlue, Color.accentPurple, Color.accentPink][index],
                                        [Color.accentBlue, Color.accentPurple, Color.accentPink][index].opacity(0.5)
                                    ],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .frame(width: 12, height: 12)
                            .scaleEffect(pulseScale)
                            .animation(
                                .easeInOut(duration: 0.8)
                                .repeatForever(autoreverses: true)
                                .delay(Double(index) * 0.2),
                                value: pulseScale
                            )
                    }
                }
                .padding(.top, 8)
            }
        }
        .onAppear {
            // Start infinite animations
            withAnimation(.linear(duration: 8).repeatForever(autoreverses: false)) {
                rotationAngle = 360
            }
            
            withAnimation(.easeInOut(duration: 1.5).repeatForever(autoreverses: true)) {
                pulseScale = 1.2
            }
            
            withAnimation(.linear(duration: 5).repeatForever(autoreverses: true)) {
                gradientOffset = .pi * 2
            }
            
            withAnimation(.linear(duration: 6).repeatForever(autoreverses: false)) {
                particleOffset = .pi * 2
            }
        }
    }
}
