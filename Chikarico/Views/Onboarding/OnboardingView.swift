import SwiftUI

struct OnboardingView: View {
    @EnvironmentObject var persistence: PersistenceService
    @EnvironmentObject var router: Router
    @State private var currentPage = 0
    
    private let pages: [OnboardingPage] = [
        OnboardingPage(
            icon: "calendar.badge.clock",
            title: "Welcome to Chikarico",
            description: "See and understand your recurring commitments over time. A commitment is anything you once agreed to keep repeating."
        ),
        OnboardingPage(
            icon: "arrow.triangle.2.circlepath",
            title: "What is a Commitment?",
            description: "Subscriptions, memberships, bills, donations, courses, or personal agreements. We observe commitments, we don't judge them."
        ),
        OnboardingPage(
            icon: "lock.shield",
            title: "Local-First & Private",
            description: "All your data stays on your device. No accounts, no cloud sync, no external services. Your commitments are yours alone."
        )
    ]
    
    var body: some View {
        ZStack {
            // Animated gradient background
            LinearGradient(
                colors: [
                    Color(red: 0.1, green: 0.05, blue: 0.2),
                    Color(red: 0.15, green: 0.1, blue: 0.3),
                    Color(red: 0.2, green: 0.15, blue: 0.25)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            
            VStack(spacing: 0) {
                TabView(selection: $currentPage) {
                    ForEach(Array(pages.enumerated()), id: \.offset) { index, page in
                        OnboardingPageView(page: page, index: index)
                            .tag(index)
                    }
                }
                .tabViewStyle(.page(indexDisplayMode: .never))
                
                // Page indicator dots
                HStack(spacing: 12) {
                    ForEach(0..<pages.count, id: \.self) { index in
                        Circle()
                            .fill(
                                currentPage == index
                                    ? LinearGradient(
                                        colors: [.accentBlue, .accentPurple],
                                        startPoint: .leading,
                                        endPoint: .trailing
                                    )
                                    : LinearGradient(
                                        colors: [.textSecondary.opacity(0.3), .textSecondary.opacity(0.2)],
                                        startPoint: .leading,
                                        endPoint: .trailing
                                    )
                            )
                            .frame(width: currentPage == index ? 32 : 10, height: 10)
                            .animation(.spring(response: 0.3, dampingFraction: 0.7), value: currentPage)
                    }
                }
                .padding(.bottom, 20)
                
                // Show "Start" button only on last page
                if currentPage == pages.count - 1 {
                    Button(action: handleStart) {
                        HStack(spacing: 12) {
                            Text("Get Started")
                                .font(.system(size: 20, weight: .bold, design: .rounded))
                            
                            Image(systemName: "arrow.right")
                                .font(.system(size: 18, weight: .bold))
                        }
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: 64)
                        .background(
                            ZStack {
                                LinearGradient(
                                    colors: [.accentBlue, .accentPurple, .accentPink],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                                
                                LinearGradient(
                                    colors: [
                                        Color.white.opacity(0.3),
                                        Color.clear
                                    ],
                                    startPoint: .top,
                                    endPoint: .bottom
                                )
                            }
                        )
                        .cornerRadius(24)
                        .shadow(color: .accentPurple.opacity(0.5), radius: 20, x: 0, y: 10)
                        .shadow(color: .black.opacity(0.3), radius: 10, x: 0, y: 5)
                        .padding(.horizontal, 24)
                        .padding(.bottom, 40)
                    }
                    .transition(.move(edge: .bottom).combined(with: .opacity))
                } else {
                    // Show "Next" button on other pages
                    Button(action: {
                        withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                            currentPage += 1
                        }
                    }) {
                        HStack(spacing: 12) {
                            Text("Next")
                                .font(.system(size: 20, weight: .bold, design: .rounded))
                            
                            Image(systemName: "arrow.right")
                                .font(.system(size: 18, weight: .bold))
                        }
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: 64)
                        .background(
                            ZStack {
                                LinearGradient(
                                    colors: [.accentBlue, .accentPurple],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                                
                                LinearGradient(
                                    colors: [
                                        Color.white.opacity(0.2),
                                        Color.clear
                                    ],
                                    startPoint: .top,
                                    endPoint: .bottom
                                )
                            }
                        )
                        .cornerRadius(24)
                        .shadow(color: .accentBlue.opacity(0.4), radius: 15, x: 0, y: 8)
                        .padding(.horizontal, 24)
                        .padding(.bottom, 40)
                    }
                    .transition(.move(edge: .bottom).combined(with: .opacity))
                }
            }
        }
    }
    
    private func handleStart() {
        persistence.appState.preferences.onboardingCompleted = true
        router.setRoot(.home)
    }
}

struct OnboardingPage {
    let icon: String
    let title: String
    let description: String
}

struct OnboardingPageView: View {
    let page: OnboardingPage
    let index: Int
    @State private var iconScale: CGFloat = 0.8
    @State private var iconRotation: Double = 0
    
    private var gradientColors: [Color] {
        switch index {
        case 0:
            return [.accentBlue, .accentPurple]
        case 1:
            return [.accentPurple, .accentPink]
        default:
            return [.accentGreen, .accentBlue]
        }
    }
    
    var body: some View {
        VStack(spacing: 30) {
            Spacer()
                .frame(maxHeight: 60)
            
            ZStack {
                // Animated background particles
                ForEach(0..<6, id: \.self) { i in
                    Circle()
                        .fill(
                            RadialGradient(
                                colors: [
                                    gradientColors[0].opacity(0.2),
                                    gradientColors[1].opacity(0.1),
                                    Color.clear
                                ],
                                center: .center,
                                startRadius: 0,
                                endRadius: 50
                            )
                        )
                        .frame(width: 80, height: 80)
                        .blur(radius: 20)
                        .offset(
                            x: cos(Double(i) * .pi / 3 + iconRotation) * 100,
                            y: sin(Double(i) * .pi / 3 + iconRotation) * 100
                        )
                }
                
                // Glow effect
                Circle()
                    .fill(
                        RadialGradient(
                            colors: [
                                gradientColors[0].opacity(0.4),
                                gradientColors[1].opacity(0.3),
                                Color.clear
                            ],
                            center: .center,
                            startRadius: 40,
                            endRadius: 140
                        )
                    )
                    .frame(width: 280, height: 280)
                    .blur(radius: 50)
                    .scaleEffect(iconScale)
                
                // Icon with custom assets
                Group {
                    if index == 0 {
                        Image("icon_onboarding_1")
                            .resizable()
                            .scaledToFit()
                    } else if index == 1 {
                        Image("icon_onboarding_2")
                            .resizable()
                            .scaledToFit()
                    } else {
                        Image("icon_onboarding_3")
                            .resizable()
                            .scaledToFit()
                    }
                }
                .frame(width: 160, height: 160)
                .scaleEffect(iconScale)
                .rotationEffect(.degrees(iconRotation * 10))
                .shadow(color: gradientColors[0].opacity(0.6), radius: 40, x: 0, y: 0)
            }
            
            VStack(spacing: 20) {
                Text(page.title)
                    .font(.system(size: 32, weight: .bold, design: .rounded))
                    .foregroundStyle(
                        LinearGradient(
                            colors: [.textPrimary, gradientColors[0], gradientColors[1]],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .multilineTextAlignment(.center)
                    .shadow(color: gradientColors[0].opacity(0.4), radius: 15, x: 0, y: 5)
                    .padding(.horizontal, 32)
                    .fixedSize(horizontal: false, vertical: true)
                
                Text(page.description)
                    .font(.system(size: 17, weight: .medium, design: .rounded))
                    .foregroundColor(.textSecondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 32)
                    .lineSpacing(5)
                    .fixedSize(horizontal: false, vertical: true)
            }
            
            Spacer()
        }
        .onAppear {
            withAnimation(.spring(response: 0.8, dampingFraction: 0.6)) {
                iconScale = 1.0
            }
            withAnimation(.linear(duration: 20).repeatForever(autoreverses: false)) {
                iconRotation = 360
            }
        }
    }
}
