import SwiftUI

struct CommitmentProjectionView: View {
    let commitment: Commitment
    @State private var projectionMonths: Int = 12
    
    var projections: [ProjectionEntry] {
        calculateProjections()
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            HStack {
                Text("Commitment Projection")
                    .font(.system(size: 22, weight: .bold, design: .rounded))
                    .foregroundColor(.textPrimary)
                
                Spacer()
                
                Picker("", selection: $projectionMonths) {
                    Text("6 months").tag(6)
                    Text("12 months").tag(12)
                    Text("24 months").tag(24)
                }
                .pickerStyle(.menu)
            }
            
            if projections.isEmpty {
                emptyState
            } else {
                ScrollView {
                    VStack(spacing: 12) {
                        ForEach(projections) { projection in
                            ProjectionCard(projection: projection, commitment: commitment)
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
    
    private func calculateProjections() -> [ProjectionEntry] {
        guard commitment.status.isActive else { return [] }
        
        let calendar = Calendar.current
        var projections: [ProjectionEntry] = []
        var currentDate = Date()
        let endDate = calendar.date(byAdding: .month, value: projectionMonths, to: currentDate) ?? currentDate
        
        while currentDate <= endDate {
            let nextOccurrence = CommitmentCalculator.computeNextOccurrence(
                from: commitment.startDate,
                cycle: commitment.cycle,
                currentDate: currentDate
            )
            
            if nextOccurrence <= endDate {
                projections.append(ProjectionEntry(
                    date: nextOccurrence,
                    amount: commitment.amount
                ))
                currentDate = calendar.date(byAdding: .day, value: 1, to: nextOccurrence) ?? nextOccurrence
            } else {
                break
            }
        }
        
        return projections
    }
    
    private var emptyState: some View {
        VStack(spacing: 12) {
            Image(systemName: "chart.line.uptrend.xyaxis")
                .font(.system(size: 40))
                .foregroundColor(.textSecondary)
            
            Text("No projection data")
                .font(.system(size: 16, weight: .medium))
                .foregroundColor(.textSecondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 40)
    }
}

struct ProjectionEntry: Identifiable {
    let id = UUID()
    let date: Date
    let amount: Decimal?
}

struct ProjectionCard: View {
    let projection: ProjectionEntry
    let commitment: Commitment
    
    var body: some View {
        HStack(spacing: 16) {
            ZStack {
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [
                                Color.accentPurple.opacity(0.3),
                                Color.accentPurple.opacity(0.2)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 44, height: 44)
                
                Image(systemName: "calendar")
                    .font(.system(size: 20, weight: .semibold))
                    .foregroundColor(.accentPurple)
            }
            
            VStack(alignment: .leading, spacing: 6) {
                Text(projection.date.formattedShort())
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(.textPrimary)
                
                Text(projection.date.formattedRelative())
                    .font(.system(size: 13))
                    .foregroundColor(.textSecondary)
                
                if let amount = projection.amount {
                    Text(formatAmount(amount, currency: commitment.currency))
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(.accentGreen)
                }
            }
            
            Spacer()
        }
        .padding(16)
        .background(Color.cardBackground.opacity(0.5))
        .cornerRadius(12)
    }
    
    private func formatAmount(_ amount: Decimal, currency: String) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = currency == "Other" ? "" : currency
        return formatter.string(from: amount as NSDecimalNumber) ?? "\(amount) \(currency)"
    }
}
