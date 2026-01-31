import SwiftUI

struct NotesHistoryView: View {
    let commitment: Commitment
    
    var notesHistory: [NotesHistoryEntry] {
        var entries: [NotesHistoryEntry] = []
        
        // Initial notes
        if let initialNotes = commitment.notes, !initialNotes.isEmpty {
            entries.append(NotesHistoryEntry(
                date: commitment.createdAt,
                notes: initialNotes,
                type: .initial
            ))
        }
        
        // Notes changes from history
        for entry in commitment.history.entries where entry.type == .notesChanged {
            if let newValue = entry.newValue {
                entries.append(NotesHistoryEntry(
                    date: entry.timestamp,
                    notes: newValue,
                    type: .changed
                ))
            }
        }
        
        return entries.sorted { $0.date > $1.date }
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            Text("Notes History")
                .font(.system(size: 22, weight: .bold, design: .rounded))
                .foregroundColor(.textPrimary)
            
            if notesHistory.isEmpty {
                emptyState
            } else {
                ScrollView {
                    VStack(spacing: 16) {
                        ForEach(notesHistory) { entry in
                            NotesHistoryCard(entry: entry)
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
                                Color.accentBlue.opacity(0.3),
                                Color.accentBlue.opacity(0.1)
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
            Image(systemName: "note.text")
                .font(.system(size: 40))
                .foregroundColor(.textSecondary)
            
            Text("No notes history")
                .font(.system(size: 16, weight: .medium))
                .foregroundColor(.textSecondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 40)
    }
}

struct NotesHistoryEntry: Identifiable {
    let id = UUID()
    let date: Date
    let notes: String
    let type: NotesChangeType
}

enum NotesChangeType {
    case initial
    case changed
    
    var displayName: String {
        switch self {
        case .initial: return "Initial"
        case .changed: return "Updated"
        }
    }
}

struct NotesHistoryCard: View {
    let entry: NotesHistoryEntry
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: "note.text")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(.accentBlue)
                
                Text(entry.type.displayName)
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(.textSecondary)
                
                Spacer()
                
                Text(entry.date.formattedRelative())
                    .font(.system(size: 12))
                    .foregroundColor(.textSecondary)
            }
            
            Text(entry.notes)
                .font(.system(size: 15))
                .foregroundColor(.textPrimary)
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(16)
        .background(Color.cardBackground.opacity(0.5))
        .cornerRadius(12)
    }
}
