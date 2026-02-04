import SwiftUI

struct QuietHighlightsView: View {
    @EnvironmentObject var router: Router
    @EnvironmentObject var persistence: PersistenceService
    let commitments: [Commitment]
    
    var highlights: [QuietHighlight] {
        calculateHighlights()
    }
    
    var body: some View {
        ZStack {
            // Gradient background
            LinearGradient(
                colors: [
                    Color.gradientStart,
                    Color.gradientEnd,
                    Color.backgroundPrimary
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Header
                HStack {
                    Button(action: { router.pop() }) {
                        ZStack {
                            Circle()
                                .fill(Color.cardBackground.opacity(0.6))
                                .frame(width: 40, height: 40)
                            
                            Image(systemName: "chevron.left")
                                .font(.system(size: 18, weight: .bold))
                                .foregroundColor(.textPrimary)
                        }
                    }
                    
                    Spacer()
                    
                    VStack(spacing: 4) {
                        Text("Quiet Highlights")
                            .font(.system(size: 28, weight: .bold, design: .rounded))
                            .foregroundStyle(
                                LinearGradient(
                                    colors: [.textPrimary, .accentOrange],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                        
                        Text("Small wins worth celebrating")
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(.textSecondary)
                    }
                    
                    Spacer()
                    
                    // Spacer for symmetry
                    Circle()
                        .fill(Color.clear)
                        .frame(width: 40, height: 40)
                }
                .padding(.horizontal, 20)
                .safeAreaInset(edge: .top) {
                    Color.clear.frame(height: 0)
                }
                .padding(.top, 8)
                .padding(.bottom, 20)
                
                // Content
                if highlights.isEmpty {
                    emptyStateView
                } else {
                    ScrollView {
                        VStack(spacing: 16) {
                            ForEach(highlights) { highlight in
                                HighlightCard(highlight: highlight, router: router)
                            }
                        }
                        .padding(.horizontal, 20)
                        .padding(.bottom, 100)
                    }
                }
            }
        }
    }
    
    // MARK: - Empty State
    private var emptyStateView: some View {
        VStack(spacing: 24) {
            ZStack {
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [.accentOrange.opacity(0.3), .yellow.opacity(0.2)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 120, height: 120)
                    .blur(radius: 20)
                
                Image(systemName: "sparkles")
                    .font(.system(size: 60, weight: .bold))
                    .foregroundStyle(
                        LinearGradient(
                            colors: [.accentOrange, .yellow],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
            }
            
            VStack(spacing: 12) {
                Text("No Highlights Yet")
                    .font(.system(size: 24, weight: .bold, design: .rounded))
                    .foregroundColor(.textPrimary)
                
                Text("Your achievements and milestones will appear here")
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(.textSecondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 40)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding(.bottom, 100)
    }
    
    // MARK: - Calculation
    private func calculateHighlights() -> [QuietHighlight] {
        var highlights: [QuietHighlight] = []
        let calendar = Calendar.current
        let today = Date()
        
        for commitment in commitments where commitment.status.isActive {
            let duration = commitment.activeDuration
            let days = Int(duration / (24 * 3600))
            
            // 7 days milestone
            if days >= 7 && days < 14 {
                highlights.append(QuietHighlight(
                    commitment: commitment,
                    title: "One Week Strong",
                    description: "\(commitment.title) has been active for a week",
                    icon: "calendar.badge.clock",
                    color: .accentBlue
                ))
            }
            
            // 30 days milestone
            if days >= 30 && days < 60 {
                highlights.append(QuietHighlight(
                    commitment: commitment,
                    title: "One Month Milestone",
                    description: "\(commitment.title) reached its first month",
                    icon: "star.fill",
                    color: .accentGreen
                ))
            }
            
            // 100 days milestone
            if days >= 100 && days < 110 {
                highlights.append(QuietHighlight(
                    commitment: commitment,
                    title: "100 Days",
                    description: "\(commitment.title) has been active for 100 days",
                    icon: "trophy.fill",
                    color: .accentOrange
                ))
            }
            
            // Consistent reflections
            let recentReflections = commitment.history.entries
                .filter { $0.type == .reflectionChanged }
                .filter { 
                    if let date = calendar.date(byAdding: .day, value: -30, to: today) {
                        return $0.timestamp >= date
                    }
                    return false
                }
            
            if recentReflections.count >= 4 {
                highlights.append(QuietHighlight(
                    commitment: commitment,
                    title: "Consistent Reflection",
                    description: "Regularly reflecting on \(commitment.title)",
                    icon: "sparkles",
                    color: .accentPurple
                ))
            }
            
            // No pauses in last 90 days
            let recentPauses = commitment.history.entries
                .filter { $0.type == .paused }
                .filter { 
                    if let date = calendar.date(byAdding: .day, value: -90, to: today) {
                        return $0.timestamp >= date
                    }
                    return false
                }
            
            if recentPauses.isEmpty && days >= 90 {
                highlights.append(QuietHighlight(
                    commitment: commitment,
                    title: "Uninterrupted",
                    description: "\(commitment.title) has been active for 90+ days without pause",
                    icon: "flame.fill",
                    color: .accentPink
                ))
            }
        }
        
        return highlights
    }
}

// MARK: - Models
struct QuietHighlight: Identifiable {
    let id = UUID()
    let commitment: Commitment
    let title: String
    let description: String
    let icon: String
    let color: Color
}

// MARK: - Highlight Card
struct HighlightCard: View {
    let highlight: QuietHighlight
    let router: Router
    
    var body: some View {
        Button(action: {
            router.push(.commitmentDetail(id: highlight.commitment.id))
        }) {
            HStack(spacing: 16) {
                // Icon
                ZStack {
                    RoundedRectangle(cornerRadius: 16)
                        .fill(
                            LinearGradient(
                                colors: [
                                    highlight.color.opacity(0.3),
                                    highlight.color.opacity(0.2)
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 60, height: 60)
                        .shadow(color: highlight.color.opacity(0.3), radius: 8, x: 0, y: 4)
                    
                    Image(systemName: highlight.icon)
                        .font(.system(size: 28, weight: .bold))
                        .foregroundColor(highlight.color)
                }
                
                // Content
                VStack(alignment: .leading, spacing: 6) {
                    Text(highlight.title)
                        .font(.system(size: 18, weight: .bold, design: .rounded))
                        .foregroundColor(.textPrimary)
                    
                    Text(highlight.description)
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(.textSecondary)
                        .lineLimit(2)
                }
                
                Spacer()
                
                // Arrow
                Image(systemName: "chevron.right")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(.textSecondary.opacity(0.5))
            }
            .padding(20)
            .background(
                ZStack {
                    RoundedRectangle(cornerRadius: 20)
                        .fill(
                            LinearGradient(
                                colors: [
                                    Color.cardBackground,
                                    Color.cardBackground.opacity(0.8)
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                    
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(
                            LinearGradient(
                                colors: [
                                    highlight.color.opacity(0.4),
                                    highlight.color.opacity(0.1)
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            lineWidth: 1
                        )
                }
            )
            .shadow(color: .black.opacity(0.1), radius: 12, x: 0, y: 6)
        }
        .buttonStyle(PlainButtonStyle())
    }
}
