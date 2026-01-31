import Foundation

struct AnalyticsService {
    static func activityDistribution(
        commitments: [Commitment],
        months: Int = 12
    ) -> [ActivityDataPoint] {
        let calendar = Calendar.current
        let endDate = Date()
        guard let startDate = calendar.date(byAdding: .month, value: -months, to: endDate) else {
            return []
        }
        
        // Optimize: Only check dates where commitments actually occur
        var distribution: [Date: Int] = [:]
        
        // Pre-filter commitments that could be in range
        let relevantCommitments = commitments.filter { commitment in
            let finalDate = commitment.status.isActive ? endDate : (extractEndDate(from: commitment.status) ?? endDate)
            return commitment.startDate <= endDate && finalDate >= startDate
        }
        
        // For each commitment, calculate its occurrence dates more efficiently
        for commitment in relevantCommitments {
            let commitmentStart = max(commitment.startDate, startDate)
            let commitmentEnd = min(
                commitment.status.isActive ? endDate : (extractEndDate(from: commitment.status) ?? endDate),
                endDate
            )
            
            // Skip if commitment wasn't active in this period
            if commitmentStart > commitmentEnd {
                continue
            }
            
            // Calculate next occurrence dates instead of checking every day
            var currentOccurrence = CommitmentCalculator.computeNextOccurrence(
                from: commitment.startDate,
                cycle: commitment.cycle,
                currentDate: commitmentStart
            )
            
            // If paused, adjust
            if case .paused(let pausedAt) = commitment.status, let paused = pausedAt {
                if currentOccurrence >= paused {
                    continue // Skip if paused before first occurrence in range
                }
            }
            
            // Count occurrences in the date range
            while currentOccurrence <= commitmentEnd {
                if currentOccurrence >= commitmentStart {
                    let key = calendar.startOfDay(for: currentOccurrence)
                    distribution[key, default: 0] += 1
                }
                
                // Calculate next occurrence
                guard let nextDate = calendar.date(byAdding: .day, value: commitment.cycle.intervalDays, to: currentOccurrence) else { break }
                currentOccurrence = nextDate
            }
        }
        
        // Fill in missing dates with 0 for continuity
        var result: [ActivityDataPoint] = []
        var currentDate = calendar.startOfDay(for: startDate)
        let endDay = calendar.startOfDay(for: endDate)
        
        while currentDate <= endDay {
            result.append(ActivityDataPoint(
                date: currentDate,
                count: distribution[currentDate] ?? 0
            ))
            guard let nextDate = calendar.date(byAdding: .day, value: 1, to: currentDate) else { break }
            currentDate = nextDate
        }
        
        return result
    }
    
    static func categoryTrends(
        commitments: [Commitment],
        categories: [Category],
        months: Int = 6
    ) -> [CategoryTrendData] {
        let calendar = Calendar.current
        let endDate = Date()
        guard let startDate = calendar.date(byAdding: .month, value: -months, to: endDate) else {
            return []
        }
        
        var monthlyData: [String: [String: Int]] = [:] // [Month: [Category: Count]]
        var currentDate = startDate
        
        while currentDate <= endDate {
            let monthKey = monthKey(for: currentDate)
            monthlyData[monthKey] = [:]
            
            guard let nextMonth = calendar.date(byAdding: .month, value: 1, to: currentDate) else { break }
            currentDate = nextMonth
        }
        
        // Count commitments by category for each month
        for commitment in commitments {
            let categoryName = categories.first { $0.id == commitment.categoryId }?.name ?? "Unknown"
            let commitmentStart = commitment.startDate
            let commitmentEnd = commitment.status.isActive ? endDate : (extractEndDate(from: commitment.status) ?? endDate)
            
            var checkDate = max(commitmentStart, startDate)
            while checkDate <= min(commitmentEnd, endDate) {
                let monthKey = monthKey(for: checkDate)
                monthlyData[monthKey, default: [:]][categoryName, default: 0] += 1
                
                guard let nextMonth = calendar.date(byAdding: .month, value: 1, to: checkDate) else { break }
                checkDate = nextMonth
            }
        }
        
        return monthlyData.map { month, categoryCounts in
            CategoryTrendData(month: month, categoryCounts: categoryCounts)
        }.sorted { $0.month < $1.month }
    }
    
    static func commitmentGrowth(
        commitments: [Commitment],
        months: Int = 12
    ) -> [GrowthDataPoint] {
        let calendar = Calendar.current
        let endDate = Date()
        guard let startDate = calendar.date(byAdding: .month, value: -months, to: endDate) else {
            return []
        }
        
        var monthlyCounts: [String: (created: Int, archived: Int)] = [:]
        var currentDate = startDate
        
        while currentDate <= endDate {
            let monthKey = monthKey(for: currentDate)
            monthlyCounts[monthKey] = (created: 0, archived: 0)
            
            guard let nextMonth = calendar.date(byAdding: .month, value: 1, to: currentDate) else { break }
            currentDate = nextMonth
        }
        
        // Count created and archived by month
        for commitment in commitments {
            let createdMonth = monthKey(for: commitment.createdAt)
            if monthlyCounts[createdMonth] != nil {
                monthlyCounts[createdMonth]!.created += 1
            }
            
            if case .archived = commitment.status {
                if let archivedDate = findArchivedDate(commitment) {
                    let archivedMonth = monthKey(for: archivedDate)
                    if monthlyCounts[archivedMonth] != nil {
                        monthlyCounts[archivedMonth]!.archived += 1
                    }
                }
            }
        }
        
        var runningTotal = 0
        return monthlyCounts.map { month, counts in
            runningTotal += counts.created - counts.archived
            return GrowthDataPoint(month: month, total: runningTotal, created: counts.created, archived: counts.archived)
        }.sorted { $0.month < $1.month }
    }
    
    private static func wasActiveOnDate(_ commitment: Commitment, date: Date) -> Bool {
        if date < commitment.startDate {
            return false
        }
        
        if case .archived = commitment.status {
            if let archivedDate = findArchivedDate(commitment), date > archivedDate {
                return false
            }
        }
        
        if case .paused = commitment.status {
            if let pausedAt = commitment.pausedAt, date >= pausedAt {
                // Check if resumed before this date
                if let resumedDate = findResumedDate(commitment), date >= resumedDate {
                    return true
                }
                return false
            }
        }
        
        return true
    }
    
    private static func extractEndDate(from status: CommitmentStatus) -> Date? {
        if case .ending(let endDate) = status {
            return endDate
        }
        return nil
    }
    
    private static func findArchivedDate(_ commitment: Commitment) -> Date? {
        return commitment.history.entries
            .first { $0.type == .archived }?
            .timestamp
    }
    
    private static func findResumedDate(_ commitment: Commitment) -> Date? {
        return commitment.history.entries
            .first { $0.type == .resumed }?
            .timestamp
    }
    
    private static func monthKey(for date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM"
        return formatter.string(from: date)
    }
}

struct ActivityDataPoint: Identifiable {
    let id = UUID()
    let date: Date
    let count: Int
}

struct CategoryTrendData: Identifiable {
    let id = UUID()
    let month: String
    let categoryCounts: [String: Int]
}

struct GrowthDataPoint: Identifiable {
    let id = UUID()
    let month: String
    let total: Int
    let created: Int
    let archived: Int
}
