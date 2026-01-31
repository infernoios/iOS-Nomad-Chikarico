import SwiftUI

struct DurationStatsView: View {
    let commitments: [Commitment]
    
    var stats: DurationStatistics {
        calculateStats()
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            Text("Duration Statistics")
                .font(.system(size: 22, weight: .bold, design: .rounded))
                .foregroundColor(.textPrimary)
            
            if commitments.isEmpty {
                emptyState
            } else {
                VStack(spacing: 16) {
                    // Average duration
                    StatCard(
                        title: "Average Duration",
                        value: formatDuration(stats.averageDuration),
                        icon: "clock.fill",
                        color: .accentBlue
                    )
                    
                    // Longest duration
                    if let longest = stats.longestCommitment {
                        StatCard(
                            title: "Longest Running",
                            value: longest.title,
                            subtitle: formatDuration(longest.activeDuration),
                            icon: "hourglass.tophalf.fill",
                            color: .accentGreen
                        )
                    }
                    
                    // Shortest duration
                    if let shortest = stats.shortestCommitment {
                        StatCard(
                            title: "Shortest Duration",
                            value: shortest.title,
                            subtitle: formatDuration(shortest.activeDuration),
                            icon: "hourglass.bottomhalf.fill",
                            color: .accentOrange
                        )
                    }
                    
                    // Duration distribution
                    DurationDistributionChart(durations: stats.durations)
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
                                Color.accentBlue.opacity(0.3),
                                Color.accentBlue.opacity(0.1)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        lineWidth: 1
                    )
            }
        )
    }
    
    private func calculateStats() -> DurationStatistics {
        let durations = commitments.map { $0.activeDuration }
        let average = durations.isEmpty ? 0 : durations.reduce(0, +) / Double(durations.count)
        
        let longest = commitments.max(by: { $0.activeDuration < $1.activeDuration })
        let shortest = commitments.min(by: { $0.activeDuration < $1.activeDuration })
        
        return DurationStatistics(
            averageDuration: average,
            longestCommitment: longest,
            shortestCommitment: shortest,
            durations: durations
        )
    }
    
    private func formatDuration(_ duration: TimeInterval) -> String {
        let days = Int(duration / (24 * 3600))
        if days < 30 {
            return "\(days) days"
        } else if days < 365 {
            let months = days / 30
            return "\(months) months"
        } else {
            let years = days / 365
            let remainingMonths = (days % 365) / 30
            if remainingMonths > 0 {
                return "\(years) years, \(remainingMonths) months"
            }
            return "\(years) years"
        }
    }
    
    private var emptyState: some View {
        VStack(spacing: 12) {
            Image(systemName: "chart.bar.doc.horizontal")
                .font(.system(size: 40))
                .foregroundColor(.textSecondary)
            
            Text("No duration data")
                .font(.system(size: 16, weight: .medium))
                .foregroundColor(.textSecondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 40)
    }
}

struct DurationStatistics {
    let averageDuration: TimeInterval
    let longestCommitment: Commitment?
    let shortestCommitment: Commitment?
    let durations: [TimeInterval]
}

struct StatCard: View {
    let title: String
    let value: String
    var subtitle: String? = nil
    let icon: String
    let color: Color
    
    var body: some View {
        HStack(spacing: 16) {
            ZStack {
                RoundedRectangle(cornerRadius: 12)
                    .fill(
                        LinearGradient(
                            colors: [
                                color.opacity(0.3),
                                color.opacity(0.2)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 50, height: 50)
                
                Image(systemName: icon)
                    .font(.system(size: 24, weight: .semibold))
                    .foregroundColor(color)
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(.textSecondary)
                
                Text(value)
                    .font(.system(size: 18, weight: .bold))
                    .foregroundColor(.textPrimary)
                
                if let subtitle = subtitle {
                    Text(subtitle)
                        .font(.system(size: 12))
                        .foregroundColor(.textSecondary)
                }
            }
            
            Spacer()
        }
        .padding(16)
        .background(Color.cardBackground.opacity(0.5))
        .cornerRadius(12)
    }
}

struct DurationDistributionChart: View {
    let durations: [TimeInterval]
    
    var buckets: [(range: String, count: Int)] {
        var buckets: [String: Int] = [
            "< 1 month": 0,
            "1-3 months": 0,
            "3-6 months": 0,
            "6-12 months": 0,
            "1-2 years": 0,
            "> 2 years": 0
        ]
        
        for duration in durations {
            let days = Int(duration / (24 * 3600))
            if days < 30 {
                buckets["< 1 month"]! += 1
            } else if days < 90 {
                buckets["1-3 months"]! += 1
            } else if days < 180 {
                buckets["3-6 months"]! += 1
            } else if days < 365 {
                buckets["6-12 months"]! += 1
            } else if days < 730 {
                buckets["1-2 years"]! += 1
            } else {
                buckets["> 2 years"]! += 1
            }
        }
        
        return buckets.map { ($0.key, $0.value) }.sorted { $0.1 > $1.1 }
    }
    
    var maxCount: Int {
        buckets.map { $0.count }.max() ?? 1
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Distribution")
                .font(.system(size: 16, weight: .bold))
                .foregroundColor(.textPrimary)
            
            ForEach(Array(buckets.enumerated()), id: \.offset) { index, bucket in
                VStack(alignment: .leading, spacing: 6) {
                    HStack {
                        Text(bucket.range)
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(.textPrimary)
                        
                        Spacer()
                        
                        Text("\(bucket.count)")
                            .font(.system(size: 14, weight: .bold))
                            .foregroundColor(.textPrimary)
                    }
                    
                    GeometryReader { geometry in
                        ZStack(alignment: .leading) {
                            RoundedRectangle(cornerRadius: 6)
                                .fill(Color.cardBackground)
                                .frame(height: 8)
                            
                            RoundedRectangle(cornerRadius: 6)
                                .fill(
                                    LinearGradient(
                                        colors: [
                                            Color.accentBlue,
                                            Color.accentPurple
                                        ],
                                        startPoint: .leading,
                                        endPoint: .trailing
                                    )
                                )
                                .frame(
                                    width: geometry.size.width * CGFloat(bucket.count) / CGFloat(maxCount),
                                    height: 8
                                )
                        }
                    }
                    .frame(height: 8)
                }
            }
        }
        .padding(16)
        .background(Color.cardBackground.opacity(0.5))
        .cornerRadius(12)
    }
}
