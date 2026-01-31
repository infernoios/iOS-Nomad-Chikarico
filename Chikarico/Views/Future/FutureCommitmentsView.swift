import SwiftUI

struct FutureCommitmentsView: View {
    let commitments: [Commitment]
    @State private var selectedTimeframe: Timeframe = .next30Days
    
    enum Timeframe: String, CaseIterable {
        case next7Days = "Next 7 Days"
        case next30Days = "Next 30 Days"
        case next90Days = "Next 90 Days"
        case nextYear = "Next Year"
        
        var days: Int {
            switch self {
            case .next7Days: return 7
            case .next30Days: return 30
            case .next90Days: return 90
            case .nextYear: return 365
            }
        }
    }
    
    var futureCommitments: [Commitment] {
        let calendar = Calendar.current
        let endDate = calendar.date(byAdding: .day, value: selectedTimeframe.days, to: Date()) ?? Date()
        
        return commitments
            .filter { commitment in
                commitment.status.isActive && commitment.nextOccurrenceDate <= endDate
            }
            .sorted { $0.nextOccurrenceDate < $1.nextOccurrenceDate }
    }
    
    var groupedCommitments: [Date: [Commitment]] {
        Dictionary(grouping: futureCommitments) { commitment in
            Calendar.current.startOfDay(for: commitment.nextOccurrenceDate)
        }
    }
    
    var sortedDates: [Date] {
        Array(groupedCommitments.keys).sorted()
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            HStack {
                Text("Future Commitments")
                    .font(.system(size: 22, weight: .bold, design: .rounded))
                    .foregroundColor(.textPrimary)
                
                Spacer()
                
                Picker("", selection: $selectedTimeframe) {
                    ForEach(Timeframe.allCases, id: \.self) { timeframe in
                        Text(timeframe.rawValue).tag(timeframe)
                    }
                }
                .pickerStyle(.menu)
            }
            
            if futureCommitments.isEmpty {
                emptyState
            } else {
                ScrollView {
                    VStack(spacing: 20) {
                        ForEach(sortedDates, id: \.self) { date in
                            FutureCommitmentsGroup(
                                date: date,
                                commitments: groupedCommitments[date] ?? []
                            )
                        }
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
    
    private var emptyState: some View {
        VStack(spacing: 12) {
            Image(systemName: "calendar.badge.clock")
                .font(.system(size: 40))
                .foregroundColor(.textSecondary)
            
            Text("No upcoming commitments")
                .font(.system(size: 16, weight: .medium))
                .foregroundColor(.textSecondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 40)
    }
}

struct FutureCommitmentsGroup: View {
    let date: Date
    let commitments: [Commitment]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text(date.formattedShort())
                    .font(.system(size: 18, weight: .bold, design: .rounded))
                    .foregroundColor(.textPrimary)
                
                Spacer()
                
                Text("\(commitments.count) commitment\(commitments.count == 1 ? "" : "s")")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(.textSecondary)
            }
            
            VStack(spacing: 8) {
                ForEach(commitments) { commitment in
                    FutureCommitmentCard(commitment: commitment)
                }
            }
        }
        .padding(16)
        .background(Color.cardBackground.opacity(0.5))
        .cornerRadius(12)
    }
}

struct FutureCommitmentCard: View {
    let commitment: Commitment
    
    var body: some View {
        HStack(spacing: 12) {
            RoundedRectangle(cornerRadius: 6)
                .fill(Color.accentBlue.opacity(0.3))
                .frame(width: 4)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(commitment.title)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(.textPrimary)
                
                HStack(spacing: 8) {
                    Text(commitment.nextOccurrenceDate.formattedRelative())
                        .font(.system(size: 12))
                        .foregroundColor(.textSecondary)
                    
                    if let amount = commitment.amount {
                        Text("•")
                            .foregroundColor(.textSecondary)
                        
                        Text(formatAmount(amount, currency: commitment.currency))
                            .font(.system(size: 12, weight: .medium))
                            .foregroundColor(.textSecondary)
                    }
                }
            }
            
            Spacer()
        }
        .padding(12)
        .background(Color.cardBackground)
        .cornerRadius(10)
    }
    
    private func formatAmount(_ amount: Decimal, currency: String) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = currency == "Other" ? "" : currency
        return formatter.string(from: amount as NSDecimalNumber) ?? "\(amount) \(currency)"
    }
}
