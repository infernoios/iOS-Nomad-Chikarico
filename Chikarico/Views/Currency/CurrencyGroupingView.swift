import SwiftUI

struct CurrencyGroupingView: View {
    let commitments: [Commitment]
    
    var currencyGroups: [CurrencyGroup] {
        Dictionary(grouping: commitments.filter { $0.amount != nil }, by: { $0.currency })
            .map { currency, commitments in
                let total = commitments.compactMap { $0.amount }.reduce(Decimal(0), +)
                return CurrencyGroup(
                    currency: currency,
                    commitments: commitments,
                    total: total
                )
            }
            .sorted { $0.total > $1.total }
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            Text("Currency Grouping")
                .font(.system(size: 22, weight: .bold, design: .rounded))
                .foregroundColor(.textPrimary)
            
            if currencyGroups.isEmpty {
                emptyState
            } else {
                ScrollView {
                    VStack(spacing: 16) {
                        ForEach(currencyGroups) { group in
                            CurrencyGroupCard(group: group)
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
            Image(systemName: "banknote")
                .font(.system(size: 40))
                .foregroundColor(.textSecondary)
            
            Text("No currency data")
                .font(.system(size: 16, weight: .medium))
                .foregroundColor(.textSecondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 40)
    }
}

struct CurrencyGroup: Identifiable {
    let id = UUID()
    let currency: String
    let commitments: [Commitment]
    let total: Decimal
}

struct CurrencyGroupCard: View {
    let group: CurrencyGroup
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text(group.currency == "Other" ? "Other Currency" : group.currency)
                    .font(.system(size: 18, weight: .bold, design: .rounded))
                    .foregroundColor(.textPrimary)
                
                Spacer()
                
                Text(formatAmount(group.total, currency: group.currency))
                    .font(.system(size: 18, weight: .bold))
                    .foregroundColor(.accentBlue)
            }
            
            Text("\(group.commitments.count) commitment\(group.commitments.count == 1 ? "" : "s")")
                .font(.system(size: 14))
                .foregroundColor(.textSecondary)
            
            // Commitments list
            VStack(spacing: 8) {
                ForEach(group.commitments.prefix(5)) { commitment in
                    HStack {
                        Text(commitment.title)
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(.textPrimary)
                        
                        Spacer()
                        
                        if let amount = commitment.amount {
                            Text(formatAmount(amount, currency: group.currency))
                                .font(.system(size: 14))
                                .foregroundColor(.textSecondary)
                        }
                    }
                    .padding(.vertical, 4)
                }
                
                if group.commitments.count > 5 {
                    Text("+ \(group.commitments.count - 5) more")
                        .font(.system(size: 12))
                        .foregroundColor(.textSecondary)
                        .padding(.top, 4)
                }
            }
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
