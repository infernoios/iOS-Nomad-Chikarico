import SwiftUI

struct LifecycleView: View {
    let commitment: Commitment
    
    var currentStage: LifecycleStage {
        switch commitment.status {
        case .active: return .active
        case .paused: return .paused
        case .ending: return .ending
        case .archived: return .archived
        }
    }
    
    var possibleTransitions: [LifecycleStage] {
        switch currentStage {
        case .active:
            return [.paused, .ending, .archived]
        case .paused:
            return [.active, .archived]
        case .ending:
            return [.archived]
        case .archived:
            return []
        }
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            Text("Lifecycle")
                .font(.system(size: 22, weight: .bold, design: .rounded))
                .foregroundColor(.textPrimary)
            
            // Lifecycle diagram
            VStack(spacing: 16) {
                // Top row: Active and Paused
                HStack(spacing: 20) {
                    LifecycleStageView(
                        stage: .active,
                        isCurrent: currentStage == .active,
                        isPossible: possibleTransitions.contains(.active)
                    )
                    
                    LifecycleStageView(
                        stage: .paused,
                        isCurrent: currentStage == .paused,
                        isPossible: possibleTransitions.contains(.paused)
                    )
                }
                
                // Arrows
                HStack(spacing: 20) {
                    if currentStage == .active {
                        ArrowView(direction: .down, isActive: true)
                    } else {
                        ArrowView(direction: .down, isActive: false)
                    }
                    
                    if currentStage == .paused {
                        ArrowView(direction: .down, isActive: true)
                    } else {
                        ArrowView(direction: .down, isActive: false)
                    }
                }
                
                // Bottom row: Ending and Archived
                HStack(spacing: 20) {
                    LifecycleStageView(
                        stage: .ending,
                        isCurrent: currentStage == .ending,
                        isPossible: possibleTransitions.contains(.ending)
                    )
                    
                    LifecycleStageView(
                        stage: .archived,
                        isCurrent: currentStage == .archived,
                        isPossible: possibleTransitions.contains(.archived)
                    )
                }
            }
            .padding(.vertical, 16)
            
            // Current status info
            HStack(spacing: 12) {
                Circle()
                    .fill(currentStageColor)
                    .frame(width: 12, height: 12)
                
                Text("Current: \(currentStage.displayName)")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(.textPrimary)
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
    
    private var currentStageColor: Color {
        switch currentStage {
        case .active: return .accentGreen
        case .paused: return .accentOrange
        case .ending: return .accentPink
        case .archived: return .gray
        }
    }
}

enum LifecycleStage {
    case active
    case paused
    case ending
    case archived
    
    var displayName: String {
        switch self {
        case .active: return "Active"
        case .paused: return "Paused"
        case .ending: return "Ending"
        case .archived: return "Archived"
        }
    }
    
    var color: Color {
        switch self {
        case .active: return .accentGreen
        case .paused: return .accentOrange
        case .ending: return .accentPink
        case .archived: return .gray
        }
    }
}

struct LifecycleStageView: View {
    let stage: LifecycleStage
    let isCurrent: Bool
    let isPossible: Bool
    
    var body: some View {
        VStack(spacing: 8) {
            ZStack {
                RoundedRectangle(cornerRadius: 12)
                    .fill(
                        isCurrent
                            ? stage.color
                            : (isPossible ? stage.color.opacity(0.3) : Color.cardBackground)
                    )
                    .frame(width: 80, height: 60)
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(
                                isCurrent
                                    ? Color.white.opacity(0.3)
                                    : (isPossible ? stage.color.opacity(0.5) : Color.textSecondary.opacity(0.2)),
                                lineWidth: isCurrent ? 3 : 1
                            )
                    )
                
                if isCurrent {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.system(size: 24))
                        .foregroundColor(.white)
                } else {
                    Text(stage.displayName.prefix(1))
                        .font(.system(size: 20, weight: .bold))
                        .foregroundColor(isPossible ? stage.color : .textSecondary)
                }
            }
            
            Text(stage.displayName)
                .font(.system(size: 12, weight: .medium))
                .foregroundColor(isCurrent ? .textPrimary : .textSecondary)
        }
    }
}

struct ArrowView: View {
    enum Direction {
        case down
        case right
        case left
    }
    
    let direction: Direction
    let isActive: Bool
    
    var body: some View {
        Image(systemName: arrowIcon)
            .font(.system(size: 16, weight: .semibold))
            .foregroundColor(isActive ? .accentBlue : .textSecondary.opacity(0.3))
    }
    
    private var arrowIcon: String {
        switch direction {
        case .down: return "arrow.down"
        case .right: return "arrow.right"
        case .left: return "arrow.left"
        }
    }
}
