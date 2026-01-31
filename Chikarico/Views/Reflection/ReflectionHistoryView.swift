import SwiftUI

struct ReflectionHistoryView: View {
    let commitment: Commitment
    
    var reflectionHistory: [ReflectionHistoryEntry] {
        commitment.history.entries
            .filter { $0.type == .reflectionChanged }
            .map { entry in
                ReflectionHistoryEntry(
                    date: entry.timestamp,
                    oldState: ReflectionState(rawValue: entry.oldValue ?? "") ?? nil,
                    newState: ReflectionState(rawValue: entry.newValue ?? "") ?? nil
                )
            }
            .sorted { $0.date > $1.date }
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            Text("Reflection History")
                .font(.system(size: 22, weight: .bold, design: .rounded))
                .foregroundColor(.textPrimary)
            
            if reflectionHistory.isEmpty {
                emptyState
            } else {
                ScrollView {
                    VStack(spacing: 12) {
                        ForEach(reflectionHistory) { entry in
                            ReflectionHistoryCard(entry: entry)
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
    
    private var emptyState: some View {
        VStack(spacing: 12) {
            Image(systemName: "sparkles")
                .font(.system(size: 40))
                .foregroundColor(.textSecondary)
            
            Text("No reflection history")
                .font(.system(size: 16, weight: .medium))
                .foregroundColor(.textSecondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 40)
    }
}

struct ReflectionHistoryEntry: Identifiable {
    let id = UUID()
    let date: Date
    let oldState: ReflectionState?
    let newState: ReflectionState?
}

struct ReflectionHistoryCard: View {
    let entry: ReflectionHistoryEntry
    
    var body: some View {
        HStack(spacing: 16) {
            // Old state
            if let oldState = entry.oldState {
                ReflectionStateCircle(state: oldState, size: 40)
            } else {
                Circle()
                    .fill(Color.cardBackground)
                    .frame(width: 40, height: 40)
                    .overlay(
                        Text("?")
                            .font(.system(size: 16, weight: .bold))
                            .foregroundColor(.textSecondary)
                    )
            }
            
            // Arrow
            Image(systemName: "arrow.right")
                .font(.system(size: 16, weight: .semibold))
                .foregroundColor(.textSecondary)
            
            // New state
            if let newState = entry.newState {
                ReflectionStateCircle(state: newState, size: 40)
            } else {
                Circle()
                    .fill(Color.cardBackground)
                    .frame(width: 40, height: 40)
                    .overlay(
                        Text("?")
                            .font(.system(size: 16, weight: .bold))
                            .foregroundColor(.textSecondary)
                    )
            }
            
            Spacer()
            
            VStack(alignment: .trailing, spacing: 4) {
                Text(entry.date.formattedRelative())
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(.textPrimary)
                
                Text(entry.date.formattedShort())
                    .font(.system(size: 12))
                    .foregroundColor(.textSecondary)
            }
        }
        .padding(16)
        .background(Color.cardBackground.opacity(0.5))
        .cornerRadius(12)
    }
}

struct ReflectionStateCircle: View {
    let state: ReflectionState
    let size: CGFloat
    
    var body: some View {
        ZStack {
            Circle()
                .fill(
                    LinearGradient(
                        colors: [
                            stateColor(state),
                            stateColor(state).opacity(0.7)
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .frame(width: size, height: size)
            
            Image(systemName: stateIcon(state))
                .font(.system(size: size * 0.4, weight: .bold))
                .foregroundColor(.white)
        }
    }
    
    private func stateColor(_ state: ReflectionState) -> Color {
        switch state {
        case .yes: return .accentGreen
        case .neutral: return .accentOrange
        case .no: return .accentPink
        }
    }
    
    private func stateIcon(_ state: ReflectionState) -> String {
        switch state {
        case .yes: return "checkmark"
        case .neutral: return "minus"
        case .no: return "xmark"
        }
    }
}
