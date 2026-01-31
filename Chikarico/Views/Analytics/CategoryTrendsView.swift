import SwiftUI

struct CategoryTrendsView: View {
    let commitments: [Commitment]
    let categories: [Category]
    @State private var selectedMonths: Int = 6
    @State private var cachedTrendData: [CategoryTrendData] = []
    @State private var cachedMonths: Int = 0
    
    var trendData: [CategoryTrendData] {
        cachedTrendData
    }
    
    var allCategoryNames: [String] {
        // Use Set to ensure uniqueness, then convert to array and sort
        let uniqueNames = Set(trendData.flatMap { Array($0.categoryCounts.keys) })
        return Array(uniqueNames).sorted()
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            HStack {
                Text("Category Trends")
                    .font(.system(size: 22, weight: .bold, design: .rounded))
                    .foregroundColor(.textPrimary)
                
                Spacer()
                
                Picker("", selection: $selectedMonths) {
                    Text("3 months").tag(3)
                    Text("6 months").tag(6)
                    Text("12 months").tag(12)
                }
                .pickerStyle(.menu)
            }
            
            if trendData.isEmpty {
                emptyState
            } else {
                ScrollView {
                    VStack(spacing: 20) {
                        ForEach(trendData) { data in
                            CategoryTrendMonthCard(data: data, allCategories: allCategoryNames, categories: categories)
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
        .onAppear {
            loadTrendData()
        }
        .onChange(of: selectedMonths) { _ in
            loadTrendData()
        }
        .onChange(of: commitments.count) { _ in
            loadTrendData()
        }
    }
    
    private func loadTrendData() {
        DispatchQueue.global(qos: .userInitiated).async {
            let data = AnalyticsService.categoryTrends(commitments: commitments, categories: categories, months: selectedMonths)
            DispatchQueue.main.async {
                self.cachedTrendData = data
                self.cachedMonths = selectedMonths
            }
        }
    }
    
    private var emptyState: some View {
        VStack(spacing: 12) {
            Image(systemName: "chart.pie")
                .font(.system(size: 40))
                .foregroundColor(.textSecondary)
            
            Text("No trend data")
                .font(.system(size: 16, weight: .medium))
                .foregroundColor(.textSecondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 40)
    }
}

struct CategoryTrendMonthCard: View {
    let data: CategoryTrendData
    let allCategories: [String]
    let categories: [Category]
    
    var totalCount: Int {
        data.categoryCounts.values.reduce(0, +)
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(formatMonth(data.month))
                .font(.system(size: 18, weight: .bold, design: .rounded))
                .foregroundColor(.textPrimary)
            
            VStack(spacing: 8) {
                // Use enumerated to ensure unique IDs
                ForEach(Array(allCategories.enumerated()), id: \.offset) { index, categoryName in
                    if let count = data.categoryCounts[categoryName], count > 0 {
                        CategoryTrendRow(
                            categoryName: categoryName,
                            count: count,
                            total: totalCount,
                            category: categories.first { $0.name == categoryName }
                        )
                    }
                }
            }
        }
        .padding(16)
        .background(Color.cardBackground.opacity(0.5))
        .cornerRadius(12)
    }
    
    private func formatMonth(_ monthKey: String) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM"
        if let date = formatter.date(from: monthKey) {
            formatter.dateFormat = "MMMM yyyy"
            return formatter.string(from: date)
        }
        return monthKey
    }
}

struct CategoryTrendRow: View {
    let categoryName: String
    let count: Int
    let total: Int
    let category: Category?
    
    var percentage: Double {
        guard total > 0 else { return 0 }
        return Double(count) / Double(total) * 100
    }
    
    var body: some View {
        HStack(spacing: 12) {
            RoundedRectangle(cornerRadius: 4)
                .fill(category?.color.color ?? .gray)
                .frame(width: 12, height: 12)
            
            Text(categoryName)
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(.textPrimary)
            
            Spacer()
            
            Text("\(count)")
                .font(.system(size: 14, weight: .bold))
                .foregroundColor(.textPrimary)
            
            Text("(\(Int(percentage))%)")
                .font(.system(size: 12))
                .foregroundColor(.textSecondary)
            
            // Progress bar
            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 4)
                        .fill(Color.cardBackground)
                        .frame(height: 6)
                    
                    RoundedRectangle(cornerRadius: 4)
                        .fill(
                            LinearGradient(
                                colors: [
                                    category?.color.color ?? .gray,
                                    (category?.color.color ?? .gray).opacity(0.7)
                                ],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .frame(width: geometry.size.width * CGFloat(percentage / 100), height: 6)
                }
            }
            .frame(width: 60, height: 6)
        }
    }
}
