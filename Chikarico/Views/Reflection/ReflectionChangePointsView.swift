import SwiftUI

struct ReflectionChangePointsView: View {
    let commitment: Commitment
    
    var changePoints: [ReflectionChangePoint] {
        var points: [ReflectionChangePoint] = []
        
        for entry in commitment.history.entries where entry.type == .reflectionChanged {
            let oldState = ReflectionState(rawValue: entry.oldValue?.capitalized ?? "")
            let newState = ReflectionState(rawValue: entry.newValue?.capitalized ?? "")
            
            if let newState = newState {
                points.append(ReflectionChangePoint(
                    date: entry.timestamp,
                    from: oldState,
                    to: newState,
                    significance: calculateSignificance(from: oldState, to: newState)
                ))
            }
        }
        
        return points.sorted { $0.date > $1.date }
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            Text("Reflection Change Points")
                .font(.system(size: 22, weight: .bold, design: .rounded))
                .foregroundColor(.textPrimary)
            
            if changePoints.isEmpty {
                emptyState
            } else {
                ScrollView {
                    VStack(spacing: 16) {
                        ForEach(changePoints) { point in
                            ReflectionChangePointCard(point: point)
                        }
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
    
    private func calculateSignificance(from oldState: ReflectionState?, to newState: ReflectionState) -> ChangeSignificance {
        guard let oldState = oldState else {
            return .moderate // First reflection
        }
        
        switch (oldState, newState) {
        case (.no, .yes), (.yes, .no):
            return .high // Complete reversal
        case (.neutral, .yes), (.neutral, .no):
            return .moderate // From neutral to decision
        case (.yes, .neutral), (.no, .neutral):
            return .low // To neutral
        default:
            return .low
        }
    }
    
    private var emptyState: some View {
        VStack(spacing: 12) {
            Image(systemName: "arrow.triangle.2.circlepath")
                .font(.system(size: 40))
                .foregroundColor(.textSecondary)
            
            Text("No change points")
                .font(.system(size: 16, weight: .medium))
                .foregroundColor(.textSecondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 40)
    }
}

struct ReflectionChangePoint: Identifiable {
    let id = UUID()
    let date: Date
    let from: ReflectionState?
    let to: ReflectionState
    let significance: ChangeSignificance
}

enum ChangeSignificance {
    case low
    case moderate
    case high
    
    var displayName: String {
        switch self {
        case .low: return "Minor"
        case .moderate: return "Moderate"
        case .high: return "Major"
        }
    }
    
    var color: Color {
        switch self {
        case .low: return .textSecondary
        case .moderate: return .accentOrange
        case .high: return .accentPink
        }
    }
}

struct ReflectionChangePointCard: View {
    let point: ReflectionChangePoint
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                // From state
                if let fromState = point.from {
                    ReflectionStateCircle(state: fromState, size: 32)
                } else {
                    Circle()
                        .fill(Color.cardBackground)
                        .frame(width: 32, height: 32)
                        .overlay(
                            Text("?")
                                .font(.system(size: 14, weight: .bold))
                                .foregroundColor(.textSecondary)
                        )
                }
                
                // Arrow
                Image(systemName: "arrow.right")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(.textSecondary)
                
                // To state
                ReflectionStateCircle(state: point.to, size: 32)
                
                Spacer()
                
                // Significance badge
                HStack(spacing: 4) {
                    Circle()
                        .fill(point.significance.color)
                        .frame(width: 8, height: 8)
                    
                    Text(point.significance.displayName)
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundColor(point.significance.color)
                }
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
                .background(point.significance.color.opacity(0.2))
                .cornerRadius(8)
            }
            
            HStack {
                Text(point.date.formattedRelative())
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(.textPrimary)
                
                Spacer()
                
                Text(point.date.formattedShort())
                    .font(.system(size: 12))
                    .foregroundColor(.textSecondary)
            }
        }
        .padding(16)
        .background(
            ZStack {
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color.cardBackground.opacity(0.5))
                
                RoundedRectangle(cornerRadius: 12)
                    .stroke(
                        point.significance.color.opacity(0.3),
                        lineWidth: point.significance == .high ? 2 : 1
                    )
            }
        )
    }
}
