import SwiftUI

struct ArchivedInsightsView: View {
    let archivedCommitments: [Commitment]
    
    var insights: ArchivedInsights {
        calculateInsights()
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            Text("Archived Insights")
                .font(.system(size: 22, weight: .bold, design: .rounded))
                .foregroundColor(.textPrimary)
            
            if archivedCommitments.isEmpty {
                emptyState
            } else {
                VStack(spacing: 16) {
                    // Total archived
                    StatCard(
                        title: "Total Archived",
                        value: "\(archivedCommitments.count)",
                        icon: "archivebox.fill",
                        color: .gray
                    )
                    
                    // Average duration before archive
                    StatCard(
                        title: "Avg Duration Before Archive",
                        value: formatDuration(insights.averageDurationBeforeArchive),
                        icon: "clock.arrow.circlepath",
                        color: .accentOrange
                    )
                    
                    // Most common reason
                    if let mostCommonReason = insights.mostCommonReason {
                        StatCard(
                            title: "Most Common Reason",
                            value: mostCommonReason,
                            icon: "info.circle.fill",
                            color: .accentPink
                        )
                    }
                    
                    // Archive timeline
                    ArchiveTimelineChart(archivedCommitments: archivedCommitments)
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
                                Color.gray.opacity(0.3),
                                Color.gray.opacity(0.1)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        lineWidth: 1
                    )
            }
        )
    }
    
    private func calculateInsights() -> ArchivedInsights {
        let durations = archivedCommitments.map { $0.activeDuration }
        let average = durations.isEmpty ? 0 : durations.reduce(0, +) / Double(durations.count)
        
        // Analyze archive reasons from history
        var reasons: [String: Int] = [:]
        for commitment in archivedCommitments {
            if let archivedEntry = commitment.history.entries.first(where: { $0.type == .archived }) {
                if let note = archivedEntry.note {
                    reasons[note, default: 0] += 1
                } else {
                    reasons["Manual Archive", default: 0] += 1
                }
            } else {
                reasons["Auto Archive", default: 0] += 1
            }
        }
        
        let mostCommon = reasons.max(by: { $0.value < $1.value })?.key
        
        return ArchivedInsights(
            averageDurationBeforeArchive: average,
            mostCommonReason: mostCommon
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
            return "\(years) years"
        }
    }
    
    private var emptyState: some View {
        VStack(spacing: 12) {
            Image(systemName: "archivebox")
                .font(.system(size: 40))
                .foregroundColor(.textSecondary)
            
            Text("No archived commitments")
                .font(.system(size: 16, weight: .medium))
                .foregroundColor(.textSecondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 40)
    }
}

struct ArchivedInsights {
    let averageDurationBeforeArchive: TimeInterval
    let mostCommonReason: String?
}

struct ArchiveTimelineChart: View {
    let archivedCommitments: [Commitment]
    
    var monthlyArchives: [String: Int] {
        var counts: [String: Int] = [:]
        
        for commitment in archivedCommitments {
            if let archivedDate = findArchivedDate(commitment) {
                let monthKey = monthKey(for: archivedDate)
                counts[monthKey, default: 0] += 1
            }
        }
        
        return counts
    }
    
    var sortedMonths: [String] {
        // Ensure uniqueness by using Set
        Array(Set(monthlyArchives.keys)).sorted()
    }
    
    var maxCount: Int {
        monthlyArchives.values.max() ?? 1
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Archive Timeline")
                .font(.system(size: 16, weight: .bold))
                .foregroundColor(.textPrimary)
            
            if sortedMonths.isEmpty {
                Text("No timeline data")
                    .font(.system(size: 14))
                    .foregroundColor(.textSecondary)
            } else {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(alignment: .bottom, spacing: 8) {
                        ForEach(sortedMonths, id: \.self) { month in
                            VStack(spacing: 4) {
                                RoundedRectangle(cornerRadius: 4)
                                    .fill(
                                        LinearGradient(
                                            colors: [.gray, .gray.opacity(0.7)],
                                            startPoint: .bottom,
                                            endPoint: .top
                                        )
                                    )
                                    .frame(
                                        width: 30,
                                        height: max(4, CGFloat(monthlyArchives[month] ?? 0) / CGFloat(maxCount) * 80)
                                    )
                                
                                Text(monthLabel(for: month))
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
        }
        .padding(16)
        .background(Color.cardBackground.opacity(0.5))
        .cornerRadius(12)
    }
    
    private func findArchivedDate(_ commitment: Commitment) -> Date? {
        return commitment.history.entries
            .first { $0.type == .archived }?
            .timestamp
    }
    
    private func monthKey(for date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM"
        return formatter.string(from: date)
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
