import SwiftUI

struct ArchivedView: View {
    @EnvironmentObject var persistence: PersistenceService
    @EnvironmentObject var router: Router
    
    var archivedCommitments: [Commitment] {
        persistence.appState.commitments.commitments.filter {
            if case .archived = $0.status {
                return true
            }
            return false
        }
    }
    
    var body: some View {
        ZStack {
            Color.backgroundPrimary
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Header
                HStack {
                    Button(action: { router.pop() }) {
                        Image(systemName: "chevron.left")
                            .font(.system(size: 18, weight: .semibold))
                            .foregroundColor(.textPrimary)
                    }
                    
                    Spacer()
                    
                    Text("Archived")
                        .font(.system(size: 20, weight: .semibold))
                        .foregroundColor(.textPrimary)
                    
                    Spacer()
                    
                    Button(action: {}) {
                        Image(systemName: "chevron.left")
                            .font(.system(size: 18, weight: .semibold))
                            .foregroundColor(.clear)
                    }
                }
                .padding(.horizontal, 20)
                .padding(.top, 8)
                .padding(.bottom, 16)
                
                if archivedCommitments.isEmpty {
                    VStack(spacing: 20) {
                        Image(systemName: "archivebox")
                            .font(.system(size: 60))
                            .foregroundColor(.textSecondary)
                        
                        Text("No archived commitments")
                            .font(.system(size: 22, weight: .semibold))
                            .foregroundColor(.textPrimary)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else {
                    ScrollView {
                        LazyVStack(spacing: 12) {
                            ForEach(archivedCommitments) { commitment in
                                ArchivedCommitmentCard(
                                    commitment: commitment,
                                    persistence: persistence
                                )
                            }
                        }
                        .padding(.horizontal, 20)
                        .padding(.bottom, 40)
                    }
                }
            }
        }
    }
}

struct ArchivedCommitmentCard: View {
    let commitment: Commitment
    let persistence: PersistenceService
    
    var category: Category? {
        persistence.appState.categories.categories.first { $0.id == commitment.categoryId }
    }
    
    var body: some View {
        HStack(spacing: 16) {
            RoundedRectangle(cornerRadius: 8)
                .fill(category?.color.color ?? .gray)
                .frame(width: 4)
            
            VStack(alignment: .leading, spacing: 6) {
                Text(commitment.title)
                    .font(.system(size: 17, weight: .semibold))
                    .foregroundColor(.textPrimary)
                
                HStack(spacing: 12) {
                    Text(commitment.startDate.formattedShort())
                        .font(.system(size: 14))
                        .foregroundColor(.textSecondary)
                    
                    if let amount = commitment.amount {
                        Text(formatAmount(amount, currency: commitment.currency))
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(.textSecondary)
                    }
                }
            }
            
            Spacer()
            
            Button(action: restoreCommitment) {
                Text("Restore")
                    .font(.system(size: 15, weight: .medium))
                    .foregroundColor(.blue)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 8)
                    .background(Color.blue.opacity(0.2))
                    .cornerRadius(8)
            }
        }
        .padding(16)
        .background(Color.cardBackground)
        .cornerRadius(16)
    }
    
    private func formatAmount(_ amount: Decimal, currency: String) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = currency == "Other" ? "" : currency
        return formatter.string(from: amount as NSDecimalNumber) ?? "\(amount) \(currency)"
    }
    
    private func restoreCommitment() {
        guard let index = persistence.appState.commitments.commitments.firstIndex(where: { $0.id == commitment.id }) else { return }
        
        let today = Date()
        let nextDate = CommitmentCalculator.computeNextOccurrence(
            from: commitment.startDate,
            cycle: commitment.cycle,
            currentDate: today
        )
        
        persistence.appState.commitments.commitments[index].status = .active
        persistence.appState.commitments.commitments[index].nextOccurrenceDate = nextDate
    }
}
