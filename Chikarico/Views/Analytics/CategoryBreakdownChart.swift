import SwiftUI

struct CategoryBreakdownChart: View {
    let commitments: [Commitment]
    let categories: [Category]
    
    var categoryCounts: [(Category, Int)] {
        let counts = Dictionary(grouping: commitments, by: { $0.categoryId })
            .mapValues { $0.count }
        
        return categories
            .filter { counts[$0.id] != nil }
            .map { ($0, counts[$0.id] ?? 0) }
            .sorted { $0.1 > $1.1 }
    }
    
    var totalCount: Int {
        categoryCounts.reduce(0) { $0 + $1.1 }
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            Text("Category Breakdown")
                .font(.system(size: 22, weight: .bold, design: .rounded))
                .foregroundColor(.textPrimary)
            
            if categoryCounts.isEmpty {
                emptyState
            } else {
                VStack(spacing: 16) {
                    // Visual bars
                    ForEach(Array(categoryCounts.enumerated()), id: \.offset) { index, item in
                        CategoryBreakdownRow(
                            category: item.0,
                            count: item.1,
                            total: totalCount,
                            rank: index + 1
                        )
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
                                Color.accentPink.opacity(0.3),
                                Color.accentPink.opacity(0.1)
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
            Image(systemName: "chart.pie")
                .font(.system(size: 40))
                .foregroundColor(.textSecondary)
            
            Text("No category data")
                .font(.system(size: 16, weight: .medium))
                .foregroundColor(.textSecondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 40)
    }
}

struct CategoryBreakdownRow: View {
    let category: Category
    let count: Int
    let total: Int
    let rank: Int
    
    var percentage: Double {
        guard total > 0 else { return 0 }
        return Double(count) / Double(total) * 100
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text("#\(rank)")
                    .font(.system(size: 14, weight: .bold))
                    .foregroundColor(.textSecondary)
                    .frame(width: 30)
                
                RoundedRectangle(cornerRadius: 6)
                    .fill(
                        LinearGradient(
                            colors: [
                                category.color.color,
                                category.color.color.opacity(0.7)
                            ],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .frame(width: 20, height: 20)
                
                Text(category.name)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(.textPrimary)
                
                Spacer()
                
                Text("\(count)")
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(.textPrimary)
                
                Text("(\(Int(percentage))%)")
                    .font(.system(size: 14))
                    .foregroundColor(.textSecondary)
            }
            
            // Progress bar
            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 8)
                        .fill(Color.cardBackground.opacity(0.5))
                        .frame(height: 8)
                    
                    RoundedRectangle(cornerRadius: 8)
                        .fill(
                            LinearGradient(
                                colors: [
                                    category.color.color,
                                    category.color.color.opacity(0.7)
                                ],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .frame(width: geometry.size.width * CGFloat(percentage / 100), height: 8)
                        .shadow(color: category.color.color.opacity(0.5), radius: 4, x: 0, y: 0)
                }
            }
            .frame(height: 8)
        }
    }
}
