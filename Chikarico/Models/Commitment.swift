import Foundation
import SwiftUI

enum CommitmentCycle: Codable, Equatable {
    case weekly
    case monthly
    case yearly
    case custom(intervalDays: Int)
    
    var displayName: String {
        switch self {
        case .weekly: return "Weekly"
        case .monthly: return "Monthly"
        case .yearly: return "Yearly"
        case .custom(let days): return "Every \(days) days"
        }
    }
    
    var intervalDays: Int {
        switch self {
        case .weekly: return 7
        case .monthly: return 30
        case .yearly: return 365
        case .custom(let days): return days
        }
    }
}

enum CommitmentStatus: Codable, Equatable {
    case active
    case paused(pausedAt: Date?)
    case ending(endDate: Date)
    case archived
    
    var isActive: Bool {
        if case .active = self { return true }
        return false
    }
    
    var isEnding: Bool {
        if case .ending = self { return true }
        return false
    }
    
    var isPaused: Bool {
        if case .paused = self { return true }
        return false
    }
    
    var isArchived: Bool {
        if case .archived = self { return true }
        return false
    }
}

enum ReflectionState: String, Codable {
    case yes
    case neutral
    case no
}

struct Commitment: Identifiable, Codable {
    let id: UUID
    var title: String
    var categoryId: UUID
    var amount: Decimal?
    var currency: String
    var cycle: CommitmentCycle
    var startDate: Date
    var nextOccurrenceDate: Date
    var status: CommitmentStatus
    var notes: String?
    var reflectionState: ReflectionState?
    var createdAt: Date
    var pausedAt: Date?
    var totalPausedSeconds: TimeInterval
    var history: CommitmentHistory
    var tags: [String]
    var isHidden: Bool
    
    init(
        id: UUID = UUID(),
        title: String,
        categoryId: UUID,
        amount: Decimal? = nil,
        currency: String = "USD",
        cycle: CommitmentCycle,
        startDate: Date,
        nextOccurrenceDate: Date? = nil,
        status: CommitmentStatus = .active,
        notes: String? = nil,
        reflectionState: ReflectionState? = nil,
        createdAt: Date = Date(),
        pausedAt: Date? = nil,
        totalPausedSeconds: TimeInterval = 0,
        history: CommitmentHistory? = nil,
        tags: [String] = [],
        isHidden: Bool = false
    ) {
        self.id = id
        self.title = title
        self.categoryId = categoryId
        self.amount = amount
        self.currency = currency
        self.cycle = cycle
        self.startDate = startDate
        self.nextOccurrenceDate = nextOccurrenceDate ?? startDate
        self.status = status
        self.notes = notes
        self.reflectionState = reflectionState
        self.createdAt = createdAt
        self.pausedAt = pausedAt
        self.totalPausedSeconds = totalPausedSeconds
        
        var newHistory = history ?? CommitmentHistory()
        if newHistory.entries.isEmpty {
            newHistory.addEntry(CommitmentHistoryEntry(
                type: .created,
                note: "Commitment created"
            ))
        }
        self.history = newHistory
        self.tags = tags
        self.isHidden = isHidden
    }
    
    var activeDuration: TimeInterval {
        let now = Date()
        let baseDuration = now.timeIntervalSince(startDate)
        return baseDuration - totalPausedSeconds
    }
    
    var activeDurationString: String {
        let months = Int(activeDuration / (30 * 24 * 3600))
        if months == 0 {
            let days = Int(activeDuration / (24 * 3600))
            return "Active for \(days) day\(days == 1 ? "" : "s")"
        }
        return "Active for \(months) month\(months == 1 ? "" : "s")"
    }
}
