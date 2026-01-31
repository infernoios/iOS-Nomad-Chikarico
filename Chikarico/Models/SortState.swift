import Foundation

enum SortOption: String, Codable, CaseIterable {
    case nextDate
    case duration
    case amount
    case status
    case title
    case category
    case createdAt
    
    var displayName: String {
        switch self {
        case .nextDate: return "Next Date"
        case .duration: return "Duration"
        case .amount: return "Amount"
        case .status: return "Status"
        case .title: return "Title"
        case .category: return "Category"
        case .createdAt: return "Created Date"
        }
    }
}

enum SortDirection: String, Codable {
    case ascending
    case descending
}

struct SortState: Codable, Equatable {
    var primary: SortOption = .nextDate
    var primaryDirection: SortDirection = .ascending
    var secondary: SortOption? = nil
    var secondaryDirection: SortDirection = .ascending
    
    static let `default` = SortState()
}

struct SortService {
    static func sortCommitments(
        _ commitments: [Commitment],
        with sort: SortState,
        categories: [Category]
    ) -> [Commitment] {
        let categoryMap = Dictionary(uniqueKeysWithValues: categories.map { ($0.id, $0) })
        
        return commitments.sorted { lhs, rhs in
            // Primary sort
            let primaryResult = compareCommitments(lhs, rhs, by: sort.primary, direction: sort.primaryDirection, categoryMap: categoryMap)
            if primaryResult != 0 {
                return primaryResult < 0
            }
            
            // Secondary sort (if exists)
            if let secondary = sort.secondary {
                let secondaryResult = compareCommitments(lhs, rhs, by: secondary, direction: sort.secondaryDirection, categoryMap: categoryMap)
                if secondaryResult != 0 {
                    return secondaryResult < 0
                }
            }
            
            // Final tie-breaker: by ID
            return lhs.id.uuidString < rhs.id.uuidString
        }
    }
    
    private static func compareCommitments(
        _ lhs: Commitment,
        _ rhs: Commitment,
        by option: SortOption,
        direction: SortDirection,
        categoryMap: [UUID: Category]
    ) -> Int {
        let result: Int
        
        switch option {
        case .nextDate:
            result = lhs.nextOccurrenceDate.compare(rhs.nextOccurrenceDate).rawValue
            
        case .duration:
            let lhsDuration = lhs.activeDuration
            let rhsDuration = rhs.activeDuration
            if lhsDuration < rhsDuration {
                result = -1
            } else if lhsDuration > rhsDuration {
                result = 1
            } else {
                result = 0
            }
            
        case .amount:
            let lhsAmount = lhs.amount ?? Decimal(0)
            let rhsAmount = rhs.amount ?? Decimal(0)
            if lhsAmount < rhsAmount {
                result = -1
            } else if lhsAmount > rhsAmount {
                result = 1
            } else {
                result = 0
            }
            
        case .status:
            let lhsPriority = statusPriority(lhs.status)
            let rhsPriority = statusPriority(rhs.status)
            result = lhsPriority - rhsPriority
            
        case .title:
            result = lhs.title.compare(rhs.title).rawValue
            
        case .category:
            let lhsCategory = categoryMap[lhs.categoryId]?.name ?? ""
            let rhsCategory = categoryMap[rhs.categoryId]?.name ?? ""
            result = lhsCategory.compare(rhsCategory).rawValue
            
        case .createdAt:
            result = lhs.createdAt.compare(rhs.createdAt).rawValue
        }
        
        return direction == .descending ? -result : result
    }
    
    private static func statusPriority(_ status: CommitmentStatus) -> Int {
        switch status {
        case .active: return 0
        case .ending: return 1
        case .paused: return 2
        case .archived: return 3
        }
    }
}
