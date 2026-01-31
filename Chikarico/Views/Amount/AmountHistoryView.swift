import SwiftUI

struct AmountHistoryView: View {
    let commitment: Commitment
    
    var amountHistory: [AmountHistoryEntry] {
        var entries: [AmountHistoryEntry] = []
        
        // Initial amount
        if let initialAmount = commitment.amount {
            entries.append(AmountHistoryEntry(
                date: commitment.startDate,
                amount: initialAmount,
                currency: commitment.currency,
                type: .initial
            ))
        }
        
        // Amount changes from history
        for entry in commitment.history.entries where entry.type == .amountChanged {
            if let newValue = entry.newValue,
               let amount = extractAmount(from: newValue) {
                entries.append(AmountHistoryEntry(
                    date: entry.timestamp,
                    amount: amount,
                    currency: commitment.currency,
                    type: .changed
                ))
            }
        }
        
        return entries.sorted { $0.date > $1.date }
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            Text("Amount History")
                .font(.system(size: 22, weight: .bold, design: .rounded))
                .foregroundColor(.textPrimary)
            
            if amountHistory.isEmpty {
                emptyState
            } else {
                ScrollView {
                    VStack(spacing: 12) {
                        ForEach(amountHistory) { entry in
                            AmountHistoryCard(entry: entry)
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
    
    private func extractAmount(from value: String) -> Decimal? {
        // Remove currency symbols and parse
        let cleaned = value.replacingOccurrences(of: "$", with: "")
            .replacingOccurrences(of: "€", with: "")
            .replacingOccurrences(of: "£", with: "")
            .replacingOccurrences(of: "¥", with: "")
            .replacingOccurrences(of: ",", with: "")
            .trimmingCharacters(in: .whitespaces)
        
        return Decimal(string: cleaned)
    }
    
    private var emptyState: some View {
        VStack(spacing: 12) {
            Image(systemName: "dollarsign.circle")
                .font(.system(size: 40))
                .foregroundColor(.textSecondary)
            
            Text("No amount history")
                .font(.system(size: 16, weight: .medium))
                .foregroundColor(.textSecondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 40)
    }
}

struct AmountHistoryEntry: Identifiable {
    let id = UUID()
    let date: Date
    let amount: Decimal
    let currency: String
    let type: AmountChangeType
}

enum AmountChangeType {
    case initial
    case changed
    
    var displayName: String {
        switch self {
        case .initial: return "Initial"
        case .changed: return "Changed"
        }
    }
}

struct AmountHistoryCard: View {
    let entry: AmountHistoryEntry
    
    var body: some View {
        HStack(spacing: 16) {
            ZStack {
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [
                                Color.accentGreen.opacity(0.3),
                                Color.accentGreen.opacity(0.2)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 44, height: 44)
                
                Image(systemName: "dollarsign.circle.fill")
                    .font(.system(size: 20, weight: .semibold))
                    .foregroundColor(.accentGreen)
            }
            
            VStack(alignment: .leading, spacing: 6) {
                Text(formatAmount(entry.amount, currency: entry.currency))
                    .font(.system(size: 18, weight: .bold))
                    .foregroundColor(.textPrimary)
                
                HStack(spacing: 8) {
                    Text(entry.type.displayName)
                        .font(.system(size: 13, weight: .medium))
                        .foregroundColor(.textSecondary)
                    
                    Text("•")
                        .foregroundColor(.textSecondary)
                    
                    Text(entry.date.formattedRelative())
                        .font(.system(size: 13))
                        .foregroundColor(.textSecondary)
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
