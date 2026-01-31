import SwiftUI

struct ReflectionSummaryView: View {
    let commitment: Commitment
    
    var summary: ReflectionSummary {
        calculateSummary()
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            Text("Reflection Summary")
                .font(.system(size: 22, weight: .bold, design: .rounded))
                .foregroundColor(.textPrimary)
            
            if summary.totalReflections == 0 {
                emptyState
            } else {
                VStack(spacing: 16) {
                    // Current state
                    if let currentState = commitment.reflectionState {
                        CurrentReflectionCard(state: currentState)
                    }
                    
                    // Statistics
                    VStack(spacing: 12) {
                        StatRow(
                            label: "Total Reflections",
                            value: "\(summary.totalReflections)",
                            icon: "sparkles"
                        )
                        
                        StatRow(
                            label: "Yes",
                            value: "\(summary.yesCount)",
                            icon: "checkmark.circle.fill",
                            color: .accentGreen
                        )
                        
                        StatRow(
                            label: "Neutral",
                            value: "\(summary.neutralCount)",
                            icon: "minus.circle.fill",
                            color: .accentOrange
                        )
                        
                        StatRow(
                            label: "No",
                            value: "\(summary.noCount)",
                            icon: "xmark.circle.fill",
                            color: .accentPink
                        )
                    }
                    
                    // Most common
                    if let mostCommon = summary.mostCommonState {
                        MostCommonReflectionCard(state: mostCommon, count: summary.mostCommonCount)
                    }
                }
            }
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
                                Color.accentPurple.opacity(0.3),
                                Color.accentPurple.opacity(0.1)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        lineWidth: 1
                    )
            }
        )
    }
    
    private func calculateSummary() -> ReflectionSummary {
        var yesCount = 0
        var neutralCount = 0
        var noCount = 0
        
        for entry in commitment.history.entries where entry.type == .reflectionChanged {
            if let newState = ReflectionState(rawValue: entry.newValue?.capitalized ?? "") {
                switch newState {
                case .yes: yesCount += 1
                case .neutral: neutralCount += 1
                case .no: noCount += 1
                }
            }
        }
        
        let total = yesCount + neutralCount + noCount
        let mostCommon: ReflectionState?
        let mostCommonCount: Int
        
        if yesCount >= neutralCount && yesCount >= noCount && yesCount > 0 {
            mostCommon = .yes
            mostCommonCount = yesCount
        } else if neutralCount >= noCount && neutralCount > 0 {
            mostCommon = .neutral
            mostCommonCount = neutralCount
        } else if noCount > 0 {
            mostCommon = .no
            mostCommonCount = noCount
        } else {
            mostCommon = nil
            mostCommonCount = 0
        }
        
        return ReflectionSummary(
            totalReflections: total,
            yesCount: yesCount,
            neutralCount: neutralCount,
            noCount: noCount,
            mostCommonState: mostCommon,
            mostCommonCount: mostCommonCount
        )
    }
    
    private var emptyState: some View {
        VStack(spacing: 12) {
            Image(systemName: "sparkles")
                .font(.system(size: 40))
                .foregroundColor(.textSecondary)
            
            Text("No reflections yet")
                .font(.system(size: 16, weight: .medium))
                .foregroundColor(.textSecondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 40)
    }
}

struct ReflectionSummary {
    let totalReflections: Int
    let yesCount: Int
    let neutralCount: Int
    let noCount: Int
    let mostCommonState: ReflectionState?
    let mostCommonCount: Int
}

struct CurrentReflectionCard: View {
    let state: ReflectionState
    
    var body: some View {
        HStack(spacing: 16) {
            ReflectionStateCircle(state: state, size: 60)
            
            VStack(alignment: .leading, spacing: 4) {
                Text("Current Reflection")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(.textSecondary)
                
                Text(state.displayName)
                    .font(.system(size: 24, weight: .bold))
                    .foregroundColor(.textPrimary)
            }
            
            Spacer()
        }
        .padding(16)
        .background(
            LinearGradient(
                colors: [
                    stateColor(state).opacity(0.2),
                    stateColor(state).opacity(0.1)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        )
        .cornerRadius(12)
    }
    
    private func stateColor(_ state: ReflectionState) -> Color {
        switch state {
        case .yes: return .accentGreen
        case .neutral: return .accentOrange
        case .no: return .accentPink
        }
    }
}

struct StatRow: View {
    let label: String
    let value: String
    let icon: String
    var color: Color = .accentBlue
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.system(size: 18))
                .foregroundColor(color)
                .frame(width: 30)
            
            Text(label)
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(.textPrimary)
            
            Spacer()
            
            Text(value)
                .font(.system(size: 16, weight: .bold))
                .foregroundColor(.textPrimary)
        }
        .padding(12)
        .background(Color.cardBackground.opacity(0.5))
        .cornerRadius(10)
    }
}

struct MostCommonReflectionCard: View {
    let state: ReflectionState
    let count: Int
    
    var body: some View {
        HStack(spacing: 12) {
            ReflectionStateCircle(state: state, size: 40)
            
            VStack(alignment: .leading, spacing: 4) {
                Text("Most Common")
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(.textSecondary)
                
                Text("\(state.displayName) (\(count) times)")
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(.textPrimary)
            }
            
            Spacer()
        }
        .padding(16)
        .background(Color.cardBackground.opacity(0.5))
        .cornerRadius(12)
    }
}

extension ReflectionState {
    var displayName: String {
        switch self {
        case .yes: return "Yes"
        case .neutral: return "Neutral"
        case .no: return "No"
        }
    }
}
