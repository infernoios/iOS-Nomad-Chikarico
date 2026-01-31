import Foundation

struct CommitmentHistoryEntry: Identifiable, Codable {
    let id: UUID
    let timestamp: Date
    let type: HistoryEntryType
    let oldValue: String?
    let newValue: String?
    let note: String?
    
    init(
        id: UUID = UUID(),
        timestamp: Date = Date(),
        type: HistoryEntryType,
        oldValue: String? = nil,
        newValue: String? = nil,
        note: String? = nil
    ) {
        self.id = id
        self.timestamp = timestamp
        self.type = type
        self.oldValue = oldValue
        self.newValue = newValue
        self.note = note
    }
}

enum HistoryEntryType: String, Codable {
    case created
    case statusChanged
    case cycleChanged
    case amountChanged
    case categoryChanged
    case paused
    case resumed
    case markedEnding
    case archived
    case titleChanged
    case notesChanged
    case reflectionChanged
    
    var displayName: String {
        switch self {
        case .created: return "Created"
        case .statusChanged: return "Status Changed"
        case .cycleChanged: return "Cycle Changed"
        case .amountChanged: return "Amount Changed"
        case .categoryChanged: return "Category Changed"
        case .paused: return "Paused"
        case .resumed: return "Resumed"
        case .markedEnding: return "Marked as Ending"
        case .archived: return "Archived"
        case .titleChanged: return "Title Changed"
        case .notesChanged: return "Notes Changed"
        case .reflectionChanged: return "Reflection Changed"
        }
    }
    
    var icon: String {
        switch self {
        case .created: return "plus.circle.fill"
        case .statusChanged: return "arrow.triangle.2.circlepath"
        case .cycleChanged: return "arrow.clockwise"
        case .amountChanged: return "dollarsign.circle.fill"
        case .categoryChanged: return "folder.fill"
        case .paused: return "pause.circle.fill"
        case .resumed: return "play.circle.fill"
        case .markedEnding: return "flag.fill"
        case .archived: return "archivebox.fill"
        case .titleChanged: return "textformat"
        case .notesChanged: return "note.text"
        case .reflectionChanged: return "sparkles"
        }
    }
}

struct CommitmentHistory: Codable {
    var entries: [CommitmentHistoryEntry] = []
    
    mutating func addEntry(_ entry: CommitmentHistoryEntry) {
        entries.append(entry)
        // Keep only last 100 entries to prevent bloat
        if entries.count > 100 {
            entries.removeFirst()
        }
    }
}
