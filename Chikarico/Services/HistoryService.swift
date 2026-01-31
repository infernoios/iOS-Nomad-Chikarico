import Foundation

struct HistoryService {
    static func recordStatusChange(
        _ commitment: inout Commitment,
        from oldStatus: CommitmentStatus,
        to newStatus: CommitmentStatus
    ) {
        let oldValue = statusString(oldStatus)
        let newValue = statusString(newStatus)
        
        let entryType: HistoryEntryType
        switch newStatus {
        case .paused:
            entryType = .paused
        case .active:
            if case .paused = oldStatus {
                entryType = .resumed
            } else {
                entryType = .statusChanged
            }
        case .ending:
            entryType = .markedEnding
        case .archived:
            entryType = .archived
        }
        
        commitment.history.addEntry(CommitmentHistoryEntry(
            type: entryType,
            oldValue: oldValue,
            newValue: newValue
        ))
    }
    
    static func recordCycleChange(
        _ commitment: inout Commitment,
        from oldCycle: CommitmentCycle,
        to newCycle: CommitmentCycle
    ) {
        commitment.history.addEntry(CommitmentHistoryEntry(
            type: .cycleChanged,
            oldValue: oldCycle.displayName,
            newValue: newCycle.displayName
        ))
    }
    
    static func recordAmountChange(
        _ commitment: inout Commitment,
        from oldAmount: Decimal?,
        to newAmount: Decimal?,
        currency: String
    ) {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = currency == "Other" ? "" : currency
        
        let oldValue = oldAmount.map { formatter.string(from: $0 as NSDecimalNumber) ?? "\($0)" } ?? "None"
        let newValue = newAmount.map { formatter.string(from: $0 as NSDecimalNumber) ?? "\($0)" } ?? "None"
        
        commitment.history.addEntry(CommitmentHistoryEntry(
            type: .amountChanged,
            oldValue: oldValue,
            newValue: newValue
        ))
    }
    
    static func recordCategoryChange(
        _ commitment: inout Commitment,
        from oldCategoryId: UUID,
        to newCategoryId: UUID,
        oldCategoryName: String,
        newCategoryName: String
    ) {
        commitment.history.addEntry(CommitmentHistoryEntry(
            type: .categoryChanged,
            oldValue: oldCategoryName,
            newValue: newCategoryName
        ))
    }
    
    static func recordTitleChange(
        _ commitment: inout Commitment,
        from oldTitle: String,
        to newTitle: String
    ) {
        commitment.history.addEntry(CommitmentHistoryEntry(
            type: .titleChanged,
            oldValue: oldTitle,
            newValue: newTitle
        ))
    }
    
    static func recordReflectionChange(
        _ commitment: inout Commitment,
        from oldReflection: ReflectionState?,
        to newReflection: ReflectionState?
    ) {
        commitment.history.addEntry(CommitmentHistoryEntry(
            type: .reflectionChanged,
            oldValue: oldReflection?.rawValue.capitalized ?? "None",
            newValue: newReflection?.rawValue.capitalized ?? "None"
        ))
    }
    
    static func recordNotesChange(
        _ commitment: inout Commitment,
        from oldNotes: String?,
        to newNotes: String?
    ) {
        commitment.history.addEntry(CommitmentHistoryEntry(
            type: .notesChanged,
            oldValue: oldNotes ?? "None",
            newValue: newNotes ?? "None"
        ))
    }
    
    private static func statusString(_ status: CommitmentStatus) -> String {
        switch status {
        case .active: return "Active"
        case .paused: return "Paused"
        case .ending(let endDate):
            let formatter = DateFormatter()
            formatter.dateStyle = .medium
            formatter.timeStyle = .none
            return "Ending on \(formatter.string(from: endDate))"
        case .archived: return "Archived"
        }
    }
}
