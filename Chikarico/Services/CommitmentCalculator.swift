import Foundation

struct CommitmentCalculator {
    static func computeNextOccurrence(
        from startDate: Date,
        cycle: CommitmentCycle,
        currentDate: Date = Date()
    ) -> Date {
        let intervalDays = cycle.intervalDays
        var nextDate = startDate
        
        while nextDate < currentDate {
            nextDate = Calendar.current.date(byAdding: .day, value: intervalDays, to: nextDate) ?? nextDate
        }
        
        return nextDate
    }
    
    static func shouldAutoArchive(_ commitment: Commitment) -> Bool {
        if case .ending(let endDate) = commitment.status {
            return endDate <= Date()
        }
        return false
    }
}
