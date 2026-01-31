import Foundation

struct FilterService {
    static func filterCommitments(
        _ commitments: [Commitment],
        with filter: FilterState,
        categories: [Category]
    ) -> [Commitment] {
        return commitments.filter { commitment in
            // Status filter
            if !filter.statuses.isEmpty {
                let matches = filter.statuses.contains { statusFilter in
                    statusFilter.matches(commitment.status)
                }
                if !matches { return false }
            }
            
            // Category filter
            if !filter.categoryIds.isEmpty {
                if !filter.categoryIds.contains(commitment.categoryId) {
                    return false
                }
            }
            
            // Cycle filter
            if !filter.cycles.isEmpty {
                let matches = filter.cycles.contains { cycleFilter in
                    cycleFilter.matches(commitment.cycle)
                }
                if !matches { return false }
            }
            
            // Reflection filter
            if !filter.reflectionStates.isEmpty {
                if let reflection = commitment.reflectionState {
                    if !filter.reflectionStates.contains(reflection) {
                        return false
                    }
                } else {
                    return false
                }
            }
            
            // Amount filter
            if let hasAmount = filter.hasAmount {
                if hasAmount && commitment.amount == nil {
                    return false
                }
                if !hasAmount && commitment.amount != nil {
                    return false
                }
            }
            
            // Date range filter
            if let dateRange = filter.dateRange {
                if !dateRange.matches(commitment.nextOccurrenceDate) {
                    return false
                }
            }
            
            return true
        }
    }
}
