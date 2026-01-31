import SwiftUI

struct ActivityHeatmapView: View {
    let commitments: [Commitment]
    @State private var selectedMonth: Date = Date()
    @State private var cachedDayCounts: [Date: Int] = [:]
    @State private var cachedMonth: Date = Date()
    
    var calendar = Calendar.current
    
    var monthStart: Date {
        calendar.date(from: calendar.dateComponents([.year, .month], from: selectedMonth)) ?? selectedMonth
    }
    
    var daysInMonth: [Date] {
        guard let monthInterval = calendar.dateInterval(of: .month, for: selectedMonth) else {
            return []
        }
        
        let firstDay = monthInterval.start
        
        let firstDayWeekday = calendar.component(.weekday, from: firstDay)
        let daysToSubtract = (firstDayWeekday - calendar.firstWeekday + 7) % 7
        
        guard let startDate = calendar.date(byAdding: .day, value: -daysToSubtract, to: firstDay) else {
            return []
        }
        
        var days: [Date] = []
        var currentDate = startDate
        
        for _ in 0..<42 {
            days.append(currentDate)
            guard let nextDate = calendar.date(byAdding: .day, value: 1, to: currentDate) else { break }
            currentDate = nextDate
        }
        
        return days
    }
    
    var dayActivityCounts: [Date: Int] {
        cachedDayCounts
    }
    
    private func calculateDayCounts() -> [Date: Int] {
        var counts: [Date: Int] = [:]
        
        guard let monthEnd = calendar.date(byAdding: .month, value: 1, to: monthStart) else {
            return counts
        }
        
        let endDate = min(Date(), monthEnd)
        
        // Pre-filter commitments that could be in this month
        let relevantCommitments = commitments.filter { commitment in
            let commitmentEnd = commitment.status.isActive ? endDate : (commitment.pausedAt ?? endDate)
            return commitment.startDate < monthEnd && commitmentEnd >= monthStart
        }
        
        // For each commitment, calculate occurrence dates more efficiently
        for commitment in relevantCommitments {
            // Calculate next occurrence dates instead of checking every day
            var currentOccurrence = CommitmentCalculator.computeNextOccurrence(
                from: commitment.startDate,
                cycle: commitment.cycle,
                currentDate: monthStart
            )
            
            // If paused, adjust
            if case .paused(let pausedAt) = commitment.status, let paused = pausedAt {
                if currentOccurrence >= paused || paused < monthStart {
                    continue
                }
            }
            
            // Count occurrences in the month
            while currentOccurrence < endDate {
                if currentOccurrence >= monthStart {
                    let key = calendar.startOfDay(for: currentOccurrence)
                    counts[key, default: 0] += 1
                }
                
                // Calculate next occurrence
                guard let nextDate = calendar.date(byAdding: .day, value: commitment.cycle.intervalDays, to: currentOccurrence) else { break }
                currentOccurrence = nextDate
            }
        }
        
        return counts
    }
    
    var maxCount: Int {
        dayActivityCounts.values.max() ?? 1
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            HStack {
                Text("Activity Heatmap")
                    .font(.system(size: 22, weight: .bold, design: .rounded))
                    .foregroundColor(.textPrimary)
                
                Spacer()
                
                Button(action: {
                    if let prevMonth = calendar.date(byAdding: .month, value: -1, to: selectedMonth) {
                        selectedMonth = prevMonth
                    }
                }) {
                    Image(systemName: "chevron.left")
                        .foregroundColor(.textPrimary)
                }
                
                Text(monthLabel)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(.textPrimary)
                    .frame(width: 120)
                
                Button(action: {
                    if let nextMonth = calendar.date(byAdding: .month, value: 1, to: selectedMonth) {
                        selectedMonth = nextMonth
                    }
                }) {
                    Image(systemName: "chevron.right")
                        .foregroundColor(.textPrimary)
                }
            }
            
            // Weekday headers
            HStack(spacing: 0) {
                ForEach(["S", "M", "T", "W", "T", "F", "S"], id: \.self) { weekday in
                    Text(weekday)
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(.textSecondary)
                        .frame(maxWidth: .infinity)
                }
            }
            
            // Calendar grid
            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 7), spacing: 4) {
                ForEach(daysInMonth, id: \.self) { date in
                    HeatmapDayView(
                        date: date,
                        month: selectedMonth,
                        count: dayActivityCounts[calendar.startOfDay(for: date)] ?? 0,
                        maxCount: maxCount
                    )
                }
            }
            
            // Legend
            HStack(spacing: 12) {
                Text("Less")
                    .font(.system(size: 11))
                    .foregroundColor(.textSecondary)
                
                ForEach(0..<5) { level in
                    RoundedRectangle(cornerRadius: 3)
                        .fill(heatmapColor(for: level, maxLevel: 4))
                        .frame(width: 12, height: 12)
                }
                
                Text("More")
                    .font(.system(size: 11))
                    .foregroundColor(.textSecondary)
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
                                Color.accentOrange.opacity(0.3),
                                Color.accentOrange.opacity(0.1)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        lineWidth: 1
                    )
            }
        )
        .onAppear {
            loadHeatmapData()
        }
        .onChange(of: selectedMonth) { _ in
            loadHeatmapData()
        }
        .onChange(of: commitments.count) { _ in
            loadHeatmapData()
        }
    }
    
    private func loadHeatmapData() {
        DispatchQueue.global(qos: .userInitiated).async {
            let counts = calculateDayCounts()
            DispatchQueue.main.async {
                self.cachedDayCounts = counts
                self.cachedMonth = selectedMonth
            }
        }
    }
    
    private var monthLabel: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM yyyy"
        return formatter.string(from: selectedMonth)
    }
    
    private func wasActiveOnDate(_ commitment: Commitment, date: Date) -> Bool {
        if date < commitment.startDate {
            return false
        }
        
        if case .archived = commitment.status {
            return false
        }
        
        if case .paused = commitment.status {
            if let pausedAt = commitment.pausedAt, date >= pausedAt {
                if let resumedDate = findResumedDate(commitment), date >= resumedDate {
                    return true
                }
                return false
            }
        }
        
        return true
    }
    
    private func findResumedDate(_ commitment: Commitment) -> Date? {
        return commitment.history.entries
            .first { $0.type == .resumed }?
            .timestamp
    }
    
    private func heatmapColor(for level: Int, maxLevel: Int) -> Color {
        let intensity = Double(level) / Double(maxLevel)
        return Color.accentOrange.opacity(0.2 + intensity * 0.8)
    }
}

struct HeatmapDayView: View {
    let date: Date
    let month: Date
    let count: Int
    let maxCount: Int
    
    private let calendar = Calendar.current
    
    var isInCurrentMonth: Bool {
        calendar.isDate(date, equalTo: month, toGranularity: .month)
    }
    
    var intensity: Double {
        guard maxCount > 0 else { return 0 }
        return Double(count) / Double(maxCount)
    }
    
    var body: some View {
        RoundedRectangle(cornerRadius: 4)
            .fill(
                isInCurrentMonth
                    ? Color.accentOrange.opacity(0.2 + intensity * 0.8)
                    : Color.clear
            )
            .frame(width: 32, height: 32)
            .overlay(
                Group {
                    if isInCurrentMonth && count > 0 {
                        Text("\(count)")
                            .font(.system(size: 9, weight: .bold))
                            .foregroundColor(intensity > 0.5 ? .white : .textPrimary)
                    }
                }
            )
    }
}
