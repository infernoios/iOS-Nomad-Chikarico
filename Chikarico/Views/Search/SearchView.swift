import SwiftUI

struct SearchView: View {
    @EnvironmentObject var persistence: PersistenceService
    @EnvironmentObject var router: Router
    @State private var searchText: String = ""
    @FocusState private var isSearchFocused: Bool
    
    var filteredCommitments: [Commitment] {
        if searchText.isEmpty {
            return []
        }
        
        let text = searchText.lowercased()
        return persistence.appState.commitments.commitments.filter { commitment in
            commitment.title.lowercased().contains(text)
        }
    }
    
    var suggestions: [String] {
        if searchText.isEmpty {
            return []
        }
        
        let text = searchText.lowercased()
        var suggestions: Set<String> = []
        
        // Get titles that match
        for commitment in persistence.appState.commitments.commitments {
            let title = commitment.title.lowercased()
            if title.contains(text) && title != text {
                suggestions.insert(commitment.title)
            }
        }
        
        // Get similar titles (fuzzy match)
        for commitment in persistence.appState.commitments.commitments {
            let title = commitment.title.lowercased()
            if title.hasPrefix(text) || text.count >= 3 && title.contains(text) {
                suggestions.insert(commitment.title)
            }
        }
        
        return Array(suggestions.prefix(5))
    }
    
    var body: some View {
        ZStack {
            // Gradient background
            LinearGradient(
                colors: [
                    Color.gradientStart,
                    Color.gradientEnd,
                    Color.backgroundPrimary
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
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
                    
                    Text("Search")
                        .font(.system(size: 20, weight: .bold, design: .rounded))
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
                
                // Search field
                HStack(spacing: 12) {
                    Image(systemName: "magnifyingglass")
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundColor(.textSecondary)
                    
                    TextField("Search commitments...", text: $searchText)
                        .font(.system(size: 17, weight: .medium))
                        .foregroundColor(.textPrimary)
                        .focused($isSearchFocused)
                        .autocorrectionDisabled()
                    
                    if !searchText.isEmpty {
                        Button(action: {
                            searchText = ""
                        }) {
                            Image(systemName: "xmark.circle.fill")
                                .font(.system(size: 18))
                                .foregroundColor(.textSecondary)
                        }
                    }
                }
                .padding(16)
                .background(
                    ZStack {
                        RoundedRectangle(cornerRadius: 16)
                            .fill(Color.cardBackground)
                        
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(
                                isSearchFocused
                                    ? LinearGradient(colors: [.accentBlue, .accentPurple], startPoint: .leading, endPoint: .trailing)
                                    : LinearGradient(colors: [Color.clear], startPoint: .leading, endPoint: .trailing),
                                lineWidth: 2
                            )
                    }
                )
                .padding(.horizontal, 20)
                .padding(.bottom, 16)
                
                if !searchText.isEmpty {
                    ScrollView {
                        VStack(spacing: 16) {
                            // Suggestions
                            if !suggestions.isEmpty {
                                VStack(alignment: .leading, spacing: 12) {
                                    Text("Suggestions")
                                        .font(.system(size: 15, weight: .semibold))
                                        .foregroundColor(.textSecondary)
                                        .padding(.horizontal, 20)
                                    
                                    ForEach(suggestions, id: \.self) { suggestion in
                                        Button(action: {
                                            searchText = suggestion
                                        }) {
                                            HStack(spacing: 12) {
                                                Image(systemName: "arrow.up.left")
                                                    .font(.system(size: 14))
                                                    .foregroundColor(.accentBlue)
                                                
                                                Text(suggestion)
                                                    .font(.system(size: 16, weight: .medium))
                                                    .foregroundColor(.textPrimary)
                                                
                                                Spacer()
                                            }
                                            .padding(16)
                                            .background(Color.cardBackground)
                                            .cornerRadius(12)
                                        }
                                        .padding(.horizontal, 20)
                                    }
                                }
                            }
                            
                            // Results
                            if !filteredCommitments.isEmpty {
                                VStack(alignment: .leading, spacing: 12) {
                                    Text("Results (\(filteredCommitments.count))")
                                        .font(.system(size: 15, weight: .semibold))
                                        .foregroundColor(.textSecondary)
                                        .padding(.horizontal, 20)
                                    
                                    ForEach(filteredCommitments) { commitment in
                                        SearchResultCard(commitment: commitment, router: router, persistence: persistence)
                                    }
                                }
                            } else if !searchText.isEmpty {
                                VStack(spacing: 16) {
                                    Image(systemName: "magnifyingglass")
                                        .font(.system(size: 50))
                                        .foregroundColor(.textSecondary)
                                    
                                    Text("No commitments found")
                                        .font(.system(size: 18, weight: .semibold))
                                        .foregroundColor(.textPrimary)
                                    
                                    Text("Try a different search term")
                                        .font(.system(size: 14))
                                        .foregroundColor(.textSecondary)
                                }
                                .frame(maxWidth: .infinity)
                                .padding(.top, 60)
                            }
                        }
                        .padding(.bottom, 40)
                    }
                } else {
                    VStack(spacing: 20) {
                        Image(systemName: "magnifyingglass")
                            .font(.system(size: 60))
                            .foregroundStyle(
                                LinearGradient(
                                    colors: [.accentBlue, .accentPurple],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                        
                        Text("Search commitments")
                            .font(.system(size: 20, weight: .bold, design: .rounded))
                            .foregroundColor(.textPrimary)
                        
                        Text("Start typing to search by title")
                            .font(.system(size: 15))
                            .foregroundColor(.textSecondary)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                }
            }
        }
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                isSearchFocused = true
            }
        }
    }
}

struct SearchResultCard: View {
    let commitment: Commitment
    let router: Router
    let persistence: PersistenceService
    
    var category: Category? {
        persistence.appState.categories.categories.first { $0.id == commitment.categoryId }
    }
    
    var body: some View {
        Button(action: {
            router.push(.commitmentDetail(id: commitment.id))
        }) {
            HStack(spacing: 16) {
                RoundedRectangle(cornerRadius: 8)
                    .fill(category?.color.color ?? .gray)
                    .frame(width: 4)
                
                VStack(alignment: .leading, spacing: 6) {
                    Text(commitment.title)
                        .font(.system(size: 17, weight: .semibold))
                        .foregroundColor(.textPrimary)
                        .multilineTextAlignment(.leading)
                    
                    HStack(spacing: 12) {
                        Text(commitment.nextOccurrenceDate.formattedRelative())
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
            }
            .padding(16)
            .background(Color.cardBackground)
            .cornerRadius(16)
        }
        .buttonStyle(PlainButtonStyle())
        .padding(.horizontal, 20)
    }
    
    private func formatAmount(_ amount: Decimal, currency: String) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = currency == "Other" ? "" : currency
        return formatter.string(from: amount as NSDecimalNumber) ?? "\(amount) \(currency)"
    }
}
