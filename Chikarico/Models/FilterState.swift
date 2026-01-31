import Foundation

struct FilterState: Codable, Equatable {
    var statuses: Set<CommitmentStatusFilter> = []
    var categoryIds: Set<UUID> = []
    var cycles: Set<CommitmentCycleFilter> = []
    var reflectionStates: Set<ReflectionState> = []
    var hasAmount: Bool? = nil // nil = all, true = with amount, false = without amount
    var dateRange: DateRangeFilter? = nil
    
    var isActive: Bool {
        !statuses.isEmpty ||
        !categoryIds.isEmpty ||
        !cycles.isEmpty ||
        !reflectionStates.isEmpty ||
        hasAmount != nil ||
        dateRange != nil
    }
    
    static let empty = FilterState()
}

enum CommitmentStatusFilter: String, Codable, CaseIterable {
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
    
    func matches(_ status: CommitmentStatus) -> Bool {
        switch (self, status) {
        case (.active, .active): return true
        case (.paused, .paused): return true
        case (.ending, .ending): return true
        case (.archived, .archived): return true
        default: return false
        }
    }
}

enum CommitmentCycleFilter: String, Codable, CaseIterable {
    case weekly
    case monthly
    case yearly
    case custom
    
    var displayName: String {
        switch self {
        case .weekly: return "Weekly"
        case .monthly: return "Monthly"
        case .yearly: return "Yearly"
        case .custom: return "Custom"
        }
    }
    
    func matches(_ cycle: CommitmentCycle) -> Bool {
        switch (self, cycle) {
        case (.weekly, .weekly): return true
        case (.monthly, .monthly): return true
        case (.yearly, .yearly): return true
        case (.custom, .custom): return true
        default: return false
        }
    }
}

struct DateRangeFilter: Codable, Equatable {
    var startDate: Date?
    var endDate: Date?
    
    func matches(_ date: Date) -> Bool {
        if let start = startDate, date < start {
            return false
        }
        if let end = endDate, date > end {
            return false
        }
        return true
    }
}
