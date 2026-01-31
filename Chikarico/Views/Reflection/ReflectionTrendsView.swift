import SwiftUI

struct ReflectionTrendsView: View {
    let commitments: [Commitment]
    @State private var selectedMonths: Int = 6
    @State private var cachedTrends: ReflectionTrends = ReflectionTrends(yesCount: 0, neutralCount: 0, noCount: 0, monthlyTrends: [:])
    @State private var cachedMonths: Int = 0
    @State private var isDataLoaded = false
    
    var trends: ReflectionTrends {
        cachedTrends
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            HStack {
                Text("Reflection Trends")
                    .font(.system(size: 22, weight: .bold, design: .rounded))
                    .foregroundColor(.textPrimary)
                
                Spacer()
                
                Picker("", selection: $selectedMonths) {
                    Text("3 months").tag(3)
                    Text("6 months").tag(6)
                    Text("12 months").tag(12)
                }
                .pickerStyle(.menu)
            }
            
            if commitments.isEmpty {
                emptyState
            } else {
                VStack(spacing: 16) {
                    // Overall distribution
                    ReflectionDistributionChart(
                        yesCount: trends.yesCount,
                        neutralCount: trends.neutralCount,
                        noCount: trends.noCount
                    )
                    
                    // Trend over time
                    ReflectionTimelineChart(
                        monthlyTrends: trends.monthlyTrends
                    )
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
                                Color.accentPurple.opacity(0.3),
                                Color.accentPurple.opacity(0.1)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        lineWidth: 1
                    )
            }
        )
    }
    
    private func calculateTrends() -> ReflectionTrends {
        let calendar = Calendar.current
        let endDate = Date()
        guard let startDate = calendar.date(byAdding: .month, value: -selectedMonths, to: endDate) else {
            return ReflectionTrends(yesCount: 0, neutralCount: 0, noCount: 0, monthlyTrends: [:])
        }
        
        var yesCount = 0
        var neutralCount = 0
        var noCount = 0
        var monthlyTrends: [String: (yes: Int, neutral: Int, no: Int)] = [:]
        
        for commitment in commitments {
            if let reflection = commitment.reflectionState {
                switch reflection {
                case .yes: yesCount += 1
                case .neutral: neutralCount += 1
                case .no: noCount += 1
                }
            }
            
            // Get reflection changes in the period
            for entry in commitment.history.entries where entry.type == .reflectionChanged {
                if entry.timestamp >= startDate && entry.timestamp <= endDate {
                    let monthKey = monthKey(for: entry.timestamp)
                    if let newState = ReflectionState(rawValue: entry.newValue?.capitalized ?? "") {
                        switch newState {
                        case .yes: monthlyTrends[monthKey, default: (0, 0, 0)].yes += 1
                        case .neutral: monthlyTrends[monthKey, default: (0, 0, 0)].neutral += 1
                        case .no: monthlyTrends[monthKey, default: (0, 0, 0)].no += 1
                        }
                    }
                }
            }
        }
        
        return ReflectionTrends(
            yesCount: yesCount,
            neutralCount: neutralCount,
            noCount: noCount,
            monthlyTrends: monthlyTrends
        )
    }
    
    private func monthKey(for date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM"
        return formatter.string(from: date)
    }
    
    private var emptyState: some View {
        VStack(spacing: 12) {
            Image(systemName: "chart.bar.xaxis")
                .font(.system(size: 40))
                .foregroundColor(.textSecondary)
            
            Text("No reflection data")
                .font(.system(size: 16, weight: .medium))
                .foregroundColor(.textSecondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 40)
    }
}

struct ReflectionTrends {
    let yesCount: Int
    let neutralCount: Int
    let noCount: Int
    let monthlyTrends: [String: (yes: Int, neutral: Int, no: Int)]
}

struct ReflectionDistributionChart: View {
    let yesCount: Int
    let neutralCount: Int
    let noCount: Int
    
    var total: Int {
        yesCount + neutralCount + noCount
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Current Distribution")
                .font(.system(size: 16, weight: .bold))
                .foregroundColor(.textPrimary)
            
            if total == 0 {
                Text("No reflections yet")
                    .font(.system(size: 14))
                    .foregroundColor(.textSecondary)
            } else {
                VStack(spacing: 12) {
                    ReflectionDistributionRow(
                        label: "Yes",
                        count: yesCount,
                        total: total,
                        color: .accentGreen,
                        icon: "checkmark.circle.fill"
                    )
                    
                    ReflectionDistributionRow(
                        label: "Neutral",
                        count: neutralCount,
                        total: total,
                        color: .accentOrange,
                        icon: "minus.circle.fill"
                    )
                    
                    ReflectionDistributionRow(
                        label: "No",
                        count: noCount,
                        total: total,
                        color: .accentPink,
                        icon: "xmark.circle.fill"
                    )
                }
            }
        }
        .padding(16)
        .background(Color.cardBackground.opacity(0.5))
        .cornerRadius(12)
    }
}

struct ReflectionDistributionRow: View {
    let label: String
    let count: Int
    let total: Int
    let color: Color
    let icon: String
    
    var percentage: Double {
        guard total > 0 else { return 0 }
        return Double(count) / Double(total) * 100
    }
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.system(size: 20))
                .foregroundColor(color)
            
            Text(label)
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(.textPrimary)
            
            Spacer()
            
            Text("\(count)")
                .font(.system(size: 14, weight: .bold))
                .foregroundColor(.textPrimary)
            
            Text("(\(Int(percentage))%)")
                .font(.system(size: 12))
                .foregroundColor(.textSecondary)
            
            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 6)
                        .fill(Color.cardBackground)
                        .frame(height: 8)
                    
                    RoundedRectangle(cornerRadius: 6)
                        .fill(
                            LinearGradient(
                                colors: [color, color.opacity(0.7)],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .frame(
                            width: geometry.size.width * CGFloat(percentage / 100),
                            height: 8
                        )
                }
            }
            .frame(width: 80, height: 8)
        }
    }
}

struct ReflectionTimelineChart: View {
    let monthlyTrends: [String: (yes: Int, neutral: Int, no: Int)]
    
    var sortedMonths: [String] {
        // Ensure uniqueness by using Set
        Array(Set(monthlyTrends.keys)).sorted()
    }
    
    var maxCount: Int {
        monthlyTrends.values.map { $0.yes + $0.neutral + $0.no }.max() ?? 1
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Trend Over Time")
                .font(.system(size: 16, weight: .bold))
                .foregroundColor(.textPrimary)
            
            if sortedMonths.isEmpty {
                Text("No timeline data")
                    .font(.system(size: 14))
                    .foregroundColor(.textSecondary)
            } else {
                timelineChart
            }
        }
        .padding(16)
        .background(Color.cardBackground.opacity(0.5))
        .cornerRadius(12)
    }
    
    private var timelineChart: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(alignment: .bottom, spacing: 8) {
                // Use enumerated to ensure unique IDs
                ForEach(Array(sortedMonths.enumerated()), id: \.offset) { index, month in
                    MonthTrendBar(month: month, trends: monthlyTrends[month] ?? (0, 0, 0), maxCount: maxCount, monthLabel: monthLabel(for: month))
                }
            }
            .padding(.vertical, 8)
        }
    }
    
    private func monthLabel(for monthKey: String) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM"
        if let date = formatter.date(from: monthKey) {
            formatter.dateFormat = "MMM"
            return formatter.string(from: date)
        }
        return monthKey
    }
}

struct MonthTrendBar: View {
    let month: String
    let trends: (yes: Int, neutral: Int, no: Int)
    let maxCount: Int
    let monthLabel: String
    
    var body: some View {
        VStack(spacing: 2) {
            stackedBars
            
            Text(monthLabel)
                .font(.system(size: 9))
                .foregroundColor(.textSecondary)
                .frame(width: 30)
                .rotationEffect(.degrees(-45))
                .offset(y: 10)
        }
    }
    
    private var stackedBars: some View {
        HStack(alignment: .bottom, spacing: 2) {
            if trends.yes > 0 {
                trendBar(color: .accentGreen, count: trends.yes)
            }
            
            if trends.neutral > 0 {
                trendBar(color: .accentOrange, count: trends.neutral)
            }
            
            if trends.no > 0 {
                trendBar(color: .accentPink, count: trends.no)
            }
        }
    }
    
    private func trendBar(color: Color, count: Int) -> some View {
        RoundedRectangle(cornerRadius: 2)
            .fill(color)
            .frame(
                width: 8,
                height: max(2, CGFloat(count) / CGFloat(maxCount) * 60)
            )
    }
}
