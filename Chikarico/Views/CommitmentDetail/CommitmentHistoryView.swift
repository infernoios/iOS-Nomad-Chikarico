import SwiftUI

struct CommitmentHistoryView: View {
    let commitment: Commitment
    let categories: [Category]
    
    var categoryMap: [UUID: Category] {
        Dictionary(uniqueKeysWithValues: categories.map { ($0.id, $0) })
    }
    
    var sortedHistory: [CommitmentHistoryEntry] {
        commitment.history.entries.sorted { $0.timestamp > $1.timestamp }
    }
    
    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                if sortedHistory.isEmpty {
                    VStack(spacing: 16) {
                        Image(systemName: "clock.badge.questionmark")
                            .font(.system(size: 50))
                            .foregroundColor(.textSecondary)
                        
                        Text("No history yet")
                            .font(.system(size: 18, weight: .semibold))
                            .foregroundColor(.textPrimary)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.top, 60)
                } else {
                    ForEach(sortedHistory) { entry in
                        HistoryEntryCard(entry: entry, categoryMap: categoryMap)
                    }
                }
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 16)
        }
    }
}

struct HistoryEntryCard: View {
    let entry: CommitmentHistoryEntry
    let categoryMap: [UUID: Category]
    
    var body: some View {
        HStack(spacing: 16) {
            // Icon
            ZStack {
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [
                                entryTypeColor(entry.type).opacity(0.3),
                                entryTypeColor(entry.type).opacity(0.2)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 44, height: 44)
                
                Image(systemName: entry.type.icon)
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(entryTypeColor(entry.type))
            }
            
            VStack(alignment: .leading, spacing: 6) {
                Text(entry.type.displayName)
                    .font(.system(size: 16, weight: .bold, design: .rounded))
                    .foregroundColor(.textPrimary)
                
                if let oldValue = entry.oldValue, let newValue = entry.newValue {
                    HStack(spacing: 8) {
                        Text(oldValue)
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(.textSecondary)
                            .strikethrough()
                        
                        Image(systemName: "arrow.right")
                            .font(.system(size: 12))
                            .foregroundColor(.textSecondary)
                        
                        Text(newValue)
                            .font(.system(size: 14, weight: .bold))
                            .foregroundColor(.textPrimary)
                    }
                } else if let newValue = entry.newValue {
                    Text(newValue)
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(.textPrimary)
                }
                
                if let note = entry.note {
                    Text(note)
                        .font(.system(size: 13))
                        .foregroundColor(.textSecondary)
                        .italic()
                }
                
                Text(entry.timestamp.formattedRelative())
                    .font(.system(size: 12))
                    .foregroundColor(.textSecondary.opacity(0.7))
            }
            
            Spacer()
        }
        .padding(16)
        .background(
            ZStack {
                RoundedRectangle(cornerRadius: 16)
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
                
                RoundedRectangle(cornerRadius: 16)
                    .stroke(
                        LinearGradient(
                            colors: [
                                entryTypeColor(entry.type).opacity(0.3),
                                entryTypeColor(entry.type).opacity(0.1)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        lineWidth: 1
                    )
            }
        )
    }
    
    private func entryTypeColor(_ type: HistoryEntryType) -> Color {
        switch type {
        case .created: return .accentGreen
        case .statusChanged, .paused, .resumed: return .accentOrange
        case .cycleChanged: return .accentBlue
        case .amountChanged: return .accentGreen
        case .categoryChanged: return .accentPurple
        case .markedEnding: return .accentPink
        case .archived: return .gray
        case .titleChanged, .notesChanged: return .accentBlue
        case .reflectionChanged: return .accentPurple
        }
    }
}
