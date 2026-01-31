import SwiftUI

struct SeasonalCommitmentsView: View {
    let commitments: [Commitment]
    
    var seasonalData: SeasonalData {
        calculateSeasonalData()
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            Text("Seasonal Commitments")
                .font(.system(size: 22, weight: .bold, design: .rounded))
                .foregroundColor(.textPrimary)
            
            if commitments.isEmpty {
                emptyState
            } else {
                VStack(spacing: 16) {
                    // Season distribution
                    SeasonDistributionChart(
                        spring: seasonalData.springCount,
                        summer: seasonalData.summerCount,
                        autumn: seasonalData.autumnCount,
                        winter: seasonalData.winterCount
                    )
                    
                    // Monthly breakdown
                    MonthlySeasonalChart(monthlyData: seasonalData.monthlyCounts)
                    
                    // Seasonal insights
                    if let mostActiveSeason = seasonalData.mostActiveSeason {
                        SeasonInsightCard(season: mostActiveSeason, count: seasonalData.mostActiveCount)
                    }
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
                                Color.accentGreen.opacity(0.3),
                                Color.accentGreen.opacity(0.1)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        lineWidth: 1
                    )
            }
        )
    }
    
    private func calculateSeasonalData() -> SeasonalData {
        let calendar = Calendar.current
        var springCount = 0
        var summerCount = 0
        var autumnCount = 0
        var winterCount = 0
        var monthlyCounts: [Int: Int] = [:]
        
        for commitment in commitments {
            let month = calendar.component(.month, from: commitment.startDate)
            monthlyCounts[month, default: 0] += 1
            
            switch month {
            case 3...5: springCount += 1
            case 6...8: summerCount += 1
            case 9...11: autumnCount += 1
            default: winterCount += 1
            }
        }
        
        let seasons = [
            ("Spring", springCount),
            ("Summer", summerCount),
            ("Autumn", autumnCount),
            ("Winter", winterCount)
        ]
        
        let mostActive = seasons.max(by: { $0.1 < $1.1 })
        
        return SeasonalData(
            springCount: springCount,
            summerCount: summerCount,
            autumnCount: autumnCount,
            winterCount: winterCount,
            monthlyCounts: monthlyCounts,
            mostActiveSeason: mostActive?.0,
            mostActiveCount: mostActive?.1 ?? 0
        )
    }
    
    private var emptyState: some View {
        VStack(spacing: 12) {
            Image(systemName: "leaf.fill")
                .font(.system(size: 40))
                .foregroundColor(.textSecondary)
            
            Text("No seasonal data")
                .font(.system(size: 16, weight: .medium))
                .foregroundColor(.textSecondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 40)
    }
}

struct SeasonalData {
    let springCount: Int
    let summerCount: Int
    let autumnCount: Int
    let winterCount: Int
    let monthlyCounts: [Int: Int]
    let mostActiveSeason: String?
    let mostActiveCount: Int
}

struct SeasonDistributionChart: View {
    let spring: Int
    let summer: Int
    let autumn: Int
    let winter: Int
    
    var total: Int {
        spring + summer + autumn + winter
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("By Season")
                .font(.system(size: 16, weight: .bold))
                .foregroundColor(.textPrimary)
            
            VStack(spacing: 12) {
                SeasonRow(
                    season: "Spring",
                    count: spring,
                    total: total,
                    color: .green,
                    icon: "leaf.fill"
                )
                
                SeasonRow(
                    season: "Summer",
                    count: summer,
                    total: total,
                    color: .yellow,
                    icon: "sun.max.fill"
                )
                
                SeasonRow(
                    season: "Autumn",
                    count: autumn,
                    total: total,
                    color: .orange,
                    icon: "leaf.fill"
                )
                
                SeasonRow(
                    season: "Winter",
                    count: winter,
                    total: total,
                    color: .blue,
                    icon: "snowflake"
                )
            }
        }
        .padding(16)
        .background(Color.cardBackground.opacity(0.5))
        .cornerRadius(12)
    }
}

struct SeasonRow: View {
    let season: String
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
                .font(.system(size: 18))
                .foregroundColor(color)
                .frame(width: 30)
            
            Text(season)
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

struct MonthlySeasonalChart: View {
    let monthlyData: [Int: Int]
    
    var sortedMonths: [(month: Int, count: Int)] {
        monthlyData.map { ($0.key, $0.value) }
            .sorted { $0.month < $1.month }
    }
    
    var maxCount: Int {
        monthlyData.values.max() ?? 1
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("By Month")
                .font(.system(size: 16, weight: .bold))
                .foregroundColor(.textPrimary)
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(alignment: .bottom, spacing: 8) {
                    ForEach(sortedMonths, id: \.month) { item in
                        VStack(spacing: 4) {
                            RoundedRectangle(cornerRadius: 4)
                                .fill(
                                    LinearGradient(
                                        colors: [.accentGreen, .accentBlue],
                                        startPoint: .bottom,
                                        endPoint: .top
                                    )
                                )
                                .frame(
                                    width: 30,
                                    height: max(4, CGFloat(item.count) / CGFloat(maxCount) * 100)
                                )
                            
                            Text(monthName(item.month))
                                .font(.system(size: 9))
                                .foregroundColor(.textSecondary)
                                .frame(width: 40)
                                .rotationEffect(.degrees(-45))
                                .offset(y: 10)
                        }
                    }
                }
                .padding(.vertical, 8)
            }
        }
        .padding(16)
        .background(Color.cardBackground.opacity(0.5))
        .cornerRadius(12)
    }
    
    private func monthName(_ month: Int) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM"
        let date = Calendar.current.date(from: DateComponents(month: month)) ?? Date()
        return formatter.string(from: date)
    }
}

struct SeasonInsightCard: View {
    let season: String
    let count: Int
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: "star.fill")
                .font(.system(size: 24))
                .foregroundColor(.accentOrange)
            
            VStack(alignment: .leading, spacing: 4) {
                Text("Most Active Season")
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(.textSecondary)
                
                Text("\(season) (\(count) commitments)")
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(.textPrimary)
            }
            
            Spacer()
        }
        .padding(16)
        .background(
            LinearGradient(
                colors: [
                    Color.accentOrange.opacity(0.2),
                    Color.accentOrange.opacity(0.1)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        )
        .cornerRadius(12)
    }
}
