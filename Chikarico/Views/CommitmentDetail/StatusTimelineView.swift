import SwiftUI

struct StatusTimelineView: View {
    let commitment: Commitment
    
    var timelinePeriods: [TimelinePeriod] {
        var periods: [TimelinePeriod] = []
        let today = Date()
        
        // Start period
        periods.append(TimelinePeriod(
            startDate: commitment.startDate,
            endDate: commitment.startDate,
            status: .active
        ))
        
        // Process history to build timeline
        let sortedHistory = commitment.history.entries.sorted { $0.timestamp < $1.timestamp }
        
        for entry in sortedHistory {
            switch entry.type {
            case .paused:
                if let lastPeriod = periods.last {
                    let pausedDate = entry.timestamp
                    if lastPeriod.endDate < pausedDate {
                        periods[periods.count - 1].endDate = pausedDate
                        periods.append(TimelinePeriod(
                            startDate: pausedDate,
                            endDate: pausedDate,
                            status: .paused(pausedAt: pausedDate)
                        ))
                    }
                }
            case .resumed:
                if let lastPeriod = periods.last, case .paused = lastPeriod.status {
                    let resumedDate = entry.timestamp
                    periods[periods.count - 1].endDate = resumedDate
                    periods.append(TimelinePeriod(
                        startDate: resumedDate,
                        endDate: today,
                        status: .active
                    ))
                }
            case .markedEnding:
                if let endDate = extractEndDate(from: commitment.status) {
                    periods.append(TimelinePeriod(
                        startDate: entry.timestamp,
                        endDate: endDate,
                        status: .ending(endDate: endDate)
                    ))
                }
            case .archived:
                if periods.last != nil {
                    periods[periods.count - 1].endDate = entry.timestamp
                }
            default:
                break
            }
        }
        
        // Update last period end date
        if periods.last != nil {
            if case .archived = commitment.status {
                // Already handled
            } else if case .ending(let endDate) = commitment.status {
                periods[periods.count - 1].endDate = endDate
            } else {
                periods[periods.count - 1].endDate = today
            }
        }
        
        return periods
    }
    
    private func extractEndDate(from status: CommitmentStatus) -> Date? {
        if case .ending(let endDate) = status {
            return endDate
        }
        return nil
    }
    
    var totalDuration: TimeInterval {
        let endDate = commitment.status.isActive ? Date() : (extractEndDate(from: commitment.status) ?? Date())
        return endDate.timeIntervalSince(commitment.startDate)
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            Text("Status Timeline")
                .font(.system(size: 22, weight: .bold, design: .rounded))
                .foregroundColor(.textPrimary)
            
            if timelinePeriods.isEmpty {
                VStack(spacing: 12) {
                    Image(systemName: "clock.badge.questionmark")
                        .font(.system(size: 40))
                        .foregroundColor(.textSecondary)
                    
                    Text("No timeline data")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(.textSecondary)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 40)
            } else {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 0) {
                        ForEach(Array(timelinePeriods.enumerated()), id: \.offset) { index, period in
                            TimelinePeriodBar(period: period, totalDuration: totalDuration, isLast: index == timelinePeriods.count - 1)
                        }
                    }
                    .padding(.vertical, 8)
                }
                
                // Legend
                VStack(alignment: .leading, spacing: 12) {
                    ForEach([(CommitmentStatus.active, "Active"), 
                             (CommitmentStatus.paused(pausedAt: nil), "Paused"),
                             (CommitmentStatus.ending(endDate: Date()), "Ending"),
                             (CommitmentStatus.archived, "Archived")], id: \.1) { status, name in
                        HStack(spacing: 8) {
                            RoundedRectangle(cornerRadius: 4)
                                .fill(statusColor(status))
                                .frame(width: 16, height: 16)
                            
                            Text(name)
                                .font(.system(size: 14, weight: .medium))
                                .foregroundColor(.textSecondary)
                        }
                    }
                }
                .padding(.top, 8)
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
    
    private func statusColor(_ status: CommitmentStatus) -> Color {
        switch status {
        case .active: return .accentGreen
        case .paused: return .accentOrange
        case .ending: return .accentPink
        case .archived: return .gray
        }
    }
}

struct TimelinePeriod {
    var startDate: Date
    var endDate: Date
    let status: CommitmentStatus
    
    var duration: TimeInterval {
        endDate.timeIntervalSince(startDate)
    }
}

struct TimelinePeriodBar: View {
    let period: TimelinePeriod
    let totalDuration: TimeInterval
    let isLast: Bool
    
    var width: CGFloat {
        let ratio = period.duration / totalDuration
        return max(20, CGFloat(ratio) * 300) // Minimum 20 points width
    }
    
    var body: some View {
        VStack(spacing: 4) {
            RoundedRectangle(cornerRadius: 6)
                .fill(periodColor)
                .frame(width: width, height: 32)
            
            if isLast || width > 40 {
                Text(periodDurationString)
                    .font(.system(size: 10, weight: .medium))
                    .foregroundColor(.textSecondary)
                    .frame(width: width)
            }
        }
    }
    
    private var periodColor: Color {
        switch period.status {
        case .active: return .accentGreen
        case .paused: return .accentOrange
        case .ending: return .accentPink
        case .archived: return .gray
        }
    }
    
    private var periodDurationString: String {
        let days = Int(period.duration / (24 * 3600))
        if days < 30 {
            return "\(days)d"
        } else {
            let months = days / 30
            return "\(months)m"
        }
    }
}
